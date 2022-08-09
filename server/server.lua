local cache = {}
local loaded_list = {}
local APIKey = ""
local COMMID = ""

RegisterNetEvent("sonoran_permissions::rankupdate", function(data)
    local ppermissiondata = data.data.primaryRank
    local ppermissiondatas = data.data.secondaryRanks
    local identifier = data.identifier
    if data.key == APIKey then
        if Config.rank_mapping[ppermissiondata] ~= nil then
            ExecuteCommand("add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                               Config.rank_mapping[ppermissiondata])
            if loaded_list[identifier] == nil then
                loaded_list[identifier] = {
                    [ppermissiondata] = Config.rank_mapping[ppermissiondata]
                }
            end
            if Config.offline_cache then
                if cache[identifier] == nil then
                    cache[identifier] = {
                        [ppermissiondata] = "add_principal identifier." .. Config.primary_identifier .. ":" ..
                            identifier .. " " .. Config.rank_mapping[ppermissiondata]
                    }
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                else
                    cache[identifier][ppermissiondata] =
                        "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                            Config.rank_mapping[ppermissiondata]
                    SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                end
            end
        end
        for _, v in pairs(ppermissiondatas) do
            if Config.rank_mapping[v] ~= nil then
                ExecuteCommand(
                    "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                        Config.rank_mapping[v])
                if loaded_list[identifier] == nil then
                    loaded_list[identifier] = {
                        [v] = Config.rank_mapping[v]
                    }
                end
                if Config.offline_cache then
                    if cache[identifier] == nil then
                        cache[identifier] = {
                            [v] = "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier ..
                                " " .. Config.rank_mapping[v]
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
                    ExecuteCommand(
                        "remove_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                            v)
                    if Config.offline_cache then
                        cache[identifier][k] = nil
                        SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                    end
                end
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(100)
        cache = json.decode(LoadResourceFile(GetCurrentResourceName(), "cache.json"))
        if GetResourceState("sonorancms") ~= "started" then
            print("ERROR! SONORANCMS CORE NOT RUNNING!")
        else
            APIKey = GetConvar("sonorancms_api_key")
            COMMID = GetConvar("sonorancms_comm_id")
            TriggerEvent("sonorancms::RegisterPushEvent", "ACCOUNT_UPDATED", "sonoran_permissions::rankupdate")
        end
    end
end)

AddEventHandler("playerConnecting", function(_, _, deferrals)
    deferrals.defer();
    deferrals.update("Grabbing API ID and getting your permissions...")
    local identifier
    for _, v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len(Config.primary_identifier .. ":")) == Config.primary_identifier .. ":" then
            identifier = string.sub(v, string.len(Config.primary_identifier .. ":") + 1)
        end
    end
    PerformHttpRequest("https://cmsapi.dev.sonoransoftware.com/general/get_account_ranks",
        function(code, result, _)
            if code == 200 then
                local ppermissiondata = json.decode(result)
                for _, v in pairs(ppermissiondata) do
                    if Config.rank_mapping[v] ~= nil then
                        ExecuteCommand(
                            "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                                Config.rank_mapping[v])
                        if loaded_list[identifier] == nil then
                            loaded_list[identifier] = {
                                [v] = Config.rank_mapping[v]
                            }
                        end
                        if Config.offline_cache then
                            if cache[identifier] == nil then
                                cache[identifier] = {
                                    [v] = "add_principal identifier." .. Config.primary_identifier .. ":" ..
                                        identifier .. " " .. Config.rank_mapping[v]
                                }
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            else
                                cache[identifier][v] =
                                    "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier ..
                                        " " .. Config.rank_mapping[v]
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            end
                        end
                    end
                end
                if loaded_list[identifier] ~= nil then
                    for k, v in pairs(loaded_list[identifier]) do
                        if ppermissiondata[k] == nil then
                            loaded_list[k] = nil
                            ExecuteCommand("remove_principal identifier." .. Config.primary_identifier .. ":" ..
                                               identifier .. " " .. v)
                            if Config.offline_cache then
                                cache[identifier][k] = nil
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            end
                        end
                    end
                end
                deferrals.done()
            elseif Config.offline_cache then
                if cache[identifier] ~= nil then
                    for _, v in pairs(cache[identifier]) do
                        if string.sub(v, 1, string.len("")) == "add_principal" then
                            ExecuteCommand(v)
                            if loaded_list[identifier] == nil then
                                loaded_list[identifier] = {
                                    [v] = Config.rank_mapping[v]
                                }
                            else
                                loaded_list[identifier][v] = Config.rank_mapping[v]
                            end
                        end
                    end
                end
            end
        end, "POST", json.encode({
            id = COMMID,
            key = APIKey,
            type = "GET_ACCOUNT_RANKS",
            data = {{
                apiId = identifier
            }}
        }))
end)

RegisterCommand("refreshpermissions", function(src, _, _)
    local identifier
    for _, v in pairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len(Config.primary_identifier .. ":")) == Config.primary_identifier .. ":" then
            identifier = string.sub(v, string.len(Config.primary_identifier .. ":") + 1)
        end
    end
    PerformHttpRequest("https://cmsapi.dev.sonoransoftware.com/general/get_account_ranks",
        function(code, result, _)
            if code == 200 then
                local ppermissiondata = json.decode(result)
                for _, v in pairs(ppermissiondata) do
                    if Config.rank_mapping[v] ~= nil then
                        ExecuteCommand(
                            "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                                Config.rank_mapping[v])
                        if loaded_list[identifier] == nil then
                            loaded_list[identifier] = {
                                [v] = Config.rank_mapping[v]
                            }
                        end
                        if Config.offline_cache then
                            if cache[identifier] == nil then
                                cache[identifier] = {
                                    [v] = "add_principal identifier." .. Config.primary_identifier .. ":" ..
                                        identifier .. " " .. Config.rank_mapping[v]
                                }
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            else
                                cache[identifier][v] =
                                    "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier ..
                                        " " .. Config.rank_mapping[v]
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            end
                        end
                    end
                end
                if loaded_list[identifier] ~= nil then
                    for k, v in pairs(loaded_list[identifier]) do
                        if ppermissiondata[k] == nil then
                            loaded_list[k] = nil
                            ExecuteCommand("remove_principal identifier." .. Config.primary_identifier .. ":" ..
                                               identifier .. " " .. v)
                            if Config.offline_cache then
                                cache[identifier][k] = nil
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            end
                        end
                    end
                end
            elseif Config.offline_cache then
                if cache[identifier] ~= nil then
                    for _, v in pairs(cache[identifier]) do
                        if string.sub(v, 1, string.len("")) == "add_principal" then
                            ExecuteCommand(v)
                            if loaded_list[identifier] == nil then
                                loaded_list[identifier] = {
                                    [v] = Config.rank_mapping[v]
                                }
                            else
                                loaded_list[identifier][v] = Config.rank_mapping[v]
                            end
                        end
                    end
                end
            end
        end, "POST", json.encode({
            id = COMMID,
            key = APIKey,
            type = "GET_ACCOUNT_RANKS",
            data = {{
                apiId = identifier
            }}
        }))
end)
