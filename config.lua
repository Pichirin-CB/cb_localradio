Config = {}

-- ============================================================================
-- CB LOCAL RADIO
-- Configuration File
-- ============================================================================
-- Author      : CB Studios
-- Resource    : cb_localradio
-- Description : Local radio communication system with antenna networks.
-- ============================================================================

-- ============================================================================
-- GENERAL
-- ============================================================================

Config.Debug = false

-- ============================================================================
-- AVAILABLE LANGUAGES: en, es, tr, fr
-- ============================================================================

Config.Locale = 'es'

-- ============================================================================
-- ITEMS
-- ============================================================================

Config.Items = {

    radio = 'radio',

    antennaKit = 'radio_antenna',
    repairKit = 'radio_repair_kit',
    maintenanceKit = 'radio_maintenance_kit',

    cable = 'radio_cable',
    metal = 'scrap_metal',
    electronics = 'electronic_parts'
}

-- ============================================================================
-- ANTENNA SYSTEM
-- ============================================================================

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

    Costs = {

        construction = {
            antennaKit = 1
        },

        repair = {
            repairKit = 1,
            metal = 2,
            electronics = 1
        },

        maintenance = {
            maintenanceKit = 1,
            cable = 1
        }
    },

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

-- ============================================================================
-- RADIO NETWORK
-- ============================================================================

Config.Network = {

    linkDistance = 1200.0,

    allowChaining = true,

    refreshSeconds = 5,

    playerCheckSeconds = 2
}

-- ============================================================================
-- RADIO
-- ============================================================================

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

-- ============================================================================
-- PHYSICAL RADIO ANIMATION
-- ============================================================================

Config.RadioAnimation = {

    enabled = true,

    prop = 'prop_cs_hand_radio',

    openDuration = 650,

    closeDuration = 650,

    idle = {

        dict = 'cellphone@',
        anim = 'cellphone_text_read_base',

        flag = 49,

        bone = 57005,

        offset = vector3(
            0.14,
            0.005,
            -0.02
        ),

        rotation = vector3(
            110.0,
            120.0,
            -15.0
        )
    },

    talking = {

        dict = 'random@arrests',
        anim = 'generic_radio_chatter',

        flag = 49,

        bone = 28422,

        offset = vector3(
            0.0750,
            0.0230,
            -0.0230
        ),

        rotation = vector3(
            -90.0,
            0.0,
            -59.9999
        )
    }
}

-- ============================================================================
-- BLIPS
-- ============================================================================

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

-- ============================================================================
-- COVERAGE VISUALIZATION
-- ============================================================================

Config.Radius = {

    enabled = false,

    drawDistance = 2500.0,

    color = {

        active = {
            r = 80,
            g = 220,
            b = 120,
            a = 35
        },

        maintenance = {
            r = 255,
            g = 160,
            b = 40,
            a = 35
        },

        broken = {
            r = 220,
            g = 60,
            b = 60,
            a = 30
        }
    }
}

-- ============================================================================
-- WORLD ANTENNAS
-- ============================================================================

