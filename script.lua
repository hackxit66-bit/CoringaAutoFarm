local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

getgenv().CoringaFarm = {
    Enabled = false,
    Teleport = 2,
    TimeBetweenRuns = 5,
    Escudo = false,
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

local tamanhoOriginal = UDim2.new(0, 550, 0, 350)
local tamanhoMinimizado = UDim2.new(0, 100, 0, 30)

local coresTimes = {
    {Nome = " Preto", Cor = Color3.fromRGB(40, 40, 40)},
    {Nome = " Azul", Cor = Color3.fromRGB(0, 100, 255)},
    {Nome = " Verde", Cor = Color3.fromRGB(0, 150, 0)},
    {Nome = " Roxo", Cor = Color3.fromRGB(150, 0, 150)},
    {Nome = " Vermelho", Cor = Color3.fromRGB(200, 0, 0)},
    {Nome = " Branco", Cor = Color3.fromRGB(255, 255, 255)},
    {Nome = " Amarelo", Cor = Color3.fromRGB(255, 200, 0)}
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

function teleportarParaJogador(alvo)
    local root = getRoot()
    if not root then return end
    
    local alvoChar = alvo.Character
    if not alvoChar then return end
    
    local alvoRoot = alvoChar:FindFirstChild("HumanoidRootPart")
    if not alvoRoot then return end
    
    root.CFrame = alvoRoot.CFrame * CFrame.new(0, 3, 2)
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
    btnTimes.Text = " TIMES"
    btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoringaFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.DisplayOrder = 999

local botaoFlutuante = Instance.new("TextButton")
botaoFlutuante.Size = UDim2.new(0, 30, 0, 30)
botaoFlutuante.Position = UDim2.new(0.02, 0, 0.5, -15)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
botaoFlutuante.Text = ""
botaoFlutuante.TextColor3 = Color3.fromRGB(0, 0, 0)
botaoFlutuante.TextSize = 16
botaoFlutuante.Font = Enum.Font.GothamBold
botaoFlutuante.Visible = false
botaoFlutuante.Active = true
botaoFlutuante.Draggable = true
botaoFlutuante.Parent = screenGui
Instance.new("UICorner", botaoFlutuante).CornerRadius = UDim.new(1, 0)

local frame = Instance.new("Frame")
frame.Size = tamanhoOriginal
frame.Position = UDim2.new(0.5, -275, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
title.Text = " CORINGA ULTIMATE "
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local btnMinimizar = Instance.new("TextButton")
btnMinimizar.Size = UDim2.new(0, 20, 0, 20)
btnMinimizar.Position = UDim2.new(1, -45, 0, 5)
btnMinimizar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
btnMinimizar.Text = ""
btnMinimizar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinimizar.TextSize = 12
btnMinimizar.Font = Enum.Font.GothamBold
btnMinimizar.Parent = frame
Instance.new("UICorner", btnMinimizar).CornerRadius = UDim.new(0, 4)

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 20, 0, 20)
btnFechar.Position = UDim2.new(1, -20, 0, 5)
btnFechar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
btnFechar.Text = ""
btnFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFechar.TextSize = 12
btnFechar.Font = Enum.Font.GothamBold
btnFechar.Parent = frame
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 4)

-- =============================================
-- CONTAINER PRINCIPAL (DIVIDIDO EM DUAS COLUNAS)
-- =============================================
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -10, 1, -35)
container.Position = UDim2.new(0, 5, 0, 30)
container.BackgroundTransparency = 1
container.Parent = frame

-- COLUNA ESQUERDA (STATUS E BOTÕES)
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0.45, -5, 1, 0)
leftPanel.BackgroundTransparency = 1
leftPanel.Parent = container

-- COLUNA DIREITA (JOGADORES PRÓXIMOS)
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0.55, -5, 1, 0)
rightPanel.Position = UDim2.new(0.45, 5, 0, 0)
rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
rightPanel.BackgroundTransparency = 0.1
rightPanel.Parent = container
Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 6)

-- TÍTULO DO PAINEL DIREITO
local rightTitle = Instance.new("TextLabel")
rightTitle.Size = UDim2.new(1, -10, 0, 25)
rightTitle.Position = UDim2.new(0, 5, 0, 5)
rightTitle.BackgroundTransparency = 1
rightTitle.Text = " JOGADORES PRÓXIMOS"
rightTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
rightTitle.TextSize = 12
rightTitle.Font = Enum.Font.GothamBold
rightTitle.Parent = rightPanel

-- LISTA DE JOGADORES
local jogadoresLista = Instance.new("ScrollingFrame")
jogadoresLista.Size = UDim2.new(1, -10, 1, -35)
jogadoresLista.Position = UDim2.new(0, 5, 0, 30)
jogadoresLista.BackgroundTransparency = 1
jogadoresLista.ScrollBarThickness = 5
jogadoresLista.CanvasSize = UDim2.new(0, 0, 0, 0)
jogadoresLista.Parent = rightPanel

