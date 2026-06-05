class AppStrings {
  AppStrings._();

  static const _strings = <String, Map<String, String>>{
    // ─── App shell ───
    'app_title': {'en': 'LingoDemo', 'zh': 'LingoDemo'},
    'settings': {'en': 'Settings', 'zh': '设置'},
    'save': {'en': 'Save', 'zh': '保存'},
    'settings_saved': {'en': 'Settings saved', 'zh': '设置已保存'},
    'ai_settings_saved': {'en': 'AI config saved', 'zh': 'AI 配置已保存'},
    'tts_test_success': {
      'en': 'TTS test passed — check your speaker',
      'zh': 'TTS 测试通过 — 请听喇叭',
    },
    'tts_test_failed': {'en': 'TTS test failed', 'zh': 'TTS 测试失败'},
    'tts_test_failed_detail': {
      'en': 'TTS test failed: {msg}',
      'zh': 'TTS 测试失败：{msg}',
    },

    // ─── List overview ───
    'import_words': {'en': 'Import Words', 'zh': '导入单词'},
    'retry': {'en': 'Retry', 'zh': '重试'},
    'failed_lists': {'en': 'Failed to load lists', 'zh': '加载单词表失败'},
    'no_lists_yet': {'en': 'No word lists yet', 'zh': '暂无单词表'},
    'previous_page': {'en': 'Previous', 'zh': '上一页'},
    'next_page': {'en': 'Next', 'zh': '下一页'},
    'all_books': {'en': 'All Books', 'zh': '全部词书'},
    'list_page_range': {
      'en': 'Page {page}/{total} · list {start}-{end}',
      'zh': '第{page}/{total}页·list{start}-{end}',
    },
    'tap_built_in': {
      'en': 'Tap a built-in book to get started, or import your own.',
      'zh': '点击内置词库开始，或导入自己的单词表。',
    },
    'browse_files': {'en': 'Browse Files...', 'zh': '浏览文件...'},
    'delete_list_title': {'en': 'Delete List', 'zh': '删除单词表'},
    'delete_confirm': {
      'en': 'Delete "{name}"?\nThis action cannot be undone.',
      'zh': '删除 "{name}"？\n此操作不可撤销。',
    },
    'cancel': {'en': 'Cancel', 'zh': '取消'},
    'delete': {'en': 'Delete', 'zh': '删除'},
    'n_words': {'en': '{count} words', 'zh': '{count} 个单词'},
    'pass_badge': {'en': 'PASS', 'zh': '通过'},
    'home_title': {'en': 'Today', 'zh': '今日学习'},
    'home_subtitle': {
      'en': 'Choose a list, review progress, or open the tools you use often.',
      'zh': '选择词表、查看进度，或打开常用学习工具。',
    },
    'home_lists_stat': {'en': 'Lists passed', 'zh': '已通过 List'},
    'home_words_stat': {'en': 'Total words', 'zh': '总单词'},
    'home_continue_list': {'en': 'Continue {name}', 'zh': '继续 {name}'},
    'home_word_lists': {'en': 'Word Lists', 'zh': '单词列表'},
    'home_word_lists_desc': {
      'en': 'Browse imported and built-in lists.',
      'zh': '查看已导入和内置词表。',
    },
    'home_import_desc': {
      'en': 'Add built-in books or your own files.',
      'zh': '添加内置词库或自己的文件。',
    },
    'home_tts_desc': {
      'en': 'Read any sentence or paragraph aloud.',
      'zh': '朗读任意句子或段落。',
    },
    'home_history_desc': {
      'en': 'Review previous practice sessions.',
      'zh': '查看之前的练习记录。',
    },
    'home_skills_desc': {
      'en': 'Run reusable learning workflows.',
      'zh': '运行可复用的学习工作流。',
    },
    'home_section_learning': {'en': 'Learning', 'zh': '学习'},
    'home_section_ai_practice': {'en': 'AI Practice', 'zh': 'AI 练习'},
    'home_section_tools': {'en': 'Tools', 'zh': '工具'},
    'home_ai_deep_desc': {
      'en': 'Practice collocations, sentences, and idioms.',
      'zh': '练习搭配、语境句和俗语谚语。',
    },
    'home_ai_dialogue_desc': {
      'en': 'Generate dialogues from a passed list.',
      'zh': '基于已通过词表生成对话。',
    },
    'home_speaking_desc': {
      'en': 'Read examples aloud and get scoring feedback.',
      'zh': '朗读例句并获得评分反馈。',
    },
    'home_no_unlocked_lists': {
      'en': 'Pass a word list first to unlock this feature.',
      'zh': '请先通过一个单词表再使用此功能。',
    },
    'home_choose_passed_list': {
      'en': 'Choose a passed list',
      'zh': '选择已通过的单词表',
    },

    // ─── Lingo Skills ───
    'skills_title': {'en': 'Lingo Skills', 'zh': 'Lingo Skills'},
    'skills_intro': {
      'en':
          'Run controlled built-in workflows that reuse your word lists, review data, AI, and local services.',
      'zh': '运行受控的内置工作流，复用词表、复习数据、AI 和本地服务。',
    },
    'skills_no_lists': {
      'en': 'Import a word list before running skills.',
      'zh': '请先导入单词表，再运行 Skills。',
    },
    'skill_word_story': {'en': 'Word Story', 'zh': '单词故事'},
    'skill_word_story_desc': {
      'en': 'Generate a short bilingual story from words in a list.',
      'zh': '从词表单词生成一个双语短故事。',
    },
    'skill_review_plan': {'en': 'Review Planner', 'zh': '复习计划'},
    'skill_review_plan_desc': {
      'en': 'Summarize error words, forgotten words, and recent practice.',
      'zh': '汇总错词、遗忘词和近期练习情况。',
    },
    'skill_input_word_list': {'en': 'Word List', 'zh': '单词表'},
    'skill_input_word_count': {'en': 'Words to use', 'zh': '使用单词数'},
    'skill_capability_ai': {'en': 'AI', 'zh': 'AI'},
    'skill_capability_database': {'en': 'Database', 'zh': '数据库'},
    'skill_capability_tts': {'en': 'TTS', 'zh': 'TTS'},
    'skill_capability_asr': {'en': 'ASR', 'zh': 'ASR'},
    'skill_capability_local': {'en': 'Local', 'zh': '本地'},
    'skill_capability_cloud': {'en': 'Cloud', 'zh': '云端'},
    'skill_run': {'en': 'Run Skill', 'zh': '运行 Skill'},
    'skill_running': {'en': 'Running...', 'zh': '运行中...'},
    'skill_ai_confirm_title': {'en': 'Run AI skill?', 'zh': '运行 AI Skill？'},
    'skill_ai_confirm_body': {
      'en':
          'This skill uses your configured AI provider and may consume API quota.',
      'zh': '此 Skill 会使用已配置的 AI 服务，可能消耗 API 额度。',
    },
    'skill_progress_starting': {'en': 'Starting...', 'zh': '正在启动...'},
    'skill_progress_loading_words': {
      'en': 'Loading words...',
      'zh': '正在加载单词...',
    },
    'skill_progress_generating_story': {
      'en': 'Generating story...',
      'zh': '正在生成故事...',
    },
    'skill_progress_loading_review_data': {
      'en': 'Loading review data...',
      'zh': '正在加载复习数据...',
    },
    'skill_run_cancelled': {'en': 'Skill run cancelled.', 'zh': 'Skill 已取消。'},
    'skill_run_failed': {'en': 'Skill run failed.', 'zh': 'Skill 运行失败。'},
    'skill_error_unknown_skill': {'en': 'Unknown skill.', 'zh': '未知 Skill。'},
    'skill_error_missing_handler': {
      'en': 'Skill handler is not registered.',
      'zh': 'Skill handler 未注册。',
    },
    'skill_error_required_input': {
      'en': 'Required input is missing.',
      'zh': '缺少必填输入。',
    },
    'skill_error_invalid_input': {
      'en': 'Skill input is invalid.',
      'zh': 'Skill 输入无效。',
    },
    'skill_error_missing_list': {
      'en': 'Choose a valid word list.',
      'zh': '请选择有效的单词表。',
    },
    'skill_error_no_words': {
      'en': 'This list has no words.',
      'zh': '此单词表没有单词。',
    },
    'skill_error_need_three_words': {
      'en': 'This skill needs at least three words.',
      'zh': '此 Skill 至少需要三个单词。',
    },
    'skill_result_word_story_summary': {
      'en': 'Story generated with {count} words.',
      'zh': '已使用 {count} 个单词生成故事。',
    },
    'skill_result_words_used': {'en': 'Words Used', 'zh': '使用的单词'},
    'skill_result_story': {'en': 'Story', 'zh': '故事'},
    'skill_result_translation': {'en': 'Translation', 'zh': '翻译'},
    'skill_result_review_plan_summary': {
      'en': 'Plan ready: {errors} error words, {forgotten} forgotten words.',
      'zh': '计划已生成：{errors} 个错词，{forgotten} 个遗忘词。',
    },
    'skill_result_review_summary': {'en': 'Summary', 'zh': '摘要'},
    'skill_result_review_next_steps': {'en': 'Next Steps', 'zh': '下一步'},
    'skill_result_review_focus_words': {'en': 'Focus Words', 'zh': '重点单词'},
    'skill_result_recent_sessions': {'en': 'Recent Sessions', 'zh': '近期练习'},
    'skill_review_plan_list_line': {'en': 'List: {name}', 'zh': '单词表：{name}'},
    'skill_review_plan_words_line': {
      'en': 'Words: {count}',
      'zh': '单词数：{count}',
    },
    'skill_review_plan_errors_line': {
      'en': 'Active error words: {count}',
      'zh': '当前错词：{count}',
    },
    'skill_review_plan_forgotten_line': {
      'en': 'Active forgotten words: {count}',
      'zh': '当前遗忘词：{count}',
    },
    'skill_review_plan_accuracy_line': {
      'en': 'Recent average accuracy: {accuracy}',
      'zh': '近期平均正确率：{accuracy}',
    },
    'skill_review_plan_accuracy_none_line': {
      'en': 'Recent average accuracy: no recent practice',
      'zh': '近期平均正确率：暂无近期练习',
    },
    'skill_review_plan_no_focus_words': {
      'en': 'No active review words.',
      'zh': '暂无需要重点复习的单词。',
    },
    'skill_review_plan_focus_word_line': {
      'en': '{word} - errors {errors}, forgotten {forgotten}',
      'zh': '{word} - 错误 {errors} 次，遗忘 {forgotten} 次',
    },
    'skill_review_plan_step_forgotten': {
      'en': 'Start with forgotten-word practice to clear stale memory.',
      'zh': '先练习遗忘词，清理不牢固的记忆。',
    },
    'skill_review_plan_step_errors': {
      'en': 'Review error words before running a full-list quiz.',
      'zh': '先复习错词，再做整表练习。',
    },
    'skill_review_plan_step_baseline': {
      'en': 'Run one baseline practice session for this list.',
      'zh': '先为此单词表完成一次基线练习。',
    },
    'skill_review_plan_step_low_accuracy': {
      'en': 'Use multiple-choice once, then switch to fill-in practice.',
      'zh': '先做一次选择题，再切换到填空练习。',
    },
    'skill_review_plan_step_high_accuracy': {
      'en': 'Use fill-in or dictation to confirm durable recall.',
      'zh': '使用填空或听写确认长期记忆。',
    },
    'skill_review_plan_step_clear': {
      'en': 'No urgent review items. Do one short mixed practice pass.',
      'zh': '暂无紧急复习项，做一次短的混合练习即可。',
    },
    'skill_review_plan_session_line': {
      'en': '{mode}: {accuracy}, {correct}/{total} correct',
      'zh': '{mode}：{accuracy}，正确 {correct}/{total}',
    },

    // ─── Review center ───
    'review_center': {'en': 'Review Center', 'zh': '复习中心'},
    'review_center_desc': {
      'en': 'Review error words, forgotten words, and study stats.',
      'zh': '查看错词、遗忘词和学习统计。',
    },
    'selected_book': {'en': 'Selected Book', 'zh': '所选词书'},
    'error_collection': {'en': 'Error Collection', 'zh': '错词收录'},
    'forgotten_collection': {'en': 'Forgotten Collection', 'zh': '遗忘收录'},
    'learning_stats': {'en': 'Study Stats', 'zh': '学习统计'},
    'total_error_count': {'en': 'Total Errors', 'zh': '累计错误数'},
    'total_forgotten_count': {'en': 'Total Forgotten', 'zh': '累计遗忘词数'},
    'active_error_words': {'en': 'Active Error Words', 'zh': '当前错词数'},
    'active_forgotten_words': {'en': 'Active Forgotten Words', 'zh': '当前遗忘词数'},
    'sort_by_error_count': {'en': 'By Errors', 'zh': '按错误次数'},
    'sort_by_forgotten_count': {'en': 'By Forgotten', 'zh': '按遗忘次数'},
    'review_choice': {'en': 'Choice', 'zh': '选择题'},
    'review_fill': {'en': 'Fill', 'zh': '填空题'},
    'no_review_data': {'en': 'No review data yet.', 'zh': '暂无复习数据。'},
    'error_count_label': {'en': 'Errors', 'zh': '错误'},
    'forgotten_count_label': {'en': 'Forgotten', 'zh': '遗忘'},
    'review_practice_result': {'en': 'Review Result', 'zh': '复习结果'},
    'review_practice_passed': {'en': 'Cleared', 'zh': '已清除'},
    'review_practice_not_passed': {'en': 'Not cleared yet', 'zh': '尚未清除'},
    'review_error_cleared_n': {
      'en': 'Cleared {count} error words.',
      'zh': '已清除 {count} 个错词。',
    },
    'back_to_review': {'en': 'Back to Review Center', 'zh': '返回复习中心'},
    'answer': {'en': 'Answer', 'zh': '答案'},

    // ─── List preview ───
    'word_list': {'en': 'Word List', 'zh': '单词表'},
    'back_home': {'en': 'Back to home', 'zh': '返回首页'},
    'back_to_lists': {'en': 'Back to word lists', 'zh': '返回词表'},
    'loading': {'en': 'Loading...', 'zh': '加载中...'},
    'error': {'en': 'Error', 'zh': '错误'},
    'passed_badge': {'en': 'Passed', 'zh': '已通过'},
    'history': {'en': 'History', 'zh': '历史记录'},
    'error_words_title': {'en': 'Error Words', 'zh': '错误单词'},
    'no_words': {'en': 'No words in this list.', 'zh': '此列表中没有单词。'},
    'start_practice': {'en': 'Start Practice', 'zh': '开始练习'},
    'ai_deep_learn': {'en': 'AI Deep Learn', 'zh': 'AI 深度学习'},
    'shuffled_order': {'en': 'Shuffled order', 'zh': '已打乱顺序'},
    'shuffle': {'en': 'Shuffle', 'zh': '打乱'},
    'failed_words': {'en': 'Failed to load words', 'zh': '加载单词失败'},
    'pronounce': {'en': 'Pronounce', 'zh': '发音'},
    'pronounce_example': {'en': 'Read example', 'zh': '朗读例句'},
    'show_chinese': {'en': 'Show Chinese', 'zh': '显示中文'},
    'hide_chinese': {'en': 'Hide Chinese', 'zh': '隐藏中文'},
    'scenario_translation_label': {'en': 'Translation', 'zh': '翻译'},
    'forgotten_label': {'en': 'Forgotten', 'zh': '已遗忘'},
    'mark_forgotten': {'en': 'Mark as forgotten', 'zh': '标记为遗忘'},
    'mark_forgotten_short': {'en': 'Mark', 'zh': '标记'},
    'forgotten_words_menu': {'en': 'Forgotten Words', 'zh': '遗忘单词'},
    'forgotten_words_title': {'en': 'Forgotten Words', 'zh': '遗忘单词'},
    'no_forgotten_words': {'en': 'No forgotten words.', 'zh': '没有遗忘的单词。'},
    'no_forgotten_words_hint': {
      'en':
          'Tap the flag icon next to any word in a list to mark it as forgotten.',
      'zh': '在列表中点击单词右侧的旗帜图标即可标记为遗忘。',
    },
    'practice_forgotten': {'en': 'Practice Forgotten Words', 'zh': '练习遗忘单词'},
    'forgotten_practice_intro': {
      'en':
          'Pass the practice to clear forgotten status. Words you answer correctly will be cleared once your overall accuracy meets the list pass threshold.',
      'zh': '通过本次练习后即可清除遗忘状态。当本次准确率达到该 list 的通过阈值，答对的单词会自动清除遗忘标记。',
    },
    'error_practice_intro': {
      'en':
          'Pass this retest to clear error words. Words you answer correctly will be removed once your overall accuracy meets the list pass threshold.',
      'zh': '通过本次重测后即可清除错词。当本次准确率达到该 list 的通过阈值，答对的单词会自动从错误单词中移除。',
    },
    'forgotten_cleared_n': {
      'en': 'Cleared forgotten status for {count} words.',
      'zh': '已清除 {count} 个单词的遗忘状态。',
    },
    'error_cleared_n': {
      'en': 'Cleared {count} error words.',
      'zh': '已清除 {count} 个错误单词。',
    },
    'forgotten_not_cleared': {
      'en':
          'Accuracy below pass threshold — forgotten status unchanged. Try again.',
      'zh': '准确率未达到通过阈值，遗忘状态保留。请再试一次。',
    },
    'error_not_cleared': {
      'en': 'Accuracy below pass threshold. Error words were kept.',
      'zh': '准确率未达到通过阈值，错误单词保留。',
    },
    'forgotten_mode_locked': {
      'en':
          'Once marked, "forgotten" can only be cleared by passing the forgotten-words practice.',
      'zh': '标记后，"已遗忘"状态只能通过完成遗忘单词二次背诵过关才能消除。',
    },
    'done': {'en': 'Done', 'zh': '完成'},
    'check_answer': {'en': 'Check', 'zh': '检查'},

    // ─── Speaking practice ───
    'speaking_practice': {'en': 'Speaking Practice', 'zh': '口语练习'},
    'speaking_transcript_label': {'en': 'Recognized text', 'zh': '识别文本'},
    'speaking_transcript_hint': {
      'en': 'Recognized speech appears here...',
      'zh': '语音识别文本会显示在这里...',
    },
    'speaking_asr_pending_hint': {
      'en':
          'Microphone and local ASR are the next integration step; this field drives the scoring core now.',
      'zh': '麦克风和本地 ASR 是下一步接入；当前先用此输入验证评分核心。',
    },
    'speaking_asr_ready_hint': {
      'en':
          'The local ASR transcript is scored against the reference sentence. You can edit the text before checking again.',
      'zh': '本地 ASR 识别文本会和标准例句对齐评分。你也可以编辑文本后重新检查。',
    },
    'speaking_tap_record': {'en': 'Tap to record', 'zh': '点击开始录音'},
    'speaking_recording': {
      'en': 'Recording... tap to stop',
      'zh': '正在录音... 点击停止',
    },
    'speaking_recognizing': {'en': 'Recognizing speech...', 'zh': '正在识别语音...'},
    'speaking_mic_permission_denied': {
      'en': 'Microphone permission was denied.',
      'zh': '麦克风权限被拒绝。',
    },
    'speaking_recording_failed': {'en': 'Recording failed.', 'zh': '录音失败。'},
    'speaking_action_failed': {
      'en': 'Speaking action failed: {msg}',
      'zh': '口语操作失败：{msg}',
    },
    'speaking_asr_model_needed': {
      'en': 'Download the local ASR model before recording.',
      'zh': '请先下载本地 ASR 模型再录音。',
    },
    'speaking_asr_model_not_downloaded': {
      'en': 'ASR model not downloaded',
      'zh': 'ASR 模型未下载',
    },
    'speaking_asr_model_desc': {
      'en':
          'SenseVoice INT8 supports Chinese, English, Japanese, Korean, and Cantonese. Download size is about 240 MB.',
      'zh': 'SenseVoice INT8 支持中、英、日、韩、粤语，下载体积约 240 MB。',
    },
    'speaking_asr_download_model': {'en': 'Download Model', 'zh': '下载模型'},
    'speaking_asr_model_downloading': {
      'en': 'Downloading ASR model... {progress}%',
      'zh': '正在下载 ASR 模型... {progress}%',
    },
    'speaking_asr_model_ready': {'en': 'ASR model ready', 'zh': 'ASR 模型已就绪'},
    'speaking_asr_model_ready_desc': {
      'en': 'Recognition runs locally on this device.',
      'zh': '语音识别会在本机离线运行。',
    },
    'speaking_asr_model_error': {'en': 'ASR model error', 'zh': 'ASR 模型错误'},
    'speaking_asr_download_network_error': {
      'en':
          'Download failed because the network connection was interrupted. Try again later.',
      'zh': '网络连接中断，模型下载失败。请稍后重试。',
    },
    'speaking_asr_download_verification_failed': {
      'en':
          'The downloaded model file did not pass integrity checks. Please download it again.',
      'zh': '下载的模型文件未通过完整性校验，请重新下载。',
    },
    'speaking_asr_download_disk_error': {
      'en':
          'The model could not be saved to disk. Check available space and try again.',
      'zh': '模型无法保存到磁盘。请检查可用空间后重试。',
    },
    'speaking_asr_download_unknown_error': {
      'en': 'Download failed unexpectedly. Please try again.',
      'zh': '下载异常失败，请重试。',
    },
    'speaking_asr_retry_download': {'en': 'Retry Download', 'zh': '重试下载'},
    'speaking_asr_empty_audio': {
      'en': 'No usable speech was found in the recording.',
      'zh': '录音中没有可用语音。',
    },
    'speaking_asr_empty_transcript': {
      'en':
          'ASR did not recognize any text. Try again closer to the microphone.',
      'zh': 'ASR 未识别到文本。请靠近麦克风再试一次。',
    },
    'speaking_score': {'en': 'Score {score}', 'zh': '得分 {score}'},
    'speaking_extra_words': {'en': 'Extra words: {words}', 'zh': '多读：{words}'},
    'speaking_finished': {
      'en': 'Speaking practice finished. Average score: {score}',
      'zh': '口语练习完成，平均分：{score}',
    },
    'no_speaking_prompts': {
      'en': 'No example sentences available for speaking practice.',
      'zh': '当前没有可用于口语练习的例句。',
    },

    // ─── Book reset ───
    'reset_book_order_menu': {'en': 'Reset Book Order', 'zh': '重置词书顺序'},
    'reset_book_order_desc': {
      'en': 'Choose a word book and reshuffle all of its lists.',
      'zh': '选择一本词书，重排整本词书下的所有 list。',
    },
    'reset_book_order_select_title': {
      'en': 'Choose a word book',
      'zh': '选择要重置的词书',
    },
    'reset_book_order_title': {
      'en': 'Reset whole-book word order?',
      'zh': '重置整本词书的词序？',
    },
    'reset_book_order_warning': {
      'en':
          'Resetting will fully reshuffle the entire word book. Words previously fixed inside each list will change. This is irreversible — confirm to reset?',
      'zh': '重置词序后会使整本词书完全重新乱序排列，list 内原先固定词将会变化，是否确定重置（不可逆）？',
    },
    'reset_book_order_cooldown': {
      'en': 'Cooling down... {seconds}s',
      'zh': '冷静期... {seconds} 秒',
    },
    'reset_book_order_confirm': {'en': 'Reset', 'zh': '确认重置'},
    'reset_book_order_done': {
      'en': 'Whole-book word order reset.',
      'zh': '整本词书词序已重置。',
    },
    'reset_book_order_no_book': {
      'en': 'This list is not attached to a book; nothing to reset.',
      'zh': '此 list 不属于任何词书，无法重置。',
    },
    'reset_book_order_no_books': {
      'en': 'No word books available to reset.',
      'zh': '没有可重置的词书。',
    },

    // ─── Listening / audio-choice mode ───
    'audio_choice': {'en': 'Audio Choice', 'zh': '听选'},
    'audio_choice_desc': {
      'en':
          'Listen to the English word and pick the correct Chinese meaning from five options. The word is hidden until you answer.',
      'zh': '听英文单词，从五个选项中选出正确的中文释义。回答前单词会被遮挡。',
    },
    'listen_then_choose': {
      'en': 'Listen, then choose the correct meaning',
      'zh': '听发音，选择正确释义',
    },
    'word_obscured_hint': {
      'en':
          'Tap the speaker to listen — the word stays hidden until you answer.',
      'zh': '点击喇叭听发音 — 回答前单词不会显示。',
    },
    'locked_until_passed': {
      'en': 'Pass this list with multiple-choice or fill-in to unlock.',
      'zh': '请先通过选择/填空模式后解锁。',
    },
    'locked_chip': {'en': 'Locked', 'zh': '未解锁'},

    // ─── Custom TTS reader ───
    'custom_tts_title': {'en': 'Custom Text TTS', 'zh': '自定义文本朗读'},
    'custom_tts_intro': {
      'en':
          'Paste or type any text — the active TTS engine will read it aloud. Useful for sentences, paragraphs, or material outside the word lists.',
      'zh': '粘贴或输入任意文本，使用当前 TTS 引擎朗读。适合句子、段落或词表外的素材。',
    },
    'custom_tts_hint': {
      'en': 'Type or paste text to read...',
      'zh': '输入或粘贴要朗读的文本...',
    },
    'custom_tts_speak': {'en': 'Speak', 'zh': '朗读'},
    'custom_tts_speaking': {'en': 'Speaking...', 'zh': '朗读中...'},
    'custom_tts_clear': {'en': 'Clear', 'zh': '清空'},
    'custom_tts_menu': {'en': 'Read Custom Text', 'zh': '朗读自定义文本'},
    'custom_tts_last_status': {
      'en': 'Last playback: {status}',
      'zh': '上次播放：{status}',
    },

    // ─── Idioms / proverbs deep-practice mode ───
    'idioms_mode': {'en': 'Idioms & Proverbs', 'zh': '俗语谚语'},
    'idioms_mode_desc': {
      'en':
          'AI generates idioms or proverbs that use the list words; fill in the missing word. Requires AI configuration.',
      'zh': 'AI 基于 list 词汇生成俗语/谚语，填出缺失单词。需配置 AI。',
    },

    // ─── Import screen ───
    'import_words_title': {'en': 'Import Words', 'zh': '导入单词'},
    'importing': {'en': 'Importing words...', 'zh': '正在导入单词...'},
    'built_in_books': {'en': 'Built-in Word Books', 'zh': '内置词库'},
    'loading_built_in_books': {
      'en': 'Loading built-in word books...',
      'zh': '正在加载内置词库...',
    },
    'tap_to_import': {'en': 'Tap a book to import directly', 'zh': '点击词库直接导入'},
    'or_import_file': {'en': 'or import from file', 'zh': '或从文件导入'},
    'change': {'en': 'Change', 'zh': '更换'},
    'list_name': {'en': 'List Name', 'zh': '列表名称'},
    'list_name_hint': {
      'en': 'Enter a name for this word list',
      'zh': '输入单词表名称',
    },
    'pass_threshold': {'en': 'Pass Threshold', 'zh': '通过阈值'},
    'preview': {'en': 'Preview', 'zh': '预览'},
    'show_less': {'en': 'Show Less', 'zh': '收起'},
    'show_all': {'en': 'Show All', 'zh': '展开全部'},
    'english_col': {'en': 'English', 'zh': '英文'},
    'chinese_col': {'en': 'Chinese', 'zh': '中文'},
    'pronunciation_col': {'en': 'Pronunciation', 'zh': '发音'},
    'more_words': {
      'en': '... and {count} more words',
      'zh': '... 还有 {count} 个单词',
    },
    'import_n_words': {'en': 'Import {count} Words', 'zh': '导入 {count} 个单词'},
    'ai_gen_scenarios': {
      'en': 'AI Generate Scenario Examples [Beta]',
      'zh': 'AI 生成情景例句 [灰度测试]',
    },
    'ai_gen_scenarios_desc': {
      'en':
          'After import, use AI to create example sentences for each word. Takes extra time but helps with memorization.',
      'zh': '导入后使用 AI 为每个单词生成情景例句。会多花一些时间，但有助记忆。',
    },
    'gen_scenarios_progress': {
      'en': 'Generating scenarios... {done}/{total}',
      'zh': '正在生成情景例句... {done}/{total}',
    },
    'n_words_found': {'en': '{count} words found', 'zh': '找到 {count} 个单词'},

    // ─── Import error messages ───
    'builtin_empty': {'en': 'Built-in word book is empty.', 'zh': '内置词库为空。'},
    'no_valid_words_name': {
      'en': 'No valid words found in {name}.',
      'zh': '在 {name} 中未找到有效单词。',
    },
    'failed_load_name': {
      'en': 'Failed to load {name}: {err}',
      'zh': '加载 {name} 失败：{err}',
    },
    'no_file_path': {'en': 'Could not access file path.', 'zh': '无法访问文件路径。'},
    'file_empty': {'en': 'File is empty.', 'zh': '文件为空。'},
    'unsupported_type': {
      'en': 'Unsupported file type: {type}',
      'zh': '不支持的文件类型：{type}',
    },
    'no_valid_words_file': {
      'en': 'No valid words found in file.',
      'zh': '文件中未找到有效单词。',
    },
    'parse_error': {'en': 'Parse error: {msg}', 'zh': '解析错误：{msg}'},
    'failed_read_file': {
      'en': 'Failed to read file: {err}',
      'zh': '读取文件失败：{err}',
    },
    'csv_columns_error': {
      'en': 'CSV must have "english" and "chinese_meanings" columns.',
      'zh': 'CSV 必须包含 "english" 和 "chinese_meanings" 列。',
    },
    'json_array_error': {
      'en': 'JSON must be an array of word objects.',
      'zh': 'JSON 必须是单词对象数组。',
    },
    'enter_list_name': {'en': 'Please enter a list name.', 'zh': '请输入列表名称。'},
    'import_failed': {'en': 'Import failed: {err}', 'zh': '导入失败：{err}'},
    'list_size_label': {'en': 'Words per List', 'zh': '每组词数'},
    'splits_into': {
      'en': 'Splits into {count} lists',
      'zh': '将拆分为 {count} 个列表',
    },
    'list_size_warning': {
      'en':
          'For effective learning, choose an appropriate list size based on your ability.',
      'zh': '为保证学习深度，请根据自身实际情况设置适当的list词数。',
    },

    // ─── Practice setup ───
    'start_practice_title': {'en': 'Start Practice', 'zh': '开始练习'},
    'choose_mode': {'en': 'Choose a mode', 'zh': '选择模式'},
    'multiple_choice': {'en': 'Multiple Choice', 'zh': '选择题'},
    'multiple_choice_desc': {
      'en':
          'See an English word and pick the correct Chinese meaning from five options.',
      'zh': '看英文单词，从五个选项中选出正确的中文释义。',
    },
    'fill_blank': {'en': 'Fill in the Blank', 'zh': '填空题'},
    'fill_blank_desc': {
      'en':
          'See the English word and type its Chinese meaning(s). Any correct meaning counts.',
      'zh': '看英文单词，输入中文释义。多义词写对任意一个即可。',
    },
    'dictation': {'en': 'Dictation', 'zh': '听写'},
    'dictation_desc': {
      'en':
          'Listen to the English word and type its Chinese meaning(s). Any correct meaning counts.',
      'zh': '听英文单词发音，输入中文释义。多义词写对任意一个即可。',
    },
    'start': {'en': 'Start', 'zh': '开始'},

    // ─── Practice quiz ───
    'no_words_practice': {'en': 'No words to practice.', 'zh': '没有可练习的单词。'},
    'correct': {'en': 'Correct!', 'zh': '正确！'},
    'incorrect': {'en': 'Incorrect', 'zh': '错误'},
    'see_results': {'en': 'See Results', 'zh': '查看结果'},
    'next': {'en': 'Next', 'zh': '下一题'},
    'quit_practice_title': {'en': 'Quit Practice?', 'zh': '退出练习？'},
    'answer_progress': {
      'en': 'You have answered {answered} of {total} questions.',
      'zh': '你已回答 {answered} / {total} 道题。',
    },
    'progress_lost': {'en': 'Progress will be lost.', 'zh': '进度将会丢失。'},
    'continue_label': {'en': 'Continue', 'zh': '继续'},
    'quit': {'en': 'Quit', 'zh': '退出'},
    'submit': {'en': 'Submit', 'zh': '提交'},
    'choose_meaning': {'en': 'Choose the correct meaning', 'zh': '选择正确释义'},
    'tap_listen': {
      'en': 'Tap to listen, then type the Chinese meaning',
      'zh': '点击听发音，然后输入中文释义',
    },
    'type_english': {'en': 'Type the English word', 'zh': '输入英文单词'},
    'type_chinese': {'en': 'Type the Chinese meaning', 'zh': '输入中文释义'},
    'enter_english_hint': {
      'en': 'Enter the English word...',
      'zh': '输入英文单词...',
    },
    'enter_chinese_hint': {
      'en': 'Enter the Chinese meaning...',
      'zh': '输入中文释义...',
    },
    'correct_answer_label': {'en': 'Correct answer:', 'zh': '正确答案：'},
    'also_means': {'en': 'Also means:', 'zh': '也指：'},
    'missing_meanings': {'en': 'Missing meanings:', 'zh': '遗漏释义：'},

    // ─── Practice result ───
    'practice_results': {'en': 'Practice Results', 'zh': '练习结果'},
    'passed': {'en': 'Passed!', 'zh': '通过！'},
    'list_passed_unlocked': {
      'en':
          'List completed. AI Deep Learn, AI Dialogue, Dictation, and Audio Choice are now unlocked.',
      'zh': '本组 list 已完成。AI 深度学习、AI 对话、听写和听选已解锁。',
    },
    'practice_save_warning': {
      'en':
          'Practice history was not fully saved: {msg}. Pass status was applied if your accuracy met the threshold.',
      'zh': '练习记录未完整保存：{msg}。如果正确率达到阈值，本 list 已按通过处理。',
    },
    'practice_save_timeout': {'en': 'save timed out', 'zh': '保存超时'},
    'keep_practice': {'en': 'Keep Practicing', 'zh': '继续练习'},
    'correct_stat': {'en': 'Correct', 'zh': '正确'},
    'incorrect_stat': {'en': 'Incorrect', 'zh': '错误'},
    'total_stat': {'en': 'Total', 'zh': '总计'},
    'words_to_review': {'en': 'Words to Review', 'zh': '需要复习的单词'},
    'practice_again': {'en': 'Practice Again', 'zh': '再次练习'},
    'back_to_list': {'en': 'Back to List', 'zh': '返回列表'},

    // ─── Deep practice setup ───
    'ai_deep_learning': {'en': 'AI Deep Learning', 'zh': 'AI 深度学习'},
    'collocations_title': {'en': 'Collocations', 'zh': '词语搭配'},
    'collocations_desc': {
      'en':
          'Learn which words naturally pair together. AI generates common collocations for each word.',
      'zh': '学习单词的自然搭配。AI 为每个单词生成常用搭配。',
    },
    'contextual_sentences': {'en': 'Contextual Sentences', 'zh': '语境句子'},
    'contextual_sentences_desc': {
      'en':
          'Fill in the missing word in real-world example sentences generated by AI.',
      'zh': '在 AI 生成的真实例句中填入缺失的单词。',
    },
    'generating_ai': {'en': 'Generating AI content...', 'zh': '正在生成 AI 内容...'},
    'n_of_m_words': {
      'en': '{generated} / {total} words',
      'zh': '{generated} / {total} 个单词',
    },
    'content_ready': {'en': 'Content ready!', 'zh': '内容已准备好！'},
    'n_questions_prepared': {
      'en': '{count} questions prepared.',
      'zh': '已准备 {count} 道题。',
    },
    'generate_ai_content': {'en': 'Generate AI Content', 'zh': '生成 AI 内容'},
    'generating_btn': {'en': 'Generating...', 'zh': '生成中...'},
    'start_practice_n': {
      'en': 'Start Practice ({count} Qs)',
      'zh': '开始练习（{count} 题）',
    },
    'no_questions': {'en': 'No questions available.', 'zh': '没有可用的题目。'},

    // ─── Deep practice quiz ───
    'collocation_question': {
      'en': 'What word fits this collocation?',
      'zh': '哪个词符合这个搭配？',
    },
    'complete_sentence': {'en': 'Complete the sentence', 'zh': '完成句子'},
    'hint_prefix': {'en': 'Hint: {hint}', 'zh': '提示：{hint}'},
    'type_missing_word': {'en': 'Type the missing word...', 'zh': '输入缺失的单词...'},

    // ─── Deep practice result ───
    'deep_results': {'en': 'Deep Practice Results', 'zh': 'AI 深度学习结果'},

    // ─── Practice history ───
    'practice_history_title': {'en': 'Practice History', 'zh': '练习历史'},
    'list_history_title': {'en': 'List History', 'zh': '列表历史'},
    'no_sessions': {'en': 'No practice sessions yet.', 'zh': '暂无练习记录。'},
    'no_list_sessions': {
      'en': 'No practice sessions for this list.',
      'zh': '此列表暂无练习记录。',
    },
    'deleted_list': {'en': 'Deleted List', 'zh': '已删除的列表'},

    // ─── Error word review ───
    'error_words_screen_title': {'en': 'Error Words', 'zh': '错误单词'},
    'retest': {'en': 'Retest', 'zh': '重测'},
    'no_error_words': {'en': 'No Error Words!', 'zh': '没有错误单词！'},
    'great_job': {
      'en': 'Great job! All words were answered correctly.',
      'zh': '太棒了！所有单词都回答正确。',
    },

    // ─── Settings ───
    'ai_provider_section': {'en': 'AI Provider', 'zh': 'AI 服务商'},
    'provider_label': {'en': 'Provider', 'zh': '服务商'},
    'api_key_section': {'en': 'API Key', 'zh': 'API 密钥'},
    'api_key_label': {'en': 'API Key', 'zh': 'API 密钥'},
    'api_key_hint': {'en': 'Enter your API key', 'zh': '输入你的 API 密钥'},
    'test_connection': {'en': 'Test Connection', 'zh': '测试连接'},
    'testing': {'en': 'Testing...', 'zh': '测试中...'},
    'test_btn': {'en': 'Test', 'zh': '测试'},
    'connection_success': {'en': 'Connection successful!', 'zh': '连接成功！'},
    'connection_failed': {'en': 'Connection failed: ', 'zh': '连接失败：'},
    'ai_usage_title': {'en': 'AI Token Usage', 'zh': 'AI Token 消耗'},
    'ai_usage_last': {
      'en': 'Last call ({provider} / {model}): input {input}, output {output}',
      'zh': '本次（{provider} / {model}）：输入 {input}，输出 {output}',
    },
    'ai_usage_total': {
      'en': 'Total cumulative: input {input}, output {output}',
      'zh': '累计：输入 {input}，输出 {output}',
    },
    'ai_usage_no_records': {
      'en': 'No AI token usage recorded yet.',
      'zh': '暂无 AI Token 消耗记录。',
    },
    'ai_usage_load_failed': {
      'en': 'Failed to load AI usage: {msg}',
      'zh': '加载 AI 消耗失败：{msg}',
    },
    'language_section': {'en': 'Language', 'zh': '语言'},
    'language_label': {'en': 'Language', 'zh': '语言'},
    'english_lang': {'en': 'English', 'zh': 'English'},
    'chinese_lang': {'en': '中文', 'zh': '中文'},
    'practice_section': {'en': 'Practice', 'zh': '练习'},
    'default_pass_threshold': {'en': 'Default Pass Threshold', 'zh': '默认通过阈值'},
    'appearance_section': {'en': 'Appearance', 'zh': '外观'},
    'theme_label': {'en': 'Theme', 'zh': '主题'},
    'system_default': {'en': 'System Default', 'zh': '跟随系统'},
    'light': {'en': 'Light', 'zh': '浅色'},
    'dark': {'en': 'Dark', 'zh': '深色'},
    'tts_speed_label': {'en': 'TTS Speech Speed', 'zh': '语音朗读速度'},
    'tts_section': {'en': 'TTS Engine', 'zh': '语音引擎'},
    'tts_engine_label': {'en': 'Speech Engine', 'zh': '语音引擎'},
    'tts_none': {
      'en': 'System (SAPI) — free, offline',
      'zh': '系统语音 (SAPI) — 免费离线',
    },
    'tts_openai': {
      'en': 'OpenAI TTS — high quality, paid',
      'zh': 'OpenAI TTS — 高质量付费',
    },
    'tts_openai_title': {'en': 'OpenAI TTS', 'zh': 'OpenAI TTS'},
    'tts_supertonic': {
      'en': 'Supertonic 3 — on-device, free',
      'zh': 'Supertonic 3 — 设备端免费',
    },
    'tts_qwen': {
      'en': 'Qwen3 TTS — cloud, high quality',
      'zh': 'Qwen3 TTS — 云端高质量',
    },
    'tts_qwen_title': {'en': 'Qwen3 TTS', 'zh': 'Qwen3 TTS'},
    'tts_doubao': {
      'en': 'Doubao TTS — cloud, high quality',
      'zh': '豆包语音合成 — 云端高质量',
    },
    'tts_doubao_title': {'en': 'Doubao TTS', 'zh': '豆包语音合成'},
    'tts_sapi': {
      'en': 'Windows SAPI — lightweight offline',
      'zh': 'Windows SAPI — 轻量离线',
    },
    'tts_api_key_label': {'en': 'TTS API Key', 'zh': 'TTS API 密钥'},
    'tts_api_key_hint': {
      'en': 'Enter your TTS API key',
      'zh': '请输入你的 TTS API 密钥',
    },
    'tts_base_url_label': {'en': 'Base URL', 'zh': '接口地址'},
    'tts_model_label': {'en': 'Model', 'zh': '模型'},
    'tts_voice_label': {'en': 'Voice', 'zh': '音色'},
    'tts_resource_id_label': {'en': 'Resource ID', 'zh': '资源 ID'},
    'tts_precache_cet4_n': {
      'en': 'Pre-cache first {count} CET-4 Lists',
      'zh': '缓存 CET-4 前 {count} 个 List 读音',
    },
    'tts_precache_list_count_label': {
      'en': 'Number of Lists',
      'zh': '缓存 List 数量',
    },
    'tts_precache_list_count_hint': {
      'en': 'Enter how many CET-4 lists to cache',
      'zh': '输入要缓存的 CET-4 List 数量',
    },
    'tts_precache_invalid_list_count': {
      'en': 'Please enter a list count of 1 or more.',
      'zh': '请输入大于等于 1 的 List 数量。',
    },
    'tts_precache_hint': {
      'en':
          'Uses Doubao cloud TTS to cache the first {count} CET-4 Lists in order. Existing audio is skipped.',
      'zh': '使用豆包云端语音按顺序缓存 CET-4 前 {count} 个 List，已缓存的读音会自动跳过。',
    },
    'tts_precache_cancel': {'en': 'Cancel', 'zh': '取消'},
    'tts_precache_running': {
      'en': 'Caching audio... {done}/{total}',
      'zh': '正在缓存读音... {done}/{total}',
    },
    'tts_precache_current': {
      'en': 'Current: {list} — {word}',
      'zh': '当前：{list} — {word}',
    },
    'tts_precache_counts': {
      'en': 'Success {success}, skipped {skipped}, failed {failed}',
      'zh': '成功 {success}，跳过 {skipped}，失败 {failed}',
    },
    'tts_precache_usage': {
      'en':
          'This run: {calls} API calls, {chars} billable chars, {bytes} audio',
      'zh': '本次：{calls} 次 API 调用，{chars} 计费字符，{bytes} 音频',
    },
    'tts_precache_done': {
      'en':
          'Cache complete: success {success}, skipped {skipped}, failed {failed}',
      'zh': '缓存完成：成功 {success}，跳过 {skipped}，失败 {failed}',
    },
    'tts_precache_cancelled': {
      'en':
          'Cache cancelled: success {success}, skipped {skipped}, failed {failed}',
      'zh': '已取消缓存：成功 {success}，跳过 {skipped}，失败 {failed}',
    },
    'tts_precache_failed': {'en': 'Cache failed: {msg}', 'zh': '缓存失败：{msg}'},
    'tts_precache_no_cet4': {
      'en': 'CET-4 word book not found. Import CET-4 first.',
      'zh': '未找到 CET-4 词书，请先导入 CET-4。',
    },
    'tts_precache_need_api_key': {
      'en': 'Please enter your Doubao TTS API key first.',
      'zh': '请先填写豆包 TTS API 密钥。',
    },
    'tts_precache_first_failure': {
      'en': 'First failure: {error}',
      'zh': '首个失败：{error}',
    },
    'tts_doubao_live_api_enabled': {
      'en': 'Allow live Doubao API for normal playback',
      'zh': '允许普通播放实时调用豆包 API',
    },
    'tts_doubao_live_api_enabled_desc': {
      'en':
          'Turn off to play cached Doubao audio only. Missing cache will not call the API or fall back to SAPI.',
      'zh': '关闭后只播放豆包本地缓存；没有缓存时不会调用 API，也不会回退到 SAPI。',
    },
    'tts_usage_title': {'en': 'Doubao API Usage', 'zh': '豆包 API 消耗'},
    'tts_usage_summary': {
      'en':
          'Total: {calls} calls, {chars} billable chars, {bytes} audio, {failed} failed',
      'zh': '累计：{calls} 次调用，{chars} 计费字符，{bytes} 音频，失败 {failed} 次',
    },
    'tts_usage_load_failed': {
      'en': 'Failed to load usage: {msg}',
      'zh': '加载消耗记录失败：{msg}',
    },
    'tts_usage_no_records': {
      'en': 'No API call records yet.',
      'zh': '暂无 API 调用记录。',
    },
    'tts_usage_record': {
      'en': '{time} {action} {word} — {chars} chars — {status}',
      'zh': '{time} {action} {word} — {chars} 字符 — {status}',
    },
    'tts_cache_status_title': {'en': 'CET-4 Cache Status', 'zh': 'CET-4 缓存状态'},
    'tts_cache_status_empty': {
      'en': 'No cache status loaded yet. Tap Refresh.',
      'zh': '尚未加载缓存状态，请点击刷新。',
    },
    'tts_cache_status_summary': {
      'en':
          'Lists done {doneLists}/{totalLists}, words cached {cachedWords}/{totalWords}, failed words {failed}',
      'zh':
          'List 完成 {doneLists}/{totalLists}，单词缓存 {cachedWords}/{totalWords}，失败单词 {failed}',
    },
    'tts_cache_incomplete': {
      'en': 'Cache incomplete Lists only',
      'zh': '只缓存未完成的 List',
    },
    'tts_cache_all_done': {
      'en': 'All CET-4 Lists are cached.',
      'zh': '所有 CET-4 List 都已缓存完成。',
    },
    'tts_cache_list_status': {
      'en': 'List {index}: {name} — {cached}/{total}',
      'zh': 'List {index}：{name} — {cached}/{total}',
    },
    'tts_cache_failed_words': {'en': 'Failed: {words}', 'zh': '失败：{words}'},
    'tts_cache_this_list': {'en': 'Cache this List', 'zh': '缓存此 List'},
    'refresh': {'en': 'Refresh', 'zh': '刷新'},
    'tts_cache_health_title': {'en': 'Cache Health', 'zh': '缓存健康'},
    'tts_cache_health_empty': {
      'en': 'No cache health report yet. Tap Check Health.',
      'zh': '尚未检查缓存健康，请点击检查。',
    },
    'tts_cache_health_summary': {
      'en':
          'Records {records}, healthy {healthy}, missing {missing}, empty {empty}, orphan files {orphan}, expired records {expiredRecords}',
      'zh':
          '记录 {records}，健康 {healthy}，缺失 {missing}，空文件 {empty}，孤立文件 {orphan}，过期记录 {expiredRecords}',
    },
    'tts_cache_health_ok': {'en': 'Cache looks healthy.', 'zh': '缓存状态正常。'},
    'tts_cache_health_issue': {'en': 'Cache needs cleanup.', 'zh': '缓存需要清理。'},
    'tts_cache_health_check': {'en': 'Check Health', 'zh': '检查健康'},
    'tts_cache_cleanup': {'en': 'Clean Expired', 'zh': '清理过期'},
    'tts_cache_cleanup_desc': {
      'en':
          'Removes broken cache files and stale cache records older than {days} days.',
      'zh': '清理损坏的缓存文件和超过 {days} 天的过期缓存记录。',
    },
    'tts_cache_cleanup_done': {
      'en': 'Cleanup complete: removed {files} files, {records} records.',
      'zh': '清理完成：删除 {files} 个文件，{records} 条记录。',
    },
    'tts_cache_cleanup_failed': {
      'en': 'Cleanup failed: {msg}',
      'zh': '清理失败：{msg}',
    },
    'tts_played_doubao_cache': {
      'en': 'Played from Doubao cache',
      'zh': '已使用豆包缓存播放',
    },
    'tts_played_doubao_api': {
      'en': 'Called Doubao API and cached audio',
      'zh': '已调用豆包 API 并缓存读音',
    },
    'tts_doubao_cache_missing_api_disabled': {
      'en': 'No Doubao cache found; live API is disabled',
      'zh': '未找到豆包缓存，实时 API 已关闭',
    },
    'tts_doubao_api_failed': {
      'en': 'Doubao API playback failed',
      'zh': '豆包 API 播放失败',
    },
    'tts_model_status': {'en': 'Model Status', 'zh': '模型状态'},
    'tts_model_not_downloaded': {
      'en': 'Model not downloaded (~350 MB)',
      'zh': '模型未下载（约350MB）',
    },
    'tts_model_downloading': {
      'en': 'Downloading model... {progress}%',
      'zh': '正在下载模型... {progress}%',
    },
    'tts_model_ready': {'en': 'Model ready', 'zh': '模型已就绪'},
    'tts_model_error': {'en': 'Download failed: {error}', 'zh': '下载失败：{error}'},
    'tts_download_model': {'en': 'Download Model', 'zh': '下载模型'},
    'tts_retry_download': {'en': 'Retry Download', 'zh': '重试下载'},
    'tts_download_warning': {
      'en': 'Uses mobile data. Download on Wi-Fi recommended.',
      'zh': '将使用移动数据，建议在Wi-Fi下下载。',
    },
    'ai_configure_hint': {
      'en': 'Please configure your AI API key in Settings.',
      'zh': '请在设置中配置你的 AI API 密钥。',
    },

    // ─── Mode labels (practice history) ───
    'mode_choice': {'en': 'Choice', 'zh': '选择题'},
    'mode_fill': {'en': 'Fill', 'zh': '填空题'},
    'mode_dictation': {'en': 'Dictation', 'zh': '听写'},
    'mode_deep_choice': {'en': 'AI Colloc.', 'zh': 'AI 搭配'},
    'mode_deep_fill': {'en': 'AI Sentence', 'zh': 'AI 句子'},
    'mode_deep_idioms': {'en': 'AI Idioms', 'zh': 'AI 俗语'},

    // ─── Built-in book names ───
    'book_cet4': {'en': 'CET-4', 'zh': '四级'},
    'book_cet6': {'en': 'CET-6', 'zh': '六级'},
    'book_kaoyan': {'en': '考研', 'zh': '考研'},

    // ─── AI Dialogue ───
    'ai_dialogue_title': {'en': 'AI Dialogue', 'zh': 'AI 对话'},
    'dialogue_scenario': {'en': 'Scenario', 'zh': '场景'},
    'select_words_for_dialogue': {
      'en': 'Select words ({count} selected)',
      'zh': '选择单词（已选 {count} 个）',
    },
    'select_all': {'en': 'Select All', 'zh': '全选'},
    'deselect_all': {'en': 'Deselect All', 'zh': '取消全选'},
    'generate_dialogue': {'en': 'Generate Dialogue', 'zh': '生成对话'},
    'generating_dialogue': {'en': 'Generating dialogue...', 'zh': '正在生成对话...'},
    'lines_count': {'en': 'lines', 'zh': '行'},
    'regenerate': {'en': 'Regenerate', 'zh': '重新生成'},
    'toggle_translation': {'en': 'Toggle Translation', 'zh': '切换翻译'},
    'ai_dialogue_btn': {'en': 'AI Dialogue', 'zh': 'AI 对话'},
  };

  static String get(String key, String lang, {Map<String, String>? params}) {
    final str = _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
    if (params != null) {
      var result = str;
      for (final entry in params.entries) {
        result = result.replaceAll('{${entry.key}}', entry.value);
      }
      return result;
    }
    return str;
  }
}
