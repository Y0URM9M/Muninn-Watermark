-----------------------
-- Muninn Watermark  --
-----------------------
local isUiOpen = false
local userTurnedOff = false
local autoHideTimer = nil


-- ?? Monitor pause/map UI
Citizen.CreateThread(function()
    local previousState = false

    while true do
        Citizen.Wait(250)
        local isMapOrUiActive = IsRadarHidden() or IsPauseMenuActive()

        if isMapOrUiActive ~= previousState then
            previousState = isMapOrUiActive
            if not userTurnedOff then
                showWM(not isMapOrUiActive)
            end
        end
    end
end)

-- ?? Show/Hide watermark
function showWM(display)
    local success, err = pcall(function()
        SendNUIMessage({
            type = 'DisplayWM',
            visible = display,
            position = config.position
        })
    end)

    if not success then
        print("^1[WM ERROR]^0 NUI message failed: " .. err)
    end

    isUiOpen = display

    -- Start auto-hide timer if enabled and displaying
    if display and config.autoHide then
        if autoHideTimer then
            -- cancel previous timer if one exists
            autoHideTimer = nil
        end

        Citizen.CreateThread(function()
            autoHideTimer = true
            Citizen.Wait(config.hideAfter * 1000)

            if autoHideTimer then -- still active (wasn't toggled off manually)
                showWM(false)
                print("^3[WM]^0 Watermark auto-hidden after " .. config.hideAfter .. " seconds.")
            end
        end)
    end
end

-- ??? Add /watermark command after session starts
Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do
        Citizen.Wait(100)
    end
    TriggerEvent("chat:addSuggestion", "/watermark", "Toggle the watermark display")
end)

-- ?? Framework character selection handling
function HandleCharacterSelection()
    Citizen.Wait(5000) -- shorter wait before showing watermark
    userTurnedOff = false
    showWM(true)
end

if config.framework == 'vorp' then
    RegisterNetEvent("vorp:SelectedCharacter", HandleCharacterSelection)
elseif config.framework == 'rsg' then
    RegisterNetEvent("RSGCore:Client:OnPlayerLoaded", HandleCharacterSelection)
elseif config.framework == 'redemrp' then
    RegisterNetEvent("redemrp_charselect:SpawnCharacter", HandleCharacterSelection)
else
    print("^1[WM ERROR]^0 Unsupported framework in config.")
end

-- ??? Toggle watermark via event
RegisterNetEvent('DisplayWM')
AddEventHandler('DisplayWM', function(status)
    userTurnedOff = not status
    showWM(status)
end)

-- ?? /watermark command
RegisterCommand('watermark', function()
    if config.allowoff then
        local newStatus = not isUiOpen
        autoHideTimer = nil -- cancel any running timer
        TriggerEvent('DisplayWM', newStatus)
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {"^9[RedM-WM]^1 This server has disabled watermark toggling!"}
        })
    end
end)

