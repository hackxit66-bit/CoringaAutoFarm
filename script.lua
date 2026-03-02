local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

getgenv().TreasureAutoFarm = {
    Enabled = false,
    Teleport = 2,
    TimeBetweenRuns = 5
}

local farmAtivo = false
local ouroTotal = 0
local faseAtual = 1
local runAtual = 1
local menuMinimizado = false
local submenuTimesVisivel = false
local tpBoxVisivel = false
local tamanhoOriginal = UDim2.new(0, 320, 0, 280)
local tamanhoMinimizado = UDim2.new(0, 120, 0, 30)

local coresTimes = {
    {Nome = " Preto", Cor = Color3.fromRGB(40, 40, 40), TeamName = "Preto", TeamColor = BrickColor.new("Black"), 
     BaseNames = {"Preto", "Black", "BasePreta", "BlackBase"}},
    {Nome = " Azul", Cor = Color3.fromRGB(0, 100, 255), TeamName = "Azul", TeamColor = BrickColor.new("Bright blue"),
     BaseNames = {"Azul", "Blue", "BaseAzul", "BlueBase"}},
    {Nome = " Verde", Cor = Color3.fromRGB(0, 150, 0), TeamName = "Verde", TeamColor = BrickColor.new("Bright green"),
     BaseNames = {"Verde", "Green", "BaseVerde", "GreenBase"}},
    {Nome = " Roxo", Cor = Color3.fromRGB(150, 0, 150), TeamName = "Roxo", TeamColor = BrickColor.new("Bright violet"),
     BaseNames = {"Roxo", "Purple", "BaseRoxa", "PurpleBase"}},
    {Nome = " Vermelho", Cor = Color3.fromRGB(200, 0, 0), TeamName = "Vermelho", TeamColor = BrickColor.new("Bright red"),
     BaseNames = {"Vermelho", "Red", "BaseVermelha", "RedBase"}},
    {Nome = " Branco", Cor = Color3.fromRGB(255, 255, 255), TeamName = "Branco", TeamColor = BrickColor.new("White"),
     BaseNames = {"Branco", "White", "BaseBranca", "WhiteBase"}},
    {Nome = " Amarelo", Cor = Color3.fromRGB(255, 200, 0), TeamName = "Amarelo", TeamColor = BrickColor.new("Bright yellow"),
     BaseNames = {"Amarelo", "Yellow", "BaseAmarela", "YellowBase"}}
}

function getRoot()
    local character = player.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function autoFarm(currentRun)
    local Character = player.Character
    if not Character then 
        player.CharacterAdded:Wait()
        Character = player.Character
    end
    
    local BoatStages = Workspace:FindFirstChild("BoatStages")
    if not BoatStages then 
        wait(2)
        return
    end
    
    local NormalStages = BoatStages:FindFirstChild("NormalStages")
    if not NormalStages then 
        wait(2)
        return
    end

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
                
                wait(getgenv().TreasureAutoFarm.Teleport)
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
                        if Character and Character.HumanoidRootPart then
                            Character.HumanoidRootPart.CFrame = Trigger.CFrame
                        end
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
        Connection = player.CharacterAdded:Connect(function(newChar)
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
        
        wait(getgenv().TreasureAutoFarm.TimeBetweenRuns)
    end
end

function iniciarFarmOriginal()
    runAtual = 1
    while farmAtivo do
        if farmAtivo then
            local success, err = pcall(function()
                autoFarm(runAtual)
            end)
            
            if not success then
                wait(2)
            end
            
            runAtual = runAtual + 1
            atualizarUI()
        end
        wait(1)
    end
end

function teleportarParaCor(teamInfo)
    local root = getRoot()
    if not root then return end
    
    local encontrou = false
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("Model") then
            for _, nomeBase in pairs(teamInfo.BaseNames) do
                if obj.Name:find(nomeBase) or (obj.Name:find("Base") and obj.Name:find(teamInfo.TeamName)) then
                    if obj:IsA("Model") and obj.PrimaryPart then
                        root.CFrame = obj.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                        encontrou = true
                    elseif obj:IsA("Part") then
                        root.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
                        encontrou = true
                    end
                    if encontrou then break end
                end
            end
            if encontrou then break end
        end
    end
    
    if not encontrou then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local otherChar = otherPlayer.Character
                if otherChar and otherChar:FindFirstChild("HumanoidRootPart") then
                    root.CFrame = otherChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 2)
                    encontrou = true
                    break
                end
            end
        end
    end
    
    if not encontrou then
        local character = player.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("Part") or part:IsA("MeshPart") then
                    part.BrickColor = teamInfo.TeamColor
                    part.Material = Enum.Material.Neon
                end
            end
        end
    end
    
    submenuTimes.Visible = false
    submenuTimesVisivel = false
    btnTimes.Text = ""
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
    
    if tpBoxVisivel then
        tpBox.Visible = false
        tpBoxVisivel = false
        btnTP.Text = ""
        btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoringaAutoFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.DisplayOrder = 999

