main = ($scope) ->
  map-option = do
    center: new google.maps.LatLng 22.624146, 120.320623
    zoom: 13
    minZoom: 8
    maxZoom: 18
    mapTypeId: google.maps.MapTypeId.ROADMAP
    panControlOptions: position: google.maps.ControlPosition.LEFT_CENTER
    zoomControlOptions: position: google.maps.ControlPosition.LEFT_CENTER
    mapTypeControlOptions: position: google.maps.ControlPosition.LEFT_CENTER

  map-style = [
    {
      "featureType": "road",
      "stylers": [
        { "saturation": -100 }
      ]
    },{
      "featureType": "poi",
      "stylers": [
        { "saturation": -100 }
      ]
    },{
      "featureType": "transit",
      "stylers": [
        { "saturation": -100 }
      ]
    }
  ]

  map = new google.maps.Map document.getElementById(\mainmap), map-option
  map.set \styles, map-style
  #google.maps.event.addListenerOnce map, \idle, -> google.maps.event.trigger map, \resize
  overlay = new google.maps.OverlayView! <<< do
    info: {}
    onAdd: ->
      @root = @getPanes!overlayLayer
      @svg = d3.select @root .append \svg .attr do
        width: "1000px"
        height: "1200px"
        "viewBox": "0 0 1000 1200"
      @svg.style do
        position: "absolute"
      #@svg.append \g .attr(\class, \all).style(\opacity, -> if $scope.showmode == 1 => 1 else 0)
      #@svg.append \g .attr(\class, \petro).style(\opacity, -> if $scope.showmode == 2 => 1 else 0)
      @info.prj = d3.geo.mercator!center [120.3202, 22.7199] .scale 335000
      @info.path = d3.geo.path!projection @info.prj
      @color = <[#f90 #f00 #0f0 #09f #00f #f0f #f00]>
      @opacity = ->
        z = map.getZoom!
        if z >= 16 => return 0.3
        if z >= 14 => return 0.5
        if z >= 12 => return 0.7
        if z <= 11 => return 1
      @strokeWidth = ->
        z = map.getZoom!
        if z >= 16 => return "5"
        if z >= 14 => return "7"
        if z >= 12 => return "9"
        if z <=11 => return "11"

      d3.json \json/index.json, (list) ~>
        $scope.$apply ~> $scope.maplist = (list ++ [<[all 全部]>])map((d,i) ~> d ++ [@color[i]])
        #$scope.$apply ~> $scope.maplist = list.map((d,i) ~> d ++ [@color[i]])

        _ = (k,n,i) ~> 
          d3.json "json/#k.geojson", (json) ~>
            @svg.append \g .attr(\class, k).style(\opacity, -> if $scope.showmode == k or $scope.showmode == 'all' => 1 else 0)
            @svg.select "g.#k" .selectAll "path.#k" .data json.features
              ..enter!append \path
                ..attr do
                  class: k
                  d: @info.path
                  stroke: @color[i]
                  opacity: @opacity
                  "stroke-width": @strokeWidth
                  "stroke-linejoin": \round
                  fill: \none
            @info.nodes = @svg.selectAll \path

        for [k,n],i in list => _ k,n,i


    ll2p: (lat, lng, prj) ->
      ret = prj.fromLatLngToDivPixel(new google.maps.LatLng lat, lng)

    bound2p: (bound) ->
      prj = @getProjection!
      ne = bound.getNorthEast!
      sw = bound.getSouthWest!
      console.log sw.lng!, ne.lat!
      console.log ne.lng!, sw.lat!
      p1 = @ll2p ne.lat!, sw.lng!, prj
      p2 = @ll2p sw.lat!, ne.lng!, prj
      return [p1,p2]

    draw: ->
      prj = @getProjection!
      [p1,p2] = @bound2p map.getBounds!
      [w,h] = [p2.x - p1.x, p2.y - p1.y]
      # svg bounding box (fixed)
      b1 = @ll2p 22.7595, 120.23795080859372, prj
      b2 = @ll2p 22.5698, 120.409450, prj
      @svg.style do
        left: "#{b1.x}px"
        top: "#{b1.y}px"

      @svg.attr do
        width: "#{b2.x - b1.x}px"
        height: "#{b2.y - b1.y}px"
      @svg.selectAll \path .attr do
        "opacity": @opacity
        "stroke-width": @strokeWidth
      #console.log map.getZoom!
      #console.log w,h

  overlay.setMap map
  $scope.showmode = 'all'
  $scope.$watch 'showmode', (v) -> if overlay.svg and v =>
    console.log $scope.showmode, v
    for [k,n] in $scope.maplist =>
      overlay.svg.select "g.#k" .style \opacity, -> if v==k or v=='all' => 1 else 0
    #overlay.svg.select \g.all .style \opacity, -> if v==1 => 1 else 0
    #overlay.svg.select \g.petro .style \opacity, -> if v==2 => 1 else 0
