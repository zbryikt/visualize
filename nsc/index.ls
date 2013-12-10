budgetCtrl = ($scope) ->
  $scope <<< do
    inst: ""
    name: ""
  data <- d3.json \budget.json
  radius = 900
  bubble = d3.layout.pack!sort null .size [radius,radius] .padding 1.5
  svg = d3.select \#svg
  root = {children: []}
  inst-hash = {}
  color = d3.scale.category20c!
  root =
    children: for key of data => do
      name: key
      inst: key
      value: data[key]0
      c: for dept of data[key]1 => {name: dept, inst: key, value: data[key]1[dept]>?1}

  svg.selectAll \g.inst .data bubble.nodes(root)
    ..enter!append \g .attr \class \inst
      ..attr \transform -> "translate(#{it.x} #{it.y})"
      ..append \circle
        .attr \r -> it.r
        .attr \fill -> if it.inst => color it.inst else \none
      ..append \text .attr \class \name
        .text -> if it.r>10 => it.name else ""
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
