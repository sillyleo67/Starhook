--[[
this loader was given to me by someone and was sightly edited by me for improvements
]]--

local ExecutorName = (identifyexecutor and identifyexecutor() or ""):lower()

local Source = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/sillyleo67/Starhook/refs/heads/main/Scripts/StarhookPF.lua"))()
]]

local ThreadSource = ([[local Shared = getrenv().shared if Shared and Shared.require then %s end]]):format(Source)

local Executors = {
    { "wave", get_deleted_actors, run_on_actor },
    { "choco", get_deleted_actors, run_on_actor },
    { "volt", getactors, run_on_actor },
    { "synapse", getactors, run_on_actor },
    { "potassium", getactorthreads, run_on_thread }
}

local function JoinServer() -- this is just for qt or ob servers cause you can't rejoin those servers
    local Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100&excludeFullGames=true"

    local Success, Response = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet(Url))
    end)

    if not Success or not Response or not Response.data then
        return
    end

    for _, Server in ipairs(Response.data) do
        if Server.id ~= game.JobId and Server.maxPlayers - Server.playing >= 4 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Server.id, game:GetService("Players").LocalPlayer)
            break
        end
    end
end

for _, Executor in ipairs(Executors) do
    local Name = Executor[1]
    local GetActors = Executor[2]
    local Execute = Executor[3]

    if ExecutorName:find(Name, 1, true) then
        for _, Actor in ipairs(GetActors()) do
            Execute(Actor, ThreadSource)
        end

        return
    end
end

if getfflag and tostring(getfflag("DebugRunParallelLuaOnMainThread")):lower() == "true" then
    loadstring(Source)()
elseif setfflag then
    setfflag("DebugRunParallelLuaOnMainThread", "True")

    local StatusText = Drawing.new("Text")

    StatusText.Position = game:GetService("Workspace").CurrentCamera.ViewportSize / 2
    StatusText.Center = true
    StatusText.Outline = true
    StatusText.Visible = true
    StatusText.Size = 25
    StatusText.Color = Color3.new(1, 1, 1)
    StatusText.Text = "You are about to rejoin. If the script does not execute, reexecute it."

    task.wait(5)
    StatusText:Remove()

    if queue_on_teleport then
        queue_on_teleport([=[
            repeat task.wait() until game:IsLoaded()
            task.wait(2)
        ]=] .. Source)
    end

    if string.find(game:GetService("Players").LocalPlayer.PlayerGui.ChatScreenGui.Main.TextVersion.ContentText, "-prod") then -- so dtc
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    else
        JoinServer()
    end
else
    loadstring(Source)()
end
