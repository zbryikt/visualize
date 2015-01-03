angular.module \0media.events, <[]>
  ..controller \0media.events.main, <[$scope $interval $timeout $http 0media.events.map]> ++ ($scope,$interval,$timeout,$http,map) ->
    resize = (p1,p2) -> $scope.$apply ->
      [w,h] = [$('#mainmap').width!, $('#mainmap').height!]
      $scope.events.map (event,i) ->
        event.y = parseInt(( event.lat - p1.0 ) / (p2.0 - p1.0) * h)
        event.x = parseInt(( event.lng - p1.1 ) / (p2.1 - p1.1) * w)
    overlay-adapter = do
      onAdd: (overlay, root) ->
        bubbles = document.getElementById('bubbles')
        bubbles.parentNode.removeChild(bubbles)
        root.appendChild(bubbles)

      draw: (overlay, map) ->
        z = 1 .<<. ( map.getZoom! - 7 )
        $scope.events.map (event, i) ->
          event <<< overlay.ll2p(event.lat, event.lng){x,y}
          event.rate = z

    $scope.reset = -> $scope.events.map (it, i) -> 
      it <<< {fadeout: 1, opacity: 1, top: 65,size: 0, circle_opacity: 0, bubble: {}}
      it.top = i * 50 + 65
      it
    $scope.play = -> $scope.state = 1
    $scope.pause = -> $scope.state = 0
    $scope.speeding = -> $scope.speed = ($scope.speed % 3) + 1
    $scope.state = 1
    $scope.speed = 3
    $scope.initData = ->
      $http do
        url: \https://spreadsheets.google.com/feeds/list/1p0DNKBt4oNfDBgHv4ZXH-vu0bJ_PtxFFXCL7o4O_Cxo/1/public/values?alt=json
        method: \GET
      .success (d) -> 
        data = d.feed.entry.map ->
          date = it['gsx$日期']$t.replace /[年月]/g, '/'
          date = date.replace /[日]/g, ''
          dateFull = new Date(date)
          m = dateFull.getMonth! + 1
          date = (dateFull.getYear! + 1900) + "/" + (if m < 10 => "0" else "") + m
          ret = /(?:(\d+)死)?(?:(\d+)傷)?(?:(\d+)生還)?/.exec it['gsx$死傷']$t
          casualty = {die: parseInt((ret and ret.1) or 0), hurt: parseInt((ret and ret.2) or 0), live: parseInt((ret and ret.3) or 0)}
          casualty.total = casualty.die + casualty.hurt
          casualty.radius = parseInt( Math.sqrt(casualty.total ) ) * 3 + 10
          lat = parseFloat(it['gsx$緯度']$t or 0)
          lng = parseFloat(it['gsx$經度']$t or 0)
          name = (it['gsx$短名']$t or it['gsx$事件']$t)trim!
          loc = new google.maps.LatLng(lat, lng)
          ret = {name, dateFull, casualty, lat, lng, loc, date}
          ret <<< {fadeout: 1, opacity: 1, top: 65,size: 0, circle_opacity: 0, bubble: {}}
          ret
        data = data.filter -> it.lat and it.lng and it.casualty.total
        data.map (it, i) -> it.top = i * 50 + 65
        step = ->
          hit = 0
          chosen = false
          if data[* - 1].top <= 67 => $scope.state = 0
          data.map (it, i) -> 
            if $scope.state == 1 => it.top = it.top - 4
            if it.top <= 67 and it.top >= 64 => hit := 1
            if it.top < 65 =>
              it.fadeout = 1 - (65 - it.top) / 20
              if it.fadeout < 0 => it.fadeout = 0
            if it.top > 300 =>
              it.fadeout = 1 - ((it.top - 300) / 100)
            it.opacity = ( 400 - it.top ) / 400
            it.opacity <?1 >?0
            if it.top < -200 =>
              it.bubble.state = 0
              it.circle_opacity = 0
              it.size = 0

            if it.bubble.state == 1 =>
              it.bubble.state = 2
              it.circle_opacity = 0
              it.size = it.casualty.radius * it.rate

            if !chosen and it.top >= 64 => 
              $scope.current = it
              it.first = true
              if it.bubble.state != 2 =>
                it.bubble.state = 1
                it.circle_opacity = 1
                it.size = 0
              chosen := true

            it
          if hit => $timeout step, 910 - ($scope.speed * 300)
          else $timeout step, 40 - ($scope.speed * 10)
        $timeout step, 30
        $scope.events = data
        map.init resize, overlay-adapter
    $scope.initData!
