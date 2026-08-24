#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Replace', 'Rollback')]
    [string]$Action,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-f0-9]{64}\.wav$')]
    [string]$FileName,

    [string]$SourceFile,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-f0-9]{64}$')]
    [string]$ExpectedCurrentSha256,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-f0-9]{64}$')]
    [string]$ExpectedResultSha256,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, [Int64]::MaxValue)]
    [Int64]$ExpectedResultBytes,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9_-]{8,120}$')]
    [string]$OperationId,

    [ValidatePattern('^[A-Za-z0-9_-]{8,120}$')]
    [string]$ServerBackupId,

    [string]$SshTarget,
    [string]$BaseUrl,
    [string]$IdentityFile,
    [string]$ConfigPath = 'D:\LingoDemoData\word_audio_publish.json',

    # Used only by the application's explicit "Open Interactive Server
    # Command" action. The normal app path must never request a password.
    [switch]$InteractiveSudo
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ConfigString {
    param(
        [Parameter(Mandatory = $true)][psobject]$Config,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $property = $Config.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        return $null
    }
    $value = [string]$property.Value
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $null
    }
    return $value.Trim()
}

function Resolve-DDrivePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Description,
        [switch]$File
    )

    $pathType = if ($File) { 'Leaf' } else { 'Container' }
    if (-not (Test-Path -LiteralPath $Path -PathType $pathType)) {
        throw "$Description does not exist: $Path"
    }
    $resolved = (Resolve-Path -LiteralPath $Path).Path
    if ([System.IO.Path]::GetPathRoot($resolved) -ine 'D:\') {
        throw "$Description must be stored on the D drive."
    }
    return $resolved
}

function Get-NormalizedBaseUrl {
    param([Parameter(Mandatory = $true)][string]$Value)

    $trimmed = $Value.Trim().TrimEnd('/')
    $uri = $null
    if (-not [Uri]::TryCreate($trimmed, [UriKind]::Absolute, [ref]$uri) -or
        ($uri.Scheme -ne 'http' -and $uri.Scheme -ne 'https') -or
        [string]::IsNullOrWhiteSpace($uri.Host) -or
        -not [string]::IsNullOrEmpty($uri.UserInfo) -or
        -not [string]::IsNullOrEmpty($uri.Query) -or
        -not [string]::IsNullOrEmpty($uri.Fragment)) {
        throw 'BaseUrl must be an absolute HTTP(S) URL without credentials, query, or fragment.'
    }
    return $trimmed
}

