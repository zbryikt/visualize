main = ($scope, $interval, $http) ->
  map-option = do
    center: new google.maps.LatLng 23.624146, 120.320623
    zoom: 9
    minZoom: 7
    maxZoom: 18
    mapTypeId: google.maps.MapTypeId.ROADMAP
    panControl: false
    scaleControl: false
    mapTypeControl: false
    streetviewControl: false
    #panControlOptions: position: google.maps.ControlPosition.LEFT_CENTER
    zoomControlOptions: position: google.maps.ControlPosition.RIGHT_CENTER
    #mapTypeControlOptions: position: google.maps.ControlPosition.LEFT_CENTER

  map-bound = new google.maps.LatLngBounds!
  bound-ptrs = [[25.471911, 119.455903] [21.707318, 122.356293]]
  bound-ptrs.map(-> new google.maps.LatLng it.0, it.1)map(->map-bound.extend it)
  simdate = (date) -> date.getYear! + 1900

  map-style = [
    {
      "featureType": "water",
      "stylers": [
        { "hue": '#1900ff' },
        { "lightness": -86 },
        { "saturation": -80 }
      ]
    },{
      "featureType": "landscape",
      "stylers": [
        { "lightness": -47 },
        { "hue": '#dd3d00' },
        { "saturation": -80 }
      ]
    },{
      "featureType": "poi",
      "stylers": [
        { "saturation": -100 },
        { "lightness": -30 }
      ]
    },{
      "featureType": "road",
      "stylers": [
        { "weight": 0.3 },
        { "saturation": -48 },
        { "lightness": -0 },
        { "hue": '#dd4400' }
      ]
    }
  ]


  map = new google.maps.Map document.getElementById(\mainmap), map-option
  map.set \styles, map-style
  map.fitBounds map-bound
  google.maps.event.addDomListener window, 'resize', ->
    [w,h] = [$('#mainmap').width!, $('#mainmap').height!]
    map.fitBounds map-bound
    b = map.getBounds!
    [lat1,lng1] = [b.getNorthEast!.lat!, b.getSouthWest!.lng!]
    [lat2,lng2] = [b.getSouthWest!.lat!, b.getNorthEast!.lng!]
    #map.panTo map-option.center
    #
    prj = overlay.getProjection!
    if !prj => return
    b1 = overlay.ll2p lat1, lng1, prj
    b2 = overlay.ll2p lat2, lng2, prj
    w = b2.x - b1.x
    h = b2.y - b1.y
    overlay.resize! 
    /*
    console.log b1.x, b1.y, w, h
    overlay.svg.attr do
      width: "#{w}px"
      height: "#{h}px"
      "viewBox": "0 0 #{w} #{h}"
    overlay.svg.style do
      top: "#{b1.y}px"
      left: "#{b1.x}px"
      position: \absolute
    */
  google.maps.event.addListener map, 'zoom_changed', -> overlay.resize!

  #google.maps.event.addListenerOnce map, \idle, -> google.maps.event.trigger map, \resize
  overlay = new google.maps.OverlayView! <<< do
    info: {}
    onAdd: ->
      @root = d3.select @getPanes!overlayLayer
      [w,h] = [$('#mainmap').width!, $('#mainmap').height!]

      #@axis = d3.select @root .append \svg 
      /*.attr do
        width: "200px"
        height: "20px"
        viewBox: "0 0 200 20"
      */
      /*@axis.append \rect .attr do
        width: \200
        height: \20
        fill: \#f00
        x: \0
        y: \0
      */

      /*@svg = d3.select @root .append \svg .attr do
        width: "#{w}px"
        height: "#{h}px"
        "viewBox": "0 0 #{w} #{h}"
      @svg.style do
        position: "absolute"*/

      @info.prj = d3.geo.mercator!center [120.3202, 22.7199] .scale 335000
      @info.path = d3.geo.path!projection @info.prj
      #d3.json \sample.json, (json) ~>
      #  @data = json.map -> {year: it.0, name: it.1, loc: new google.maps.LatLng(it.4, it.5), casualty: parseInt(it.2) + parseInt(it.3)}
      #  @initNode!
      #  overlay.draw!

      $http do
        url: \https://spreadsheets.google.com/feeds/list/1p0DNKBt4oNfDBgHv4ZXH-vu0bJ_PtxFFXCL7o4O_Cxo/1/public/values?alt=json
        method: \GET
      .success (d) -> 
        data = d.feed.entry.map ->
          date = it.gsx$日期.$t.replace /[年月]/g, '/'
          date = date.replace /[日]/g, ''
          date = new Date(date)
          ret = /(?:(\d+)死)?(?:(\d+)傷)?(?:(\d+)生還)?/.exec it.gsx$死傷.$t
          casualty = {die: parseInt((ret and ret.1) or 0), hurt: parseInt((ret and ret.2) or 0), live: parseInt((ret and ret.3) or 0)}
          casualty.total = casualty.die + casualty.hurt
          casualty.radius = parseInt( Math.sqrt(casualty.total ) )
          lat = parseFloat(it.gsx$緯度.$t or 0)
          lng = parseFloat(it.gsx$經度.$t or 0)
          name = (it.gsx$短名.$t or it.gsx$事件.$t)trim!
          loc = new google.maps.LatLng(lat, lng)
          {name, date, casualty, lat, lng, loc}
        data = data.filter -> it.lat and it.lng and it.casualty.total
        overlay.initNode data


    initNode: (data) ->
      @data = data
      @root.selectAll \svg .data @data
        ..enter!append \svg .append \circle

      @root.selectAll \svg .style do
        position: \absolute
        #border: '1px solid #0f0'
      @root.selectAll "svg circle" .attr do
        cx: 0
        cy: 0
        r: 0
        fill: 'rgba(255,128,64,0.3)'
        stroke: 'rgba(255,0,0,1)'
        "stroke-width": '2.5px'
        opacity: 0.9

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
    resize: ->
      if !map or !map.getBounds! => return
      prj = @getProjection!
      if !prj => return
      [p1,p2] = @bound2p map.getBounds!
      ne = map.getBounds!.getNorthEast!
      sw = map.getBounds!.getSouthWest!
      cr = 0.1 * (p2.x - p1.x) / (ne.lng! - sw.lng!)
      z = map.getZoom!
      [w,h] = [p2.x - p1.x, p2.y - p1.y]
      @root.selectAll \svg
        ..attr do
          width: (d,i) -> "#{cr * d.casualty.radius * 2}px"
          height: (d,i) -> "#{cr * d.casualty.radius * 2}px"
          viewBox: (d,i) -> 
            L = parseInt(cr * d.casualty.radius * 2)
            "0 0 #L #L"
        ..style do
          top: (d,i) ~>
            v = @ll2p d.loc.lat!, d.loc.lng!, prj
            "#{parseInt(v.y - cr * d.casualty.radius)}px"
          left: (d,i) ~>
            v = @ll2p d.loc.lat!, d.loc.lng!, prj
            "#{parseInt(v.x - cr * d.casualty.radius)}px"
        ..select \circle .attr do
          r: (d,i) ~> 
            if i <=@tick and i >= @tick - 4 => return cr * d.casualty.radius * 0.9
            return 0
          cx: (d,i) -> cr * d.casualty.radius 
          cy: (d,i) -> cr * d.casualty.radius 

    draw: ->
      if !map or !map.getBounds! => return
      prj = @getProjection!
      if !prj => return
      [p1,p2] = @bound2p map.getBounds!
      [w,h] = [p2.x - p1.x, p2.y - p1.y]
      ne = map.getBounds!.getNorthEast!
      sw = map.getBounds!.getSouthWest!
      cr = 0.1 * w / (ne.lng! - sw.lng!)

      now = @root.selectAll \svg .filter (d,i) ~> i == @tick
      #nowt = @root.selectAll \svg .filter (d,i) ~> i == @tick
      if overlay.data => @tick = ( @tick + 1 ) % overlay.data.length
      now.each -> $scope.name = "#{(1900 + it.date.getYear!)}/#{it.date.getMonth! + 1} #{it.name} / #{it.casualty.die}死 #{it.casualty.hurt}傷"
      now.each -> console.log it
      now
        ..attr do
          width: (d,i) -> "#{cr * d.casualty.radius * 2}px"
          height: (d,i) -> "#{cr * d.casualty.radius * 2}px"
          viewBox: (d,i) -> 
            L = parseInt(cr * d.casualty.radius * 2)
            "0 0 #L #L"

        ..style do
          top: (d,i) ~>
            v = @ll2p d.loc.lat!, d.loc.lng!, prj
            "#{parseInt(v.y - cr * d.casualty.radius)}px"
          left: (d,i) ~>
            v = @ll2p d.loc.lat!, d.loc.lng!, prj
            "#{parseInt(v.x - cr * d.casualty.radius)}px"
        ..select \circle
          .attr do
            cx: (d,i) -> cr * d.casualty.radius
            cy: (d,i) -> cr * d.casualty.radius
            r: (d,i) -> 0
            opacity: 1
          .transition!ease \cubic-out .duration 1000
            .attr do
              opacity: 0.5
              r: (d,i) -> cr * d.casualty.radius * 0.9
          .transition!ease \linear .duration 1000
            .attr do
              opacity: 0.0

  overlay.setMap map
  $interval ->
    overlay.draw!
  , 500
