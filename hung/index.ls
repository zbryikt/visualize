x = null
main = ($scope, $http) ->
  [w,h,m] = [$(window)width! * 0.8, $(window)height! * 0.8, 70]
  (data) <- $http.get \data.json .success
  x := data
  sorter = (a,b,idx, lv) ->
    if idx.length == lv => return 0
    v = idx[lv]
    if isNaN a[v] =>
      u = if a[v]<b[v] => 1 else if a[v]>b[v] => -1 else => sorter a,b, idx, lv + 1
    else 
      u = ~~b[v] - ~~a[v]
      if u==0 => u = sorter a,b, idx, lv + 1
    u
  sort = (idx) ->
    data.sort (a,b) -> 
      sorter a, b, idx, 0
    for item,i in data
      item.9 = i
  for item in data => item.push 0
  sort [6, 2]
  console.log [item.2 for item in data]
  days = [it.6 for it in data]
  lvs = [it.0 for it in data]
  x-axis = d3.scale.linear!domain [0, data.length - 1] .range [w - m, m]
  y-axis = d3.scale.linear!domain [d3.min(days), d3.max(days)] .range [h - m, m * 2]
  color = d3.scale.ordinal!range <[#5b7 #d64]>

  cont = d3.select \#container
  cont.selectAll \div.tops .data data
    ..exit!remove!
    ..enter!append \div .attr \class \tops
  cont.selectAll \div.mrks .data data
    ..exit!remove!
    ..enter!append \div .attr \class \mrks
  cont.selectAll \div.name1 .data data
    ..exit!remove!
    ..enter!append \div .attr \class \name1
  cont.selectAll \div.name2 .data data
    ..exit!remove!
    ..enter!append \div .attr \class \name2
  cont.selectAll \div.day .data data
    ..exit!remove!
    ..enter!append \div .attr \class \day

  tops = cont.selectAll \div.tops
  mrks = cont.selectAll \div.mrks
  name1 = cont.selectAll \div.name1
  name2 = cont.selectAll \div.name2
  day = cont.selectAll \div.day
  init = ->
    cont.selectAll \div.name1
      ..style \width \60px
      ..style \height -> "21px"
      ..text -> "#{it.4}"
    cont.selectAll \div.name2
      ..style \width \60px
      ..style \height -> "21px"
      ..text -> "#{it.5}"
    cont.selectAll \div.day
      ..style \width \60px
      ..style \height -> "21px"
      ..text -> "#{it.6}天"
    cont.selectAll \div.tops
      ..style \width \40px
      ..style \height -> "21px"
      ..style \background -> 
        "url(mark-top-#{if it.2=='542旅' => 1 else 2}.png) center bottom"
    cont.selectAll \div.mrks
      ..style \width \40px
      ..style \height -> "#{1 + h - m - y-axis(it.6) + 27}px"
      ..style \background -> 
        "url(mark-#{if it.0<11 => \general else \sergeant}-#{if it.2=='542旅' => 1 else 2}.png) center bottom"

  render = ->
    cont.selectAll \div.name1
      .transition!duration 400
        .style \left -> "#{x-axis(it.9) - 30}px"
        .style \top -> "#{h - m + 10 + 27}px"
    cont.selectAll \div.name2
      .transition!duration 400
        .style \left -> "#{x-axis(it.9) - 30}px"
        .style \top -> "#{h - m + 25 + 27}px"
    cont.selectAll \div.day
      .transition!duration 400
        .style \left -> "#{x-axis(it.9) - 30}px"
        .style \top -> "#{y-axis(it.6) - 41}px"
    cont.selectAll \div.tops
      .transition!duration 400
        .style \left -> "#{x-axis(it.9) - 20}px"
        .style \top -> "#{y-axis(it.6) - 21}px"
    cont.selectAll \div.mrks
      .transition!duration 400
        .style \left -> "#{x-axis(it.9) - 20}px"
        .style \top -> "#{y-axis(it.6)}px"

  init!
  render!
  /*set-interval (->
    sort [parseInt(Math.random!*9),parseInt(Math.random!*9)]
    render!
  ), 1000*/

  $scope.sort = (array) -> 
    sort array
    render!
  /*
  rbox = cont.append \div .attr \class \rectbox

  
  mbkbox = svg.append \g .attr \class \mbkbox
  sbox = svg.append \g .attr \class \sbox
  rbox = svg.append \g .attr \class \rbox
  bbox = svg.append \g .attr \class \bbox
  tbox = svg.append \g .attr \class \tbox
  dbox = svg.append \g .attr \class \dbox
  lbox = svg.append \g .attr \class \tbox
  mbox = svg.append \g .attr \class \mbox

  rbox.selectAll \rect .data data
    ..exit!remove!
    ..enter!append \rect

  sbox.selectAll \rect .data data
    ..exit!remove!
    ..enter!append \rect

  bbox.selectAll \text .data data
    ..exit!remove!
    ..enter!append \text .attr \class \back

  dbox.selectAll \text .data data
    ..exit!remove!
    ..enter!append \text .attr \class \day

  tbox.selectAll \text .data data
    ..exit!remove!
    ..enter!append \text .attr \class \front

  lbox.selectAll \text .data data
    ..exit!remove!
    ..enter!append \text .attr \class \label

  mbkbox.selectAll \image .data data
    ..exit!remove!
    ..enter!append \image .attr \class \markbk
  mbox.selectAll \image .data data
    ..exit!remove!
    ..enter!append \image .attr \class \mark

  circles = cbox.selectAll \circle
  rects = rbox.selectAll \rect
  shadows = sbox.selectAll \rect
  texts = tbox.selectAll \text
  days = dbox.selectAll \text
  backs = bbox.selectAll \text
  labels = lbox.selectAll \text
  marks = mbox.selectAll \image
  markbks = mbkbox.selectAll \image

  render = ->
    circles
      ..attr \cx -> x-axis it.9
      ..attr \cy -> y-axis(it.6) - 20
      ..attr \r \0
      ..style \fill -> color it.2

    rects = rbox.selectAll \rect
      ..attr \x -> x-axis(it.9) - 22
      ..attr \y -> y-axis(it.6)
      ..attr \width \60px
      ..attr \height -> 1 + h - m - y-axis(it.6)
      ..attr \fill 'url(#sergeant1)' #-> color it.2
      ..attr \stroke \#000

    shadows = sbox.selectAll \rect
      ..attr \x -> x-axis(it.9) - 24
      ..attr \y -> y-axis(it.6) + 3
      ..attr \width \45px
      ..attr \height -> 1 + h - m - y-axis(it.6)
      ..attr \fill \#ccc

    backs
      ..attr \x -> x-axis it.9
      ..attr \y -> y-axis(it.6) - 20
      ..text -> it.5

    days
      ..attr \x -> x-axis it.9
      ..attr \y -> y-axis(it.6) - 20
      ..text -> "#{it.6}天"

    texts
      ..attr \x -> x-axis it.9
      ..attr \y -> h - m + 40 #y-axis(it.6) - 20
      ..text -> it.5

    labels
      ..attr \x -> x-axis it.9
      ..attr \y -> h - m + 20
      ..text -> it.1

    markbks
      ..attr \x -> x-axis(it.9) - 45
      ..attr \y -> h - m - 89
      ..attr \width \90px
      ..attr \height \90px
      ..attr \xlink:href -> if it.0 < 11 => \officer.svg else \sergeant.svg

  render!
  */
