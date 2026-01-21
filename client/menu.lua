TowingMenu = {}
TowingMenu.CurrentMode = nil -- "bed" ou "winch"
TowingMenu.WinchSubMode = nil -- "control" ou "attach"

function TowingMenu.OpenMainMenu(towTruck)
    if not towTruck then return end
    
    local options = {
        {
            title = 'Controlar Rampa',
            description = 'Controlar movimento da rampa do caminhão',
            icon = 'truck-ramp-box',
            onSelect = function()
                TowingMenu.OpenBedControlMenu(towTruck)
            end
        }
    }
    
    -- Só mostra opção de guincho se houver veículo conectado
    if towTruck:IsCarHooked() then
        options[#options + 1] = {
            title = 'Controlar Guincho',
            description = 'Controlar guincho e veículo rebocado',
            icon = 'link',
            onSelect = function()
                TowingMenu.OpenWinchControlMenu(towTruck)
            end
        }
    end
    
    lib.registerContext({
        id = 'towing_main_menu',
        title = 'Menu de Reboque',
        options = options
    })
    
    lib.showContext('towing_main_menu')
end

function TowingMenu.OpenBedControlMenu(towTruck)
    TowingMenu.CurrentMode = "bed"
    
    lib.registerContext({
        id = 'towing_bed_menu',
        title = 'Controle de Rampa',
        menu = 'towing_main_menu',
        options = {
            {
                title = 'Informação',
                description = 'Use as setas ← → para controlar\nPressione M para voltar ao menu',
                icon = 'circle-info',
                readOnly = true
            },
            {
                title = '→ Avançar Rampa',
                description = 'Pressione seta direita',
                icon = 'arrow-right',
                readOnly = true
            },
            {
                title = '← Recuar Rampa',
                description = 'Pressione seta esquerda',
                icon = 'arrow-left',
                readOnly = true
            }
        }
    })
    
    lib.showContext('towing_bed_menu')
    
    -- Inicia thread de controle
    TowingMenu.StartBedControlThread(towTruck)
end

function TowingMenu.OpenWinchControlMenu(towTruck)
    TowingMenu.CurrentMode = "winch"
    TowingMenu.WinchSubMode = "control"
    
    lib.registerContext({
        id = 'towing_winch_menu',
        title = 'Controle de Guincho',
        menu = 'towing_main_menu',
        options = {
            {
                title = 'Informação',
                description = 'Use as setas ↑ ↓ para controlar corda\nPressione N para alternar modo\nPressione M para menu',
                icon = 'circle-info',
                readOnly = true
            },
            {
                title = '↑ Puxar Corda',
                description = 'Pressione seta cima',
                icon = 'arrow-up',
                readOnly = true
            },
            {
                title = '↓ Soltar Corda',
                description = 'Pressione seta baixo',
                icon = 'arrow-down',
                readOnly = true
            },
            {
                title = 'Alternar para Modo Anexar/Desanexar',
                description = 'Pressione N',
                icon = 'rotate',
                readOnly = true
            }
        }
    })
    
    lib.showContext('towing_winch_menu')
    
    -- Inicia thread de controle
    TowingMenu.StartWinchControlThread(towTruck)
end

function TowingMenu.OpenWinchAttachMenu(towTruck)
    TowingMenu.WinchSubMode = "attach"
    
    local isStrapped = towTruck.towingCarHandle and IsEntityAttachedToEntity(
        towTruck.truckHandle or towTruck.bedHandle, 
        towTruck.towingCarHandle
    )
    
    lib.registerContext({
        id = 'towing_winch_attach_menu',
        title = 'Anexar/Desanexar Veículo',
        menu = 'towing_winch_menu',
        options = {
            {
                title = 'Informação',
                description = 'Use as setas para ações\nPressione N para voltar ao controle\nPressione M para menu',
                icon = 'circle-info',
                readOnly = true
            },
            {
                title = isStrapped and '↑ Desanexar Veículo' or '↑ Anexar Veículo',
                description = 'Pressione seta cima',
                icon = isStrapped and 'link-slash' or 'link',
                readOnly = true
            },
            {
                title = '↓ Remover Guincho',
                description = 'Pressione seta baixo',
                icon = 'trash',
                readOnly = true
            },
            {
                title = 'Voltar ao Controle de Corda',
                description = 'Pressione N',
                icon = 'rotate',
                readOnly = true
            }
        }
    })
    
    lib.showContext('towing_winch_attach_menu')
end

function TowingMenu.StartBedControlThread(towTruck)
    Citizen.CreateThread(function()
        while TowingMenu.CurrentMode == "bed" do
            Citizen.Wait(0)
            
            -- Seta Direita - Avançar (Baixar)
            if IsControlJustPressed(0, 175) then -- RIGHT
                towTruck:SetAction(TowTruck.ACTION.LOWERING)
            elseif IsControlJustReleased(0, 175) then
                towTruck:SetAction(TowTruck.ACTION.NONE)
            end
            
            -- Seta Esquerda - Recuar (Subir)
            if IsControlJustPressed(0, 174) then -- LEFT
                towTruck:SetAction(TowTruck.ACTION.RAISING)
            elseif IsControlJustReleased(0, 174) then
                towTruck:SetAction(TowTruck.ACTION.NONE)
            end
            
            -- M - Abrir Menu
            if IsControlJustPressed(0, 244) then -- M
                TowingMenu.CurrentMode = nil
                TowingMenu.OpenMainMenu(towTruck)
                break
            end
            
            -- ESC - Sair
            if IsControlJustPressed(0, 322) then -- ESC
                TowingMenu.CurrentMode = nil
                towTruck:SetAction(TowTruck.ACTION.NONE)
                break
            end
        end
    end)
