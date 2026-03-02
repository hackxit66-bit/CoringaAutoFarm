-- loadstring(game:HttpGet("https://raw.githubusercontent.com/hackxit66-bit/CoringaAutoFarm/main/loader.lua"))()

local repo = "hackxit66-bit"
local nomeScript = "CoringaAutoFarm"
local versaoAtual = "2.0"

function verificarVersao()
    local sucesso, versaoSite = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/" .. repo .. "/" .. nomeScript .. "/main/version.txt")
    end)
    
    if sucesso and versaoSite then
        return versaoSite:gsub("%s+", "")
    end
    return nil
end

function baixarScript()
    local sucesso, script = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/" .. repo .. "/" .. nomeScript .. "/main/script.lua")
    end)
    
    if sucesso and script then
        return script
    end
    return nil
end

function limparCache()
    if getgenv().TreasureAutoFarm then
        getgenv().TreasureAutoFarm = nil
    end
end

limparCache()
wait(0.5)

local versaoSite = verificarVersao()
if versaoSite and versaoSite ~= versaoAtual then
    
end

wait(0.5)

local scriptConteudo = baixarScript()

if scriptConteudo then
    wait(0.5)
    
    local sucesso, erro = pcall(function()
        loadstring(scriptConteudo)()
    end)
    
    if not sucesso then
        
    end
end
