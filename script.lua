local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

getgenv().CoringaFarm = {
    Enabled = false,
    Teleport = 2,
    TimeBetweenRuns = 5,
    AntiAfk = false,
    Voo = false,
    Noclip = false,
    GravidadeZero = false,
    Invisivel = false,
    VidaInfinita = false,
    Escudo = false,
    AutoComer = false,
    DetectarPerigos = false,
    Espiando = nil
}

local farmAtivo = false
local ouroTotal = 0
local faseAtual = 1
local runAtual = 1
local menuMinimizado = false
local submenuVisivel = ""
local temporizador = 0
local jogadoresProximos = {}
local perigosProximos = {}

local tamanhoOriginal = UDim2.new(0, 550, 0, 450)
local tamanhoMinimizado = UDim2.new(0, 120, 0, 30)

local coresTimes = {
    {Nome = "⚫ Preto", Cor = Color3.fromRGB(40, 40, 40)},
    {Nome = "🔵 Azul", Cor = Color3.fromRGB(0, 100, 255)},
    {Nome = "🟢 Verde", Cor = Color3.fromRGB(0, 150, 0)},
    {Nome = "🟣 Roxo", Cor = Color3.fromRGB(150, 0, 150)},
    {Nome = "🔴 Vermelho", Cor = Color3.fromRGB(200, 0, 0)},
    {Nome = "⚪ Branco", Cor = Color3.fromRGB(255, 255, 255)},
    {Nome = "🟡 Amarelo", Cor = Color3.fromRGB(255, 200, 0)}
}

function getRoot()
    local character = player.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function getHumanoid()
    local character = player.Character
    if character then
        return character:FindFirstChild("Humanoid")
    end
    return nil
end

-- =============================================
-- FUNÇÕES DAS NOVAS FUNCIONALIDADES
-- =============================================

function antiAfkLoop()
    spawn(function()
        while getgenv().CoringaFarm.AntiAfk do
            wait(60)
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

function vooLoop()
    spawn(function()
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        
        while getgenv().CoringaFarm.Voo do
            local root = getRoot()
            if root then
                bodyVelocity.Parent = root
                
                local moveDirection = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -50) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 50) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-50, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(50, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 50, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection + Vector3.new(0, -50, 0) end
                
                bodyVelocity.Velocity = moveDirection
            end
            wait()
        end
        if bodyVelocity then bodyVelocity:Destroy() end
    end)
end

function noclipLoop()
    spawn(function()
        while getgenv().CoringaFarm.Noclip do
            local character = player.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            wait(0.1)
        end
    end)
end

function gravidadeZeroLoop()
    spawn(function()
        while getgenv().CoringaFarm.GravidadeZero do
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = 200
                humanoid.WalkSpeed = 50
            end
            wait()
        end
    end)
end

function invisivelLoop()
    spawn(function()
        while getgenv().CoringaFarm.Invisivel do
            local character = player.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                    end
                end
            end
            wait()
        end
        local character = player.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end)
end

function vidaInfinitaLoop()
    spawn(function()
        while getgenv().CoringaFarm.VidaInfinita do
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
            end
            wait(0.5)
        end
    end)
end

function escudoLoop()
    spawn(function()
        while getgenv().CoringaFarm.Escudo do
            local character = player.Character
            if character then
                local shield = Instance.new("ForceField")
                shield.Name = "Shield"
                shield.Parent = character
            end
            wait(5)
            if character then
                local shield = character:FindFirstChild("Shield")
                if shield then shield:Destroy() end
            end
            wait(1)
        end
    end)
end

function autoComerLoop()
    spawn(function()
        while getgenv().CoringaFarm.AutoComer do
            local humanoid = getHumanoid()
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.Health + 10
            end
            wait(2)
        end
    end)
end

function detectarPerigosLoop()
    spawn(function()
        while getgenv().CoringaFarm.DetectarPerigos do
            perigosProximos = {}
            local root = getRoot()
            if root then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") and obj.Name:find("Lava") or obj.Name:find("Spike") or obj.Name:find("Kill") then
                        local dist = (obj.Position - root.Position).Magnitude
                        if dist < 50 then
                            table.insert(perigosProximos, {obj = obj, dist = dist})
                        end
                    end
                end
            end
            wait(1)
        end
    end)
