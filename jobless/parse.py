# -*- coding: utf-8 -*-
import re, json, sys

pat = [
  [r"<資料時期>([^<]+)", "時間"],
  [r"<初次尋職者>([^<]+)", "初次尋職"],
  [r"<工作場所業務緊縮或歇業>([^<]+)", "裁員倒閉"],
  [r"<對原有工作不滿意>([^<]+)", "不滿"],
  [r"<健康不良>([^<]+)", "健康問題"],
  [r"<季節性或臨時性工作結束>([^<]+)", "短期工結束"],
  [r"<女性結婚或生育>([^<]+)", "結婚或生育"],
  [r"<退休>([^<]+)", "退休"],
  [r"<家務太忙>([^<]+)", "家務繁忙"],
  [r"<其他>([^<]+)", "其他"]
]

lines = [re.sub(r"[\r\n]","", x).strip() for x in open("data.2.xml","r").readlines()]
all = []
obj = {}
reason = {}

#print("{")
for line in lines:
  if line=="<失業原因>": 
    obj = {}
    all += [obj]
    #print("  {")
    continue
  if line=="</失業原因>": 
    #print("  },")
    continue
  if re.search("^<總計>|^<男>|^<女>", line): continue
  for p in pat:
    result = re.search(p[0], line)
    if not result: continue
    obj[p[1]] = result.group(1)
    reason[p[1]] = 0
    #print('    "%s": "%s",'%(p[1], result.group(1)))
#print("}")
#print(json.dumps(all,ensure_ascii=False))
reason = reason.keys()
output = [reason,[]]
for item in all:
  obj = []
  output[1] += [obj]
  for k in reason:
    obj += [item[k]]
  
print(json.dumps(output,ensure_ascii=False))
