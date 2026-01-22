local activeTruck = nil
local currentMode = nil
local winchSubMode = 'rope'
local lastControlUpdate = 0
local controlUpdateInterval = 50 -- ms between control updates

-- Get closest tow truck to player
local function getClosestTowTruck()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestTruck = nil
    local closestDistance = math.huge

    for _, modelName in ipairs(Config.TowTrucks) do
        local model = GetHashKey(modelName)
        local vehicleHandle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 50.0, model, 70)
        
        if vehicleHandle and vehicleHandle ~= 0 then
            local distance = #(playerCoords - GetEntityCoords(vehicleHandle))
            if distance < closestDistance then
                closestDistance = distance
                closestTruck = vehicleHandle
            end
        end
    end
    
    return closestTruck
end

-- Check if vehicle is a registered tow truck
local function isTowTruck(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    return Config.TowTrucks[modelName] ~= nil
end

-- Initialize tow truck instance
local function initializeTowTruck(vehicleEntity)
    if not isTowTruck(vehicleEntity) then
        return nil
    end

    local netId = PossiblyNetworkId(vehicleEntity)
    activeTruck = TowTruck.new(vehicleEntity, netId)
    
    -- Setup ox_target points
    Target.setupTargets(activeTruck)
    
    UI.notify('Reboque', 'Caminhão de reboque detectado!', 'success')
    
    return activeTruck
end

-- Start ramp control mode
local function startRampControl(truck)
    if not truck then
        truck = activeTruck
    end
    
    if not truck then
        UI.notify('Erro', 'Nenhum caminhão próximo', 'error')
        return
    end
    
    currentMode = 'ramp'
    truck.isControlling = true
    truck.currentMode = 'ramp'
    
    UI.showRampMode(truck.ramp.state)
end

-- Start winch control mode
local function startWinchControl(truck)
    if not truck then
        truck = activeTruck
    end
    
    if not truck then
        UI.notify('Erro', 'Nenhum caminhão próximo', 'error')
        return
    end
    
    currentMode = 'winch'
    winchSubMode = 'rope'
    truck.isControlling = true
    truck.currentMode = 'winch'
    truck.winch.subMode = winchSubMode
    
    UI.showWinchMode('winch', winchSubMode)
end

-- Stop current control mode
local function stopControl()
    if activeTruck then
        activeTruck:stopControl()
    end
    currentMode = nil
    winchSubMode = 'rope'
    UI.hideTextUI()
end

-- Open main menu
local function openMainMenu()
    if not activeTruck then
        local truck = getClosestTowTruck()
        if truck then
            activeTruck = initializeTowTruck(truck)
        else
            UI.notify('Erro', 'Nenhum caminhão próximo', 'error')
            return
        end
    end

    UI.openMainMenu(function(mode)
        if mode == 'ramp' then
            startRampControl(activeTruck)
        elseif mode == 'winch' then
            startWinchControl(activeTruck)
        end
    end)
end

-- Handle ramp mode controls
local function handleRampControls()
    if not activeTruck or not activeTruck.isControlling or currentMode ~= 'ramp' then
        return
    end

    -- Arrow Left = Lower Ramp
    if IsControlJustPressed(0, GetHashKey(Config.Keybinds.rampDown)) then
        if activeTruck.type == 'PROP_BASED' then
            activeTruck:lowerRamp()
        else
            activeTruck:lowerForks()
        end
        UI.showRampMode(activeTruck.ramp.state)
    end

    -- Arrow Right = Raise Ramp
    if IsControlJustPressed(0, GetHashKey(Config.Keybinds.rampUp)) then
        if activeTruck.type == 'PROP_BASED' then
            activeTruck:raiseRamp()
        else
            activeTruck:raiseForks()
        end
        UI.showRampMode(activeTruck.ramp.state)
    end

    -- M = Back to menu
    if IsControlJustPressed(0, GetHashKey(Config.Keybinds.backMenu)) then
        stopControl()
        openMainMenu()
    end

    -- ESC = Close
    if IsControlJustPressed(0, GetHashKey(Config.Keybinds.closeUI)) then
        stopControl()
    end
end

-- Handle winch mode controls
local function handleWinchControls()
    if not activeTruck or not activeTruck.isControlling or currentMode ~= 'winch' then
        return
    end

    local now = GetGameTimer()
    if now - lastControlUpdate < controlUpdateInterval then
        return
    end
    lastControlUpdate = now
    local delta = controlUpdateInterval

    -- N = Toggle between rope and attach submodes
    if IsControlJustPressed(0, GetHashKey(Config.Keybinds.winchToggleMode)) then
        winchSubMode = activeTruck.winch:toggleSubMode()
        UI.showWinchMode('winch', winchSubMode)
    end

    if winchSubMode == 'rope' then
        -- Arrow Up = Pull rope
        if IsControlPressed(0, GetHashKey(Config.Keybinds.winchUp)) then
            if not activeTruck.winch.hook.grabbed then
                activeTruck.winch:grabHook()
            else
                activeTruck.winch:pullRope(delta)
            end
        end

        -- Arrow Down = Release rope
        if IsControlPressed(0, GetHashKey(Config.Keybinds.winchDown)) then
            if activeTruck.winch.rope.created then
                activeTruck.winch:releaseRope(delta)
            end
        end

    elseif winchSubMode == 'attach' then
        -- Arrow Up = Attach/Detach vehicle
        if IsControlJustPressed(0, GetHashKey(Config.Keybinds.winchUp)) then
            if not activeTruck.winch.attachedVehicle.attached then
                if activeTruck.winch:chooseVehicle() then
                    activeTruck.winch:createRope()
                    activeTruck.winch:attachVehicle()
                    UI.notify('Guincho', 'Veículo anexado', 'success')
                else
                    UI.notify('Erro', 'Nenhum veículo na mira', 'error')
                end
            else
                activeTruck.winch:detachVehicle()
                UI.notify('Guincho', 'Veículo desanexado', 'info')
            end
        end

        -- Arrow Down = Remove winch (release hook)
        if IsControlJustPressed(0, GetHashKey(Config.Keybinds.winchDown)) then
            activeTruck.winch:releaseHook()
            UI.notify('Guincho', 'Gancho solto', 'info')
        end
    end

    -- M = Back to menu
    if IsControlJustPressed(0, GetHashKey(Config.Keybinds.backMenu)) then
        stopControl()
        openMainMenu()
    end

    -- ESC = Close
    if IsControlJustPressed(0, GetHashKey(Config.Keybinds.closeUI)) then
        stopControl()
    end
end

-- Detect player entering tow truck
AddEventHandler('enteredVehicle', function(vehicle, seat)
    if seat == -1 and isTowTruck(vehicle) then
        if not activeTruck or activeTruck.entity ~= vehicle then
            activeTruck = initializeTowTruck(vehicle)
        end
    end
end)

-- Register network events
RegisterNetEvent('tow:startRampControl', function(truck)
    startRampControl(truck)
end)

RegisterNetEvent('tow:startWinchControl', function(truck)
    startWinchControl(truck)
end)

-- Main control loop
CreateThread(function()
    while true do
        Wait(0)
        
        handleRampControls()
        handleWinchControls()
    end
end)

-- Keybind for opening main menu
RegisterCommand('towtruck', function()
    openMainMenu()
end, false)

-- Register export for opening menu
exports('openMenu', openMainMenu)

print('^2[Tow Truck] System loaded!^7')