end

function verJogadoresProximos()
    jogadoresProximos = {}
    local root = getRoot()
    if root then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local otherChar = otherPlayer.Character
                if otherChar and otherChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (otherChar.HumanoidRootPart.Position - root.Position).Magnitude
                    table.insert(jogadoresProximos, {player = otherPlayer, dist = dist})
                end
            end
        end
        table.sort(jogadoresProximos, function(a, b) return a.dist < b.dist end)
    end
    atualizarUI()
end

function espiarJogador(alvo)
    getgenv().CoringaFarm.Espiando = alvo
    spawn(function()
        while getgenv().CoringaFarm.Espiando do
            local root = getRoot()
            local alvoChar = alvo.Character
            if root and alvoChar and alvoChar:FindFirstChild("HumanoidRootPart") then
                root.CFrame = alvoChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
            end
            wait(0.1)
        end
    end)
end

function autoFarm(currentRun)
    local Character = player.Character
    if not Character then 
        player.CharacterAdded:Wait()
        Character = player.Character
    end
    
    local BoatStages = Workspace:FindFirstChild("BoatStages")
    if not BoatStages then wait(2) return end
    
    local NormalStages = BoatStages:FindFirstChild("NormalStages")
    if not NormalStages then wait(2) return end

    for i = 1, 10 do
        if not farmAtivo then break end
        
        local Stage = NormalStages:FindFirstChild("CaveStage" .. i)
        if Stage then
            local DarknessPart = Stage:FindFirstChild("DarknessPart")
            if DarknessPart then
                Character.HumanoidRootPart.CFrame = DarknessPart.CFrame
                
                local Part = Instance.new("Part")
                Part.Anchored = true
                Part.Position = Character.HumanoidRootPart.Position - Vector3.new(0, 6, 0)
                Part.Parent = Character
                
                wait(getgenv().CoringaFarm.Teleport)
                Part:Destroy()
                
                faseAtual = i
                atualizarUI()
            end
        end
    end

    if farmAtivo then
        local TheEnd = NormalStages:FindFirstChild("TheEnd")
        if TheEnd then
            local GoldenChest = TheEnd:FindFirstChild("GoldenChest")
            if GoldenChest then
                local Trigger = GoldenChest:FindFirstChild("Trigger")
                if Trigger then
                    repeat 
                        wait()
                        Character.HumanoidRootPart.CFrame = Trigger.CFrame
                    until Lighting.ClockTime ~= 14 or not farmAtivo
                    
                    if farmAtivo then
                        ouroTotal = ouroTotal + 100
                        atualizarUI()
                    end
                end
            end
        end
    end

    if farmAtivo then
        local Respawned = false
        local Connection
        Connection = player.CharacterAdded:Connect(function()
            Respawned = true
            Connection:Disconnect()
            wait(2)
            faseAtual = 1
            atualizarUI()
        end)

        local tempoEspera = 0
        while not Respawned and farmAtivo and tempoEspera < 30 do
            wait(1)
            tempoEspera = tempoEspera + 1
        end
        
        wait(getgenv().CoringaFarm.TimeBetweenRuns)
    end
end

function iniciarFarmOriginal()
    runAtual = 1
    while farmAtivo do
        if farmAtivo then
            pcall(function() autoFarm(runAtual) end)
            runAtual = runAtual + 1
            atualizarUI()
        end
        wait(1)
    end
end

function teleportarParaCor(teamInfo)
    local root = getRoot()
    if not root then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            if otherChar and otherChar:FindFirstChild("HumanoidRootPart") then
                root.CFrame = otherChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 2)
                break
            end
        end
    end
    
    submenuVisivel = ""
    btnTimes.Text = "👥 TIMES"
    btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
end

