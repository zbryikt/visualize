require! <[fs]>

data = fs.readFileSync(\ttsinterpellation.json)toString!
tts = JSON.parse data
console.log tts.paging

ent = []
for item in tts.entries
  obj = item{asked_by,topic,keywords,category}
  ent.push obj

ret = {entries: ent}
fs.writeFileSync \output, JSON.stringify ret
