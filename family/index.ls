<- $ document .ready

max-overall = 0
max = {}
min = {}
count = 0

window.visible = (type) ->
  d3.selectAll '#svg circle.vertical' .transition!duration 500 .style \opacity -> if type>1 => 1.0 else 0
  d3.selectAll '#svg circle.horizontal' .transition!duration 500 .style \opacity -> if type%2 => 0.5 else 0

d3.csv \data.csv (data) ->
  mgn = [50 60 90 30]
  console.log data
  dlist = []
  key-list = {}
  yr-list = {}
  for item in data => for key of item
    if key==="年" or key==="總計" => continue
    v = parseInt(10*Math.sqrt(parseInt item[key]/10000))/10.0
    max-overall>?= v
    max[key]>?= v
    min[key]<?= v
    key-list[key] = 1
    yr-list[item["年"]] = 1
    dlist.push [item["年"], key, v]
  dlist.sort (a,b) -> parseInt Math.random!*3 - 1
  key-list = [k for k of key-list]
  yr-list = [k for k of yr-list]
  sx = d3.scale.ordinal!domain yr-list .rangePoints [mgn.0, 800 - mgn.2]
  sy = d3.scale.ordinal!domain key-list .rangePoints [mgn.1, 430 - mgn.3]
  xy = d3.svg.axis!scale sy .orient \left .tickValues key-list .tickPadding 0
  xx = d3.svg.axis!scale sx .orient \top .tickValues yr-list .tickPadding 0
  color = d3.scale.category20b!
  show = ->
    if count >= dlist.length => return
    d = dlist[count]
    [x,y] = [sx(d.0), sy(d.1)]
    radius =  20 * ( (d.2 - min[d.1]) / (max[d.1] - min[d.1]) ) + 2
    radius-all =  20 * ( d.2 / max-overall ) + 2

    e = d3.select \#svg .append \circle .attr \class \vertical
    e .attr \cx x
      .attr \cy y
      .attr \r 0
      .attr \fill \none
      .attr \stroke -> color (d.1 + 1)
      .attr \stroke-width \1px
      .transition!ease \elastic .duration 500 .attr \r radius-all

    e = d3.select \#svg .append \circle .attr \class \horizontal
    e .attr \cx x
      .attr \cy y
      .attr \r 0
      .style \opacity \0.5
      .attr \fill -> color d.1
      .transition!ease \elastic .duration 500 .attr \r radius

    f = d3.select \#svg .append \text .text (->parseInt(d.2*d.2))
      .attr \text-anchor \middle .attr \x x
      .attr \fill \#f00
    set-handle = (e, f, x, y, r) ->
      e.on \click ->
        f.attr \y y .style \opacity 1 .transition!ease \bounce .duration 500 .style \opacity 0 .attr \y (-> y - 20)
      e.on \mouseover ->
        e .attr \r -> r + 5
          .transition!ease \bounce .duration 500 .attr \r -> r
    set-handle e, f, x, y, radius
    count := count + 1
    for i from 0 to parseInt Math.random!*2
      setTimeout show, parseInt(Math.random!*700)
  d3.select \#svg .append \g .attr \class \yaxis .attr \transform, "translate(780 0)" .call xy
  d3.select \#svg .append \g .attr \class \xaxis .attr \transform, "translate(0 30)" .call xx
  show!