function teleportarParaJogador(nick)
    if not nick or nick == "" then return end
    
    local alvo = Players:FindFirstChild(nick)
    if not alvo then return end
    
    local root = getRoot()
    if not root then return end
    
    local alvoChar = alvo.Character
    if not alvoChar then return end
    
    local alvoRoot = alvoChar:FindFirstChild("HumanoidRootPart")
    if not alvoRoot then return end
    
    root.CFrame = alvoRoot.CFrame * CFrame.new(0, 3, 2)
    
    if submenuVisivel == "TP" then
        submenuVisivel = ""
        btnTP.Text = "👤 TP"
        btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoringaFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.DisplayOrder = 999

local botaoFlutuante = Instance.new("TextButton")
botaoFlutuante.Size = UDim2.new(0, 35, 0, 35)
botaoFlutuante.Position = UDim2.new(0.02, 0, 0.5, -17)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
botaoFlutuante.Text = "⚡"
botaoFlutuante.TextColor3 = Color3.fromRGB(0, 0, 0)
botaoFlutuante.TextSize = 18
botaoFlutuante.Font = Enum.Font.GothamBold
botaoFlutuante.Visible = false
botaoFlutuante.Active = true
botaoFlutuante.Draggable = true
botaoFlutuante.Parent = screenGui
Instance.new("UICorner", botaoFlutuante).CornerRadius = UDim.new(1, 0)

local frame = Instance.new("Frame")
frame.Size = tamanhoOriginal
frame.Position = UDim2.new(0.5, -275, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
title.Text = "⚡ CORINGA ULTIMATE ⚡"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local btnMinimizar = Instance.new("TextButton")
btnMinimizar.Size = UDim2.new(0, 22, 0, 22)
btnMinimizar.Position = UDim2.new(1, -50, 0, 6)
btnMinimizar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
btnMinimizar.Text = "➖"
btnMinimizar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinimizar.TextSize = 14
btnMinimizar.Font = Enum.Font.GothamBold
btnMinimizar.Parent = frame
Instance.new("UICorner", btnMinimizar).CornerRadius = UDim.new(0, 4)

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 22, 0, 22)
btnFechar.Position = UDim2.new(1, -24, 0, 6)
btnFechar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
btnFechar.Text = "✖"
btnFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFechar.TextSize = 14
btnFechar.Font = Enum.Font.GothamBold
btnFechar.Parent = frame
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 4)

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -10, 1, -40)
container.Position = UDim2.new(0, 5, 0, 35)
container.BackgroundTransparency = 1
container.Parent = frame

-- =============================================
-- STATUS BAR
-- =============================================
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 25)
statusFrame.BackgroundTransparency = 1
statusFrame.Parent = container

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 45, 0, 25)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.Text = "⚪"
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = statusFrame
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 4)

local ouroLabel = Instance.new("TextLabel")
ouroLabel.Size = UDim2.new(0, 70, 0, 25)
ouroLabel.Position = UDim2.new(0, 50, 0, 0)
ouroLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ouroLabel.Text = "💰 0"
ouroLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
ouroLabel.TextSize = 12
ouroLabel.Font = Enum.Font.GothamBold
ouroLabel.Parent = statusFrame
Instance.new("UICorner", ouroLabel).CornerRadius = UDim.new(0, 4)

local faseLabel = Instance.new("TextLabel")
faseLabel.Size = UDim2.new(0, 65, 0, 25)
faseLabel.Position = UDim2.new(0, 125, 0, 0)
faseLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
faseLabel.Text = "🚢 1/10"
faseLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
faseLabel.TextSize = 10
faseLabel.Font = Enum.Font.GothamBold
faseLabel.Parent = statusFrame
Instance.new("UICorner", faseLabel).CornerRadius = UDim.new(0, 4)

local runLabel = Instance.new("TextLabel")
runLabel.Size = UDim2.new(0, 45, 0, 25)
runLabel.Position = UDim2.new(0, 195, 0, 0)
runLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
runLabel.Text = "🔄 1"
runLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
runLabel.TextSize = 10
runLabel.Font = Enum.Font.GothamBold
runLabel.Parent = statusFrame
Instance.new("UICorner", runLabel).CornerRadius = UDim.new(0, 4)

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0, 55, 0, 25)
timerLabel.Position = UDim2.new(0, 245, 0, 0)
timerLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
timerLabel.Text = "⏱️ 0s"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 10
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = statusFrame
Instance.new("UICorner", timerLabel).CornerRadius = UDim.new(0, 4)

