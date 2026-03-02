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
    Velocidade = false,
    Invisivel = false,
    SuperPulo = false,
    AndarAgua = false,
    VisaoNoturna = false,
    EfeitosParticulas = false,
    Noclip = false,
    VidaInfinita = false
}

local farmAtivo = false
local ouroTotal = 0
local faseAtual = 1
local runAtual = 1
local menuMinimizado = false
local mostrandoJogadores = true
local mostrandoPlayers = false
local mostrandoTimes = false
local mostrandoConfig = false
local temporizador = 0
local jogadoresProximos = {}
local farmCancelado = false
local idiomaAtual = "portugues"
local tamanhoOriginal = UDim2.new(0, 400, 0, 300)
local tamanhoMinimizado = UDim2.new(0, 80, 0, 25)
local efeitos = {}

-- =============================================
-- TEXTOS DOS IDIOMAS
-- =============================================
local textos = {
    portugues = {
        titulo = " CORINGA ",
        iniciar = " INICIAR",
        pausar = " PAUSAR",
        velocidade = " VEL NORMAL",
        velRapida = " VEL RÁPIDA",
        velLenta = " VEL LENTA",
        times = " TIMES",
        fecharTimes = " FECHAR TIMES",
        player = " PLAYER",
        fecharPlayer = " FECHAR PLAYER",
        config = " CONFIG",
        fecharConfig = " FECHAR CONFIG",
        jogadores = " JOGADORES",
        timesTitulo = " TIMES",
        playerTitulo = " PLAYER",
        configTitulo = " CONFIGURAÇÕES",
        idioma = " IDIOMA",
        portuguesOpcao = " Português",
        inglesOpcao = " English",
        espanholOpcao = " Español",
        velocidadeNome = " Velocidade",
        invisivelNome = " Invisível",
        superPuloNome = " Super Pulo",
        escudoNome = " Escudo",
        andarAguaNome = " Andar na Água",
        visaoNoturnaNome = " Visão Noturna",
        efeitosNome = " Efeitos",
        noclipNome = " NoClip",
        vidaInfinitaNome = " Vida Infinita"
    },
    english = {
        titulo = " CORINGA ",
        iniciar = " START",
        pausar = " PAUSE",
        velocidade = " SPEED NORMAL",
        velRapida = " FAST SPEED",
        velLenta = " SLOW SPEED",
        times = " TEAMS",
        fecharTimes = " CLOSE TEAMS",
        player = " PLAYER",
        fecharPlayer = " CLOSE PLAYER",
        config = " SETTINGS",
        fecharConfig = " CLOSE SETTINGS",
        jogadores = " PLAYERS",
        timesTitulo = " TEAMS",
        playerTitulo = " PLAYER",
        configTitulo = " SETTINGS",
        idioma = " LANGUAGE",
        portuguesOpcao = " Portuguese",
        inglesOpcao = " English",
        espanholOpcao = " Spanish",
        velocidadeNome = " Speed",
        invisivelNome = " Invisible",
        superPuloNome = " Super Jump",
        escudoNome = " Shield",
        andarAguaNome = " Water Walk",
        visaoNoturnaNome = " Night Vision",
        efeitosNome = " Effects",
        noclipNome = " NoClip",
        vidaInfinitaNome = " Infinite Life"
    },
    espanol = {
        titulo = " CORINGA ",
        iniciar = " INICIAR",
        pausar = " PAUSAR",
        velocidade = " VEL NORMAL",
        velRapida = " VEL RÁPIDA",
        velLenta = " VEL LENTA",
        times = " EQUIPOS",
        fecharTimes = " CERRAR EQUIPOS",
        player = " JUGADOR",
        fecharPlayer = " CERRAR JUGADOR",
        config = " CONFIG",
        fecharConfig = " CERRAR CONFIG",
        jogadores = " JUGADORES",
        timesTitulo = " EQUIPOS",
        playerTitulo = " JUGADOR",
        configTitulo = " CONFIGURACIÓN",
        idioma = " IDIOMA",
        portuguesOpcao = " Portugués",
        inglesOpcao = " Inglés",
        espanholOpcao = " Español",
        velocidadeNome = " Velocidad",
        invisivelNome = " Invisible",
        superPuloNome = " Super Salto",
        escudoNome = " Escudo",
        andarAguaNome = " Caminar Agua",
        visaoNoturnaNome = " Visión Nocturna",
        efeitosNome = " Efectos",
        noclipNome = " NoClip",
        vidaInfinitaNome = " Vida Infinita"
    }
}

