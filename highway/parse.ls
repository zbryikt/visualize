require! <[fs]>
lines = fs.read-file-sync \data .toString!split \\n
miles = []
names = []
for line in lines
  ret = /(\S+) (\S+)/.exec line
  if not ret
    names.push line
    continue
  miles.push parseFloat ret.1
  names.push ret.2

price = miles.map -> parseInt(it * 12) / 10.0
price.5 = 0
price[* - 1] = 0
price[* - 2] = 0
no1 = {miles, names, price}
fs.write-file-sync \no1.json, JSON.stringify no1

sum-of-miles = (s, e) ->
  s = no1.names.indexOf s
  e = no1.names.indexOf e
  if s < 0 or e < 0 => return NaN
  ret-miles = no1.miles.slice s, e .reduce(((a,b)->a + b ),0)
  ret-price = (no1.price.slice s, e .reduce(((a,b)->a + b ),0) - 24)
  ret-price >?=0
  [ret-miles, ret-price, parseInt( ret-price * 9 ) / 10 ]

ret = sum-of-miles \汐止, \台北
console.log ret
ret = sum-of-miles \基隆端, '新竹(北)'
console.log ret