-- =============================================
-- BOTÕES PRINCIPAIS
-- =============================================
local botoesFrame = Instance.new("Frame")
botoesFrame.Size = UDim2.new(1, 0, 0, 40)
botoesFrame.Position = UDim2.new(0, 0, 0, 30)
botoesFrame.BackgroundTransparency = 1
botoesFrame.Parent = container

local btnIniciar = Instance.new("TextButton")
btnIniciar.Size = UDim2.new(0, 90, 0, 40)
btnIniciar.Position = UDim2.new(0, 0, 0, 0)
btnIniciar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnIniciar.Text = "▶️ FARM"
btnIniciar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnIniciar.TextSize = 11
btnIniciar.Font = Enum.Font.GothamBold
btnIniciar.Parent = botoesFrame
Instance.new("UICorner", btnIniciar).CornerRadius = UDim.new(0, 4)

local btnVelocidade = Instance.new("TextButton")
btnVelocidade.Size = UDim2.new(0, 90, 0, 40)
btnVelocidade.Position = UDim2.new(0, 100, 0, 0)
btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
btnVelocidade.Text = "⚡ NORMAL"
btnVelocidade.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVelocidade.TextSize = 10
btnVelocidade.Font = Enum.Font.GothamBold
btnVelocidade.Parent = botoesFrame
Instance.new("UICorner", btnVelocidade).CornerRadius = UDim.new(0, 4)

local btnTimes = Instance.new("TextButton")
btnTimes.Size = UDim2.new(0, 90, 0, 40)
btnTimes.Position = UDim2.new(0, 200, 0, 0)
btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
btnTimes.Text = "👥 TIMES"
btnTimes.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTimes.TextSize = 10
btnTimes.Font = Enum.Font.GothamBold
btnTimes.Parent = botoesFrame
Instance.new("UICorner", btnTimes).CornerRadius = UDim.new(0, 4)

local btnTP = Instance.new("TextButton")
btnTP.Size = UDim2.new(0, 90, 0, 40)
btnTP.Position = UDim2.new(0, 300, 0, 0)
btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
btnTP.Text = "👤 TP"
btnTP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTP.TextSize = 10
btnTP.Font = Enum.Font.GothamBold
btnTP.Parent = botoesFrame
Instance.new("UICorner", btnTP).CornerRadius = UDim.new(0, 4)

local btnUtilidades = Instance.new("TextButton")
btnUtilidades.Size = UDim2.new(0, 90, 0, 40)
btnUtilidades.Position = UDim2.new(0, 400, 0, 0)
btnUtilidades.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
btnUtilidades.Text = "🛠️ UTIL"
btnUtilidades.TextColor3 = Color3.fromRGB(255, 255, 255)
btnUtilidades.TextSize = 10
btnUtilidades.Font = Enum.Font.GothamBold
btnUtilidades.Parent = botoesFrame
Instance.new("UICorner", btnUtilidades).CornerRadius = UDim.new(0, 4)

-- =============================================
-- SUBMENU DE UTILIDADES (CONTINUAÇÃO)
-- =============================================
local utilFrame = Instance.new("Frame")
utilFrame.Size = UDim2.new(1, 0, 0, 200)
utilFrame.Position = UDim2.new(0, 0, 0, 75)
utilFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
utilFrame.BackgroundTransparency = 0.1
utilFrame.Visible = false
utilFrame.Parent = container
Instance.new("UICorner", utilFrame).CornerRadius = UDim.new(0, 6)

local utilTitle = Instance.new("TextLabel")
utilTitle.Size = UDim2.new(1, 0, 0, 25)
utilTitle.BackgroundTransparency = 1
utilTitle.Text = "⚙️ UTILIDADES"
utilTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
utilTitle.TextSize = 12
utilTitle.Font = Enum.Font.GothamBold
utilTitle.Parent = utilFrame

