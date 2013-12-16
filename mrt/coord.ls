# forumal adopted from 
# http://blog.ez2learn.com/2009/08/15/lat-lon-to-twd97/
# http://sask989.blogspot.tw/2012/05/wgs84totwd97.html
# example
#   coord.to-twd97 {lat: 25.040280669021932, lng: 121.50378056709678}
#   coord.to-gws84 300835.44, 2770333.73

coord =
  a: 6378137.0
  b: 6356752.3142451
  k0: 0.9999
  dx: 250000
  dy: 0
  lng0: 121 * Math.PI / 180
  init: ->
    {a,b} = @
    @e = 1 - Math.pow(b, 2) / Math.pow(a, 2)
    @e2 = (1 - Math.pow(b, 2) / Math.pow(a, 2)) / (Math.pow(b, 2) / Math.pow(a, 2))
    @init = null

  rad: -> it * Math.PI / 180
  to-gws84: (x, y) ->
    if @init => @init!
    {a,b,k0,dx,dy,lng0,e,e2} = @
    {sin,cos,tan} = Math
    x -= dx
    y -= dy

    # Calculate the Meridional Arc
    M = y / k0

    # Calculate Footprint Latitude
    mu = M / (a * (1.0 - e / 4.0 - 3 * Math.pow(e, 2) / 64.0 - 5 * Math.pow(e, 3) / 256.0))
    e1 = (1.0 - Math.sqrt(1.0 - e)) / (1.0 + Math.sqrt(1.0 - e))

    J1 = (3 * e1 / 2 - 27 * Math.pow(e1, 3) / 32.0)
    J2 = (21 * Math.pow(e1, 2) / 16 - 55 * Math.pow(e1, 4) / 32.0)
    J3 = (151 * Math.pow(e1, 3) / 96.0)
    J4 = (1097 * Math.pow(e1, 4) / 512.0)

    fp = mu + J1 * Math.sin(2 * mu) + J2 * Math.sin(4 * mu) + J3 * Math.sin(6 * mu) + J4 * Math.sin(8 * mu)

    # Calculate Latitude and Longitude
    C1 = e2 * Math.pow(Math.cos(fp), 2)
    T1 = Math.pow(Math.tan(fp), 2)
    R1 = a * (1 - e) / Math.pow((1 - e * Math.pow(Math.sin(fp), 2)), (3.0 / 2.0))
    N1 = a / Math.pow((1 - e * Math.pow(Math.sin(fp), 2)), 0.5)

    D = x / (N1 * k0)

    # 計算緯度
    Q1 = N1 * Math.tan(fp) / R1
    Q2 = (Math.pow(D, 2) / 2.0)
    Q3 = (5 + 3 * T1 + 10 * C1 - 4 * Math.pow(C1, 2) - 9 * e2) * Math.pow(D, 4) / 24.0
    Q4 = (61 + 90 * T1 + 298 * C1 + 45 * Math.pow(T1, 2) - 3 * Math.pow(C1, 2) - 252 * e2) * Math.pow(D, 6) / 720.0
    lat = fp - Q1 * (Q2 - Q3 + Q4)

    # 計算經度
    Q5 = D
    Q6 = (1 + 2 * T1 + C1) * Math.pow(D, 3) / 6
    Q7 = (5 - 2 * C1 + 28 * T1 - 3 * Math.pow(C1, 2) + 8 * e2 + 24 * Math.pow(T1, 2)) * Math.pow(D, 5) / 120.0
    lng = lng0 + (Q5 - Q6 + Q7) / Math.cos(fp)

    lat = (lat * 180) / Math.PI # 緯度
    lng = (lng * 180) / Math.PI # 經度

    {lat, lng}

  to-twd97: ({lat, lng}) ->
    if @init => @init!
    {a,b,k0,dx,dy,lng0,e,e2} = @
    {sin,cos,tan} = Math
    [lat,lng] = [@rad(lat), @rad(lng)]

    e = (1 - b**2/a**2)**0.5
    e2 = e**2/(1 - e**2)
    n = (a - b)/(a + b)
    nu = a/(1 - (e**2)*(sin(lat)**2))**0.5
    p = lng - lng0

    A = a*(1 - n + (5/4.0)*(n**2 - n**3) + (81/64.0)*(n**4  - n**5))
    B = (3*a*n/2.0)*(1 - n + (7/8.0)*(n**2 - n**3) + (55/64.0)*(n**4 - n**5))
    C = (15*a*(n**2)/16.0)*(1 - n + (3/4.0)*(n**2 - n**3))
    D = (35*a*(n**3)/48.0)*(1 - n + (11/16.0)*(n**2 - n**3))
    E = (315*a*(n**4)/51.0)*(1 - n)

    S = A*lat - B*sin(2*lat) + C*sin(4*lat) - D*sin(6*lat) + E*sin(8*lat)

    K1 = S*k0
    K2 = k0*nu*sin(2*lat)/4.0
    K3 = (k0*nu*sin(lat)*(cos(lat)**3)/24.0) *
        (5 - tan(lat)**2 + 9*e2*(cos(lat)**2) + 4*(e2**2)*(cos(lat)**4))

    y = K1 + K2*(p**2) + K3*(p**4)

    K4 = k0*nu*cos(lat)
    K5 = (k0*nu*(cos(lat)**3)/6.0) *
        (1 - tan(lat)**2 + e2*(cos(lat)**2))

    x = K4*p + K5*(p**3) + dx
    return [x, y]

