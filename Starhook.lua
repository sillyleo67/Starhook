local Executor = string.lower(identifyexecutor and identifyexecutor() or "")
local Source = [[getgenv().SCRIPT_KEY = "KEYLESS"; loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/680cb3160eb57826849c357d82cb511a6986ec128fa0c3abdec457870c918cac/download"))()]]
local ThreadSource = [[local Shared = getrenv().shared if Shared and Shared.require then ]] .. Source .. [[ end]]

local function JoinServer()
    local Http = game:GetService("HttpService")
    local Teleport = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    
    local Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100&excludeFullGames=true"
    local Success, Response = pcall(function() 
        return Http:JSONDecode(game:HttpGet(Url)) 
    end)
    
    if Success and Response and Response.data then
        for _, Server in ipairs(Response.data) do
            if Server.id ~= game.JobId and (Server.maxPlayers - Server.playing) >= 4 then
                Teleport:TeleportToPlaceInstance(game.PlaceId, Server.id, Players.LocalPlayer)
                break
            end
        end
    end
end

if string.find(Executor, "wave") or string.find(Executor, "choco") then
    for _, Actor in ipairs(get_deleted_actors()) do 
        run_on_actor(Actor, ThreadSource) 
    end
elseif string.find(Executor, "v2olt") or string.find(Executor, "synapse") then
    for _, Actor in ipairs(getactors()) do 
        run_on_actor(Actor, ThreadSource) 
    end
elseif string.find(Executor, "potassium") then
    for _, Actor in ipairs(getactorthreads()) do 
        run_on_thread(Actor, ThreadSource) 
    end
elseif getfflag and string.lower(tostring(getfflag("DebugRunParallelLuaOnMainThread"))) == "true" then
    loadstring(Source)()
elseif setfflag then
    setfflag("DebugRunParallelLuaOnMainThread", "True")

    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local StatusText = Drawing.new("Text")
    StatusText.Position = Camera.ViewportSize / 2
    StatusText.Center = true
    StatusText.Outline = true
    StatusText.Visible = true
    StatusText.Size = 25
    StatusText.Color = Color3.new(1, 1, 1)
    StatusText.Text = "You are about to rejoin if the script does not execute you may reexecute it"
    
    task.wait(5)
    StatusText:Remove()

    if queue_on_teleport then
        queue_on_teleport([=[
            repeat task.wait() until game:IsLoaded()
            task.wait(2)
        ]=] .. Source)
    end

    JoinServer()
end
