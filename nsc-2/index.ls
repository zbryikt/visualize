[w,h] = [900,600,50]
[r-min, r-max] = [2,50]
r-show = 5
trans-time = 5000
r-show-text = 15
mg = 60

budgetCtrl = ($scope) ->
  data <- d3.json \budget.json
  force = d3.layout.force!gravity 1.0 .charge(-> -0 - it.charge) .size [( w - 2 * mg ) ,( h - 2 * mg ) ] 
  year-s = 101
  year-e = 102
  hash = {}
  main = (data) ->
    $scope.$apply ->
      $scope.year-s = year-s
      $scope.year-e = year-e
    keys = [k for k of data[year-s]]
    hkeys = [k for k of hash]
    newkeys = []
    delkeys = []
    for k of data[year-e] => keys.push k if not (k of data[year-s])
    for k in keys => if not (k of hash) => newkeys.push k
    for k in hkeys => if not (k in keys) => delkeys.push k
    for k in keys => hash[k] = (hash[k] or {}) <<< do
      name: k
      value: parseInt((data[year-e][k] or 0) / 10)
      r: Math.sqrt ~~(data[year-e][k] or 0)
      delta: ((data[year-e][k] - data[year-s][k]) or 0) / (data[year-s][k] or 1) 

    for k in delkeys => 
      hash[k]r = 0
      hash[k]delta = 0

    r = [v.r for k,v of hash]
    r-map = d3.scale.linear!domain [d3.min(r), d3.max(r)] .range [r-min, r-max]
    for k in keys =>
      if r-map(hash[k]r) <= r-show => hash[k]delta = 0
    delta = [v.delta for k,v of hash]
    [d-min, d-max] = [d3.min(delta), d3.max(delta)]

    c1 = d3.scale.linear!domain [0 255] .range <[#f00 #ff0]>
    c2 = d3.scale.linear!domain [0 255] .range <[#ff0 #0ff]>
    delta-map = d3.scale.linear!domain [d-max>?-d-min, 0] .range [mg + r-max , h - r-max - mg] 
    list = for k,it of hash =>
      it.cx = w / 2 +  Math.random! * (w / 2 - r-max - mg) * (if it.delta > 0 => 1 else -1)
      it.cy = delta-map Math.abs it.delta
      it.r = r-map it.r
      it.charge = 0
      color = parseInt(255 - 255 * Math.abs(it.delta) / d-max)
      it.fill = if it.delta > 0 => c1 color else c2 color
      it

    for k in delkeys => 
      hash[k]r = 0
      hash[k]delta = 0

    force.nodes list
    mouseover = (n) -> 
      if n.r > r-show => $scope.$apply -> $scope{name, value} = n

    d3.select '#svg g.circles' .selectAll \g.circle-group .data list .enter!append \g
      ..attr \class "circle-group root-group"
      ..attr \transform -> "translate(#{it.cx},#{it.cy})"
      ..style \opacity 0
      ..on \mouseover mouseover
      ..append \g
        ..attr \class \force-group
        ..append \circle
          ..attr \stroke "rgba(0,0,0,0.3)"
          .attr \r 0

    d3.select '#svg g.texts' .selectAll \g.text-group .data list .enter!append \g 
      ..attr \class "text-group root-group"
      ..attr \transform -> "translate(#{it.cx},#{it.cy})"
      ..on \mouseover mouseover
      ..append \g
        ..attr \class \force-group
        ..style \opacity 0
        ..append \text
          ..attr \class \bk
          ..text -> it.name
        ..append \text
          ..text -> it.name

    d3.select \#svg .selectAll \g.circle-group
      ..attr \class -> "circle-group root-group#{if it.r <= r-show => '' else ' active'}"
      ..transition!duration trans-time 
        .attr \transform -> "translate(#{it.cx},#{it.cy})"
        .style \opacity -> if it.r <= r-show => 0 else 1
      ..select \g.force-group
        ..attr \transform -> "translate(#{it.x - w / 2},#{it.y - h / 2})"
      ..select \circle 
        ..transition!duration trans-time 
          .attr \r -> it.r #if it.r > r-show
          .attr \fill -> it.fill
    d3.select \#svg .selectAll \g.text-group 
      ..attr \class -> "text-group root-group#{if it.r <= r-show-text => '' else ' active'}"
      ..transition!duration trans-time .attr \transform -> "translate(#{it.cx},#{it.cy})"
      ..select \g.force-group
        ..attr \transform -> "translate(#{it.x - w / 2},#{it.y - h / 2})"

    keys = [k for k of hash]filter(->hash[it]r > r-show)
    items = keys.map -> hash[it]
    kl = keys.length
    force.on \tick, ->
      for i from 0 til kl
        for j from 0 til kl
          if i == j => continue
          it = items[i]
          jt = items[j]
          r = it.r + jt.r
          dtx = it.x + it.cx - jt.x - jt.cx
          dty = it.y + it.cy - jt.y - jt.cy
          d = dtx * dtx + dty * dty
          if r * r > d =>
            d = Math.sqrt d
            dr = ( r - d ) / ( d * 1 );
            it.x = it.x + dtx * dr
            it.y = it.y + dty * dr
          

    force.start!
    for i from 0 to 100 => force.tick!
    force.stop!
    cgroups = d3.select \#svg .selectAll \g.circle-group.active .select \g.force-group 
      .transition!duration trans-time .attr \transform -> "translate(#{(it.x - w / 2)},#{(it.y - h / 2)})"
    tgroups = d3.select \#svg .selectAll \g.text-group.active .select \g.force-group
        .transition!duration trans-time 
          .attr \transform -> "translate(#{(it.x - w / 2)},#{(it.y - h / 2)})"
          .style \opacity -> if it.r <= r-show-text => \0 else \1

    
  idx = 79
  update = ->
    year-s := idx
    year-e := idx + 1
    idx := idx + 1
    if idx > 101 => idx := 79
    main data

  update!
  setInterval update, 5100
