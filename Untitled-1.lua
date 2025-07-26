-- Script GLOBAL pour la transformation des cartes Unit et Place

-- Configuration - AJUSTEZ CES VALEURS SELON VOTRE TABLE
local FIGURINE_SCALE = {1.0, 1.0, 1.0}
local DISCARD_POSITION = {10, 2, 0}
local CARD_BACK_URL = "https://steamusercontent-a.akamaihd.net/ugc/11792848951894476360/26B168D352B1D4016D3E5C58A187294267119B4C/"

function onLoad()
    Turns.enable = true
end

function onObjectDrop(pPlayerColour, pObject)
    if pObject then
        pObject.highlightOn(pPlayerColour)
        pObject.setColorTint(pPlayerColour)
    end
end

function onObjectEnterZone(zone, obj)
    if zone.getName() ~= "Board" then return end
    if obj.getName() == "Unit" then
        replaceObjectByFigurine(obj)
    end
    -- Ajoutez ici la gestion des cartes "Place" si besoin
end

function onObjectLeaveZone(zone, obj)
    if zone.getName() ~= "Board" then return end
    if obj.getName() == "Unit - Figurine" then
        replaceFigurineByCard(obj)
    end
end

function replaceObjectByFigurine(card)
    local img = card.getCustomObject().face
    local figurine = spawnObject({
        type = "Figurine_Custom",
        position = card.getPosition(),
        scale = FIGURINE_SCALE,
        callback_function = function(obj)
            obj.setCustomObject({image = img})
            obj.setName("Unit - Figurine")
            obj.reload()
            card.destroy()
        end
    })
end

function replaceFigurineByCard(figurine)
    local img = figurine.getCustomObject().image
    local playerZoneMap = {
        Red = "Red To Move",
        Blue = "Blue To Move"
    }
    for _, player in ipairs(Player.getPlayers()) do
        local color = player.color
        local zoneName = playerZoneMap[color]
        if zoneName then
            local holding = player.getHoldingObjects()
            if holding[1] and holding[1].getName() == "Unit - Figurine" then
                for _, zone in ipairs(getObjects()) do
                    if zone.getName() == zoneName then
                        spawnObject({
                            type = "CardCustom",
                            position = zone.getPosition(),
                            callback_function = function(obj)
                                obj.setCustomObject({face = img, back = CARD_BACK_URL})
                                obj.setName("Unit")
                                obj.reload()
                                figurine.destroy()
                            end
                        })
                        return
                    end
                end
            end
        end
    end
end
