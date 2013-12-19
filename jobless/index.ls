mainCtrl = ($scope) ->
  radius = 140
  $scope <<<
    stat: {}
    cookie: {}
    db-ref: new Firebase \https://jobless.firebaseIO.com/
    fav: {}
    fav-count: 0
    is-fav: -> if $scope.fav[it] => \active else ""
    set-fav: ->
      if !$scope.fav[it] => $scope.fav[it] = ++$scope.fav-count
      else
        [k for k of $scope.fav]map (k) -> if $scope.fav[k]>$scope.fav[it] => $scope.fav[k]--
        delete $scope.fav[it]
        $scope.fav-count--
      $scope.choices = [k for k of $scope.fav]sort (a,b) -> $scope.fav[b] - $scope.fav[a]
    send-fav: ->
      if $scope.cookie[\jobless] == 1 or !$scope.choices.length => return
      document.cookie = "jobless=1"
      $scope.cookie[\jobless] = 1
      setTimeout (-> $scope.db-ref.push $scope.choices), 0
    radiusFilter: -> it.value<12
    sizeFilter: -> it.dx<33 || it.dy<12
    rotate: -> parseInt(((360 * (it / $scope.type.length)) + 90 ) / 180) * 180
    random-date: ->
      if $scope.serial-timer => clearInterval $scope.serial-timer
      $scope.serial-timer = null
      $scope.current = $scope.data[parseInt(Math.random! * $scope.data.length)]
    serial: -1
    serial-timer: null
    serial-date: ->
      if $scope.serial-timer => return
      $scope.serial-timer = setInterval ->
        $scope.$apply ->
          $scope.serial = ($scope.serial + 1) % ($scope.data.length)
          $scope.current = $scope.data[$scope.serial]
      ,500
    data: []
    type: []
    current: {}
    aux:
      pie: d3.layout.pie!sort null .value -> it.value
      arc: d3.svg.arc!outerRadius radius .innerRadius 0
      color: d3.scale.category20!
      bubble: d3.layout.pack!sort null .size [radius * 2.2,radius * 2.2] .padding 1.5
      treemap: d3.layout.treemap!sort null .size [400 250] .padding 5
    viz:
      pie: []
      bar: []
      bubble: []
      treemap: []

  document.cookie.split(\;)map ->
    it = it.split(\=)
    $scope.cookie[it.0.trim!] = ~~(it.1 or "")trim!
  $scope.db-ref.on \child_added, (d) ->
    v = d.val!
    <- $scope.$apply
    for it,i in v =>
      $scope.stat[it] = ( $scope.stat[it] or 0 ) + v.length - i
    $scope.viz.stat = $scope.aux.bubble.nodes({children: [{name:k,value:~~$scope.stat[k]} for k of $scope.stat]})filter(->!it.children)

  $scope.$watch 'current', ->
    $scope.viz.pie = $scope.aux.pie [{name:k,value:~~$scope.current[k]} for k in $scope.type]
    $scope.viz.bar = [{name:k,value:~~$scope.current[k]} for k in $scope.type]
    $scope.viz.bubble = $scope.aux.bubble.nodes({children: [{name:k,value:~~$scope.current[k]} for k in $scope.type]})filter(->!it.children)
    $scope.viz.treemap = $scope.aux.treemap.nodes({children: [{name:k,value:~~$scope.current[k]} for k in $scope.type]})filter(->!it.children)
  ,true

  (data) <- d3.json \data.json
  data-list= []
  for d in data.1
    obj = {}
    data.0.map (it,i) -> obj[it] = d[i]
    data-list.push obj
  $scope.$apply -> $scope <<< {data: data-list, type: data.0.filter(->it!=\時間), current: data-list[* - 1]}

