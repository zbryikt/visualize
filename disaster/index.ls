main = ($scope, $interval) ->
  map-option = do
    center: new google.maps.LatLng 23.624146, 120.320623
    zoom: 7
    minZoom: 7
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
        width: "1400px"
        height: "1200px"
        "viewBox": "0 0 1400 1200"
      @svg.style do
        position: "absolute"

      @info.prj = d3.geo.mercator!center [120.3202, 22.7199] .scale 335000
      @info.path = d3.geo.path!projection @info.prj
      d3.json \sample.json, (json) ~>
        @data = json.map -> {year: it.0, name: it.1, loc: new google.maps.LatLng(it.4, it.5), casualty: parseInt(it.2) + parseInt(it.3)}
        @svg.selectAll \circle .data @data
          ..enter!append \circle
        @svg.selectAll \text .data @data .enter!append \text
        @svg.selectAll \circle
          .attr do
            cx: 1
            cy: 1
            r: 1
            fill: 'rgba(255,128,64,0.5)'
            stroke: 'rgba(128,64,32,1)'
            "stroke-width": '1.5px'
            opacity: 0.9
        overlay.draw!

    ll2p: (lat, lng, prj) ->
      ret = prj.fromLatLngToDivPixel(new google.maps.LatLng lat, lng)

    bound2p: (bound) ->
      prj = @getProjection!
      ne = bound.getNorthEast!
      sw = bound.getSouthWest!
      p1 = @ll2p ne.lat!, sw.lng!, prj
      p2 = @ll2p sw.lat!, ne.lng!, prj
      return [p1,p2]
    tick: 0
    draw: ->
      prj = @getProjection!
      [p1,p2] = @bound2p map.getBounds!
      [w,h] = [p2.x - p1.x, p2.y - p1.y]

      # svg bounding box (fixed)
      b1 = @ll2p 22.7595, 120.23795080859372, prj
      b2 = @ll2p 22.5698, 120.409450, prj

      now = @svg.selectAll \circle .filter (d,i) ~> i == @tick
      nowt = @svg.selectAll \text .filter (d,i) ~> i == @tick
      if overlay.data => @tick = ( @tick + 1 ) % overlay.data.length

      now.attr do
        cx: (d,i) ~> 
          v = @ll2p d.loc.lat!, d.loc.lng!, prj
          v.x
        cy: (d,i) ~> 
          v = @ll2p d.loc.lat!, d.loc.lng!, prj
          v.y
        r: -> 10
        opacity: 1
      nowt
        .attr do
          x: 100
          y: 60
          opacity: 1
          "dominant-baseline": "central"
          "font-size": (d,i) -> (Math.sqrt(d.casualty) * 3) >? 20 <? 60
        .text -> "#{it.year} #{it.name}"
      now
        .transition!ease \cubic-out .duration 1000
          .attr do
            opacity: 0.5
            r: (d,i) -> 10 + (7 * (d.casualty - 10) / 8)
        .transition!ease \linear .duration 2000
          .attr do
            opacity: 0.0
            r: (d,i) -> d.casualty
      nowt
        .transition!duration 2000
          .attr do
            y: 400
            opacity: 0.6
        .transition!duration 1000
          .attr do
            opacity: 0

  overlay.setMap map
  $interval ->
    overlay.draw!
  , 500
