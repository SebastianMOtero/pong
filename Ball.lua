Ball = Class{}

function Ball:init(x, y, radius)
	self.x = x - radius
	self.y = y - radius
	self.radius = radius
	self.dx = math.random(2) == 1 and -100 or 100
	self.dy = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
end

function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Ball:reset()
	self.x = VIRTUAL_WIDTH / 2
	self.y = VIRTUAL_HEIGHT / 2
	self.dx = math.random(2) == 1 and -100 or 100
	self.dy = math.random(-50, 50)
end

function Ball:collides(paddle)
	if self.x - self.radius > paddle.x + paddle.width or paddle.x > self.x + self.radius then
		return false
	end

	if self.y - self.radius > paddle.y + paddle.height or paddle.y > self.y + self.radius then
		return false
	end

	return true
end

function Ball:render()
	love.graphics.circle('fill', self.x, self.y, self.radius)
end