# TTS 模型能力测试样本

## 测试目的

这是一套由浅入深的英语口语测试样本集，用于系统性地暴露不同 TTS 模型之间的能力差距。测试范围从最基础的发音准确度，逐步扩展到韵律、情绪、语境理解、副语言现象和复杂叙事表达。

每个级别均包含：

- 测试样本；
- 主要测试能力；
- 机械式 TTS 模型的典型失败表现。

## 建议测试方式

- 使用相同的文本、音色、语言、语速和音频格式测试不同模型。
- 分别记录供应商、模型版本、音色、生成参数和测试日期。
- 对带有“场景”的样本，将场景作为上下文或风格指令传给支持该能力的模型，不要把场景文字合成到最终音频中。
- 对括号标记，如 “(laughs)” 和 “(whispering)”，记录模型是执行了指令、忽略了指令，还是把标记直接读了出来。
- 除音质外，建议同时记录首音延迟、完整生成耗时、是否流式播放及缓存命中情况。

---

## Level 1：基础自然度与清晰度

**Basic Naturalness & Intelligibility**

**目标：**考察音素覆盖、发音准确度和基本流利度。连这一级都无法通过的模型，基本不具备可用性。

| 编号 | 样本 | 测试重点 | 机械模型的典型失败 |
| --- | --- | --- | --- |
| 1.1 | The quick brown fox jumps over the lazy dog near the quaint village zoo. | 全音素覆盖，复杂辅音连接。 | 部分音素含混、拼接感明显。 |
| 1.2 | I need to read this report, but I’ve already read the summary. | 同形异音词：read /riːd/ 与 /red/。 | 前后都读成同一个音，不懂语法区分。 |
| 1.3 | Please record the record of our meeting on January 1st, 2024, at 5:30 p.m. | 异义异读词 record，以及数字、缩写和时间表达。 | record 读法随机；时间和数字生硬，像在逐位念号码。 |
| 1.4 | Is it going to rain tomorrow? | 简单一般疑问句的句末升调。 | 语调平坦，结尾无上扬，听不出是在提问。 |

---

## Level 2：基础韵律与强调

**Basic Prosody & Emphasis**

**目标：**考察模型是否只会“平均化”地念字，还是能合理分配重音、停顿和语调模式。

| 编号 | 样本 | 测试重点 | 机械模型的典型失败 |
| --- | --- | --- | --- |
| 2.1 | I asked you to buy apples, not oranges. | 对比重音：apples 与 oranges。 | 每个词力度均匀，听不出被对比的对象。 |
| 2.2 | I didn’t say you were wrong, I said you were late. | 焦点重音：wrong 与 late。 | 重音消失，句子变成一条直线。 |
| 2.3 | That’s incredible, isn’t it? | 反意疑问句语调。 | 附加问句读成平调，或出现不合逻辑的升降。 |
| 2.4 | She packed her bags, grabbed her keys, and walked out the door. | 列举语调（升—升—降）以及动作连贯的节奏。 | 三个短语之间没有语调变化，听起来像彼此独立的词组。 |

---

## Level 3：基础情感表达

**Basic Emotion & Affect**

**目标：**考察模型能否脱离“中性朗读”，表达常见情绪。重点关注基频、速度和音色紧张度是否发生合理变化。

| 编号 | 样本 | 测试重点 | 机械模型的典型失败 |
| --- | --- | --- | --- |
| 3.1 | Oh my god! I got the job! I’m so excited! | 高唤醒的喜悦：语速稍快、基频抬高。 | 极度平淡，像在说“我吃了早饭”。 |
| 3.2 | There was nothing more we could do. I’m so sorry for your loss. | 低唤醒的悲伤：放慢、气声、下倾语调。 | 节奏和音调毫无变化，显得很冷漠。 |
| 3.3 | How dare you speak to me like that! | 愤怒：声带紧张，强调 dare，并以尖锐语调收尾。 | 依然规规矩矩地发音，毫无爆发力。 |
| 3.4 | W-what was that noise? Is someone there? | 恐惧或紧张：结巴、气息重、声调虚浮。 | 流畅地读成 “W what”，结巴感全无，完全不像受惊。 |

---

## Level 4：语义理解与语境语调

**Semantic Understanding & Contextual Intonation**

**目标：**考察同一句话在不同语境中的读法。模型需要先理解场景、人物关系和真实意图，再决定语调，而不能只按字面意义朗读。

