TowTruck = {}
TowTruck.__index = TowTruck

-- Factory: Create a new tow truck instance
function TowTruck.new(vehicleEntity, vehicleNetId)
    local model = GetEntityModel(vehicleEntity)
    local modelName = GetDisplayNameFromVehicleModel(model)
    
    local config = Config.TowTrucks[modelName] or Config.DefaultTruck
    
    local self = setmetatable({}, TowTruck)
    
    self.entity = vehicleEntity
    self.netId = vehicleNetId
    self.modelName = modelName
    self.config = config
    self.type = config.type
    
    -- Ramp state machine
    self.ramp = {
        state = 'up', -- up, down, moving_up, moving_down
        speed = 2.0,
        isAnimating = false,
    }
    
    -- Winch instance
    self.winch = Winch.new(vehicleNetId, vehicleEntity)
    
    -- Control state
    self.isControlling = false
    self.currentMode = nil -- 'ramp' or 'winch'
    
    -- Initialize StateBags
    self:initStateBags()
    
    return self
end

-- Initialize StateBags for network synchronization
function TowTruck:initStateBags()
    local stateBag = Entity(self.entity).state
    
    stateBag:set('tow_truck_type', self.type, true)
    stateBag:set('ramp_state', self.ramp.state, true)
    stateBag:set('winch_state', 'idle', true)
    stateBag:set('winch_submode', 'rope', true)
end

-- Raise ramp (PROP_BASED only)
function TowTruck:raiseRamp()
    if self.type ~= 'PROP_BASED' then
        return false
    end
    
    if self.ramp.state == 'up' or self.ramp.isAnimating then
        return false
    end
    
    self.ramp.isAnimating = true
    self.ramp.state = 'moving_up'
    
    -- Animate ramp bone rotation
    local bone = GetEntityBoneIndexByName(self.entity, self.config.rampBone)
    if bone ~= -1 then
        local startRot = GetEntityBoneRotation(self.entity, bone)
        local targetRot = self.config.rampUpRotation
        
        local duration = 2000 -- 2 seconds
        local startTime = GetGameTimer()
        
        local function animateRamp()
            local elapsed = GetGameTimer() - startTime
            local progress = math.min(elapsed / duration, 1.0)
            
            local currentRot = startRot + ((targetRot - startRot) * progress)
            SetEntityBoneRotation(self.entity, bone, 0.0, currentRot, 0.0)
            
            if progress >= 1.0 then
                self.ramp.state = 'up'
                self.ramp.isAnimating = false
                self:updateRampStateBag()
                return
            end
            
            SetTimeout(10, animateRamp)
        end
        
        animateRamp()
    end
    
    return true
end

-- Lower ramp (PROP_BASED only)
function TowTruck:lowerRamp()
    if self.type ~= 'PROP_BASED' then
        return false
    end
    
    if self.ramp.state == 'down' or self.ramp.isAnimating then
        return false
    end
    
    self.ramp.isAnimating = true
    self.ramp.state = 'moving_down'
    
    -- Animate ramp bone rotation
    local bone = GetEntityBoneIndexByName(self.entity, self.config.rampBone)
    if bone ~= -1 then
        local startRot = GetEntityBoneRotation(self.entity, bone)
        local targetRot = self.config.rampDownRotation
        
        local duration = 2000
        local startTime = GetGameTimer()
        
        local function animateRamp()
            local elapsed = GetGameTimer() - startTime
            local progress = math.min(elapsed / duration, 1.0)
            
            local currentRot = startRot + ((targetRot - startRot) * progress)
            SetEntityBoneRotation(self.entity, bone, 0.0, currentRot, 0.0)
            
            if progress >= 1.0 then
                self.ramp.state = 'down'
                self.ramp.isAnimating = false
                self:updateRampStateBag()
                return
            end
            
            SetTimeout(10, animateRamp)
        end
        
        animateRamp()
    end
    
    return true
end

-- Raise forks (SCOOP_BASED only)
function TowTruck:raiseForks()
    if self.type ~= 'SCOOP_BASED' then
        return false
    end
    
    if self.ramp.state == 'up' or self.ramp.isAnimating then
        return false
    end
    
    self.ramp.isAnimating = true
    self.ramp.state = 'moving_up'
    
    local bone = GetEntityBoneIndexByName(self.entity, self.config.forkBone)
    if bone ~= -1 then
        local startZ = self.config.forkDownZ
        local targetZ = self.config.forkUpZ
        
        local duration = 2000
        local startTime = GetGameTimer()
        
        local function animateForks()
            local elapsed = GetGameTimer() - startTime
            local progress = math.min(elapsed / duration, 1.0)
            
            local currentZ = startZ + ((targetZ - startZ) * progress)
            local boneCoords = GetWorldPositionOfEntityBone(self.entity, bone)
            SetEntityBonePosition(self.entity, bone, boneCoords.x, boneCoords.y, currentZ)
            
            if progress >= 1.0 then
                self.ramp.state = 'up'
                self.ramp.isAnimating = false
                self:updateRampStateBag()
                return
            end
            
            SetTimeout(10, animateForks)
        end
        
        animateForks()
    end
    
    return true
end

-- Lower forks (SCOOP_BASED only)
function TowTruck:lowerForks()
    if self.type ~= 'SCOOP_BASED' then
        return false
    end
    
    if self.ramp.state == 'down' or self.ramp.isAnimating then
        return false
    end
    
    self.ramp.isAnimating = true
    self.ramp.state = 'moving_down'
    
    local bone = GetEntityBoneIndexByName(self.entity, self.config.forkBone)
    if bone ~= -1 then
        local startZ = self.config.forkUpZ
        local targetZ = self.config.forkDownZ
        
        local duration = 2000
        local startTime = GetGameTimer()
        
        local function animateForks()
            local elapsed = GetGameTimer() - startTime
            local progress = math.min(elapsed / duration, 1.0)
            
            local currentZ = startZ + ((targetZ - startZ) * progress)
            local boneCoords = GetWorldPositionOfEntityBone(self.entity, bone)
            SetEntityBonePosition(self.entity, bone, boneCoords.x, boneCoords.y, currentZ)
            
            if progress >= 1.0 then
                self.ramp.state = 'down'
                self.ramp.isAnimating = false
                self:updateRampStateBag()
                return
            end
            
            SetTimeout(10, animateForks)
        end
        
        animateForks()
    end
    
    return true
end

-- Generic toggle ramp/forks
function TowTruck:toggleRamp()
    if self.ramp.state == 'up' then
        if self.type == 'PROP_BASED' then
            return self:lowerRamp()
        else
            return self:lowerForks()
        end
    else
        if self.type == 'PROP_BASED' then
            return self:raiseRamp()
        else
            return self:raiseForks()
        end
    end
end

-- Update ramp StateBag
function TowTruck:updateRampStateBag()
    local stateBag = Entity(self.entity).state
    stateBag:set('ramp_state', self.ramp.state, true)
end

-- Check if player is near truck
function TowTruck:isPlayerNear(distance)
    distance = distance or 15.0
    local playerCoords = GetEntityCoords(PlayerPedId())
    local truckCoords = GetEntityCoords(self.entity)
    return #(playerCoords - truckCoords) <= distance
end

-- Stop all operations and cleanup
function TowTruck:stopControl()
    self.isControlling = false
    self.currentMode = nil
    self.winch:releaseHook()
    self.winch:detachVehicle()
    UI.hideTextUI()
end

return TowTruck