Config.WorldAntennas = {

    {
        id = 'world_ant_01',
        model = 'sc1_23_antenna',
        coords = vector3(
            203.69232,
            -1664.9331,
            49.81714
        ),
        heading = 0.0,
        radius = 1100.0
    },

    {
        id = 'world_ant_02',
        model = 'ap1_01_a_aerialb',
        coords = vector3(
            -1275.6925,
            -2447.8364,
            72.05527
        ),
        heading = -30.0,
        radius = 1100.0
    },

    {
        id = 'world_ant_03',
        model = 'vb_34_baybuild_antenna',
        coords = vector3(
            -1196.7003,
            -1789.0812,
            22.26281
        ),
        heading = 0.0,
        radius = 900.0
    },

    {
        id = 'world_ant_04',
        model = 'ch2_03_radio_tower_01',
        coords = vector3(
            758.4658,
            1273.7211,
            405.94495
        ),
        heading = 0.0,
        radius = 2500.0
    },

    {
        id = 'world_ant_05',
        model = 'cs2_09b_tower01',
        coords = vector3(
            2971.6052,
            3488.215,
            81.04724
        ),
        heading = -100.46,
        radius = 1300.0
    },

    {
        id = 'world_ant_06',
        model = 'cs3_07_toweraerials',
        coords = vector3(
            -2504.1719,
            3304.7654,
            97.72673
        ),
        heading = 0.0,
        radius = 1300.0
    },

    {
        id = 'world_ant_07',
        model = 'cs4_03_antnn',
        coords = vector3(
            998.9762,
            3581.5034,
            51.19351
        ),
        heading = 0.0,
        radius = 1300.0
    },

    {
        id = 'world_ant_08',
        model = 'cs4_10_antenna',
        coords = vector3(
            1866.7229,
            3711.8506,
            51.787895
        ),
        heading = 0.0,
        radius = 1300.0
    },

    {
        id = 'world_ant_09',
        model = 'lr_cs6_04_antenna_d',
        coords = vector3(
            2325.0298,
            2951.9822,
            105.8528
        ),
        heading = 0.0,
        radius = 1500.0
    },

    {
        id = 'world_ant_10',
        model = 'h4_mph4_wtowers_radiotower',
        coords = vector3(
            5266.011,
            -5428.056,
            102.6
        ),
        heading = 0.0,
        radius = 2500.0
    },

    {
        id = 'world_mast_01',
        model = 'prop_mobile_mast_1',
        coords = vector3(
            374.14688,
            -2622.5208,
            4.965317
        ),
        heading = 1.17,
        radius = 900.0
    },

    {
        id = 'world_mast_02',
        model = 'prop_mobile_mast_1',
        coords = vector3(
            950.34045,
            -3295.5022,
            4.700043
        ),
        heading = -91.40,
        radius = 900.0
    },

    {
        id = 'world_mast_03',
        model = 'prop_mobile_mast_1',
        coords = vector3(
            -343.3855,
            -1367.3738,
            30.284204
        ),
        heading = 124.50,
        radius = 900.0
    },

    {
        id = 'world_mast_04',
        model = 'prop_mobile_mast_1',
        coords = vector3(
            197.91278,
            -1479.185,
            28.092821
        ),
        heading = 45.0,
        radius = 900.0
    },

    {
        id = 'world_mast_05',
        model = 'prop_mobile_mast_1',
        coords = vector3(
            215.47592,
            -2002.2576,
            18.004007
        ),
        heading = 50.0,
        radius = 900.0
    },

    {
        id = 'world_mast_06',
        model = 'prop_mobile_mast_1',
        coords = vector3(
            -884.8886,
            -2395.2607,
            44.554817
        ),
        heading = -30.0,
        radius = 900.0
    },

    {
        id = 'world_mast_07',
        model = 'prop_mobile_mast_1',
        coords = vector3(
            2679.652,
            4570.3267,
            39.583183
        ),
        heading = -44.95,
        radius = 900.0
    },

    {
        id = 'world_mast_08',
        model = 'prop_mobile_mast_1',
        coords = vector3(
            1397.0498,
            2116.6426,
            103.88455
        ),
        heading = -49.94,
        radius = 900.0
    }
}

-- ============================================================================
-- LANGUAGES
-- ============================================================================

