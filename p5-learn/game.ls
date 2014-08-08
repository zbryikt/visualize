[w,h,m] = [800,600,10]
circles = []
bp = []
ep = []
pp = {x: 0, y: h - m - 10}
score = 0
setup = ->
  createCanvas w,h
  fullscreen!


enemy = (v) ->
  stroke 255,0,0
  beginShape!
  vertex v.x - v.r, v.y - v.r
  vertex v.x, v.y + v.r
  vertex v.x + v.r, v.y - v.r
  vertex v.x - v.r, v.y - v.r
  endShape \Close

bullet = (v) ->
  fill 0
  stroke 0
  ellipse v.x, v.y, v.r, v.r
player = ->
  stroke 0,128,0
  beginShape!
  vertex pp.x - 10, pp.y + 10
  vertex pp.x, pp.y - 10
  vertex pp.x + 10, pp.y + 10
  vertex pp.x - 10, pp.y + 10
  endShape \Close

mouseMoved = ->
  pp.x = mouseX

mousePressed = ->
  bp ++= [{x: pp.x, y: pp.y - 10, r: 5}]

scoring = ->
  textSize 32
  text "score: #score", 10, 40

draw = ->
  rect 0,0,w,h
  scoring!
  player!
  for b in bp =>
    bullet b
    b.y -= 5

  for e in ep =>
    enemy e
    e.y += 5

  if ep.length < 15 and Math.random! >0.9 =>
    r = Math.random!*10 + 10
    x = parseInt(Math.random!*(w - 2 * m - 2 * r) + m + r)
    y = m + 10
    ep.push {x,y,r}

  for b in bp =>
    for e in ep =>
      if Math.sqrt((b.x - e.x)**2 + (b.y - e.y)**2) < e.r =>
        e.die = 1
        b.die = 1
        score := score + 10
  for e in ep =>
      if Math.sqrt((pp.x - e.x)**2 + (pp.y - e.y)**2) < e.r => 
        noLoop!
        text "Game Over", w/2 - 50, h/2

  ep := ep.filter -> it.y <= ( h - m ) and !it.die
  bp := bp.filter -> it.y <= ( h - m ) and !it.die