local botaoFlutuante = Instance.new("TextButton")
botaoFlutuante.Size = UDim2.new(0, 35, 0, 35)
botaoFlutuante.Position = UDim2.new(0.02, 0, 0.5, -17)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
botaoFlutuante.Text = ""
botaoFlutuante.TextColor3 = Color3.fromRGB(0, 0, 0)
botaoFlutuante.TextSize = 20
botaoFlutuante.Font = Enum.Font.GothamBold
botaoFlutuante.Visible = false
botaoFlutuante.Active = true
botaoFlutuante.Draggable = true
botaoFlutuante.Parent = screenGui

local botaoCorner = Instance.new("UICorner")
botaoCorner.CornerRadius = UDim.new(1, 0)
botaoCorner.Parent = botaoFlutuante

local frame = Instance.new("Frame")
frame.Size = tamanhoOriginal
frame.Position = UDim2.new(0.5, -160, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
title.Text = " CORINGA "
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local btnMinimizar = Instance.new("TextButton")
btnMinimizar.Size = UDim2.new(0, 20, 0, 20)
btnMinimizar.Position = UDim2.new(1, -45, 0, 3)
btnMinimizar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
btnMinimizar.Text = ""
btnMinimizar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMinimizar.TextSize = 14
btnMinimizar.Font = Enum.Font.GothamBold
btnMinimizar.Parent = frame

local btnMinimizarCorner = Instance.new("UICorner")
btnMinimizarCorner.CornerRadius = UDim.new(0, 4)
btnMinimizarCorner.Parent = btnMinimizar

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 20, 0, 20)
btnFechar.Position = UDim2.new(1, -20, 0, 3)
btnFechar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
btnFechar.Text = ""
btnFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFechar.TextSize = 14
btnFechar.Font = Enum.Font.GothamBold
btnFechar.Parent = frame

local btnFecharCorner = Instance.new("UICorner")
btnFecharCorner.CornerRadius = UDim.new(0, 4)
btnFecharCorner.Parent = btnFechar

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -10, 1, -30)
container.Position = UDim2.new(0, 5, 0, 25)
container.BackgroundTransparency = 1
container.Parent = frame

local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 20)
statusFrame.BackgroundTransparency = 1
statusFrame.Parent = container

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 50, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = statusFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 4)
statusCorner.Parent = statusLabel

local ouroLabel = Instance.new("TextLabel")
ouroLabel.Size = UDim2.new(0, 60, 0, 20)
ouroLabel.Position = UDim2.new(0, 55, 0, 0)
ouroLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ouroLabel.Text = "0"
ouroLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
ouroLabel.TextSize = 12
ouroLabel.Font = Enum.Font.GothamBold
ouroLabel.Parent = statusFrame

local ouroCorner = Instance.new("UICorner")
ouroCorner.CornerRadius = UDim.new(0, 4)
ouroCorner.Parent = ouroLabel

local faseLabel = Instance.new("TextLabel")
faseLabel.Size = UDim2.new(0, 50, 0, 20)
faseLabel.Position = UDim2.new(0, 120, 0, 0)
faseLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
faseLabel.Text = "1/10"
faseLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
faseLabel.TextSize = 11
faseLabel.Font = Enum.Font.GothamBold
faseLabel.Parent = statusFrame

local faseCorner = Instance.new("UICorner")
faseCorner.CornerRadius = UDim.new(0, 4)
faseCorner.Parent = faseLabel

local runLabel = Instance.new("TextLabel")
runLabel.Size = UDim2.new(0, 40, 0, 20)
runLabel.Position = UDim2.new(0, 175, 0, 0)
runLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
runLabel.Text = "1"
runLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
runLabel.TextSize = 11
runLabel.Font = Enum.Font.GothamBold
runLabel.Parent = statusFrame

local runCorner = Instance.new("UICorner")
runCorner.CornerRadius = UDim.new(0, 4)
runCorner.Parent = runLabel

local botoesFrame = Instance.new("Frame")
botoesFrame.Size = UDim2.new(1, 0, 0, 30)
botoesFrame.Position = UDim2.new(0, 0, 0, 25)
botoesFrame.BackgroundTransparency = 1
botoesFrame.Parent = container