Config.Locales = {

    en = {

        brand = 'LOCAL RADIO',
        subtitle = 'SURVIVAL COMMUNICATION UNIT',

        power = 'PWR',
        close = 'CLOSE',

        signal = 'SIGNAL',
        signal_ok = 'SIGNAL OK',
        signal_none = 'NO SIGNAL',

        local_mode = 'LOCAL',
        active_frequency = 'ACTIVE FREQUENCY',
        network = 'NETWORK',

        connected = 'CONNECTED',
        disconnected = 'DISCONNECTED',
        no_coverage = 'NO COVERAGE',

        cb_surv = 'CB-SURV',
        field_radio = 'FIELD RADIO',

        down = 'DOWN',
        up = 'UP',

        frequency = 'FREQUENCY',
        select_channel = 'SELECT CHANNEL',

        audio_control = 'AUDIO CONTROL',
        volume = 'VOLUME',
        min = 'MIN',
        max = 'MAX',

        connect = 'CONNECT',
        join_frequency = 'JOIN FREQUENCY',

        disconnect = 'DISCONNECT',
        leave_network = 'LEAVE NETWORK',

        change_frequency = 'CHANGE FREQUENCY',
        tune = 'TUNE',

        close_radio = 'Close radio',
        decrease_frequency = 'Decrease frequency',
        increase_frequency = 'Increase frequency',
        set_frequency = 'Set frequency',
        volume_label = 'Volume',

        pma_not_started = 'pma-voice is not started.',
        radio_open = 'Open local radio',

        no_radio = 'You do not have a radio.',
        no_radio_signal = 'You do not have a radio signal.',
        already_radio = 'You are already connected to a frequency.',
        joined = 'Connected to frequency %s.',
        left = 'You left the frequency.',
        invalid_frequency = 'Invalid frequency.',

        antenna_placed = 'Antenna installed.',
        antenna_removed = 'Antenna removed.',
        antenna_broken = 'The antenna is broken.',
        antenna_repaired = 'Antenna repaired to %s%%.',
        antenna_maintained = 'Maintenance completed. Integrity: %s%%.',
        antenna_no_maintenance = 'The antenna does not need maintenance yet.',

        too_close = 'You cannot install an antenna so close to another one.',
        no_items = 'You do not have the required materials.',
        too_far = 'You are too far away from the antenna.',
        construction_cancelled = 'Installation cancelled.',
        not_owner = 'You cannot remove this antenna.',
        out_of_coverage = 'You have left the radio network coverage.',

        -- Antenna terminal
        antenna_ui_title = 'ANTENNA SERVICE TERMINAL',
        antenna_ui_subtitle = 'FIELD COMMUNICATIONS INFRASTRUCTURE',

        antenna_health = 'INTEGRITY',
        antenna_state = 'STATUS',
        antenna_type = 'TYPE',
        antenna_network = 'NETWORK',
        antenna_coverage = 'COVERAGE',
        antenna_owner = 'OWNER',

        antenna_materials = 'REQUIRED MATERIALS',

        antenna_repair = 'REPAIR',
        antenna_maintenance = 'MAINTENANCE',
        antenna_remove = 'REMOVE ANTENNA',
        antenna_close = 'CLOSE TERMINAL',

        antenna_active = 'ACTIVE',
        antenna_maintenance_state = 'MAINTENANCE',
        antenna_broken_state = 'BROKEN',

        antenna_world = 'FIXED',
        antenna_player = 'PERSONAL',

        antenna_available = 'AVAILABLE',
        antenna_missing = 'MISSING',
        antenna_not_needed = 'NOT REQUIRED',

        antenna_confirm_remove = 'Remove this antenna?',

        antenna_repair_hint = 'Restore a broken antenna.',
        antenna_maintenance_hint = 'Restore degraded integrity.',
        antenna_remove_hint = 'Recover the installed antenna kit.',

        antenna_network_online = 'NETWORK ONLINE',
        antenna_network_offline = 'NETWORK OFFLINE'
    },

    es = {

        brand = 'RADIO LOCAL',
        subtitle = 'UNIDAD DE COMUNICACIÓN DE SUPERVIVENCIA',

        power = 'PWR',
        close = 'CERRAR',

        signal = 'SEÑAL',
        signal_ok = 'SEÑAL OK',
        signal_none = 'SIN SEÑAL',

        local_mode = 'LOCAL',
        active_frequency = 'FRECUENCIA ACTIVA',
        network = 'RED',

        connected = 'CONECTADA',
        disconnected = 'DESCONECTADA',
        no_coverage = 'SIN COBERTURA',

        cb_surv = 'CB-SURV',
        field_radio = 'RADIO DE CAMPO',

        down = 'BAJAR',
        up = 'SUBIR',

        frequency = 'FRECUENCIA',
        select_channel = 'SELECCIONAR CANAL',

        audio_control = 'CONTROL DE AUDIO',
        volume = 'VOLUMEN',
        min = 'MIN',
        max = 'MAX',

        connect = 'CONECTAR',
        join_frequency = 'UNIRSE A FRECUENCIA',

        disconnect = 'DESCONECTAR',
        leave_network = 'SALIR DE LA RED',

        change_frequency = 'CAMBIAR FRECUENCIA',
        tune = 'SINTONIZAR',

        close_radio = 'Cerrar radio',
        decrease_frequency = 'Disminuir frecuencia',
        increase_frequency = 'Aumentar frecuencia',
        set_frequency = 'Establecer frecuencia',
        volume_label = 'Volumen',

        pma_not_started = 'pma-voice no está iniciado.',
        radio_open = 'Abrir radio local',

        no_radio = 'No tienes una radio.',
        no_radio_signal = 'No tienes señal de radio.',
        already_radio = 'Ya estás conectado a una frecuencia.',
        joined = 'Conectado a la frecuencia %s.',
        left = 'Has salido de la frecuencia.',
        invalid_frequency = 'Frecuencia no válida.',

        antenna_placed = 'Antena instalada.',
        antenna_removed = 'Antena retirada.',
        antenna_broken = 'La antena está rota.',
        antenna_repaired = 'Antena reparada al %s%%.',
        antenna_maintained = 'Mantenimiento completado. Integridad: %s%%.',
        antenna_no_maintenance = 'La antena no necesita mantenimiento todavía.',

        too_close = 'No puedes instalar una antena tan cerca de otra.',
        no_items = 'No tienes los materiales necesarios.',
        too_far = 'Estás demasiado lejos de la antena.',
        construction_cancelled = 'Instalación cancelada.',
        not_owner = 'No puedes retirar esta antena.',
        out_of_coverage = 'Has salido del alcance de la red de radio.',

        -- Terminal de antena
        antenna_ui_title = 'TERMINAL DE SERVICIO DE ANTENA',
        antenna_ui_subtitle = 'INFRAESTRUCTURA DE COMUNICACIONES DE CAMPO',

        antenna_health = 'INTEGRIDAD',
        antenna_state = 'ESTADO',
        antenna_type = 'TIPO',
        antenna_network = 'RED',
        antenna_coverage = 'COBERTURA',
        antenna_owner = 'PROPIETARIO',

        antenna_materials = 'MATERIALES NECESARIOS',

        antenna_repair = 'REPARAR',
        antenna_maintenance = 'MANTENIMIENTO',
        antenna_remove = 'RETIRAR ANTENA',
        antenna_close = 'CERRAR TERMINAL',

        antenna_active = 'ACTIVA',
        antenna_maintenance_state = 'MANTENIMIENTO',
        antenna_broken_state = 'ROTA',

        antenna_world = 'FIJA',
        antenna_player = 'PROPIA',

        antenna_available = 'DISPONIBLE',
        antenna_missing = 'FALTA',
        antenna_not_needed = 'NO NECESARIO',

        antenna_confirm_remove = '¿Retirar esta antena?',

        antenna_repair_hint = 'Restaurar una antena rota.',
        antenna_maintenance_hint = 'Restaurar la integridad degradada.',
        antenna_remove_hint = 'Recuperar el kit de antena instalado.',

        antenna_network_online = 'RED ACTIVA',
        antenna_network_offline = 'RED INACTIVA'
    },

    tr = {

        brand = 'YEREL RADYO',
        subtitle = 'HAYATTA KALMA HABERLEŞME ÜNİTESİ',

        power = 'GÜÇ',
        close = 'KAPAT',

        signal = 'SİNYAL',
        signal_ok = 'SİNYAL TAMAM',
        signal_none = 'SİNYAL YOK',

        local_mode = 'YEREL',
        active_frequency = 'AKTİF FREKANS',
        network = 'AĞ',

        connected = 'BAĞLI',
        disconnected = 'BAĞLANTI YOK',
        no_coverage = 'KAPSAMA YOK',

        cb_surv = 'CB-SURV',
        field_radio = 'SAHA TELSİZİ',

        down = 'AZALT',
        up = 'ARTIR',

        frequency = 'FREKANS',
        select_channel = 'KANAL SEÇ',

        audio_control = 'SES KONTROLÜ',
        volume = 'SES',
        min = 'MİN',
        max = 'MAKS',

        connect = 'BAĞLAN',
        join_frequency = 'FREKANSA KATIL',

        disconnect = 'AYRIL',
        leave_network = 'AĞDAN AYRIL',

        change_frequency = 'FREKANSI DEĞİŞTİR',
        tune = 'AYARLA',

        close_radio = 'Telsizi kapat',
        decrease_frequency = 'Frekansı azalt',
        increase_frequency = 'Frekansı artır',
        set_frequency = 'Frekansı ayarla',
        volume_label = 'Ses',

        pma_not_started = 'pma-voice başlatılmadı.',
        radio_open = 'Yerel telsizi aç',

        no_radio = 'Telsizin yok.',
        no_radio_signal = 'Telsiz sinyalin yok.',
        already_radio = 'Zaten bir frekansa bağlısın.',
        joined = '%s frekansına bağlandın.',
        left = 'Frekans bağlantısından ayrıldın.',
        invalid_frequency = 'Geçersiz frekans.',

        antenna_placed = 'Anten kuruldu.',
        antenna_removed = 'Anten kaldırıldı.',
        antenna_broken = 'Anten bozuk.',
        antenna_repaired = 'Anten %s%% seviyesine onarıldı.',
        antenna_maintained = 'Bakım tamamlandı. Bütünlük: %s%%.',
        antenna_no_maintenance = 'Antenin henüz bakıma ihtiyacı yok.',

        too_close = 'Başka bir antene bu kadar yakın anten kuramazsın.',
        no_items = 'Gerekli malzemelere sahip değilsin.',
        too_far = 'Antenden çok uzaktasın.',
        construction_cancelled = 'Kurulum iptal edildi.',
        not_owner = 'Bu anteni kaldıramazsın.',
        out_of_coverage = 'Telsiz ağının kapsama alanından çıktın.',

        -- Anten terminali
        antenna_ui_title = 'ANTEN SERVİS TERMİNALİ',
        antenna_ui_subtitle = 'SAHA HABERLEŞME ALTYAPISI',

        antenna_health = 'BÜTÜNLÜK',
        antenna_state = 'DURUM',
        antenna_type = 'TİP',
        antenna_network = 'AĞ',
        antenna_coverage = 'KAPSAMA',
        antenna_owner = 'SAHİP',

        antenna_materials = 'GEREKLİ MALZEMELER',

        antenna_repair = 'ONAR',
        antenna_maintenance = 'BAKIM',
        antenna_remove = 'ANTENİ KALDIR',
        antenna_close = 'TERMİNALİ KAPAT',

        antenna_active = 'AKTİF',
        antenna_maintenance_state = 'BAKIM',
        antenna_broken_state = 'BOZUK',

        antenna_world = 'SABİT',
        antenna_player = 'KİŞİSEL',

        antenna_available = 'MEVCUT',
        antenna_missing = 'EKSİK',
        antenna_not_needed = 'GEREKLİ DEĞİL',

        antenna_confirm_remove = 'Bu anten kaldırılsın mı?',

        antenna_repair_hint = 'Bozuk anteni onar.',
        antenna_maintenance_hint = 'Azalmış bütünlüğü geri yükle.',
        antenna_remove_hint = 'Kurulu anten kitini geri al.',

        antenna_network_online = 'AĞ AKTİF',
        antenna_network_offline = 'AĞ KAPALI'
    },

    fr = {

        brand = 'RADIO LOCALE',
        subtitle = 'UNITÉ DE COMMUNICATION DE SURVIE',

        power = 'PWR',
        close = 'FERMER',

        signal = 'SIGNAL',
        signal_ok = 'SIGNAL OK',
        signal_none = 'AUCUN SIGNAL',

        local_mode = 'LOCAL',
        active_frequency = 'FRÉQUENCE ACTIVE',
        network = 'RÉSEAU',

        connected = 'CONNECTÉ',
        disconnected = 'DÉCONNECTÉ',
        no_coverage = 'AUCUNE COUVERTURE',

        cb_surv = 'CB-SURV',
        field_radio = 'RADIO DE TERRAIN',

        down = 'BAS',
        up = 'HAUT',

        frequency = 'FRÉQUENCE',
        select_channel = 'SÉLECTIONNER LE CANAL',

        audio_control = 'CONTRÔLE AUDIO',
        volume = 'VOLUME',
        min = 'MIN',
        max = 'MAX',

        connect = 'CONNECTER',
        join_frequency = 'REJOINDRE LA FRÉQUENCE',

        disconnect = 'DÉCONNECTER',
        leave_network = 'QUITTER LE RÉSEAU',

        change_frequency = 'CHANGER DE FRÉQUENCE',
        tune = 'RÉGLER',

        close_radio = 'Fermer la radio',
        decrease_frequency = 'Diminuer la fréquence',
        increase_frequency = 'Augmenter la fréquence',
        set_frequency = 'Définir la fréquence',
        volume_label = 'Volume',

        pma_not_started = 'pma-voice n’est pas démarré.',
        radio_open = 'Ouvrir la radio locale',

        no_radio = 'Vous n’avez pas de radio.',
        no_radio_signal = 'Vous n’avez pas de signal radio.',
        already_radio = 'Vous êtes déjà connecté à une fréquence.',
        joined = 'Connecté à la fréquence %s.',
        left = 'Vous avez quitté la fréquence.',
        invalid_frequency = 'Fréquence invalide.',

        antenna_placed = 'Antenne installée.',
        antenna_removed = 'Antenne retirée.',
        antenna_broken = 'L’antenne est cassée.',
        antenna_repaired = 'Antenne réparée à %s%%.',
        antenna_maintained = 'Maintenance terminée. Intégrité : %s%%.',
        antenna_no_maintenance = 'L’antenne ne nécessite pas encore de maintenance.',

        too_close = 'Vous ne pouvez pas installer une antenne aussi près d’une autre.',
        no_items = 'Vous ne possédez pas les matériaux nécessaires.',
        too_far = 'Vous êtes trop loin de l’antenne.',
        construction_cancelled = 'Installation annulée.',
        not_owner = 'Vous ne pouvez pas retirer cette antenne.',
        out_of_coverage = 'Vous avez quitté la couverture du réseau radio.',

        -- Terminal d'antenne
        antenna_ui_title = 'TERMINAL DE SERVICE ANTENNE',
        antenna_ui_subtitle = 'INFRASTRUCTURE DE COMMUNICATION DE TERRAIN',

        antenna_health = 'INTÉGRITÉ',
        antenna_state = 'ÉTAT',
        antenna_type = 'TYPE',
        antenna_network = 'RÉSEAU',
        antenna_coverage = 'COUVERTURE',
        antenna_owner = 'PROPRIÉTAIRE',

        antenna_materials = 'MATÉRIAUX REQUIS',

        antenna_repair = 'RÉPARER',
        antenna_maintenance = 'MAINTENANCE',
        antenna_remove = 'RETIRER L’ANTENNE',
        antenna_close = 'FERMER LE TERMINAL',

        antenna_active = 'ACTIVE',
        antenna_maintenance_state = 'MAINTENANCE',
        antenna_broken_state = 'CASSÉE',

        antenna_world = 'FIXE',
        antenna_player = 'PERSONNELLE',

        antenna_available = 'DISPONIBLE',
        antenna_missing = 'MANQUANT',
        antenna_not_needed = 'NON REQUIS',

        antenna_confirm_remove = 'Retirer cette antenne ?',

        antenna_repair_hint = 'Restaurer une antenne cassée.',
        antenna_maintenance_hint = 'Restaurer l’intégrité dégradée.',
        antenna_remove_hint = 'Récupérer le kit d’antenne installé.',

        antenna_network_online = 'RÉSEAU ACTIF',
        antenna_network_offline = 'RÉSEAU INACTIF'
    }
}

