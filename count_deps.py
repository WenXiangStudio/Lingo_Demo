import json, os, urllib.parse
with open('D:/LingoDemo/lingo_app/.dart_tool/package_config.json') as f:
    d = json.load(f)
total = 0
project_root = 'D:/LingoDemo/lingo_app'
big = []
for p in d['packages']:
    root = p['rootUri']
    if root.startswith('file:///'):
        root = urllib.parse.unquote(root[len('file:///'):])
    elif root.startswith('../'):
        root = os.path.normpath(os.path.join(project_root, root))
    pkg_uri = p.get('packageUri', 'lib/').rstrip('/')
    full = os.path.join(root, pkg_uri)
    cnt = 0
    for dp, _, fs in os.walk(full):
        cnt += sum(1 for f in fs if f.endswith('.dart'))
    total += cnt
    big.append((cnt, p['name']))
big.sort(reverse=True)
print('total dart files across deps lib/:', total)
print('top 15 heaviest packages:')
for c, n in big[:15]:
    print(f'  {c:>5}  {n}')