local coresTimes = {
    {Nome = " Preto", Cor = Color3.fromRGB(40, 40, 40), TeamColor = BrickColor.new("Black")},
    {Nome = " Azul", Cor = Color3.fromRGB(0, 100, 255), TeamColor = BrickColor.new("Bright blue")},
    {Nome = " Verde", Cor = Color3.fromRGB(0, 150, 0), TeamColor = BrickColor.new("Bright green")},
    {Nome = " Roxo", Cor = Color3.fromRGB(150, 0, 150), TeamColor = BrickColor.new("Bright violet")},
    {Nome = " Vermelho", Cor = Color3.fromRGB(200, 0, 0), TeamColor = BrickColor.new("Bright red")},
    {Nome = " Branco", Cor = Color3.fromRGB(255, 255, 255), TeamColor = BrickColor.new("White")},
    {Nome = " Amarelo", Cor = Color3.fromRGB(255, 200, 0), TeamColor = BrickColor.new("Bright yellow")}
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
-- FUNÇÕES DAS UTILIDADES (CORRIGIDAS)
-- =============================================

-- ANDAR NA ÁGUA (CORRIGIDO - SEM MORRER)
function andarAguaLoop()
    spawn(function()
        while getgenv().CoringaFarm.AndarAgua do
            local root = getRoot()
            local humanoid = getHumanoid()
            if root and humanoid then
                -- Verifica se está na água
                local material = Workspace:GetMaterialAtPosition(root.Position + Vector3.new(0, -3, 0))
                if material == Enum.Material.Water then
                    -- Mantém acima da água
                    root.CFrame = root.CFrame + Vector3.new(0, 2, 0)
                    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                end
            end
            wait(0.1)
        end
    end)
end

-- VISÃO NOTURNA
function visaoNoturnaLoop()
    spawn(function()
        while getgenv().CoringaFarm.VisaoNoturna do
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            wait()
        end
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 1
    end)
end

-- EFEITOS DE PARTÍCULAS
function efeitosParticulasLoop()
    spawn(function()
        while getgenv().CoringaFarm.EfeitosParticulas do
            local root = getRoot()
            if root then
                for _, efeito in pairs(efeitos) do
                    efeito:Destroy()
                end
                efeitos = {}
                
                local particle = Instance.new("ParticleEmitter")
                particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                particle.Color = ColorSequence.new(Color3.new(1, 0, 0), Color3.new(1, 1, 0))
                particle.Lifetime = NumberRange.new(1, 2)
                particle.Rate = 50
                particle.SpreadAngle = Vector2.new(360, 360)
                particle.VelocityInheritance = 0
                particle.Parent = root
                table.insert(efeitos, particle)
            end
            wait(5)
        end
        for _, efeito in pairs(efeitos) do
            efeito:Destroy()
        end
        efeitos = {}
    end)
end

-- NOCLIP
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
        local character = player.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)
end

-- VIDA INFINITA
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

-- FUNÇÕES ANTIGAS
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

