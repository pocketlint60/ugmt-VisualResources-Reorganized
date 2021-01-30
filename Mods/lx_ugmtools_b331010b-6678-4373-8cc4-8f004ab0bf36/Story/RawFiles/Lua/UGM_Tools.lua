-- Activate/Deactivate
local function MassActivateDeactivate(item, event)
    if event == "GM_Activate" then
        for char,x in pairs(selected) do
            RemoveStatus(char, "DEACTIVATED")
        end
    elseif event == "GM_Deactivate" then
        for char,x in pairs(selected) do
            ApplyStatus(char, "DEACTIVATED", -1.0, 1)
        end
    else return end
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", MassActivateDeactivate)

local function MassSheatheUnsheathe(item, event)
    if event == "GM_Sheathe" then
        for char,x in pairs(selected) do
            RemoveStatus(char, PersistentVars.selectType.current)
            RemoveStatus(char, "UNSHEATHED")
        end
    elseif event == "GM_Unsheathe" then
        for char,x in pairs(selected) do
            RemoveStatus(char, PersistentVars.selectType.current)
            ApplyStatus(char, "UNSHEATHED", -1.0, 1)
        end
    else return end
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", MassSheatheUnsheathe)

local function StoryFreezeManagement(item, event)
    if event == "GM_Freeze_Players" then
        if GetTableSize(selected) < 1 then
            local players = Osi.DB_IsPlayer:Get(nil)
            for i,player in pairs(players) do
                CharacterFreeze(player)
                ApplyStatus(player, "GM_STORYFREEZE", -1.0)
            end
        else
            for char,x in pairs(selected) do
                CharacterFreeze(char)
                ApplyStatus(char, "GM_STORYFREEZE", -1.0)
            end
        end
    elseif event == "GM_Unfreeze_Players" then
        if GetTableSize(selected) < 1 then
            local players = Osi.DB_IsPlayer(nil)
            for i,player in pairs(players) do
                RemoveStatus(player, "GM_STORYFREEZE")
            end
        else
            for char,x in pairs(selected) do
                RemoveStatus(char, "GM_STORYFREEZE")
            end
        end
    else return end
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", StoryFreezeManagement)

local function Unfreeze(char, status, causee)
    if status ~= "GM_STORYFREEZE" then return end
    CharacterUnfreeze(char)
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", Unfreeze)

local function FetchVisibleStatus(character)
    local char = Ext.GetCharacter(character)
    local charStatuses = char.GetStatuses(char)
    local list = {}
    for i,status in pairs(charStatuses) do
        if string.len(NRD_StatGetString(status, "DisplayName")) > 0 and status ~= PersistentVars.targetType.current then
            table.insert(list, status)
        end
    end
    return list
end

local function CopyRemoveStatus(item, event)
    if GetTableSize(selected) == 0 then return end
    if event == "GM_Copy_Status" then
        if target == nil then return end
        local statuses = FetchVisibleStatus(target)
        for char,x in pairs(selected) do
            for i,status in pairs(statuses) do
                local duration = GetStatusTurns(target, status)
                ApplyStatus(char, status, duration, 1)
            end
        end
    elseif event == "GM_Clear_Status" then
        for char,x in pairs(selected) do
            local statuses = FetchVisibleStatus(char)
            for i,status in pairs(statuses) do
                RemoveStatus(char, status)
            end
        end
    else return end
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", CopyRemoveStatus)

-- Transform character
local function TransformCharacter(item, event)
    if event ~= "GM_Transform" or target == nil then return end
    for char,x in pairs(selected) do
        CharacterTransformAppearanceTo(char, target, 0, 1)
    end
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", TransformCharacter)

-- Bossifier
local function Bossify(item, event)
    if event ~= "GM_Bossify" then return end
    for char,x in pairs(selected) do
        if IsBoss(char) == 0 then
            SetIsBoss(char, 1)
        else
            SetIsBoss(char, 0)
        end
    end
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", Bossify)

-- Make PC or NPC
local function ManagePlayable(item, event)
    if event == "GM_MakePlayer" then
        for char,x in pairs(selected) do
            CharacterMakePlayer(char)
            Osi.DB_IsPlayer(char)
        end
    elseif event == "GM_MakeNPC" then
        for char,x in pairs(selected) do
            CharacterMakeNPC(char)
            Osi.DB_IsPlayer:Delete(char)
        end
    elseif event == "GM_MakeFollower" and target ~= nil then
        for char,x in pairs(selected) do
            CharacterAddToPlayerCharacter(char, target)
        end
    elseif event == "GM_UnmakeFollower" then
        for char,x in pairs(selected) do
            local owner = CharacterGetOwner(char)
            CharacterRemoveFromPlayerCharacter(char, owner)
        end
    elseif event == "GM_AssignPlayer" and target ~= nil then
        for char,x in pairs(selected) do
            local user = CharacterGetReservedUserID(target)
            CharacterAssignToUser(char, user)
        end
    else return end
    ClearSelectionAndTarget()
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", ManagePlayable)
 
function UGM_ApplyStatus(status, duration)
    if duration ~= -1 then duration = duration * 6.0 end
    if NRD_StatExists(string.upper(status)) then
        for char,x in pairs(selected) do
            ApplyStatus(char, string.upper(status), duration, 1)
        end
    else
        print("This status does not exists !")
    end
end

function UGM_ShowVisibleStatuses()
    for char,x in pairs(selected) do
        print("Character: "..Ext.GetCharacter(char).DisplayName)
        local statuses = FetchVisibleStatus(char)
        for i,status in pairs(statuses) do
            print(status)
        end
    end
end
