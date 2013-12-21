mrtCtrl = ($scope) ->
  $scope.site-hash = {}
  $scope.dates = {cur: ""}
  $scope.datebar = {}
  $scope.dim = \flow
  $scope.links = []
  $scope.dindex = 0
  $scope.date-hite = 60
  $scope.date-format = ->
    ret = /(\d+)年(\d+)月/.exec it
    "#{ret.1}.#{if ~~ret.2>9 => "" else \0}#{ret.2}"
  $scope.play = true
  $scope.legend =
    flow:  [100000 to 3000000 by 400000]map -> ["#{it/10000}萬", Math.sqrt(it) / 100 ]
    price: [100000 to 4500000 by 500000]map -> ["#{it/10000}萬", Math.sqrt(it) / 100 ]
  $scope.color = d3.scale.linear!domain [0 9 18] .range <[#0f0 #ff0 #f00]>
  $scope.prj = d3.geo.mercator!center [121.51833286913558, 25.09823258363324] .scale 120000
  $scope.coloring = -> $scope.color it
  $scope.v1 = -> it>1
  $scope.v2 = (link) ->
    date = $scope.dates.cur
    $scope.dim==\price or (link.source[$scope.dim][date] > 1 and link.target[$scope.dim][date] > 1 and
    (link.ready-time==0 or link.ready-time <= parseFloat date))
  $scope.toggle-play = ->
    $scope.play = !$scope.play
    $scope.force.stop!

  $scope.set-date = (e) ->
    offset = $(\#svg)offset!
    [x,y] = [e.clientX - offset.left, e.clientY - offset.top]
    if $scope.dates[$scope.dim] and x < 40 and y >= 60 =>
      $scope.dindex = parseInt($scope.dates[$scope.dim]length * (( y - 60 ) / 420 ))
      $scope.dindex = $scope.dindex>?0<?$scope.dates[$scope.dim]length
      $scope.date-hite = $scope.datebar[$scope.dim] $scope.dindex
      $scope.dates.cur = $scope.dates[$scope.dim][$scope.dindex]
  $scope.force = d3.layout.force!gravity 0.5
    .charge ->
      if not it.name => return -30
      -it.name.length * 100
    .on \tick ->
      x = [x for x of $scope.site-hash]
      $scope.$apply -> $scope.site-hash = $scope.site-hash
  (raw-site) <- d3.csv \latlng.utf-8.csv
  for it in raw-site
    name = ( it.NAME - /站.*$/ )trim!
    name = name.replace /臺/g,\台
    if name=="台北車" => name = "台北車站"
    $scope.site-hash[name] = {name,weight: 1,flow:{},price:{}} <<< coord.to-gws84 it.X, it.Y
  load-price = (data) ->
    dates = []
    for k of data =>
      dates.push k
      for i,v of data[k] => $scope.site-hash[i]price[k] = ( Math.sqrt(~~v) / 100 >? 2 )
    $scope.datebar.price = d3.scale.linear!domain [0 dates.length - 1] .range [60 480]
    $scope.dates.price = dates
  load-px = (flow) ->
    px = new Px flow
    dates = px.metadata.VALUES.年月別.map -> $scope.date-format it
    inout = px.metadata.VALUES.入出站別
    sites = px.metadata.VALUES.項目
    count = 0
    for d in dates => for io in inout => for s in sites
      s = (s - /站.*$/)trim!
      s = s.replace /臺/g,\台
      if s == \台北 => s = \台北車站
      if not $scope.site-hash[s] =>
        count += 1
        continue
      v = px.data[count]
      $scope.site-hash[s]flow[d] = if v=='"."' => 0 else (Math.sqrt(~~v) / 100 >? 2)
      count += 1
    px
  $.ajax \pair.json, {dataType: \json} .done (raw-links) ->
    if typeof raw-links == typeof "" => raw-links = JSON.parse raw-links
    links = []
    ready-time = {}
    for item in raw-links.1 => ready-time["#{item.0}-#{item.1}"] = $scope.date-format item.2
    for path in raw-links.0
      for i from 2 til path.length
        src = $scope.site-hash[path[i - 1]]
        des = $scope.site-hash[path[i]]
        lnk = "#{src.name}-#{des.name}"
        links.push {source: src, target: des, color: path.0, ready-time: parseFloat(ready-time[lnk] or 0)}
    $scope.$apply -> $scope.links = links
    (flow) <- $.ajax \flow.utf-8.px .done
    (price) <- $.ajax \mrt_unitprice.json, {dataType: \json} .done
    $.ajax \meow.utf-8.px .done (meow) ->
      px = load-px flow
      load-px meow
      load-price price
      dates = px.metadata.VALUES.年月別.map -> $scope.date-format it
      $scope.$apply ->
        $scope.datebar.flow = d3.scale.linear!domain [0 dates.length - 1] .range [60 480]
        for k of $scope.site-hash
          v = $scope.site-hash[k]
          [x,y] = $scope.prj [v.lng, v.lat]
          v <<< {x,y}
        $scope.dates.flow = dates
        $scope.force.nodes [$scope.site-hash[x] for x of $scope.site-hash] .links $scope.links .size [1024,500] .start!
        $scope.site-hash = $scope.site-hash
      setInterval ->
        if $scope.play => $scope.$apply ->
          $scope.dindex = ($scope.dindex + 1) % $scope.dates[$scope.dim]length
          $scope.date-hite = $scope.datebar[$scope.dim] $scope.dindex
          $scope.dates.cur = $scope.dates[$scope.dim][$scope.dindex]
          if !$scope.force.alpha! => $scope.force.start!
        else
          $scope.force.stop!
      , 400
