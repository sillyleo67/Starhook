--[[
this loader was given to me by someone and was edited by me for improvements
]]--

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ExecutorName = (identifyexecutor and identifyexecutor() or ""):lower()

local Source = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/sillyleo67/Starhook/refs/heads/main/Scripts/StarhookPF.lua"))()
]]

local Executors = {
    { "wave", get_deleted_actors, run_on_actor },
    { "choco", get_deleted_actors, run_on_actor },
    { "volt", getactors, run_on_actor },
    { "synapse", getactors, run_on_actor },
    { "potassium", getactorthreads, run_on_thread }
}

local function JoinServer() -- erm we do this for qt and ob servers because you can't rejoin them :D
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
    local RunFunction = Executor[3]

    if ExecutorName:find(Name, 1, true) then
        if not Name or not GetActors or not RunFunction then
            game:GetService("Players").LocalPlayer:Kick("report this in the discord server")
        end

        local Actors = GetActors()

        if Name == "synapse" or Name == "choco" then
            for i = 1, #Actors do
                RunFunction(Actors[i], Source)
            end
            return
        end

        local Found = false

        for i = 1, #Actors do
            if Found then
                break
            end

            local Actor = Actors[i]
            local Index, Channel

            if Name == "wave" and actor.createcommchannel then
                Index, Channel = actor.createcommchannel()
            elseif create_comm_channel then
                Index, Channel = create_comm_channel()
            end

            if Channel then
                Channel.Event:Once(function()
                    if Found then
                        return
                    end

                    RunFunction(Actor, Source)
                    Found = true
                end)

                RunFunction(Actor, [=[
                    local Channel = get_comm_channel(...)

                    local Shared = getrenv().shared
                    local Require = Shared and Shared.require

                    if Require then
                        Channel:Fire()
                    end
                ]=], Index)
            end
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

    if string.find(game:GetService("Players").LocalPlayer.PlayerGui.ChatScreenGui.Main.TextVersion.ContentText, "-prod") then -- no detection pls
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    else
        JoinServer()
    end
else
    loadstring(Source)()
end