-- Botões de utilidades (4 colunas)
local utilBotoes = {
    {nome = "🛡️ Anti-AFK", var = "AntiAfk", cor = Color3.fromRGB(100, 100, 100)},
    {nome = "✈️ Voo", var = "Voo", cor = Color3.fromRGB(0, 150, 255)},
    {nome = "🧱 Noclip", var = "Noclip", cor = Color3.fromRGB(150, 75, 0)},
    {nome = "🌌 Gravidade Zero", var = "GravidadeZero", cor = Color3.fromRGB(150, 0, 150)},
    {nome = "👻 Invisível", var = "Invisivel", cor = Color3.fromRGB(100, 100, 100)},
    {nome = "❤️ Vida Infinita", var = "VidaInfinita", cor = Color3.fromRGB(255, 0, 0)},
    {nome = "🛡️ Escudo", var = "Escudo", cor = Color3.fromRGB(0, 0, 255)},
    {nome = "🍔 Auto Comer", var = "AutoComer", cor = Color3.fromRGB(255, 150, 0)},
    {nome = "⚠️ Detectar Perigos", var = "DetectarPerigos", cor = Color3.fromRGB(255, 255, 0)},
    {nome = "👥 Ver Jogadores", var = "verJogadores", cor = Color3.fromRGB(0, 255, 0)},
    {nome = "👁️ Espiar", var = "espiar", cor = Color3.fromRGB(255, 0, 255)},
}

local posX, posY = 10, 30
local coluna = 0

for i, botao in pairs(utilBotoes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 30)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = botao.cor
    btn.Text = botao.nome
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.Parent = utilFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        if botao.var == "verJogadores" then
            verJogadoresProximos()
        elseif botao.var == "espiar" then
            if jogadoresProximos[1] then
                espiarJogador(jogadoresProximos[1].player)
            end
        else
            getgenv().CoringaFarm[botao.var] = not getgenv().CoringaFarm[botao.var]
            btn.BackgroundColor3 = getgenv().CoringaFarm[botao.var] and Color3.fromRGB(0, 255, 0) or botao.cor
            
            if botao.var == "AntiAfk" then antiAfkLoop()
            elseif botao.var == "Voo" then vooLoop()
            elseif botao.var == "Noclip" then noclipLoop()
            elseif botao.var == "GravidadeZero" then gravidadeZeroLoop()
            elseif botao.var == "Invisivel" then invisivelLoop()
            elseif botao.var == "VidaInfinita" then vidaInfinitaLoop()
            elseif botao.var == "Escudo" then escudoLoop()
            elseif botao.var == "AutoComer" then autoComerLoop()
            elseif botao.var == "DetectarPerigos" then detectarPerigosLoop()
            end
        end
    end)
    
    posX = posX + 120
    coluna = coluna + 1
    if coluna == 4 then
        coluna = 0
        posX = 10
        posY = 70
    end
end

-- =============================================
-- LISTA DE JOGADORES PRÓXIMOS
-- =============================================
local jogadoresFrame = Instance.new("Frame")
jogadoresFrame.Size = UDim2.new(1, 0, 0, 150)
jogadoresFrame.Position = UDim2.new(0, 0, 0, 280)
jogadoresFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
jogadoresFrame.BackgroundTransparency = 0.1
jogadoresFrame.Visible = false
jogadoresFrame.Parent = container
Instance.new("UICorner", jogadoresFrame).CornerRadius = UDim.new(0, 6)

local jogadoresTitle = Instance.new("TextLabel")
jogadoresTitle.Size = UDim2.new(1, 0, 0, 25)
jogadoresTitle.BackgroundTransparency = 1
jogadoresTitle.Text = "👥 JOGADORES PRÓXIMOS"
jogadoresTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
jogadoresTitle.TextSize = 12
jogadoresTitle.Font = Enum.Font.GothamBold
jogadoresTitle.Parent = jogadoresFrame

