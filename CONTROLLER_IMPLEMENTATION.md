# Implementação do Sistema de Prop Controlador

## Resumo
Foi implementado um sistema automático que spawna e gerencia um prop de controlador remoto quando um caminhão de tow é carregado, e o destrói quando o script é desativado.

## Mudanças Realizadas

### 1. **shared/config.lua**
Adicionados dois modelos de caminhão com configurações de controlador:

#### `16ramrb`
```lua
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
    -- ... resto das configurações
}
```

#### `flatbedm2`
```lua
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
    -- ... resto das configurações
}
```

### 2. **client/classes/scoopBased.lua**

#### Alterações na função `ScoopTowTruck.new`
- Adicionada variável `self.controllerPropHandle = nil` para rastrear o prop
- Chamada automática de `self:SpawnControllerProp()` na inicialização

#### Alterações na função `ScoopTowTruck.ValidateConfig`
- Adicionada validação da configuração do controlador
- Processa as propriedades: `propName`, `boneName`, `offsetPos`, `offsetRot`

#### Nova função `ScoopTowTruck:SpawnControllerProp()`
Realiza:
- Verificação se o modelo tem configuração de controlador
- Carregamento do modelo do prop
- Criação do objeto na posição do veículo
- Prensagem do prop no bone especificado com os offsets corretos
- Logging de sucesso/erro

```lua
function ScoopTowTruck:SpawnControllerProp()
    -- Valida se tem controlador configurado
    -- Carrega o modelo
    -- Spawna o prop
    -- Prende ao bone correto
    -- Limpa o modelo de memória
end
```

#### Nova função `ScoopTowTruck:DestroyControllerProp()`
Realiza:
- Despreensão do prop do veículo
- Exclusão do prop da memória
- Reset da variável `controllerPropHandle`
- Logging de sucesso

#### Alterações na função `ScoopTowTruck:Destroy()`
- Adicionada chamada para destruir o prop controlador antes de destruir outros elementos

## Fluxo de Funcionamento

### Ativação (Ao entrar no caminhão)
1. Jogador entra no caminhão (e.g., `16ramrb`)
2. `TowTruck.new()` é chamado com a configuração do modelo
3. `ScoopTowTruck.new()` é executado
4. `SpawnControllerProp()` é chamado automaticamente
5. Modelo do prop é carregado (e.g., `m24_2_prop_m42_rc_controller_01a`)
6. Prop é criado e preso ao bone (`attach_male`)
7. Prop fica visível no veículo com posição e rotação corretas

### Desativação (Ao sair do caminhão/desativar script)
1. `currentTowTruck:Destroy()` é chamado
2. `DestroyControllerProp()` é executado
3. Prop é solto do veículo
4. Prop é deletado da memória
5. Variáveis são resetadas

## Configuração de Novos Modelos

Para adicionar um novo modelo com controlador:

```lua
[`novoModelo`] = {
    truckType = "scoop",
    truckModel = `novoModelo`,
    controlBoxOffset = vector3(-1.17, -4.44, -0.02),
    
    -- Adicione isso:
    controler = {
        propName = "nome_do_prop", -- Hash do modelo do controlador
        boneName = "nome_do_bone", -- Bone do veículo para prender
        offsetPos = vector3(x, y, z), -- Posição relativa ao bone
        offsetRot = vector3(rx, ry, rz), -- Rotação em graus
    },
    
    -- ... resto das configurações
}
```

## Notas Técnicas

- O sistema verifica automaticamente se o modelo tem controlador configurado
- Se não houver configuração, o controlador simplesmente não é spawneado
- O prop é preso ao veículo usando `AttachEntityToEntity()`
- Se o modelo falhar ao carregar, um debug log é exibido
- A destruição do prop é automática quando o truck é destruído

## Testando

1. Entre em um dos caminhões configurados (16ramrb ou flatbedm2)
2. Verifique se o prop do controlador aparece na posição e rotação corretas
3. Saia do caminhão
4. O prop deve desaparecer

## Arquivos Modificados

- ✅ [shared/config.lua](shared/config.lua) - Adicionados modelos com configuração
- ✅ [client/classes/scoopBased.lua](client/classes/scoopBased.lua) - Sistema de controlador
