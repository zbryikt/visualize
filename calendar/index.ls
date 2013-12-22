mainCtrl = ($scope) ->
ircCtrl = ($scope, $http, $element) ->
  $scope <<< do
    week:
      th: <[一 二 三 四 五 六 日]>
      y-hash: {}
      m-hash: {}
      hover:
        map: d3.scale.linear!domain [0 300] .range [50 250]
        cur: {v: 0, d: "-"}
        setter: null
        set: ->
          if !it =>
            @setter = setTimeout ~>
              @setter = null
              $scope.$apply ~> @cur = {v:0,d:"-"}
            , 1000
          else if @setter =>
            clearTimeout @setter
            @setter = null
          @cur <<< it
          @cur.tx = @map @cur.x

  $http.get \g0v-count.json .success (data)->
    len = data.by_date_per_day.length
    weekday = data.by_date_per_day.slice(len - 259, len - 1)
    offset = (moment weekday.0.0 .weekday! + 6) % 7
    dmonth = 0
    $scope.date = weekday.map (d,i) ->
      i += offset
      m = moment d.0
      [year,month] = [m.year!, m.month! + 1]
      if not (month of $scope.week.m-hash) =>
        dmonth += 2
        $scope.week.m-hash[month] = dmonth + parseInt((i % 280) / 7) * 7
      [x,y] = [dmonth + parseInt((i % 280) / 7) * 7,  (i % 7) * 7 + parseInt(i / 280) * 60]
      if not (year of $scope.week.y-hash) => $scope.week.y-hash[year] = x
      { y, x, v: d.1, d: d.0  }
    v = $scope.date.map -> it.v
    [min,max] = [d3.min(v), d3.max(v)]
    $scope.week.day-from = moment $scope.date.0.d .format \L
    $scope.week.day-til = moment $scope.date[*-1]d .format \L
    $scope.heat-color = d3.scale.linear!domain [min,(2 * min + max)/3,(min + 2 * max)/3,max] .range <[#EEEEEE #D6E685 #8CC665 #1E6823]>
