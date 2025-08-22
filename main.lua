io.stdout:setvbuf('no')

function love.load()
  love.window.setMode(640, 640)

--Liczba trójkątów:
  NO_TRIANGLES = 20

--Czemu LUA nie ma enum?
  UP = "up"
  DOWN = "down"
  LEFT = "left"
  RIGHT = "right"
  EMPTY = 0
  WALL = 1
  PLAYER = 2

--0 - empty
--1 - walls
--2 - player
--3+ - enemy

--Szmeksi LUA table magic, mogłaby być bardziej ale nie chce mi się
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

--Inicjalizuje mapę jako grid 20x20 
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
    act_x = 256,
    act_y = 256,
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

--CZEMU LUA NIE MA KLAS
  triangle.__index = triangle

  function triangle.new(x, y, id, direction)
    local self = setmetatable({}, triangle)
    self.x = x
    self.y = y
    self.id = id
    self.direction = direction
    return self
  end

  function triangle.setX(self, x)
    self.x = x
  end

  function triangle.setY(self, y)
    self.y = y
  end

  function triangle.setDirection(self, direction)
    self.direction = direction
  end

  function triangle.setActX(self, act_x)
    self.act_x = act_x
  end

  function triangle.setActY(self, act_y)
    self.act_y = act_y
  end

  tableOfTriangles = {}

  initTriangles()

  worldmap[player.x][player.y] = PLAYER
end

function initTriangles()
  math.randomseed(os.time())
  tableOfCoords = {}


  for i = 1, NO_TRIANGLES do
    point = {}

    randX = 10
    while randX == 9 or randX == 10 or randX == 11 do
      randX = math.random(1,18)
    end

    point.x = randX
    randY = 10
    point.y = randY
    table.insert(tableOfCoords, point)

--Manualne sprawdzanie czy punkty, w których będą trójkąty są unikatowe
    uniquePoint = false
    while (randY == 9 or randY == 10 or randY == 11 or not uniquePoint) do
      randY = math.random(1,18)
      uniquePoint = true
      for k, v in pairs(tableOfCoords) do
        if v.x == point.x and v.y == randY then
          uniquePoint = false
        end
      end
      table.insert(tableOfCoords, point)
    end
    table.insert(tableOfTriangles, triangle.new(randX, randY, i + 2, randomDirection()) )
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
--Piękna animacja. Z tutoriala.
  player.act_x = player.act_x - ((player.act_x - (player.x * 32)) * player.speed * dt)
  player.act_y = player.act_y - ((player.act_y - (player.y * 32)) * player.speed * dt)
end

function love.draw()
  love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)

  for i = 1, #tableOfTriangles do
    tmp = tableOfTriangles[i]
    if tmp.direction == RIGHT then
      love.graphics.polygon("fill", tmp.x * 32, tmp.y * 32, tmp.x * 32, ((tmp.y+1) * 32), ((tmp.x + 1) * 32), (tmp.y*32 +16))
    elseif tmp.direction == DOWN then
      love.graphics.polygon("fill", tmp.x * 32, tmp.y * 32, (tmp.x + 1) * 32, tmp.y * 32, (tmp.x *32 + 16), ((tmp.y+1)*32))
    elseif tmp.direction == LEFT then
      love.graphics.polygon("fill", (tmp.x + 1) * 32, tmp.y * 32, (tmp.x+1) * 32, (tmp.y + 1)* 32, tmp.x * 32, tmp.y*32+16)
    elseif tmp.direction == UP then
      love.graphics.polygon("fill", tmp.x * 32, (tmp.y+1) * 32, (tmp.x + 1) * 32, ((tmp.y +1 )* 32), (tmp.x *32 + 16), tmp.y*32)
    end
  end


  for x=0, #worldmap do
    for y=0, #worldmap[x] do
      if worldmap[x][y] == 1 then
        love.graphics.rectangle("line", x * 32, y * 32, 32, 32)
      end
    end
  end
end
--Do debugowania, nie czytać
function showMatrix()
  for y = 0, #worldmap do
    for x = 0, #worldmap[y] do
      io.write(worldmap[x][y])
    end
    io.write("\n")
  end
  io.write("\n\n")
end

function moveTriangles()
  for k, v in pairs(tableOfTriangles) do
    if v.direction == UP then
      if v.y > 1 then
        v.y = v.y -1
      end
      v.direction = randomDirection()
    elseif v.direction == DOWN then
      if v.y < 18 then
        v.y = v.y + 1
      end
      v.direction = randomDirection()
    elseif v.direction == LEFT then
      if v.x > 1 then
        v.x = v.x - 1
      end
      v.direction = randomDirection()
    elseif v.direction == RIGHT then
      if v.x < 18 then
        v.x = v.x + 1
      end
      v.direction = randomDirection()
    end
  end
end

--Ruch z wykrywaniem kolizji
function love.keypressed(key)  
  if key == "down" then
    if (worldmap[player.x][player.y+1] ~= WALL) then
      movement[DOWN]()
      moveTriangles()
    end
  elseif key == "up" then
    if (worldmap[player.x][player.y-1] ~= WALL) then
      movement[UP]()
      moveTriangles()

    end
  elseif key == "left" then
    if (worldmap[player.x-1][player.y] ~= WALL) then
      movement[LEFT]()
      moveTriangles()

    end
  elseif key == "right" then
    if (worldmap[player.x+1][player.y] ~= WALL) then
      movement[RIGHT]()      
      moveTriangles()
    end
  end
end