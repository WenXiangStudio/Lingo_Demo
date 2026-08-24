# Lighthouse 开发期单词 WAV 服务

本方案用于当前开发期：手机或 Windows 应用点击单词后，从 Lighthouse 请求已生成的原始 WAV；应用只在内存中播放，不把该读音写入设备持久缓存。

## 单词播放来源

应用默认选择“服务器 WAV”：单词按钮只请求下方的静态 WAV 地址，**不会请求 Qwen、豆包或 OpenAI**，也不会因为服务器缺文件而自动调用这些 API。

设置页还提供“当前 TTS 引擎（开发测试）”。只有手动切换到它后，单词按钮才会使用当前选中的 Qwen / 豆包 / OpenAI 的常规本地缓存和 API 流程；它同样不会自动回退到服务器。完成测试后请切回“服务器 WAV”。

应用请求地址固定为：

```text
http://<Lighthouse 公网 IP>/audio/v1/en/<audio-key>.wav
```

其中 `<audio-key>` 是应用按 Qwen 的固定 WAV 配置、语言和小写单词计算出的 SHA-256 值。桌面端的 Qwen 生成工具会把新 WAV 直接写为 `<audio-key>.wav`，因此上传时不需要改名。

Qwen3-TTS-Flash / Katerina 的**例句**音频与单词音频完全隔离，固定地址为：

```text
http://<Lighthouse 公网 IP>/audio/v1/en/examples/qwen3-example-<audio-key>.wav
```

例句键包含 `qwen3-tts-flash-katerina-british-instruction-example-v2`、语言和规范化后的完整例句；大小写、标点或句子内容变化会生成新键，绝不会覆盖已经验收的单词 WAV 或旧例句 WAV。v2 固定加入了朗读指令（见 §3.1），所有**新生成**的例句都只使用 v2 键。

为避免升级后把已经生成、已付费的 `qwen3-tts-flash-katerina-example-v1` 缓存误显示为丢失，应用会按“v2 → v1”顺序兼容查找本地缓存、服务器播放和服务器状态；旧文件不会被改名或覆盖。若将含 v1 文件的已验证缓存重新打包/发布，发布器会保留其原有 `qwen3-example-<sha256>.wav` 文件名，客户端也会回退到该旧键。这样既保留旧缓存，又不会让新的合成结果与旧音频共用同一键。

## 1. 在 Ubuntu 24.04 安装 Nginx

以下操作在 Lighthouse 内完成。把命令中的占位符替换为自己的登录用户和公网 IP；不要把私钥或密码放进应用仓库。

```bash
sudo apt update
sudo apt install -y nginx
sudo install -d -o www-data -g www-data -m 0755 /var/www/lingo-word-audio/audio/v1/en
sudo install -d -m 0755 /tmp/lingo-word-audio
```

复制仓库中的 [Nginx 模板](../deploy/lighthouse/lingo-word-audio.nginx.conf.template)，将 `LIGHTHOUSE_PUBLIC_IP` 替换为 Lighthouse 的固定公网 IP，保存为：

```text
/etc/nginx/sites-available/lingo-word-audio
```

然后启用并检查配置：

```bash
sudo ln -s /etc/nginx/sites-available/lingo-word-audio /etc/nginx/sites-enabled/lingo-word-audio
sudo nginx -t
sudo systemctl reload nginx
```

还需要在 Lighthouse 防火墙/安全组允许入站 TCP 80；如果 Ubuntu 启用了 UFW，也运行：

```bash
sudo ufw allow 'Nginx HTTP'
```

如果这台服务器已有占用 80 端口的 Nginx `server` 块，请先合并配置或选定同一个 Nginx 实例，不要新增第二个 Web 服务器。

## 2. 在桌面端生成上传用 WAV

在应用的“设置 → 语音引擎 → Qwen Audio TTS”中，保持已确认的固定参数：WAV、48 kHz、音量 50、语速 1.0、音高 1.0、seed 0。点击生成 CET-4 List 后，文件会落在：

```text
D:\LingoDemoData\lingo_tts_cache\
```

本次方案生成的上传文件名满足：

```text
^[0-9a-f]{64}\.wav$
```

