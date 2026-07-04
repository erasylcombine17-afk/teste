local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===== СОЗДАЁМ УДАЛЁННОЕ СОБЫТИЕ =====
local DropkickEvent = Instance.new("RemoteEvent")
DropkickEvent.Name = "DropkickEvent"
DropkickEvent.Parent = ReplicatedStorage

local mouse = player:GetMouse()
local isDropkickMode = false
local buttonGui = nil

-- ===== АНИМАЦИЯ УДАРА НОГОЙ =====
local function playKickAnimation()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local rightLeg = char:FindFirstChild("Right Leg")
    local leftLeg = char:FindFirstChild("Left Leg")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rightLeg or not leftLeg or not root then return end
    
    -- Сохраняем оригинальные позиции
    local rightCF = rightLeg.CFrame
    local leftCF = leftLeg.CFrame
    
    -- Поднимаем ногу для удара
    for i = 1, 5 do
        local t = i / 5
        rightLeg.CFrame = rightCF * CFrame.Angles(0, 0, -t * 1.5)
        task.wait(0.02)
    end
    
    -- РЕЗКИЙ УДАР ВПЕРЁД
    for i = 1, 10 do
        local t = i / 10
        local angle = math.sin(t * math.pi) * 3.5
        rightLeg.CFrame = rightCF * CFrame.Angles(0, 0, -angle)
        leftLeg.CFrame = leftCF * CFrame.Angles(0, 0, angle * 0.2)
        
        -- Лёгкое смещение корпуса вперёд
        if i > 5 then
            root.CFrame = root.CFrame + root.CFrame.LookVector * 0.05
        end
        
        task.wait(0.015)
    end
    
    -- Возврат ноги
    for i = 1, 10 do
        local t = i / 10
        local angle = math.sin((1 - t) * math.pi) * 3.5
        rightLeg.CFrame = rightCF * CFrame.Angles(0, 0, -angle)
        leftLeg.CFrame = leftCF * CFrame.Angles(0, 0, angle * 0.2)
        task.wait(0.015)
    end
    
    -- Возвращаем всё на место
    rightLeg.CFrame = rightCF
    leftLeg.CFrame = leftCF
    
    -- Эффект "ударной волны" от ноги
    local wave = Instance.new("Part")
    wave.Size = Vector3.new(2, 2, 2)
    wave.CFrame = rightLeg.CFrame * CFrame.new(0, -0.5, -1)
    wave.Shape = Enum.PartType.Ball
    wave.Material = Enum.Material.Neon
    wave.Color = Color3.fromRGB(255, 200, 0)
    wave.Anchored = true
    wave.CanCollide = false
    wave.Transparency = 0.3
    wave.Parent = workspace
    
    -- Анимация волны
    task.spawn(function()
        for i = 1, 15 do
            wave.Size = wave.Size + Vector3.new(0.3, 0.3, 0.3)
            wave.Transparency = wave.Transparency + 0.05
            wave.CFrame = wave.CFrame + wave.CFrame.LookVector * 0.1
            task.wait(0.03)
        end
        wave:Destroy()
    end)
end

-- ===== КВАДРАТНАЯ КНОПКА-ПЕРЕКЛЮЧАТЕЛЬ =====
local function createToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DropkickUI"
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
    
    -- Иконка (ножной удар)
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 0.7, 0)
    icon.Position = UDim2.new(0, 0, 0.05, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🦵"
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
        isDropkickMode = not isDropkickMode
        
        if isDropkickMode then
            -- ВКЛЮЧЕНО
            button.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
            button.BackgroundTransparency = 0.2
            button.BorderColor3 = Color3.fromRGB(0, 255, 0)
            statusText.Text = "ON"
            statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            icon.Text = "⚡"
            
            -- Подсветка игроков
            highlightPlayers(true)
            
            -- Уведомление
            showNotification("🔴 DROPKICK АКТИВЕН! Кликни на игрока")
        else
            -- ВЫКЛЮЧЕНО
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            button.BackgroundTransparency = 0.1
            button.BorderColor3 = Color3.fromRGB(100, 100, 100)
            statusText.Text = "OFF"
            statusText.TextColor3 = Color3.fromRGB(255, 50, 50)
            icon.Text = "🦵"
            
            highlightPlayers(false)
            showNotification("🟢 Режим выключен")
        end
    end)
    
    buttonGui = screenGui
    return button
end

-- ===== ПОДСВЕТКА ИГРОКОВ =====
local function highlightPlayers(enabled)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char then
                local highlight = char:FindFirstChild("DropkickHighlight")
                if enabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "DropkickHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.3
                        highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
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

-- ===== СЕРВЕРНАЯ ЧАСТЬ (ВСТРОЕННАЯ) =====
-- Отправляем запрос на сервер
local function requestDropkick(targetName)
    DropkickEvent:FireServer(targetName)
end

