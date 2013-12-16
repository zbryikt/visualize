mrtCtrl = ($scope) ->
  $scope.site-hash = {a: 1, b: 2}
  $scope.links = []
  $scope.dindex = 0
  $scope.color = d3.scale.linear!domain [0 10] .range <[blue red]>
  $scope.prj = d3.geo.mercator!center [121.51833286913558, 25.09823258363324] .scale 120000
  $scope.coloring = -> $scope.color it
  $scope.force = d3.layout.force!gravity 0.3
    .charge ->
      if not it.name => return -30
      -it.name.length * 100
    .on \tick ->
      x = [x for x of $scope.site-hash]
      #console.log($scope.site-hash[x.2]x, $scope.site-hash[x.2]y)
      $scope.$apply -> $scope.site-hash = $scope.site-hash
  (raw-site) <- d3.csv \latlng.utf-8.csv
  for it in raw-site
    name = ( it.NAME - /站.*$/ )trim!
    name = name.replace /臺/g,\台
    if name=="台北車" => name = "台北車站"
    $scope.site-hash[name] = {name,weight: 1} <<< coord.to-gws84 it.X, it.Y

  $.ajax \pair.json .done (raw-links) ->
    raw-links = JSON.parse raw-links
    links = []
    for path in raw-links
      for i from 1 til path.length
        src = $scope.site-hash[path[i - 1]]
        des = $scope.site-hash[path[i]]
        links.push {source: $scope.site-hash[path[i - 1]], target: $scope.site-hash[path[i]]}
    $scope.$apply -> $scope.links = links
    $.ajax \flow.utf-8.px .done (flow) ->
      px = new Px flow
      dates = px.metadata.VALUES.年月別
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
        $scope.site-hash[s][d] = if v=='"."' => 0 else Math.sqrt(~~v) / 100
        count += 1
      $scope.$apply ->
        for k of $scope.site-hash
          v = $scope.site-hash[k]
          [x,y] = $scope.prj [v.lng, v.lat]
          v <<< {x,y}
        $scope.dates = dates
        $scope.force.nodes [$scope.site-hash[x] for x of $scope.site-hash] .links $scope.links .size [900,700] .start!
        $scope.site-hash = $scope.site-hash
      setInterval ->
        $scope.$apply ->
          $scope.dindex = ($scope.dindex + 1) % dates.length
      , 200
