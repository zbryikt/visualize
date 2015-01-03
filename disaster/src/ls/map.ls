angular.module \0media.events
  ..factory \0media.events.map, <[]> ++ -> do
    init: (node, resize, overlay) ->
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
        zoomControlOptions: position: google.maps.ControlPosition.RIGHT_CENTER
        #panControlOptions: position: google.maps.ControlPosition.LEFT_CENTER
        #mapTypeControlOptions: position: google.maps.ControlPosition.LEFT_CENTER

      map-bound = new google.maps.LatLngBounds!
      bound-ptrs = [[25.471911, 119.455903] [21.707318, 122.356293]]
      bound-ptrs.map(-> new google.maps.LatLng it.0, it.1)map(->map-bound.extend it)
      simdate = (date) -> date.getYear! + 1900


      map = new google.maps.Map node, map-option
      map.fitBounds map-bound

      google.maps.event.addDomListener window, 'resize', ->
        [w,h] = [$(node).width!, $(node).height!]
        map.fitBounds map-bound
        b = map.getBounds!
        [lat1,lng1] = [b.getNorthEast!.lat!, b.getSouthWest!.lng!]
        [lat2,lng2] = [b.getSouthWest!.lat!, b.getNorthEast!.lng!]

      _overlay = new google.maps.OverlayView! <<< do
        ll2p: (lat, lng)->
          prj = @getProjection!
          ret = prj.fromLatLngToDivPixel(new google.maps.LatLng lat, lng)
        onAdd: -> overlay.onAdd @, @getPanes!overlayLayer
        draw: -> overlay.draw @, map
      _overlay.setMap map
      return map

