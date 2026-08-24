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
    'phonetics_menu': {'en': 'Phonetics', 'zh': '音标学习'},
    'phonetics_menu_desc': {
      'en': 'Learn the 44 Cambridge British English phonemes.',
      'zh': '学习剑桥英式英语 44 个音素。',
    },
    'phonetics_title': {
      'en': 'Cambridge British English IPA',
      'zh': '剑桥英式英语音标',
    },
    'phonetics_monophthongs': {'en': 'Monophthongs', 'zh': '单元音'},
    'phonetics_diphthongs': {'en': 'Diphthongs', 'zh': '双元音'},
    'phonetics_consonants': {'en': 'Consonants', 'zh': '辅音'},
    'phonetics_play_label': {
      'en': 'Play /{symbol}/, example {example}',
      'zh': '播放 /{symbol}/，代表词 {example}',
    },
    'phonetics_play_failed': {
      'en': 'Could not play /{symbol}/.',
      'zh': '无法播放 /{symbol}/。',
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
    'home_section_labs': {'en': 'Labs', 'zh': '实验室'},
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
    'workflow_title': {'en': "Today's workflow", 'zh': '今日工作流'},
    'workflow_subtitle': {
      'en':
          'Choose one or more Lists, memorize them, then explore the AI modules.',
      'zh': '选择一个或多个 List，先背词，再探索 AI 模块。',
    },
    'workflow_memorization': {'en': 'Memorize words', 'zh': '背单词'},
    'workflow_memorization_desc': {
      'en': 'Preview a List and start the regular practice.',
      'zh': '先预览 List，再开始普通练习。',
    },
    'workflow_select_list': {'en': 'Select Lists', 'zh': '选择 List'},
    'workflow_select_list_required': {
      'en': 'Select at least one List before starting.',
      'zh': '开始前请至少选择一个 List。',
    },
    'workflow_selected_lists': {
      'en': '{count} Lists selected',
      'zh': '已选择 {count} 个 List',
    },
    'workflow_choose_selected_list': {
      'en': 'Choose a selected List',
      'zh': '选择要使用的 List',
    },
    'workflow_next_unpassed': {'en': 'Suggested next List', 'zh': '建议下一个 List'},
    'workflow_ai_learning': {'en': 'AI Learning', 'zh': 'AI 学习'},
    'workflow_ai_learning_desc': {
      'en': 'Practice collocations, sentences, and idioms with AI.',
      'zh': '使用 AI 练习搭配、句子和俗语。',
    },
    'workflow_ai_dialogue': {'en': 'AI Dialogue', 'zh': 'AI 对话'},
    'workflow_ai_dialogue_desc': {
      'en': 'Use your List words in a guided role-play.',
      'zh': '在引导式角色对话中使用 List 单词。',
    },
    'workflow_skills': {'en': 'Lingo Skills', 'zh': 'Lingo Skills'},
    'workflow_skills_desc': {
      'en': 'Run a reusable skill on the selected List.',
      'zh': '在所选 List 上运行可复用 Skill。',
    },
    'workflow_locked': {'en': 'Locked', 'zh': '未解锁'},
    'workflow_lock_hint': {
      'en': 'Finish memorization first to unlock this entry.',
      'zh': '请先完成背词，解锁此入口。',
    },
    'workflow_same_book_required': {
      'en': 'AI Learning needs passed Lists from one word book.',
      'zh': 'AI 学习需要选择同一本词书中已通过的 List。',
    },
    'workflow_no_list': {
      'en': 'Import or create a List first.',
      'zh': '请先导入或创建 List。',
    },
    'workflow_return': {'en': 'Back to workflow', 'zh': '返回工作流'},
    'review_list_progress': {'en': 'List memorization', 'zh': 'List 背诵情况'},
    'review_list_stats': {
      'en': '{sessions} sessions · {covered}/{total} words',
      'zh': '{sessions} 次练习 · 覆盖 {covered}/{total} 词',
    },
    'review_word_detail': {
      'en': '{answers} answers · {correct} correct · {incorrect} incorrect',
      'zh': '{answers} 次答题 · 正确 {correct} · 错误 {incorrect}',
    },
    'review_no_word_details': {
      'en': 'No answers on this date.',
      'zh': '当天没有答题记录。',
    },
    'review_ai_analysis': {'en': 'AI learning analysis', 'zh': 'AI 学习分析'},
    'review_ai_type_ai_learning': {'en': 'AI Learning', 'zh': 'AI 学习'},
    'review_ai_type_dialogue': {'en': 'AI Dialogue', 'zh': 'AI 对话'},
    'review_ai_type_skill': {'en': 'Lingo Skills', 'zh': 'Lingo Skills'},
    'review_ai_questions': {
      'en': 'Questions {questions} · accuracy {accuracy}',
      'zh': '题量 {questions} · 正确率 {accuracy}',
    },
    'review_dialogue_metrics': {
      'en': 'Dialogue turns {turns} · target uses {used}',
      'zh': '对话轮次 {turns} · 目标词使用 {used}',
    },
    'review_skill_metrics': {
      'en': 'Skill runs {runs}',
      'zh': 'Skill 运行 {runs} 次',
    },
    'review_focus_words': {'en': 'Focus words: {words}', 'zh': '重点词：{words}'},
    'review_focus_words_empty': {'en': 'No focus words yet.', 'zh': '暂无重点词。'},
    'speaking_check': {'en': 'Speaking check', 'zh': '口语检查'},
    'coming_soon': {'en': 'Coming soon', 'zh': '即将支持'},
    'not_available': {'en': '—', 'zh': '—'},
    'dismiss': {'en': 'Dismiss', 'zh': '知道了'},
    'review_data_reset_notice': {
      'en':
          'Legacy review data was cleared. New statistics start from this upgrade.',
      'zh': '旧复习数据已清除，统计从本次升级后的新记录开始。',
    },

    // ─── Labs ───
    'lab_present_menu': {'en': 'Present Tense Diagnosis Lab', 'zh': '现在时诊断实验室'},
    'lab_present_menu_desc': {
      'en': 'Test real answers against the local grammar diagnosis engine.',
      'zh': '用真实回答验证本地语法诊断引擎。',
    },
    'lab_present_title': {
      'en': 'Present Tense Diagnosis Lab',
      'zh': '现在时诊断实验室',
    },
    'lab_present_experiment_badge': {'en': 'Experiment', 'zh': '实验验证'},
    'lab_present_intro': {
      'en':
          'This page only sends the question and answer to the local diagnosis service, then renders the returned JSON.',
      'zh': '本页面只把题目和回答发送给本地诊断服务，然后渲染返回的 JSON。',
    },
    'lab_present_question_section': {'en': 'Question', 'zh': '题目区'},
    'lab_present_question_picker': {'en': 'Built-in prompt', 'zh': '内置题目'},
    'lab_present_answer_label': {'en': 'Your answer', 'zh': '用户回答'},
    'lab_present_answer_hint': {
      'en': 'Type a real learner answer...',
      'zh': '输入一个真实学习者回答...',
    },
    'lab_present_use_sample': {'en': 'Use sample answer', 'zh': '使用示例回答'},
    'lab_present_sample_answer': {
      'en': 'My brother like coffee, but he drinking tea now.',
      'zh': 'My brother like coffee, but he drinking tea now.',
    },
    'lab_present_submit': {'en': 'Run Diagnosis', 'zh': '提交诊断'},
    'lab_present_submitting': {'en': 'Diagnosing...', 'zh': '正在诊断...'},
    'lab_present_empty_answer': {
      'en': 'Enter an answer first.',
      'zh': '请先输入回答。',
    },
    'lab_present_submit_failed': {
      'en': 'Diagnosis failed: {error}',
      'zh': '诊断失败：{error}',
    },
    'lab_present_feedback_section': {'en': 'Business Feedback', 'zh': '业务反馈区'},
    'lab_present_feedback_empty': {
      'en': 'Submit an answer to see the user-facing diagnosis.',
      'zh': '提交回答后查看面向用户的诊断结果。',
    },
    'lab_present_has_error': {
      'en': 'The answer has grammar errors.',
      'zh': '回答存在语法错误。',
    },
    'lab_present_no_error': {
      'en': 'No grammar error was found.',
      'zh': '未发现语法错误。',
    },
    'lab_present_error_n': {'en': 'Error {index}', 'zh': '第 {index} 处错误'},
    'lab_present_error_span': {'en': 'Span', 'zh': '错误片段'},
    'lab_present_error_type': {'en': 'Error type', 'zh': '错误类型'},
    'lab_present_grammar_rule': {'en': 'Grammar rule', 'zh': '语法声明'},
    'lab_present_reasoning': {'en': 'Reasoning', 'zh': '改正思路'},
    'lab_present_correction': {'en': 'Correction', 'zh': '改正'},
    'lab_present_corrected_answer': {
      'en': 'Corrected example',
      'zh': '改正后的正确例子',
    },
    'lab_present_manual_rating': {'en': 'Manual Rating', 'zh': '手动评价'},
    'lab_present_rating_good': {'en': 'Good', 'zh': '好'},
    'lab_present_rating_acceptable': {'en': 'Acceptable', 'zh': '可接受'},
    'lab_present_rating_failed_label': {'en': 'Failed', 'zh': '失败'},
    'lab_present_rating_unset': {'en': 'unset', 'zh': '未评价'},
    'lab_present_rating_failed': {
      'en': 'Failed to save rating: {error}',
      'zh': '保存评价失败：{error}',
    },
    'lab_present_debug_section': {'en': 'Debug', 'zh': 'Debug 区'},
    'lab_present_central_cards': {'en': 'central cards', 'zh': 'central cards'},
    'lab_present_supporting_cards': {
      'en': 'supporting cards',
      'zh': 'supporting cards',
    },
    'lab_present_fallback': {'en': 'fallback', 'zh': 'fallback'},
    'lab_present_record_id': {'en': 'record id', 'zh': 'record id'},
    'lab_present_records_path': {'en': 'records path', 'zh': 'records path'},
    'lab_present_raw_json': {'en': 'raw JSON', 'zh': 'raw JSON'},
    'lab_present_raw_json_empty': {'en': 'No response yet.', 'zh': '暂无返回结果。'},
    'lab_present_recent_records': {'en': 'Recent records', 'zh': '最近测试记录'},
    'lab_present_recent_record_line': {
      'en': '{time} · central {cards} · rating {rating}',
      'zh': '{time} · central {cards} · 评价 {rating}',
    },
    'lab_present_known_gap_section': {'en': 'Known Gap Cases', 'zh': '已知漏判样例'},
    'lab_present_known_gap_desc': {
      'en': 'Regression samples for later knowledge-base expansion.',
      'zh': '用于后续知识库扩展后的回归验证。',
    },
    'lab_present_known_gap_answer': {'en': 'Answer', 'zh': '回答'},
    'lab_present_known_gap_expected': {
      'en': 'Expected correction',
      'zh': '预期改正',
    },
    'lab_present_known_gap_units': {
      'en': 'Future knowledge area',
      'zh': '后续知识点范围',
    },
    'lab_present_known_gap_load': {'en': 'Load Case', 'zh': '加载样例'},
    'lab_present_known_gap_1_label': {
      'en': 'Either/neither for two alternatives',
      'zh': '两者否定 either / neither',
    },
    'lab_present_known_gap_1_answer': {
      'en': "She doesn't like any one.",
      'zh': "She doesn't like any one.",
    },
    'lab_present_known_gap_1_expected': {
      'en': "She doesn't like either. / She likes neither.",
      'zh': "She doesn't like either. / She likes neither.",
    },
    'lab_present_known_gap_1_units': {
      'en':
          'Pronouns and determiners: either, neither, one; later units 42, 76, 77, 81.',
      'zh': '代词和限定词：either、neither、one；后续 Unit 42、76、77、81。',
    },
    'lab_present_known_gap_2_label': {
      'en': 'Count noun plural after some',
      'zh': 'some 后可数名词复数',
    },
    'lab_present_known_gap_2_answer': {
      'en': 'She is reading some newspaper.',
      'zh': 'She is reading some newspaper.',
    },
    'lab_present_known_gap_2_expected': {
      'en': 'She is reading some newspapers.',
      'zh': 'She is reading some newspapers.',
    },
    'lab_present_known_gap_2_units': {
      'en':
          'Countable and uncountable nouns; noun plural forms; later units 66 and 67.',
      'zh': '可数 / 不可数名词、名词复数形式；后续 Unit 66、67。',
    },
    'lab_present_question_1': {
      'en': 'What does your brother drink?',
      'zh': 'What does your brother drink?',
    },
    'lab_present_question_2': {
      'en': 'What does your sister do every morning?',
      'zh': 'What does your sister do every morning?',
    },
    'lab_present_question_3': {
      'en': 'Where does Tom work?',
      'zh': 'Where does Tom work?',
    },
    'lab_present_question_4': {
      'en': 'What are you doing now?',
      'zh': 'What are you doing now?',
    },
    'lab_present_question_5': {
      'en': 'What is Anna reading at the moment?',
      'zh': 'What is Anna reading at the moment?',
    },
    'lab_present_question_6': {
      'en': 'How often do you watch TV?',
      'zh': 'How often do you watch TV?',
    },
    'lab_present_question_7': {
      'en': 'Does your father usually cook dinner?',
      'zh': 'Does your father usually cook dinner?',
    },
    'lab_present_question_8': {
      'en': 'Are the children playing outside now?',
      'zh': 'Are the children playing outside now?',
    },
    'lab_present_question_9': {
      'en': 'What time does the train leave?',
      'zh': 'What time does the train leave?',
    },
    'lab_present_question_10': {
      'en': 'What are your friends talking about?',
      'zh': 'What are your friends talking about?',
    },
    'lab_present_question_11': {
      'en': 'Does Maria like tea or coffee?',
      'zh': 'Does Maria like tea or coffee?',
    },
    'lab_present_question_12': {
      'en': 'What do you usually have for breakfast?',
      'zh': 'What do you usually have for breakfast?',
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
    'cue_memory_collection': {'en': 'Cue Memory Collection', 'zh': '线索记忆收录'},
    'learning_stats': {'en': 'Study Stats', 'zh': '学习统计'},
    'total_error_count': {'en': 'Total Errors', 'zh': '累计错误数'},
    'total_forgotten_count': {'en': 'Total Forgotten', 'zh': '累计遗忘词数'},
    'total_cue_memory_count': {'en': 'Total Cue Memory', 'zh': '累计线索记忆词数'},
    'active_error_words': {'en': 'Active Error Words', 'zh': '当前错词数'},
    'active_forgotten_words': {'en': 'Active Forgotten Words', 'zh': '当前遗忘词数'},
    'active_cue_memory_words': {
      'en': 'Active Cue Memory Words',
      'zh': '当前线索记忆词数',
    },
    'sort_by_error_count': {'en': 'By Errors', 'zh': '按错误次数'},
    'sort_by_forgotten_count': {'en': 'By Forgotten', 'zh': '按遗忘次数'},
    'sort_by_cue_memory_count': {'en': 'By Cue Memory', 'zh': '按线索记忆次数'},
    'review_choice': {'en': 'Choice', 'zh': '选择题'},
    'review_fill': {'en': 'Fill', 'zh': '填空题'},
    'no_review_data': {'en': 'No review data yet.', 'zh': '暂无复习数据。'},
    'error_count_label': {'en': 'Errors', 'zh': '错误'},
    'forgotten_count_label': {'en': 'Forgotten', 'zh': '遗忘'},
    'cue_memory_count_label': {'en': 'Cue Memory', 'zh': '线索记忆'},
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
    'cue_memory_button': {'en': 'Cue memory', 'zh': '线索记忆'},
    'cue_memory_marked': {'en': 'Cue memory marked', 'zh': '已标记线索记忆'},
    'completely_forgotten': {'en': 'Completely forgotten', 'zh': '完全遗忘'},
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
    'cue_memory_cleared_n': {
      'en': 'Cleared cue-memory status for {count} words.',
      'zh': '已清除 {count} 个单词的线索记忆状态。',
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
    'reveal_example': {'en': 'Reveal example', 'zh': '查看例句'},
    'invalid_meanings': {'en': 'Incorrect:', 'zh': '错误释义：'},

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
    'back': {'en': 'Back', 'zh': '返回'},
    'deep_scope_title': {'en': 'Choose practice range', 'zh': '选择练习范围'},
    'deep_scope_description': {
      'en':
          'Choose a continuous range of passed Lists from one word book. Only words in this range become exercise targets.',
      'zh': '在同一本词书中选择连续的已通过 List。只有该范围内的单词会成为练习目标。',
    },
    'deep_scope_book_label': {'en': 'Word book', 'zh': '词书'},
    'deep_scope_passed_section_label': {
      'en': 'Available passed sections',
      'zh': '可选的已通过区段',
    },
    'deep_scope_start_label': {'en': 'Start List', 'zh': '起始 List'},
    'deep_scope_end_label': {'en': 'End List', 'zh': '结束 List'},
    'deep_scope_selected_title': {'en': 'Selected range', 'zh': '已选范围'},
    'deep_scope_selected_count': {
      'en': '{lists} Lists · {words} words',
      'zh': '{lists} 个 List · {words} 个单词',
    },
    'deep_scope_range_label': {
      'en': '{start} – {end}',
      'zh': '{start} – {end}',
    },
    'deep_scope_continue': {'en': 'Choose learning mode', 'zh': '选择学习模式'},
    'deep_scope_other_lists': {'en': 'Other Lists', 'zh': '其他 List'},
    'deep_scope_no_passed_lists': {
      'en': 'Pass at least one List before starting AI Deep Learning.',
      'zh': '至少通过一个 List 后才能开始 AI 深度学习。',
    },
    'deep_scope_load_error': {
      'en': 'Unable to load your Lists.',
      'zh': '无法加载你的 List。',
    },
    'deep_scope_invalid': {
      'en': 'Choose at least one passed List first.',
      'zh': '请先选择至少一个已通过的 List。',
    },
    'deep_scope_requires_pass': {
      'en': 'Every List in this range must be passed.',
      'zh': '范围内的每个 List 都必须已通过。',
    },
    'deep_scope_same_book_required': {
      'en': 'Choose Lists from the same word book.',
      'zh': '请选择同一本词书中的 List。',
    },
    'deep_scope_no_words': {
      'en': 'The selected range has no words.',
      'zh': '所选范围没有单词。',
    },
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
    'deep_no_generated_content': {
      'en': 'No usable AI content was generated. Please generate again.',
      'zh': '没有生成可用的 AI 内容，请重新生成。',
    },
    'deep_generation_failed': {
      'en': 'AI generation failed: {error}',
      'zh': 'AI 生成失败：{error}',
    },
    'deep_ai_response_invalid': {
      'en':
          'The AI returned an incomplete response after one retry. Please try again, or check the selected provider and model in Settings.',
      'zh': 'AI 重试后仍返回不完整内容。请重新生成，或检查设置中的服务商和模型。',
    },
    'deep_answer_check_failed': {
      'en':
          'Unable to check this alternative answer. Please try again: {error}',
      'zh': '无法判断这个替代答案，请重试：{error}',
    },

    // ─── Deep practice quiz ───
    'collocation_question': {
      'en': 'What word fits this collocation?',
      'zh': '哪个词符合这个搭配？',
    },
    'collocation_fill_question': {
      'en': 'Type the target word to complete this collocation',
      'zh': '输入目标词完成这个搭配',
    },
    'deep_collocation_fill_notice': {
      'en':
          'Safe multiple-choice options were unavailable, so this collocation is shown as a fill-in question.',
      'zh': '暂时无法校验安全的选择题干扰项，因此该搭配以填空题呈现。',
    },
    'deep_collocation_fill_setup_notice': {
      'en':
          'Some collocations will use typing because safe multiple-choice options could not be verified.',
      'zh': '部分搭配因无法校验安全干扰项，将以填空方式练习。',
    },
    'deep_collocation_fill_disabled_notice': {
      'en':
          'AI option validation is off, so this collocation is shown as a fill-in question.',
      'zh': 'AI 干扰项校验已关闭，因此该搭配以填空题呈现。',
    },
    'deep_collocation_fill_setup_disabled_notice': {
      'en':
          'AI option validation is off. Collocations will use typing instead of multiple choice.',
      'zh': 'AI 干扰项校验已关闭，搭配题将以填空方式练习。',
    },
    'complete_sentence': {'en': 'Complete the sentence', 'zh': '完成句子'},
    'hint_prefix': {'en': 'Hint: {hint}', 'zh': '提示：{hint}'},
    'type_missing_word': {'en': 'Type the missing word...', 'zh': '输入缺失的单词...'},
    'previous_question': {'en': 'Previous question', 'zh': '上一题'},
    'edit_answer': {'en': 'Edit answer', 'zh': '修改答案'},
    'deep_acceptable_alternative': {
      'en': 'Acceptable alternative',
      'zh': '表达可接受',
    },
    'deep_acceptable_alternative_message': {
      'en': 'Your answer works, but the target word is {word}.',
      'zh': '你的表达可以成立，但本题目标词是 {word}。',
    },
    'deep_acceptable_alternative_count': {
      'en':
          '{count} answer(s) were linguistically acceptable but did not use the target word.',
      'zh': '{count} 个答案表达可接受，但未使用目标词。',
    },

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
    'ai_collocation_option_validation': {
      'en': 'AI-validate collocation options',
      'zh': 'AI 校验搭配干扰项',
    },
    'ai_collocation_option_validation_desc': {
      'en':
          'Uses an extra AI call to verify multiple-choice distractors. Turn it off to save time and tokens; collocations will use fill-in questions.',
      'zh': '额外调用 AI 校验选择题干扰项。关闭可节省时间和 Token；搭配题将以填空题呈现。',
    },
    'language_tool_section': {
      'en': 'LanguageTool Grammar Check',
      'zh': 'LanguageTool 语法检查',
    },
    'language_tool_desc': {
      'en':
          'Checks each AI Dialogue reply before AI feedback and adds grammar suggestions to the feedback panel.',
      'zh': '在 AI 对话反馈前检查每次英文回复，并把语法建议加入反馈区。',
    },
    'language_tool_base_url': {
      'en': 'LanguageTool Base URL',
      'zh': 'LanguageTool 服务地址',
    },
    'language_tool_test_success': {
      'en': 'LanguageTool connection successful.',
      'zh': 'LanguageTool 连接成功。',
    },
    'language_tool_test_failed': {
      'en': 'LanguageTool test failed: {error}',
      'zh': 'LanguageTool 测试失败：{error}',
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
    'tts_section': {'en': 'TTS Engine', 'zh': '语音引擎'},
    'tts_engine_label': {'en': 'Speech Engine', 'zh': '语音引擎'},
    'word_audio_playback_title': {
      'en': 'Word Pronunciation Playback',
      'zh': '单词读音播放来源',
    },
    'word_audio_playback_source_label': {'en': 'Playback source', 'zh': '播放来源'},
    'word_audio_playback_remote': {'en': 'Server WAV', 'zh': '服务器 WAV'},
    'word_audio_playback_remote_desc': {
      'en':
          'Fetches each pre-generated WAV from the server and plays it from memory. It never calls the TTS engine selected below.',
      'zh': '从服务器请求每个预生成 WAV，并只在内存中播放；不会调用下方选中的 TTS 引擎。',
    },
    'word_audio_playback_current_tts': {
      'en': 'Current TTS Engine (development)',
      'zh': '当前 TTS 引擎（开发测试）',
    },
    'word_audio_playback_current_tts_desc': {
      'en':
          'Uses the TTS engine selected below and its normal cache/API flow. It never falls back to the server automatically.',
      'zh': '使用下方选中的 TTS 引擎及其常规缓存/API 流程；不会自动回退到服务器。',
    },
    'example_audio_playback_title': {
      'en': 'Example Sentence Playback',
      'zh': '例句音频播放来源',
    },
    'example_audio_playback_source_label': {
      'en': 'Playback source',
      'zh': '播放来源',
    },
    'example_audio_playback_remote': {
      'en': 'Server WAV (Qwen3 Katerina)',
      'zh': '服务器 WAV（Qwen3 Katerina）',
    },
    'example_audio_playback_current_tts': {
      'en': 'Current TTS Engine',
      'zh': '当前 TTS 引擎',
    },
    'example_audio_playback_remote_desc': {
      'en':
          'Fetches the published Qwen3 example WAV from the server and plays it from memory. A missing file never triggers a cloud TTS request.',
      'zh': '从服务器请求已发布的 Qwen3 例句 WAV，并只在内存中播放；文件缺失时绝不会自动调用云端 TTS。',
    },
    'example_audio_playback_remote_tencent_wewinny': {
      'en': 'Server WAV (Tencent WeWinny + WeJack)',
      'zh': '服务器 WAV（腾讯云 WeWinny + WeJack）',
    },
    'example_audio_playback_remote_tencent_wewinny_desc': {
      'en':
          'Fetches the published Tencent Cloud example WAV (existing WeWinny or repaired WeJack) from the server and plays it from memory. A missing file never triggers a cloud TTS request.',
      'zh':
          '从服务器请求已发布的腾讯云例句 WAV（已有 WeWinny 或补跑的 WeJack），并只在内存中播放；文件缺失时绝不会自动调用云端 TTS。',
    },
    'example_audio_playback_current_tts_desc': {
      'en':
          'Uses the selected TTS engine and its normal local-cache/API flow. This is the default until a Qwen3 example release is published.',
      'zh': '使用选中 TTS 引擎的常规本地缓存/API 流程；在 Qwen3 例句发布完成前，这是默认模式。',
    },
    'example_audio_server_not_configured': {
      'en': 'Set the server audio address before playing example sentences.',
      'zh': '请先设置服务器音频地址，再播放例句。',
    },
    'example_audio_server_invalid_url': {
      'en': 'The server audio address is invalid.',
      'zh': '服务器音频地址无效。',
    },
    'example_audio_file_not_found': {
      'en': 'This example sentence has not been uploaded to the server yet.',
      'zh': '此例句音频尚未上传到服务器。',
    },
    'example_audio_timeout': {
      'en': 'The example-audio server request timed out.',
      'zh': '例句音频服务器请求超时。',
    },
    'example_audio_invalid_file': {
      'en': 'The server response is not a valid example WAV file.',
      'zh': '服务器响应不是有效的例句 WAV 文件。',
    },
    'example_audio_unavailable': {
      'en': 'Example audio is currently unavailable.',
      'zh': '例句音频暂时不可用。',
    },
    'example_audio_direct_not_configured': {
      'en':
          'Configure the current TTS engine before playing example sentences.',
      'zh': '请先配置当前 TTS 引擎，再播放例句。',
    },
    'example_audio_direct_failed': {
      'en': 'The current TTS engine could not play this example sentence.',
      'zh': '当前 TTS 引擎无法播放此例句。',
    },
    'word_audio_server_title': {'en': 'Word Audio Server', 'zh': '单词音频服务器'},
    'word_audio_server_desc': {
      'en':
          'Each word is fetched as a pre-generated WAV and played from memory only. For development, enter http://<Lighthouse-IP>/audio; use an HTTPS domain for release.',
      'zh':
          '每个单词都会请求预生成的 WAV，并只在内存中播放。开发期填写 http://<Lighthouse-IP>/audio；正式版请改用 HTTPS 域名。',
    },
    'word_audio_server_address': {'en': 'Server base address', 'zh': '服务器基础地址'},
    'word_audio_server_address_hint': {
      'en': 'http://<Lighthouse-IP>/audio',
      'zh': 'http://<Lighthouse-IP>/audio',
    },
    'word_audio_server_save': {'en': 'Save Server Address', 'zh': '保存服务器地址'},
    'word_audio_server_invalid_address': {
      'en': 'Enter a valid HTTP or HTTPS server address.',
      'zh': '请输入有效的 HTTP 或 HTTPS 服务器地址。',
    },
    'tts_openai': {
      'en': 'OpenAI TTS — high quality, paid',
      'zh': 'OpenAI TTS — 高质量付费',
    },
    'tts_openai_title': {'en': 'OpenAI TTS', 'zh': 'OpenAI TTS'},
    'tts_qwen': {
      'en': 'Qwen Audio TTS — word pronunciation',
      'zh': 'Qwen Audio TTS — 单词发音',
    },
    'tts_qwen_title': {'en': 'Qwen Audio TTS', 'zh': 'Qwen Audio TTS'},
    'tts_qwen3_flash_katerina': {
      'en': 'Qwen3 Flash — Katerina',
      'zh': 'Qwen3 Flash — Katerina',
    },
    'tts_qwen3_flash_katerina_title': {
      'en': 'Qwen3-TTS-Flash · Katerina',
      'zh': 'Qwen3-TTS-Flash · Katerina',
    },
    'tts_qwen3_flash_katerina_desc': {
      'en':
          'A fixed Qwen3-TTS-Flash profile for English example sentences. Katerina is an expressive female system voice; this profile has its own local cache and does not change approved word audio.',
      'zh':
          '用于英语例句的固定 Qwen3-TTS-Flash 预设。Katerina 是富有表现力的女性系统音色；此预设使用独立本地缓存，不会修改已确认的单词音频。',
    },
    'tts_qwen3_flash_katerina_instruction': {
      'en':
          'Clear, natural British pronunciation; moderate pace; fluent, expressive intonation; continuous rhythm; suitable for reading English sentences.',
      'zh': '清晰自然的英式发音，语速适中，语调流畅有起伏，节奏连贯，适合英语句子朗读。',
    },
    'tts_qwen_word_preset_title': {
      'en': 'Qwen Audio TTS — approved word profile',
      'zh': 'Qwen Audio TTS — 已确认的单词预设',
    },
    'tts_qwen_word_preset_desc': {
      'en':
          'The existing approved Qwen Audio TTS word-pronunciation profile. Its model, voice, WAV format, cache identity, and release flow remain unchanged.',
      'zh': '现有已确认的 Qwen Audio TTS 单词发音预设。其模型、音色、WAV 格式、缓存标识和发布流程均保持不变。',
    },
    'tts_doubao': {
      'en': 'Doubao TTS — cloud, high quality',
      'zh': '豆包语音合成 — 云端高质量',
    },
    'tts_doubao_title': {'en': 'Doubao TTS', 'zh': '豆包语音合成'},
    'tts_api_key_label': {'en': 'TTS API Key', 'zh': 'TTS API 密钥'},
    'tts_api_key_hint': {
      'en': 'Enter your TTS API key',
      'zh': '请输入你的 TTS API 密钥',
    },
    'tts_base_url_label': {'en': 'Base URL', 'zh': '接口地址'},
    'tts_model_label': {'en': 'Model', 'zh': '模型'},
    'tts_voice_label': {'en': 'Voice', 'zh': '音色'},
    'tts_instruction_label': {'en': 'Fixed instruction', 'zh': '固定朗读指令'},
    'tts_resource_id_label': {'en': 'Resource ID', 'zh': '资源 ID'},
    'tts_workspace_id_label': {
      'en': 'Alibaba Cloud Workspace ID (Beijing)',
      'zh': '阿里云 Workspace ID（北京地域）',
    },
    'tts_qwen_word_audio_profile': {
      'en': 'Server-staged word audio: WAV, 48 kHz (original)',
      'zh': '服务器暂存的单词音频：WAV，48 kHz（原始）',
    },
    'tts_qwen_word_audio_profile_desc': {
      'en':
          'Keeps the fixed Qwen voice and approved profile. These WAV files are staging assets for upload; word playback does not read device storage.',
      'zh': '保持固定的 Qwen 音色和已确认的参数。这些 WAV 仅用于生成后上传；单词播放不会读取设备存储。',
    },
    'word_audio_release_title': {
      'en': 'One-tap Server Audio Release',
      'zh': '单词音频一键发布',
    },
    'word_audio_release_desc': {
      'en':
          'Choose one or more CET-4 Lists, review the combined call cap once, then generate, validate, package, publish, and HTTP-check them automatically.',
      'zh': '选择一个或多个 CET-4 List，一次确认合计调用上限后，应用会自动生成、校验、打包、发布并进行 HTTP 检查。',
    },
    'qwen3_example_audio_release_title': {
      'en': 'Qwen3 Example Audio Release',
      'zh': 'Qwen3 例句音频发布',
    },
    'qwen3_example_audio_release_desc': {
      'en':
          'Batch-cache the selected CET-4 scenario examples with Qwen3-TTS-Flash / Katerina, validate the independent WAV profile, then package, publish, and HTTP-check /audio/v1/en/examples/.',
      'zh':
          '使用 Qwen3-TTS-Flash / Katerina 批量缓存所选 CET-4 场景例句，校验独立 WAV 配置后，打包、发布并 HTTP 检查 /audio/v1/en/examples/。',
    },
    'qwen3_example_audio_release_list_label': {
      'en': 'CET-4 Lists to release',
      'zh': '要发布例句的 CET-4 List',
    },
    'qwen3_example_audio_release_list_option': {
      'en': 'List {index}: {name} — {count} examples',
      'zh': 'List {index}：{name} — {count} 条例句',
    },
    'qwen3_example_audio_release_no_lists': {
      'en': 'No CET-4 List is available. Import CET-4 first, then refresh.',
      'zh': '没有可发布例句的 CET-4 List。请先导入 CET-4，然后刷新。',
    },
    'qwen3_example_audio_release_select_lists': {
      'en': 'Select CET-4 Lists for examples',
      'zh': '选择要处理例句的 CET-4 List',
    },
    'qwen3_example_audio_release_no_selection': {
      'en': 'Select at least one CET-4 List to continue.',
      'zh': '请至少选择一个 CET-4 List 后继续。',
    },
    'qwen3_example_audio_release_selected_lists': {
      'en': '{count} Lists selected: {lists}',
      'zh': '已选择 {count} 个 List：{lists}',
    },
    'qwen3_example_audio_release_plan_summary': {
      'en':
          '{lists}: {total} unique example WAVs; valid reusable WAVs {reusable}; need synthesis {pending}.',
      'zh':
          '{lists}：共 {total} 个唯一例句 WAV；可复用有效 WAV {reusable} 个；需合成 {pending} 个。',
    },
    'qwen3_example_audio_release_confirm_title': {
      'en': 'Confirm Qwen3 example release',
      'zh': '确认 Qwen3 例句发布',
    },
    'qwen3_example_audio_release_confirm_publish_desc': {
      'en':
          'Release {lists}: it will synthesize missing Qwen3 example WAVs, validate them, create one local package, publish through the configured uploader, and HTTP-check the result.',
      'zh':
          '发布 {lists}：将合成缺失的 Qwen3 例句 WAV、校验、创建一个本地包、通过已配置的发布器上传，并进行 HTTP 检查。',
    },
    'qwen3_example_audio_release_confirm_generate_desc': {
      'en':
          'Generate {lists}: it will synthesize missing Qwen3 example WAVs, validate them, and create one local upload package without publishing.',
      'zh': '生成 {lists}：将合成缺失的 Qwen3 例句 WAV、校验并创建一个本地上传包，但不会发布到服务器。',
    },
    'qwen3_example_audio_release_confirm_calls': {
      'en':
          'This authorization covers {calls} normal Qwen3 cloud calls and no more than {attempts} total attempts (up to two retries per example).',
      'zh': '本次授权包含 {calls} 次正常 Qwen3 云端调用，最多 {attempts} 次总尝试（每条例句最多重试两次）。',
    },
    'qwen3_example_audio_release_confirm_cache': {
      'en': 'Already reusable: {reusable}/{total} valid local example WAVs.',
      'zh': '已可复用：{reusable}/{total} 个有效本地例句 WAV。',
    },
    'qwen3_example_audio_release_package_ready': {
      'en':
          'A validated local package with {count} Qwen3 example WAVs is ready for server verification or republishing.',
      'zh': '包含 {count} 个 Qwen3 例句 WAV 的已校验本地包已就绪，可用于服务器校验或重新发布。',
    },
    'qwen3_example_audio_release_synthesis_failed': {
      'en':
          'Synthesis failed for at least one example sentence. Nothing was packaged or published.',
      'zh': '至少有一条例句合成失败，未进行打包或发布。',
    },
    'qwen3_example_audio_release_validation_failed': {
      'en':
          'A required Qwen3 example WAV did not pass validation. Nothing was published.',
      'zh': '所需 Qwen3 例句 WAV 未通过校验，未发布任何文件。',
    },
    'qwen3_example_audio_release_error_detail': {
      'en': 'Qwen3 example release error: {msg}',
      'zh': 'Qwen3 例句发布错误：{msg}',
    },
    'qwen3_example_audio_release_list_cached': {
      'en': 'Local example cache complete',
      'zh': '本地例句缓存完整',
    },
    'qwen3_example_audio_release_list_cache_progress': {
      'en': 'Local examples: {cached}/{total}',
      'zh': '本地例句：{cached}/{total}',
    },
    'qwen3_example_audio_release_list_cache_unknown': {
      'en': 'Local example cache status has not loaded',
      'zh': '本地例句缓存状态尚未加载',
    },
    'qwen3_example_audio_release_all_lists_cached': {
      'en':
          'All CET-4 example Lists are fully cached. Select any List to package or publish without synthesis.',
      'zh': '所有 CET-4 List 的例句均已完整缓存，可选择任意 List 打包或发布，不会重新合成。',
    },
    'qwen3_example_audio_release_cache_status_failed': {
      'en': 'Could not load local example cache status: {msg}',
      'zh': '无法加载本地例句缓存状态：{msg}',
    },
    'qwen3_example_audio_release_server_status_title': {
      'en': 'Qwen3 example server status',
      'zh': 'Qwen3 例句服务器状态',
    },
    'qwen3_example_audio_release_check_server_status': {
      'en': 'Check server status',
      'zh': '检查服务器状态',
    },
    'qwen3_example_audio_release_refresh_server_status': {
      'en': 'Refresh server status',
      'zh': '刷新服务器状态',
    },
    'qwen3_example_audio_release_server_status_not_checked': {
      'en':
          'Check the server to show upload status for fully cached example Lists.',
      'zh': '检查服务器后，可显示已完整缓存例句 List 的上传状态。',
    },
    'qwen3_example_audio_release_server_status_no_cached': {
      'en': 'No fully cached example List is available to check.',
      'zh': '没有本地例句缓存完整的 List 可供检查。',
    },
    'qwen3_example_audio_release_server_status_progress': {
      'en': 'Checking Qwen3 example WAVs: {done}/{total}',
      'zh': '正在检查 Qwen3 例句 WAV：{done}/{total}',
    },
    'qwen3_example_audio_release_server_status_uploaded': {
      'en': 'Uploaded: {lists}',
      'zh': '已上传：{lists}',
    },
    'qwen3_example_audio_release_server_status_not_uploaded': {
      'en': 'Not uploaded: {lists}',
      'zh': '未上传：{lists}',
    },
    'qwen3_example_audio_release_server_status_partial': {
      'en': 'Partially uploaded: {lists}',
      'zh': '部分上传：{lists}',
    },
    'qwen3_example_audio_release_server_status_unavailable': {
      'en': 'Could not verify: {lists}',
      'zh': '无法确认：{lists}',
    },
    'qwen3_example_audio_release_server_status_not_configured': {
      'en': 'Set the remote audio server address before checking.',
      'zh': '请先设置远程音频服务器地址，再进行检查。',
    },
    'qwen3_example_audio_release_server_status_invalid_url': {
      'en': 'The remote audio server address is invalid.',
      'zh': '远程音频服务器地址无效。',
    },
    'qwen3_example_audio_release_server_status_failed': {
      'en': 'The Qwen3 example server status check could not be completed.',
      'zh': 'Qwen3 例句服务器状态检查未能完成。',
    },
    'qwen3_example_audio_release_list_server_checking': {
      'en': 'Server: checking ({checked}/{total})',
      'zh': '服务器：检查中（{checked}/{total}）',
    },
    'qwen3_example_audio_release_list_server_uploaded': {
      'en': 'Server: uploaded ({uploaded}/{total})',
      'zh': '服务器：已上传（{uploaded}/{total}）',
    },
    'qwen3_example_audio_release_list_server_not_uploaded': {
      'en': 'Server: not uploaded (0/{total})',
      'zh': '服务器：未上传（0/{total}）',
    },
    'qwen3_example_audio_release_list_server_partial': {
      'en': 'Server: partial ({uploaded}/{total})',
      'zh': '服务器：部分上传（{uploaded}/{total}）',
    },
    'qwen3_example_audio_release_list_server_unavailable': {
      'en': 'Server: unable to verify',
      'zh': '服务器：无法确认',
    },
    'qwen3_example_audio_release_list_server_not_checked': {
      'en': 'Server: not checked',
      'zh': '服务器：尚未检查',
    },
    'tencent_wewinny_example_audio_release_title': {
      'en': 'Tencent Cloud Example Audio Release (WeWinny + WeJack fallback)',
      'zh': '腾讯云例句音频发布（WeWinny + WeJack 补跑）',
    },
    'tencent_wewinny_example_audio_release_desc': {
      'en':
          'An independent production pipeline for English CET-4 scenario examples: existing WeWinny (501009, 24 kHz) files stay read-only, and missing items use WeJack (101050, 16 kHz). Both immutable WAV profiles share this Tencent example release; Qwen and Qwen3 assets are unchanged.',
      'zh':
          '用于 CET-4 英语场景例句的独立生产链路：已有 WeWinny（501009、24 kHz）文件只读保留，缺失项使用 WeJack（101050、16 kHz）补跑。两种不可变 WAV 共用腾讯云例句发布入口；不会改动任何 Qwen 或 Qwen3 资产。',
    },
    'tencent_wewinny_example_audio_release_credentials_ready': {
      'en':
          'TENCENTCLOUD_SECRET_ID and TENCENTCLOUD_SECRET_KEY are configured in the Windows environment. Their values are hidden and are never saved in app settings, reports, or cache records.',
      'zh':
          'Windows 环境变量 TENCENTCLOUD_SECRET_ID 与 TENCENTCLOUD_SECRET_KEY 已配置。其值不会显示，也不会写入应用设置、发布报告或缓存记录。',
    },
    'tencent_wewinny_example_audio_release_credentials_missing': {
      'en':
          'Tencent environment credentials are incomplete. Set both TENCENTCLOUD_SECRET_ID and TENCENTCLOUD_SECRET_KEY, then restart the desktop app. No credential value is requested or shown here.',
      'zh':
          '腾讯云环境凭据不完整。请设置 TENCENTCLOUD_SECRET_ID 和 TENCENTCLOUD_SECRET_KEY 后重新启动桌面应用；此处不会要求或显示任何凭据值。',
    },
    'tencent_wewinny_example_audio_release_credentials_required': {
      'en':
          'Missing Tencent environment credentials. Set TENCENTCLOUD_SECRET_ID and TENCENTCLOUD_SECRET_KEY, restart the app, then try again.',
      'zh':
          '缺少腾讯云环境凭据。请设置 TENCENTCLOUD_SECRET_ID 和 TENCENTCLOUD_SECRET_KEY，重新启动应用后再试。',
    },
    'tencent_wewinny_example_audio_release_list_label': {
      'en': 'CET-4 Lists to release',
      'zh': '要发布例句的 CET-4 List',
    },
    'tencent_wewinny_example_audio_release_list_option': {
      'en': 'List {index}: {name} — {count} examples',
      'zh': 'List {index}：{name} — {count} 条例句',
    },
    'tencent_wewinny_example_audio_release_no_lists': {
      'en': 'No CET-4 List is available. Import CET-4 first, then refresh.',
      'zh': '没有可发布例句的 CET-4 List。请先导入 CET-4，然后刷新。',
    },
    'tencent_wewinny_example_audio_release_select_lists': {
      'en': 'Select CET-4 Lists for Tencent examples',
      'zh': '选择要用腾讯云处理例句的 CET-4 List',
    },
    'tencent_wewinny_example_audio_release_no_selection': {
      'en': 'Select at least one CET-4 List to continue.',
      'zh': '请至少选择一个 CET-4 List 后继续。',
    },
    'tencent_wewinny_example_audio_release_selected_lists': {
      'en': '{count} Lists selected: {lists}',
      'zh': '已选择 {count} 个 List：{lists}',
    },
    'tencent_wewinny_example_audio_release_plan_summary': {
      'en':
          '{lists}: {total} unique Tencent example WAVs; reusable WeWinny/WeJack WAVs {reusable}; synthesize with WeJack {pending}.',
      'zh':
          '{lists}：共 {total} 个唯一腾讯云例句 WAV；可复用 WeWinny/WeJack 有效 WAV {reusable} 个；需用 WeJack 合成 {pending} 个。',
    },
    'tencent_wewinny_example_audio_release_confirm_title': {
      'en': 'Confirm Tencent example release (WeJack fallback)',
      'zh': '确认腾讯云例句发布（WeJack 补跑）',
    },
    'tencent_wewinny_example_audio_release_confirm_publish_desc': {
      'en':
          'Release {lists}: it will keep existing WeWinny WAVs, synthesize only missing items with WeJack, validate both rates, create one mixed local package, publish through the configured uploader, and HTTP-check the result.',
      'zh':
          '发布 {lists}：保留已有 WeWinny WAV，只用 WeJack 合成缺失项，校验两种采样率，创建混合本地包，通过已配置发布器上传并进行 HTTP 检查。',
    },
    'tencent_wewinny_example_audio_release_confirm_generate_desc': {
      'en':
          'Generate {lists}: it will keep existing WeWinny WAVs, synthesize only missing items with WeJack, validate both rates, and create one mixed local upload package without publishing.',
      'zh':
          '生成 {lists}：保留已有 WeWinny WAV，只用 WeJack 合成缺失项，校验两种采样率并创建混合本地上传包，但不会发布到服务器。',
    },
    'tencent_wewinny_example_audio_release_confirm_calls': {
      'en':
          'This authorization covers {calls} normal Tencent Cloud TextToVoice calls and no more than {attempts} total attempts. Only temporary retryable failures are retried; credential, quota, and parameter errors stop for that sentence.',
      'zh':
          '本次授权包含 {calls} 次正常腾讯云 TextToVoice 调用，最多 {attempts} 次总尝试。只有临时可重试失败才会重试；凭据、额度和参数错误会在该条例句处停止。',
    },
    'tencent_wewinny_example_audio_release_confirm_cache': {
      'en':
          'Already reusable: {reusable}/{total} valid local Tencent WeWinny/WeJack example WAVs.',
      'zh': '已可复用：{reusable}/{total} 个有效本地腾讯云 WeWinny/WeJack 例句 WAV。',
    },
    'tencent_wewinny_example_audio_release_package_ready': {
      'en':
          'A validated mixed local package with {count} Tencent WeWinny/WeJack example WAVs is ready for server verification or republishing.',
      'zh': '包含 {count} 个腾讯云 WeWinny/WeJack 例句 WAV 的混合本地已校验包已就绪，可用于服务器校验或重新发布。',
    },
    'tencent_wewinny_example_audio_release_synthesis_failed': {
      'en':
          'Synthesis failed for at least one Tencent example sentence. Nothing was packaged or published.',
      'zh': '至少有一条腾讯云例句合成失败，未进行打包或发布。',
    },
    'tencent_wewinny_example_audio_release_validation_failed': {
      'en':
          'A required Tencent WeWinny/WeJack example WAV did not pass its 24 kHz or 16 kHz PCM validation. Nothing was published.',
      'zh':
          '所需腾讯云 WeWinny/WeJack 例句 WAV 未通过对应的 24 kHz 或 16 kHz PCM 校验，未发布任何文件。',
    },
    'tencent_wewinny_example_audio_release_error_detail': {
      'en': 'Tencent example release error: {msg}',
      'zh': '腾讯云例句发布错误：{msg}',
    },
    'tencent_wewinny_example_audio_release_list_cached': {
      'en': 'Local Tencent example cache complete',
      'zh': '本地腾讯云例句缓存完整',
    },
    'tencent_wewinny_example_audio_release_list_cache_progress': {
      'en': 'Local Tencent examples: {cached}/{total}',
      'zh': '本地腾讯云例句：{cached}/{total}',
    },
    'tencent_wewinny_example_audio_release_list_cache_unknown': {
      'en': 'Local Tencent example cache status has not loaded',
      'zh': '本地腾讯云例句缓存状态尚未加载',
    },
    'tencent_wewinny_example_audio_release_all_lists_cached': {
      'en':
          'All CET-4 Tencent example Lists are fully cached. Select any List to package or publish without synthesis.',
      'zh': '所有 CET-4 腾讯云例句 List 均已完整缓存，可选择任意 List 打包或发布，不会重新合成。',
    },
    'tencent_wewinny_example_audio_release_cache_status_failed': {
      'en': 'Could not load local Tencent example cache status: {msg}',
      'zh': '无法加载本地腾讯云例句缓存状态：{msg}',
    },
    'tencent_wewinny_example_audio_release_server_status_title': {
      'en': 'Tencent example server status (WeWinny + WeJack)',
      'zh': '腾讯云例句服务器状态（WeWinny + WeJack）',
    },
    'tencent_wewinny_example_audio_release_check_server_status': {
      'en': 'Check server status',
      'zh': '检查服务器状态',
    },
    'tencent_wewinny_example_audio_release_refresh_server_status': {
      'en': 'Refresh server status',
      'zh': '刷新服务器状态',
    },
    'tencent_wewinny_example_audio_release_server_status_not_checked': {
      'en':
          'Check the server to show upload status for fully cached Tencent example Lists.',
      'zh': '检查服务器后，可显示本地完整缓存的腾讯云例句 List 上传状态。',
    },
    'tencent_wewinny_example_audio_release_server_status_no_cached': {
      'en': 'No fully cached Tencent example List is available to check.',
      'zh': '没有本地腾讯云例句缓存完整的 List 可供检查。',
    },
    'tencent_wewinny_example_audio_release_server_status_progress': {
      'en': 'Checking Tencent example WAVs: {done}/{total}',
      'zh': '正在检查腾讯云例句 WAV：{done}/{total}',
    },
    'tencent_wewinny_example_audio_release_server_status_uploaded': {
      'en': 'Uploaded: {lists}',
      'zh': '已上传：{lists}',
    },
    'tencent_wewinny_example_audio_release_server_status_not_uploaded': {
      'en': 'Not uploaded: {lists}',
      'zh': '未上传：{lists}',
    },
    'tencent_wewinny_example_audio_release_server_status_partial': {
      'en': 'Partially uploaded: {lists}',
      'zh': '部分上传：{lists}',
    },
    'tencent_wewinny_example_audio_release_server_status_unavailable': {
      'en': 'Could not verify: {lists}',
      'zh': '无法确认：{lists}',
    },
    'tencent_wewinny_example_audio_release_server_status_not_configured': {
      'en': 'Set the remote audio server address before checking.',
      'zh': '请先设置远程音频服务器地址，再进行检查。',
    },
    'tencent_wewinny_example_audio_release_server_status_invalid_url': {
      'en': 'The remote audio server address is invalid.',
      'zh': '远程音频服务器地址无效。',
    },
    'tencent_wewinny_example_audio_release_server_status_failed': {
      'en': 'The Tencent example server status check could not be completed.',
      'zh': '腾讯云例句服务器状态检查未能完成。',
    },
    'word_audio_release_list_label': {
      'en': 'CET-4 Lists to release',
      'zh': '要发布的 CET-4 List',
    },
    'word_audio_release_list_option': {
      'en': 'List {index}: {name} — {count} words',
      'zh': 'List {index}：{name} — {count} 个单词',
    },
    'word_audio_release_list_cached': {
      'en': 'Local cache complete',
      'zh': '本地缓存完整',
    },
    'word_audio_release_list_cache_progress': {
      'en': 'Local cache: {cached}/{total}',
      'zh': '本地缓存：{cached}/{total}',
    },
    'word_audio_release_list_cache_unknown': {
      'en': 'Local cache status has not loaded',
      'zh': '本地缓存状态尚未加载',
    },
    'word_audio_release_all_lists_cached': {
      'en':
          'All CET-4 Lists are fully cached. Select any List to package or publish without synthesis.',
      'zh': '所有 CET-4 List 均已完整缓存，可选择任意 List 打包或发布，不会重新合成。',
    },
    'word_audio_release_server_status_title': {
      'en': 'Server upload status',
      'zh': '服务器上传状态',
    },
    'word_audio_release_check_server_status': {
      'en': 'Check server status',
      'zh': '检查服务器状态',
    },
    'word_audio_release_refresh_server_status': {
      'en': 'Refresh server status',
      'zh': '刷新服务器状态',
    },
    'word_audio_release_server_status_not_checked': {
      'en': 'Check the server to show upload status for fully cached Lists.',
      'zh': '检查服务器后，可显示已完整缓存 List 的上传状态。',
    },
    'word_audio_release_server_status_no_cached': {
      'en': 'No fully cached List is available to check.',
      'zh': '没有本地缓存完整的 List 可供检查。',
    },
    'word_audio_release_server_status_progress': {
      'en': 'Checking server WAVs: {done}/{total}',
      'zh': '正在检查服务器 WAV：{done}/{total}',
    },
    'word_audio_release_server_status_uploaded': {
      'en': 'Uploaded: {lists}',
      'zh': '已上传：{lists}',
    },
    'word_audio_release_server_status_not_uploaded': {
      'en': 'Not uploaded: {lists}',
      'zh': '未上传：{lists}',
    },
    'word_audio_release_server_status_partial': {
      'en': 'Partially uploaded: {lists}',
      'zh': '部分上传：{lists}',
    },
    'word_audio_release_server_status_unavailable': {
      'en': 'Could not verify: {lists}',
      'zh': '无法确认：{lists}',
    },
    'word_audio_release_server_status_not_configured': {
      'en': 'Set the remote word-audio server address before checking.',
      'zh': '请先设置远程单词音频服务器地址，再进行检查。',
    },
    'word_audio_release_server_status_invalid_url': {
      'en': 'The remote word-audio server address is invalid.',
      'zh': '远程单词音频服务器地址无效。',
    },
    'word_audio_release_server_status_failed': {
      'en': 'The server status check could not be completed.',
      'zh': '服务器状态检查未能完成。',
    },
    'word_audio_release_list_server_checking': {
      'en': 'Server: checking ({checked}/{total})',
      'zh': '服务器：检查中（{checked}/{total}）',
    },
    'word_audio_release_list_server_uploaded': {
      'en': 'Server: uploaded ({uploaded}/{total})',
      'zh': '服务器：已上传（{uploaded}/{total}）',
    },
    'word_audio_release_list_server_not_uploaded': {
      'en': 'Server: not uploaded (0/{total})',
      'zh': '服务器：未上传（0/{total}）',
    },
    'word_audio_release_list_server_partial': {
      'en': 'Server: partial ({uploaded}/{total})',
      'zh': '服务器：部分上传（{uploaded}/{total}）',
    },
    'word_audio_release_list_server_unavailable': {
      'en': 'Server: unable to verify',
      'zh': '服务器：无法确认',
    },
    'word_audio_release_list_server_not_checked': {
      'en': 'Server: not checked',
      'zh': '服务器：尚未检查',
    },
    'word_audio_release_no_lists': {
      'en': 'No CET-4 List is available. Import CET-4 first, then refresh.',
      'zh': '没有可发布的 CET-4 List。请先导入 CET-4，然后刷新。',
    },
    'word_audio_release_select_lists': {
      'en': 'Select CET-4 Lists',
      'zh': '选择 CET-4 List',
    },
    'word_audio_release_no_selection': {
      'en': 'Select at least one CET-4 List to continue.',
      'zh': '请至少选择一个 CET-4 List 后继续。',
    },
    'word_audio_release_selected_lists': {
      'en': '{count} Lists selected: {lists}',
      'zh': '已选择 {count} 个 List：{lists}',
    },
    'word_audio_release_plan_summary': {
      'en':
          '{lists}: {total} unique server WAVs; valid reusable WAVs {reusable}; need synthesis {pending}.',
      'zh':
          '{lists}：共 {total} 个唯一服务器 WAV；可复用有效 WAV {reusable} 个；需合成 {pending} 个。',
    },
    'word_audio_release_call_summary': {
      'en': 'Normal TTS calls: {calls}; maximum attempts: {attempts}.',
      'zh': '正常 TTS 调用：{calls} 次；最多尝试：{attempts} 次。',
    },
    'word_audio_release_generate_publish': {
      'en': 'Generate & Publish',
      'zh': '生成并发布',
    },
    'word_audio_release_generate_only': {'en': 'Generate Only', 'zh': '仅生成'},
    'word_audio_release_confirm_title': {
      'en': 'Confirm audio release',
      'zh': '确认音频发布',
    },
    'word_audio_release_confirm_publish_desc': {
      'en':
          'Release {lists}: it will synthesize missing WAVs, validate them, create one local package, publish through the configured uploader, and HTTP-check the result.',
      'zh': '发布 {lists}：将合成缺失 WAV、校验、创建一个本地包、通过已配置的发布器上传，并进行 HTTP 检查。',
    },
    'word_audio_release_confirm_generate_desc': {
      'en':
          'Generate {lists}: it will synthesize missing WAVs, validate them, and create one local upload package without publishing.',
      'zh': '生成 {lists}：将合成缺失 WAV、校验并创建一个本地上传包，但不会发布到服务器。',
    },
    'word_audio_release_confirm_calls': {
      'en':
          'This authorization covers {calls} normal cloud calls and no more than {attempts} total attempts (up to two retries per word).',
      'zh': '本次授权包含 {calls} 次正常云端调用，最多 {attempts} 次总尝试（每词最多重试两次）。',
    },
    'word_audio_release_confirm_cache': {
      'en': 'Already reusable: {reusable}/{total} valid local WAVs.',
      'zh': '已可复用：{reusable}/{total} 个有效本地 WAV。',
    },
    'word_audio_release_confirm_publish': {
      'en': 'Confirm & Publish',
      'zh': '确认并发布',
    },
    'word_audio_release_confirm_generate': {
      'en': 'Confirm & Generate',
      'zh': '确认并生成',
    },
    'word_audio_release_package_ready': {
      'en':
          'A validated local package with {count} WAV files is ready for recovery actions.',
      'zh': '包含 {count} 个 WAV 的已校验本地包已就绪，可用于恢复操作。',
    },
    'word_audio_release_verify_server': {'en': 'Verify Server', 'zh': '校验服务器'},
    'word_audio_release_republish': {
      'en': 'Republish Package',
      'zh': '重新发布本地包',
    },
    'word_audio_release_sudo_required': {
      'en':
          'The server requested its sudo password. Open the interactive publisher, enter that password there, then return here and verify the server.',
      'zh': '服务器要求输入 sudo 密码。请打开交互式发布窗口并在那里输入密码，完成后回到这里校验服务器。',
    },
    'word_audio_release_open_interactive': {
      'en': 'Open Password Prompt',
      'zh': '打开密码窗口',
    },
    'word_audio_release_interactive_opened': {
      'en':
          'The interactive publisher is open. Enter the server sudo password there; no command needs to be typed. Then use Verify Server here.',
      'zh': '交互式发布窗口已打开。请在窗口中输入服务器 sudo 密码，无需输入命令；完成后回到这里点击“校验服务器”。',
    },
    'word_audio_release_log_title': {'en': 'Publisher log', 'zh': '发布日志'},
    'word_audio_release_stage_planning': {
      'en': 'Checking the selected List and local WAV cache…',
      'zh': '正在检查所选 List 和本地 WAV 缓存…',
    },
    'word_audio_release_stage_ready': {
      'en': 'Plan ready. Review the call cap and confirm when ready.',
      'zh': '计划已就绪。请核对调用上限后确认。',
    },
    'word_audio_release_stage_synthesizing': {
      'en': 'Generating missing WAV files…',
      'zh': '正在生成缺失的 WAV 文件…',
    },
    'word_audio_release_stage_validating': {
      'en': 'Validating every canonical WAV…',
      'zh': '正在校验每个规范 WAV…',
    },
    'word_audio_release_stage_packaging': {
      'en': 'Creating the upload folder, ZIP, and release report…',
      'zh': '正在创建上传文件夹、ZIP 和发布报告…',
    },
    'word_audio_release_stage_publishing': {
      'en': 'Uploading and publishing with conflict protection…',
      'zh': '正在上传并以冲突保护方式发布…',
    },
    'word_audio_release_stage_verifying': {
      'en': 'Checking published WAV files over HTTP…',
      'zh': '正在通过 HTTP 检查已发布 WAV 文件…',
    },
    'word_audio_release_generated': {
      'en':
          'Generation and local packaging completed. No server publish was requested.',
      'zh': '生成和本地打包已完成，未请求服务器发布。',
    },
    'word_audio_release_published': {
      'en': 'Generation, publish, and HTTP verification completed.',
      'zh': '生成、发布和 HTTP 校验已完成。',
    },
    'word_audio_release_verified': {
      'en': 'The saved package passed server HTTP verification.',
      'zh': '已保存的本地包已通过服务器 HTTP 校验。',
    },
    'word_audio_release_synthesis_failed': {
      'en':
          'Synthesis failed for at least one word. Nothing was packaged or published.',
      'zh': '至少有一个单词合成失败，未进行打包或发布。',
    },
    'word_audio_release_validation_failed': {
      'en': 'A required WAV did not pass validation. Nothing was published.',
      'zh': '所需 WAV 未通过校验，未发布任何文件。',
    },
    'word_audio_release_cancelled': {
      'en': 'The release was cancelled before server publication.',
      'zh': '已在服务器发布前取消该任务。',
    },
    'word_audio_release_failed': {
      'en': 'Audio release did not complete.',
      'zh': '音频发布未完成。',
    },
    'word_audio_release_unsupported': {
      'en': 'One-tap publishing is available only in the Windows desktop app.',
      'zh': '一键发布仅在 Windows 桌面应用中可用。',
    },
    'word_audio_release_error_detail': {
      'en': 'Audio release error: {msg}',
      'zh': '音频发布错误：{msg}',
    },
    'word_audio_repair_settings_title': {
      'en': 'Repair One Word Pronunciation',
      'zh': '修复单个单词发音',
    },
    'word_audio_repair_settings_desc': {
      'en':
          'Create and audition one validated local Qwen WAV with a chosen pronunciation context. Local acceptance never uploads; a separately confirmed server replacement is available only after review.',
      'zh': '按指定发音信息生成并试听一个已校验的本地 Qwen WAV；采用本地音频不会上传，只有审核后才能进入独立确认的服务器替换流程。',
    },
    'word_audio_repair_open': {'en': 'Open Repair Tool', 'zh': '打开修复工具'},
    'word_audio_repair_title': {
      'en': 'Word Pronunciation Repair',
      'zh': '单词发音修复',
    },
    'word_audio_repair_intro': {
      'en':
          'Choose one dictionary word, describe the intended pronunciation, review the call cap, then generate a local audition. The formal cache changes only after you accept the staged WAV.',
      'zh': '选择一个词库单词并填写目标发音信息，核对调用上限后生成本地试听版本；只有点击采用后才会修改正式本地缓存。',
    },
    'word_audio_repair_search_label': {
      'en': 'Find a dictionary word',
      'zh': '查找词库单词',
    },
    'word_audio_repair_search_hint': {
      'en': 'Search English or Chinese meaning',
      'zh': '搜索英文或中文释义',
    },
    'word_audio_repair_search_empty': {
      'en': 'No matching dictionary word was found.',
      'zh': '没有找到匹配的词库单词。',
    },
    'word_audio_repair_selected_word': {'en': 'Selected word', 'zh': '已选择单词'},
    'word_audio_repair_change_word': {
      'en': 'Choose Another Word',
      'zh': '重新选择单词',
    },
    'word_audio_repair_part_of_speech_label': {
      'en': 'Target part of speech (optional)',
      'zh': '目标词性（可选）',
    },
    'word_audio_repair_part_of_speech_hint': {
      'en': 'For example: noun',
      'zh': '例如：名词',
    },
    'word_audio_repair_target_ipa_label': {
      'en': 'Target IPA (optional guidance)',
      'zh': '目标 IPA（可选指引）',
    },
    'word_audio_repair_target_ipa_hint': {
      'en': 'For example: /ˈætrɪbjuːt/',
      'zh': '例如：/ˈætrɪbjuːt/',
    },
    'word_audio_repair_note_label': {
      'en': 'Pronunciation instruction (optional)',
      'zh': '发音说明（可选）',
    },
    'word_audio_repair_note_hint': {
      'en': 'Describe the desired pronunciation in plain language',
      'zh': '用自然语言描述希望的读法',
    },
    'word_audio_repair_ipa_guidance': {
      'en':
          'IPA is included as natural-language guidance. Qwen does not provide a documented phoneme/SSML control for this workflow.',
      'zh': 'IPA 会作为自然语言指引写入生成说明；此流程不依赖 Qwen 未文档化的 phoneme/SSML 控制。',
    },
    'word_audio_repair_local_only': {
      'en':
          'Local repair scope: the generation and “Accept New Local Audio” steps change only the local v2 cache. Server replacement is a separate later action with its own comparison and confirmation.',
      'zh': '本地修复范围：生成和“采用新本地音频”只会修改本地 v2 缓存。服务器替换是之后独立的操作，必须重新比较并单独确认。',
    },
    'word_audio_repair_review_plan': {
      'en': 'Review Repair Plan',
      'zh': '生成修复计划',
    },
    'word_audio_repair_plan_title': {'en': 'Repair plan', 'zh': '修复计划'},
    'word_audio_repair_plan_calls': {
      'en': 'Normal cloud calls: {calls}; maximum attempts: {attempts}.',
      'zh': '正常云端调用：{calls} 次；最多尝试：{attempts} 次。',
    },
    'word_audio_repair_plan_existing_valid': {
      'en': 'A valid local WAV will be backed up before replacement.',
      'zh': '当前有效本地 WAV 会在替换前备份。',
    },
    'word_audio_repair_plan_existing_invalid': {
      'en':
          'An existing local file is invalid and will be retained as a backup if you accept a replacement.',
      'zh': '当前本地文件无效；若采用新版本，仍会将其保留为备份。',
    },
    'word_audio_repair_plan_existing_missing': {
      'en':
          'No local WAV exists yet; accepting a candidate creates the local cache entry only.',
      'zh': '目前没有本地 WAV；采用试听版本只会创建本地缓存条目。',
    },
    'word_audio_repair_plan_instruction': {
      'en': 'Generation instruction',
      'zh': '生成说明',
    },
    'word_audio_repair_generate': {
      'en': 'Confirm & Generate Local Audition',
      'zh': '确认并生成本地试听版本',
    },
    'word_audio_repair_generating': {
      'en': 'Generating and validating WAV… attempt {attempt}/{max}',
      'zh': '正在生成并校验 WAV…第 {attempt}/{max} 次尝试',
    },
    'word_audio_repair_cancel_generation': {
      'en': 'Cancel Remaining Attempts',
      'zh': '取消后续尝试',
    },
    'word_audio_repair_staged_title': {
      'en': 'Validated local audition is ready',
      'zh': '已校验的本地试听版本已就绪',
    },
    'word_audio_repair_staged_desc': {
      'en':
          'Generated with {calls} API call(s), {bytes} bytes. It is still isolated from the formal local cache.',
      'zh': '已使用 {calls} 次 API 调用生成，文件大小 {bytes} 字节；当前仍与正式本地缓存隔离。',
    },
    'word_audio_repair_preview_current': {
      'en': 'Preview Current Local WAV',
      'zh': '试听当前本地 WAV',
    },
    'word_audio_repair_preview_staged': {
      'en': 'Preview New Audition',
      'zh': '试听新版本',
    },
    'word_audio_repair_preview_failed': {
      'en': 'Audio preview could not be started.',
      'zh': '无法开始音频试听。',
    },
    'word_audio_repair_current_missing': {
      'en': 'No valid current local WAV is available to preview.',
      'zh': '当前没有可试听的有效本地 WAV。',
    },
    'word_audio_repair_apply': {
      'en': 'Accept New Local Audio',
      'zh': '采用新本地音频',
    },
    'word_audio_repair_applying': {
      'en': 'Backing up and applying the local WAV…',
      'zh': '正在备份并采用本地 WAV…',
    },
    'word_audio_repair_discard_staged': {
      'en': 'Discard New Audition',
      'zh': '丢弃新试听版本',
    },
    'word_audio_repair_applied_title': {
      'en': 'New local audio accepted',
      'zh': '已采用新本地音频',
    },
    'word_audio_repair_applied_with_backup': {
      'en':
          'The previous WAV was backed up and the cache record was updated. No server audio was changed.',
      'zh': '旧 WAV 已备份，缓存记录已更新；未修改任何服务器音频。',
    },
    'word_audio_repair_applied_without_backup': {
      'en':
          'The local cache entry was created and its cache record was updated. No server audio was changed.',
      'zh': '已创建本地缓存条目并更新缓存记录；未修改任何服务器音频。',
    },
    'word_audio_repair_restore': {
      'en': 'Restore Previous Local Audio',
      'zh': '恢复旧本地音频',
    },
    'word_audio_repair_restoring': {
      'en': 'Restoring the retained local backup…',
      'zh': '正在恢复已保留的本地备份…',
    },
    'word_audio_repair_restored_title': {
      'en': 'Previous local audio restored',
      'zh': '已恢复旧本地音频',
    },
    'word_audio_repair_restored_desc': {
      'en':
          'The earlier WAV is active again. The replacement is retained separately for recovery; no server audio was changed.',
      'zh': '先前 WAV 已重新生效；替换版本会单独保留以便恢复；未修改任何服务器音频。',
    },
    'word_audio_repair_start_new': {
      'en': 'Start Another Repair',
      'zh': '开始另一项修复',
    },
    'word_audio_repair_error_invalid_word': {
      'en': 'Choose a single supported English dictionary word.',
      'zh': '请选择一个受支持的英文词库单词。',
    },
    'word_audio_repair_error_missing_api_key': {
      'en': 'Save a Qwen API key in TTS settings before generating audio.',
      'zh': '请先在 TTS 设置中保存 Qwen API 密钥，再生成音频。',
    },
    'word_audio_repair_error_missing_workspace': {
      'en': 'Save a Qwen Workspace ID in TTS settings before generating audio.',
      'zh': '请先在 TTS 设置中保存 Qwen Workspace ID，再生成音频。',
    },
    'word_audio_repair_error_synthesis_failed': {
      'en':
          'The new audio could not be generated. The existing local cache was not changed.',
      'zh': '无法生成新音频，现有本地缓存未被修改。',
    },
    'word_audio_repair_error_invalid_staged_audio': {
      'en': 'The generated audio did not pass the required WAV validation.',
      'zh': '生成的音频未通过所需 WAV 校验。',
    },
    'word_audio_repair_error_staged_missing': {
      'en':
          'The staged audio is no longer available. Generate a new audition first.',
      'zh': '试听版本已不可用，请先重新生成。',
    },
    'word_audio_repair_error_apply_failed': {
      'en':
          'The local cache was not safely updated. The backup was retained for recovery.',
      'zh': '未能安全更新本地缓存；备份已保留以便恢复。',
    },
    'word_audio_repair_error_restore_unavailable': {
      'en': 'No valid previous local backup is available to restore.',
      'zh': '没有可恢复的有效旧本地备份。',
    },
    'word_audio_repair_error_restore_failed': {
      'en': 'The previous local audio could not be restored safely.',
      'zh': '无法安全恢复旧本地音频。',
    },
    'word_audio_repair_error_cancelled': {
      'en':
          'The remaining generation attempts were cancelled. The formal cache was not changed.',
      'zh': '已取消后续生成尝试，正式缓存未被修改。',
    },
    'word_audio_repair_error_unknown': {
      'en':
          'The word-audio repair did not complete. The server was not changed.',
      'zh': '单词音频修复未完成，服务器未被修改。',
    },
    'word_audio_server_replace_title': {
      'en': 'Publish Reviewed Word Audio to Server',
      'zh': '发布已审核的单词音频到服务器',
    },
    'word_audio_server_replace_intro': {
      'en':
          'This is a separate, one-word server action. It keeps the fixed audio URL, first compares the current server WAV with the reviewed local candidate, then—only after confirmation—backs up and atomically replaces that one file. It makes no TTS API call.',
      'zh':
          '这是独立的单词级服务器操作：保持固定音频 URL 不变，先比较当前服务器 WAV 与已审核的本地候选音频，只有确认后才备份并原子替换这一个文件；不会调用 TTS API。',
    },
    'word_audio_server_replace_local_review_needed': {
      'en': 'Preview the active local WAV before comparing or publishing it.',
      'zh': '请先试听当前生效的本地 WAV，再进行比较或发布。',
    },
    'word_audio_server_replace_local_reviewed': {
      'en': 'The active local candidate has been previewed in this session.',
      'zh': '当前生效的本地候选音频已在本次会话中试听。',
    },
    'word_audio_server_replace_preview_local': {
      'en': 'Preview Active Local WAV',
      'zh': '试听当前本地 WAV',
    },
    'word_audio_server_replace_no_local_candidate': {
      'en':
          'There is no valid active local WAV to publish. Accept a validated local audition first, or select a word that already has a valid local cache entry.',
      'zh': '当前没有可发布的有效本地 WAV。请先采用已校验的本地试听版本，或选择已有有效本地缓存的单词。',
    },
    'word_audio_server_replace_compare': {
      'en': 'Compare Local Candidate with Server',
      'zh': '比较本地候选与服务器',
    },
    'word_audio_server_replace_plan_title': {
      'en': 'Server replacement plan',
      'zh': '服务器替换计划',
    },
    'word_audio_server_replace_plan_desc': {
      'en':
          '“{word}” uses one fixed key. Server current: {old_bytes} bytes, SHA-256 {old_hash}. Reviewed local candidate: {new_bytes} bytes, SHA-256 {new_hash}.',
      'zh':
          '“{word}” 使用一个固定键。服务器当前版本：{old_bytes} 字节，SHA-256 {old_hash}；已审核本地候选：{new_bytes} 字节，SHA-256 {new_hash}。',
    },
    'word_audio_server_replace_fixed_url': {
      'en': 'Fixed server URL (unchanged after replacement)',
      'zh': '固定服务器 URL（替换后保持不变）',
    },
    'word_audio_server_replace_preview_server': {
      'en': 'Preview Current Server WAV',
      'zh': '试听当前服务器 WAV',
    },
    'word_audio_server_replace_preview_published': {
      'en': 'Preview Newly Published Audio',
      'zh': '试听刚发布的新音频',
    },
    'word_audio_server_replace_refresh_compare': {
      'en': 'Refresh Server Comparison',
      'zh': '重新比较服务器版本',
    },
    'word_audio_server_replace_discard_plan': {
      'en': 'Discard This Server Plan',
      'zh': '放弃本次服务器计划',
    },
    'word_audio_server_replace_action': {
      'en': 'Replace Server WAV',
      'zh': '替换服务器 WAV',
    },
    'word_audio_server_replace_confirm_title': {
      'en': 'Replace one server WAV?',
      'zh': '替换一个服务器 WAV？',
    },
    'word_audio_server_replace_confirm_desc': {
      'en':
          'You are about to replace the fixed server audio for “{word}”.\n\nURL: {url}\nCurrent SHA-256: {old_hash}\nNew SHA-256: {new_hash}\n\nThe server will retain the current WAV as a protected backup, atomically publish the reviewed local WAV, and verify the public GET body by SHA-256. No TTS will be generated. Continue?',
      'zh':
          '即将替换“{word}”对应的固定服务器音频。\n\nURL：{url}\n当前 SHA-256：{old_hash}\n新版本 SHA-256：{new_hash}\n\n服务器会将当前 WAV 保留为受保护备份，原子发布已审核的本地 WAV，并通过 SHA-256 校验公开 GET 响应内容。不会生成 TTS。是否继续？',
    },
    'word_audio_server_replace_confirm_action': {
      'en': 'Confirm Server Replacement',
      'zh': '确认替换服务器音频',
    },
    'word_audio_server_replace_already_current': {
      'en':
          'The reviewed local WAV already matches the current server body exactly. Nothing was uploaded or changed.',
      'zh': '已审核的本地 WAV 与当前服务器内容完全一致；未上传也未修改任何内容。',
    },
    'word_audio_server_replace_succeeded': {
      'en':
          'The server WAV was backed up as “{backup}”, atomically replaced at the same fixed URL, and verified by HTTP GET SHA-256.',
      'zh': '服务器 WAV 已备份为“{backup}”，已在同一固定 URL 原子替换，并通过 HTTP GET SHA-256 校验。',
    },
    'word_audio_server_replace_stage_comparing': {
      'en': 'Reading and validating the current server WAV…',
      'zh': '正在读取并校验当前服务器 WAV…',
    },
    'word_audio_server_replace_stage_replacing': {
      'en': 'Backing up, atomically replacing, and verifying the server WAV…',
      'zh': '正在备份、原子替换并校验服务器 WAV…',
    },
    'word_audio_server_replace_stage_checking_rollback': {
      'en': 'Checking the retained server backup and live server hash…',
      'zh': '正在检查保留的服务器备份和线上当前哈希…',
    },
    'word_audio_server_replace_stage_rolling_back': {
      'en':
          'Backing up the current server WAV and restoring the retained version…',
      'zh': '正在备份当前服务器 WAV 并恢复保留版本…',
    },
    'word_audio_server_replace_stage_checking_result': {
      'en': 'Checking the server result after the interactive sudo command…',
      'zh': '正在检查交互式 sudo 命令后的服务器结果…',
    },
    'word_audio_server_replace_stage_working': {
      'en': 'Working on the guarded server audio operation…',
      'zh': '正在执行受保护的服务器音频操作…',
    },
    'word_audio_server_replace_sudo_required': {
      'en':
          'The server cannot authorize sudo in the app’s non-interactive process. The app did not send or save any password. Open the visible PowerShell command only if you want to continue the action you already confirmed.',
      'zh':
          '服务器无法在应用的非交互式进程中完成 sudo 授权。应用不会发送或保存任何密码。只有希望继续刚才已确认的操作时，才打开可见的 PowerShell 命令。',
    },
    'word_audio_server_replace_diagnostics_title': {
      'en': 'Recent Server Diagnostics',
      'zh': '最近的服务器诊断日志',
    },
    'word_audio_server_replace_diagnostics_desc': {
      'en':
          'This output is limited and redacted before it is displayed or saved to the local audit.',
      'zh': '此输出在显示和写入本地审计前已进行长度限制和敏感信息脱敏。',
    },
    'word_audio_server_replace_diagnostics_copy': {
      'en': 'Copy Diagnostics',
      'zh': '复制诊断日志',
    },
    'word_audio_server_replace_diagnostics_copied': {
      'en': 'Diagnostics copied.',
      'zh': '诊断日志已复制。',
    },
    'word_audio_server_replace_open_interactive': {
      'en': 'Open Interactive Server Command',
      'zh': '打开交互式服务器命令',
    },
    'word_audio_server_replace_interactive_opened': {
      'en':
          'The interactive command window is open. Complete or cancel it there, then use the check below; checking only reads the public server WAV.',
      'zh': '交互式命令窗口已打开。请在其中完成或取消操作，然后点击下方检查；检查只会读取公开服务器 WAV。',
    },
    'word_audio_server_replace_check_interactive': {
      'en': 'Check Server Result',
      'zh': '检查服务器结果',
    },
    'word_audio_server_replace_interactive_not_completed': {
      'en':
          'The server still has the reviewed pre-operation WAV. The interactive action was not completed; nothing new was recorded locally.',
      'zh': '服务器仍保留比较时的旧 WAV。交互式操作未完成，未在本地记录新的发布结果。',
    },
    'word_audio_server_rollback_prepare': {
      'en': 'Find Eligible Server Backup for Rollback',
      'zh': '查找可回滚的服务器备份',
    },
    'word_audio_server_rollback_plan_title': {
      'en': 'Server rollback plan',
      'zh': '服务器回滚计划',
    },
    'word_audio_server_rollback_plan_desc': {
      'en':
          'Backup “{backup}” will restore SHA-256 {restore_hash} over the currently active SHA-256 {active_hash}. The current server WAV will first be retained as a new backup.',
      'zh':
          '将使用备份“{backup}”恢复 SHA-256 {restore_hash}，替换当前的 SHA-256 {active_hash}。当前服务器 WAV 会先被保留为新的备份。',
    },
    'word_audio_server_rollback_action': {
      'en': 'Restore This Server Backup',
      'zh': '恢复此服务器备份',
    },
    'word_audio_server_rollback_confirm_title': {
      'en': 'Restore previous server WAV?',
      'zh': '恢复之前的服务器 WAV？',
    },
    'word_audio_server_rollback_confirm_desc': {
      'en':
          'You are about to restore the retained server backup for “{word}”.\n\nURL: {url}\nCurrent SHA-256: {active_hash}\nRestore SHA-256: {restore_hash}\n\nThe current server WAV will be backed up first, then the retained WAV will be atomically restored at the same fixed URL and verified by HTTP GET SHA-256. Continue?',
      'zh':
          '即将恢复“{word}”保留的服务器备份。\n\nURL：{url}\n当前 SHA-256：{active_hash}\n恢复目标 SHA-256：{restore_hash}\n\n当前服务器 WAV 会先备份，再在同一固定 URL 原子恢复保留 WAV，并通过 HTTP GET SHA-256 校验。是否继续？',
    },
    'word_audio_server_rollback_confirm_action': {
      'en': 'Confirm Server Rollback',
      'zh': '确认服务器回滚',
    },
    'word_audio_server_rollback_succeeded': {
      'en':
          'The prior server WAV was restored at the fixed URL. The displaced current version was retained as backup “{backup}” and verified by HTTP GET SHA-256.',
      'zh':
          '已在固定 URL 恢复先前服务器 WAV。被替换的当前版本已保留为备份“{backup}”，并通过 HTTP GET SHA-256 校验。',
    },
    'word_audio_server_replace_error_unsupported': {
      'en':
          'This guarded server workflow is available only in the Windows desktop app.',
      'zh': '此受保护的服务器流程仅在 Windows 桌面应用中可用。',
    },
    'word_audio_server_replace_error_local_missing': {
      'en':
          'The reviewed local WAV is no longer available. No server action was started.',
      'zh': '已审核的本地 WAV 已不可用，未启动任何服务器操作。',
    },
    'word_audio_server_replace_error_local_invalid': {
      'en':
          'The local WAV is missing or no longer passes the required validation. No server action was started.',
      'zh': '本地 WAV 缺失或不再通过所需校验，未启动任何服务器操作。',
    },
    'word_audio_server_replace_error_server_not_configured': {
      'en':
          'Save a word-audio server address in Settings before comparing or publishing.',
      'zh': '请先在设置中保存单词音频服务器地址，再进行比较或发布。',
    },
    'word_audio_server_replace_error_server_address_invalid': {
      'en': 'The saved word-audio server address is not a valid HTTP(S) URL.',
      'zh': '已保存的单词音频服务器地址不是有效的 HTTP(S) URL。',
    },
    'word_audio_server_replace_error_remote_missing': {
      'en':
          'The fixed server WAV does not exist. This replacement workflow will not create a new file; use the protected batch/new-file publisher instead.',
      'zh': '固定服务器 WAV 不存在。此替换流程不会创建新文件；请使用受保护的批量/新文件发布流程。',
    },
    'word_audio_server_replace_error_remote_invalid': {
      'en':
          'The current server response is not a valid production word WAV. Nothing was replaced.',
      'zh': '当前服务器响应不是有效的生产单词 WAV，未替换任何内容。',
    },
    'word_audio_server_replace_error_remote_unavailable': {
      'en':
          'The current server WAV could not be read or verified. Nothing was replaced.',
      'zh': '无法读取或校验当前服务器 WAV，未替换任何内容。',
    },
    'word_audio_server_replace_error_remote_changed': {
      'en':
          'The server WAV changed after the comparison or does not match the selected backup chain. Refresh the comparison before taking any further action.',
      'zh': '服务器 WAV 在比较后发生变化，或不匹配所选备份链。请先重新比较，再进行后续操作。',
    },
    'word_audio_server_replace_error_server_address_changed': {
      'en':
          'The current server address differs from the one recorded with this backup. Restore the original address before rolling it back.',
      'zh': '当前服务器地址与该备份记录的地址不同。请恢复原服务器地址后再执行回滚。',
    },
    'word_audio_server_replace_error_rollback_unavailable': {
      'en':
          'No eligible local replacement audit and un-restored server backup were found for this word.',
      'zh': '未找到此单词可用的本地替换审计记录和未恢复的服务器备份。',
    },
    'word_audio_server_replace_error_publish_failed': {
      'en':
          'The guarded server command did not complete before reporting a replacement. The server should remain unchanged; review the diagnostics below and refresh the comparison before retrying.',
      'zh': '受保护的服务器命令未在报告替换前完成。服务器应保持不变；请查看下方诊断日志，并在重试前重新比较。',
    },
    'word_audio_server_replace_error_publish_may_have_changed': {
      'en':
          'The server command stopped after reporting a possible file change, but final verification was not conclusive. Do not retry blindly—refresh the server comparison and inspect the retained audit first.',
      'zh': '服务器命令在报告可能已修改文件后中断，最终校验未能确认。请不要直接重试；先重新比较服务器版本并检查保留的审计记录。',
    },
    'word_audio_server_replace_error_unknown': {
      'en':
          'The guarded server audio operation did not complete. Refresh the comparison before taking another action.',
      'zh': '受保护的服务器音频操作未完成。再次操作前请重新比较。',
    },
    'tts_precache_cet4_n': {
      'en': 'Generate first {count} CET-4 Lists',
      'zh': '生成 CET-4 前 {count} 个 List 音频',
    },
    'tts_precache_list_count_label': {
      'en': 'Lists to generate',
      'zh': '要生成的 List 数量',
    },
    'tts_precache_list_count_hint': {
      'en': 'Enter how many CET-4 Lists to generate',
      'zh': '输入要生成的 CET-4 List 数量',
    },
    'tts_precache_invalid_list_count': {
      'en': 'Please enter a list count of 1 or more.',
      'zh': '请输入大于等于 1 的 List 数量。',
    },
    'tts_precache_hint': {
      'en':
          'Uses Qwen Audio TTS to generate WAV staging files for the first {count} CET-4 Lists. Invalid or silent WAVs are discarded and retried. Upload them to the server; word playback never uses this folder.',
      'zh':
          '使用 Qwen Audio TTS 生成 CET-4 前 {count} 个 List 的 WAV 暂存文件。无效或静音 WAV 会被丢弃并重试。请上传到服务器；单词播放不会使用此文件夹。',
    },
    'tts_precache_cancel': {'en': 'Cancel', 'zh': '取消'},
    'tts_precache_running': {
      'en': 'Generating WAV files... {done}/{total}',
      'zh': '正在生成 WAV 文件... {done}/{total}',
    },
    'tts_precache_current': {
      'en': 'Current: {list} — {word}',
      'zh': '当前：{list} — {word}',
    },
    'tts_precache_counts': {
      'en': 'Generated {success}, skipped {skipped}, failed {failed}',
      'zh': '已生成 {success}，跳过 {skipped}，失败 {failed}',
    },
    'tts_precache_usage': {
      'en':
          'This run: {calls} API calls, {chars} billable chars, {bytes} audio',
      'zh': '本次：{calls} 次 API 调用，{chars} 计费字符，{bytes} 音频',
    },
    'tts_precache_done': {
      'en':
          'WAV generation complete: success {success}, skipped {skipped}, failed {failed}',
      'zh': 'WAV 生成完成：成功 {success}，跳过 {skipped}，失败 {failed}',
    },
    'tts_precache_cancelled': {
      'en':
          'WAV generation cancelled: success {success}, skipped {skipped}, failed {failed}',
      'zh': '已取消 WAV 生成：成功 {success}，跳过 {skipped}，失败 {failed}',
    },
    'tts_precache_failed': {
      'en': 'WAV generation failed: {msg}',
      'zh': 'WAV 生成失败：{msg}',
    },
    'tts_precache_no_cet4': {
      'en': 'CET-4 word book not found. Import CET-4 first.',
      'zh': '未找到 CET-4 词书，请先导入 CET-4。',
    },
    'tts_precache_need_api_key': {
      'en': 'Please enter your Qwen TTS API key first.',
      'zh': '请先填写 Qwen TTS API 密钥。',
    },
    'tts_precache_need_workspace_id': {
      'en': 'Please enter the Beijing-region Workspace ID first.',
      'zh': '请先填写北京地域的 Workspace ID。',
    },
    'tts_precache_first_failure': {
      'en': 'First failure: {error}',
      'zh': '首个失败：{error}',
    },
    'tts_precache_audio_invalid_wav': {
      'en': 'The generated WAV was invalid after retries.',
      'zh': '生成的 WAV 无效，重试后仍未成功。',
    },
    'tts_precache_audio_unexpected_format': {
      'en': 'The generated WAV format did not match the staging profile.',
      'zh': '生成的 WAV 格式不符合暂存参数。',
    },
    'tts_precache_audio_too_short': {
      'en':
          'The generated WAV was too short to contain a usable pronunciation.',
      'zh': '生成的 WAV 过短，无法包含可用读音。',
    },
    'tts_precache_audio_silent': {
      'en': 'The generated WAV contained no audible speech after retries.',
      'zh': '生成的 WAV 没有可听语音，重试后仍未成功。',
    },
    'tts_doubao_live_api_enabled': {
      'en': 'Allow live Doubao API for normal playback',
      'zh': '允许普通播放实时调用豆包 API',
    },
    'tts_doubao_live_api_enabled_desc': {
      'en':
          'Turn off to play cached Doubao audio only. Missing cache will not call the API.',
      'zh': '关闭后只播放豆包本地缓存；没有缓存时不会调用 API。',
    },
    'tts_usage_title': {'en': 'Qwen API Usage', 'zh': 'Qwen API 消耗'},
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
    'tts_cache_status_title': {
      'en': 'CET-4 Server Audio Build Status',
      'zh': 'CET-4 服务器音频生成状态',
    },
    'tts_cache_status_empty': {
      'en': 'No server-audio build status loaded yet. Tap Refresh.',
      'zh': '尚未加载服务器音频生成状态，请点击刷新。',
    },
    'tts_cache_status_summary': {
      'en':
          'Lists done {doneLists}/{totalLists}, WAV files staged {cachedWords}/{totalWords}, failed words {failed}',
      'zh':
          'List 完成 {doneLists}/{totalLists}，WAV 暂存 {cachedWords}/{totalWords}，失败单词 {failed}',
    },
    'tts_cache_incomplete': {
      'en': 'Generate incomplete Lists only',
      'zh': '只生成未完成的 List',
    },
    'tts_cache_all_done': {
      'en': 'All CET-4 WAV files are staged for upload.',
      'zh': '所有 CET-4 WAV 文件均已暂存，可上传。',
    },
    'tts_cache_list_status': {
      'en': 'List {index}: {name} — {cached}/{total}',
      'zh': 'List {index}：{name} — {cached}/{total}',
    },
    'tts_cache_failed_words': {'en': 'Failed: {words}', 'zh': '失败：{words}'},
    'tts_cache_this_list': {'en': 'Generate this List', 'zh': '生成此 List'},
    'refresh': {'en': 'Refresh', 'zh': '刷新'},
    'tts_cache_limit_title': {'en': 'WAV Staging Storage', 'zh': 'WAV 暂存存储'},
    'tts_cache_limit_desc': {
      'en':
          'Set 0 to keep all generated WAV files until upload. This only affects desktop staging; word playback never uses local audio files.',
      'zh': '设为 0 可保留所有已生成 WAV，直到上传完成。它只影响桌面暂存；单词播放不会使用本地音频文件。',
    },
    'tts_cache_limit_label': {'en': 'Staging limit (MB)', 'zh': '暂存上限（MB）'},
    'tts_cache_limit_hint': {'en': '0', 'zh': '0'},
    'tts_cache_limit_apply': {'en': 'Apply Staging Limit', 'zh': '应用暂存上限'},
    'tts_cache_limit_summary': {
      'en': 'Staged {used}; limit {limit}.',
      'zh': '已暂存 {used}；上限 {limit}。',
    },
    'tts_cache_limit_done': {
      'en':
          'Staging limit applied: removed {files} files ({bytes}); staged now {used}.',
      'zh': '已应用暂存上限：移除 {files} 个文件（{bytes}）；当前暂存 {used}。',
    },
    'tts_cache_limit_unlimited': {'en': 'Unlimited', 'zh': '不限'},
    'tts_cache_limit_invalid': {
      'en': 'Enter a whole number of 0 or more.',
      'zh': '请输入大于等于 0 的整数。',
    },
    'tts_cache_health_title': {'en': 'WAV Staging Health', 'zh': 'WAV 暂存健康'},
    'tts_cache_health_empty': {
      'en': 'No WAV staging health report yet. Tap Check Health.',
      'zh': '尚未检查 WAV 暂存健康，请点击检查。',
    },
    'tts_cache_health_summary': {
      'en':
          'Records {records}, healthy {healthy}, missing {missing}, empty {empty}, orphan files {orphan}, expired records {expiredRecords}',
      'zh':
          '记录 {records}，健康 {healthy}，缺失 {missing}，空文件 {empty}，孤立文件 {orphan}，过期记录 {expiredRecords}',
    },
    'tts_cache_health_ok': {
      'en': 'WAV staging looks healthy.',
      'zh': 'WAV 暂存状态正常。',
    },
    'tts_cache_health_issue': {
      'en': 'WAV staging needs cleanup.',
      'zh': 'WAV 暂存需要清理。',
    },
    'tts_cache_health_check': {'en': 'Check Health', 'zh': '检查健康'},
    'tts_cache_cleanup': {'en': 'Clean Expired', 'zh': '清理过期'},
    'tts_cache_cleanup_desc': {
      'en':
          'Removes broken staging files and stale records older than {days} days.',
      'zh': '清理损坏的暂存文件和超过 {days} 天的过期记录。',
    },
    'tts_cache_cleanup_done': {
      'en':
          'Staging cleanup complete: removed {files} files, {records} records.',
      'zh': '暂存清理完成：删除 {files} 个文件，{records} 条记录。',
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
    'tts_qwen_not_configured': {
      'en': 'Configure the Qwen API key and Workspace ID in Settings first.',
      'zh': '请先在设置中填写 Qwen API 密钥和 Workspace ID。',
    },
    'tts_qwen_api_failed_detail': {
      'en': 'Qwen pronunciation failed: {msg}',
      'zh': 'Qwen 单词发音失败：{msg}',
    },
    'tts_qwen_not_ready': {
      'en': 'Speech playback is not ready. Please try again.',
      'zh': '语音播放尚未就绪，请稍后重试。',
    },
    'tts_qwen_busy': {
      'en': 'Another pronunciation request is still running.',
      'zh': '另一个单词发音请求仍在处理中。',
    },
    'word_audio_direct_not_configured': {
      'en': 'Configure the currently selected TTS engine in Settings first.',
      'zh': '请先在设置中配置当前选中的 TTS 引擎。',
    },
    'word_audio_direct_failed': {
      'en': 'The currently selected TTS engine could not play this word.',
      'zh': '当前选中的 TTS 引擎无法播放该单词。',
    },
    'word_audio_server_not_configured': {
      'en': 'Set the word-audio server address in Settings first.',
      'zh': '请先在设置中填写单词音频服务器地址。',
    },
    'word_audio_server_invalid_url': {
      'en': 'The word-audio server address is invalid.',
      'zh': '单词音频服务器地址无效。',
    },
    'word_audio_file_not_found': {
      'en': 'This word has not been uploaded to the audio server yet.',
      'zh': '该单词音频尚未上传到服务器。',
    },
    'word_audio_timeout': {
      'en':
          'The word-audio server timed out. Check your network and try again.',
      'zh': '单词音频服务器请求超时，请检查网络后重试。',
    },
    'word_audio_invalid_file': {
      'en': 'The server returned an invalid WAV file.',
      'zh': '服务器返回的 WAV 文件无效。',
    },
    'word_audio_unavailable': {
      'en':
          'The word-audio server is temporarily unavailable. Please try again.',
      'zh': '单词音频服务器暂时不可用，请稍后重试。',
    },
    'word_audio_busy': {
      'en': 'Another pronunciation request is still running.',
      'zh': '另一个单词发音请求仍在处理中。',
    },
    'word_audio_not_ready': {
      'en': 'Speech playback is not ready. Please try again.',
      'zh': '语音播放尚未就绪，请稍后重试。',
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
    'book_kaoyan': {'en': 'Postgraduate Entrance Exam', 'zh': '考研'},

    // ─── AI Dialogue ───
    'ai_dialogue_title': {'en': 'AI Dialogue', 'zh': 'AI 对话'},
    'dialogue_scenario': {'en': 'Scenario', 'zh': '场景'},
    'dialogue_scenario_daily': {'en': 'Daily conversation', 'zh': '日常交流'},
    'dialogue_scenario_shopping': {'en': 'Shopping', 'zh': '购物'},
    'dialogue_scenario_restaurant': {'en': 'Ordering food', 'zh': '餐厅点餐'},
    'dialogue_scenario_travel': {'en': 'Travel', 'zh': '旅行机场'},
    'dialogue_scenario_interview': {'en': 'Job interview', 'zh': '工作面试'},
    'dialogue_scenario_doctor': {'en': 'Doctor visit', 'zh': '就医看诊'},
    'dialogue_scenario_phone': {'en': 'Phone call', 'zh': '电话沟通'},
    'dialogue_scenario_directions': {'en': 'Asking directions', 'zh': '问路'},
    'dialogue_scenario_hotel': {'en': 'At a hotel', 'zh': '酒店入住'},
    'dialogue_scenario_meeting': {'en': 'Business meeting', 'zh': '商务会议'},
    'select_words_for_dialogue': {
      'en': 'Select words ({count} selected)',
      'zh': '选择单词（已选 {count} 个）',
    },
    'select_all': {'en': 'Select All', 'zh': '全选'},
    'deselect_all': {'en': 'Deselect All', 'zh': '取消全选'},
    'dialogue_select_recommended': {'en': 'Recommended', 'zh': '推荐选择'},
    'generate_dialogue': {'en': 'Generate Dialogue', 'zh': '生成对话'},
    'generating_dialogue': {'en': 'Generating dialogue...', 'zh': '正在生成对话...'},
    'dialogue_start_practice': {'en': 'Start Role-play', 'zh': '开始角色练习'},
    'dialogue_starting_practice': {
      'en': 'Starting role-play...',
      'zh': '正在开始角色练习...',
    },
    'dialogue_reply_hint': {'en': 'Reply in English', 'zh': '用英语回复'},
    'dialogue_send': {'en': 'Send', 'zh': '发送'},
    'lines_count': {'en': 'lines', 'zh': '行'},
    'regenerate': {'en': 'Regenerate', 'zh': '重新生成'},
    'toggle_translation': {'en': 'Toggle Translation', 'zh': '切换翻译'},
    'dialogue_turn_count': {
      'en': 'Turn {current}/{total}',
      'zh': '轮次 {current}/{total}',
    },
    'dialogue_words_used_count': {
      'en': 'Words {used}/{total}',
      'zh': '用词 {used}/{total}',
    },
    'dialogue_try_words': {'en': 'Try next: {words}', 'zh': '下一轮尝试：{words}'},
    'dialogue_feedback': {'en': 'Feedback', 'zh': '反馈'},
    'language_tool_title': {'en': 'LanguageTool', 'zh': 'LanguageTool'},
    'language_tool_no_issues': {
      'en': 'No grammar or spelling issue found by LanguageTool.',
      'zh': 'LanguageTool 未发现语法或拼写问题。',
    },
    'language_tool_unavailable': {
      'en': 'LanguageTool is unavailable: {error}',
      'zh': 'LanguageTool 当前不可用：{error}',
    },
    'language_tool_issue': {
      'en': '{issue}: {message}',
      'zh': '{issue}：{message}',
    },
    'language_tool_suggestions': {
      'en': 'Suggestions: {suggestions}',
      'zh': '建议：{suggestions}',
    },
    'dialogue_naturalness': {'en': 'Naturalness', 'zh': '自然度'},
    'dialogue_context_fit': {'en': 'Context', 'zh': '场景匹配'},
    'dialogue_no_words_used': {
      'en': 'No target word used in this reply.',
      'zh': '这次回复还没有使用目标词。',
    },
    'dialogue_used_words': {'en': 'Used: {words}', 'zh': '已使用：{words}'},
    'dialogue_correction': {'en': 'Correction: {text}', 'zh': '纠正：{text}'},
    'dialogue_better_version': {'en': 'Better: {text}', 'zh': '更自然：{text}'},
    'dialogue_complete_title': {'en': 'Role-play Complete', 'zh': '角色练习完成'},
    'dialogue_summary': {
      'en': '{turns} turns completed. Target words used: {used}/{total}.',
      'zh': '已完成 {turns} 轮。目标词使用：{used}/{total}。',
    },
    'dialogue_practice_again': {'en': 'Practice Again', 'zh': '再练一次'},
    'dialogue_change_setup': {'en': 'Change Setup', 'zh': '调整设置'},
    'dialogue_error_min_words': {
      'en': 'Select 3 to 5 words for role-play practice.',
      'zh': '请选择 3 到 5 个单词进行角色练习。',
    },
    'dialogue_error_max_words': {
      'en': 'Use up to 5 words so the conversation stays natural.',
      'zh': '最多选择 5 个单词，避免对话变得生硬。',
    },
    'dialogue_error_empty_reply': {
      'en': 'Enter an English reply first.',
      'zh': '请先输入一句英文回复。',
    },
    'dialogue_start_failed': {
      'en': 'Failed to start role-play: {error}',
      'zh': '角色练习启动失败：{error}',
    },
    'dialogue_turn_failed': {
      'en': 'Failed to continue dialogue: {error}',
      'zh': '对话继续失败：{error}',
    },
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