function velocidadeLoop()
    spawn(function()
        while getgenv().CoringaFarm.Velocidade do
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = 50
            end
            wait()
        end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
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

function superPuloLoop()
    spawn(function()
        while getgenv().CoringaFarm.SuperPulo do
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = 100
            end
            wait()
        end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.JumpPower = 50
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
    atualizarListaJogadores()
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

function teleportarParaCor(corInfo)
    local root = getRoot()
    if not root then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            if otherChar and otherChar:FindFirstChild("HumanoidRootPart") then
                for _, part in pairs(otherChar:GetChildren()) do
                    if part:IsA("Part") and part.BrickColor == corInfo.TeamColor then
                        root.CFrame = otherChar.HumanoidRootPart.CFrame * CFrame.new(0, 5, 2)
                        return
                    end
                end
            end
        end
    end
    
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("Part") then
                part.BrickColor = corInfo.TeamColor
            end
        end
    end
end

-- =============================================
-- FUNÇÃO DE FARM
-- =============================================

function autoFarm(currentRun)
    farmCancelado = false
    local Character = player.Character
    if not Character then 
        player.CharacterAdded:Wait()
        Character = player.Character
    end
    
    local BoatStages = Workspace:FindFirstChild("BoatStages")
    if not BoatStages then return end
    
    local NormalStages = BoatStages:FindFirstChild("NormalStages")
    if not NormalStages then return end

    for i = 1, 10 do
        if not farmAtivo or farmCancelado then break end
        
        local Stage = NormalStages:FindFirstChild("CaveStage" .. i)
        if Stage then
            local DarknessPart = Stage:FindFirstChild("DarknessPart")
            if DarknessPart then
                Character.HumanoidRootPart.CFrame = DarknessPart.CFrame
                
                local Part = Instance.new("Part", Character)
                Part.Anchored = true
                Part.Position = Character.HumanoidRootPart.Position - Vector3.new(0, 6, 0)
                
                wait(getgenv().CoringaFarm.Teleport)
                Part:Destroy()
                
                faseAtual = i
                atualizarUI()
            end
        end
    end

    if farmAtivo and not farmCancelado then
        local TheEnd = NormalStages:FindFirstChild("TheEnd")
        if TheEnd then
            local GoldenChest = TheEnd:FindFirstChild("GoldenChest")
            if GoldenChest then
                local Trigger = GoldenChest:FindFirstChild("Trigger")
                if Trigger then
                    Character.HumanoidRootPart.CFrame = Trigger.CFrame
                    
                    local luzMudou = false
                    
                    while not luzMudou and farmAtivo do
                        wait(0.5)
                        
                        if Lighting.ClockTime ~= 14 then
                            luzMudou = true
                        end
                        
                        if Character and Character.HumanoidRootPart then
                            Character.HumanoidRootPart.CFrame = Trigger.CFrame
                        end
                    end
                    
                    if luzMudou then
                        ouroTotal = ouroTotal + 100
                    end
                    atualizarUI()
                end
            end
        end
    end

    if farmAtivo and not farmCancelado then
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
    while farmAtivo and not farmCancelado do
        if farmAtivo and not farmCancelado then
            local success = pcall(function() 
                autoFarm(runAtual) 
            end)
            
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
botaoFlutuante.Size = UDim2.new(0, 25, 0, 25)
botaoFlutuante.Position = UDim2.new(0.02, 0, 0.5, -12)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
botaoFlutuante.Text = ""
botaoFlutuante.TextColor3 = Color3.fromRGB(0, 0, 0)
botaoFlutuante.TextSize = 14
botaoFlutuante.Font = Enum.Font.GothamBold
botaoFlutuante.Visible = false
botaoFlutuante.Active = true
botaoFlutuante.Draggable = true
botaoFlutuante.Parent = screenGui
Instance.new("UICorner", botaoFlutuante).CornerRadius = UDim.new(1, 0)

local frame = Instance.new("Frame")
frame.Size = tamanhoOriginal
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
title.Text = textos[idiomaAtual].titulo
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 6)

local btnMinimizar = Instance.new("TextButton")
btnMinimizar.Size = UDim2.new(0, 18, 0, 18)
btnMinimizar.Position = UDim2.new(1, -38, 0, 3)
btnMinimizar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnMinimizar.Text = ""
btnMinimizar.TextColor3 = Color3.fromRGB(0, 0, 0)
btnMinimizar.TextSize = 12
btnMinimizar.Font = Enum.Font.GothamBold
btnMinimizar.Parent = frame
Instance.new("UICorner", btnMinimizar).CornerRadius = UDim.new(0, 3)

local btnFechar = Instance.new("TextButton")
btnFechar.Size = UDim2.new(0, 18, 0, 18)
btnFechar.Position = UDim2.new(1, -18, 0, 3)
btnFechar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnFechar.Text = ""
btnFechar.TextColor3 = Color3.fromRGB(0, 0, 0)
btnFechar.TextSize = 12
btnFechar.Font = Enum.Font.GothamBold
btnFechar.Parent = frame
Instance.new("UICorner", btnFechar).CornerRadius = UDim.new(0, 3)

-- =============================================
-- CONTAINER PRINCIPAL
-- =============================================
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -10, 1, -30)
container.Position = UDim2.new(0, 5, 0, 25)
container.BackgroundTransparency = 1
container.Parent = frame

