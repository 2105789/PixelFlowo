local blobs = {}
local WINDOW_WIDTH, WINDOW_HEIGHT = 800, 600
local NUM_BLOBS = 40
local BLOB_MIN_RADIUS, BLOB_MAX_RADIUS = 10, 40
local GRID_SIZE = 2
local THRESHOLD = 1.2
local MAX_SPEED = 100
local PARTICLE_LIFETIME = 0.5
local MERGE_DISTANCE = 50

local function lerpColor(c1, c2, t)
    return {
        c1[1] + (c2[1] - c1[1]) * t,
        c1[2] + (c2[2] - c1[2]) * t,
        c1[3] + (c2[3] - c1[3]) * t
    }
end

local function createParticle(x, y, color)
    return {
        x = x,
        y = y,
        lifetime = PARTICLE_LIFETIME,
        color = {color[1], color[2], color[3], 1}
    }
end

local function createBlob(x, y)
    local color = {
        love.math.random(), 
        love.math.random(), 
        love.math.random()
    }
    table.insert(blobs, {
        x = x or love.math.random(WINDOW_WIDTH),
        y = y or love.math.random(WINDOW_HEIGHT),
        radius = love.math.random(BLOB_MIN_RADIUS, BLOB_MAX_RADIUS),
        speed = love.math.random(50,MAX_SPEED),
        directionX = love.math.random() < 0.5 and -1 or 1,
        directionY = love.math.random() < 0.5 and -1 or 1,
        color = color,
        targetColor = {love.math.random(), love.math.random(), love.math.random()},
        colorChangeTimer = love.math.random(2, 5),
        particles = {}
    })
end

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    for i = 1, NUM_BLOBS do
        createBlob()
    end
end

function love.update(dt)
    for i = #blobs, 1, -1 do
        local blob = blobs[i]

        blob.x = blob.x + (blob.speed * dt * blob.directionX) * 0.1 
        blob.y = blob.y + (blob.speed * dt * blob.directionY) * 0.1 

        if blob.x < -BLOB_MAX_RADIUS then blob.x = WINDOW_WIDTH + BLOB_MAX_RADIUS end
        if blob.x > WINDOW_WIDTH + BLOB_MAX_RADIUS then blob.x = -BLOB_MAX_RADIUS end
        if blob.y < -BLOB_MAX_RADIUS then blob.y = WINDOW_HEIGHT + BLOB_MAX_RADIUS end
        if blob.y > WINDOW_HEIGHT + BLOB_MAX_RADIUS then blob.y = -BLOB_MAX_RADIUS end
        if love.math.random() < 0.01 then blob.directionX = -blob.directionX end
        if love.math.random() < 0.01 then blob.directionY = -blob.directionY end
        blob.colorChangeTimer = blob.colorChangeTimer - dt
        if blob.colorChangeTimer <= 0 then
            blob.targetColor = {love.math.random(), love.math.random(), love.math.random()}
            blob.colorChangeTimer = love.math.random(2, 5)
        end
        blob.color = lerpColor(blob.color, blob.targetColor, dt * 2)
        if love.math.random() < 0.2 then
            table.insert(blob.particles, createParticle(blob.x, blob.y, blob.color))
        end
        for j = #blob.particles, 1, -1 do
            local particle = blob.particles[j]
            particle.lifetime = particle.lifetime - dt
            particle.color[4] = particle.lifetime / PARTICLE_LIFETIME
            if particle.lifetime <= 0 then table.remove(blob.particles, j) end
        end
        for j = i - 1, 1, -1 do 
            local otherBlob = blobs[j]
            local dx = otherBlob.x - blob.x
            local dy = otherBlob.y - blob.y
            local distance = math.sqrt(dx*dx + dy*dy)
            if distance < MERGE_DISTANCE then
                if blob.radius > otherBlob.radius then
                    blob.radius = blob.radius + otherBlob.radius * 0.1
                    table.remove(blobs, j) 
                else
                    otherBlob.radius = otherBlob.radius + blob.radius * 0.1
                    table.remove(blobs, i) 
                    break
                end
            end
        end 
    end
end

function love.draw()
    local canvas = love.graphics.newCanvas(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    for y = 0, WINDOW_HEIGHT, GRID_SIZE do
        for x = 0, WINDOW_WIDTH, GRID_SIZE do
            local sum = 0
            local closestBlob = nil
            local minDist = math.huge
            for _, blob in ipairs(blobs) do
                local dx = x - blob.x
                local dy = y - blob.y
                local distSq = dx*dx + dy*dy
                sum = sum + (blob.radius * blob.radius) / distSq
                if distSq < minDist then
                    minDist = distSq
                    closestBlob = blob
                end
            end
            if sum > THRESHOLD and closestBlob then
                love.graphics.setColor(closestBlob.color)
                love.graphics.rectangle("fill", x, y, GRID_SIZE, GRID_SIZE)
            end
        end
    end
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas)
    for _, blob in ipairs(blobs) do
        for _, particle in ipairs(blob.particles) do
            love.graphics.setColor(particle.color)
            love.graphics.circle("fill", particle.x, particle.y, 2)
        end
    end
    love.graphics.setColor(0, 0, 0, 0.1)
    for y = 0, WINDOW_HEIGHT, 4 do
        love.graphics.line(0, y, WINDOW_WIDTH, y)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        createBlob(x, y)
    end
end
