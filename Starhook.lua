local Source = [[getgenv().SCRIPT_KEY = "KEYLESS"; loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/680cb3160eb57826849c357d82cb511a6986ec128fa0c3abdec457870c918cac/download"))()]]

local Executor = string.lower(identifyexecutor and identifyexecutor() or "")

local ThreadSource = [[
    local Shared = getrenv().shared

    if Shared and Shared.require then
        ]] .. Source .. [[

    end
]]

local function RunSource(Runner, GetAll)
    for _, Actor in ipairs(GetAll()) do
        Runner(Actor, ThreadSource)
    end
end

if string.find(Executor, "wave") or string.find(Executor, "choco") then
    RunSource(run_on_actor, get_deleted_actors)
elseif string.find(Executor, "volt") or string.find(Executor, "synapse") then
    RunSource(run_on_actor, getactors)
elseif string.find(Executor, "potassium") then
    RunSource(run_on_thread, getactorthreads)
elseif getfflag and string.lower(tostring(getfflag("DebugRunParallelLuaOnMainThread"))) == "true" then
    loadstring(Source)()
elseif setfflag then
    setfflag("DebugRunParallelLuaOnMainThread", "True")

    if queue_on_teleport then
        queue_on_teleport(Source)
    end

    game:GetService("TeleportService"):Teleport(game.PlaceId)
end