function Assert-WordWav {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$File)

    [byte[]]$bytes = [System.IO.File]::ReadAllBytes($File.FullName)
    if ($bytes.Length -lt 12 -or
        [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4) -cne 'RIFF' -or
        [System.Text.Encoding]::ASCII.GetString($bytes, 8, 4) -cne 'WAVE') {
        throw "Invalid RIFF/WAVE header: $($File.Name)"
    }

    $offset = 12
    $audioFormat = $null
    $channels = $null
    $sampleRate = $null
    $byteRate = $null
    $blockAlign = $null
    $bitsPerSample = $null
    $audioDataOffset = $null
    $audioDataLength = $null

    while ($offset + 8 -le $bytes.Length) {
        $chunkId = [System.Text.Encoding]::ASCII.GetString($bytes, $offset, 4)
        [uint32]$chunkSize = [BitConverter]::ToUInt32($bytes, $offset + 4)
        [long]$chunkDataOffset = $offset + 8
        [long]$availableChunkBytes = $bytes.Length - $chunkDataOffset

        if ($chunkId -ceq 'fmt ') {
            if ($chunkSize -gt $availableChunkBytes -or $chunkSize -lt 16) {
                throw "Invalid fmt chunk: $($File.Name)"
            }
            $audioFormat = [BitConverter]::ToUInt16($bytes, [int]$chunkDataOffset)
            $channels = [BitConverter]::ToUInt16($bytes, [int]$chunkDataOffset + 2)
            $sampleRate = [BitConverter]::ToUInt32($bytes, [int]$chunkDataOffset + 4)
            $byteRate = [BitConverter]::ToUInt32($bytes, [int]$chunkDataOffset + 8)
            $blockAlign = [BitConverter]::ToUInt16($bytes, [int]$chunkDataOffset + 12)
            $bitsPerSample = [BitConverter]::ToUInt16($bytes, [int]$chunkDataOffset + 14)
        }
        elseif ($chunkId -ceq 'data') {
            $audioDataOffset = [int]$chunkDataOffset
            $audioDataLength = [int]$(if ($chunkSize -gt $availableChunkBytes) {
                    $availableChunkBytes
                }
                else {
                    $chunkSize
                })
            break
        }
        elseif ($chunkSize -gt $availableChunkBytes) {
            throw "Invalid WAV chunk: $($File.Name)"
        }

        [long]$nextOffset = $chunkDataOffset + $chunkSize
        if (($chunkSize % 2) -ne 0) { $nextOffset++ }
        if ($nextOffset -gt [int]::MaxValue) {
            throw "WAV chunk offset is too large: $($File.Name)"
        }
        $offset = [int]$nextOffset
    }

    $requiredValues = @(
        $audioFormat, $channels, $sampleRate, $byteRate,
        $blockAlign, $bitsPerSample, $audioDataOffset, $audioDataLength
    )
    if ($requiredValues -contains $null) {
        throw "WAV metadata is incomplete: $($File.Name)"
    }
    if ($audioFormat -ne 1 -or
        $channels -ne 1 -or
        $sampleRate -ne 48000 -or
        $bitsPerSample -ne 16 -or
        $blockAlign -ne 2 -or
        $byteRate -ne 96000 -or
        ($audioDataLength % $blockAlign) -ne 0) {
        throw "Unexpected WAV format (expected PCM, mono, 48 kHz, 16-bit): $($File.Name)"
    }
    if ($audioDataLength -lt 19200) {
        throw "WAV audio is shorter than 200 ms: $($File.Name)"
    }

    $audible = $false
    $audioDataEnd = $audioDataOffset + $audioDataLength
    for ($sampleOffset = $audioDataOffset; $sampleOffset + 1 -lt $audioDataEnd; $sampleOffset += 2) {
        $sample = [BitConverter]::ToInt16($bytes, $sampleOffset)
        if ([Math]::Abs([int]$sample) -ge 64) {
            $audible = $true
            break
        }
    }
    if (-not $audible) {
        throw "WAV audio is silent: $($File.Name)"
    }
}

function Get-FileSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)

    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Invoke-HttpContentVerification {
    param(
        [Parameter(Mandatory = $true)][string]$AudioBaseUrl,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][Int64]$ExpectedBytes,
        [Parameter(Mandatory = $true)][string]$ExpectedSha256,
        [Parameter(Mandatory = $true)][string]$CacheToken
    )

    $lastFailure = $null
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $response = $null
        $stream = $null
        $hasher = $null
        try {
            $uriBuilder = [System.UriBuilder]::new("$AudioBaseUrl/v1/en/$Name")
            # The pathname remains the fixed key. This unique query and no-cache
            # headers make deployment verification less likely to see a stale
            # intermediary response body.
            $uriBuilder.Query = "lingo_replace=$([Uri]::EscapeDataString($CacheToken))"
            $request = [System.Net.HttpWebRequest]::Create($uriBuilder.Uri)
            $request.Method = 'GET'
            $request.AllowAutoRedirect = $false
            $request.Timeout = 20000
            $request.ReadWriteTimeout = 20000
            $request.CachePolicy = [System.Net.Cache.RequestCachePolicy]::new(
                [System.Net.Cache.RequestCacheLevel]::Reload
            )
            $request.Headers['Cache-Control'] = 'no-cache'
            $request.Headers['Pragma'] = 'no-cache'
            $response = [System.Net.HttpWebResponse]$request.GetResponse()

            if ([int]$response.StatusCode -ne 200) {
                throw "HTTP $([int]$response.StatusCode)"
            }
            $contentType = [string]$response.ContentType
            if ($contentType.Split(';')[0].Trim() -ine 'audio/wav') {
                throw "unexpected Content-Type '$contentType'"
            }
            if ($response.ContentLength -ge 0 -and $response.ContentLength -ne $ExpectedBytes) {
                throw "Content-Length $($response.ContentLength) does not match expected size $ExpectedBytes"
            }

            $stream = $response.GetResponseStream()
            $hasher = [System.Security.Cryptography.SHA256]::Create()
            $digest = $hasher.ComputeHash($stream)
            $actualSha256 = (($digest | ForEach-Object { $_.ToString('x2') }) -join '')
            if ($actualSha256 -cne $ExpectedSha256) {
                throw "HTTP body SHA-256 $actualSha256 does not match expected $ExpectedSha256"
            }
            $lastFailure = $null
            break
        }
        catch {
            $lastFailure = $_.Exception.Message
            if ($attempt -lt 3) { Start-Sleep -Seconds 1 }
        }
        finally {
            if ($null -ne $stream) { $stream.Dispose() }
            if ($null -ne $hasher) { $hasher.Dispose() }
            if ($null -ne $response) { $response.Close() }
        }
    }

    if ($null -ne $lastFailure) {
        throw "HTTP GET SHA-256 verification failed: $lastFailure"
    }
    Write-Host 'HTTP GET checked: 1'
    Write-Host 'HTTP GET failures: 0'
}

