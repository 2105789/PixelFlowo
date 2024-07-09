# LÖVE 2D Blob and Sand Simulation

This repository contains two distinct LÖVE 2D simulations: "Sando" (falling sand) and "Lavo" (interactive blobs). Each simulation explores different visual and physics concepts, offering unique interactive experiences.
![sando banner](https://raw.githubusercontent.com/2105789/PixelFlowo/main/Sando.png)
## 1. Sando: Interactive Falling Sand Simulation

**Sando.lua** creates a captivating visual experience reminiscent of classic falling sand games. It uses a grid-based system to simulate sand-like particles with customizable colors, wind interaction, and even anti-gravity.

### Features:

- **Mouse-drawn Sand:** Click and drag your mouse to release a stream of colorful sand particles that fall realistically.
- **Dynamic Color Selection:**  A color picker conveniently located at the top of the screen empowers you to change the color of the sand on the fly.
- **Simulated Wind Effects:**  Use the 'A' and 'D' keys to generate wind currents that realistically push the sand particles, adding another layer of complexity to the simulation.
- **Gravity Defiance (Anti-Gravity):**  Press the 'Space' key to activate or deactivate anti-gravity. Watch in awe as the sand defies conventional physics, falling upwards instead of down.
- **Realistic Particle Weight:**  Each sand particle is assigned a random weight, influencing its fall speed and susceptibility to wind forces. Heavier particles fall faster and are less affected by wind, while lighter particles exhibit the opposite behavior.

### Key Code Explanations:

**1. Grid-Based Physics:**

```lua
local sandParticles = {}  -- Stores all sand particles
local cellSize = 2         -- Size of each cell in the grid
local gridWidth, gridHeight

-- ... (Initialization code) ...

function updateSandParticles()
    -- ... (Loop through each sand particle) ...

        if particle.y < gridHeight and particle.falling then
            local fallSpeed = 1 + (particle.weight * 2) 

            if not antigravity then
                -- ... (Check for collisions and move particle down) ...
            else
                -- ... (Check for collisions and move particle up) ...
            end
        end

    -- ... (Handle wind and sideways movement) ...
end
```

The simulation uses a grid to represent the space where sand particles can exist. Each cell in the grid can be either empty or occupied by a single particle. The `updateSandParticles` function iterates through all particles and updates their positions based on gravity, wind, and collisions.

**2. Wind Simulation:**

```lua
local windDirection = 0  -- -1: left, 1: right, 0: no wind

-- ... (In the love.keypressed function) ...

    if key == "a" then
        windDirection = -1
    elseif key == "d" then
        windDirection = 1
    -- ...
end

-- ... (In the updateSandParticles function) ...

    if windDirection ~= 0 then
        -- ... (Apply wind force to particles based on their weight) ...
    end
```

The `windDirection` variable controls the direction and strength of the wind. When a key is pressed, the wind direction changes, and the `updateSandParticles` function applies a horizontal force to each particle, simulating the effect of wind.

**3. Anti-Gravity:**

```lua
local antigravity = false

-- ... (In the love.keypressed function) ...

    if key == "space" then
        antigravity = not antigravity
    end 

-- ... (In the updateSandParticles function) ...

    if not antigravity then
        -- ... (Move particle down due to gravity) ...
    else
        -- ... (Move particle up against gravity) ...
    end
```

The `antigravity` flag determines the direction of the gravitational force.  When activated, the sand particles will move upwards.

### Controls:

- **Mouse Click & Drag:** Spawn sand particles.
- **A Key:** Wind blows left.
- **D Key:** Wind blows right.
- **Space Key:** Toggle anti-gravity.
- 
![lavo banner](https://raw.githubusercontent.com/2105789/PixelFlowo/main/Lavo.png)
## 2. Lavo.lua: Blob Simulation with Metaballs and Particles

**Lavo.lua** presents a mesmerizing simulation of colorful, pulsating blobs that interact with each other and their environment. The simulation utilizes the metaballs algorithm to achieve smooth, organic-looking blob merging.

### Features:

- **Metaballs Effect:** Creates visually appealing, organically shaped blobs that blend seamlessly when they come into contact with each other.
- **Particle Emission:**  Blobs periodically release particles that gradually fade over time, leaving beautiful, ephemeral trails.
- **Dynamic Blob Merging:**  When two blobs get close enough, they merge into a single, larger blob. The resulting blob inherits characteristics from both parent blobs.
- **Color Transitions:** Blobs continuously transition between randomly generated colors, adding visual interest and dynamism to the simulation.

### Key Code Explanations:

**1. Metaballs Algorithm:**

```lua
local GRID_SIZE = 2     -- Size of each cell in the grid
local THRESHOLD = 1.2  -- Threshold for metaballs rendering

function love.draw()
    -- ...
    for y = 0, WINDOW_HEIGHT, GRID_SIZE do
        for x = 0, WINDOW_WIDTH, GRID_SIZE do
            local sum = 0
            local closestBlob = nil
            -- ... (Find closest blob) ...
            for _, blob in ipairs(blobs) do
                local dx = x - blob.x
                local dy = y - blob.y
                local distSq = dx*dx + dy*dy
                sum = sum + (blob.radius * blob.radius) / distSq -- Calculate metaball field
                -- ...
            end
            if sum > THRESHOLD and closestBlob then
                love.graphics.setColor(closestBlob.color)
                love.graphics.rectangle("fill", x, y, GRID_SIZE, GRID_SIZE)
            end
        end
    end
    -- ...
end
```

The code iterates over a grid, and for each cell, it calculates the sum of the influence fields of all blobs. If the sum exceeds a certain threshold (`THRESHOLD`), the cell is considered to be inside a blob and is filled with the color of the closest blob.

**2. Blob Merging:**

```lua
local MERGE_DISTANCE = 50 -- Distance at which blobs merge

function love.update(dt)
    -- ...
    for i = #blobs, 1, -1 do
        local blob = blobs[i]
        -- ... (Update blob position and other properties) ...

        for j = i - 1, 1, -1 do
            local otherBlob = blobs[j]
            local dx = otherBlob.x - blob.x
            local dy = otherBlob.y - blob.y
            local distance = math.sqrt(dx*dx + dy*dy)
            if distance < MERGE_DISTANCE then
                -- ... (Merge blobs based on size) ...
            end
        end
    end
end
```

This part of the code iterates through all pairs of blobs and checks if their distance is less than `MERGE_DISTANCE`.  If blobs are close enough, the smaller blob is absorbed into the larger one.

**3. Particle System:**

```lua
local PARTICLE_LIFETIME = 0.5

-- ... (createParticle function to generate particles) ...

function love.update(dt)
    -- ...
    for i = #blobs, 1, -1 do
        local blob = blobs[i]
        -- ...

        if love.math.random() < 0.2 then  -- Chance to spawn a particle
            table.insert(blob.particles, createParticle(blob.x, blob.y, blob.color))
        end

        -- ... (Update particle lifetimes and remove dead particles) ...
    end
end
```
This code snippet demonstrates how particles are emitted from each blob. It generates particles at random intervals and assigns them a lifetime, creating a fading trail effect.

### Controls:

- **Mouse Click:** Creates a new blob at the cursor's location.

## How to Run:

1. **Install LÖVE 2D:** Download the correct version of LÖVE 2D for your operating system from the official website: [https://love2d.org/](https://love2d.org/).

2. **Download the Code:** Download the repository's `.lua` files (Sando.lua and Lavo.lua).

3. **Execute with LÖVE 2D:** Open the desired `.lua` file (either Sando.lua or Lavo.lua) using the LÖVE 2D executable to launch the simulation.


## Credits:

These simulations were created using the LÖVE 2D framework: [https://love2d.org/](https://love2d.org/).