-- =============================================
-- PAINEL ESQUERDO (STATUS E BOTÕES)
-- =============================================
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0.5, -3, 1, 0)
leftPanel.BackgroundTransparency = 1
leftPanel.Parent = container

local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 45)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusFrame.BackgroundTransparency = 0.1
statusFrame.Parent = leftPanel
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 5)

local statusGrid = Instance.new("Frame")
statusGrid.Size = UDim2.new(1, -10, 1, -10)
statusGrid.Position = UDim2.new(0, 5, 0, 5)
statusGrid.BackgroundTransparency = 1
statusGrid.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.33, -2, 1, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = statusGrid
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 4)

local ouroLabel = Instance.new("TextLabel")
ouroLabel.Size = UDim2.new(0.33, -2, 1, 0)
ouroLabel.Position = UDim2.new(0.33, 2, 0, 0)
ouroLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ouroLabel.Text = "0"
ouroLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
ouroLabel.TextSize = 11
ouroLabel.Font = Enum.Font.GothamBold
ouroLabel.Parent = statusGrid
Instance.new("UICorner", ouroLabel).CornerRadius = UDim.new(0, 4)

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.33, -2, 1, 0)
timerLabel.Position = UDim2.new(0.66, 4, 0, 0)
timerLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
timerLabel.Text = "0s"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 10
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = statusGrid
Instance.new("UICorner", timerLabel).CornerRadius = UDim.new(0, 4)

-- BOTÕES EM CINZA CLARO
local botoesFrame = Instance.new("Frame")
botoesFrame.Size = UDim2.new(1, 0, 0, 170)
botoesFrame.Position = UDim2.new(0, 0, 0, 50)
botoesFrame.BackgroundTransparency = 1
botoesFrame.Parent = leftPanel

local btnIniciar = Instance.new("TextButton")
btnIniciar.Size = UDim2.new(1, 0, 0, 30)
btnIniciar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnIniciar.Text = textos[idiomaAtual].iniciar
btnIniciar.TextColor3 = Color3.fromRGB(0, 0, 0)
btnIniciar.TextSize = 10
btnIniciar.Font = Enum.Font.GothamBold
btnIniciar.Parent = botoesFrame
Instance.new("UICorner", btnIniciar).CornerRadius = UDim.new(0, 4)

local btnVelocidade = Instance.new("TextButton")
btnVelocidade.Size = UDim2.new(1, 0, 0, 30)
btnVelocidade.Position = UDim2.new(0, 0, 0, 35)
btnVelocidade.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnVelocidade.Text = textos[idiomaAtual].velocidade
btnVelocidade.TextColor3 = Color3.fromRGB(0, 0, 0)
btnVelocidade.TextSize = 9
btnVelocidade.Font = Enum.Font.GothamBold
btnVelocidade.Parent = botoesFrame
Instance.new("UICorner", btnVelocidade).CornerRadius = UDim.new(0, 4)

local btnTimes = Instance.new("TextButton")
btnTimes.Size = UDim2.new(1, 0, 0, 30)
btnTimes.Position = UDim2.new(0, 0, 0, 70)
btnTimes.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnTimes.Text = textos[idiomaAtual].times
btnTimes.TextColor3 = Color3.fromRGB(0, 0, 0)
btnTimes.TextSize = 10
btnTimes.Font = Enum.Font.GothamBold
btnTimes.Parent = botoesFrame
Instance.new("UICorner", btnTimes).CornerRadius = UDim.new(0, 4)

