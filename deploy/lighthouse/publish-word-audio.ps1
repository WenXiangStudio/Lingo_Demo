#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [Alias('List')]
    [ValidateRange(1, 10000)]
    [int]$ListNumber,

    [string]$SourceDirectory,
    [string]$SshTarget,
    [string]$BaseUrl,
    [string]$IdentityFile,

    [ValidateRange(1, 10000)]
    [int]$ExpectedCount = 30,

    [ValidateSet('word', 'example', 'tencent_example')]
    [string]$ReleaseKind = 'word',

    [string]$ConfigPath = 'D:\LingoDemoData\word_audio_publish.json',

    [switch]$VerifyOnly,
    [switch]$DryRun,
    [switch]$CleanupRemoteStaging
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($VerifyOnly -and $DryRun) {
    throw '-VerifyOnly and -DryRun cannot be used together.'
}
if ($VerifyOnly -and $CleanupRemoteStaging) {
    throw '-CleanupRemoteStaging is only valid during a real publish.'
}

function Get-ConfigString {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter(Mandatory = $true)]
        [string]$Name
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
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [switch]$File
    )

    if (-not (Test-Path -LiteralPath $Path -PathType $(if ($File) { 'Leaf' } else { 'Container' }))) {
        throw "$Description does not exist: $Path"
    }

    $resolved = (Resolve-Path -LiteralPath $Path).Path
    if ([System.IO.Path]::GetPathRoot($resolved) -ine 'D:\') {
        throw "$Description must be stored on the D drive."
    }
    return $resolved
}

function Get-DefaultSourceDirectory {
    param(
        [int]$Number,
        [ValidateSet('word', 'example', 'tencent_example')]
        [string]$Kind
    )

    $root = 'D:\LingoDemoData'
    if (-not (Test-Path -LiteralPath $root -PathType Container)) {
        throw "Lingo data directory does not exist: $root"
    }

    $prefix = switch ($Kind) {
        'example' { 'lingo_example_audio_upload_v2' }
        'tencent_example' { 'lingo_tencent_wewinny_example_audio_upload_v2' }
        default { 'lingo_word_audio_upload_v2' }
    }
    $pattern = "${prefix}_list${Number}_*"
    $candidates = @(
        Get-ChildItem -LiteralPath $root -Directory -Filter $pattern |
            Sort-Object LastWriteTime -Descending
    )
    if ($candidates.Count -eq 0) {
        throw "No upload directory matches D:\LingoDemoData\$pattern"
    }
    if ($candidates.Count -gt 1) {
        $paths = ($candidates.FullName -join [Environment]::NewLine)
        throw "More than one upload directory matches List $Number. Use -SourceDirectory explicitly:$([Environment]::NewLine)$paths"
    }
    return $candidates[0].FullName
}