end

function TowingMenu.StartWinchControlThread(towTruck)
    Citizen.CreateThread(function()
        while TowingMenu.CurrentMode == "winch" do
            Citizen.Wait(0)
            
            if TowingMenu.WinchSubMode == "control" then
                -- Modo Controle de Corda
                
                -- Seta Cima - Puxar
                if IsControlPressed(0, 172) then -- UP
                    if towTruck.hookRopeHandle and DoesRopeExist(towTruck.hookRopeHandle) then
                        ActivatePhysics(towTruck.towingCarHandle)
                        StartRopeWinding(towTruck.hookRopeHandle)
                        FreezeEntityPosition(towTruck.truckHandle, true)
                    end
                elseif IsControlJustReleased(0, 172) then
                    if towTruck.hookRopeHandle and DoesRopeExist(towTruck.hookRopeHandle) then
                        StopRopeWinding(towTruck.hookRopeHandle)
                        FreezeEntityPosition(towTruck.truckHandle, false)
                    end
                end
                
                -- Seta Baixo - Soltar
                if IsControlPressed(0, 173) then -- DOWN
                    if towTruck.hookRopeHandle and DoesRopeExist(towTruck.hookRopeHandle) then
                        ActivatePhysics(towTruck.towingCarHandle)
                        StartRopeUnwindingFront(towTruck.hookRopeHandle)
                        FreezeEntityPosition(towTruck.truckHandle, true)
                    end
                elseif IsControlJustReleased(0, 173) then
                    if towTruck.hookRopeHandle and DoesRopeExist(towTruck.hookRopeHandle) then
                        StopRopeUnwindingFront(towTruck.hookRopeHandle)
                        FreezeEntityPosition(towTruck.truckHandle, false)
                    end
                end
                
                -- N - Alternar para modo Anexar
                if IsControlJustPressed(0, 249) then -- N
                    TowingMenu.OpenWinchAttachMenu(towTruck)
                end
                
            elseif TowingMenu.WinchSubMode == "attach" then
                -- Modo Anexar/Desanexar
                
                -- Seta Cima - Anexar/Desanexar
                if IsControlJustPressed(0, 172) then -- UP
                    local attachTarget = towTruck.truckHandle
                    if towTruck.bedHandle then
                        attachTarget = towTruck.bedHandle
                    end
                    
                    local isStrapped = IsEntityAttachedToEntity(attachTarget, towTruck.towingCarHandle)
                    
                    if isStrapped then
                        -- Desanexar
                        towTruck:DetachCar()
                        towTruck:SetTowingCar(nil)
                        lib.notify({
                            title = 'Reboque',
                            description = 'Veículo desanexado',
                            type = 'success'
                        })
                        TowingMenu.CurrentMode = nil
                        TowingMenu.WinchSubMode = nil
                    else
                        -- Anexar
                        if towTruck.hookRopeHandle then
                            DeleteRope(towTruck.hookRopeHandle)
                            towTruck:SetRopeData(nil)
                            towTruck.hookRopeHandle = nil
                        end
                        towTruck:AttachCarToBed()
                        lib.notify({
                            title = 'Reboque',
                            description = 'Veículo anexado',
                            type = 'success'
                        })
                        TowingMenu.OpenWinchAttachMenu(towTruck)
                    end
                end
                
                -- Seta Baixo - Remover Guincho
                if IsControlJustPressed(0, 173) then -- DOWN
                    if towTruck.hookRopeHandle then
                        DeleteRope(towTruck.hookRopeHandle)
                        towTruck:SetRopeData(nil)
                        towTruck.hookRopeHandle = nil
                    end
                    towTruck.towingCarAttachOffset = nil
                    towTruck:SetTowingCar(nil)
                    lib.notify({
                        title = 'Reboque',
                        description = 'Guincho removido',
                        type = 'success'
                    })
                    TowingMenu.CurrentMode = nil
                    TowingMenu.WinchSubMode = nil
                end
                
                -- N - Voltar ao controle
                if IsControlJustPressed(0, 249) then -- N
                    TowingMenu.OpenWinchControlMenu(towTruck)
                end
            end
            
            -- M - Abrir Menu
            if IsControlJustPressed(0, 244) then -- M
                TowingMenu.OpenMainMenu(towTruck)
            end
            
            -- ESC - Sair
            if IsControlJustPressed(0, 322) then -- ESC
                TowingMenu.CurrentMode = nil
                TowingMenu.WinchSubMode = nil
                if towTruck.hookRopeHandle and DoesRopeExist(towTruck.hookRopeHandle) then
                    StopRopeWinding(towTruck.hookRopeHandle)
                    StopRopeUnwindingFront(towTruck.hookRopeHandle)
                end
                FreezeEntityPosition(towTruck.truckHandle, false)
                break
            end
        end
    end)
end

-- Exporta para uso externo
exports('OpenTowingMenu', function()
    if currentTowTruck then
        TowingMenu.OpenMainMenu(currentTowTruck)
    else
        lib.notify({
            title = 'Reboque',
            description = 'Você precisa estar em um caminhão de reboque',
            type = 'error'
        })
    end
end)