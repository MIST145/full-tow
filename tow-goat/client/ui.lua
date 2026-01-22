UI = {}
UI.currentTextUI = nil
UI.currentMode = nil

-- Open main menu with ramp and winch options
function UI.openMainMenu(callback)
    local menu = {
        {
            title = 'Controlar Rampa',
            description = 'Subir e descer a cama do reboque',
            icon = 'fa-solid fa-arrow-up-down',
            onSelect = function()
                if callback then callback('ramp') end
            end
        },
        {
            title = 'Controlar Guincho',
            description = 'Controlar o sistema de guincho',
            icon = 'fa-solid fa-hook',
            onSelect = function()
                if callback then callback('winch') end
            end
        },
    }

    lib.registerContext({
        id = 'tow_main_menu',
        title = 'Sistema de Reboque',
        options = menu,
        disableInvCheck = true,
    })

    lib.showContext('tow_main_menu')
end

-- Show ramp mode TextUI
function UI.showRampMode(state)
    if UI.currentTextUI then
        lib.hideTextUI()
    end

    local content = string.format(
        "~h~~b~MODO RAMPA~s~\n" ..
        "Estado: %s\n\n" ..
        "~g~← ESQUERDA~s~ - Descer Cama\n" ..
        "~g~DIREITA →~s~ - Subir Cama\n\n" ..
        "~y~M~s~ - Menu Principal\n" ..
        "~r~ESC~s~ - Fechar",
        state or "Parado"
    )

    lib.showTextUI(content, {
        position = Config.TextUI.position,
        offset = {x = Config.TextUI.offset, y = Config.TextUI.offset},
        style = {
            backgroundColor = '#1a1a1a',
            textColor = '#ffffff',
            border = '2px solid #0088ff',
            borderRadius = '8px',
            padding = '12px'
        }
    })

    UI.currentTextUI = 'ramp'
    UI.currentMode = 'ramp'
end

-- Show winch mode TextUI
function UI.showWinchMode(mode, submode)
    if UI.currentTextUI then
        lib.hideTextUI()
    end

    local submodeText = submode == 'rope' and 'CORDA' or 'ANEXAR/DESANEXAR'
    local controlText = submode == 'rope' and
        "~g~↑ CIMA~s~ - Puxar Corda\n~g~↓ BAIXO~s~ - Soltar Corda" or
        "~g~↑ CIMA~s~ - Anexar/Desanexar\n~g~↓ BAIXO~s~ - Remover Guincho"

    local content = string.format(
        "~h~~b~MODO GUINCHO~s~\n" ..
        "Submodo: %s\n\n" ..
        "%s\n\n" ..
        "~c~N~s~ - Alternar Submodo\n" ..
        "~y~M~s~ - Menu Principal\n" ..
        "~r~ESC~s~ - Fechar",
        submodeText,
        controlText
    )

    lib.showTextUI(content, {
        position = Config.TextUI.position,
        offset = {x = Config.TextUI.offset, y = Config.TextUI.offset},
        style = {
            backgroundColor = '#1a1a1a',
            textColor = '#ffffff',
            border = '2px solid #ff8800',
            borderRadius = '8px',
            padding = '12px'
        }
    })

    UI.currentTextUI = 'winch'
    UI.currentMode = 'winch'
end

-- Hide current TextUI
function UI.hideTextUI()
    if UI.currentTextUI then
        lib.hideTextUI()
        UI.currentTextUI = nil
        UI.currentMode = nil
    end
end

-- Show notification
function UI.notify(title, message, type)
    lib.notify({
        title = title,
        description = message,
        type = type or 'info',
        position = 'top',
        duration = 4000,
        icon = 'fa-solid fa-info',
        iconColor = '#0088ff',
    })
end

return UI
