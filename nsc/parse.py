# -*- coding: utf-8 -*-
import re, string, json, sys

lines = map(lambda x: x.split(","), open("nsc_projects.raw.csv","r").readlines())[1:]
insthash = {}
for line in lines:
  #c1 = string.find(line[2], "大學")
  #c2 = string.find(line[2], "學院")
  #c3 = string.find(line[2], "研究院")
  instpostfix = ["物院","署","研究院","中心","大學","學院","專科學校","醫院","基金會","委員會"]
  cs = map(lambda x:string.find(line[2],x), instpostfix)
  count = 0
  inst = ""
  for v in cs:
    if v>0:
      inst = line[2][0:v] + instpostfix[count]
      break
    count += 1
  #if (c1>0 and c2<0) or (c1>0 and c1<c2): inst = line[2][0:c1]+"大學"
  #elif c1<0 and ((c3>0 and c2<0) or (c3>0 and c3<c2)): inst = line[2][0:c3]+"研究院"
  #elif c1<0 and c2>0: inst = line[2][0:c2]+"學院"
  if inst=="": inst = line[2]
  inst = re.sub('"',"",inst.decode("utf-8"))
  dept = re.sub('"',"",line[2].decode("utf-8"))
  dept = re.sub(inst, "", dept)
  dept = re.sub(ur"[（].*?[）]","",dept)
  dept = re.sub(ur"\(.+\)","",dept)
  inst = re.sub(ur"國立|私立|財團法人","",inst)
  inst = re.sub(ur"[（].*?[）]","",inst)
  inst = re.sub(ur"\(.+\)","",inst)
  
  budget = re.sub(r'"',"",line[5])
  insthash.setdefault(inst, [0,{}])
  insthash[inst][0] += int(budget)/1000
  if dept!="":
    insthash[inst][1].setdefault(dept, 0)
    insthash[inst][1][dept] += int(budget)/1000

print(json.dumps(insthash, ensure_ascii=False).encode("utf-8"))
  
#"102","王志宏","國立交通大學生物科技學系（所）","探討腎素-血管縮收素系統機制與代謝症候群 (Metabolic Syndrome)的關聯性","2013/08/01~2016/07/31","5820000","1","B","B10"
