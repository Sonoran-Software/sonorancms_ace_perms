Config = {}

-- General Configuration Section --
Config.configuration_version = 1.0
Config.debug_mode = false -- Only useful for developers and if support asks you to enable it

Config.primary_identifier = "fivem" -- The primary identifier to use, options are: license, fivem, steam, discord

Config.rank_mapping = {
    ["9"] = "group.ace"
}

Config.offline_cache = true -- If set to true role permissions will be cached on the server in-case CMS goes down, the
-- cache will be updated everytime the player rejoins, the rank refresh command is run, or has a rank change in CMS
