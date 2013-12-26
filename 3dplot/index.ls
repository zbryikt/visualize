google.load \visualization, \1
mainCtrl = ($scope) ->
  $scope.date-idx = 0
  $scope.date-string = ""
  $scope.tooltip = {}
  $scope.grid-data = {}
  $scope.site-hash = {}
  $scope.date-format = ->
    ret = /(\d+)年(\d+)月/.exec it
    "#{ret.1}.#{if ~~ret.2>9 => "" else \0}#{ret.2}"
  $scope.range = lat: {}, lng: {}, num: {}
  $scope.prj = d3.geo.mercator!center [121.51833286913558, 25.09823258363324] .scale 120000
  $scope.num = r: 60, c: 60
  <- google.setOnLoadCallback
  data = new google.visualization.DataTable!
  [i for i from 0 til $scope.num.c]map -> data.add-column \number, "col#i"
  data.add-rows $scope.num.r
  d = 360 / $scope.num.r

  plot = new greg.ross.visualisation.SurfacePlot document.getElementById \viewport
  fillPly = true

  colour1 = {red:0, green:0, blue:255}
  colour2 = {red:0, green:255, blue:255}
  colour3 = {red:0, green:255, blue:0}
  colour4 = {red:255, green:255, blue:0}
  colour5 = {red:255, green:0, blue:0}
  colours = [colour1, colour2, colour3, colour4, colour5]

  yAxisHeader = "經度"
  xAxisHeader = "緯度"
  zAxisHeader = "人數"

  options = do
    xPos: 0
    yPos: 0
    width: 600
    height: 500
    colourGradient: colours
    fillPolygons: fillPly
    tooltips: $scope.tooltip
    xTitle: xAxisHeader
    yTitle: yAxisHeader
    zTitle: zAxisHeader
    restrictXRotation: false

  (raw-site) <- d3.csv \latlng.utf-8.csv
  for it in raw-site
    name = ( it.NAME - /站.*$/ )trim!
    name = name.replace /臺/g,\台
    if name=="台北車" => name = "台北車站"
    $scope.site-hash[name] = {name,weight: 1,flow:{},price:{}} <<< coord.to-gws84 it.X, it.Y
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
  (flow) <- $.ajax \flow.utf-8.px .done
  $.ajax \meow.utf-8.px .done (meow) ->
    px = load-px flow
    load-px meow
    dates = px.metadata.VALUES.年月別.map -> $scope.date-format it
    for k of $scope.site-hash
      v = $scope.site-hash[k]
      [x,y] = $scope.prj [v.lng, v.lat]
      $scope.range.lat.min<?=y
      $scope.range.lat.max>?=y
      $scope.range.lng.min<?=x
      $scope.range.lng.max>?=x
      v <<< {x,y}
      for k,d of v.flow =>
        $scope.range.num.min<?=d
        $scope.range.num.max>?=d

    init = ->
      for i from 0 til $scope.num.r => for j from 0 til $scope.num.c =>
        data.set-value i, j, 0
    grid =
      x: d3.scale.linear!domain [$scope.range.lng.min, $scope.range.lng.max] .range [0 $scope.num.c]
      y: d3.scale.linear!domain [$scope.range.lat.min, $scope.range.lat.max] .range [0 $scope.num.r]
      z: d3.scale.linear!domain [$scope.range.num.min, $scope.range.num.max] .range [0 1]
    lo = 3
    update = ->
      max = 0
      for k of $scope.grid-data => $scope.grid-data[k] = 0
      for k,v of $scope.site-hash
        [x,y] = [parseInt(grid.x(v.x)), parseInt(grid.y(v.y))]
        for i from y - 6 to y + 6 => for j from x - 6 to x + 6
          d = ((y - i)**2 + (x - j)**2)**0.5
          ratio = Math.exp((-d * d) / (2 * lo * lo ))
          if i<0 or j<0 or i>=$scope.num.r or j>=$scope.num.c => continue
          value = (grid.z(v.flow[$scope.date-string] or 0)) * ratio
          key = "#{i}-#{j}"
          if not (key of $scope.grid-data) => $scope.grid-data[key] = 0
          $scope.grid-data[key] += value
          max >?= $scope.grid-data[key]
          if d<=3 => $scope.tooltip[i * $scope.num.c + j] = v.name
      for i from 0 til $scope.num.r => for j from 0 til $scope.num.c =>
        idx = i * $scope.num.c + j
        if not $scope.tooltip[idx] => $scope.tooltip[idx] = ""
        data.set-value i, j, ($scope.grid-data["#{i}-#{j}"] or 0) / max
      options.tooltips = $scope.tooltip
    $scope.dates = dates
    init!
    iterate = ->
      $scope.$apply ->
        $scope.date-idx = ( $scope.date-idx + 1 ) % $scope.dates.length
        $scope.date-string = $scope.dates[$scope.date-idx]
      update!
      plot.draw data, options
    iterate!
    setInterval iterate, 1000
