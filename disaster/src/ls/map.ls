angular.module \0media.events
  ..factory \0media.events.map, <[]> ++ -> do
    init: (resize, overlay) ->
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
        #prj = overlay.getProjection!
        #if !prj => return
        #b1 = overlay.ll2p lat1, lng1, prj
        #b2 = overlay.ll2p lat2, lng2, prj
        #w = b2.x - b1.x
        #h = b2.y - b1.y
        #resize!
        #resize [lat1, lng2], [lat2, lng1]

      _overlay = new google.maps.OverlayView! <<< do
        ll2p: (lat, lng)->
          prj = @getProjection!
          ret = prj.fromLatLngToDivPixel(new google.maps.LatLng lat, lng)
        onAdd: -> overlay.onAdd @, @getPanes!overlayLayer
        draw: -> overlay.draw @, map
      _overlay.setMap map
      return map

