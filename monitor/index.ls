mainCtrl = ($scope) ->
  map-option = do
    center: new google.maps.LatLng 25.048281,121.5371
    scrollwheel: false
    zoom: 16
    minZoom: 8
    maxZoom: 18
    mapTypeId: google.maps.MapTypeId.ROADMAP

  cluster-option = do
    grid-size: 75
    max-zoom: 15
    minimum-cluster-size: 1
    zoom-on-click: true

  map = new google.maps.Map document.getElementById(\map-node), map-option
  google.maps.event.addListenerOnce map, \idle, -> google.maps.event.trigger map, \resize
  setTimeout (-> $ \#map-node .css \width \100%), 1000
  mc = new MarkerClusterer map, [], cluster-option

  $scope.poi = []
  $scope.poi-icon = do
    url: \poi.png
    size: new google.maps.Size(13,16)
    origin: new google.maps.Point(0, 0)

  (data) <- d3.csv \monitor.csv

  count = 0
  for item in data
    if count> 10000 => break
    count++
    m = new google.maps.Marker do
      zIndex: 9900000
      position: new google.maps.LatLng item.lat, item.lng
      map: null
      icon: $scope.poi-icon
    $scope.poi.push m
  mc.addMarkers $scope.poi
  $scope.cluster-is-on = true
  $scope.$watch 'clusterIsOn', (v) ->
    if v => mc.addMarkers $scope.poi
    else
      mc.clearMarkers!
      $scope.poi.map -> it.set-map map