local btnPlayer = Instance.new("TextButton")
btnPlayer.Size = UDim2.new(1, 0, 0, 30)
btnPlayer.Position = UDim2.new(0, 0, 0, 105)
btnPlayer.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnPlayer.Text = textos[idiomaAtual].player
btnPlayer.TextColor3 = Color3.fromRGB(0, 0, 0)
btnPlayer.TextSize = 10
btnPlayer.Font = Enum.Font.GothamBold
btnPlayer.Parent = botoesFrame
Instance.new("UICorner", btnPlayer).CornerRadius = UDim.new(0, 4)

local btnConfig = Instance.new("TextButton")
btnConfig.Size = UDim2.new(1, 0, 0, 30)
btnConfig.Position = UDim2.new(0, 0, 0, 140)
btnConfig.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
btnConfig.Text = textos[idiomaAtual].config
btnConfig.TextColor3 = Color3.fromRGB(0, 0, 0)
btnConfig.TextSize = 10
btnConfig.Font = Enum.Font.GothamBold
btnConfig.Parent = botoesFrame
Instance.new("UICorner", btnConfig).CornerRadius = UDim.new(0, 4)

-- =============================================
-- PAINEL DIREITO (JOGADORES / TIMES / PLAYER / CONFIG)
-- =============================================
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0.5, -3, 1, 0)
rightPanel.Position = UDim2.new(0.5, 3, 0, 0)
rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
rightPanel.BackgroundTransparency = 0.1
rightPanel.Parent = container
Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 5)

local rightTitle = Instance.new("TextLabel")
rightTitle.Size = UDim2.new(1, -10, 0, 20)
rightTitle.Position = UDim2.new(0, 5, 0, 5)
rightTitle.BackgroundTransparency = 1
rightTitle.Text = textos[idiomaAtual].jogadores
rightTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
rightTitle.TextSize = 11
rightTitle.Font = Enum.Font.GothamBold
rightTitle.Parent = rightPanel

-- LISTA DE JOGADORES
local jogadoresLista = Instance.new("ScrollingFrame")
jogadoresLista.Size = UDim2.new(1, -10, 1, -30)
jogadoresLista.Position = UDim2.new(0, 5, 0, 25)
jogadoresLista.BackgroundTransparency = 1
jogadoresLista.ScrollBarThickness = 4
jogadoresLista.CanvasSize = UDim2.new(0, 0, 0, 0)
jogadoresLista.Parent = rightPanel
jogadoresLista.Visible = true

-- LISTA DE TIMES
local timesLista = Instance.new("Frame")
timesLista.Size = UDim2.new(1, -10, 0, 140)
timesLista.Position = UDim2.new(0, 5, 0, 25)
timesLista.BackgroundTransparency = 1
timesLista.Parent = rightPanel
timesLista.Visible = false

local posX, posY = 5, 5
local colunas = 0

for i, corInfo in pairs(coresTimes) do
    local btnCor = Instance.new("TextButton")
    btnCor.Size = UDim2.new(0, 70, 0, 22)
    btnCor.Position = UDim2.new(0, posX, 0, posY)
    btnCor.BackgroundColor3 = corInfo.Cor
    btnCor.Text = corInfo.Nome
    btnCor.TextColor3 = corInfo.Cor.r + corInfo.Cor.g + corInfo.Cor.b > 1.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    btnCor.TextSize = 8
    btnCor.Font = Enum.Font.GothamBold
    btnCor.Parent = timesLista
    Instance.new("UICorner", btnCor).CornerRadius = UDim.new(0, 4)
    
    btnCor.MouseButton1Click:Connect(function()
        teleportarParaCor(corInfo)
    end)
    
    posX = posX + 75
    colunas = colunas + 1
    
    if colunas == 2 then
        colunas = 0
        posX = 5
        posY = posY + 27
    end
end