-- ===== КЛИК ПО ИГРОКУ =====
local function setupClickHandler()
    mouse.Button1Down:Connect(function()
        if not isDropkickMode then return end
        
        local target = mouse.Target
        if not target then return end
        
        local character = target.Parent
        if not character then return end
        
        local targetPlayer = Players:GetPlayerFromCharacter(character)
        if not targetPlayer or targetPlayer == player then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- 1. ИГРАЕМ АНИМАЦИЮ УДАРА
        playKickAnimation()
        
        -- 2. ЭФФЕКТ КЛИКА
        local clickEffect = Instance.new("Part")
        clickEffect.Size = Vector3.new(3, 3, 3)
        clickEffect.CFrame = target.CFrame
        clickEffect.Shape = Enum.PartType.Ball
        clickEffect.Material = Enum.Material.Neon
        clickEffect.Color = Color3.fromRGB(255, 255, 0)
        clickEffect.Anchored = true
        clickEffect.CanCollide = false
        clickEffect.Transparency = 0.2
        clickEffect.Parent = workspace
        
        task.spawn(function()
            for i = 1, 10 do
                clickEffect.Size = clickEffect.Size + Vector3.new(0.5, 0.5, 0.5)
                clickEffect.Transparency = clickEffect.Transparency + 0.08
                task.wait(0.04)
            end
            clickEffect:Destroy()
        end)
        
        -- 3. ОТПРАВЛЯЕМ ЗАПРОС
        requestDropkick(targetPlayer.Name)
        showNotification("🦵 ВЫШВЫРИВАЕМ " .. targetPlayer.Name .. "!")
        
        -- 4. ВИБРАЦИЯ КАМЕРЫ (эффект удара)
        task.spawn(function()
            local cam = workspace.CurrentCamera
            local originalPos = cam.CFrame
            for i = 1, 5 do
                cam.CFrame = cam.CFrame * CFrame.new(math.random(-1, 1) * 0.1, math.random(-1, 1) * 0.1, math.random(-1, 1) * 0.1)
                task.wait(0.02)
            end
            cam.CFrame = originalPos
        end)
    end)
end

-- ===== ОБНОВЛЕНИЕ ПОДСВЕТКИ =====
Players.PlayerAdded:Connect(function(newPlayer)
    if isDropkickMode then
        task.wait(0.5)
        highlightPlayers(true)
    end
end)

-- ===== ЗАПУСК =====
createToggleButton()
setupClickHandler()

-- Обновляем подсветку при появлении персонажа
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if isDropkickMode then
        highlightPlayers(true)
    end
end)

-- ===== ВСТРОЕННЫЙ СЕРВЕРНЫЙ ОБРАБОТЧИК =====
-- ВНИМАНИЕ! Этот код должен быть в ServerScript, но я вставляю его сюда для полноты
-- На самом деле, поместите его в отдельный ServerScript в StarterServerScriptService

--[[
-- СЕРВЕРНАЯ ЧАСТЬ (помести в StarterServerScriptService):

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DropkickEvent = ReplicatedStorage:FindFirstChild("DropkickEvent")

local function isAdmin(player)
    return player.UserId == 123456789 -- ТВОЙ ID
end

DropkickEvent.OnServerEvent:Connect(function(player, targetName)
    if not isAdmin(player) then
        player:Kick("Нет прав на дропкик!")
        return
    end
    
    local target = Players:FindFirstChild(targetName)
    if not target or target == player then
        player:Kick("Некого дропкикать!")
        return
    end
    
    -- Дропкик
    local targetChar = target.Character
    if not targetChar then return end
    
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local executorRoot = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetHumanoid or not targetRoot or not executorRoot then return end
    
    -- Отключаем всё у жертвы
    targetHumanoid.PlatformStand = true
    targetHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    targetHumanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    targetHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    
    for _, part in ipairs(targetChar:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    -- Вычисляем направление (ОТ ТЕБЯ)
    local direction = (targetRoot.Position - executorRoot.Position).Unit
    local velocity = direction * 150 + Vector3.new(0, 60, 0)
    
    targetRoot.AssemblyLinearVelocity = velocity
    targetRoot.AssemblyAngularVelocity = Vector3.new(
        math.random(-20, 20),
        math.random(-30, 30),
        math.random(-20, 20)
    )
    
    -- Делаем исполнителя неуязвимым
    local executorHumanoid = player.Character:FindFirstChild("Humanoid")
    if executorHumanoid then
        executorHumanoid.MaxHealth = math.huge
        executorHumanoid.Health = math.huge
        executorHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        executorHumanoid.BreakJointsOnDeath = false
        
        task.wait(3)
        executorHumanoid.MaxHealth = 100
        executorHumanoid.Health = 100
        executorHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        executorHumanoid.BreakJointsOnDeath = true
    end
    
    -- Кикаем через 2.5 секунды
    task.wait(2.5)
    target:Kick("🦵 DROPKICK! Вышвырнут " .. player.Name)
end)
]]
