Winch = {}
Winch.__index = Winch

-- Initialize winch for a tow truck
function Winch.new(truckNetId, truckEntity)
    local self = setmetatable({}, Winch)
    
    self.truckNetId = truckNetId
    self.truckEntity = truckEntity
    self.ropeLength = 0.0
    self.maxRopeLength = Config.Winch.ropeLength
    self.isRopeTaut = false
    self.ropeBroken = false
    
    -- Hook and rope data
    self.hook = {
        object = nil,
        netId = nil,
        grabbed = false,
    }
    
    self.rope = {
        id = nil,
        created = false,
    }
    
    self.attachedVehicle = {
        netId = nil,
        entity = nil,
        attached = false,
        bone = nil,
    }
    
    -- State machine
    self.state = 'idle' -- idle, hooked, pulling, attached
    self.subMode = 'rope' -- rope, attach
    
    return self
end

-- Toggle between rope and attach submodes
function Winch:toggleSubMode()
    if self.subMode == 'rope' then
        self.subMode = 'attach'
    else
        self.subMode = 'rope'
    end
    
    self:updateStateBag()
    return self.subMode
end

-- Grab hook with raycast to find nearby objects
function Winch:grabHook()
    if self.hook.grabbed then
        return false
    end

    local hookCoords = self:getHookCoords()
    
    -- Raycast for hook object
    local rayHandle = StartShapeTestRay(
        hookCoords.x, hookCoords.y, hookCoords.z,
        hookCoords.x, hookCoords.y, hookCoords.z - 10.0,
        10, -- Object check
        self.truckEntity,
        7
    )
    
    local hit, endCoords, hitEntity = GetShapeTestResult(rayHandle)
    
    if hit == 1 and DoesEntityExist(hitEntity) then
        self.hook.object = hitEntity
        self.hook.netId = PossiblyNetworkId(hitEntity)
        self.hook.grabbed = true
        self.state = 'hooked'
        
        self:updateStateBag()
        return true
    end
    
    return false
end

-- Choose vehicle by raycast for attachment
function Winch:chooseVehicle()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local aheadCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 50.0, 0.0)
    
    -- Raycast for vehicles
    local rayHandle = StartShapeTestRay(
        playerCoords.x, playerCoords.y, playerCoords.z,
        aheadCoords.x, aheadCoords.y, aheadCoords.z,
        10, -- Vehicle check
        self.truckEntity,
        7
    )
    
    local hit, endCoords, hitEntity = GetShapeTestResult(rayHandle)
    
    if hit == 1 and DoesEntityExist(hitEntity) and IsEntityAVehicle(hitEntity) then
        self.attachedVehicle.entity = hitEntity
        self.attachedVehicle.netId = PossiblyNetworkId(hitEntity)
        
        self:updateStateBag()
        return true
    end
    
    return false
end

-- Create rope from hook to vehicle
function Winch:createRope()
    if not self.hook.grabbed or not self.attachedVehicle.entity then
        return false
    end

    if self.rope.created then
        DeleteRope(self.rope.id)
    end

    local hookCoords = GetEntityCoords(self.hook.object)
    local vehicleCoords = GetEntityCoords(self.attachedVehicle.entity)
    
    -- Create rope object
    self.rope.id = AddRope(
        hookCoords.x, hookCoords.y, hookCoords.z,
        vehicleCoords.x, vehicleCoords.y, vehicleCoords.z,
        self.maxRopeLength, 0, 0.5, 0.0, 1.0, false, false,
        false, 1.0, false, nil
    )
    
    self.rope.created = true
    self.ropeLength = #(vehicleCoords - hookCoords)
    self.state = 'pulling'
    
    self:updateStateBag()
    return true
end

-- Pull rope (reel in vehicle)
function Winch:pullRope(delta)
    if not self.rope.created or not self.hook.object or not self.attachedVehicle.entity then
        return false
    end

    self.ropeLength = math.max(5.0, self.ropeLength - (Config.Winch.pullSpeed * delta / 1000))
    self:updateRopeLength()
    
    return true
end

-- Release rope (let out line)
function Winch:releaseRope(delta)
    if not self.rope.created or not self.hook.object or not self.attachedVehicle.entity then
        return false
    end

    self.ropeLength = math.min(self.maxRopeLength, self.ropeLength + (Config.Winch.releaseSpeed * delta / 1000))
    self:updateRopeLength()
    
    return true
end

-- Update rope length visually
function Winch:updateRopeLength()
    if not self.rope.created or not self.hook.object or not self.attachedVehicle.entity then
        return
    end

    local hookCoords = GetEntityCoords(self.hook.object)
    local vehicleCoords = GetEntityCoords(self.attachedVehicle.entity)
    local distance = #(vehicleCoords - hookCoords)
    
    if distance > self.ropeLength then
        -- Pull vehicle towards hook
        local direction = (hookCoords - vehicleCoords) / distance
        local newCoords = vehicleCoords + (direction * (distance - self.ropeLength + 0.5))
        SetEntityCoords(self.attachedVehicle.entity, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
    end
    
    -- Tighten rope visually
    if self.rope.id then
        RopeUnwindingScroll(self.rope.id, self.ropeLength)
    end
end

-- Attach vehicle to truck
function Winch:attachVehicle()
    if not self.attachedVehicle.entity or self.attachedVehicle.attached then
        return false
    end

    -- Attach vehicle to truck (behind and slightly elevated)
    local attachCoords = GetOffsetFromEntityInWorldCoords(self.truckEntity, 0.0, -5.0, 0.0)
    
    SetEntityCoords(self.attachedVehicle.entity, attachCoords.x, attachCoords.y, attachCoords.z + 0.1)
    
    -- In multiplayer, you'd use AttachEntityToEntity here
    -- For now, we're handling via StateBags
    
    self.attachedVehicle.attached = true
    self.state = 'attached'
    
    self:updateStateBag()
    return true
end

-- Detach vehicle
function Winch:detachVehicle()
    if not self.attachedVehicle.attached then
        return false
    end

    -- Drop vehicle on ground
    local vehicleCoords = GetEntityCoords(self.attachedVehicle.entity)
    SetEntityAsNoLongerNeeded(self.attachedVehicle.entity)
    
    self.attachedVehicle.attached = false
    self.attachedVehicle.entity = nil
    self.attachedVehicle.netId = nil
    
    self:updateStateBag()
    return true
end

-- Release hook
function Winch:releaseHook()
    if self.rope.created then
        DeleteRope(self.rope.id)
        self.rope.created = false
    end
    
    self.hook.grabbed = false
    self.hook.object = nil
    self.hook.netId = nil
    self.ropeLength = 0.0
    self.state = 'idle'
    
    self:updateStateBag()
    return true
end

-- Get hook world coordinates
function Winch:getHookCoords()
    local hookOffset = Config.Winch.hookOffset
    return GetOffsetFromEntityInWorldCoords(self.truckEntity, hookOffset.x, hookOffset.y, hookOffset.z)
end

-- Update StateBag with winch data
function Winch:updateStateBag()
    local stateBag = Entity(self.truckEntity).state
    
    stateBag:set('winch_state', self.state, true)
    stateBag:set('winch_submode', self.subMode, true)
    stateBag:set('winch_rope_length', self.ropeLength, true)
    stateBag:set('winch_hook_grabbed', self.hook.grabbed, true)
    stateBag:set('winch_vehicle_attached', self.attachedVehicle.attached, true)
end

return Winch