local jogadoresLista = Instance.new("ScrollingFrame")
jogadoresLista.Size = UDim2.new(1, -10, 1, -35)
jogadoresLista.Position = UDim2.new(0, 5, 0, 30)
jogadoresLista.BackgroundTransparency = 1
jogadoresLista.ScrollBarThickness = 5
jogadoresLista.CanvasSize = UDim2.new(0, 0, 0, 0)
jogadoresLista.Parent = jogadoresFrame

function atualizarListaJogadores()
    for _, child in pairs(jogadoresLista:GetChildren()) do
        child:Destroy()
    end
    
    local yPos = 0
    for _, info in pairs(jogadoresProximos) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.Text = info.player.Name .. " | " .. math.floor(info.dist) .. "m"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.Parent = jogadoresLista
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            espiarJogador(info.player)
        end)
        
        yPos = yPos + 30
    end
    jogadoresLista.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- =============================================
-- SUBMENU DE CORES
-- =============================================
local submenuTimes = Instance.new("Frame")
submenuTimes.Size = UDim2.new(1, 0, 0, 80)
submenuTimes.Position = UDim2.new(0, 0, 0, 75)
submenuTimes.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
submenuTimes.BackgroundTransparency = 0.1
submenuTimes.Visible = false
submenuTimes.Parent = container
Instance.new("UICorner", submenuTimes).CornerRadius = UDim.new(0, 6)

local posX, posY = 10, 10
local colunas = 0

for i, corInfo in pairs(coresTimes) do
    local btnCor = Instance.new("TextButton")
    btnCor.Size = UDim2.new(0, 100, 0, 25)
    btnCor.Position = UDim2.new(0, posX, 0, posY)
    btnCor.BackgroundColor3 = corInfo.Cor
    btnCor.Text = corInfo.Nome
    btnCor.TextColor3 = corInfo.Cor.r + corInfo.Cor.g + corInfo.Cor.b > 1.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    btnCor.TextSize = 10
    btnCor.Font = Enum.Font.GothamBold
    btnCor.Parent = submenuTimes
    Instance.new("UICorner", btnCor).CornerRadius = UDim.new(0, 4)
    
    btnCor.MouseButton1Click:Connect(function() teleportarParaCor(corInfo) end)
    
    posX = posX + 110
    colunas = colunas + 1
    if colunas == 4 then
        colunas = 0
        posX = 10
        posY = 45
    end
end

-- =============================================
-- CAIXA DE TP
-- =============================================
local tpBox = Instance.new("Frame")
tpBox.Size = UDim2.new(1, 0, 0, 70)
tpBox.Position = UDim2.new(0, 0, 0, 75)
tpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tpBox.BackgroundTransparency = 0.1
tpBox.Visible = false
tpBox.Parent = container
Instance.new("UICorner", tpBox).CornerRadius = UDim.new(0, 6)

local tpInput = Instance.new("TextBox")
tpInput.Size = UDim2.new(0.7, 0, 0, 25)
tpInput.Position = UDim2.new(0.15, 0, 0.1, 0)
tpInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
tpInput.PlaceholderText = "Digite o nick..."
tpInput.Text = ""
tpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
tpInput.TextSize = 11
tpInput.Font = Enum.Font.Gotham
tpInput.ClearTextOnFocus = false
tpInput.Parent = tpBox
Instance.new("UICorner", tpInput).CornerRadius = UDim.new(0, 4)

local btnConfirmar = Instance.new("TextButton")
btnConfirmar.Size = UDim2.new(0.4, 0, 0, 25)
btnConfirmar.Position = UDim2.new(0.3, 0, 0.55, 0)
btnConfirmar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnConfirmar.Text = "✅ IR"
btnConfirmar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnConfirmar.TextSize = 11
btnConfirmar.Font = Enum.Font.GothamBold
btnConfirmar.Parent = tpBox
Instance.new("UICorner", btnConfirmar).CornerRadius = UDim.new(0, 4)

btnConfirmar.MouseButton1Click:Connect(function() teleportarParaJogador(tpInput.Text) end)
tpInput.FocusLost:Connect(function(enter) if enter then teleportarParaJogador(tpInput.Text) end end)

