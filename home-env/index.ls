epaCtrl = ($scope) ->
  $scope.name = "近期附近無公害申訴"
  $scope.epas = []
  map-option = do
    center: new google.maps.LatLng 25.048281,121.5371
    scrollwheel: false
    zoom: 16
    minZoom: 8
    maxZoom: 18
    mapTypeId: google.maps.MapTypeId.ROADMAP

  map = new google.maps.Map document.getElementById(\map-node), map-option
  google.maps.event.addListenerOnce map, \idle, -> google.maps.event.trigger map, \resize
  setTimeout (-> $ \#map-node .css \width \100%), 1000

  google.maps.event.addListener map, \dragend ->
    ll = map.getCenter!
    $.ajax \/epa, method: \POST, data: JSON.stringify {lat:ll.lat!, lng: ll.lng!}
    .failed ->
      $scope.$apply -> $scope.epa = [[\環境衛生 46] [\噪音 8] [\廢棄物 3] [\空氣污染不含異味污染物 1]]
    .success (data) ->
      count = {}
      for item in data
        cat = item.Pollution_Parent
        count[cat] = (count[cat] or 0) + 1
      ret = [k for k of count]sort (a,b) -> count[b] - count[a]
      $scope.$apply ->
        $scope.epa = ret.map -> [it,count[it]]
        $scope.name = if ret.length => "附近主要公害類型為#{ret[0]}" else "近期附近無公害申訴"
  setTimeout (->$ \#map-node .width \100%), 1000