-- LISTA DE PLAYER (COM FUNÇÕES CORRIGIDAS)
local playerLista = Instance.new("ScrollingFrame")
playerLista.Size = UDim2.new(1, -10, 1, -30)
playerLista.Position = UDim2.new(0, 5, 0, 25)
playerLista.BackgroundTransparency = 1
playerLista.ScrollBarThickness = 4
playerLista.CanvasSize = UDim2.new(0, 0, 0, 0)
playerLista.Parent = rightPanel
playerLista.Visible = false

local function criarBotoesPlayer()
    for _, child in pairs(playerLista:GetChildren()) do
        child:Destroy()
    end
    
    local functions = {
        {nome = textos[idiomaAtual].velocidadeNome, var = "Velocidade"},
        {nome = textos[idiomaAtual].invisivelNome, var = "Invisivel"},
        {nome = textos[idiomaAtual].superPuloNome, var = "SuperPulo"},
        {nome = textos[idiomaAtual].escudoNome, var = "Escudo"},
        {nome = textos[idiomaAtual].andarAguaNome, var = "AndarAgua"},
        {nome = textos[idiomaAtual].visaoNoturnaNome, var = "VisaoNoturna"},
        {nome = textos[idiomaAtual].efeitosNome, var = "EfeitosParticulas"},
        {nome = textos[idiomaAtual].noclipNome, var = "Noclip"},
        {nome = textos[idiomaAtual].vidaInfinitaNome, var = "VidaInfinita"}
    }
    
    local yPos = 0
    for i, func in pairs(functions) do
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -10, 0, 35)
        bg.Position = UDim2.new(0, 5, 0, yPos)
        bg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        bg.Parent = playerLista
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)
        
        local nomeLabel = Instance.new("TextLabel")
        nomeLabel.Size = UDim2.new(0.6, -5, 1, 0)
        nomeLabel.Position = UDim2.new(0, 5, 0, 0)
        nomeLabel.BackgroundTransparency = 1
        nomeLabel.Text = func.nome
        nomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nomeLabel.TextSize = 10
        nomeLabel.Font = Enum.Font.GothamBold
        nomeLabel.Parent = bg
        
        local btnToggle = Instance.new("TextButton")
        btnToggle.Size = UDim2.new(0.3, 0, 0, 25)
        btnToggle.Position = UDim2.new(0.7, 0, 0.5, -12)
        btnToggle.BackgroundColor3 = getgenv().CoringaFarm[func.var] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
        btnToggle.Text = getgenv().CoringaFarm[func.var] and "ON" or "OFF"
        btnToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnToggle.TextSize = 9
        btnToggle.Font = Enum.Font.GothamBold
        btnToggle.Parent = bg
        Instance.new("UICorner", btnToggle).CornerRadius = UDim.new(0, 4)
        
        btnToggle.MouseButton1Click:Connect(function()
            getgenv().CoringaFarm[func.var] = not getgenv().CoringaFarm[func.var]
            btnToggle.BackgroundColor3 = getgenv().CoringaFarm[func.var] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
            btnToggle.Text = getgenv().CoringaFarm[func.var] and "ON" or "OFF"
            
            if func.var == "Velocidade" then velocidadeLoop()
            elseif func.var == "Invisivel" then invisivelLoop()
            elseif func.var == "SuperPulo" then superPuloLoop()
            elseif func.var == "Escudo" then escudoLoop()
            elseif func.var == "AndarAgua" then andarAguaLoop()
            elseif func.var == "VisaoNoturna" then visaoNoturnaLoop()
            elseif func.var == "EfeitosParticulas" then efeitosParticulasLoop()
            elseif func.var == "Noclip" then noclipLoop()
            elseif func.var == "VidaInfinita" then vidaInfinitaLoop()
            end
        end)
        
        yPos = yPos + 40
    end
    playerLista.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

criarBotoesPlayer()

-- LISTA DE CONFIGURAÇÃO
local configLista = Instance.new("Frame")
configLista.Size = UDim2.new(1, -10, 0, 120)
configLista.Position = UDim2.new(0, 5, 0, 25)
configLista.BackgroundTransparency = 1
configLista.Parent = rightPanel
configLista.Visible = false

