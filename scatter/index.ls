m = [20 20 30 40]
mi = [10 10 20 20]

[w,h] = [900 600]


main = ($scope) ->
  $scope.cat = x: 1, y: 1
  $scope.idx = x: 1, y: 1
  $scope.area = x: 1, y: 1
  $scope.stat-cat = stat-cat
  $scope.stat-idx = stat-idx
  $scope.stat-area = stat-area
  $scope.gotolink = ->
    s = $scope
    p = window.location.pathname
    window.location.href = "#p?#{parse-int(Math.random!*10000)}\##{s.cat.x}.#{s.idx.x}.#{s.area.x}.#{s.cat.y}.#{s.idx.y}.#{s.area.y}"


hannah = (d1, d2) ->
  nodes = for r,i in d1.range => {x: d1.data[i], y: d2.data[i], v: ~~r}
  links = for i from 1 til nodes.length =>
    [n1, n2] = nodes[i - 1, i]
    v: n1.v, src: {x: n1.x, y: n1.y}, des: {x: n2.x, y: n2.y}
  {nodes, links}
  
load-px = (data, idx, ldx) ->
  px = new Px data
  index = px.metadata.VALUES[\指標]
  range = px.metadata.VALUES[\期間]
  local = px.metadata.VALUES[\縣市]
  offset = idx * range.length * local.length
  ret = {
    data: for r,i in range => parseFloat(px.data[offset + i * local.length + ldx]) or 0
    local: local[ldx]
    index: index[idx]
    range
  }
    ..min = d3.min ret.data
    ..max = d3.max ret.data
    ..size = ret.max - ret.min
  ret

config = do
  d1: path: 3, idx: 2, loc: 3
  d2: path: 13, idx: 0, loc: 3

console.log JSON.stringify(config)
ret = /#(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)$/.exec window.location.href 
if ret =>
  config.d1 = path: ~~ret.1, idx: ~~ret.2, loc: ~~ret.3
  config.d2 = path: ~~ret.4, idx: ~~ret.5, loc: ~~ret.6
(d1) <- $.ajax "data/#{config.d1.path}.px" .done
(d2) <- $.ajax "data/#{config.d2.path}.px" .done
px1 = load-px d1, config.d1.idx, config.d1.loc
px2 = load-px d2, config.d2.idx, config.d2.loc
x-axis = d3.scale.linear!domain [px1.min,px1.max] .range [m.3 + mi.3, w - m.1 - m.3 - mi.1 - mi.3]
y-axis = d3.scale.linear!domain [px2.min,px2.max] .range [h - m.0 - m.2 - mi.0 - mi.2, m.0 + mi.0]
hd = hannah px1, px2

d3.select \#label
  ..append \g .attr \class 'axis x-axis'
    .append \path
      .attr \class \base
      .attr \d -> "M#{m.3} #{h - m.2 - m.0}L#{w - m.3 - m.1} #{h - m.2 - m.0}"
  ..append \g .attr \class 'axis y-axis'
    .append \path
      .attr \class \base
      .attr \d -> "M#{m.3} #{m.0}L#{m.3} #{h - m.2 - m.0}"

if px1.size == 0 or px2.size == 0 => return

d3.select '#label g.x-axis' .selectAll \path.tick .data [[x-axis(i),i] for i from px1.min to px1.max by (px1.size / 10)]
   ..enter!append \g
     ..attr \transform -> "translate(#{it.0} #{h - m.2 - m.0})"
     ..append \path
       .attr \class \tick
       .attr \d -> "M0 0 L0 5"
     ..append \text
       .attr \dy \12px
       .text -> "#{it.1}".substring(0,4)
   ..exit!remove!

d3.select '#label g.y-axis' .selectAll \path.tick .data [[y-axis(i),i] for i from px2.min to px2.max by (px2.size / 10)]
   ..enter!append \g
     ..attr \transform -> "translate(#{m.3} #{it.0})"
     ..append \path
       .attr \class \tick
       .attr \d -> "M0 0 L-5 0"
     ..append \text
       .attr \dy \14px
       .attr \transform "rotate(90)"
       .text -> "#{it.1}".substring(0,4)
   ..exit!remove!

d3.select \#label .append \g .attr \transform "translate(5 300)" 
  .append \text .attr \transform "rotate(90)" .text -> "#{px2.local} / #{px2.index}"
d3.select \#label .append \g .attr \transform "translate(450 580)" 
  .append \text .text -> "#{px1.local} / #{px1.index}"

d3.select \#chart .selectAll \g.link .data hd.links
  ..enter!append \g
    ..attr \class \link
    ..append \line
      .attr \x1 -> x-axis it.src.x
      .attr \y1 -> y-axis it.src.y
      .attr \x2 -> x-axis it.des.x
      .attr \y2 -> y-axis it.des.y
      .attr \stroke ->
        if it.v < 2000 => return \#f00
        if it.v < 2008 => return \#0c0
        \#00c
  ..exit!remove!

d3.select \#chart .selectAll \g.node .data hd.nodes
  ..enter!append \g
    ..attr \class \node
    ..attr \transform -> "translate(#{x-axis it.x}, #{y-axis it.y})"
    ..append \circle
      .attr \r \3px
      .attr \stroke ->
        if it.v < 2000 => return \#f00
        if it.v < 2008 => return \#0c0
        \#00c
    ..append \text
      .attr \dy \14px
      .text -> "#{it.v}"
  ..exit!remove!