| 编号 | 场景与样本 | 测试重点 | 机械模型的典型失败 |
| --- | --- | --- | --- |
| 4.1 | **场景：**你策划的户外派对遇上倾盆大雨。<br><br>Oh, brilliant. Just what I needed. | 反讽：语调应平淡下沉，与字面上的热情相反。 | 按字面义读出阳光灿烂的 brilliant，讽刺感全无。 |
| 4.2 | **场景：**朋友端上一盘看起来十分可疑的自制料理，问你好不好吃。<br><br>Wow, this is… really something. | 言不由衷的犹豫：拖长音，语调轻微扭曲。 | 听不出任何迟疑，像是真心称赞。 |
| 4.3 | **同一句话，两个语境：**<br><br>Is that so?<br><br>**语境 A：**学生在解释一个离谱的迟到理由。（怀疑／威胁）<br><br>**语境 B：**多年未见的老友突然出现在门口。（惊喜／不敢相信） | 根据语境生成完全不同的语调。A 应缓慢压低；B 应轻快上扬。 | 两种语境读得一模一样，通常都被处理成普通的上扬疑问式。 |
| 4.4 | **对话片段：**<br><br>A: I don’t think you can do it.<br>B: Oh really? Just watch me. | 被挑衅后的回击：Oh really 需要带有不屑和挑战。 | Oh really? 被读成真正的疑问；Just watch me 缺乏力度。 |

---

## Level 5：副语言现象与高级表现力

**Paralinguistics & Advanced Expressivity**

**目标：**考察模型能否生成笑声、叹气、犹豫词等非词汇人声元素，以及能否完成复杂的风格和情绪切换。

| 编号 | 样本 | 测试重点 | 机械模型的典型失败 |
| --- | --- | --- | --- |
| 5.1 | I think we should, uh, maybe postpone the, um, decision until next week. | 自然融入填充停顿词（filled pauses），不显突兀。 | 直接跳过填充词，或把它们读成生硬的单词 “UH”。 |
| 5.2 | You’re kidding, right? (laughs) There’s no way that’s true. | 生成自然笑声，或至少在声门和音色中呈现笑意。 | 忽略笑声标记，或生成一段奇怪的拼接笑声。 |
| 5.3 | (whispering) The code is 7-4-5-9. Don’t tell anyone. | 气声耳语的音色转换。 | 只是音量变小，发音方式不变，没有气声质感。 |
| 5.4 | I was terrified, but then I realized it was just a prank. You guys are the worst! … But I love you. | 情绪快速转换：恐惧 → 释然 → 佯怒 → 宠溺。 | 全程保持一种情绪，音调没有起承转合。 |
| 5.5 | **① 新闻播报**<br>Good evening, here is the news. The Prime Minister has announced…<br><br>**② 唱读／哄睡**<br>Hush now, little baby, don’t say a word, mama’s gonna buy you a mockingbird. | 语域和风格自动切换：新闻播报与唱读／哄睡。 | 两种文本使用相同的报告体风格，无法区分正式与亲密。 |

---

## 综合挑战：把一切串起来

下面的叙事短文涵盖情绪起伏、停顿、轻声、反讽、重音等多种现象。表现力较强的模型应当讲出明显的“故事感”；机械模型通常会从头到尾匀速念完。

> I woke up late, of course. Rushed out the door—no coffee. Great. Then, on the train, I saw her. My heart stopped. "Is that really you?" I whispered. She smiled. Suddenly, the whole awful, terrible, no-good morning turned into the best day ever.

### 试听观察项

- **of course.** 是否带有自嘲式的下坠？
- **Great.** 是否表现出反讽，而不是字面上的愉快？
- **“Is that really you?”** 是否带有气声、轻声和难以置信的感觉？
- **awful, terrible, no-good** 在列举时，节奏是否层层递进？
- **best day ever** 是否在结尾释放出温暖和愉悦？

---

## 单次测试记录模板

| 项目 | 记录 |
| --- | --- |
| 供应商／模型 |  |
| 音色 |  |
| 模型版本 |  |
| 语言／语速／格式 |  |
| 上下文或风格控制方式 |  |
| 是否流式播放 |  |
| 首音延迟 |  |
| 完整生成耗时 |  |
| 缓存状态 |  |
| 自然度与清晰度 |  |
| 韵律与重音 |  |
| 情绪与语境表达 |  |
| 副语言表现 |  |
| 主要问题与备注 |  |
