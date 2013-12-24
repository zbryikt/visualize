main = ($scope) ->
  ns = "http://www.w3.org/2000/svg"
  svg = document.getElementById \svg
  $scope <<< do
    cur-r: 20
    old-r: 20
    reuse-ani: true
    animate:
      wrap: (name, src, des, dur)->
        cur = src
        st = new Date!getTime!
        _animate = ->
          ct = new Date!getTime!
          ratio = ((ct - st) / dur)<?1
          v = cur + (des - src) * ratio
          $scope.$apply -> $scope.$eval "#{name} = #{v}"
          if ratio<1 => setTimeout _animate, 10
        setTimeout _animate, 0
      begin: 0
    new-ani: ->
      document.createElementNS ns, \animate
        ..setAttribute \attributeName, \r
        ..setAttribute \dur, \1s
        ..setAttribute \begin, \indefinite
        ..setAttribute \end, \indefinite
        ..setAttribute \fill, \freeze

  $scope.js-smil = document.getElementById \js-smil
  $scope.js-smil-ani = $scope.new-ani!
  $scope.js-smil.appendChild $scope.js-smil-ani
  $scope.d3-anim = d3.select \#d3-anim
  $scope.verbose = -> parseInt(it)* 5

  setInterval ->
    $scope.$apply ->
      # core attribute: radius
      $scope.old-r = $scope.cur-r
      $scope.cur-r = Math.random!*50

      # for smil
      $scope.animate.begin = svg.getCurrentTime!

      # js-smil
      $scope.js-smil.removeChild($scope.js-smil-ani)
      if not $scope.reuse-ani => $scope.js-smil-ani = $scope.new-ani!
      cc = svg.getCurrentTime!
      $scope.js-smil-ani
        ..setAttribute("from", $scope.old-r)
        ..setAttribute("to", $scope.cur-r)
        ..beginElementAt(cc)
        ..endElementAt(cc + 1.5)
      $scope.js-smil
        ..appendChild $scope.js-smil-ani
        ..setAttribute \r, $scope.cur-r

      # d3-anim
      $scope.d3-anim.transition!ease \linear .duration 1000 .attr \r -> $scope.cur-r
      $scope.animate.wrap \animate.r, $scope.old-r, $scope.cur-r, 1000
  ,1000
