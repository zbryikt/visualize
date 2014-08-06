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
      @svg.append \g .attr(\class, \all).style(\opacity, -> if $scope.showmode == 1 => 1 else 0)
      @svg.append \g .attr(\class, \petro).style(\opacity, -> if $scope.showmode == 2 => 1 else 0)
      @info.prj = d3.geo.mercator!center [120.3202, 22.7199] .scale 335000
      @info.path = d3.geo.path!projection @info.prj
      d3.json \kh_pipelines.geojson, (json) ~>
        @svg.select \g.all .selectAll \path.all .data json.features
          ..enter!append \path
            ..attr do
              class: \all
              d: @info.path
              stroke: \#00f
              opacity: 0.7
              "stroke-width": 2
              "stroke-linejoin": \round
              fill: \none
        @info.nodes = @svg.selectAll \path
      d3.json \kh_petrolines.geojson, (json) ~>
        @svg.select \g.petro .selectAll \path.petro .data json.features
          ..enter!append \path
            ..attr do
              class: \petro
              d: @info.path
              stroke: \#f00
              opacity: 0.7
              "stroke-width": 2
              "stroke-linejoin": \round
              fill: \none
        @info.nodes = @svg.selectAll \path

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
        "opacity": ~>
          z = map.getZoom!
          if z >= 16 => return 0.3
          if z >= 14 => return 0.5
          if z >= 12 => return 0.7
          if z < 11 => return 1
        "stroke-width": ~>
          z = map.getZoom!
          if z >= 16 => return "1"
          if z >= 14 => return "2"
          if z >= 12 => return "5"
          if z <11 => return "7"
      console.log map.getZoom!
      console.log w,h

  overlay.setMap map
  $scope.showmode = 2
  $scope.$watch 'showmode', (v) -> if overlay.svg and v=>
    overlay.svg.select \g.all .style \opacity, -> if v==1 => 1 else 0
    overlay.svg.select \g.petro .style \opacity, -> if v==2 => 1 else 0
