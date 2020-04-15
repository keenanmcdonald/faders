-- faders

g = grid.connect()
local faders = {8, 8, 8, 8}
local voltsOut = {5, 5, 5, 5}
local slew = {0, 0, 0, 0}
local slewSelect = 1

function init()
  for i = 1,4 do
    crow.output[i].receive = function(v) outs(i,v) end
  end
  
  r = metro.init()
  r.time = 0.01
  r.event = function()
    for i = 1,4 do
      crow.output[i].query()
    end
    redraw()
    grid_redraw()
  end
  r:start()
  update_crow()
end

function outs(i, v)
  voltsOut[i] = v
end

function update()
  grid_redraw()
  update_crow()
  redraw()
end

function grid_redraw()
  g:all(0)
  for i=1, 4 do
    drawFader(i)
  end
  g:refresh()
end

function drawFader(i)
  height = math.floor(voltsOut[i] / (10/16))
  remainder = voltsOut[i] % (10/16)
  brightness = math.floor(remainder*12)
  for j=1,height do
    g:led(17-j, 10-i*2, 12)
    g:led(17-j, 9-i*2, 12)
  end
  g:led(16-height, 10-i*2, brightness)
  g:led(16-height, 9-i*2, brightness)
end  

function enc(n, z)
  if n == 2 then
    slewSelect = util.clamp(slewSelect + z, 1, 4)
    print(slewSelect)
  elseif n == 3 then
    if slew[slewSelect] <= 1 then
      slew[slewSelect] = util.clamp(slew[slewSelect] + z*.01, 0, 25)
    elseif slew[slewSelect] <= 5 then
      slew[slewSelect] = util.clamp(slew[slewSelect] + z*.05, 0, 25)
    else
      slew[slewSelect] = util.clamp(slew[slewSelect] + z*.1, 0, 25)
    end
  end
  update()
end


function key(n, z)
  if n == 2 and z == 1 then
    crow.output[1].query()
  end
end

function redraw()
  screen.clear()
  screen.level(15)
  for i=1,4 do
    x = (i-1)*34
    screen.move(x, 10)
    screen.text(tostring(i))
    screen.move(x,20)
    screen.text('v: ')
    screen.text(math.floor(voltsOut[i]*10)*0.1)
    screen.move(x,30)
    screen.text('s: ')
    screen.text(slew[i])
    if slewSelect == i then
      screen.move(x,40)
      screen.line(x+20, 40)
      screen.stroke()
    end
  end
  screen.update()
end

g.key = function(x,y,z)
  if z==1 then
    if y <= 2 then
      if faders[4] ==1 then
        faders[4] = 0
      else
        faders[4] = 17-x
      end
    elseif y <= 4 then
      if faders[3] ==1 then
        faders[3] = 0
      else
        faders[3] = 17-x
      end
    elseif y <= 6 then
      if faders[2] ==1 then
        faders[2] = 0
      else
        faders[2] = 17-x
      end
    elseif y <= 8 then
      if faders[1] ==1 then
        faders[1] = 0
      else
        faders[1] = 17-x
      end
    end
  end
  update()
end

function update_crow()
  for i=1,4 do
    crow.output[i].volts = faders[i] * (10/16)
    crow.output[i].slew = slew[i]
  end
end
  