local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.new(1, -10, 0, 20)
configTitle.Position = UDim2.new(0, 5, 0, 5)
configTitle.BackgroundTransparency = 1
configTitle.Text = textos[idiomaAtual].idioma
configTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
configTitle.TextSize = 11
configTitle.Font = Enum.Font.GothamBold
configTitle.Parent = configLista

local idiomas = {
    {nome = textos[idiomaAtual].portuguesOpcao, id = "portugues"},
    {nome = textos[idiomaAtual].inglesOpcao, id = "english"},
    {nome = textos[idiomaAtual].espanholOpcao, id = "espanol"}
}

local yPosConfig = 30
local idiomaBotoes = {}

for i, idioma in pairs(idiomas) do
    local btnIdioma = Instance.new("TextButton")
    btnIdioma.Size = UDim2.new(1, -10, 0, 25)
    btnIdioma.Position = UDim2.new(0, 5, 0, yPosConfig)
    btnIdioma.BackgroundColor3 = idioma.id == idiomaAtual and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 60)
    btnIdioma.Text = idioma.nome
    btnIdioma.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnIdioma.TextSize = 10
    btnIdioma.Font = Enum.Font.GothamBold
    btnIdioma.Parent = configLista
    Instance.new("UICorner", btnIdioma).CornerRadius = UDim.new(0, 4)
    
    btnIdioma.MouseButton1Click:Connect(function()
        idiomaAtual = idioma.id
        atualizarIdioma()
        
        for _, btn in pairs(idiomaBotoes) do
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end
        btnIdioma.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        criarBotoesPlayer()
    end)
    
    table.insert(idiomaBotoes, btnIdioma)
    yPosConfig = yPosConfig + 30
end

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
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.Parent = jogadoresLista
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            teleportarParaJogador(info.player)
        end)
        
        yPos = yPos + 30
    end
    jogadoresLista.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

function atualizarUI()
    statusLabel.Text = farmAtivo and "" or ""
    statusLabel.TextColor3 = farmAtivo and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    ouroLabel.Text = "" .. ouroTotal
    timerLabel.Text = "" .. temporizador .. "s"
end

function atualizarIdioma()
    title.Text = textos[idiomaAtual].titulo
    btnIniciar.Text = farmAtivo and textos[idiomaAtual].pausar or textos[idiomaAtual].iniciar
    btnVelocidade.Text = textos[idiomaAtual].velocidade
    btnTimes.Text = mostrandoTimes and textos[idiomaAtual].fecharTimes or textos[idiomaAtual].times
    btnPlayer.Text = mostrandoPlayers and textos[idiomaAtual].fecharPlayer or textos[idiomaAtual].player
    btnConfig.Text = mostrandoConfig and textos[idiomaAtual].fecharConfig or textos[idiomaAtual].config
    rightTitle.Text = mostrandoJogadores and textos[idiomaAtual].jogadores or 
                     (mostrandoTimes and textos[idiomaAtual].timesTitulo or 
                     (mostrandoPlayers and textos[idiomaAtual].playerTitulo or 
                     textos[idiomaAtual].configTitulo))
    
    configTitle.Text = textos[idiomaAtual].idioma
    
    for i, btn in pairs(idiomaBotoes) do
        if i == 1 then btn.Text = textos[idiomaAtual].portuguesOpcao
        elseif i == 2 then btn.Text = textos[idiomaAtual].inglesOpcao
        elseif i == 3 then btn.Text = textos[idiomaAtual].espanholOpcao
        end
    end
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

-- CONEXÕES DOS BOTÕES
botaoFlutuante.MouseButton1Click:Connect(minimizarMenu)

btnIniciar.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    getgenv().CoringaFarm.Enabled = farmAtivo
    btnIniciar.Text = farmAtivo and textos[idiomaAtual].pausar or textos[idiomaAtual].iniciar
    runAtual = 1
    atualizarUI()
    
    if farmAtivo then
        spawn(iniciarFarmOriginal)
    end
end)

