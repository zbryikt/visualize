// Generated by LiveScript 1.2.0
var fs, lines, miles, names, i$, len$, line, ret, price, no1, sumOfMiles;
fs = require('fs');
lines = fs.readFileSync('data').toString().split('\n');
miles = [];
names = [];
for (i$ = 0, len$ = lines.length; i$ < len$; ++i$) {
  line = lines[i$];
  ret = /(\S+) (\S+)/.exec(line);
  if (!ret) {
    names.push(line);
    continue;
  }
  miles.push(parseFloat(ret[1]));
  names.push(ret[2]);
}
price = miles.map(function(it){
  return parseInt(it * 12) / 10.0;
});
price[5] = 0;
price[price.length - 1] = 0;
price[price.length - 2] = 0;
no1 = {
  miles: miles,
  names: names,
  price: price
};
fs.writeFileSync('no1.json', JSON.stringify(no1));
sumOfMiles = function(s, e){
  var retMiles, retPrice;
  s = no1.names.indexOf(s);
  e = no1.names.indexOf(e);
  if (s < 0 || e < 0) {
    return NaN;
  }
  retMiles = no1.miles.slice(s, e).reduce(function(a, b){
    return a + b;
  }, 0);
  retPrice = no1.price.slice(s, e).reduce(function(a, b){
    return a + b;
  }, 0) - 24;
  retPrice >= 0 || (retPrice = 0);
  return [retMiles, retPrice, parseInt(retPrice * 9) / 10];
};
ret = sumOfMiles('汐止', '台北');
console.log(ret);
ret = sumOfMiles('基隆端', '新竹(北)');
console.log(ret);