update = null

<- $ document .ready

m = [20 10 20 100]
[w,  h]  = [800, 400]
[iw, ih] = [w - m.0 - m.2, h - m.1 - m.3]
color = d3.scale.category20b!
new-svg = (cls, parent = d3.select \body) ->
  parent.append \svg .attr \class cls
    .attr \width \100%  .attr \height \100%
    .attr \viewBox "0 0 #w #h" .attr \preserveAspectRatio "xMidYMid"

line-chart = (data) ->
  data = data.by_date_per_day
  [week-data, month-data] = [[], []]

  for i in [0 to data.length - 1 by 7]
    v = [data[i]0, 0]
    for j in [0 to 7]
      if not data[i + j] => break
      v.1 += data[i + j].1
    v.1 /= 7
    week-data.push v
  for i in [0 to data.length - 1 by 30]
    v = [data[i]0, 0]
    for j in [0 to 30]
      if not data[i + j] => break
      v.1 += data[i + j].1
    v.1 /= 30
    month-data.push v

  build-chart = (data, parent)->
    line-chart = new-svg \line-chart, parent
    bar-width = iw / data.length
    y = d3.scale.linear!domain [0 d3.max [it.1 for it in data]] .range [h - m.3, m.1]
    x = d3.scale.ordinal!domain [it.0 for it in data] .rangePoints [m.0 + bar-width/2, w - m.2 - bar-width/2]
    x2 = d3.scale.ordinal!domain [it.0 for it in data] .rangePoints [m.0, w - m.2]
    x-axis = d3.svg.axis!scale x2 .orient \bottom .tickValues [1 to 5]map -> data[parseInt(it * 2 * (data.length - 1) / 12)].0
    y-axis = d3.svg.axis!scale y .orient \left
    line-chart .append \g .attr \class \bar-group .selectAll \rect .data data
      ..enter!append \rect
        .attr \width bar-width * 0.8
        .attr \height -> h - y(it.1) - m.3
        .attr \x -> x(it.0) - bar-width * 0.4
        .attr \y -> y it.1
        .attr \fill \#f94
    line-chart.append \g .attr \transform "translate(0 #{h - m.3})" .call x-axis
    line-chart.append \g .attr \transform "translate(#{m.0} 0)" .call y-axis
  build-chart week-data, d3.select \#line-chart1
  build-chart month-data, d3.select \#line-chart2

relation-chart = (data) ->
  data = data.by_nick_to
  force = d3.layout.force!
  hash = {}
  for it of data
    for jt of data[it] => if not (jt of hash) => hash[jt] = {name: jt, charge: 1}
    hash[it] = {name: it, d: data[it], charge: 1}
  nodes = [it for it of hash]map (d,i) -> hash[d].index = i; hash[d]
  links = []
  sel = $ \#select-name
  for it in nodes
    for jt in [x for x of it.d]sort((a,b) -> it.d[a] - it.d[b])[0 to 2]
      continue if not jt
      links.push source: hash[it.name], target: hash[jt]
      hash[jt]charge++
  nodes.sort (a,b) -> if a.name > b.name => 1 else if a.name==b.name => 0 else -1
    .map -> sel.append "<option value='#{it.name}'>#{it.name}</option>"
  force.nodes nodes .links links .size [w, h] .gravity 0.5 .charge(-> -(it.charge**2) - 30)start!
  #force.nodes nodes .links links .size [iw, ih] .charge(-> -(it.charge**2) - 30)start!
  svg = new-svg \relation-chart, d3.select \#relation-chart
  dim = $ \#relation-chart .offset!

  link-tag = svg.selectAll \line.link .data links
    ..enter!append \g .attr \class \link-group
      ..append \line .attr \class \link
        .attr \stroke-width \1px
        .attr \stroke \#ccc
        .attr \stroke-dasharray "3,1"

  node-tag = svg.selectAll \circle.node .data nodes
    ..enter!append \g .attr \class \node-group
      ..append \circle .attr \class \node
        .attr \r -> 2 + Math.sqrt it.charge
        .attr \fill -> color it.name
        .on \mouseover (it) ->
          text.show!css do
            left: d3.event.pageX
            top: d3.event.pageY + 15
          .text it.name .delay 1000 .fadeOut!

        .call force.drag
  text = $ \#relation-name
  last-find = do
    r: null
    charge: 0
  update := ->
    v = $ \#select-name .val! .trim!
    if not (v of hash) => return
    if last-find.r =>
      last-find.r.charge = last-find.charge
      last-find.r.active = 0
    r = hash[v]
    last-find.r = r
    last-find.charge = r.charge
    r.charge = -100
    r.active = 1
    force.start!

  force.on \tick, ->
    link-tag .selectAll \line.link
      .attr \x1 -> it.source.x
      .attr \y1 -> it.source.y
      .attr \x2 -> it.target.x
      .attr \y2 -> it.target.y

    node-tag .selectAll \circle.node
      .attr \cx -> it.x
      .attr \cy -> it.y
      .attr \stroke -> if it.active => \#f00 else \none


d3.json \http://kcwu.csie.org/~kcwu/ircstat/g0v-count.json, (data) ->
  console.log data
  line-chart data
  relation-chart data