$config = $null
if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
    $resolvedConfigPath = Resolve-DDrivePath -Path $ConfigPath -Description 'Publish config' -File
    $config = Get-Content -LiteralPath $resolvedConfigPath -Raw | ConvertFrom-Json
}
if ($null -ne $config) {
    if (-not $PSBoundParameters.ContainsKey('SshTarget')) {
        $SshTarget = Get-ConfigString -Config $config -Name 'sshTarget'
    }
    if (-not $PSBoundParameters.ContainsKey('BaseUrl')) {
        $BaseUrl = Get-ConfigString -Config $config -Name 'baseUrl'
    }
    if (-not $PSBoundParameters.ContainsKey('IdentityFile')) {
        $IdentityFile = Get-ConfigString -Config $config -Name 'identityFile'
    }
}

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    throw "BaseUrl is required. Set it in $ConfigPath or pass -BaseUrl."
}
$BaseUrl = Get-NormalizedBaseUrl -Value $BaseUrl
if ([string]::IsNullOrWhiteSpace($SshTarget)) {
    throw "SshTarget is required. Set it in $ConfigPath or pass -SshTarget."
}
if ($SshTarget -cnotmatch '^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+$') {
    throw 'SshTarget must have the form user@host and contain no spaces or shell characters.'
}
if ($null -eq (Get-Command scp -ErrorAction SilentlyContinue)) {
    throw 'scp was not found. Install or enable the Windows OpenSSH client.'
}
if ($null -eq (Get-Command ssh -ErrorAction SilentlyContinue)) {
    throw 'ssh was not found. Install or enable the Windows OpenSSH client.'
}

$identityArguments = @()
if (-not [string]::IsNullOrWhiteSpace($IdentityFile)) {
    $IdentityFile = Resolve-DDrivePath -Path $IdentityFile -Description 'SSH identity file' -File
    $identityArguments = @('-i', $IdentityFile, '-o', 'IdentitiesOnly=yes')
}

$sourceInfo = $null
if ($Action -ceq 'Replace') {
    if ([string]::IsNullOrWhiteSpace($SourceFile)) {
        throw '-SourceFile is required for -Action Replace.'
    }
    $SourceFile = Resolve-DDrivePath -Path $SourceFile -Description 'Local replacement WAV' -File
    $sourceInfo = Get-Item -LiteralPath $SourceFile -Force
    if ($sourceInfo.Name -cne $FileName) {
        throw 'The local replacement WAV name does not match the fixed server audio key.'
    }
    Assert-WordWav -File $sourceInfo
    if ($sourceInfo.Length -ne $ExpectedResultBytes) {
        throw "Local replacement size $($sourceInfo.Length) does not match the reviewed size $ExpectedResultBytes."
    }
    if ((Get-FileSha256 -Path $SourceFile) -cne $ExpectedResultSha256) {
        throw 'The local replacement WAV changed after the UI reviewed it. Nothing was uploaded.'
    }
}
elseif (-not [string]::IsNullOrWhiteSpace($SourceFile)) {
    throw '-SourceFile is only valid for -Action Replace.'
}

