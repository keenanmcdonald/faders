-- faders

g = grid.connect()
local faders = {8, 8, 8, 8}
local slew = {0, 0, 0, 0}
local slewSelect = 1

function init()
  update()
end

function update()
  grid_redraw()
  update_crow()
  redraw()
end

function grid_redraw()
  g:all(0)
  for i=1, 4 do
    for j=1,faders[i] do
      g:led(17-j, 10-i*2, 10)
      g:led(17-j, 9-i*2, 10)
    end
  end
  g:refresh()
end

function enc(n, z)
  if n == 2 then
    slewSelect = util.clamp(slewSelect + z, 1, 4)
    print(slewSelect)
  elseif n == 3 then
    slew[slewSelect] = util.clamp(slew[slewSelect] + z*.1, 0, 5)
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
    screen.text(faders[i])
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
  update()
end

function update_crow()
  for i=1,4 do
    crow.output[i].volts = faders[i] * (10/16)
    crow.output[i].slew = slew[i]
  end
end
  
