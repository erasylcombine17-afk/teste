local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ===== СОЗДАЁМ СОБЫТИЕ =====
local KillEvent = Instance.new("RemoteEvent")
KillEvent.Name = "KillEvent"
KillEvent.Parent = ReplicatedStorage

local mouse = player:GetMouse()
local isKillMode = false

-- ===== КВАДРАТНАЯ КНОПКА-ПЕРЕКЛЮЧАТЕЛЬ =====
local function createToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Квадратная кнопка
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0.9, -40, 0.05, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 3
    button.BorderColor3 = Color3.fromRGB(100, 100, 100)
    button.Text = ""
    button.Parent = screenGui
    
    -- Иконка
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0.7, 0)
    icon.Position = UDim2.new(0, 0, 0.05, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "💀"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.TextScaled = true
    icon.Font = Enum.Font.Bold
    icon.Parent = button
    
    -- Текст состояния
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 0.25, 0)
    statusText.Position = UDim2.new(0, 0, 0.75, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "OFF"
    statusText.TextColor3 = Color3.fromRGB(255, 50, 50)
    statusText.TextScaled = true
    statusText.Font = Enum.Font.Bold
    statusText.Parent = button
    
    -- ПЕРЕКЛЮЧЕНИЕ
    button.MouseButton1Click:Connect(function()
        isKillMode = not isKillMode
        
        if isKillMode then
            -- ВКЛ
            button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            button.BackgroundTransparency = 0.2
            button.BorderColor3 = Color3.fromRGB(255, 0, 0)
            statusText.Text = "ON"
            statusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            icon.Text = "⚔️"
            
            highlightPlayers(true)
            showNotification("🔴 РЕЖИМ УБИЙСТВА ВКЛЮЧЁН! Кликни на игрока")
        else
            -- ВЫКЛ
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            button.BackgroundTransparency = 0.1
            button.BorderColor3 = Color3.fromRGB(100, 100, 100)
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(255, 50, 50)
            icon.Text = "💀"
            
            highlightPlayers(false)
            showNotification("🟢 Режим выключен")
        end
    end)
    
    return button
end

-- ===== ПОДСВЕТКА ИГРОКОВ =====
local function highlightPlayers(enabled)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char then
                local highlight = char:FindFirstChild("KillHighlight")
                if enabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "KillHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.3
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineTransparency = 0.1
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = char
                    end
                else
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
end

-- ===== УВЕДОМЛЕНИЯ =====
local function showNotification(text)
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 50)
    frame.Position = UDim2.new(0.5, -225, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.7
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.Bold
    label.Parent = frame
    
    task.wait(2.5)
    gui:Destroy()
end

-- ===== КЛИК ПО ИГРОКУ =====
local function setupClickHandler()
    mouse.Button1Down:Connect(function()
        if not isKillMode then return end
        
        local target = mouse.Target
        if not target then return end
        
        local character = target.Parent
        if not character then return end
        
        local targetPlayer = Players:GetPlayerFromCharacter(character)
        if not targetPlayer or targetPlayer == player then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Отправляем запрос на убийство
        KillEvent:FireServer(targetPlayer.Name)
        
        -- Эффект при клике
        local effect = Instance.new("Part")
        effect.Size = Vector3.new(3, 3, 3)
        effect.CFrame = target.CFrame
        effect.Shape = Enum.PartType.Ball
        effect.Material = Enum.Material.Neon
        effect.Color = Color3.fromRGB(255, 0, 0)
        effect.Anchored = true
        effect.CanCollide = false
        effect.Transparency = 0.2
        effect.Parent = workspace
        
        task.spawn(function()
            for i = 1, 10 do
                effect.Size = effect.Size + Vector3.new(0.5, 0.5, 0.5)
                effect.Transparency = effect.Transparency + 0.08
                task.wait(0.04)
            end
            effect:Destroy()
        end)
        
        showNotification("💀 ВЫ УБИЛИ " .. targetPlayer.Name .. "!")
    end)
end

-- ===== ОБНОВЛЕНИЕ ПОДСВЕТКИ =====
Players.PlayerAdded:Connect(function(newPlayer)
    if isKillMode then
        task.wait(0.5)
        highlightPlayers(true)
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if isKillMode then
        highlightPlayers(true)
    end
end)

-- ===== ЗАПУСК =====
createToggleButton()
setupClickHandler()