旧的 `*-qwen-en.mp3` 或旧 WAV 文件不要上传；它们不会被新的远程键使用。为避免 600 MB 的生成任务被自动删除，将“WAV 暂存存储”保持为 `0`（不限）直到上传核验完成。

## 3. 一键上传、发布并核验（推荐）

仓库提供了 [一键发布脚本](../deploy/lighthouse/publish-word-audio.ps1)。它不会生成音频或调用 TTS API，只处理已经准备好的 List 上传目录。脚本会依次完成：

1. 检查文件数量和 64 位 SHA-256 文件名。
2. 按生产参数检查每个 WAV：PCM、48 kHz、单声道、16-bit、至少 200 ms 且非静音。
3. 上传到唯一的服务器临时目录。
4. 检查正式目录中是否存在同名但内容不同的文件；发现冲突则整批停止。
5. 逐文件原子发布，并用公网地址检查 HTTP 200、`Content-Type: audio/wav` 和文件长度。

先将示例配置复制到 D 盘数据目录，再把占位符改为实际地址。配置中不要写密码：

```powershell
Copy-Item -LiteralPath .\deploy\lighthouse\word-audio-publish.config.example.json `
  -Destination D:\LingoDemoData\word_audio_publish.json
```

只做本地预检，不连接服务器：

```powershell
.\deploy\lighthouse\publish-word-audio.ps1 -List 3 -DryRun
```

只检查已经发布的公网文件，不上传、不覆盖：

```powershell
.\deploy\lighthouse\publish-word-audio.ps1 -List 3 -VerifyOnly
```

对已经生成并打包的下一批执行完整发布：

```powershell
.\deploy\lighthouse\publish-word-audio.ps1 -List 4
```

没有配置 SSH 密钥时，`scp` 和 `ssh` 会分别要求输入账户密码，远程 `sudo` 也可能再要求一次密码。配置 SSH 密钥后可以消除前两次登录密码输入，但在服务器尚未设置专用部署权限时，`sudo` 仍可能要求一次密码。若已在 D 盘配置专用密钥，可在本地配置文件中增加可选字段：

```json
{
  "sshTarget": "ubuntu@LIGHTHOUSE_IP_OR_HOST",
  "baseUrl": "http://LIGHTHOUSE_IP_OR_HOST/audio",
  "identityFile": "D:\\LingoDemoData\\ssh\\lingo_lighthouse_ed25519"
}
```

默认会保留本批次的服务器临时目录，以便失败后排查。确认流程稳定后，可以在完整发布命令后增加 `-CleanupRemoteStaging`，仅在发布成功后清理本次创建的临时目录。正式目录、本地上传包、缓存和数据库备份都不会被脚本删除。

## 3.1 Qwen3 Katerina 批量发布 CET-4 例句

例句发布不能复用“Qwen Audio TTS 单词 WAV”的缓存文件或固定 48 kHz 参数。请在 Windows 桌面应用中执行下面的独立流程：

```text
设置 → 语音引擎 → Qwen3 Flash — Katerina
→ Qwen3 例句音频发布
→ 选择 CET-4 List（需要全量时在选择窗口点击“全选”）
→ 生成并发布
```

确认窗口会先给出所选 List 的唯一例句数、已可复用缓存数、正常 Qwen3 调用数和最多总尝试数。每条例句最多两次重试；只有点击“确认并发布”后才会调用 Qwen3 或执行上传。流程依次执行：

1. 使用固定 `qwen3-tts-flash` / `Katerina` / English 配置，以及 `input.instruction: "清晰自然的英式发音，语速适中，语调流畅有起伏，节奏连贯，适合英语句子朗读。"` 合成缺失例句；
2. 校验结果为可播放、非静音、至少 250 ms 的 PCM WAV（Qwen3 的采样率由服务返回，因此不强制沿用单词的 48 kHz）；
3. 写入 `D:\LingoDemoData\lingo_tts_cache\qwen3-example-<sha256>.wav`；
4. 打包到 `D:\LingoDemoData\lingo_example_audio_upload_v2_...`，并写入 ZIP 和不含凭据的发布报告；
5. 通过同一 SSH 发布配置上传到服务器的 `/var/www/lingo-word-audio/audio/v1/en/examples/`；
6. 对每个发布文件进行 HTTP `200`、`audio/wav` 与文件长度核验。

发布卡还提供与 Qwen Audio TTS Plus 单词卡一致的只读状态预检查：刷新后会显示每个 List 的本地有效例句缓存进度；点击“检查服务器状态”只会检查本地已完整缓存的 List，并逐个探测
`/audio/v1/en/examples/qwen3-example-<sha256>.wav`。结果会明确区分已上传、未上传、部分上传和无法确认，不会把网络故障误报成服务器缺文件。

Nginx 模板的 `location ^~ /audio/` 已允许该子目录，因此不需要为例句新增 server 块。发布完成并核验后，在“例句音频播放来源”中手动切换到“服务器 WAV（Qwen3 Katerina）”；服务器缺失文件不会自动回退到云端 API。

如需在应用外只核验一个已经打包好的例句 List，可运行：

```powershell
.\deploy\lighthouse\publish-word-audio.ps1 -List 4 -ReleaseKind example -VerifyOnly
```

该参数会只接受 `qwen3-example-<sha256>.wav` 文件，并访问 `/audio/v1/en/examples/`；默认仍是单词模式，因而不会改变已发布的单词操作。

## 3.2 腾讯云 WeWinny 英语例句独立发布

腾讯云 WeWinny 路径与 Qwen/Qwen3 的模型、参数、缓存、发布包、服务器文件和默认播放来源完全隔离。它只用于桌面端的批量生产；例句播放仍然从 Lighthouse 静态 WAV 读取，**不会**在用户播放时调用腾讯云 API。

在 Windows 的持久用户或系统环境变量中设置下面两个变量后，重新启动桌面应用：

```text
TENCENTCLOUD_SECRET_ID
TENCENTCLOUD_SECRET_KEY
```

不要把它们写入项目源文件、Git、应用设置、SQLite 数据库、发布报告或 SSH 发布配置。应用只检查变量是否存在，不显示变量值。腾讯云适配器使用官方 TC3-HMAC-SHA256 的 HTTPS 请求方式：

```text
POST https://tts.tencentcloudapi.com/
X-TC-Action: TextToVoice
X-TC-Version: 2019-08-23
X-TC-Region: ap-guangzhou
```

固定生产预设如下；不要在已经生成过文件后修改这些参数。如需换音色或参数，请创建新的 profile 版本与新的文件前缀。

```text
Voice: WeWinny
VoiceType: 501009
ModelType: 1
PrimaryLanguage: 2 (English)
Codec: wav
SampleRate: 24000
Volume: 0
Speed: 0
```

腾讯例句的不可变缓存 identity 是：

```text
profile: tencent-text-to-voice-wewinny-501009-en-wav-24k-example-v1
cache:   D:\LingoDemoData\lingo_tts_cache\tencent-wewinny-example-<sha256>.wav
package: D:\LingoDemoData\lingo_tencent_wewinny_example_audio_upload_v2_...
report:  D:\LingoDemoData\lingo_tencent_wewinny_example_audio_release_v2_....json
server:  /audio/v1/en/examples/tencent-wewinny-example-<sha256>.wav
```

服务器目录与 Qwen3 例句共用 `/audio/v1/en/examples/`，但腾讯文件具有自己的 `tencent-wewinny-example-` 前缀，上传器也使用单独的 `tencent_example` 发布类型。因此腾讯包不能混入 Qwen3 文件，Qwen3 包也不能混入腾讯文件；同名但内容不同的远程冲突保护仍然有效。

在应用中执行：

```text
设置 → 语音引擎 → 腾讯云 WeWinny 例句音频发布
→ 刷新（检查本地腾讯缓存、但不调用腾讯云）
→ 选择 CET-4 List
→ 生成并发布 / 仅生成
→ 在确认窗口再次核对调用上限
→ 确认后才会调用腾讯云 TextToVoice
```

卡片会显示 `TENCENTCLOUD_SECRET_ID` 和 `TENCENTCLOUD_SECRET_KEY` 是否都已配置；不会显示其值。若所有选中的腾讯 WAV 已在本地且通过固定 24 kHz PCM、非静音、至少 250 ms 校验，则打包/发布不会调用腾讯云。对于缺失例句，每条例句最多有一次正常调用和至多两次**临时可重试**失败后的重试；凭据、额度和参数错误不会盲目重试。

完成服务器发布并 HTTP 核验后，可在“例句音频播放来源”中选择“服务器 WAV（腾讯云 WeWinny）”。这只访问对应静态文件；404、网络失败或无效 WAV 均不会自动回退到腾讯云。

如需在应用外核验一个已经打包好的腾讯例句 List，可运行：

```powershell
.\deploy\lighthouse\publish-word-audio.ps1 -List 4 -ReleaseKind tencent_example -VerifyOnly
```

该模式只接受 `tencent-wewinny-example-<sha256>.wav`，并访问 `/audio/v1/en/examples/`。原有 `-ReleaseKind example` 仍只接受 Qwen3 的 `qwen3-example-<sha256>.wav`；单词默认模式不变。Qwen、Qwen3 与已有发布资产不会被此流程改名、覆盖或删除。

## 3.3 已发布单词的安全替换与回滚（应用内）

批量发布器的“同名但内容不同即停止”保护保持不变；**不要**用它强行覆盖已经发布的单词。对于少量审核后仍需修正的单词，使用应用内独立流程：

```text
设置 → Qwen TTS → 修复单个单词发音
→ 本地生成 / 试听 / 采用新本地音频
→ 试听当前本地 WAV
→ 比较本地候选与服务器
→ 明确确认“替换服务器 WAV”
```

“采用新本地音频”始终只改 `D:\LingoDemoData\lingo_tts_cache\`；它不会上传。只有随后单独确认服务器替换，才会写入线上文件。比较阶段只读取当前固定 URL 的 WAV，界面会显示单词、固定 URL、旧/新字节数与 SHA-256 摘要；如果两端内容已经完全一致，不会上传任何文件。

确认替换后，`replace-word-audio.ps1` 只处理一个已校验的固定键 WAV，并且在服务器上依次完成：

1. 再次确认本地候选、线上当前文件和审核计划中的 SHA-256 一致；如果比较后有人改过线上文件，立即停止。
2. 为该文件名取得独占锁，将正式目录中的旧 WAV 保留到受保护、不会被 Nginx 公开服务的目录：

   ```text
   /var/lib/lingo-word-audio/word-audio-backups/v1/en/<audio-key>/<operation-id>.wav
   ```

3. 在正式目录中写入临时文件并原子移动到原来的固定路径：

   ```text
   /var/www/lingo-word-audio/audio/v1/en/<audio-key>.wav
   ```

   因此应用请求的 URL 不变。
4. 通过公网 HTTP `GET` 重新读取内容，校验 HTTP 200、`audio/wav`、长度和完整 SHA-256。核验请求带有唯一查询参数及 `no-cache` 请求头，以降低中间缓存返回旧内容的可能性。
5. 在本机 `D:\LingoDemoData\lingo_word_audio_server_replacement_audits\` 和服务器备份目录分别留下不含凭据的审计记录。该流程不会调用 Qwen 或任何 TTS API。

自动替换在创建远端暂存目录或上传候选 WAV 前，会先以 `sudo -n -v` 做无密码预检。若服务器不能在该非交互式进程中完成 sudo 授权，脚本会稳定输出 `INTERACTIVE_SUDO_REQUIRED=1` 并停止；此时尚未上传、备份或替换任何服务器文件。应用据此显示“打开交互式服务器命令”，而不会再依赖不同服务器语言环境下的自然语言报错来判断。

服务器需要交互式 `sudo` 时，应用不会读取、保存或发送密码。只有用户主动点击“打开交互式服务器命令”后，才会打开可见的 PowerShell 窗口；用户可在那里输入服务器自己的 sudo 密码。之后点击“检查服务器结果”只读取公开 WAV 并比对哈希。替换/回滚过程中出现的 PowerShell、SSH、SCP、sudo 和 HTTP 校验输出会在长度限制和敏感信息脱敏后，保存到本机审计 JSON，并可在修复页面展开、选中或复制；不会保存密码、令牌或私钥路径。

若发现替换后效果反而不好，仍在同一修复页面点击“查找可回滚的服务器备份”。回滚在展示当前哈希、目标备份和固定 URL 后还需要一次明确确认。服务器会先将当前版本再备份为 `rollback_<operation-id>.wav`，再原子恢复旧版本并执行同样的 HTTP `GET` + SHA-256 校验。若线上当前哈希不再等于这条审计记录预期的版本，回滚会停止，避免覆盖后来发布的内容。

若某次命令在报告“可能已修改”后网络或 HTTP 校验中断，不要直接重试；先在界面中重新比较服务器版本，并检查保留的本地审计记录。

## 4. 手动上传（故障排查备用）

先在 Windows 上创建一个只包含新格式 WAV 的临时上传目录（仍在 D 盘）：

```powershell
$source = 'D:\LingoDemoData\lingo_tts_cache'
$release = 'D:\LingoDemoData\lingo_word_audio_upload'
New-Item -ItemType Directory -Force -Path $release | Out-Null
Get-ChildItem -LiteralPath $source -Filter '*.wav' |
  Where-Object { $_.Name -match '^[0-9a-f]{64}\.wav$' } |
  Copy-Item -Destination $release -Force
