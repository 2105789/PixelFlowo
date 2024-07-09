local sandParticles = {}
local cellSize = 2
local gridWidth, gridHeight
local colorPickerActive = false
local currentColor = {1, 0, 0, 1}
local colorPickerHeight = 10
local windDirection = 0
local occupiedGrid = {}
local antigravity = false
local spawnAmount = 5

function love.load()
    love.window.setMode(800, 600)
    gridWidth = math.floor(love.graphics.getWidth() / cellSize)
    gridHeight = math.floor((love.graphics.getHeight() - colorPickerHeight) / cellSize)
    math.randomseed(os.time())

    for y = 1, gridHeight do
        occupiedGrid[y] = {}
        for x = 1, gridWidth do
            occupiedGrid[y][x] = false
        end
    end
end

function love.update(dt)
    updateSandParticles()
    if love.mouse.isDown(1) and not colorPickerActive then
        local x, y = love.mouse.getPosition()
        spawnSandParticle(x, y)
    end
end

function love.draw()
    love.graphics.push('all')
    drawColorPicker()
    drawSandParticles()
    love.graphics.pop()
end

function spawnSandParticle(x, y)
    for _ = 1, spawnAmount do
        local offsetX = math.random(-1, 1) * cellSize * 2
        local offsetY = math.random(-1, 1) * cellSize * 2
        local gridX = math.floor((x + offsetX) / cellSize) + 1
        local gridY = math.floor(((y + offsetY) - colorPickerHeight) / cellSize) + 1

        if gridX >= 1 and gridX <= gridWidth and
           gridY >= 1 and gridY <= gridHeight and
           not occupiedGrid[gridY][gridX] then

            local randomAlpha = math.random()
            local weight = math.random()
            table.insert(sandParticles, {
                x = gridX,
                y = gridY,
                color = {currentColor[1], currentColor[2], currentColor[3], randomAlpha},
                weight = weight,
                falling = true
            })
            occupiedGrid[gridY][gridX] = true
        end
    end
end

function updateSandParticles()
    local newOccupiedGrid = {}
    for y = 1, gridHeight do
        newOccupiedGrid[y] = {}
        for x = 1, gridWidth do
            newOccupiedGrid[y][x] = false
        end
    end

    for i = #sandParticles, 1, -1 do
        local particle = sandParticles[i]
        local oldX, oldY = particle.x, particle.y

        if particle.y < gridHeight and particle.falling then
            local fallSpeed = 1 + (particle.weight * 2)

            if not antigravity then
                for _ = 1, math.floor(fallSpeed) do
                    if particle.y + 1 <= gridHeight and not occupiedGrid[particle.y + 1][particle.x] then
                        particle.y = particle.y + 1
                    else
                        particle.falling = false
                        break
                    end
                end
            else
                for _ = 1, math.floor(fallSpeed) do
                    if particle.y - 1 >= 1 and not occupiedGrid[particle.y - 1][particle.x] then
                        particle.y = particle.y - 1 
                    else
                        particle.falling = false
                        break
                    end
                end
            end
        end

        if windDirection ~= 0 and particle.x + windDirection >= 1 and particle.x + windDirection <= gridWidth and
           math.random() < particle.weight * 1.5 then
            if not occupiedGrid[particle.y][particle.x + windDirection] then
                particle.x = particle.x + windDirection 
            elseif particle.y + 1 <= gridHeight and not occupiedGrid[particle.y + 1][particle.x + windDirection] then
                particle.x = particle.x + windDirection
                particle.y = particle.y + 1
            end
        end

        if particle.y + 1 <= gridHeight and not occupiedGrid[particle.y + 1][particle.x] then
            particle.y = particle.y + 1
        elseif math.random() < particle.weight then
            local direction = (math.random(0, 1) * 2 - 1)
            if particle.x + direction > 0 and
               particle.x + direction <= gridWidth and
               particle.y + 1 <= gridHeight and
               not occupiedGrid[particle.y + 1][particle.x + direction] then
                particle.x = particle.x + direction
                particle.y = particle.y + 1
            end
        end

        if particle.x < 1 then particle.x = 1 end
        if particle.x > gridWidth then particle.x = gridWidth end
        if particle.y > gridHeight then particle.y = gridHeight end

        newOccupiedGrid[particle.y][particle.x] = true
    end

    occupiedGrid = newOccupiedGrid
end

function drawSandParticles()
    love.graphics.setCanvas()
    for _, particle in ipairs(sandParticles) do
        love.graphics.setColor(particle.color)
        love.graphics.rectangle("fill", (particle.x - 1) * cellSize, (particle.y - 1) * cellSize + colorPickerHeight, cellSize, cellSize)
    end
end

function drawColorPicker()
    local pickerWidth = love.graphics.getWidth()
    love.graphics.setColor(1, 1, 1, 1)
    for x = 0, pickerWidth - 1, 4 do
        local hue = x / pickerWidth
        local r, g, b = hsvToRgb(hue * 360, 1, 1)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", x, 0, 4, colorPickerHeight)
    end

    if colorPickerActive then
        local selectorX = (currentColor[1] * pickerWidth)
        love.graphics.setColor(0, 0, 0)
        love.graphics.polygon("fill", selectorX, colorPickerHeight, selectorX - 5, colorPickerHeight + 5, selectorX + 5, colorPickerHeight + 5)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and y <= colorPickerHeight then
        colorPickerActive = true
        currentColor = getColorFromPicker(x)
    else
        colorPickerActive = false
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        colorPickerActive = false
    end
end

function getColorFromPicker(x)
    local pickerWidth = love.graphics.getWidth()
    local hue = x / pickerWidth
    local r, g, b = hsvToRgb(hue * 360, 1, 1)
    return {r, g, b, currentColor[4]}
end

function hsvToRgb(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r, g, b

    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    return r + m, g + m, b + m
end

function love.keypressed(key)
    if key == "a" then
        windDirection = -1
    elseif key == "d" then
        windDirection = 1
    elseif key == "space" then
        antigravity = not antigravity
    end
end

function love.keyreleased(key)
    if key == "a" or key == "d" then
        windDirection = 0
    end
end