-- ============================================================================
-- LEGACY MESSAGE COMPATIBILITY
-- ============================================================================

local SelectedLocale =
    Config.Locales[Config.Locale]

if not SelectedLocale then
    SelectedLocale =
        Config.Locales.en
end

Config.Messages = {

    noRadio =
        SelectedLocale.no_radio,

    noSignal =
        SelectedLocale.no_radio_signal,

    alreadyRadio =
        SelectedLocale.already_radio,

    joined =
        SelectedLocale.joined,

    left =
        SelectedLocale.left,

    invalidFrequency =
        SelectedLocale.invalid_frequency,

    antennaPlaced =
        SelectedLocale.antenna_placed,

    antennaRemoved =
        SelectedLocale.antenna_removed,

    antennaBroken =
        SelectedLocale.antenna_broken,

    antennaRepaired =
        SelectedLocale.antenna_repaired,

    antennaMaintained =
        SelectedLocale.antenna_maintained,

    tooClose =
        SelectedLocale.too_close,

    noItems =
        SelectedLocale.no_items,

    tooFar =
        SelectedLocale.too_far,

    constructionCancelled =
        SelectedLocale.construction_cancelled,

    notOwner =
        SelectedLocale.not_owner,

    outOfCoverage =
        SelectedLocale.out_of_coverage,

    antennaNoMaintenance =
        SelectedLocale.antenna_no_maintenance
}