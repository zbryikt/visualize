update = null
<- $ document .ready
(data) <- d3.json \ttsinterpellation

[w,h] = [$ \#content .width!, $ \#content .height!]
data = data.entries
# todo: use prelude unique

hash-speaker = {}
speaker-keyword = {}
for it in data
  for name in it.asked_by
    if not (name of speaker-keyword) => speaker-keyword[name] = []
    speaker-keyword[name] ++= it.keywords
speaker = [it.asked_by for it in data]reduce(((a,b)->a++b),[])map ->
  it = it.trim!
  if not (it of hash-speaker) => hash-speaker[it] = 0
  hash-speaker[it]++
speaker = [{name: it, count: hash-speaker[it]} for it of hash-speaker]
hash = {}
kw = [it.keywords for it in data]
[it.keywords for it in data]reduce(((a,b) -> a ++ b), [])map ->
  it = it.trim!
  if not (it of hash) => hash[it] = 0
  hash[it]++
kw = [{text: it, size: 10 + 50 * Math.random! * hash[it]} for it of hash]
for it in kw => it.all-size = it.size


color = d3.scale.category20!
speaker-root = d3.select \#speaker
svg = d3.select \#content .append \svg .attr \width \100% .attr \height \100%
root = svg.append \g .attr \transform "translate(#{w/2},#{h/2})"

draw = ->
  console.log \draw!
  speaker-root.selectAll \div.avatar .data speaker
    ..exit!remove!
    ..enter!append \div .attr \class \avatar .each (d) ->
      d3.select @
        ..append \img
        ..append \div
  speaker-root.selectAll \div.avatar .each (d) ->
      d3.select @
        ..select \img .attr \src ->
          avatar = CryptoJS.MD5 "MLY/#{d.name}" .toString!
          "http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=medium"
        ..select \div .attr \class \name .text d.name
        ..on \click -> resize d.name
  root.selectAll \text.cloud .data kw
    ..exit!remove!
    ..enter!append \text .attr \class \cloud
      .style \font-family "century gothic"
      .style \fill (d,i) -> color i
      .attr \text-anchor "middle"
      .text -> it.text
  root.selectAll \text.cloud
    .transition!duration 1000
    .style \font-size -> "#{it.size}px"
    .attr \transform -> "translate(#{it.x},#{it.y}) rotate(#{it.rotate})"

resize = (name) ->
  keyword = speaker-keyword[name] #<[廣告代言人]>
  for it in kw
    it.size = if it.text in keyword => 100 else 10
  update!

cloud = d3.layout.cloud!size [w,h] .words kw
update := ->
  cloud
    .words kw
    .padding 0
    .rotate 0
    .font "century gothic"
    .fontSize -> it.size
    .on \end draw
    .start!

update!
#d3.layout.cloud!size [w, h] .words kw
#  .padding 0
#  .rotate 0
#  .font "century gothic"
#  .fontSize -> it.size
#  .on \end draw
#  .start!
