update = null
<- $ document .ready!

color = d3.scale.category20!
#(data) <- d3.json \http://kcwu.csie.org/~kcwu/ircstat/g0v-count.json
(data) <- d3.json \g0v-count.json

[w,h] = [$ \#content .width!, $ \#content .height!]
data = data.by_nick
max = d3.max [it.1 for it in data]
data = data.map -> {text: it.0, size: 10 + (w/2<?h/2) * it.1 / max }
nick = data.map(->it.text.toLowerCase!)sort((a,b) -> if a > b => 1 else if a==b => 0 else -1)
d3.select \#name .selectAll \option .data nick .enter!append \option .attr \value (->it) .text(->it)

svg = d3.select \#content .append \svg .attr \width \100% .attr \height \100%
root = svg.append \g .attr \transform "translate(#{w/2},#{h/2})"

update := ->
  name = $ \#name .val!
  root.selectAll \text.cloud
    .style \stroke-width -> if it.text==name => \3px else \0
    .style \stroke \#f00
draw = ->
  root.selectAll \text.cloud .data data
    ..exit!remove!
    ..enter!append \text .attr \class \cloud
      .style \font-size -> "#{it.size}px"
      .style \font-family "century gothic"
      .style \fill (d,i) -> color i
      .attr \text-anchor "middle"
      .attr \transform -> "translate(#{it.x},#{it.y}) rotate(#{it.rotate})"
    .text -> it.text

d3.layout.cloud!size [w, h] .words data
  .padding 0
  .rotate 0
  .font "century gothic"
  .fontSize -> it.size
  .on \end draw
  .start!
