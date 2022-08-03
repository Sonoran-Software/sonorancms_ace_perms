local cache = {}
local loaded_list = {}

RegisterNetEvent("sonoran_permissions::rankupdate", function(data)
    local ppermissiondata = data.ranks
    local identifier = data.identifier
    for k, v in pairs(ppermissiondata) do
        if Config.rank_mapping[v] ~= nil then
            ExecuteCommand("add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                               Config.rank_mapping[v])
            if loaded_list[identifier] == nil then
                loaded_list[identifier] = {
                    [v] = Config.rank_mapping[v]
                }
            end
            if Config.offline_cache then
                if cache[identifier] == nil then
                    cache[identifier] = {
                        [v] = "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                            Config.rank_mapping[v]
                    }
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                else
                    cache[identifier][v] = "add_principal identifier." .. Config.primary_identifier .. ":" ..
                                               identifier .. " " .. Config.rank_mapping[v]
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                end
            end
        end
    end
    if loaded_list[identifier] ~= nil then
        for k, v in pairs(loaded_list[identifier]) do
            if ppermissiondata[k] == nil then
                loaded_list[k] = nil
                ExecuteCommand("remove_principal identifier." .. Config.primary_identifier .. ":" .. identifier ..
                                   " " .. v)
                if Config.offline_cache then
                    cache[identifier][k] = nil
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                end
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(100)
        cache = json.decode(LoadResourceFile(GetCurrentResourceName(), "cache.json"))
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer();
    deferrals.update("Grabbing API ID and getting your permissions...")
    -- TODO: Implement proper API call
    local permissiondata = json.decode(LoadResourceFile(GetCurrentResourceName(), "tempdata.json"))
    local identifier
    for _, v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len(Config.primary_identifier .. ":")) == Config.primary_identifier .. ":" then
            identifier = string.sub(v, string.len(Config.primary_identifier .. ":") + 1)
        end
    end
    local ppermissiondata = permissiondata[identifier]
    for k, v in pairs(ppermissiondata) do
        if Config.rank_mapping[v] ~= nil then
            ExecuteCommand("add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                               Config.rank_mapping[v])
            if loaded_list[identifier] == nil then
                loaded_list[identifier] = {
                    [v] = Config.rank_mapping[v]
                }
            end
            if Config.offline_cache then
                if cache[identifier] == nil then
                    cache[identifier] = {
                        [v] = "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                            Config.rank_mapping[v]
                    }
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                else
                    cache[identifier][v] = "add_principal identifier." .. Config.primary_identifier .. ":" ..
                                               identifier .. " " .. Config.rank_mapping[v]
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                end
            end
        end
    end
    if loaded_list[identifier] ~= nil then
        for k, v in pairs(loaded_list[identifier]) do
            if ppermissiondata[k] == nil then
                loaded_list[k] = nil
                ExecuteCommand("remove_principal identifier." .. Config.primary_identifier .. ":" .. identifier ..
                                   " " .. v)
                if Config.offline_cache then
                    cache[identifier][k] = nil
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                end
            end
        end
    end
    deferrals.done()
end)

-- For use when CMS API is ready
--[[
if api_error and Config.offline_cache then
    if cache[identifier] ~= nil then
        for k, v in pairs(ppermissiondata) do
            if string.sub(v, 1, string.len("")) == "add_principal" then
                ExecuteCommand(v)
                if loaded_list[identifier] == nil then
                    loaded_list[identifier] = {
                        [v] = Config.rank_mapping[v]
                    }
                end
            end
        end
    end
end
]]

RegisterCommand("refreshpermissions", function(src, args, raw)
    local permissiondata = json.decode(LoadResourceFile(GetCurrentResourceName(), "tempdata.json"))
    local identifier
    for _, v in pairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len(Config.primary_identifier .. ":")) == Config.primary_identifier .. ":" then
            identifier = string.sub(v, string.len(Config.primary_identifier .. ":") + 1)
        end
    end
    local ppermissiondata = permissiondata[identifier]
    for k, v in pairs(ppermissiondata) do
        if Config.rank_mapping[v] ~= nil then
            ExecuteCommand("add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                               Config.rank_mapping[v])
            if loaded_list[identifier] == nil then
                loaded_list[identifier] = {
                    [v] = Config.rank_mapping[v]
                }
            end
            if Config.offline_cache then
                if cache[identifier] == nil then
                    cache[identifier] = {
                        [v] = "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                            Config.rank_mapping[v]
                    }
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                else
                    cache[identifier][v] = "add_principal identifier." .. Config.primary_identifier .. ":" ..
                                               identifier .. " " .. Config.rank_mapping[v]
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                end
            end
        end
    end
    if loaded_list[identifier] ~= nil then
        for k, v in pairs(loaded_list[identifier]) do
            if ppermissiondata[k] == nil then
                loaded_list[k] = nil
                ExecuteCommand("remove_principal identifier." .. Config.primary_identifier .. ":" .. identifier ..
                                   " " .. v)
                if Config.offline_cache then
                    cache[identifier][k] = nil
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                end
            end
        end
    end
end)
