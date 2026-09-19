Config = {}

Config.Debug = false

Config.Items = {
    radio = 'radio',
    antennaKit = 'radio_antenna',
    repairKit = 'radio_repair_kit',
    maintenanceKit = 'radio_maintenance_kit',
    cable = 'radio_cable',
    metal = 'scrap_metal',
    electronics = 'electronic_parts'
}

Config.Antenna = {
    defaultRadius = 1000.0,
    minimumDistance = 500.0,

    degradation = {
        enabled = true,
        intervalMinutes = 60,
        amount = 5.0,
        minimumHealthBeforeMaintenance = 95.0
    },

    playerModel = 'prop_aerial_01a',

    brokenAt = 0.0,
    maintenanceAt = 60.0,
    interactionDistance = 3.0,

    construction = {
        duration = 15000,
        itemReturnOnRemove = true,
        returnPercent = 75,
        animation = {
            dict = 'anim@amb@business@coc@coc_unpack_cut@',
            clip = 'fullcut_cycle_v6_cokecutter'
        }
    },

    repair = {
        duration = 10000,
        health = 35.0,
        animation = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        }
    },

    maintenance = {
        duration = 6000,
        health = 15.0,
        animation = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        }
    }
}

Config.Network = {
    linkDistance = 1200.0,
    allowChaining = true,
    refreshSeconds = 5,
    playerCheckSeconds = 2
}

Config.Radio = {
    enabled = true,
    command = 'localradio',
    key = 'F7',
    minFrequency = 1,
    maxFrequency = 500,
    defaultVolume = 50,
    requireSignal = true,
    leaveWhenOutOfCoverage = true,
    usePhysicalCoverage = true
}

Config.Blips = {
    enabled = true,
    showWorldAntennas = true,
    showPlayerAntennas = true,
    sprite = 459,
    scale = 0.70,

    colors = {
        active = 2,
        maintenance = 17,
        broken = 1,
        offline = 40
    },

    showName = true
}

Config.Radius = {
    enabled = false,
    drawDistance = 2500.0,

    color = {
        active = { r = 80, g = 220, b = 120, a = 35 },
        maintenance = { r = 255, g = 160, b = 40, a = 35 },
        broken = { r = 220, g = 60, b = 60, a = 30 }
    }
}

Config.Target = {
    enabled = true,
    distance = 3.0
}

Config.WorldAntennas = {
    {
        id = 'world_ant_01',
        model = 'sc1_23_antenna',
        coords = vector3(203.69232, -1664.9331, 49.81714),
        heading = 0.0,
        radius = 1100.0
    },
    {
        id = 'world_ant_02',
        model = 'ap1_01_a_aerialb',
        coords = vector3(-1275.6925, -2447.8364, 72.05527),
        heading = -30.0,
        radius = 1100.0
    },
    {
        id = 'world_ant_03',
        model = 'vb_34_baybuild_antenna',
        coords = vector3(-1196.7003, -1789.0812, 22.26281),
        heading = 0.0,
        radius = 900.0
    },
    {
        id = 'world_ant_04',
        model = 'ch2_03_radio_tower_01',
        coords = vector3(758.4658, 1273.7211, 405.94495),
        heading = 0.0,
        radius = 2500.0
    },
    {
        id = 'world_ant_05',
        model = 'cs2_09b_tower01',
        coords = vector3(2971.6052, 3488.215, 81.04724),
        heading = -100.46,
        radius = 1300.0
    },
    {
        id = 'world_ant_06',
        model = 'cs3_07_toweraerials',
        coords = vector3(-2504.1719, 3304.7654, 97.72673),
        heading = 0.0,
        radius = 1300.0
    },
    {
        id = 'world_ant_07',
        model = 'cs4_03_antnn',
        coords = vector3(998.9762, 3581.5034, 51.19351),
        heading = 0.0,
        radius = 1300.0
    },
    {
        id = 'world_ant_08',
        model = 'cs4_10_antenna',
        coords = vector3(1866.7229, 3711.8506, 51.787895),
        heading = 0.0,
        radius = 1300.0
    },
    {
        id = 'world_ant_09',
        model = 'lr_cs6_04_antenna_d',
        coords = vector3(2325.0298, 2951.9822, 105.8528),
        heading = 0.0,
        radius = 1500.0
    },
    {
        id = 'world_ant_10',
        model = 'h4_mph4_wtowers_radiotower',
        coords = vector3(5266.011, -5428.056, 102.6),
        heading = 0.0,
        radius = 2500.0
    },
    {
        id = 'world_mast_01',
        model = 'prop_mobile_mast_1',
        coords = vector3(374.14688, -2622.5208, 4.965317),
        heading = 1.17,
        radius = 900.0
    },
    {
        id = 'world_mast_02',
        model = 'prop_mobile_mast_1',
        coords = vector3(950.34045, -3295.5022, 4.700043),
        heading = -91.40,
        radius = 900.0
    },
    {
        id = 'world_mast_03',
        model = 'prop_mobile_mast_1',
        coords = vector3(-343.3855, -1367.3738, 30.284204),
        heading = 124.50,
        radius = 900.0
    },
    {
        id = 'world_mast_04',
        model = 'prop_mobile_mast_1',
        coords = vector3(197.91278, -1479.185, 28.092821),
        heading = 45.0,
        radius = 900.0
    },
    {
        id = 'world_mast_05',
        model = 'prop_mobile_mast_1',
        coords = vector3(215.47592, -2002.2576, 18.004007),
        heading = 50.0,
        radius = 900.0
    },
    {
        id = 'world_mast_06',
        model = 'prop_mobile_mast_1',
        coords = vector3(-884.8886, -2395.2607, 44.554817),
        heading = -30.0,
        radius = 900.0
    },
    {
        id = 'world_mast_07',
        model = 'prop_mobile_mast_1',
        coords = vector3(2679.652, 4570.3267, 39.583183),
        heading = -44.95,
        radius = 900.0
    },
    {
        id = 'world_mast_08',
        model = 'prop_mobile_mast_1',
        coords = vector3(1397.0498, 2116.6426, 103.88455),
        heading = -49.94,
        radius = 900.0
    }
}

Config.Messages = {
    noRadio = 'No tienes una radio.',
    noSignal = 'No tienes señal de radio.',
    alreadyRadio = 'Ya estas conectado a una frecuencia.',
    joined = 'Conectado a la frecuencia %s.',
    left = 'Has salido de la frecuencia.',
    invalidFrequency = 'Frecuencia no valida.',
    antennaPlaced = 'Antena instalada.',
    antennaRemoved = 'Antena retirada.',
    antennaBroken = 'La antena esta rota.',
    antennaRepaired = 'Antena reparada al %s%%.',
    antennaMaintained = 'Mantenimiento completado. Integridad: %s%%.',
    tooClose = 'No puedes instalar una antena tan cerca de otra.',
    noItems = 'No tienes los materiales necesarios.',
    tooFar = 'Estas demasiado lejos de la antena.',
    constructionCancelled = 'Instalacion cancelada.',
    notOwner = 'No puedes retirar esta antena.',
    outOfCoverage = 'Has salido del alcance de la red de radio.'
}