function atualizarListaJogadores()
    for _, child in pairs(jogadoresLista:GetChildren()) do
        child:Destroy()
    end
    
    local yPos = 0
    for _, info in pairs(jogadoresProximos) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.Text = info.player.Name .. " | " .. math.floor(info.dist) .. "m"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.Parent = jogadoresLista
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            teleportarParaJogador(info.player)
        end)
        
        yPos = yPos + 35
    end
    jogadoresLista.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- =============================================
-- PAINEL ESQUERDO - STATUS
-- =============================================
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 70)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusFrame.BackgroundTransparency = 0.1
statusFrame.Parent = leftPanel
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 6)

local statusTitle = Instance.new("TextLabel")
statusTitle.Size = UDim2.new(1, -10, 0, 20)
statusTitle.Position = UDim2.new(0, 5, 0, 5)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = " STATUS"
statusTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
statusTitle.TextSize = 11
statusTitle.Font = Enum.Font.GothamBold
statusTitle.Parent = statusFrame

local statusGrid = Instance.new("Frame")
statusGrid.Size = UDim2.new(1, -10, 0, 35)
statusGrid.Position = UDim2.new(0, 5, 0, 25)
statusGrid.BackgroundTransparency = 1
statusGrid.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.33, -2, 0, 35)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = statusGrid
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 4)

local ouroLabel = Instance.new("TextLabel")
ouroLabel.Size = UDim2.new(0.33, -2, 0, 35)
ouroLabel.Position = UDim2.new(0.33, 2, 0, 0)
ouroLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ouroLabel.Text = "0"
ouroLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
ouroLabel.TextSize = 12
ouroLabel.Font = Enum.Font.GothamBold
ouroLabel.Parent = statusGrid
Instance.new("UICorner", ouroLabel).CornerRadius = UDim.new(0, 4)

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.33, -2, 0, 35)
timerLabel.Position = UDim2.new(0.66, 4, 0, 0)
timerLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
timerLabel.Text = "0s"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 10
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = statusGrid
Instance.new("UICorner", timerLabel).CornerRadius = UDim.new(0, 4)

-- =============================================
-- BOTÕES PRINCIPAIS
-- =============================================
local botoesFrame = Instance.new("Frame")
botoesFrame.Size = UDim2.new(1, 0, 0, 200)
botoesFrame.Position = UDim2.new(0, 0, 0, 80)
botoesFrame.BackgroundTransparency = 1
botoesFrame.Parent = leftPanel

local btnIniciar = Instance.new("TextButton")
btnIniciar.Size = UDim2.new(1, 0, 0, 35)
btnIniciar.Position = UDim2.new(0, 0, 0, 0)
btnIniciar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnIniciar.Text = " INICIAR FARM"
btnIniciar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnIniciar.TextSize = 11
btnIniciar.Font = Enum.Font.GothamBold
btnIniciar.Parent = botoesFrame
Instance.new("UICorner", btnIniciar).CornerRadius = UDim.new(0, 4)

local btnVelocidade = Instance.new("TextButton")
btnVelocidade.Size = UDim2.new(1, 0, 0, 35)
btnVelocidade.Position = UDim2.new(0, 0, 0, 40)
btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
btnVelocidade.Text = " VELOCIDADE NORMAL"
btnVelocidade.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVelocidade.TextSize = 11
btnVelocidade.Font = Enum.Font.GothamBold
btnVelocidade.Parent = botoesFrame
Instance.new("UICorner", btnVelocidade).CornerRadius = UDim.new(0, 4)

local btnTimes = Instance.new("TextButton")
btnTimes.Size = UDim2.new(1, 0, 0, 35)
btnTimes.Position = UDim2.new(0, 0, 0, 80)
btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
btnTimes.Text = " TIMES"
btnTimes.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTimes.TextSize = 11
btnTimes.Font = Enum.Font.GothamBold
btnTimes.Parent = botoesFrame
Instance.new("UICorner", btnTimes).CornerRadius = UDim.new(0, 4)

local btnEscudo = Instance.new("TextButton")
btnEscudo.Size = UDim2.new(1, 0, 0, 35)
btnEscudo.Position = UDim2.new(0, 0, 0, 120)
btnEscudo.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
btnEscudo.Text = " ESCUDO OFF"
btnEscudo.TextColor3 = Color3.fromRGB(255, 255, 255)
btnEscudo.TextSize = 11
btnEscudo.Font = Enum.Font.GothamBold
btnEscudo.Parent = botoesFrame
Instance.new("UICorner", btnEscudo).CornerRadius = UDim.new(0, 4)

local btnAtualizar = Instance.new("TextButton")
btnAtualizar.Size = UDim2.new(1, 0, 0, 35)
btnAtualizar.Position = UDim2.new(0, 0, 0, 160)
btnAtualizar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnAtualizar.Text = " ATUALIZAR JOGADORES"
btnAtualizar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAtualizar.TextSize = 10
btnAtualizar.Font = Enum.Font.GothamBold
btnAtualizar.Parent = botoesFrame
Instance.new("UICorner", btnAtualizar).CornerRadius = UDim.new(0, 4)

