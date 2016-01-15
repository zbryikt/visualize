angular.module \main, <[ui.choices]>
  ..controller \main, <[$scope $interval]> ++ ($scope, $interval) ->
    $scope.nodes = []
    $scope <<< do
      randomWidth: false
      randomHeight: false
    $scope.init = ->
      $scope.nodes = [{
        w: if $scope.randomWidth => (Math.random!*110 + 20) else 30
        h: if $scope.randomHeight => (Math.random!*50 + 10) else 30
      } for i from 0 to (15 + parseInt(Math.random! * 7))]
    $scope.$watch 'randomHeight', $scope.init
    $scope.$watch 'randomWidth', $scope.init
    $scope.init!

    copybtn = 'textarea#output'
    clipboard = new Clipboard copybtn
    clipboard.on \success, ->
      $(copybtn).tooltip({title: 'copied', trigger: 'click'}).tooltip('show')
      setTimeout((->$(copybtn).tooltip('hide')), 1000)
    clipboard.on \error, ->
      $(copybtn).tooltip({title: 'Press Ctrl+C to Copy', trigger: 'click'}).tooltip('show')
      setTimeout((->$(copybtn).tooltip('hide')), 1000)

    direction = ->
      $scope.flexdirection = $scope.direction + if $scope.directionReverse => "-reverse" else ""
    $scope.$watch 'direction', direction
    $scope.$watch 'directionReverse', direction
    pseudocss = """
.container:after {
  display: block;
  content: " invisible node "
  flex(999 999 auto)
}"""

    $scope.update = ->
      $scope.output = """
.container {
  display: flex;
  display: -webkit-flex;
  flex-wrap: wrap;
  flex-direction: #{$scope.flexdirection};
  justify-content: #{$scope.justify.0};
  align-items: #{$scope.align.0};
  align-content: #{$scope.multialign.0};
}
#{if $scope.invisible-item => pseudocss else ''}
.item {
  flex: #{$scope.grow.0} #{$scope.shrink.0} #{$scope.basis.0}
}
"""
    $interval (-> $scope.update! ), 500
