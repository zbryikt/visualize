[w,h] = [900,600]
main = ($scope,$http) ->
  $scope.xaxis = d3.scale.linear!domain [150, w - 150] .range [0 w]
  $scope.force = d3.layout.force!gravity 0.09 .charge -> (it.name.length - 2) * -50 - 80
  $scope.start = null
  $scope.end = ""
  $scope.miles = 0
  $scope.price = 0
  $scope.choosed = []
  $http.get \no1.json, .success (data) ->
    $scope.names = data.names.filter ->it
    count = $scope.names.length
    nodes = for n,i in $scope.names => do
      weight: 1
      name: n
      x: (w/2) + h * Math.cos(-1.57 + -6.28 * i / count) / 2
      y: (h/2) + h * Math.sin(-1.57 + -6.28 * i / count) / 2
    links = for i from 1 til $scope.names.length => {source: nodes[i - 1], target: nodes[i] }
    $scope.force.nodes nodes  .links links .size [w,h] .start!

    sum-of-miles = (s, e) ->
      s = data.names.indexOf s
      e = data.names.indexOf e
      if s < 0 or e < 0 => return NaN
      ret-miles = data.miles.slice s, e .reduce(((a,b)->a + b ),0)
      ret-price = (data.price.slice s, e .reduce(((a,b)->a + b ),0) - 24)
      ret-price >?=0
      if ret-price > 240 => ret-price = 240 + ( ret-price - 240 ) * 0.75
      [ret-miles, ret-price, parseInt( ret-price * 9 ) / 10 ]

    route = ->
      passed = false
      for item in nodes => 
        if item.selected and $scope.choosed.length == 2 => passed = !passed
        item.passed = passed
      if $scope.choosed.length == 2 =>
        n =nodes.filter -> it.selected 
        ret = (sum-of-miles n.0.name, n.1.name)
        $scope.$apply ->
          $scope.price = parseInt( ret.1 * 10 ) / 10
          $scope.miles = parseInt( ret.0 * 10 ) / 10
          $scope.start = n.0.name
          $scope.end = n.1.name
      else $scope.$apply -> $scope.start = null

    draw = ->
      d3.select \#svg .selectAll \g.link .select \line
        .attr \x1 -> $scope.xaxis it.source.x
        .attr \y1 -> it.source.y
        .attr \x2 -> $scope.xaxis it.target.x
        .attr \y2 -> it.target.y
      d3.select \#svg .selectAll \g.site
        .attr \transform -> "translate(#{$scope.xaxis it.x} #{it.y})"
        .select \circle .attr \fill -> if it.selected => \#f0f else if it.passed => \#0f0 else \#fff
    d3.select \#svg 
      ..append \g
        ..selectAll \g.link .data links
          ..exit!remove!
          ..enter!append \g
            ..attr \class \link
            ..append \line
      ..append \g
        ..selectAll \g.site .data nodes
          ..exit!remove!
          ..enter!append \g
            ..attr \class \site
            ..attr \transform -> "translate(#{$scope.xaxis it.x} #{it.y})"
            ..append \circle
              .attr \r \5px
            ..append \text
              .attr \class \text-bg
              .attr \dy \18px
              .text -> it.name
            ..append \text
              .attr \class \text-fg
              .attr \dy \18px
              .text -> it.name
            ..on \click -> 
              if $scope.choosed.length == 2 and !it.selected => $scope.choosed.0.selected = false
              it.selected = !it.selected
              $scope.$apply -> $scope.choosed = nodes.filter -> it.selected
              #choosed := choosed + if it.selected => 1 else -1
              route!
              draw!
    $scope.force.on \tick, draw