if ($Action -ceq 'Rollback' -and [string]::IsNullOrWhiteSpace($ServerBackupId)) {
    throw '-ServerBackupId is required for -Action Rollback.'
}

# Test sudo before creating a staging directory or uploading a candidate. A
# stable marker lets the desktop app distinguish a required visible sudo step
# from SSH, SCP, validation, compare-and-swap, and HTTP verification failures.
# `sudo -n` guarantees this non-interactive process never accepts a password.
if (-not $InteractiveSudo) {
    $sudoPreflightScript = @'
if sudo -n -v; then
  printf 'SUDO_NONINTERACTIVE_READY=1\n'
else
  printf 'INTERACTIVE_SUDO_REQUIRED=1\n'
  exit 70
fi
'@
    & ssh @identityArguments -- $SshTarget $sudoPreflightScript
    $sudoPreflightExitCode = $LASTEXITCODE
    if ($sudoPreflightExitCode -ne 0) {
        if ($sudoPreflightExitCode -eq 70) {
            exit $sudoPreflightExitCode
        }
        throw "Could not check non-interactive sudo with exit code $sudoPreflightExitCode. No server file was changed."
    }
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$remoteStaging = "/tmp/lingo-word-audio-v2-$($Action.ToLowerInvariant())-$OperationId-$timestamp-$PID"
$remoteDestination = '/var/www/lingo-word-audio/audio/v1/en'
$remoteBackupRoot = '/var/lib/lingo-word-audio/word-audio-backups/v1/en'
# Do not pass a trailing empty argument for Replace. Some remote SSH/shell
# command paths can omit it before /bin/sh receives positional parameters.
# The root script ignores this explicit invalid-for-rollback sentinel on Replace
# and still strictly validates a real backup id for Rollback.
$remoteBackupArgument = if ($Action -ceq 'Rollback') { $ServerBackupId } else { '-' }

if ($Action -ceq 'Replace') {
    $prepareStagingScript = "set -eu; umask 077; mkdir -p -- '$remoteStaging'"
    & ssh @identityArguments -- $SshTarget $prepareStagingScript
    if ($LASTEXITCODE -ne 0) {
        throw "Could not create remote staging with exit code $LASTEXITCODE. Nothing was published."
    }
    Write-Host 'Uploading one validated replacement WAV to a unique remote staging directory...'
    $remoteTarget = $SshTarget + ':' + $remoteStaging + '/' + $FileName
    $scpArguments = @('-p') + $identityArguments + @('--', $SourceFile, $remoteTarget)
    & scp @scpArguments
    if ($LASTEXITCODE -ne 0) {
        throw "scp failed with exit code $LASTEXITCODE. Nothing was published."
    }
}

$remotePrelude = @"
set -eu
src='$remoteStaging'
dst='$remoteDestination'
backup_root='$remoteBackupRoot'
name='$FileName'
action='$Action'
expected_current='$ExpectedCurrentSha256'
expected_result='$ExpectedResultSha256'
expected_result_bytes='$ExpectedResultBytes'
operation_id='$OperationId'
server_backup_id='$remoteBackupArgument'
"@

$remoteRootScript = @'
set -eu
src="$1"
dst="$2"
backup_root="$3"
name="$4"
action="$5"
expected_current="$6"
expected_result="$7"
expected_result_bytes="$8"
operation_id="$9"
shift 9
# A missing tenth argument must not cause `set -u` to abort a Replace before
# its guarded compare-and-swap logic runs. Rollback validates this value below.
server_backup_id="${1-}"

fail() {
  printf '%s\n' "$1" >&2
  exit "$2"
}

printf '%s' "$name" | grep -Eq '^[a-f0-9]{64}\.wav$' || fail 'Invalid fixed audio file name.' 40
printf '%s' "$expected_current" | grep -Eq '^[a-f0-9]{64}$' || fail 'Invalid expected current hash.' 41
printf '%s' "$expected_result" | grep -Eq '^[a-f0-9]{64}$' || fail 'Invalid expected result hash.' 42
printf '%s' "$operation_id" | grep -Eq '^[A-Za-z0-9_-]{8,120}$' || fail 'Invalid operation identifier.' 43
case "$expected_result_bytes" in ''|*[!0-9]*) fail 'Invalid expected result byte count.' 44 ;; esac
case "$action" in Replace|Rollback) ;; *) fail 'Invalid action.' 45 ;; esac

