angular.module \main, <[ui.choices]>
  ..controller \main, ($scope) ->
    $scope.nodes = []
    $scope <<< do
      randomWidth: false
      randomHeight: false
    $scope.init = ->
      $scope.nodes = [{
        w: if $scope.randomWidth => (Math.random!*230 + 30) else 100
        h: if $scope.randomHeight => (Math.random!*230 + 30) else 100
      } for i from 0 to (5 + parseInt(Math.random! * 5))]
    $scope.$watch 'randomHeight', $scope.init
    $scope.$watch 'randomWidth', $scope.init
    $scope.init!