-- =============================================
-- SUBMENU DE CORES
-- =============================================
local submenuContainer = Instance.new("Frame")
submenuContainer.Size = UDim2.new(1, 0, 0, 60)
submenuContainer.Position = UDim2.new(0, 0, 0, 285)
submenuContainer.BackgroundTransparency = 1
submenuContainer.Parent = leftPanel

local submenuTimes = Instance.new("Frame")
submenuTimes.Size = UDim2.new(1, 0, 0, 60)
submenuTimes.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
submenuTimes.BackgroundTransparency = 0.1
submenuTimes.Visible = false
submenuTimes.Parent = submenuContainer
Instance.new("UICorner", submenuTimes).CornerRadius = UDim.new(0, 6)

local posX, posY = 5, 5
local colunas = 0

for i, corInfo in pairs(coresTimes) do
    local btnCor = Instance.new("TextButton")
    btnCor.Size = UDim2.new(0, 70, 0, 20)
    btnCor.Position = UDim2.new(0, posX, 0, posY)
    btnCor.BackgroundColor3 = corInfo.Cor
    btnCor.Text = corInfo.Nome
    btnCor.TextColor3 = corInfo.Cor.r + corInfo.Cor.g + corInfo.Cor.b > 1.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    btnCor.TextSize = 8
    btnCor.Font = Enum.Font.GothamBold
    btnCor.Parent = submenuTimes
    Instance.new("UICorner", btnCor).CornerRadius = UDim.new(0, 4)
    
    btnCor.MouseButton1Click:Connect(function() teleportarParaCor(corInfo) end)
    
    posX = posX + 75
    colunas = colunas + 1
    if colunas == 3 then
        colunas = 0
        posX = 5
        posY = 30
    end
end

-- =============================================
-- FUNÇÕES DE ATUALIZAÇÃO
-- =============================================

function atualizarUI()
    statusLabel.Text = farmAtivo and "" or ""
    statusLabel.TextColor3 = farmAtivo and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    ouroLabel.Text = "" .. ouroTotal
    timerLabel.Text = "" .. temporizador .. "s"
    btnEscudo.Text = getgenv().CoringaFarm.Escudo and " ESCUDO ON" or " ESCUDO OFF"
    btnEscudo.BackgroundColor3 = getgenv().CoringaFarm.Escudo and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(0, 0, 150)
end

function minimizarMenu()
    menuMinimizado = not menuMinimizado
    local alvoSize = menuMinimizado and tamanhoMinimizado or tamanhoOriginal
    TweenService:Create(frame, TweenInfo.new(0.2), {Size = alvoSize}):Play()
    
    if menuMinimizado then
        botaoFlutuante.Visible = true
        btnMinimizar.Text = ""
    else
        botaoFlutuante.Visible = false
        btnMinimizar.Text = ""
    end
end

botaoFlutuante.MouseButton1Click:Connect(minimizarMenu)

btnIniciar.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    getgenv().CoringaFarm.Enabled = farmAtivo
    btnIniciar.Text = farmAtivo and " PAUSAR FARM" or " INICIAR FARM"
    atualizarUI()
    
    if farmAtivo then
        spawn(iniciarFarmOriginal)
    end
end)

btnVelocidade.MouseButton1Click:Connect(function()
    if getgenv().CoringaFarm.Teleport == 2 then
        getgenv().CoringaFarm.Teleport = 0.5
        btnVelocidade.Text = " VELOCIDADE RÁPIDA"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    elseif getgenv().CoringaFarm.Teleport == 0.5 then
        getgenv().CoringaFarm.Teleport = 3
        btnVelocidade.Text = " VELOCIDADE LENTA"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    else
        getgenv().CoringaFarm.Teleport = 2
        btnVelocidade.Text = " VELOCIDADE NORMAL"
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    end
end)

btnTimes.MouseButton1Click:Connect(function()
    submenuVisivel = submenuVisivel == "TIMES" and "" or "TIMES"
    submenuTimes.Visible = submenuVisivel == "TIMES"
    btnTimes.Text = submenuVisivel == "TIMES" and " FECHAR TIMES" or " TIMES"
end)

btnEscudo.MouseButton1Click:Connect(function()
    getgenv().CoringaFarm.Escudo = not getgenv().CoringaFarm.Escudo
    atualizarUI()
    escudoLoop()
end)

btnAtualizar.MouseButton1Click:Connect(function()
    verJogadoresProximos()
    atualizarListaJogadores()
end)

btnMinimizar.MouseButton1Click:Connect(minimizarMenu)
btnFechar.MouseButton1Click:Connect(function() 
    farmAtivo = false 
    getgenv().CoringaFarm.Enabled = false 
    screenGui:Destroy() 
end)

spawn(function()
    while true do
        wait(1)
        if farmAtivo then
            temporizador = temporizador + 1
        end
        atualizarUI()
    end
end)

spawn(function()
    while true do
        wait(3)
        verJogadoresProximos()
        atualizarListaJogadores()
    end
end)

atualizarUI()

frame.BackgroundTransparency = 1
for i = 1, 10 do 
    wait(0.02) 
    frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1 
end