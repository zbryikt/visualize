<- $ document .ready
svg = d3.select \#svg

poi = [
  [1,"7-11",3, 1]
  [2,"全聯",1, 1]
  [2,"全家",3, 1]
  [2,"基地台",1, -1]
  [4,"捷運東門站",3, 1]
  [0,"5分", 10, 0]
  [6,"梅究醫院",3, -1]
  [7,"光光書局",1, 1]
  [10,"太平洋百貨",1, 1]
  [0,"10分", 10, 0]
  [12,"檜豹瓦斯行",3, -1]
  [14,"梅仁藥局",1, 1]
  [0,"15分", 10, 0]
  [17,"科學教育館",1, 1]
  [17,"兒童樂園",1, 1]
]
svg
  ..append \path .attr \class \road .attr \d "M150 50L150 570"
  ..append \image
    .attr \xlink:href "bad.png"
    .attr \x 75 .attr \y 25 .attr \width 32  .attr \height 32 .attr \transform "translate(-16 -16)"
  ..append \image
    .attr \xlink:href "good.png"
    .attr \x 225 .attr \y 25 .attr \width 32  .attr \height 32 .attr \transform "translate(-16 -16)"
y = d3.scale.ordinal!domain [x.1 for x in poi] .rangePoints [55 570]
poi-class = -> [
  "poi"
  "vip" if it.2>2
  "pos" if it.3>0
  "neg" if it.3<0
  "neu" if it.3==0
  ]filter(->it) * " "

svg.selectAll \circle.poi .data poi
  ..enter!append \g
    ..append \circle .attr \class poi-class
      .attr \cx 150
      .attr \cy -> v = y it.1
      .attr \r -> 2 + it.2
    ..append \text .attr \class poi-class
      .attr \x ->
        if it.3==0 => 150 else if it.3>0 => 225 else 75
      .attr \y -> y it.1
      .attr \text-anchor \middle
      .attr \dominant-baseline \central
      .text -> it.1
