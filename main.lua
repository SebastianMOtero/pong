--Execution "C:\Program Files\LOVE\love.exe" ./

--MODULES

push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

--CONST

--graphic config (aspect-ratio: 16:9)
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--game config
PADDLE_SPEED = 200
WINNING_SCORE = 2

--FUNCTIONS

--Runs when the game first starts up, only once; used to initialize the game.
function love.load()
	love.window.setTitle('Pong')
	love.graphics.setDefaultFilter('nearest', 'nearest')
	
	math.randomseed(os.time())

	smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)  --la font es la mitad de lo que dice en pixels de ancho y en este caso es 16x10
	love.graphics.setFont(smallFont)

	--table estructurais like dictionary in python or object in javascript
	-- [key] = values
	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
	}

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = true,
	})

	player1Score = 0
	player2Score = 0
	servingPlayer = 1
	gameState = 'start'
	showFPS = false
	
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)
	ball = Ball(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 4)
end

function love.resize(width, height)
	push:resize(width, height)
end
--Runs every frame, with "dt" passed in, our delta in seconds since the last frame.
function love.update(dt)
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	elseif gameState == 'play' then
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 9

			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit']:play()
		end

		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 8

			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit']:play()
		end

		if ball.y <= 0 then 
			ball.y = 0
			ball.dy = -ball.dy

			sounds['wall_hit']:play()
		end
		
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy

			sounds['wall_hit']:play()
		end
		
		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1
			sounds['score']:play()

			if player2Score == WINNING_SCORE then
				winningPlayer = 2
				gameState = 'done'
			else
				ball:reset()
				gameState = 'serve'
			end
		end
		
		if ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1Score = player1Score + 1
			sounds['score']:play()

			if player1Score == WINNING_SCORE then
				winningPlayer = 1
				gameState = 'done'
			else
				ball:reset()
				gameState = 'serve'
			end
		end
	end

    -- player 1 movement
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
    end

    -- player 2 movement
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end
	
	if gameState == 'play' then
		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
end

-- Keyboard handling, called by LÖVE2D each frame; passes in the key we pressed so we can access.
function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'
			
			ball:reset()
			player1Score = 0
			player2Score = 0

			if winningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayer = 1
			end
		end
	elseif key == 'f' then
		if showFPS == true then
			showFPS = false
		else
			showFPS = true
		end
	end
end

--Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
function love.draw()
	push:apply('start')

	love.graphics.clear(0, 45, 52, 0)

	love.graphics.setFont(smallFont)

	if gameState == 'serve' or gameState == 'done' then
		displayScore()
	end

	if gameState == 'start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press enter to start!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press enter to serve.', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		--nothing
	elseif gameState == 'done' then
		love.graphics.setFont(largeFont)
		love.graphics.printf('Player ' .. tostring(servingPlayer) ..  ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf('Press enter to restart game.', 0, 30, VIRTUAL_WIDTH, 'center')
	end

	player1:render()
	player2:render()
	ball:render()

	if showFPS == true then
		displayFPS()
	end

	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 20, 10)
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 66, VIRTUAL_HEIGHT / 2 - 15)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 50, VIRTUAL_HEIGHT / 2 - 15)
end
