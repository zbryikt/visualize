{unique} = require \prelude-ls
<- $ document .ready
lg = {}
(data) <- d3.json \mly-8-with-sex.json
for it in data => lg[it.name] = it
(data) <- d3.json \ttsinterpellation.json
console.log data.entries
filter = crossfilter data.entries
console.log filter.group-all!value!
asked-by-filter = filter.dimension -> it.asked_by
category-filter = filter.dimension -> it.category
topic-filter = filter.dimension -> it.topic
keywords-filter = filter.dimension -> it.keywords
party-filter = filter.dimension -> it.asked_by.map -> lg[it]party
lastname-filter = filter.dimension -> it.asked_by.map -> it.substring 0,1
sex-filter = filter.dimension -> it.asked_by.map -> lg[it]sex
constuiency-filter = filter.dimension -> it.asked_by.map -> lg[it]constuiency.0

update = (data) ->
  category = unique [x.category for x in data]reduce(((a,b)->a ++ b),[])
  keywords = unique [x.keywords for x in data]reduce(((a,b)->a ++ b),[])
  topic    = unique [x.topic for x in data]reduce(((a,b)->a ++ b),[])
  asked-by = unique [x.asked_by for x in data]reduce(((a,b)->a ++ b),[])
  party    = unique [x.asked_by.map(->lg[it]party) for x in data]reduce(((a,b)->a ++ b),[])
  sex      = unique [x.asked_by.map(->lg[it]sex) for x in data]reduce(((a,b)->a ++ b),[])
  lastname = unique [x.asked_by.map(->it.substring(0,1)) for x in data]reduce(((a,b)->a ++ b),[])
  constuiency = unique [x.asked_by.map(->lg[it]constuiency.0) for x in data]reduce(((a,b)->a ++ b),[])
  d3.select \#constuiency .selectAll \div.constuiency .data constuiency
    ..exit!remove!
    ..enter!append \div .attr \class \constuiency
      .on \click (v) ->
        constuiency-filter.filter -> v in it
        update constuiency-filter.top Infinity
  d3.select \#sex .selectAll \div.sex .data sex
    ..exit!remove!
    ..enter!append \div .attr \class \sex
      .on \click (v) ->
        sex-filter.filter -> v in it
        update sex-filter.top Infinity
  d3.select \#lastname .selectAll \div.lastname .data lastname
    ..exit!remove!
    ..enter!append \div .attr \class \lastname
      .on \click (v) ->
        lastname-filter.filter -> v in it
        update lastname-filter.top Infinity
  d3.select \#party .selectAll \i.party .data party
    ..exit!remove!
    ..enter!append \i .attr \class \party
      .on \click (v) ->
        party-filter.filter -> v in it
        update party-filter.top Infinity
  d3.select \#category .selectAll \div.category .data category
    ..exit!remove!
    ..enter!append \div .attr \class \category
      .on \click (v) ->
        category-filter.filter -> v in it
        update category-filter.top Infinity
  d3.select \#keywords .selectAll \div.keywords .data keywords
    ..exit!remove!
    ..enter!append \div .attr \class \keywords
      .on \click (v) ->
        keywords-filter.filter -> v in it
        update keywords-filter.top Infinity
  d3.select \#topic .selectAll \div.topic .data topic
    ..exit!remove!
    ..enter!append \div .attr \class \topic
      .on \click (v) ->
        topic-filter.filter -> v in it
        update topic-filter.top Infinity
  d3.select \#asked-by .selectAll \div.asked-by .data asked-by
    ..exit!remove!
    ..enter!append \div .attr \class \asked-by
      .on \click (v) ->
        asked-by-filter.filter -> v in it
        update asked-by-filter.top Infinity
  d3.selectAll \div.constuiency .text -> it
  d3.selectAll \div.sex .text -> it
  d3.selectAll \div.lastname .text -> it
  d3.selectAll \i.party .attr \class -> "g0v-icon large party #{it}"
  d3.selectAll \div.category .text -> it
  d3.selectAll \div.keywords .text -> it
  d3.selectAll \div.topic .text -> it
  d3.selectAll \div.asked-by .text -> it
  cur-set = category-filter.top(Infinity)
  cur-num = cur-set.length

  sex-group = sex-filter.group!top Infinity

  $ "\#male img" .width "#{100 * sex-group[if sex-group.0.key.0==\男 => 0 else 1]value / cur-num}px"
  $ "\#female img" .width "#{100 * sex-group[if sex-group.0.key.0==\男 => 1 else 0]value / cur-num}px"

update category-filter.top Infinity
/*set-timeout ->
  asked-by.filter \吳育仁
  update category.top Infinity

, 1000*/

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
