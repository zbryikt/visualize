{unique, pairs-to-obj, sum, flatten, keys} = require \prelude-ls

color = d3.scale.category20!
party-color = d3.scale.ordinal!domain <[KMT DPP PFP TSU NSU NON]> .range <[#0D2393 #009900 #FF6211 #994500 #CD1659 #999999]>

constuiency-map = do
  CHA: \彰化縣
  CYI: \嘉義市
  CYQ: \嘉義縣
  HSQ: \新竹縣
  HSZ: \新竹市
  HUA: \花蓮縣
  ILA: \宜蘭縣
  KEE: \基隆市
  KHH: \高雄市
  KHQ: \高雄縣
  MIA: \苗栗縣
  NAN: \南投縣
  PEN: \澎湖縣
  PIF: \屏東縣
  TAO: \桃園縣
  TNN: \台南市
  TNQ: \台南縣
  TPE: \台北市
  TPQ: \新北市
  TTT: \台東縣
  TXG: \台中市
  TXQ: \台中縣
  YUN: \雲林縣

topo = []
<- $ document .ready
lg = {}


(data) <- d3.json \mly-8-with-sex.json
for it in data => lg[it.name] = it
(data) <- d3.json \ttsinterpellation-30.json
console.log data.entries
all-data = data.entries
all-data = all-data.map(->
  if not it.asked_by => it.asked_by = [];
  return it
)filter(->
  [lg[x] for x in it.asked_by]filter(->it)length>0
)
filter = crossfilter all-data
console.log filter.group-all!value!
asked-by-filter = filter.dimension -> it.asked_by
category-filter = filter.dimension -> it.category
topic-filter = filter.dimension -> it.topic
keywords-filter = filter.dimension -> it.keywords
party-filter = filter.dimension -> it.asked_by.map -> lg[it]party
lastname-filter = filter.dimension -> it.asked_by.map -> it.substring 0,1
sex-filter = filter.dimension -> it.asked_by.map -> lg[it]sex
constuiency-filter = filter.dimension -> it.asked_by.map -> lg[it]constuiency.0

all-keywords-hash = {}
all-keywords = flatten [it.keywords for it in all-data]
for it in all-keywords
  all-keywords-hash[it]>?=0
  all-keywords-hash[it]++
all-keywords = [{text: k, raw-size: v} for k,v of all-keywords-hash]

update = (data) ->
  category = unique [x.category for x in data]reduce(((a,b)->a ++ b),[])
  keywords = unique [x.keywords for x in data]reduce(((a,b)->a ++ b),[])
  topic    = unique [x.topic for x in data]reduce(((a,b)->a ++ b),[])
  asked-by = unique [x.asked_by for x in data]reduce(((a,b)->a ++ b),[])
  party    = unique [x.asked_by.map(->lg[it]party) for x in data]reduce(((a,b)->a ++ b),[])
  sex      = unique [x.asked_by.map(->lg[it]sex) for x in data]reduce(((a,b)->a ++ b),[])
  lastname = unique [x.asked_by.map(->it.substring(0,1)) for x in data]reduce(((a,b)->a ++ b),[])
  constuiency = unique [x.asked_by.map(->lg[it]constuiency.0) for x in data]reduce(((a,b)->a ++ b),[])

  # entries filtered by current settings
  cur-set = category-filter.top(Infinity)
  cur-num = cur-set.length

  # formatting gender group
  sex-group = sex-filter.group!top Infinity
  sex-ratio = (if sex-group.0.key.0==\男 => [0 1] else [1 0])map(->sex-group[it]value/cur-num)
  sex-ratio = sex-ratio.map -> [it, it>?0.2<?0.8]
  d3.select '#male.block' .datum sex-ratio.0
  d3.select '#female.block' .datum sex-ratio.1
  d3.selectAll '#gender .block' .each ->
    d3.select @
      ..select \img .style \width "#{it.1 * 200}px"
      ..select \.count .text "#{~~(it.0 * 100)}%"

  # formatting party group
  party-group = party-filter.group!top Infinity
  party-hash  = pairs-to-obj party-group.map -> [it.key.0, it.value/cur-num]
  #TODO: auto gen list from mly-8.json
  party-ratio = <[KMT DPP PFP TSU NSU NON]>map -> {name: it, value: party-hash[it] or 0}
  radius = 100
  pie = d3.layout.pie!sort null .value(->it.value)
  arc = d3.svg.arc!outerRadius radius/2.3 .innerRadius radius/4.5

  party-root = d3.select '#party svg' .append \g .attr \transform "translate(50 50)"
  party-root.selectAll \path.arc .data pie party-ratio
    ..exit!remove!
    ..enter!append \path .attr \class \arc
      .attr \d arc
      .attr \fill -> party-color it.data.name
  d3.select '#party .flags' .selectAll \div.flag .data party-ratio.sort((a,b) -> b.value - a.value)
    ..exit!remove!
    ..enter!append \div .attr \class \flag .each ->
      d3.select @
        ..append \i
        ..append \div .attr \class \title
  d3.select '#party .flags' .selectAll \div.flag .each ->
    d3.select @
      ..select \i .attr \class -> "g0v-icon large #{it.name}"
      ..select \.title .text -> "#{~~(100 * it.value)}%"

  # formatting locality group
  constuiency-group = constuiency-filter.group!top Infinity
  constuiency-hash = pairs-to-obj constuiency-group.map -> [constuiency-map[it.key.0], it.value]
  topo.features.map -> it.value = (constuiency-hash[it.properties.COUNTYNAME] or 0) / cur-num
  constuiency-max = d3.max [it.value for it in topo.features]
  d3.select '#county svg' .selectAll \path.county .style \fill ->
    v = ~~(it.value * 255 / constuiency-max)
    "rgba(#v,#{~~(v/2)},#{~~(v)/3}, #{0.1 + 0.9 * v / 255})"

  # formatting speaker group
  asked-by-group = asked-by-filter.group!top Infinity
  avg = sum([(1 + it.value) or 1 for it in asked-by-group]) / asked-by-group.length
  asked-by-ratio = [{name: it.key.0, value: ((1 + it.value) or 1) / avg, count: it.value} for it in asked-by-group]
  num = sum [it.value for it in asked-by-ratio]
  for it in asked-by-ratio => it.value /= num
  d3.select '#asked-by' .selectAll \div.avatar .data asked-by-ratio
    ..exit!remove!
    ..enter!append \div .attr \class \avatar .each ->
      d3.select @
        ..append \div .attr \class \img .append \img
        ..append \div .attr \class \title
        ..append \div .attr \class \times

  d3.select '#asked-by' .selectAll \div.avatar .each (d) ->
    d3.select @
      ..select \img
        .attr \src ->
          avatar = CryptoJS.MD5 "MLY/#{d.name}" .toString!
          "http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=medium"
        .style \width -> "#{d.value * 400}px"
        .style \height -> "#{d.value * 400}px"
      ..select \div.title .text -> d.name
      ..select \div.times .text -> d.count

  keywords-group = keywords-filter.group!top Infinity
  keywords-hash = {}
  for it in keywords-group
    for v in it.key
      keywords-hash[v] >?= 0
      keywords-hash[v] += it.value

  for it in all-keywords
    it.size = 10*(keywords-hash[it.text] or it.raw-size)>?20

  cloud = d3.layout.cloud!size [900,300] .words all-keywords
    .padding 0
    .rotate 0
    .font "century gothic"
    .fontSize -> it.size
  cloud
    .on \end ->
      d3.select '#keywords svg' .append \g .attr \transform "translate(450 150)" .selectAll \text.cloud .data all-keywords
        ..exit!remove!
        ..enter!append \text .attr \class \cloud
          .style \font-family "century gothic"
          .attr \text-anchor \middle
      d3.select '#keywords svg g' .selectAll \text.cloud
        .style \font-size -> "#{it.size}px"
        .style \fill (d,i) -> color i
        .attr \transform -> "translate(#{it.x},#{it.y}) rotate(#{it.rotate})"
        .text -> it.text
    .start!


d3.json \twCounty2010.topo.json, (data) ->
  topo := topojson.feature data, data.objects["twCounty2010.geo"]
  prj = d3.geo.mercator!center [120.979531, 23.978567] .scale 90000
  path = d3.geo.path!projection prj
  svg = d3.select '#county svg'
  svg.selectAll \path.county .data topo.features .enter!append \path .attr \class \county
    .attr \d path
    .style \fill -> color it.properties.COUNTYNAME
    .style \stroke \#fff
    .style \stroke-width \3px
  update category-filter.top Infinity

window.reset = ->
  constuiency-filter.filterAll!
  sex-filter.filterAll!
  lastname-filter.filterAll!
  party-filter.filterAll!
  category-filter.filterAll!
  keywords-filter.filterAll!
  topic-filter.filterAll!
  asked-by-filter.filterAll!
  update category-filter.top Infinity