function Assert-ReleaseWav {
    param(
        [Parameter(Mandatory = $true)][System.IO.FileInfo]$File,
        [ValidateSet('word', 'example', 'tencent_example')]
        [string]$Kind
    )

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
        if (($chunkSize % 2) -ne 0) {
            $nextOffset++
        }
        if ($nextOffset -gt [int]::MaxValue) {
            throw "WAV chunk offset is too large: $($File.Name)"
        }
        $offset = [int]$nextOffset
    }

    $requiredValues = @(
        $audioFormat,
        $channels,
        $sampleRate,
        $byteRate,
        $blockAlign,
        $bitsPerSample,
        $audioDataOffset,
        $audioDataLength
    )
    if ($requiredValues -contains $null) {
        throw "WAV metadata is incomplete: $($File.Name)"
    }

    $expectedBlockAlign = $channels * 2
    $expectedByteRate = $sampleRate * $expectedBlockAlign
    $validCommonFormat = $audioFormat -eq 1 -and
        $channels -ge 1 -and
        $channels -le 2 -and
        $sampleRate -ge 8000 -and
        $sampleRate -le 96000 -and
        $bitsPerSample -eq 16 -and
        $blockAlign -eq $expectedBlockAlign -and
        $byteRate -eq $expectedByteRate -and
        ($audioDataLength % $blockAlign) -eq 0
    if (-not $validCommonFormat) {
        throw "Unexpected PCM WAV format: $($File.Name)"
    }

    if ($Kind -eq 'word') {
        if ($channels -ne 1 -or $sampleRate -ne 48000 -or $blockAlign -ne 2 -or $byteRate -ne 96000) {
            throw "Unexpected word WAV format (expected PCM, mono, 48 kHz, 16-bit): $($File.Name)"
        }
        $minimumBytes = 19200 # 200 ms at 48 kHz / mono / 16-bit
    }
    else {
        $minimumBytes = [int][Math]::Ceiling($byteRate * 0.25)
    }
    if ($audioDataLength -lt $minimumBytes) {
        throw "WAV audio is shorter than the minimum duration: $($File.Name)"
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

function Invoke-HttpVerification {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$Files,

        [Parameter(Mandatory = $true)]
        [string]$AudioBaseUrl,

        [ValidateSet('word', 'example', 'tencent_example')]
        [string]$Kind
    )

    $relativeDirectory = if ($Kind -ne 'word') { 'v1/en/examples' } else { 'v1/en' }
    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($file in $Files) {
        $fileUrl = "$AudioBaseUrl/$relativeDirectory/$($file.Name)"
        $lastFailure = $null

        for ($attempt = 1; $attempt -le 2; $attempt++) {
            try {
                $response = Invoke-WebRequest -Uri $fileUrl -Method Head -TimeoutSec 20 -UseBasicParsing
                $statusCode = [int]$response.StatusCode
                $contentType = [string]$response.Headers['Content-Type']
                $contentLengthText = [string]$response.Headers['Content-Length']

                if ($statusCode -ne 200) {
                    throw "HTTP $statusCode"
                }
                if ($contentType.Split(';')[0].Trim() -ine 'audio/wav') {
                    throw "unexpected Content-Type '$contentType'"
                }
                if (-not [string]::IsNullOrWhiteSpace($contentLengthText)) {
                    [long]$contentLength = 0
                    if (-not [long]::TryParse($contentLengthText, [ref]$contentLength)) {
                        throw "invalid Content-Length '$contentLengthText'"
                    }
                    if ($contentLength -ne $file.Length) {
                        throw "Content-Length $contentLength does not match local size $($file.Length)"
                    }
                }

                $lastFailure = $null
                break
            }
            catch {
                $lastFailure = $_.Exception.Message
                if ($attempt -lt 2) {
                    Start-Sleep -Seconds 1
                }
            }
        }

        if ($null -ne $lastFailure) {
            $failures.Add("$($file.Name): $lastFailure")
        }
    }

    Write-Host "HTTP checked: $($Files.Count)"
    Write-Host "HTTP failures: $($failures.Count)"
    if ($failures.Count -gt 0) {
        foreach ($failure in $failures) {
            Write-Host "  $failure"
        }
        throw 'HTTP verification failed.'
    }
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

if ([string]::IsNullOrWhiteSpace($SourceDirectory)) {
    $SourceDirectory = Get-DefaultSourceDirectory -Number $ListNumber -Kind $ReleaseKind
}
$SourceDirectory = Resolve-DDrivePath -Path $SourceDirectory -Description 'Upload directory'

$allFiles = @(Get-ChildItem -LiteralPath $SourceDirectory -File | Sort-Object Name)
$wavFiles = @($allFiles | Where-Object { $_.Extension -ieq '.wav' })
$unexpectedFiles = @($allFiles | Where-Object { $_.Extension -ine '.wav' })
if ($unexpectedFiles.Count -gt 0) {
    throw "Upload directory contains non-WAV files: $($unexpectedFiles.Name -join ', ')"
}
if ($wavFiles.Count -ne $ExpectedCount) {
    throw "Expected $ExpectedCount WAV files but found $($wavFiles.Count): $SourceDirectory"
}

foreach ($file in $wavFiles) {
    $fileNamePattern = switch ($ReleaseKind) {
        'example' { '^qwen3-example-[0-9a-f]{64}\.wav$' }
        'tencent_example' { '^tencent-(wewinny|wejack)-example-[0-9a-f]{64}\.wav$' }
        default { '^[0-9a-f]{64}\.wav$' }
    }
    if ($file.Name -cnotmatch $fileNamePattern) {
        throw "Invalid audio-key file name: $($file.Name)"
    }
    Assert-ReleaseWav -File $file -Kind $ReleaseKind
}

$totalBytes = ($wavFiles | Measure-Object -Property Length -Sum).Sum
Write-Host "Local files: $($wavFiles.Count)"
Write-Host 'Local failures: 0'
Write-Host "Local bytes: $totalBytes"

if ($DryRun) {
    Write-Host 'Dry run complete. No SSH, upload, publish, HTTP request, or TTS API call was made.'
    exit 0
}

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    throw "BaseUrl is required. Set it in $ConfigPath or pass -BaseUrl."
}
$BaseUrl = Get-NormalizedBaseUrl -Value $BaseUrl