base_name=$(printf '%s' "$name" | sed 's/\.wav$//')
backup_dir="$backup_root/$base_name"
lock_root="$backup_root/.locks"
install -d -o root -g root -m 0750 "$backup_dir" "$lock_root"
lock_dir="$lock_root/$name.lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
  fail 'Another replacement or rollback is already in progress for this fixed audio key.' 46
fi
tmp=''
cleanup() {
  if [ -n "$tmp" ] && [ -e "$tmp" ]; then rm -f -- "$tmp"; fi
  rmdir "$lock_dir" 2>/dev/null || true
}
trap cleanup EXIT HUP INT TERM

current="$dst/$name"
[ -f "$current" ] || fail 'Current server WAV is missing; use the normal new-file publisher instead.' 47
actual_current=$(sha256sum "$current" | awk '{print $1}')
[ "$actual_current" = "$expected_current" ] || fail 'Remote content changed after the reviewed comparison. Nothing was replaced.' 48

if [ "$action" = 'Replace' ]; then
  candidate="$src/$name"
  [ -f "$candidate" ] || fail 'Uploaded replacement WAV is missing from remote staging.' 49
  actual_candidate=$(sha256sum "$candidate" | awk '{print $1}')
  [ "$actual_candidate" = "$expected_result" ] || fail 'Uploaded replacement WAV hash does not match the reviewed candidate.' 50
  backup_id="$operation_id"
  backup="$backup_dir/$backup_id.wav"
  audit="$backup_dir/$backup_id.json"
  [ ! -e "$backup" ] || fail 'A server backup already exists for this replacement operation.' 51
  install -o root -g root -m 0640 "$current" "$backup"
  [ "$(sha256sum "$backup" | awk '{print $1}')" = "$expected_current" ] || fail 'Server backup hash verification failed.' 52
  tmp="$dst/.$name.replace.$$.tmp"
  install -o www-data -g www-data -m 0644 "$candidate" "$tmp"
  mv -f "$tmp" "$current"
  tmp=''
  [ "$(sha256sum "$current" | awk '{print $1}')" = "$expected_result" ] || fail 'Server replacement hash verification failed.' 53
  printf '{"schemaVersion":1,"action":"replace","operationId":"%s","fileName":"%s","beforeSha256":"%s","afterSha256":"%s","createdAt":"%s"}\n' "$operation_id" "$name" "$expected_current" "$expected_result" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$audit"
  chown root:root "$audit"
  chmod 0640 "$audit"
  printf 'REMOTE_BACKUP_ID=%s\n' "$backup_id"
  printf 'REMOTE_BACKUP_PATH=%s\n' "$backup"
  printf 'REMOTE_BEFORE_SHA256=%s\n' "$expected_current"
  printf 'REMOTE_AFTER_SHA256=%s\n' "$expected_result"
  printf 'REMOTE_REPLACED=1\n'
