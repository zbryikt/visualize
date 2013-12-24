main = ($scope) ->
  $scope.x = 20
  $scope.px = 0
  $scope.blah = []
  svgns = "http://www.w3.org/2000/svg"
  svg = document.getElementById("svg")
  #circle = document.createElementNS(svgns, "circle")
  #circle.setAttributeNS(svgns,"cx",150)
  #circle.setAttributeNS(svgns,"cy",150)
  #circle.setAttributeNS(svgns,"r",20)
  #circle.setAttributeNS(svgns,"fill",'#f00')
  c = document.createElementNS(svgns, "circle")
  c.setAttribute("cx","100")
  c.setAttribute("cy","100")
  c.setAttribute("r","20")
  c.setAttribute("fill","red")
  svg.appendChild(c)
  ani = document.createElementNS(svgns, "animate")
  ani.setAttribute("attributeName", "r")
  ani.setAttribute("dur", "1s")
  ani.setAttribute("begin", "indefinite")
  ani.setAttribute("end", "indefinite")
  ani.setAttribute("fill","remove")
  c.appendChild(ani)

  setInterval ->
    $scope.$apply ->
      $scope.px = $scope.x
      $scope.x = Math.random!*100
      c.setAttribute("r",999)#$scope.px)
      $scope.blah.push [$scope.px, $scope.x]
      c.removeChild(ani)
      #ani := document.createElementNS(svgns, "animate")
      #ani.setAttribute("attributeName", "r")
      #ani.setAttribute("dur", "1s")
      #ani.setAttribute("fill","freeze")
      ani.setAttribute("from", $scope.px)
      ani.setAttribute("to", $scope.x)
      #ani.setAttribute("begin", svg.getCurrentTime() - 0.1)
      #ani.setAttribute("end", svg.getCurrentTime() + 1.5)
      cc = svg.getCurrentTime!
      ani.beginElementAt(cc)
      #ani.endElementAt(cc + 1.5)
      console.log ani.getStartTime!, svg.getCurrentTime!
      #ani.beginElementAt(svg.getCurrentTime() - 0.1)
      #ani.endElementAt(svg.getCurrentTime() + 1.5)
      c.appendChild(ani)
      c.setAttribute("r",$scope.x)
      #c.setAttribute("r",$scope.x)
  ,2000
