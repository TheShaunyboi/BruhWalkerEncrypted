-- Game constants
local TILE_SIZE = 20
local GAME_WIDTH = 20
local GAME_HEIGHT = 20
local INITIAL_SPEED = 0.5

-- Snake constants
local SNAKE_COLOR = {255, 255, 255}
local SNAKE_BODY_COLOR = {200, 200, 200}

-- Apple constants
local APPLE_COLOR = {255, 0, 0}

-- Game state
local snake = {
  {x = 10, y = 10},
  {x = 9, y = 10},
  {x = 8, y = 10},
}
local direction = "right"
local apple = {}

-- Game setup
function setup()
  renderer:add_indicator("Score: 0", 255, 255, 255)
  spawnApple()
end

-- Game update
function on_tick()
  handleInput()
  moveSnake()
  checkCollision()
end

-- Game draw
function on_draw()
  drawGame()
end

-- Handle player input
function handleInput()
  if game:is_key_down(0x28) and direction ~= "down" then
    direction = "up"
  elseif game:is_key_down(0x26) and direction ~= "up" then
    direction = "down"
  elseif game:is_key_down(0x27) and direction ~= "right" then
    direction = "left"
  elseif game:is_key_down(0x25) and direction ~= "left" then
    direction = "right"
  end
end

-- Spawn a new apple at a random position
function spawnApple()
  local x = math.random(1, GAME_WIDTH)
  local y = math.random(1, GAME_HEIGHT)
  apple = {x = x, y = y}
end

-- Move the snake in the current direction
function moveSnake()
  local head = {x = snake[1].x, y = snake[1].y}

  if direction == "up" then
    head.y = head.y - 1
  elseif direction == "down" then
    head.y = head.y + 1
  elseif direction == "left" then
    head.x = head.x - 1
  elseif direction == "right" then
    head.x = head.x + 1
  end

  table.insert(snake, 1, head)
  table.remove(snake)
end

-- Check for collisions with walls, self, and apple
function checkCollision()
  local head = snake[1]

  -- Check wall collision
  if head.x < 1 or head.x > GAME_WIDTH or head.y < 1 or head.y > GAME_HEIGHT then
    gameOver()
  end

  -- Check self collision
  for i = 2, #snake do
    if head.x == snake[i].x and head.y == snake[i].y then
      gameOver()
    end
  end

  -- Check apple collision
  if head.x == apple.x and head.y == apple.y then
    growSnake()
    updateScore()
    spawnApple()
  end
end

-- Grow the snake by adding a new tail segment
function growSnake()
  local tail = {x = snake[#snake].x, y = snake[#snake].y}
  table.insert(snake, tail)
end

-- Update the score indicator
function updateScore()
  local score = #snake - 3
  renderer:add_indicator("Score: " .. score, 255, 255, 255)
end

-- Draw the game elements
function drawGame()
  -- Clear the screen
  renderer:draw_rect(0, 0, GAME_WIDTH * TILE_SIZE, GAME_HEIGHT * TILE_SIZE, 0, 0, 0, 255)

  -- Draw the snake
  for i, segment in ipairs(snake) do
    local color = (i == 1) and SNAKE_COLOR or SNAKE_BODY_COLOR
    local x = (segment.x - 1) * TILE_SIZE
    local y = (segment.y - 1) * TILE_SIZE
    renderer:draw_rect(x, y, TILE_SIZE, TILE_SIZE, unpack(color))
  end

  -- Draw the apple
  local appleX = (apple.x - 1) * TILE_SIZE
  local appleY = (apple.y - 1) * TILE_SIZE
  renderer:draw_rect(appleX, appleY, TILE_SIZE, TILE_SIZE, unpack(APPLE_COLOR))

end

-- Game over logic
function gameOver()
  renderer:draw_text_big_centered(GAME_WIDTH * TILE_SIZE / 2, GAME_HEIGHT * TILE_SIZE / 2, "Game Over", 255, 255, 255, 255)
  renderer:draw_text_centered(GAME_WIDTH * TILE_SIZE / 2, GAME_HEIGHT * TILE_SIZE / 2 + 30, "Press Enter to Restart", 255, 255, 255, 255)

  if game:is_key_down(0x0D) then
    resetGame()
  end
end

-- Reset the game state
function resetGame()
  snake = {
    {x = 10, y = 10},
    {x = 9, y = 10},
    {x = 8, y = 10},
  }
  direction = "right"
  spawnApple()
  updateScore()
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
