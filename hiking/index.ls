<- $ document .ready

sum = -> it.reduce(((a,b)->a+b),0)
d3.json \hiking.json, (data) ->
  margin = [10 0 10 40]
  dim = [300,200,300 - margin.1 - margin.3, 200 - margin.0 - margin.2]
  yfish = d3.fisheye.scale d3.scale.identity .domain [0 dim.1] .focus 0
  dlist = [k for k of data]map -> data[it]
  max-dist = d3.max dlist.map(-> it.totalDist)
  max-time = d3.max dlist.map -> it.totalTime
  count = dlist.length
  hite = dim.3 / (count * 2 - 1)

  svg = d3.select \#content .append \svg
    .attr \width \100% .attr \height \100% .attr \viewBox "0 0 #{dim.0} #{dim.1}"
    .attr \preserveAspectRatio "xMidYMid"
    .on \mousemove ->
      m = d3.mouse @
      yfish.focus m.1
      redraw!
  last-hover = null
  extend = (root) ->
    if last-hover => shrink last-hover
    last-hover := root
    if not root => return
    d3.select root
      ..selectAll \rect.bar
        .transition!duration 500 .attr \width -> "#{dim.2}px"
      ..selectAll \text.time
        .transition!duration 500 .attr \x -> "#{hite + dim.2}px"
      ..selectAll \text.length
        .transition!duration 500 .attr \x -> "#{hite + dim.2}px"
      ..selectAll \rect.poi
        .transition!duration 500 .attr \x -> "#{dim.2 * ( it.1 / it.3 ) - 2}px"
      ..selectAll \text.dis
        .transition!duration 500 .attr \x -> "#{dim.2 * (it.0 +  it.1 / 2) / it.5}px"
      ..selectAll \g.poi-name
        .transition!duration 500 .attr \transform -> "translate(#{dim.2 * ( it.1 / it.3 ) - 2} 0)"
  wrap = (obj, init=false) ->
    if init => obj else obj.transition!duration 500
  shrink = (root, init=false) ->
    root = d3.select root
    wrap root.selectAll(\rect.bar), init
      .attr \width -> "#{dim.2 * (it.totalDist / max-dist)}px"
    wrap root.selectAll(\text.time), init
      .attr \x -> "#{hite + dim.2 * (it.totalDist / max-dist)}px"
    wrap root.selectAll(\text.length), init
      .attr \x -> "#{hite + dim.2 * (it.totalDist / max-dist)}px"
    wrap root.selectAll(\rect.poi), init
      .attr \x -> "#{dim.2 * ( it.1 / max-dist ) - 2}px"
    wrap root.selectAll(\text.dis), init
      .attr \x -> "#{dim.2 * (it.0 +  it.1 / 2) / max-dist}px"
    wrap root.selectAll(\g.poi-name), init
      .attr \transform -> "translate(#{dim.2 * ( it.1 / max-dist ) - 2} 0)"
    #wrap root.selectAll(\text.poi), init
    #  .attr \x -> "#{dim.2 * ( it.1 / max-dist ) - 2}px"


  svg.selectAll \g.path .data dlist
    ..exit!remove!
    ..enter!append \g .attr \class \path
      ..on \mouseover -> extend @
      ..attr \transform (d,i) ->
        "translate(#{margin.3},0)"
      ..append \rect .attr \class \bar
      ..append \text .attr \class \name
        .attr \x -> -hite
        .text -> it.name
      ..append \text .attr \class \length
        .style \fill \#600
        .attr \text-anchor \start
        .text -> "#{it.totalDist}公里"
      ..append \text .attr \class \time
        .style \fill \#600
        .attr \text-anchor \start
        .text -> "#{it.totalTime}分鐘"
      ..each (it,idx) ->
        j = 0
        dst = sum: it.totalDist #sum(it.dist)
        dst.pct = it.dist.map(-> it/dst.sum)map(-> it>?=0.2)
        dst.rsm = sum(dst.pct.filter(->it>0.2))
        dst.ret = dst.pct.map (x) -> parseInt((if x>0.2 => x*dst.rsm*dst.sum else x*dst.sum)*10)/10.0
        dst.ret = it.dist
        acc = [0] ++ for i in dst.ret => j = parseInt( 100 * (j + i))/100.0
        dstsum = dst.sum
        acc-dis = dst.ret.map (d,i) -> [acc[i], d, it.time[i], idx, 0, dstsum]
        console.log acc-dis
        max-len = it.totalDist
        acc-poi = it.poi.map (d,i) -> [d, acc[i], idx, dst.sum]
        d3.select @ .selectAll \g.poi .data acc-poi .enter!append \rect .attr \class \poi
          .attr \width \2px
          .attr \fill \#caa
          .attr \stroke \#b00
        d3.select @ .selectAll \g.dis .data acc-dis .enter!append \text .attr \class \dis
          .text -> "#{it.1}k"
          .attr \fill \#fff
        d3.select @ .selectAll \g.poi-name .data acc-poi .enter!append \g .attr \class \poi-name
          .append \g .attr \class \poi-name-inner
            ..append \rect .attr \class \poi-name
              .attr \x -> "#{ -it.0.length * 2.5 - 4 }px"
              .attr \y \-7px
              .attr \rx \1px .attr \ry \1px
              .attr \width -> "#{(it.0.length * 5) + 8}px"
              .attr \height \10.5px
            ..append \text .attr \class \poi-name
              .text -> "#{it.0}"
              .attr \fill \#700
              .attr \font-size \5px

        shrink @, true

  svg.on \mouseout -> extend null
  yy = (i, d) -> yfish hite + margin.0 + i * 2 * hite + d
  redraw = ->
    svg.selectAll \rect.bar
      .attr \y (d,i) -> "#{yy i,0}px"
      .attr \height (d,i) -> "#{yy(i,hite) - yy(i,0)}px"
      .attr \rx (d,i) -> "#{(yy(i,hite) - yy(i,0))* 0.1}px"
      .attr \ry (d,i) -> "#{(yy(i,hite) - yy(i,0))* 0.1}px"
      .attr \fill (d,i) ->
        v = parseInt((yy(i,hite) - yy(i,0))*50)
        v<?=255
        "rgba(#{v},0,#{i*10},1)"

    svg.selectAll \text.name
      .attr \y (d,i) ->
        fs = (yy(i,hite*0.8) - yy(i,hite * 0.2))
        fs <?= 10
        fs = fs/2
        "#{yy(i,hite*0.5)+fs}"
      .attr \font-size (d,i) ->
        fs = (yy(i,hite*0.8) - yy(i,hite * 0.2))
        fs <?= 10
        "#{fs}px"
      .attr \fill (d,i) ->
        v = parseInt((yy(i,hite) - yy(i,0))*50)
        v<?=255
        "rgba(#{v},0,#{i*10},1)"

    svg.selectAll \text.time
      .attr \y (d,i) ->
        #fs = (yy(i,hite*0.8) - yy(i,hite * 0.2))
        #fs <?= 10
        #fs = fs/2
        "#{yy(i,hite*0.5 - 1)}"
      .attr \font-size (d,i) ->
        fs = (yy(i,hite*0.8) - yy(i,hite * 0.2))
        fs <?= 2
        "#{fs}px"
    svg.selectAll \text.length
      .attr \y (d,i) ->
        fs = (yy(i,hite*0.8) - yy(i,hite * 0.2))
        fs <?= 10
        fs = fs / 2
        "#{yy(i,hite*0.5)+ 1 + fs}"
      .attr \font-size (d,i) ->
        fs = (yy(i,hite*0.8) - yy(i,hite * 0.2))
        fs <?= 10
        "#{fs}px"

    svg.selectAll \rect.poi
      .attr \y (d,i) -> "#{yy d.2,0}px"
      .attr \height (d,i) -> "#{yy(d.2,hite) - yy(d.2,0)}px"
      .attr \stroke-width (d,i) ->
        v = (yy(d.2,hite) - yy(d.2,0))*0.05
        v >?= 0.8
        "#{v}px"
    svg.selectAll \g.poi-name-inner
      .attr \transform (d,i) ->
        v = [-hite/3 + 1.5, hite + 1, -1, 2 + 4*hite/3][i%4]
        "translate(0 #{yy d.2, v})"
      .style \opacity (d,i)->
        v = (yy(d.2,hite) - yy(d.2,0))
        v = v * 0.065
        v<?=1
        if v<0.8 => v=0
        v
    svg.selectAll \text.dis
      .each (d,i) ->
        d.4 = (yy(d.3,hite) - yy(d.3,0))
      .style \opacity (d,i)->
        v = d.4 * 0.08
        v<?=1
        if v<0.4 => v=0
        v
      .attr \font-size (d,i) ->
        v = d.4 * 0.2
        v <?= 30
        "#{v}px"
      .attr \y (d,i) ->
        v = d.4 * 0.2
        v <?= 3
        r = if i%2 => [1 2] else [2 1]
        "#{v/2 + (r.0 * yy(d.3,hite) + r.1 * yy(d.3,0))/3}px"

  redraw!
