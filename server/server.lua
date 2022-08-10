local cache = {}
local loaded_list = {}
local APIKey = ""
local COMMID = ""

RegisterNetEvent("sonoran_permissions::rankupdate", function(data)
    local ppermissiondata = data.data.primaryRank
    local ppermissiondatas = data.data.secondaryRanks
    local identifier = data.data.activeApiIds
    if data.key == APIKey then
        for _, g in pairs(identifier) do
            if loaded_list[g] ~= nil then
                for k, v in pairs(loaded_list[g]) do
                    local has = false
                    for _, b in pairs(ppermissiondatas) do
                        if b == k then
                            has = true
                        end
                    end
                    if ppermissiondata == v then
                        has = true
                    end
                    if not has then
                        loaded_list[g][k] = nil

                        ExecuteCommand("remove_principal identifier." .. Config.primary_identifier .. ":" .. g ..
                                           " " .. v)
                        if Config.offline_cache then
                            cache[g][k] = nil
                            SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                        end
                    end
                end
            end
        end
        if ppermissiondata ~= "" or ppermissiondata ~= nil then
            if Config.rank_mapping[ppermissiondata] ~= nil then
                for _, b in pairs(identifier) do
                    ExecuteCommand("add_principal identifier." .. Config.primary_identifier .. ":" .. b .. " " ..
                                       Config.rank_mapping[ppermissiondata])
                    if loaded_list[b] == nil then
                        loaded_list[b] = {
                            [ppermissiondata] = Config.rank_mapping[ppermissiondata]
                        }
                    else
                        loaded_list[b][ppermissiondata] = Config.rank_mapping[ppermissiondata]
                    end
                    if Config.offline_cache then
                        if cache[b] == nil then
                            cache[b] = {
                                [ppermissiondata] = "add_principal identifier." .. Config.primary_identifier .. ":" ..
                                    b .. " " .. Config.rank_mapping[ppermissiondata]
                            }
                            SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                        else
                            cache[b][ppermissiondata] = "add_principal identifier." .. Config.primary_identifier ..
                                                            ":" .. b .. " " .. Config.rank_mapping[ppermissiondata]
                            SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                        end
                    end
                end
            end
        end
        if ppermissiondatas ~= nil then
            for _, v in pairs(ppermissiondatas) do
                if Config.rank_mapping[v] ~= nil then
                    for _, b in pairs(identifier) do
                        ExecuteCommand(
                            "add_principal identifier." .. Config.primary_identifier .. ":" .. b .. " " ..
                                Config.rank_mapping[v])
                        if loaded_list[b] == nil then
                            loaded_list[b] = {
                                [v] = Config.rank_mapping[v]
                            }
                        else
                            loaded_list[b][v] = Config.rank_mapping[v]
                        end
                        if Config.offline_cache then
                            if cache[b] == nil then
                                cache[b] = {
                                    [v] = "add_principal identifier." .. Config.primary_identifier .. ":" .. b ..
                                        " " .. Config.rank_mapping[v]
                                }
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            else
                                cache[b][v] =
                                    "add_principal identifier." .. Config.primary_identifier .. ":" .. b .. " " ..
                                        Config.rank_mapping[v]
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            end
                        end
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
            APIKey = GetConvar("SONORAN_CMS_API_KEY")
            COMMID = GetConvar("SONORAN_CMS_COMMUNITY_ID")
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
            if code == 201 then
                local ppermissiondata = json.decode(result)
                if loaded_list[identifier] ~= nil then
                    for k, v in pairs(loaded_list[identifier]) do
                        local has = false
                        for l, b in pairs(ppermissiondata) do
                            if b == k then
                                has = true
                            end
                        end
                        if not has then
                            loaded_list[identifier][k] = nil
                            ExecuteCommand("remove_principal identifier." .. Config.primary_identifier .. ":" ..
                                               identifier .. " " .. v)
                            if Config.offline_cache then
                                cache[identifier][k] = nil
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            end
                        end
                    end
                end
                for _, v in pairs(ppermissiondata) do
                    if Config.rank_mapping[v] ~= nil then
                        ExecuteCommand(
                            "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                                Config.rank_mapping[v])
                        if loaded_list[identifier] == nil then
                            loaded_list[identifier] = {
                                [v] = Config.rank_mapping[v]
                            }
                        else
                            loaded_list[identifier][v] = Config.rank_mapping[v]
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
                deferrals.done()
            end
        end, "POST", json.encode({
            id = COMMID,
            key = APIKey,
            type = "GET_ACCOUNT_RANKS",
            data = {{
                apiId = identifier
            }}
        }), {
            ["Content-Type"] = "application/json"
        })
end)

RegisterCommand("refreshpermissions", function(src, _, _)
    local identifier
    for _, v in pairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len(Config.primary_identifier .. ":")) == Config.primary_identifier .. ":" then
            identifier = string.sub(v, string.len(Config.primary_identifier .. ":") + 1)
        end
    end
    local payload = {}
    payload["id"] = COMMID
    payload["key"] = APIKey
    payload["type"] = "GET_ACCOUNT_RANKS"
    payload["data"] = {{
        ["apiId"] = identifier
    }}
    PerformHttpRequest("https://cmsapi.dev.sonoransoftware.com/general/get_account_ranks",
        function(code, result, _)
            if code == 201 then
                local ppermissiondata = json.decode(result)
                if loaded_list[identifier] ~= nil then
                    for k, v in pairs(loaded_list[identifier]) do
                        local has = false
                        for l, b in pairs(ppermissiondata) do
                            if b == k then
                                has = true
                            end
                        end
                        if not has then
                            loaded_list[identifier][k] = nil
                            ExecuteCommand("remove_principal identifier." .. Config.primary_identifier .. ":" ..
                                               identifier .. " " .. v)
                            if Config.offline_cache then
                                cache[identifier][k] = nil
                                SaveResourceFile(GetCurrentResourceName(), "cache.json", json.encode(cache))
                            end
                        end
                    end
                end
                for _, v in pairs(ppermissiondata) do
                    if Config.rank_mapping[v] ~= nil then
                        ExecuteCommand(
                            "add_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " ..
                                Config.rank_mapping[v])
                        if loaded_list[identifier] == nil then
                            loaded_list[identifier] = {
                                [v] = Config.rank_mapping[v]
                            }
                        else
                            loaded_list[identifier][v] = Config.rank_mapping[v]
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
        end, "POST", json.encode(payload), {
            ["Content-Type"] = "application/json"
        })
end)

RegisterCommand("permissiontest", function(src, args, _)
    if IsPlayerAceAllowed(src, args[1]) then
        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            multiline = true,
            args = {"SonoranPermissions", "true"}
        })
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"SonoranPermissions", "false"}
        })
    end
end, false)

AddEventHandler('playerDropped', function()
    local src = source
    local identifier
    for _, v in pairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len(Config.primary_identifier .. ":")) == Config.primary_identifier .. ":" then
            identifier = string.sub(v, string.len(Config.primary_identifier .. ":") + 1)
        end
    end

    if loaded_list[identifier] ~= nil then
        for _, v in pairs(loaded_list[identifier]) do
            ExecuteCommand(
                "remove_principal identifier." .. Config.primary_identifier .. ":" .. identifier .. " " .. v)
        end
    end
end)
