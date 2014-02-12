
population = {"總計":23224912,"臺灣地區":23110923,"新北市":3916451,"台北市":2650968,"台中市":2664394,"台南市":1876960,"高雄市":2774470,"宜蘭縣":459061,"桃園縣":2013305,"新竹縣":517641,"苗栗縣":562010,"彰化縣":1303039,"南投縣":522807,"雲林縣":713556,"嘉義縣":537942,"屏東縣":864529,"台東縣":228290,"花蓮縣":336838,"澎湖縣":97157,"基隆市":379927,"新竹市":420052,"嘉義市":271526,"金門縣":103883,"連江縣":10106};

party = {"新北市":"#009","台北市":"#009","台中市":"#009","台南市":"#090","高雄市":"#090","宜蘭縣":"#090","桃園縣":"#009","新竹縣":"#009","苗栗縣":"#009","彰化縣":"#009","南投縣":"#009","雲林縣":"#090","嘉義縣":"#090","屏東縣":"#090","台東縣":"#009","花蓮縣":"#999","澎湖縣":"#009","基隆市":"#009","新竹市":"#009","嘉義市":"#090","金門縣":"#009","連江縣":"#009"};

$(document).ready(function(){
  $.ajax("citizen.px").done(function(data) {
    px = new Px(data);
    value = px.metadata.VALUES["指標"];
    range = px.metadata.VALUES["期間"];
    county = px.metadata.VALUES["縣市"];
    hash = {}
    for(i=0;i<county.length;i++) {
      c = county[i].trim();
      hash[c] = px.data[county.length * range.length * 2 + county.length * (range.length - 1) + i];
      hash[c] = parseInt(hash[c]);
    }
  });
  d3.json("twCounty2010.topo.json", function(data) {
    // load data with topojson.js
    topo = topojson.feature(data, data.objects["twCounty2010.geo"]);
    
    build = function(svg, prj, path) {
      
      // render them on a svg element with id "map"
      blocks = svg.selectAll("path").data(topo.features).enter()
        .append("path").attr("d",path).attr("opacity", 0.5);

      cc = d3.scale.category20();
      // initialize population data in features
      for(i = 0; i < topo.features.length; i ++ ) {
        topo.features[i].properties.value = population[topo.features[i].properties.name]
        topo.features[i].properties.v = cc(topo.features[i].properties.name);
      }

      // create a color map from population number
      colorMap = d3.scale.linear()
        .domain([0,5000000])
        .range(["#000","#f00"]);

      // fill each path with color
      blocks.attr("fill",function(it){ 
        return it.properties.v;
      });

      // map sqrt-rooted population into circle radius
      radiusMap = d3.scale.linear()
        .domain([0,5000])
        .range([0,70]);

      // create circles
      dorling = svg.selectAll("circle").data(topo.features).enter()
        .append("circle")
        .each(function(it) { 
          // use sqrt root for correct mapping from value to area
          it.properties.r = radiusMap(Math.sqrt(it.properties.value));
          it.properties.c = centroid = path.centroid(it);
          it.properties.x = 400;
          it.properties.y = 300;
        })
        .attr("cx",function(it) { return it.properties.x + it.properties.c[0] - 400; })
        .attr("cy",function(it) { return it.properties.y + it.properties.c[1] - 300; })
        .attr("r", function(it) { return it.properties.r;})
        .attr("fill", function(it) {
          return party[it.properties.name]; 
        })
        .attr("stroke",function(it) { return it.properties.v; })
        .attr("stroke-width","2px")
        .attr("opacity", 0.55);

      // force layout, for shrink circles toward center
      forceNodes = [];
      for(i = 0 ; i < topo.features.length ; i++ ) {
        forceNodes.push(topo.features[i].properties);
      }
      force = d3.layout.force().gravity(3.0).size([800,600]).charge(-1).nodes(forceNodes);


      force.on("tick", function() {
        // collision detection, for prevent circles from overlapping
        for(i = 0 ; i < topo.features.length ; i++) {
          for(j = 0 ; j < topo.features.length ; j++) {
            it = topo.features[i].properties;
            jt = topo.features[j].properties;
            if(i==j) continue; // not collide with self
            r = it.r + jt.r;
            itx = it.x + it.c[0];
            ity = it.y + it.c[1];
            jtx = jt.x + jt.c[0];
            jty = jt.y + jt.c[1];
            d = Math.sqrt( (itx - jtx) * (itx - jtx) + (ity - jty) * (ity - jty) );
            if(r > d) { // distance smaller than radius means collision
              dr = ( r - d ) / ( d * 1 );
              it.x = it.x + ( itx - jtx ) * dr;
              it.y = it.y + ( ity - jty ) * dr;
            }
        }}

        dorling.attr("cx",function(it) { return it.properties.x + it.properties.c[0] - 400; })
               .attr("cy",function(it) { return it.properties.y + it.properties.c[1] - 300; });
      });
      force.start();
    };

    gm = {
      opt: { center: new google.maps.LatLng(23.8,121.0), zoom: 7, minZoom: 7},
      ov: new google.maps.OverlayView()
    };
    gm.map = new google.maps.Map($("#gmap")[0], gm.opt);
    gm.ov.onAdd = function() {
      gm.svg = d3.select(this.getPanes().overlayLayer).append("svg");
      prj2 = googleProjection(gm.ov.getProjection());
      path2 = d3.geo.path().projection(prj2);
      build(gm.svg, prj2, path2);
    };
    function googleProjection(prj) {
      return function(lnglat) {
        ret = prj.fromLatLngToDivPixel(new google.maps.LatLng(lnglat[1],lnglat[0]))
        return [ret.x, ret.y]
      };
    }
    gm.ov.draw = function() {
      prj2 = googleProjection(gm.ov.getProjection());
      path2 = d3.geo.path().projection(prj2);
      coord1 = prj2([120,27]);
      coord2 = prj2([130,22]);
      w = coord2[0] - coord1[0];
      h = coord2[1] - coord1[1];
      gm.svg.style("position", "absolute")
            .style("top", coord1[1])
            .style("left", coord1[0])
            .style("width", w)
            .style("height",h)
            .attr("viewBox","0 0 "+w+" "+h);
      gm.svg.selectAll("path").attr("transform","translate("+(-coord1[0])+" "+(-coord1[1])+")").attr("d",path2);
      gm.svg.selectAll("circle").attr("transform","translate("+(-coord1[0])+" "+(-coord1[1])+")")
        .each(function(it) {
          // use sqrt root for correct mapping from value to area
          it.properties.r = radiusMap(Math.sqrt(it.properties.value));
          it.properties.c = centroid = path2.centroid(it);
        })
        .attr("cx",function(it) { return it.properties.x + it.properties.c[0] - 400; })
        .attr("cy",function(it) { return it.properties.y + it.properties.c[1] - 300; });
      
    };
    gm.ov.setMap(gm.map);
    google.maps.event.addListener(gm.map, "zoom_changed", function() {
      force.start();
    });
  });
});
