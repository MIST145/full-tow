--AttachEntityToEntity(m24_2_prop_m42_rc_controller_01a, 16ramrb, GetEntityBoneIndexByName(16ramrb, 'indicator_lr'), -0.1480, 0.0720, -0.6000, 1.00, 0.00, -92.50, 0, 0, 1, 0, 0, 1)
AttachEntityToEntity(m24_2_prop_m42_rc_controller_01a, 16ramrb, GetEntityBoneIndexByName(16ramrb, 'attach_male'), -0.9440, 0.0500, 0.0200, 0.00, 0.00, -93.00, 0, 0, 1, 0, 0, 1)

AttachEntityToEntity(m24_2_prop_m42_rc_controller_01a, ct660tow, GetEntityBoneIndexByName(ct660tow, 'misc_b'), -1.3740, 0.4860, -0.0600, 4.50, 0.00, -92.00, 0, 0, 1, 0, 0, 1)

AttachEntityToEntity(m24_2_prop_m42_rc_controller_01a, 337flatbed, GetEntityBoneIndexByName(337flatbed, 'misc_b'), -1.3920, 0.0520, -0.0600, 9.00, 0.00, -98.50, 0, 0, 1, 0, 0, 1)

AttachEntityToEntity(m24_2_prop_m42_rc_controller_01a, scania, GetEntityBoneIndexByName(scania, 'misc_b'), -1.3660, 0.2280, 0.0400, 6.40, 0.00, -90.75, 0, 0, 1, 0, 0, 1)





AttachEntityToEntity(17mov_radiocontrol, 112towmfd3, GetEntityBoneIndexByName(112towmfd3, 'attach_male'), -1.2420, 0.2360, 0.0600, -0.78, 92.00, -88.25, 0, 0, 1, 0, 0, 1)

AttachEntityToEntity('17mov_radiocontrol', 'flatbedm2', GetEntityBoneIndexByName('flatbedm2', 'misc_b'), -1.3760, 0.2240, 0.0800, 4.00, 90.00, -90.00, 0, 0, 1, 0, 0, 1)

AttachEntityToEntity('17mov_radiocontrol', 'scaniatow', GetEntityBoneIndexByName('scaniatow', 'misc_b'), -1.3860, 0.2300, 0.1000, -1.50, -271.50, -90.00, 0, 0, 1, 0, 0, 1)

AttachEntityToEntity('17mov_radiocontrol', '337flatbed', GetEntityBoneIndexByName('337flatbed', 'misc_b'), -1.4020, 0.0980, 0.0000, 0.00, 92.00, -95.00, 0, 0, 1, 0, 0, 1)

AttachEntityToEntity('17mov_radiocontrol', 'ct660tow', GetEntityBoneIndexByName('ct660tow', 'misc_b'), -1.3800, 0.4900, 0.0600, 0.00, 88.00, -90.00, 0, 0, 1, 0, 0, 1)

AttachEntityToEntity('17mov_radiocontrol', '16ramrb', GetEntityBoneIndexByName('16ramrb', 'attach_male'), -0.9400, 0.0460, 0.1200, -5.00, 91.50, -90.00, 0, 0, 1, 0, 0, 1)

do genero como tem estes 2 modelos:

[`16ramrb`] = {
        truckType = "scoop",
        truckModel = `16ramrb`,
        controlBoxOffset = vector3(-1.17, -4.44, -0.02),
        controler = {
            propName = "m24_2_prop_m42_rc_controller_01a",
            boneName = "attach_male",
            offsetPos = vector3(-0.9440, 0.0500, 0.0200),
            offsetRot = vector3(0.00, 0.00, -93.00),
        },
        hookRoot = {
            boneName = "attach_male",
            offset = vector3(-0.0, -0.04, 0.03),
        },
        bedAttach = {
            boneName = "misc_z",
            offset = vector3(0.00, 0.48, 0.17),
        },
        bedPositions = {
            raised = 0.005,
            lowered = 0.36,
        },
    },

    [`flatbedm2`] = {
        truckType = "scoop",
        truckModel = `flatbedm2`,
        controlBoxOffset = vector3(-1.36, -3.47, 0.40),
        controler = {
            propName = "17mov_radiocontrol",
            boneName = "misc_b",
            offsetPos = vector3(-1.3760, 0.2240, 0.0800),
            offsetRot = vector3(4.00, 90.00, -90.00),
        },
        hookRoot = {
            boneName = "misc_b",
            offset = vector3(-0.0, -0.00, 0.02),
        },
        bedAttach = {
            boneName = "misc_a",
            offset = vector3(0.00, 0.85, 0.17),
        },
        bedPositions = {
            raised = 0.0,
            lowered = 0.36,
        },
    },
fazer com que ao ativar o script para o determinado modelo criar o prop de controler e posicoes para prender no bone e ao desativar deletar, algo como este exemplo:

local vehiclePos = GetEntityCoords(testVehicle)
    
    -- Spawn imp_prop_flatbed_ramp
    local propHash = GetHashKey("17mov_radiocontrol")
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Wait(1)
    end
    
    testProp = CreateObject(propHash, vehiclePos.x, vehiclePos.y, vehiclePos.z, true, false, false)
    SetModelAsNoLongerNeeded(propHash)
    
    -- Attach usando os valores do clipboard
    AttachEntityToEntity(testProp, testVehicle, GetEntityBoneIndexByName(testVehicle, 'attach_male'), -0.9400, 0.0460, 0.1200, -5.00, 91.50, -90.00, 0, 0, 1, 0, 0, 1)