local btnIniciar = Instance.new("TextButton")
btnIniciar.Size = UDim2.new(0, 70, 0, 30)
btnIniciar.Position = UDim2.new(0, 0, 0, 0)
btnIniciar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnIniciar.Text = ""
btnIniciar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnIniciar.TextSize = 16
btnIniciar.Font = Enum.Font.GothamBold
btnIniciar.Parent = botoesFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = btnIniciar

local btnVelocidade = Instance.new("TextButton")
btnVelocidade.Size = UDim2.new(0, 70, 0, 30)
btnVelocidade.Position = UDim2.new(0, 75, 0, 0)
btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
btnVelocidade.Text = ""
btnVelocidade.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVelocidade.TextSize = 16
btnVelocidade.Font = Enum.Font.GothamBold
btnVelocidade.Parent = botoesFrame

local btnVelocidadeCorner = Instance.new("UICorner")
btnVelocidadeCorner.CornerRadius = UDim.new(0, 4)
btnVelocidadeCorner.Parent = btnVelocidade

local btnTimes = Instance.new("TextButton")
btnTimes.Size = UDim2.new(0, 70, 0, 30)
btnTimes.Position = UDim2.new(0, 150, 0, 0)
btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
btnTimes.Text = ""
btnTimes.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTimes.TextSize = 16
btnTimes.Font = Enum.Font.GothamBold
btnTimes.Parent = botoesFrame

local btnTimesCorner = Instance.new("UICorner")
btnTimesCorner.CornerRadius = UDim.new(0, 4)
btnTimesCorner.Parent = btnTimes

local btnTP = Instance.new("TextButton")
btnTP.Size = UDim2.new(0, 70, 0, 30)
btnTP.Position = UDim2.new(0, 225, 0, 0)
btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
btnTP.Text = ""
btnTP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTP.TextSize = 16
btnTP.Font = Enum.Font.GothamBold
btnTP.Parent = botoesFrame

local btnTPCorner = Instance.new("UICorner")
btnTPCorner.CornerRadius = UDim.new(0, 4)
btnTPCorner.Parent = btnTP

local submenuTimes = Instance.new("Frame")
submenuTimes.Size = UDim2.new(1, 0, 0, 90)
submenuTimes.Position = UDim2.new(0, 0, 0, 60)
submenuTimes.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
submenuTimes.BackgroundTransparency = 0.1
submenuTimes.Visible = false
submenuTimes.Parent = container

local submenuCorner = Instance.new("UICorner")
submenuCorner.CornerRadius = UDim.new(0, 6)
submenuCorner.Parent = submenuTimes

local posX = 5
local posY = 5
local colunas = 0

for i, corInfo in pairs(coresTimes) do
    local btnCor = Instance.new("TextButton")
    btnCor.Size = UDim2.new(0, 60, 0, 25)
    btnCor.Position = UDim2.new(0, posX, 0, posY)
    btnCor.BackgroundColor3 = corInfo.Cor
    btnCor.Text = string.sub(corInfo.Nome, 3, 3)
    btnCor.TextColor3 = corInfo.Cor.r + corInfo.Cor.g + corInfo.Cor.b > 1.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    btnCor.TextSize = 12
    btnCor.Font = Enum.Font.GothamBold
    btnCor.Parent = submenuTimes
    
    local btnCorCorner = Instance.new("UICorner")
    btnCorCorner.CornerRadius = UDim.new(0, 4)
    btnCorCorner.Parent = btnCor
    
    btnCor.MouseButton1Click:Connect(function()
        teleportarParaCor(corInfo)
    end)
    
    posX = posX + 65
    colunas = colunas + 1
    
    if colunas == 4 then
        colunas = 0
        posX = 5
        posY = 35
    end
end

local tpBox = Instance.new("Frame")
tpBox.Size = UDim2.new(1, 0, 0, 70)
tpBox.Position = UDim2.new(0, 0, 0, 60)
tpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tpBox.BackgroundTransparency = 0.1
tpBox.Visible = false
tpBox.Parent = container

local tpBoxCorner = Instance.new("UICorner")
tpBoxCorner.CornerRadius = UDim.new(0, 6)
tpBoxCorner.Parent = tpBox

local tpInput = Instance.new("TextBox")
tpInput.Size = UDim2.new(0.9, 0, 0, 25)
tpInput.Position = UDim2.new(0.05, 0, 0.1, 0)
tpInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
tpInput.PlaceholderText = "Nick..."
tpInput.Text = ""
tpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
tpInput.TextSize = 12
tpInput.Font = Enum.Font.Gotham
tpInput.ClearTextOnFocus = false
tpInput.Parent = tpBox

