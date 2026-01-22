Target = {}

-- Setup ox_target for a tow truck
function Target.setupTargets(towTruck)
    local modelName = towTruck.modelName
    local offsets = Config.TargetOffsets[modelName]
    
    if not offsets then
        return
    end

    for _, targetData in ipairs(offsets) do
        local offset = targetData.offset
        local distance = targetData.distance or 2.0
        local size = targetData.size or 0.5
        local mode = targetData.mode
        local label = targetData.label

        exports.ox_target:addEntity(towTruck.netId, {
            label = label,
            icon = mode == 'ramp' and 'fa-solid fa-arrow-up-down' or 'fa-solid fa-hook',
            distance = distance,
            offset = offset,
            onSelect = function()
                Target.selectMode(towTruck, mode)
            end,
            canInteract = function(entity)
                return DoesEntityExist(entity)
            end
        })
    end
end

-- Handle mode selection from target
function Target.selectMode(towTruck, mode)
    if mode == 'ramp' then
        TriggerEvent('tow:startRampControl', towTruck)
    elseif mode == 'winch' then
        TriggerEvent('tow:startWinchControl', towTruck)
    end
end

-- Remove targets from a truck
function Target.removeTargets(netId)
    exports.ox_target:removeEntity(netId)
end

return Target
