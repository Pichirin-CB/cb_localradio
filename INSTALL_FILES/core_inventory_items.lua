-- cb_localradio - core_inventory item snippet
-- Register this item in your Core Inventory item source (items.lua / items table / C8RE tools).
-- Required Core Inventory fields: name, label, x, y, category, description.
-- category must exist in Config.ItemCategories from core_inventory.

return {

    radio = {name = 'radio', label = 'Radio portátil', x = 1, y = 2, image = 'radio.png', category = 'misc', type = 'item', unique = false, useable = true, shouldClose = true, combinable = nil, weight = 800, description = 'Radio portátil para comunicarse dentro de una red de antenas.'},
    radio_antenna = {name = 'radio_antenna', label = 'Kit de antena', x = 2, y = 2, image = 'radio_antenna.png', category = 'misc', type = 'item', unique = false, useable = true, shouldClose = true, combinable = nil, weight = 3500, description = 'Kit para construir una antena de radio.'},
    radio_repair_kit = {name = 'radio_repair_kit', label = 'Kit de reparación de radio', x = 2, y = 2, image = 'radio_repair_kit.png', category = 'misc', type = 'item', unique = false, useable = true, shouldClose = true, combinable = nil, weight = 1200, description = 'Herramientas y componentes para reparar una antena rota.'},
    radio_maintenance_kit = {name = 'radio_maintenance_kit', label = 'Kit de mantenimiento de antena', x = 2, y = 2, image = 'radio_maintenance_kit.png', category = 'misc', type = 'item', unique = false, useable = true, shouldClose = true, combinable = nil, weight = 900, description = 'Materiales para mantener una antena de radio.'},
    radio_cable = {name = 'radio_cable', label = 'Cable de radio', x = 1, y = 1, image = 'radio_cable.png', category = 'misc', type = 'item', unique = false, useable = false, shouldClose = false, combinable = nil, weight = 100, description = 'Cable utilizado para instalaciones de radio.'},
    electronic_parts = {name = 'electronic_parts', label = 'Componentes electrónicos', x = 1, y = 1, image = 'electronic_parts.png', category = 'misc', type = 'item', unique = false, useable = false, shouldClose = false, combinable = nil, weight = 150, description = 'Componentes recuperados de equipos electrónicos.'},
    scrap_metal = {name = 'scrap_metal', label = 'Metal de desguace', x = 1, y = 1, image = 'scrap_metal.png', category = 'misc', type = 'item', unique = false, useable = false, shouldClose = false, combinable = nil, weight = 250, description = 'Metal reutilizable procedente de vehículos y estructuras.'},

}