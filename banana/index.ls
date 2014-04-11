scope = null

main = ($scope) ->
  scope := $scope
  $scope.fish = d3.fisheye.circular! .radius 200 .focus [-50,-50]
  $scope.coordindex = banana.coordindex.join " "
  $scope.raw-point = banana.point
  $scope.point = new Array $scope.raw-point.length
  $scope.vector = banana.vector.join " "
  $scope.morph = ->
    len = parse-int($scope.raw-point.length / 3) + 1
    console.log $scope.raw-point.length
    console.log len
    for i from 0 til len
      #{x, y} = $scope.fish {x: $scope.raw-point[i * 3] , y: $scope.raw-point[i * 3 + 1]}
      {x, y} = $scope.fish do
        x: $scope.raw-point[i * 3]
        y: $scope.raw-point[i * 3 + 1]
      z = $scope.raw-point[i * 3 + 2]
      $scope.point[i * 3] = x
      $scope.point[i * 3 + 1] = y
      $scope.point[i * 3 + 2] = z
  $scope.morph!
  $scope.mousemove = (event) ->
    $scope.fish.focus [-event.x/10, -event.y/10]
    $scope.morph!

movehandle = (e) -> if scope =>
  console.log e
  scope.$apply ->
    scope.mousemove e