else
  printf '%s' "$server_backup_id" | grep -Eq '^[A-Za-z0-9_-]{8,120}$' || fail 'Invalid server backup identifier.' 54
  restore="$backup_dir/$server_backup_id.wav"
  [ -f "$restore" ] || fail 'The retained server backup is unavailable; no rollback was made.' 55
  [ "$(sha256sum "$restore" | awk '{print $1}')" = "$expected_result" ] || fail 'The retained server backup hash does not match the reviewed rollback target.' 56
  backup_id="rollback_$operation_id"
  backup="$backup_dir/$backup_id.wav"
  audit="$backup_dir/$backup_id.json"
  [ ! -e "$backup" ] || fail 'A server backup already exists for this rollback operation.' 57
  install -o root -g root -m 0640 "$current" "$backup"
  [ "$(sha256sum "$backup" | awk '{print $1}')" = "$expected_current" ] || fail 'Current server backup hash verification failed.' 58
  tmp="$dst/.$name.rollback.$$.tmp"
  install -o www-data -g www-data -m 0644 "$restore" "$tmp"
  mv -f "$tmp" "$current"
  tmp=''
  [ "$(sha256sum "$current" | awk '{print $1}')" = "$expected_result" ] || fail 'Server rollback hash verification failed.' 59
  printf '{"schemaVersion":1,"action":"rollback","operationId":"%s","sourceBackupId":"%s","fileName":"%s","beforeSha256":"%s","afterSha256":"%s","createdAt":"%s"}\n' "$operation_id" "$server_backup_id" "$name" "$expected_current" "$expected_result" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$audit"
  chown root:root "$audit"
  chmod 0640 "$audit"
  printf 'REMOTE_BACKUP_ID=%s\n' "$backup_id"
  printf 'REMOTE_BACKUP_PATH=%s\n' "$backup"
  printf 'REMOTE_BEFORE_SHA256=%s\n' "$expected_current"
  printf 'REMOTE_AFTER_SHA256=%s\n' "$expected_result"
  printf 'REMOTE_ROLLED_BACK=1\n'
fi
'@

$remoteSudoCheck = if ($InteractiveSudo) {
    ''
}
else {
@'
if ! sudo -n -v; then
  printf 'INTERACTIVE_SUDO_REQUIRED=1\n'
  exit 70
fi
'@
}
$remoteSudoPrefix = if ($InteractiveSudo) { 'sudo' } else { 'sudo -n' }

# PowerShell here-strings do not retain a trailing newline before their closing
# delimiter. Build the remote Bash source from explicit lines so the quoted
# heredoc marker can never be joined to the root script's opening `set -eu`.
$remoteRootCommand =
    $remoteSudoPrefix +
    ' /bin/sh -s -- "$src" "$dst" "$backup_root" "$name" "$action" "$expected_current" "$expected_result" "$expected_result_bytes" "$operation_id" "$server_backup_id" <<''LINGO_ROOT'''
$remoteScriptParts = @(
    $remotePrelude.TrimEnd([char[]]"`r`n")
)
if (-not [string]::IsNullOrWhiteSpace($remoteSudoCheck)) {
    $remoteScriptParts += $remoteSudoCheck.TrimEnd([char[]]"`r`n")
}
$remoteScriptParts += $remoteRootCommand
$remoteScriptParts += $remoteRootScript.TrimEnd([char[]]"`r`n")
$remoteScriptParts += 'LINGO_ROOT'
$remoteScript = ($remoteScriptParts -join "`n") + "`n"

# Fail locally instead of sending a malformed script if a future edit changes
# the assembly contract. This check is intentionally before the guarded SSH
# command and cannot change the remote server.
$expectedHereDocumentStart = "<<'LINGO_ROOT'`nset -eu`n"
if (-not $remoteScript.Contains($expectedHereDocumentStart) -or
    -not $remoteScript.EndsWith("LINGO_ROOT`n")) {
    throw 'Internal remote-script assembly error: root here-document boundary is invalid. No server action was started.'
}

Write-Host "Running guarded server $($Action.ToLowerInvariant()) with one fixed audio key..."
$sshArguments = @()
if ($InteractiveSudo) {
    # The visible PowerShell window owns a terminal, so force a pseudo-TTY for
    # sudo's own prompt. The normal path intentionally uses no terminal.
    $sshArguments += '-tt'
}
$sshArguments += $identityArguments
$sshArguments += @('--', $SshTarget, $remoteScript)
& ssh @sshArguments
if ($LASTEXITCODE -ne 0) {
    throw "Remote $($Action.ToLowerInvariant()) failed with exit code $LASTEXITCODE. Review the operation audit before retrying."
}

Invoke-HttpContentVerification -AudioBaseUrl $BaseUrl -Name $FileName -ExpectedBytes $ExpectedResultBytes -ExpectedSha256 $ExpectedResultSha256 -CacheToken "$Action-$OperationId-$PID"

Write-Host "FIXED_AUDIO_KEY=$FileName"
Write-Host "SERVER_$($Action.ToUpperInvariant())_COMPLETE=1"
Write-Host 'No TTS API call was made by this script.'