function atualizarUI()
    statusLabel.Text = farmAtivo and "🟢" or "⚪"
    statusLabel.TextColor3 = farmAtivo and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    ouroLabel.Text = "💰 " .. ouroTotal
    faseLabel.Text = "🚢 " .. faseAtual .. "/10"
    runLabel.Text = "🔄 " .. runAtual
    timerLabel.Text = "⏱️ " .. temporizador .. "s"
    
    if getgenv().CoringaFarm.DetectarPerigos and #perigosProximos > 0 then
        timerLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    else
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

function minimizarMenu()
    menuMinimizado = not menuMinimizado
    local alvoSize = menuMinimizado and tamanhoMinimizado or tamanhoOriginal
    TweenService:Create(frame, TweenInfo.new(0.2), {Size = alvoSize}):Play()
    
    if menuMinimizado then
        botaoFlutuante.Visible = true
        btnMinimizar.Text = "⬜"
    else
        botaoFlutuante.Visible = false
        btnMinimizar.Text = "➖"
    end
end

botaoFlutuante.MouseButton1Click:Connect(minimizarMenu)

btnIniciar.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    getgenv().CoringaFarm.Enabled = farmAtivo
    btnIniciar.Text = farmAtivo and "⏸️ PAUSAR" or "▶️ FARM"
    atualizarUI()
    
    if farmAtivo then
        spawn(iniciarFarmOriginal)
    end
end)

btnVelocidade.MouseButton1Click:Connect(function()
    if getgenv().CoringaFarm.Teleport == 2 then
        getgenv().CoringaFarm.Teleport = 0.5
        btnVelocidade.Text = "⚡ RÁPIDO"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    elseif getgenv().CoringaFarm.Teleport == 0.5 then
        getgenv().CoringaFarm.Teleport = 3
        btnVelocidade.Text = "🐢 LENTO"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    else
        getgenv().CoringaFarm.Teleport = 2
        btnVelocidade.Text = "⚡ NORMAL"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    end
end)

btnTimes.MouseButton1Click:Connect(function()
    submenuVisivel = submenuVisivel == "TIMES" and "" or "TIMES"
    submenuTimes.Visible = submenuVisivel == "TIMES"
    tpBox.Visible = false
    utilFrame.Visible = false
    jogadoresFrame.Visible = false
    btnTimes.Text = submenuVisivel == "TIMES" and "❌ FECHAR" or "👥 TIMES"
end)

btnTP.MouseButton1Click:Connect(function()
    submenuVisivel = submenuVisivel == "TP" and "" or "TP"
    tpBox.Visible = submenuVisivel == "TP"
    submenuTimes.Visible = false
    utilFrame.Visible = false
    jogadoresFrame.Visible = false
    btnTP.Text = submenuVisivel == "TP" and "❌ FECHAR" or "👤 TP"
    if submenuVisivel == "TP" then
        tpInput.Text = ""
        tpInput:CaptureFocus()
    end
end)

btnUtilidades.MouseButton1Click:Connect(function()
    submenuVisivel = submenuVisivel == "UTIL" and "" or "UTIL"
    utilFrame.Visible = submenuVisivel == "UTIL"
    jogadoresFrame.Visible = false
    submenuTimes.Visible = false
    tpBox.Visible = false
    btnUtilidades.Text = submenuVisivel == "UTIL" and "❌ FECHAR" or "🛠️ UTIL"
    
    if submenuVisivel == "UTIL" then
        verJogadoresProximos()
        atualizarListaJogadores()
        jogadoresFrame.Visible = true
    end
end)

btnMinimizar.MouseButton1Click:Connect(minimizarMenu)
btnFechar.MouseButton1Click:Connect(function() farmAtivo = false getgenv().CoringaFarm.Enabled = false screenGui:Destroy() end)

-- Loop do temporizador
spawn(function()
    while true do
        wait(1)
        if farmAtivo then
            temporizador = temporizador + 1
        end
        atualizarUI()
    end
end)

atualizarUI()

frame.BackgroundTransparency = 1
for i = 1, 10 do wait(0.02) frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1 end