local tpInputCorner = Instance.new("UICorner")
tpInputCorner.CornerRadius = UDim.new(0, 4)
tpInputCorner.Parent = tpInput

local btnConfirmar = Instance.new("TextButton")
btnConfirmar.Size = UDim2.new(0.5, 0, 0, 25)
btnConfirmar.Position = UDim2.new(0.25, 0, 0.55, 0)
btnConfirmar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnConfirmar.Text = " IR"
btnConfirmar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnConfirmar.TextSize = 12
btnConfirmar.Font = Enum.Font.GothamBold
btnConfirmar.Parent = tpBox

local btnConfirmarCorner = Instance.new("UICorner")
btnConfirmarCorner.CornerRadius = UDim.new(0, 4)
btnConfirmarCorner.Parent = btnConfirmar

btnConfirmar.MouseButton1Click:Connect(function()
    teleportarParaJogador(tpInput.Text)
end)

tpInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        teleportarParaJogador(tpInput.Text)
    end
end)

function atualizarUI()
    if farmAtivo then
        statusLabel.Text = ""
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        statusLabel.Text = ""
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
    ouroLabel.Text = "" .. ouroTotal
    faseLabel.Text = "" .. faseAtual .. "/10"
    runLabel.Text = "" .. runAtual
end

function minimizarMenu()
    menuMinimizado = not menuMinimizado
    
    local alvoSize = menuMinimizado and tamanhoMinimizado or tamanhoOriginal
    local alvoTransparencia = menuMinimizado and 1 or 0
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(frame, tweenInfo, {Size = alvoSize})
    tween:Play()
    
    for _, obj in pairs(container:GetChildren()) do
        if obj:IsA("Frame") then
            local fadeTween = TweenService:Create(obj, tweenInfo, {BackgroundTransparency = alvoTransparencia})
            fadeTween:Play()
        end
    end
    
    if menuMinimizado then
        botaoFlutuante.Visible = true
        btnMinimizar.Text = ""
    else
        botaoFlutuante.Visible = false
        btnMinimizar.Text = ""
    end
end

botaoFlutuante.MouseButton1Click:Connect(function()
    if menuMinimizado then
        minimizarMenu()
    end
end)

btnIniciar.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    getgenv().TreasureAutoFarm.Enabled = farmAtivo
    btnIniciar.Text = farmAtivo and "" or ""
    atualizarUI()
    
    if farmAtivo then
        spawn(function()
            iniciarFarmOriginal()
        end)
        
        spawn(function()
            while farmAtivo do
                wait(60)
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    end
end)

btnVelocidade.MouseButton1Click:Connect(function()
    if getgenv().TreasureAutoFarm.Teleport == 2 then
        getgenv().TreasureAutoFarm.Teleport = 0.5
        btnVelocidade.Text = ""
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    elseif getgenv().TreasureAutoFarm.Teleport == 0.5 then
        getgenv().TreasureAutoFarm.Teleport = 3
        btnVelocidade.Text = ""
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    else
        getgenv().TreasureAutoFarm.Teleport = 2
        btnVelocidade.Text = ""
        btnVelocidade.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    end
end)

btnTimes.MouseButton1Click:Connect(function()
    if tpBoxVisivel then
        tpBox.Visible = false
        tpBoxVisivel = false
        btnTP.Text = ""
        btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end
    
    submenuTimesVisivel = not submenuTimesVisivel
    submenuTimes.Visible = submenuTimesVisivel
    btnTimes.Text = submenuTimesVisivel and "" or ""
    btnTimes.BackgroundColor3 = submenuTimesVisivel and Color3.fromRGB(150, 0, 150) or Color3.fromRGB(128, 0, 128)
end)

btnTP.MouseButton1Click:Connect(function()
    if submenuTimesVisivel then
        submenuTimes.Visible = false
        submenuTimesVisivel = false
        btnTimes.Text = ""
        btnTimes.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
    end
    
    tpBoxVisivel = not tpBoxVisivel
    tpBox.Visible = tpBoxVisivel
    btnTP.Text = tpBoxVisivel and "" or ""
    btnTP.BackgroundColor3 = tpBoxVisivel and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 100, 200)
    
    if tpBoxVisivel then
        tpInput.Text = ""
        tpInput:CaptureFocus()
    end
end)

btnMinimizar.MouseButton1Click:Connect(minimizarMenu)

btnFechar.MouseButton1Click:Connect(function()
    farmAtivo = false
    getgenv().TreasureAutoFarm.Enabled = false
    screenGui:Destroy()
end)

atualizarUI()

frame.BackgroundTransparency = 1
for i = 1, 10 do
    wait(0.02)
    frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1
end