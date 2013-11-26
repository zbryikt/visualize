(data) <- d3.json \twCounty2010.topo.json

topo = topojson.feature data, data.objects["twCounty2010.geo"]
topomesh = topojson.mesh data, data.objects["twCounty2010.geo"], (a,b) -> a!=b

[w,h] = [400 600]
m = [20 20 20 20]

# use mercator project (from latlng to point)
prj = d3.geo.mercator!center [120.979531, 23.978567] .scale 50000

# given a dataset and projection func, convert to svg path d parameter
path = d3.geo.path!projection prj

svg1 = d3.select \body .append \svg
  .attr \width w .attr \height h .attr \viewBox "0 0 800 600" .attr \preserveAspectRatio \xMidYMid
svg2 = d3.select \body .append \svg
  .attr \width w .attr \height h .attr \viewBox "0 0 800 600" .attr \preserveAspectRatio \xMidYMid

# render as a whole
svg1.append \text .attr \x 400 .attr \y 0 .attr \font-size \30px .text "render as a whole"
svg1.append \path .datum topo
  .attr \d path
  .style \fill \none
  .style \stroke \#f00

# render by individual blocks
svg2.append \text .attr \x 400 .attr \y 0 .attr \font-size \30px .text "render by individual blocks"
svg2.selectAll \path.county .data topo.features .enter!append \path
  .attr \d path
  .style \fill \999
  .style \stroke \none
  .style \opacity 0.2

# render boundary
svg2.append \path .attr \class \boundary .datum topomesh
  .attr \d path
  .style \fill \none
  .style \stroke "rgba(0,0,0,0.5)"
  .style \stroke-width \1px
