-- cb_localradio - ox_inventory item snippet
-- Path: resources/[ox]/ox_inventory/data/items.lua
-- Copy cigarette.png from INSTALL_FILES/inventory_icon into ox_inventory image folder.

return {
    ['radio'] = {
        label = 'Radio portátil',
        weight = 800,
        stack = false,
        close = true,
        consume = 0,
        server = { export = 'cb_localradio.useRadio' },
        description = 'Radio portátil para comunicarse dentro de una red de antenas.'
    },
    ['radio_antenna'] = {
        label = 'Kit de antena',
        weight = 3500,
        stack = true,
        close = true,
        consume = 0,
        server = { export = 'cb_localradio.useAntenna' },
        description = 'Kit para construir una antena de radio.'
    },
    ['radio_repair_kit'] = {
        label = 'Kit de reparación de radio',
        weight = 1200,
        stack = true,
        close = true,
        description = 'Herramientas y componentes para reparar una antena rota.'
    },
    ['radio_maintenance_kit'] = {
        label = 'Kit de mantenimiento de antena',
        weight = 900,
        stack = true,
        close = true,
        description = 'Materiales para mantener una antena de radio.'
    },
    ['radio_cable'] = {
        label = 'Cable de radio',
        weight = 100,
        stack = true,
        close = false,
        description = 'Cable utilizado para instalaciones de radio.'
    },
    ['electronic_parts'] = {
        label = 'Componentes electrónicos',
        weight = 150,
        stack = true,
        close = false,
        description = 'Componentes recuperados de equipos electrónicos.'
    },
    ['scrap_metal'] = {
        label = 'Metal de desguace',
        weight = 250,
        stack = true,
        close = false,
        description = 'Metal reutilizable procedente de vehículos y estructuras.'
    },
}

