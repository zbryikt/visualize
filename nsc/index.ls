budgetCtrl = ($scope) ->
  color = d3.scale.category20c!
  color = d3.scale.ordinal!range <[#F6B4FF #AA8BE8 #86A0FF #A6D7E8 #C0FFEC]>
  $scope <<< do
    inst: ""
    name: ""
    query: ""
    update: ->
      d3.select \#svg .selectAll 'g.inst circle'
        .attr \fill ->
          if $scope.query and it.name and it.name.indexOf($scope.query)>=0 => return \#f00
          if it.inst => color it.inst else \none
  $scope.$watch 'query', ->
    console.log $scope.query
    $scope.update!
  data <- d3.json \budget.json
  radius = 900
  bubble = d3.layout.pack!sort null .size [radius,radius] .padding 1.5
  svg = d3.select \#svg
  root = {children: []}
  inst-hash = {}
  circle-hash = {}
  root =
    children: for key of data => do
      name: key
      inst: key
      value: Math.sqrt(data[key]0)
      c: for dept of data[key]1 => {name: dept, inst: key, value: Math.sqrt(data[key]1[dept]>?1)}


  svg.selectAll \g.inst .data bubble.nodes(root)
    ..enter!
      ..append \g .attr \class \inst
        ..attr \transform -> "translate(#{it.x} #{it.y})"
        ..append \circle
          .attr \r -> it.r
          .attr \fill -> if it.inst => color it.inst else \none
          .call -> circle-hash[it.name] = @
        ..each (d) ->
          d3.select @ .on \mouseover (e) ~>
            $scope.$apply (e)-> $scope.inst = d.inst
            if d.r < 20 =>
              $scope.$apply (e) -> $scope.name = ""
              return
            bubble = d3.layout.pack!sort null .size [2 * d.r, 2 * d.r] .padding 1.5
            d3.select @ .selectAll \g.dept .data bubble.nodes({children: d.c})
              ..enter!append \g .attr \class \dept
                ..attr \transform ->
                  "translate(#{it.x - d.r} #{it.y - d.r})"
                ..append \circle
                  .attr \r -> it.r
                  .attr \fill -> if it.name => color it.name else \none
                  .on \mouseover (it) -> $scope.$apply (e)-> $scope.name = it.name
            d3.select @ .selectAll \g.dept .style \opacity 1
          if d.r < 20 => return
          d3.select @ .on \mouseout (e) ~>
            d3.select @ .selectAll \g.dept .style \opacity 0
      ..append \g .attr \class \inst-text
        ..attr \transform -> "translate(#{it.x} #{it.y})"
        ..append \text .attr \class \name
          .text -> if it.r>15 => it.name else ""
