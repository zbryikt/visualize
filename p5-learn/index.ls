[w,h,m] = [640,480,10]
circles = []
setup = ->
  createCanvas 640,480
  fullscreen!
draw = ->
  rect 0,0,640,480
  if mouseIsPressed => fill 0
  else => fill 255
  ellipse mouseX, mouseY, 80, 80
  if circles.length < 15 and Math.random! >0.8 =>
    r = Math.random!*40 + 40
    x = parseInt(Math.random!*(w - 2 * m - 2 * r) + m + r)
    y = parseInt(Math.random!*(h - 2 * m - 2 * r) + m + r)
    circles.push [x, y, r, 0]
  for c in circles =>
    ellipse c.0, c.1, c.3, c.3
    c.3 = ( c.3 * 2 + c.2 * 1 ) / 3
  circles := circles.filter -> it.3 <= it.2 * 0.9999
