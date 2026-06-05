"""
将 heroday/dict 格式的 JSON 词书转为 LingoDemo 兼容的 CSV。
用法: python convert_vocab.py <json文件路径>
输出: 同目录下生成同名 .csv 文件
"""

import json
import sys
import os

def convert(json_path):
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    words = []
    for item in data:
        try:
            content = item['content']['word']['content']
            english = item['headWord']
            # 提取中文翻译
            trans = content.get('trans', [])
            chinese = '；'.join(t.get('tranCn', '') for t in trans if t.get('tranCn'))
            if not chinese:
                continue
            # 提取美音音标
            usphone = content.get('usphone', '')
            # 提取第一个例句
            sentences = content.get('sentence', {}).get('sentences', [])
            example = ''
            if sentences:
                s = sentences[0]
                example = s.get('sContent', '')
            words.append((english, chinese, usphone, example))
        except (KeyError, TypeError):
            continue

    out_path = os.path.splitext(json_path)[0] + '.csv'
    with open(out_path, 'w', encoding='utf-8', newline='') as f:
        f.write('english,chinese_meanings,pronunciation,example_sentence\n')
        for w in words:
            eng = w[0].replace(',', ' ').replace('"', '')
            cn = w[1].replace(',', '，').replace('"', '')
            ph = w[2].replace(',', ' ')
            ex = w[3].replace(',', ' ').replace('"', '').replace('\n', ' ')
            f.write(f'{eng},{cn},{ph},{ex}\n')

    print(f'Done: {len(words)} words → {out_path}')

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python convert_vocab.py <file.json>')
        sys.exit(1)
    convert(sys.argv[1])