```

用你自己的 SSH 用户和 IP 上传。下面的命令只是示例，需自行替换占位符：

```powershell
scp -p "$release\*.wav" <ssh-user>@<Lighthouse-IP>:/tmp/lingo-word-audio/
```

登录服务器后安装文件并设置只读权限：

```bash
sudo install -o www-data -g www-data -m 0644 /tmp/lingo-word-audio/*.wav /var/www/lingo-word-audio/audio/v1/en/
```

上传完成后可以删除 `/tmp/lingo-word-audio` 的临时文件；不要删除 `/var/www/lingo-word-audio/audio/v1/en/` 中的已发布文件。

## 5. 手动核验静态服务

从任意可访问公网的设备选一个已上传的文件名，执行：

```bash
curl -I http://<Lighthouse-IP>/audio/v1/en/<audio-key>.wav
```

预期结果：HTTP 200、`Content-Type: audio/wav`，且响应可接受字节范围请求。若返回 404，通常是上传目录或文件名不匹配；应用会显示“该单词音频尚未上传到服务器”。

在应用“设置 → 单词音频服务器”中填入并保存：

```text
http://<Lighthouse-IP>/audio
```

Windows 开发包可直接测试。首次播放会经过网络请求；同一地区、正常移动网络下，短单词 WAV 的主要等待通常是一次连接/网络往返加几十到数百 KB 下载。请用真实手机网络分别测 Wi-Fi 和蜂窝网络，而不要只以电脑网络为准。

## 6. Android 仅 Debug 允许 HTTP

Android 正式包不能把 HTTP 明文流量放行。取得固定公网 IP 后：

1. 将 [network_security_config.xml.template](../lingo_app/android/app/src/debug/network_security_config.xml.template) 中的 `LIGHTHOUSE_PUBLIC_IP` 替换为实际 IP。
2. 创建目录 `lingo_app/android/app/src/debug/res/xml/`，把修改后的文件放为 `network_security_config.xml`。
3. 在 `lingo_app/android/app/src/debug/AndroidManifest.xml` 的 `<manifest>` 内加入仅 Debug 的 application 节点：

   ```xml
   <application
       android:networkSecurityConfig="@xml/network_security_config" />
   ```

4. 使用 Debug APK 测试。`src/debug` 不会进入 release APK；不要在 `src/main/AndroidManifest.xml` 使用 `usesCleartextTraffic="true"` 或同类全局放行。

## 7. 备案和 HTTPS 域名完成后

备案、域名审核和证书准备完成后：

1. 把 Nginx 的 `server_name` 改为正式域名并配置 443/TLS；可用 Certbot 或既有证书流程。
2. 在应用中把地址改为 `https://<你的域名>/audio`。
3. 删除本地 Debug HTTP 白名单（或保留在 Debug 源集但不用于 release）。
4. 不改变任何 WAV 文件名或应用音频键，因此不需要重新生成已上传音频。

Qwen API Key 只用于开发机生成这些 WAV，单词播放路径不会读取它。发布前不要在面向用户的应用设置中保留任何开发用 Qwen 凭据。
