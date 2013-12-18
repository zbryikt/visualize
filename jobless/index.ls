mainCtrl = ($scope) ->
  radius = 140
  $scope <<<
    radiusFilter: -> it.value<12
    sizeFilter: -> it.dx<33 || it.dy<12
    random-data: ->
      $scope.current = $scope.data[parseInt(Math.random! * $scope.data.length)]
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