if ($VerifyOnly) {
    Invoke-HttpVerification -Files $wavFiles -AudioBaseUrl $BaseUrl -Kind $ReleaseKind
    Write-Host 'Verification-only run complete. No SSH, upload, publish, or TTS API call was made.'
    exit 0
}

if ([string]::IsNullOrWhiteSpace($SshTarget)) {
    throw "SshTarget is required. Set it in $ConfigPath or pass -SshTarget."
}
if ($SshTarget -cnotmatch '^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+$') {
    throw 'SshTarget must have the form user@host and contain no spaces or shell characters.'
}

$identityArguments = @()
if (-not [string]::IsNullOrWhiteSpace($IdentityFile)) {
    $IdentityFile = Resolve-DDrivePath -Path $IdentityFile -Description 'SSH identity file' -File
    $identityArguments = @('-i', $IdentityFile, '-o', 'IdentitiesOnly=yes')
}

if ($null -eq (Get-Command scp -ErrorAction SilentlyContinue)) {
    throw 'scp was not found. Install or enable the Windows OpenSSH client.'
}
if ($null -eq (Get-Command ssh -ErrorAction SilentlyContinue)) {
    throw 'ssh was not found. Install or enable the Windows OpenSSH client.'
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$remoteStaging = "/tmp/lingo-$ReleaseKind-audio-v2-list$ListNumber-$timestamp-$PID"
$remoteDestination = if ($ReleaseKind -ne 'word') {
    '/var/www/lingo-word-audio/audio/v1/en/examples'
}
else {
    '/var/www/lingo-word-audio/audio/v1/en'
}

Write-Host 'Uploading validated WAV files to a unique remote staging directory...'
$scpArguments = @('-r', '-p') + $identityArguments + @('--', $SourceDirectory, "${SshTarget}:$remoteStaging")
& scp @scpArguments
if ($LASTEXITCODE -ne 0) {
    throw "scp failed with exit code $LASTEXITCODE. Nothing was published."
}

$cleanupCommand = ''
if ($CleanupRemoteStaging) {
    $cleanupCommand = 'rm -rf -- "$src"'
}

$remoteScript = @"
set -eu
src='$remoteStaging'
dst='$remoteDestination'
expected=$ExpectedCount
count=`$(find "`$src" -maxdepth 1 -type f -name '*.wav' | wc -l)
[ "`$count" -eq "`$expected" ] || { printf 'Remote staging count mismatch: %s\n' "`$count" >&2; exit 10; }
sudo install -d -o www-data -g www-data -m 0755 "`$dst"
for file in "`$src"/*.wav; do
  name=`${file##*/}
  if [ -e "`$dst/`$name" ] && ! cmp -s "`$file" "`$dst/`$name"; then
    printf 'Remote content conflict: %s\n' "`$name" >&2
    exit 11
  fi
done
published=0
for file in "`$src"/*.wav; do
  name=`${file##*/}
  if [ ! -e "`$dst/`$name" ]; then
    tmp="`$dst/.`$name.tmp.`$`$"
    sudo install -o www-data -g www-data -m 0644 "`$file" "`$tmp"
    sudo mv -f "`$tmp" "`$dst/`$name"
  fi
  cmp -s "`$file" "`$dst/`$name" || { printf 'Remote compare failed: %s\n' "`$name" >&2; exit 12; }
  published=`$((published + 1))
done
printf 'REMOTE_PUBLISHED=%s\n' "`$published"
$cleanupCommand
"@

Write-Host 'Publishing on the server with conflict protection...'
$sshArguments = @('-t') + $identityArguments + @('--', $SshTarget, $remoteScript)
& ssh @sshArguments
if ($LASTEXITCODE -ne 0) {
    throw "Remote publish failed with exit code $LASTEXITCODE. The staging directory was retained for inspection."
}

Invoke-HttpVerification -Files $wavFiles -AudioBaseUrl $BaseUrl -Kind $ReleaseKind

Write-Host "Published files: $($wavFiles.Count)"
Write-Host 'Publish failures: 0'
if ($CleanupRemoteStaging) {
    Write-Host 'Remote staging was removed after successful publication.'
}
else {
    Write-Host 'Remote staging was retained. Use -CleanupRemoteStaging on future successful publishes if desired.'
}
Write-Host 'Publish complete. No TTS API call was made by this script.'
