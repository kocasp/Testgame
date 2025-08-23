io.stdout:setvbuf('no')

function love.load()
  math.randomseed(os.time())

  love.window.setMode(640, 640)

--Liczba trójkątów:
  NO_TRIANGLES = 80

  -- shader additions
  startTime = love.timer.getTime()
  crtShader = love.graphics.newShader("crt.glsl")
  canvas = love.graphics.newCanvas(640, 640, { type = '2d', readable = true })

  -- load move sound
  moveSound = love.audio.newSource("sounds/moveit.mp3", "static")


  --Czemu LUA nie ma enum?
  UP = "up"
  DOWN = "down"
  LEFT = "left"
  RIGHT = "right"
  EMPTY = 0
  WALL = 1
  PLAYER = 2

  movement = {}
  movement[UP] = function()
    player.y = player.y - 1
    worldmap[player.x][player.y+1] = EMPTY
    worldmap[player.x][player.y] = PLAYER 
  end
  movement[DOWN] = function()
    player.y = player.y + 1
    worldmap[player.x][player.y-1] = EMPTY
    worldmap[player.x][player.y] = PLAYER
  end
  movement[LEFT] = function()
    player.x = player.x - 1
    worldmap[player.x+1][player.y] = EMPTY
    worldmap[player.x][player.y] = PLAYER  
  end
  movement[RIGHT] = function()
    player.x = player.x + 1
    worldmap[player.x-1][player.y] = EMPTY
    worldmap[player.x][player.y] = PLAYER  
  end

  worldmap = {}
  for i = 0, 19 do 
    worldmap[i] = {}
    for j = 0, 19 do
      if(i == 0 or j == 0 or i == 19 or j == 19) then
        worldmap[i][j] = WALL
      else worldmap[i][j] = EMPTY
      end
    end
  end

  player = {
    x = 10,
    y = 10,
    act_x = 320,
    act_y = 320,
    speed = 10
  }

  triangle = {
    x,
    y,
    id,
    direction,
    speed = 10,
    act_x,
    act_y
  }

  triangle.__index = triangle

  function triangle.new(x, y, id, direction)
    local self = setmetatable({}, triangle)
    self.x = x
    self.y = y
    self.id = id
    self.direction = direction
    self.act_x = x*32
    self.act_y = y*32
    return self
  end

  tableOfTriangles = {}
  worldmap[player.x][player.y] = PLAYER
  initTriangles()
end

function getRandomNumber()
    rnd = math.random(1,2)
    if rnd == 1 then
      return math.random(1,8)
    else
      return math.random(12,19)
    end
end

function initTriangles()
  for i = 1, NO_TRIANGLES do
    randX = getRandomNumber()
    randY = getRandomNumber()
    while worldmap[randX][randY] ~= EMPTY do
      randX = getRandomNumber()
      randY = getRandomNumber()
    end
    table.insert(tableOfTriangles, triangle.new(randX, randY, i + 2, randomDirection()) )
    worldmap[randX][randY] = i + 2
  end
end  

function randomDirection()
  dir = math.random(1,4)
  if dir == 1 then
    return RIGHT
  elseif dir == 2 then
    return LEFT
  elseif dir == 3 then
    return UP
  elseif dir == 4 then
    return DOWN
  end  
end

function love.update(dt)
  player.act_x = player.act_x - ((player.act_x - (player.x * 32)) * player.speed * dt)
  player.act_y = player.act_y - ((player.act_y - (player.y * 32)) * player.speed * dt)
  
  for k, v in pairs(tableOfTriangles) do
    v.act_x = v.act_x - ((v.act_x - (v.x * 32)) * v.speed * dt)
    v.act_y = v.act_y - ((v.act_y - (v.y * 32)) * v.speed * dt)    
  end
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0, 0, 0, 1)

  love.graphics.setColor(0.878, 0.773, 0.157, 1)
  love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)
  love.graphics.setColor(1, 1, 1, 1)
  
  for i = 1, #tableOfTriangles do
    tmp = tableOfTriangles[i]
    if tmp.direction == RIGHT then
      love.graphics.polygon("fill", tmp.act_x, tmp.act_y, tmp.act_x, tmp.act_y + 32, tmp.act_x + 32, tmp.act_y +16)
    elseif tmp.direction == DOWN then
      love.graphics.polygon("fill", tmp.act_x, tmp.act_y, tmp.act_x + 32, tmp.act_y, tmp.act_x + 16, tmp.act_y +32)
    elseif tmp.direction == LEFT then
      love.graphics.polygon("fill", tmp.act_x + 32, tmp.act_y, tmp.act_x + 32, tmp.act_y + 32, tmp.act_x, tmp.act_y+16)
    elseif tmp.direction == UP then
      love.graphics.polygon("fill", tmp.act_x, tmp.act_y + 32, tmp.act_x + 32, tmp.act_y + 32, tmp.act_x + 16, tmp.act_y)
    end
  end

  for x=0, #worldmap do
    for y=0, #worldmap[x] do
      if worldmap[x][y] == 1 then
        love.graphics.rectangle("line", x * 32, y * 32, 32, 32)
      end
    end
  end

  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1)
  crtShader:send('millis', love.timer.getTime() - startTime)
  love.graphics.setShader(crtShader)
  love.graphics.draw(canvas, 0, 0)
  love.graphics.setShader()
end

function moveTriangles()
  for k, v in pairs(tableOfTriangles) do
    if v.direction == UP then
      if worldmap[v.x][v.y-1] == EMPTY then
        worldmap[v.x][v.y] = EMPTY
        v.y = v.y -1
        worldmap[v.x][v.y] = v.id
      end
      v.direction = randomDirection()
    elseif v.direction == DOWN then
      if worldmap[v.x][v.y+1] == EMPTY then
        worldmap[v.x][v.y] = EMPTY
        v.y = v.y + 1
        worldmap[v.x][v.y] = v.id
      end
      v.direction = randomDirection()
    elseif v.direction == LEFT then
      if worldmap[v.x-1][v.y] == EMPTY then
        worldmap[v.x][v.y] = EMPTY
        v.x = v.x - 1
        worldmap[v.x][v.y] = v.id
      end
      v.direction = randomDirection()
    elseif v.direction == RIGHT then
      if worldmap[v.x+1][v.y] == EMPTY then
        worldmap[v.x][v.y] = EMPTY
        v.x = v.x + 1
        worldmap[v.x][v.y] = v.id
      end
      v.direction = randomDirection()
    end
  end
end

-- helper to play overlapping sound
function playMoveSound()
  local s = moveSound:clone()
  s:play()
end

function love.keypressed(key)  
  if key == "down" then
    if (worldmap[player.x][player.y+1] ~= WALL) then
      movement[DOWN]()
      moveTriangles()
      playMoveSound()
    end
  elseif key == "up" then
    if (worldmap[player.x][player.y-1] ~= WALL) then
      movement[UP]()
      moveTriangles()
      playMoveSound()
    end
  elseif key == "left" then
    if (worldmap[player.x-1][player.y] ~= WALL) then
      movement[LEFT]()
      moveTriangles()
      playMoveSound()
    end
  elseif key == "right" then
    if (worldmap[player.x+1][player.y] ~= WALL) then
      movement[RIGHT]()      
      moveTriangles()
      playMoveSound()
    end
  end
end
