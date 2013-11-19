// Generated by LiveScript 1.2.0
$(document).ready(function(){
  var maxOverall, max, min, count;
  maxOverall = 0;
  max = {};
  min = {};
  count = 0;
  return d3.csv('data.csv', function(data){
    var mgn, dlist, keyList, yrList, i$, len$, item, key, v, res$, k, sx, sy, xy, xx, color, show;
    mgn = [50, 80, 90, 50];
    console.log(data);
    dlist = [];
    keyList = {};
    yrList = {};
    for (i$ = 0, len$ = data.length; i$ < len$; ++i$) {
      item = data[i$];
      for (key in item) {
        if (deepEq$(key, "年", '===') || deepEq$(key, "總計", '===')) {
          continue;
        }
        v = parseInt(10 * Math.sqrt(parseInt(item[key] / 10000))) / 10.0;
        maxOverall >= v || (maxOverall = v);
        max[key] >= v || (max[key] = v);
        min[key] <= v || (min[key] = v);
        keyList[key] = 1;
        yrList[item["年"]] = 1;
        dlist.push([item["年"], key, v]);
      }
    }
    dlist.sort(function(a, b){
      return parseInt(Math.random() * 3 - 1);
    });
    res$ = [];
    for (k in keyList) {
      res$.push(k);
    }
    keyList = res$;
    res$ = [];
    for (k in yrList) {
      res$.push(k);
    }
    yrList = res$;
    sx = d3.scale.ordinal().domain(yrList).rangePoints([mgn[0], 800 - mgn[2]]);
    sy = d3.scale.ordinal().domain(keyList).rangePoints([mgn[1], 500 - mgn[3]]);
    xy = d3.svg.axis().scale(sy).orient('left').tickValues(keyList).tickPadding(0);
    xx = d3.svg.axis().scale(sx).orient('top').tickValues(yrList).tickPadding(0);
    color = d3.scale.category20b();
    show = function(){
      var d, ref$, x, y, radius, radiusAll, e, f, setHandle, i$, to$, i, results$ = [];
      if (count >= dlist.length) {
        return;
      }
      d = dlist[count];
      ref$ = [sx(d[0]), sy(d[1])], x = ref$[0], y = ref$[1];
      radius = 20 * ((d[2] - min[d[1]]) / (max[d[1]] - min[d[1]])) + 2;
      radiusAll = 20 * (d[2] / maxOverall) + 2;
      e = d3.select('#svg').append('circle');
      e.attr('cx', x).attr('cy', y).attr('r', 0).attr('fill', 'none').attr('stroke', function(){
        return color(d[1] + 1);
      }).attr('stroke-width', '1px').transition().ease('elastic').duration(500).attr('r', radiusAll);
      e = d3.select('#svg').append('circle');
      e.attr('cx', x).attr('cy', y).attr('r', 0).style('opacity', '0.5').attr('fill', function(){
        return color(d[1]);
      }).transition().ease('elastic').duration(500).attr('r', radius);
      f = d3.select('#svg').append('text').text(function(){
        return parseInt(d[2] * d[2]);
      }).attr('text-anchor', 'middle').attr('x', x).attr('fill', '#f00');
      setHandle = function(e, f, x, y, r){
        e.on('click', function(){
          return f.attr('y', y).style('opacity', 1).transition().ease('bounce').duration(500).style('opacity', 0).attr('y', function(){
            return y - 20;
          });
        });
        return e.on('mouseover', function(){
          return e.attr('r', function(){
            return r + 5;
          }).transition().ease('bounce').duration(500).attr('r', function(){
            return r;
          });
        });
      };
      setHandle(e, f, x, y, radius);
      count = count + 1;
      for (i$ = 0, to$ = parseInt(Math.random() * 2); i$ <= to$; ++i$) {
        i = i$;
        results$.push(setTimeout(show, parseInt(Math.random() * 700)));
      }
      return results$;
    };
    d3.select('#svg').append('g').attr('class', 'yaxis').attr('transform', "translate(780 0)").call(xy);
    d3.select('#svg').append('g').attr('class', 'xaxis').attr('transform', "translate(0 40)").call(xx);
    return show();
  });
});
function deepEq$(x, y, type){
  var toString = {}.toString, hasOwnProperty = {}.hasOwnProperty,
      has = function (obj, key) { return hasOwnProperty.call(obj, key); };
  var first = true;
  return eq(x, y, []);
  function eq(a, b, stack) {
    var className, length, size, result, alength, blength, r, key, ref, sizeB;
    if (a == null || b == null) { return a === b; }
    if (a.__placeholder__ || b.__placeholder__) { return true; }
    if (a === b) { return a !== 0 || 1 / a == 1 / b; }
    className = toString.call(a);
    if (toString.call(b) != className) { return false; }
    switch (className) {
      case '[object String]': return a == String(b);
      case '[object Number]':
        return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
      case '[object Date]':
      case '[object Boolean]':
        return +a == +b;
      case '[object RegExp]':
        return a.source == b.source &&
               a.global == b.global &&
               a.multiline == b.multiline &&
               a.ignoreCase == b.ignoreCase;
    }
    if (typeof a != 'object' || typeof b != 'object') { return false; }
    length = stack.length;
    while (length--) { if (stack[length] == a) { return true; } }
    stack.push(a);
    size = 0;
    result = true;
    if (className == '[object Array]') {
      alength = a.length;
      blength = b.length;
      if (first) { 
        switch (type) {
        case '===': result = alength === blength; break;
        case '<==': result = alength <= blength; break;
        case '<<=': result = alength < blength; break;
        }
        size = alength;
        first = false;
      } else {
        result = alength === blength;
        size = alength;
      }
      if (result) {
        while (size--) {
          if (!(result = size in a == size in b && eq(a[size], b[size], stack))){ break; }
        }
      }
    } else {
      if ('constructor' in a != 'constructor' in b || a.constructor != b.constructor) {
        return false;
      }
      for (key in a) {
        if (has(a, key)) {
          size++;
          if (!(result = has(b, key) && eq(a[key], b[key], stack))) { break; }
        }
      }
      if (result) {
        sizeB = 0;
        for (key in b) {
          if (has(b, key)) { ++sizeB; }
        }
        if (first) {
          if (type === '<<=') {
            result = size < sizeB;
          } else if (type === '<==') {
            result = size <= sizeB
          } else {
            result = size === sizeB;
          }
        } else {
          first = false;
          result = size === sizeB;
        }
      }
    }
    stack.pop();
    return result;
  }
}