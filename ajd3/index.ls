mapCtrl = ($scope) ->
  $scope <<< do
    geoblock: []
    fish: d3.fisheye.circular! .radius 200 .focus [450,300]
    prj: ([x,y]) ->
      [x,y] = d3.geo.mercator!center([120.979531, 23.978567])scale(50000)([x,y])
      {x,y} = $scope.fish {x,y}
      [x,y]
    color: d3.scale.category20c!
    render: -> $scope.geoblock = $scope.topo.features.map(->[$scope.color(it.properties.COUNTYNAME),$scope.path(it)])
    mousemove: ->
      $scope.fish.focus [event.x, event.y]
      $scope.render!

  $scope.path = d3.geo.path!projection $scope.prj

  data <- d3.json \twCounty2010.topo.json
  <- $scope.$apply
  $scope.topo = topojson.feature data, data.objects["twCounty2010.geo"]
  $scope.render!