btnVelocidade.MouseButton1Click:Connect(function()
    if getgenv().CoringaFarm.Teleport == 2 then
        getgenv().CoringaFarm.Teleport = 0.5
        btnVelocidade.Text = textos[idiomaAtual].velRapida
    elseif getgenv().CoringaFarm.Teleport == 0.5 then
        getgenv().CoringaFarm.Teleport = 3
        btnVelocidade.Text = textos[idiomaAtual].velLenta
    else
        getgenv().CoringaFarm.Teleport = 2
        btnVelocidade.Text = textos[idiomaAtual].velocidade
    end
end)

btnTimes.MouseButton1Click:Connect(function()
    if mostrandoTimes then
        mostrandoTimes = false
        mostrandoPlayers = false
        mostrandoConfig = false
        mostrandoJogadores = true
        jogadoresLista.Visible = true
        timesLista.Visible = false
        playerLista.Visible = false
        configLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].jogadores
        btnTimes.Text = textos[idiomaAtual].times
        btnPlayer.Text = textos[idiomaAtual].player
        btnConfig.Text = textos[idiomaAtual].config
        verJogadoresProximos()
    else
        mostrandoTimes = true
        mostrandoPlayers = false
        mostrandoConfig = false
        mostrandoJogadores = false
        jogadoresLista.Visible = false
        timesLista.Visible = true
        playerLista.Visible = false
        configLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].timesTitulo
        btnTimes.Text = textos[idiomaAtual].fecharTimes
        btnPlayer.Text = textos[idiomaAtual].player
        btnConfig.Text = textos[idiomaAtual].config
    end
end)

btnPlayer.MouseButton1Click:Connect(function()
    if mostrandoPlayers then
        mostrandoPlayers = false
        mostrandoTimes = false
        mostrandoConfig = false
        mostrandoJogadores = true
        jogadoresLista.Visible = true
        timesLista.Visible = false
        playerLista.Visible = false
        configLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].jogadores
        btnPlayer.Text = textos[idiomaAtual].player
        btnTimes.Text = textos[idiomaAtual].times
        btnConfig.Text = textos[idiomaAtual].config
        verJogadoresProximos()
    else
        mostrandoPlayers = true
        mostrandoTimes = false
        mostrandoConfig = false
        mostrandoJogadores = false
        jogadoresLista.Visible = false
        timesLista.Visible = false
        playerLista.Visible = true
        configLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].playerTitulo
        btnPlayer.Text = textos[idiomaAtual].fecharPlayer
        btnTimes.Text = textos[idiomaAtual].times
        btnConfig.Text = textos[idiomaAtual].config
    end
end)

btnConfig.MouseButton1Click:Connect(function()
    if mostrandoConfig then
        mostrandoConfig = false
        mostrandoPlayers = false
        mostrandoTimes = false
        mostrandoJogadores = true
        jogadoresLista.Visible = true
        timesLista.Visible = false
        playerLista.Visible = false
        configLista.Visible = false
        rightTitle.Text = textos[idiomaAtual].jogadores
        btnConfig.Text = textos[idiomaAtual].config
        btnTimes.Text = textos[idiomaAtual].times
        btnPlayer.Text = textos[idiomaAtual].player
        verJogadoresProximos()
    else
        mostrandoConfig = true
        mostrandoPlayers = false
        mostrandoTimes = false
        mostrandoJogadores = false
        jogadoresLista.Visible = false
        timesLista.Visible = false
        playerLista.Visible = false
        configLista.Visible = true
        rightTitle.Text = textos[idiomaAtual].configTitulo
        btnConfig.Text = textos[idiomaAtual].fecharConfig
        btnTimes.Text = textos[idiomaAtual].times
        btnPlayer.Text = textos[idiomaAtual].player
    end
end)

btnMinimizar.MouseButton1Click:Connect(minimizarMenu)
btnFechar.MouseButton1Click:Connect(function() 
    farmAtivo = false 
    farmCancelado = true
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
        if mostrandoJogadores then
            verJogadoresProximos()
        end
    end
end)

atualizarUI()
verJogadoresProximos()

frame.BackgroundTransparency = 1
for i = 1, 10 do 
    wait(0.02) 
    frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1 
end