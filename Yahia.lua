-- LocalScript (pegar en StarterPlayerScripts)

-- Servicios
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- CONFIG
local FLY_SPEED = 80        -- velocidad de vuelo
local FLY_ACCEL = 120       -- cuanto se 'acelera' hacia la velocidad objetivo

-- Crea la GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YahiaFlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 130)
frame.Position = UDim2.new(0.5, -150, 0.2, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true  -- necesario para arrastrar

-- Sombra / borde estético
local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Color3.fromRGB(200,200,200)
uiStroke.Thickness = 1
uiStroke.Transparency = 0.8

-- Título / etiqueta "hecho por yahia"
local label = Instance.new("TextLabel")
label.Name = "AuthorLabel"
label.Size = UDim2.new(1, -10, 0, 30)
label.Position = UDim2.new(0, 5, 0, 5)
label.BackgroundTransparency = 1
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.TextColor3 = Color3.fromRGB(240,240,240)
label.Text = "hecho por yahia"
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = frame

-- Botón cerrar (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -33, 0, 4)
closeBtn.AnchorPoint = Vector2.new(0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Text = "X"
closeBtn.Parent = frame

-- Botón Fly
local flyBtn = Instance.new("TextButton")
flyBtn.Name = "FlyButton"
flyBtn.Size = UDim2.new(0, 110, 0, 40)
flyBtn.Position = UDim2.new(0.5, -55, 0, 50)
flyBtn.AnchorPoint = Vector2.new(0.5,0)
flyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
flyBtn.BorderSizePixel = 0
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 20
flyBtn.TextColor3 = Color3.fromRGB(255,255,255)
flyBtn.Text = "Fly"
flyBtn.Parent = frame

-- Texto de estado (debajo del botón)
local status = Instance.new("TextLabel")
status.Name = "StatusLabel"
status.Size = UDim2.new(1, -10, 0, 20)
status.Position = UDim2.new(0, 5, 0, 100)
status.BackgroundTransparency = 1
status.Font = Enum.Font.SourceSans
status.TextSize = 16
status.TextColor3 = Color3.fromRGB(220,220,220)
status.Text = "Estado: Inactivo"
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

-- Funcionalidad: arrastrar
do
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and dragInput then
            update(input)
        end
    end)
end

-- Cerrar GUI
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ====== Código de vuelo ======
local flying = false
local connections = {}
local moveVector = Vector3.new(0,0,0)
local speed = FLY_SPEED

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Manejamos inputs para movimiento
local inputState = {
    forward = 0,
    backward = 0,
    left = 0,
    right = 0,
    up = 0,
    down = 0,
}

local function updateInput(action, state)
    -- action: key name, state: true/false
    if action == "forward" then inputState.forward = state and 1 or 0 end
    if action == "back" then inputState.backward = state and 1 or 0 end
    if action == "left" then inputState.left = state and 1 or 0 end
    if action == "right" then inputState.right = state and 1 or 0 end
    if action == "up" then inputState.up = state and 1 or 0 end
    if action == "down" then inputState.down = state and 1 or 0 end
end

-- Mapeo de teclas (WASD + Space/LeftShift)
UserInputService.InputBegan:Connect(function(inp, gameProcessed)
    if gameProcessed then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        local key = inp.KeyCode
        if key == Enum.KeyCode.W then updateInput("forward", true) end
        if key == Enum.KeyCode.S then updateInput("back", true) end
        if key == Enum.KeyCode.A then updateInput("left", true) end
        if key == Enum.KeyCode.D then updateInput("right", true) end
        if key == Enum.KeyCode.Space then updateInput("up", true) end
        if key == Enum.KeyCode.LeftShift then updateInput("down", true) end
    end
end)

UserInputService.InputEnded:Connect(function(inp, gameProcessed)
    if gameProcessed then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        local key = inp.KeyCode
        if key == Enum.KeyCode.W then updateInput("forward", false) end
        if key == Enum.KeyCode.S then updateInput("back", false) end
        if key == Enum.KeyCode.A then updateInput("left", false) end
        if key == Enum.KeyCode.D then updateInput("right", false) end
        if key == Enum.KeyCode.Space then updateInput("up", false) end
        if key == Enum.KeyCode.LeftShift then updateInput("down", false) end
    end
end)

-- Activa el vuelo para el personaje actual
local function enableFly(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    -- Evita conflictos con animaciones/rigidbody
    humanoid.PlatformStand = true

    -- BodyVelocity para controlar movimiento
    local bv = Instance.new("BodyVelocity")
    bv.Name = "YahiaFlyBV"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp

    -- Actualización por frame para aplicar velocidad suave
    local heartbeatCon = RunService.Heartbeat:Connect(function(dt)
        local camera = workspace.CurrentCamera
        if not camera then return end

        -- dirección relativa a la cámara
        local forward = (Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)).Unit
        if forward ~= forward then forward = Vector3.new(0,0,-1) end -- por si es NaN
        local right = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z).Unit
        if right ~= right then right = Vector3.new(1,0,0) end

        -- compone vector de movimiento en plano XZ
        local xDir = (right * (inputState.right - inputState.left))
        local zDir = (forward * (inputState.forward - inputState.backward))
        local vertical = (inputState.up - inputState.down)

        local targetVel = (xDir + zDir)
        if targetVel.Magnitude > 0 then
            targetVel = targetVel.Unit * speed
        end

        -- añadir componente vertical
        targetVel = targetVel + Vector3.new(0, vertical * speed, 0)

        -- suavizar con aceleración
        local current = bv.Velocity
        local newVel = current:Lerp(targetVel, math.clamp(FLY_ACCEL * dt, 0, 1))
        bv.Velocity = newVel
    end)

    -- Guardar conexiones para desconectar al desactivar
    connections.bv = bv
    connections.heartbeat = heartbeatCon
    connections.humanoid = humanoid
end

-- Desactiva vuelo y limpia
local function disableFly(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if connections.heartbeat then
        connections.heartbeat:Disconnect()
        connections.heartbeat = nil
    end
    if connections.bv and connections.bv:IsA("BodyVelocity") then
        connections.bv:Destroy()
        connections.bv = nil
    end
    if connections.humanoid then
        -- restaurar control
        if connections.humanoid.Parent then
            connections.humanoid.PlatformStand = false
        end
        connections.humanoid = nil
    end
end

-- Toggle al presionar el botón
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    status.Text = flying and "Estado: Volando" or "Estado: Inactivo"
    flyBtn.Text = flying and "Disable Fly" or "Fly"

    local char = getCharacter()
    if flying then
        enableFly(char)
    else
        disableFly(char)
    end
end)

-- Asegurar que al reaparecer personaje se limpie el vuelo
player.CharacterAdded:Connect(function(char)
    -- Espera un momento que cargue
    wait(0.2)
    if flying then
        -- Reinicia la funcionalidad de vuelo con el nuevo character
        disableFly(char) -- limpia cualquier resto
        enableFly(char)
    else
        disableFly(char)
    end
end)

-- Si el script se corta / jugador ya tiene personaje
if player.Character then
    -- nada por defecto; vuelo solo se activa con el botón
end

-- FIN del script
