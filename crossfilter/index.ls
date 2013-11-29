d1 = new Date!
{unique, pairs-to-obj, sum, flatten, keys} = require \prelude-ls

d41 = 0
color = d3.scale.category20!
party-color = d3.scale.ordinal!domain <[KMT DPP PFP TSU NSU NON]> .range <[#0D2393 #009900 #FF6211 #994500 #CD1659 #999999]>

constuiency-map = do
  彰化縣: \CHA
  嘉義市: \CYI
  嘉義縣: \CYQ
  新竹縣: \HSQ
  新竹市: \HSZ
  花蓮縣: \HUA
  宜蘭縣: \ILA
  基隆市: \KEE
  高雄市: \KHH
  高雄縣: \KHQ
  苗栗縣: \MIA
  南投縣: \NAN
  澎湖縣: \PEN
  屏東縣: \PIF
  桃園縣: \TAO
  台南市: \TNN
  台南縣: \TNQ
  台北市: \TPE
  新北市: \TPQ
  台東縣: \TTT
  台中市: \TXG
  台中縣: \TXQ
  雲林縣: \YUN

topo = []
<- $ document .ready
lg = {}


(data) <- d3.json \mly-8-with-sex.json
d2 = new Date!
for it in data => lg[it.name] = it
(data) <- d3.json \ttsinterpellation.compact.json
d31 = new Date!
#console.log data.entries
all-data = data.entries
all-data = all-data.map(->
  if not it.asked_by => it.asked_by = [];
  return it
)filter(->
  [lg[x] for x in it.asked_by]filter(->it)length>0
)
d32 = new Date!
filter = crossfilter all-data
asked-by-filter = filter.dimension -> it.asked_by
party-filter = filter.dimension -> it.asked_by.map -> lg[it]party
lastname-filter = filter.dimension -> it.asked_by.map -> it.substring 0,1
sex-filter = filter.dimension -> it.asked_by.map -> lg[it]sex
constuiency-filter = filter.dimension -> it.asked_by.map -> lg[it]constuiency.0
d33 = new Date!
choices = {}
choose = (f, n, v, r = null) ->
  choices[n] = v = if v==choices[n] => null else v
  if v => f.filter(r or v) else f.filterAll!
  update words.category.filter.top Infinity
choice-opacity = {true: 1.0, false: 0.2}
chosen = (n, v) -> if !choices[n] or choices[n]==v => true else false

words = {}
<[topic category keywords]>map (n) ->
  words.{}[n].hash = {}
  words[n].filter = filter.dimension -> it[n]
  words[n].list = flatten [it[n] for it in all-data]
  for it in words[n].list
    words[n].hash[it]>?=0
    words[n].hash[it]++
  words[n].list = [{text: k, raw-size: v} for k,v of words[n].hash]sort((a,b) -> b.raw-size - a.raw-size)[0 til 150].filter(->it)

d4 = new Date!
update = (data) ->
  d5 = new Date!
  /*
  # use reduce + prelude.unique : too slow
  category = unique [x.category for x in data]reduce(((a,b)->a ++ b),[])
  keywords = unique [x.keywords for x in data]reduce(((a,b)->a ++ b),[])
  topic    = unique [x.topic for x in data]reduce(((a,b)->a ++ b),[])
  asked-by = unique [x.asked_by for x in data]reduce(((a,b)->a ++ b),[])
  party    = unique [x.asked_by.map(->lg[it]party) for x in data]reduce(((a,b)->a ++ b),[])
  sex      = unique [x.asked_by.map(->lg[it]sex) for x in data]reduce(((a,b)->a ++ b),[])
  lastname = unique [x.asked_by.map(->it.substring(0,1)) for x in data]reduce(((a,b)->a ++ b),[])
  constuiency = unique [x.asked_by.map(->lg[it]constuiency.0) for x in data]reduce(((a,b)->a ++ b),[])
  */

  # don't do reduce: much faster
  /*
  unique2 = (n, h = {}) -> (for x in data => for it in x[n] or [] => h[it] = 1); [x for x of h]
  unique3 = (n, h = {}) -> (for x in data => for it in x.asked_by or [] => h[n it] = 1); [x for x of h]
  [category, keywords, topic, asked-by] = <[category keywords topic asked_by]>map -> unique2 it
  [party, sex, constuiency] = <[party sex constuiency]>map (n)->((n)->->lg[it][n]) n
  */

  # entries filtered by current settings
  cur-set = words.category.filter.top(Infinity)
  cur-num = cur-set.length

  d51 = new Date!
  # formatting gender group
  sex = {}
    ..group = sex-filter.group!top Infinity
    ..count = sum [0 1]map(-> sex.group[it]value)
    ..ratio = (if sex.group.0.key.0==\男 => [0 1] else [1 0])map(->sex.group[it]value/sex.count)
    ..ratio = sex.ratio.map -> [it, it>?0.2<?0.8]
  d3.select '#male.block' .datum sex.ratio.0
  d3.select '#female.block' .datum sex.ratio.1
  d3.selectAll '#gender .block'
    .each ->
      d3.select @
        ..select \img .style \width "#{it.1 * 200}px"
        ..select \.count .text "#{~~(it.0 * 100)}%"
    .on \click (d,i) -> choose sex-filter, \sex, <[女 男]>[i]
    .style \opacity (d,i) -> choice-opacity[chosen \sex, <[女 男]>[i]]

  d52 = new Date!
  # formatting party group

  party = do
    group: party-filter.group!top Infinity
    count: 0
    hash: {}
  for item in party.group
    for p in item.key
      if not p => p = \NON
      party.hash[p] >?= 0
      party.hash[p] += item.value
      party.count += item.value

  #TODO: auto gen list from mly-8.json
  party.ratio = <[KMT DPP PFP TSU NSU NON]>map -> {name: it, value: party.hash[it]/party.count or 0}
  radius = 100
  pie = d3.layout.pie!sort null .value(->it.value)
  arc = d3.svg.arc!outerRadius radius/2.3 .innerRadius radius/4.5
  party.root = d3.select '#party svg g'# .append \g .attr \transform "translate(50 50)"
  party.root.selectAll \path.arc .data pie party.ratio
    ..exit!remove!
    ..enter!append \path .attr \class \arc
  d3.selectAll '#party svg path.arc'
    .attr \d arc
    .attr \fill -> if chosen \party, it.data.name => party-color it.data.name else \#999
    .on \click -> choose party-filter, \party, it.data.name
    .style \opacity -> choice-opacity[chosen \party, it.data.name]
  d3.select '#party .flags' .selectAll \div.flag .data party.ratio.sort((a,b) -> b.value - a.value)
    ..exit!remove!
    ..enter!append \div .attr \class \flag .each ->
      d3.select @
        ..append \i
        ..append \div .attr \class \title
  d3.select '#party .flags' .selectAll \div.flag
    .each ->
      d3.select @
        ..select \i .attr \class -> "g0v-icon large #{it.name}"
        ..select \.title .text -> "#{~~(100 * it.value)}%"
    .on \click -> choose party-filter, \party, it.name
    .style \opacity -> choice-opacity[chosen \party, it.name]


  d53 = new Date!
  # formatting locality group
  constuiency = do
    group: constuiency-filter.group!top Infinity
    count: 0
    hash: {}
  for item in constuiency.group
    for p in item.key
      constuiency.hash[p] >?= 0
      constuiency.hash[p] += item.value
      constuiency.count += item.value
  topo.features.map ->
    it.name = constuiency-map[it.properties.COUNTYNAME]
    it.value = Math.sqrt((constuiency.hash[it.name] or 0) / constuiency.count)
  constuiency.max = d3.max [it.value for it in topo.features]
  d3.select '#county svg' .selectAll \path.county
    .style \fill ->
      v = ~~(it.value * 255 / constuiency.max)
      "rgba(#v,#{~~(v/2)},#{~~(v/3)}, #{0.5 + 0.5 * v / 255})"
    .on \click -> choose constuiency-filter, \constuiency, it.name
    .style \opacity -> choice-opacity[chosen \constuiency, it.name]

  d54 = new Date!
  # formatting speaker group
  asked-by = do
    group: asked-by-filter.group!top Infinity
    hash: {}
    count: 0
  avg = sum([(1 + it.value) or 1 for it in asked-by.group]) / asked-by.group.length
  for item in asked-by.group
    for p in item.key
      asked-by.hash[p] >?= 0
      asked-by.hash[p] += item.value
      asked-by.count += item.value
  asked-by.data = [{name: k, value: ((1 + v) or 1) / asked-by.count, count: v} for k,v of asked-by.hash]filter -> it.count
  d3.select '#asked-by' .selectAll \div.avatar .data asked-by.data
    ..exit!remove!
    ..enter!append \div .attr \class \avatar .each ->
      d3.select @
        ..append \div .attr \class \img .append \img
        ..append \div .attr \class \title
        ..append \div .attr \class \times
  d3.select '#asked-by' .selectAll \div.avatar
    .each (d) ->
      d3.select @
        ..select \img
          .attr \src ->
            avatar = CryptoJS.MD5 "MLY/#{d.name}" .toString!
            "http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=medium"
          .style \width -> "#{d.value * 400 >?15<?50}px"
          .style \height -> "#{d.value * 400 >?15<?50}px"
          .style \border -> "3px solid #{party-color lg[d.name]party}"
        ..select \div.title .text -> d.name
        ..select \div.times .text -> d.count
    .on \click -> choose asked-by-filter, \asked-by, it.name
    .style \opacity -> choice-opacity[chosen \asked-by, it.name]

  d55 = new Date!
  group = {}
  <[topic category keywords]>.map (n)->
    dd1 = new Date!
    group.{}[n]group = words[n]filter.group!top Infinity
    group[n]hash = {}
    for it in group[n]group
      for v in it.key
        group[n]hash[v] >?= 0
        group[n]hash[v] += it.value
    [group[n]max, group[n]min] = [0,99999]
    group[n]data = [{text: k, value: v} for k,v of group[n]hash]sort![0 to 99]sort -> ~~(Math.random!*2 - 1)
    group[n]list = [it.value for it in group[n]data]
    group[n] <<< {max: d3.max(group[n]list), min: d3.min group[n]list}
    /*
    # use word list from all interpellation.
    for t in words[n]list
      v = group[n]hash[t.text]
      if v =>
        group[n]max>?=v
        group[n]min<?=v
    */
    dmax = group[n]max - group[n]min
    for it in group[n]data #words[n]list
      it.size = 12 + ((it.value - group[n]min) / dmax) * 14
      #it.size = 12 + (((group[n]hash[it.text] or group[n]min) - group[n]min) / dmax) * 14
    dd2 = new Date!
    d3.select "\##{n} .desc" .selectAll \.tag .data group[n]data
      ..exit!remove!
      ..enter!append \div .attr \class \tag
    d3.selectAll "\##{n} .desc .tag" .text -> it.text
      .style \font-size -> "#{it.size}px"
      .attr \class (d,i) -> if i == group[n]data.length - 1 => "tag end" else "tag"
      .on \click (v) -> choose words[n]filter, n, v.text, (-> v.text in (it or []))
      .style \opacity -> choice-opacity[chosen n, it.text]

    /*
    # cloud is quite slow, bottleneck on getImageData. not using it for now.
    d3.layout.cloud!size [500,200] .words words[n]list
      .padding 0
      .rotate -> ~~(Math.random!*20 - 10)
      .font "century gothic"
      .fontSize -> it.size
      .on \end ->
        d3.select "\##{n} svg" .append \g .attr \transform "translate(250 100)" .selectAll \text.cloud .data words[n].list
          ..exit!remove!
          ..enter!append \text .attr \class \cloud
            .style \font-family "century gothic"
            .attr \text-anchor \middle
        d3.select "\##{n} svg g" .selectAll \text.cloud
          .style \font-size -> "#{it.size}px"
          .style \fill (d,i) -> color i
          .attr \transform -> "translate(#{it.x},#{it.y}) rotate(#{it.rotate})"
          .text -> it.text
      .start!
    */
    dd3 = new Date!
    #console.log dd2.getTime! - dd1.getTime!, dd3.getTime! - dd2.getTime!
  d6 = new Date!
  x = [d1,d2,d31,d32,d33,d4,d41,d5,d51,d52,d53,d54,d55,d6]map -> it.getTime!
  #for i in [1 to 13] => console.log i,"to",i+1, x[i] - x[i-1]

d3.json \twCounty2010.topo.json, (data) ->
  d41 := new Date!
  topo := topojson.feature data, data.objects["twCounty2010.geo"]
  prj = d3.geo.mercator!center [120.979531, 23.978567] .scale 90000
  path = d3.geo.path!projection prj
  svg = d3.select '#county svg'
  svg.selectAll \path.county .data topo.features .enter!append \path .attr \class \county
    .attr \d path
    .style \fill -> color it.properties.COUNTYNAME
    .style \stroke \#fff
    .style \stroke-width \3px
  update words.category.filter.top Infinity

window.reset = ->
  constuiency-filter.filterAll!
  sex-filter.filterAll!
  lastname-filter.filterAll!
  party-filter.filterAll!
  words.category.filter.filterAll!
  words.keywords.filter.filterAll!
  words.topic.filter.filterAll!
  asked-by-filter.filterAll!
  <[topic category keywords]>map (n) -> words[n]filter.filterAll!
  choices := {}
  update words.category.filter.top Infinity
