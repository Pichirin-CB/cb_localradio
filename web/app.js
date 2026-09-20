const resource = typeof GetParentResourceName === 'function'
    ? GetParentResourceName()
    : 'cb_localradio';

const radio = document.getElementById('radio');
const device = document.querySelector('.device');
const dragHandle = document.querySelector('.top');

const frequency = document.getElementById('frequency');
const volume = document.getElementById('volume');
const volumeValue = document.getElementById('volumeValue');
const signalText = document.getElementById('signalText');
const networkState = document.getElementById('networkState');
const led = document.getElementById('led');

let currentFrequency = 0;
let maxFrequency = 500;

let currentSignal = false;
let currentConnected = false;

let locale = 'en';
let translations = {};

const POSITION_KEY = 'cb_localradio_position';

const DEFAULT_POSITION = {
    x: 50,
    y: 50
};

let position = {
    x: DEFAULT_POSITION.x,
    y: DEFAULT_POSITION.y
};

let dragging = false;
let dragPointerId = null;
let dragOffsetX = 0;
let dragOffsetY = 0;

/* ============================================================
   ANTENNA TERMINAL
============================================================ */

const antennaWindow = document.querySelector(
    '.antenna-terminal'
);

const antennaDragHandle = document.querySelector(
    '.antenna-header'
);

const ANTENNA_POSITION_KEY =
    'cb_localradio_antenna_position';

const DEFAULT_ANTENNA_POSITION = {
    centered: true
};

const antennaPosition = {
    x: null,
    y: null
};

let antennaDragging = false;
let antennaDragPointerId = null;
let antennaDragOffsetX = 0;
let antennaDragOffsetY = 0;

let antennaTerminalOpen = false;
let currentAntenna = null;
let currentAntennaId = null;
let antennaBusy = false;

/* ============================================================
   NUI
============================================================ */

function post(event, data = {}) {
    return fetch(
        `https://${resource}/${event}`,
        {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }
    );
}

/* ============================================================
   TRANSLATIONS
============================================================ */

/*
 * The HTML uses descriptive keys while the Lua locale uses
 * shorter internal keys. These aliases keep the UI compatible
 * with both without hardcoding a language into the interface.
 */
const TRANSLATION_ALIASES = {
    antenna_terminal_title: 'antenna_ui_title',
    antenna_terminal_subtitle: 'antenna_ui_subtitle',

    antenna_status: 'antenna_state',
    antenna_integrity: 'antenna_health',

    antenna_type_world: 'antenna_world',
    antenna_type_player: 'antenna_player',

    antenna_state_active: 'antenna_active',
    antenna_state_maintenance: 'antenna_maintenance_state',
    antenna_state_broken: 'antenna_broken_state',
    antenna_state_offline: 'antenna_network_offline',

    antenna_resources: 'antenna_materials',

    antenna_repair_description:
        'antenna_repair_hint',

    antenna_maintenance_description:
        'antenna_maintenance_hint',

    antenna_remove_description:
        'antenna_remove_hint',

    antenna_close_terminal:
        'antenna_close',

    close_antenna:
        'antenna_close'
};

/*
 * Dynamic UI strings which are not directly represented by a
 * data-i18n element can still use these fallback translations.
 *
 * Config.Locales always has priority.
 */
const TRANSLATION_DEFAULTS = {
    antenna_id: {
        es: 'ID DE ANTENA',
        en: 'ANTENNA ID',
        tr: 'ANTEN KİMLİĞİ',
        fr: 'ID ANTENNE',
        pt: 'ID DA ANTENA'
    },

    antenna_radius: {
        es: 'RADIO DE COBERTURA',
        en: 'COVERAGE RADIUS',
        tr: 'KAPSAMA ALANI',
        fr: 'RAYON DE COUVERTURE',
        pt: 'RAIO DE COBERTURA'
    },

    antenna_signal: {
        es: 'SEÑAL DE RED',
        en: 'NETWORK SIGNAL',
        tr: 'AĞ SİNYALİ',
        fr: 'SIGNAL RÉSEAU',
        pt: 'SINAL DA REDE'
    },

    antenna_players: {
        es: 'UNIDADES CONECTADAS',
        en: 'CONNECTED UNITS',
        tr: 'BAĞLI BİRİMLER',
        fr: 'UNITÉS CONNECTÉES',
        pt: 'UNIDADES CONECTADAS'
    },

    antenna_distance: {
        es: 'DISTANCIA',
        en: 'DISTANCE',
        tr: 'MESAFE',
        fr: 'DISTANCE',
        pt: 'DISTÂNCIA'
    },

    antenna_metal: {
        es: 'CHATARRA',
        en: 'SCRAP METAL',
        tr: 'HURDA METAL',
        fr: 'MÉTAL DE RÉCUPÉRATION',
        pt: 'SUCATA'
    },

    antenna_electronics: {
        es: 'COMPONENTES ELECTRÓNICOS',
        en: 'ELECTRONIC PARTS',
        tr: 'ELEKTRONİK PARÇALAR',
        fr: 'COMPOSANTS ÉLECTRONIQUES',
        pt: 'COMPONENTES ELETRÔNICOS'
    },

    antenna_cable: {
        es: 'CABLE',
        en: 'CABLE',
        tr: 'KABLO',
        fr: 'CÂBLE',
        pt: 'CABO'
    },

    antenna_repair_kit: {
        es: 'KIT DE REPARACIÓN',
        en: 'REPAIR KIT',
        tr: 'TAMİR KİTİ',
        fr: 'KIT DE RÉPARATION',
        pt: 'KIT DE REPARO'
    },

    antenna_maintenance_kit: {
        es: 'KIT DE MANTENIMIENTO',
        en: 'MAINTENANCE KIT',
        tr: 'BAKIM KİTİ',
        fr: 'KIT DE MAINTENANCE',
        pt: 'KIT DE MANUTENÇÃO'
    },

    antenna_processing: {
        es: 'PROCESANDO',
        en: 'PROCESSING',
        tr: 'İŞLENİYOR',
        fr: 'TRAITEMENT',
        pt: 'PROCESSANDO'
    },

    antenna_please_wait: {
        es: 'ESPERA MIENTRAS SE COMPLETA LA OPERACIÓN',
        en: 'PLEASE WAIT FOR THE OPERATION TO COMPLETE',
        tr: 'İŞLEM TAMAMLANANA KADAR BEKLEYİN',
        fr: 'VEUILLEZ ATTENDRE LA FIN DE L’OPÉRATION',
        pt: 'AGUARDE ENQUANTO A OPERAÇÃO É CONCLUÍDA'
    },

    antenna_operation_complete: {
        es: 'OPERACIÓN COMPLETADA',
        en: 'OPERATION COMPLETE',
        tr: 'İŞLEM TAMAMLANDI',
        fr: 'OPÉRATION TERMINÉE',
        pt: 'OPERAÇÃO CONCLUÍDA'
    },

    antenna_system: {
        es: 'SISTEMA',
        en: 'SYSTEM',
        tr: 'SİSTEM',
        fr: 'SYSTÈME',
        pt: 'SISTEMA'
    },

    antenna_no_materials: {
        es: 'SIN MATERIALES',
        en: 'NO MATERIALS',
        tr: 'MALZEME YOK',
        fr: 'AUCUN MATÉRIAU',
        pt: 'SEM MATERIAIS'
    },

    antenna_no_cost: {
        es: 'NO REQUERIDO',
        en: 'NOT REQUIRED',
        tr: 'GEREKLİ DEĞİL',
        fr: 'NON REQUIS',
        pt: 'NÃO NECESSÁRIO'
    },

    antenna_label: {
        es: 'ANTENA',
        en: 'ANTENNA',
        tr: 'ANTEN',
        fr: 'ANTENNE',
        pt: 'ANTENA'
    },

    antenna_interact: {
        es: '[E] INTERACTUAR',
        en: '[E] INTERACT',
        tr: '[E] ETKİLEŞİM',
        fr: '[E] INTERAGIR',
        pt: '[E] INTERAGIR'
    },

    antenna_repair_progress: {
        es: 'Reparando antena...',
        en: 'Repairing antenna...',
        tr: 'Anten onarılıyor...',
        fr: 'Réparation de l’antenne...',
        pt: 'Reparando antena...'
    },

    antenna_maintenance_progress: {
        es: 'Realizando mantenimiento...',
        en: 'Performing maintenance...',
        tr: 'Bakım yapılıyor...',
        fr: 'Maintenance en cours...',
        pt: 'Realizando manutenção...'
    }
};

function translate(key) {
    if (!key) {
        return '';
    }

    /*
     * First priority:
     * exact key received from Config.Locales.
     */
    if (
        translations &&
        Object.prototype.hasOwnProperty.call(
            translations,
            key
        )
    ) {
        const value = translations[key];

        if (
            value !== undefined &&
            value !== null &&
            value !== ''
        ) {
            return String(value);
        }
    }

    /*
     * Second priority:
     * compatibility alias.
     */
    const aliasKey =
        TRANSLATION_ALIASES[key];

    if (
        aliasKey &&
        translations &&
        Object.prototype.hasOwnProperty.call(
            translations,
            aliasKey
        )
    ) {
        const value =
            translations[aliasKey];

        if (
            value !== undefined &&
            value !== null &&
            value !== ''
        ) {
            return String(value);
        }
    }

    /*
     * Third priority:
     * internal fallback.
     */
    const defaults =
        TRANSLATION_DEFAULTS[key];

    if (defaults) {
        return (
            defaults[locale] ||
            defaults.en ||
            key
        );
    }

    return key;
}

function translateMaterial(item) {
    if (!item) {
        return translate(
            'antenna_no_materials'
        );
    }

    const key =
        String(item).trim();

    /*
     * Direct locale key.
     *
     * This allows config.lua to define:
     * radio_cable
     * scrap_metal
     * electronic_parts
     * etc.
     */
    if (
        translations &&
        Object.prototype.hasOwnProperty.call(
            translations,
            key
        )
    ) {
        return String(
            translations[key]
        );
    }

    /*
     * Known inventory item IDs.
     */
    const itemKeys = {
        radio: 'antenna_radio',
        radio_antenna: 'antenna_radio',
        radio_repair_kit: 'antenna_repair_kit',
        radio_maintenance_kit:
            'antenna_maintenance_kit',
        radio_cable: 'antenna_cable',
        scrap_metal: 'antenna_metal',
        electronic_parts:
            'antenna_electronics'
    };

    const translationKey =
        itemKeys[key];

    if (translationKey) {
        return translate(
            translationKey
        );
    }

    return key;
}

/* ============================================================
   LOCALE
============================================================ */

function applyLocale(data = {}) {
    if (
        typeof data.locale === 'string' &&
        data.locale.length > 0
    ) {
        locale = data.locale;
    }

    if (
        data.translations &&
        typeof data.translations === 'object'
    ) {
        translations =
            data.translations;
    }

    document.documentElement.lang =
        locale;

    document
        .querySelectorAll('[data-i18n]')
        .forEach(element => {
            const key =
                element.dataset.i18n;

            element.textContent =
                translate(key);
        });

    document
        .querySelectorAll('[data-i18n-aria]')
        .forEach(element => {
            const key =
                element.dataset.i18nAria;

            element.setAttribute(
                'aria-label',
                translate(key)
            );
        });
}

/* ============================================================
   RADIO
============================================================ */

function renderSignal(signal) {
    currentSignal =
        Boolean(signal);

    if (!led || !signalText) {
        return;
    }

    if (currentSignal) {
        led.classList.add('ok');

        signalText.textContent =
            translate('signal_ok');
    } else {
        led.classList.remove('ok');

        signalText.textContent =
            translate('signal_none');
    }
}

function renderConnection(
    connected
) {
    currentConnected =
        Boolean(connected);

    if (!networkState) {
        return;
    }

    if (currentConnected) {
        networkState.textContent =
            translate('connected');

        networkState.classList.add(
            'connected'
        );
    } else {
        networkState.textContent =
            translate('disconnected');

        networkState.classList.remove(
            'connected'
        );
    }
}

function renderFrequency(value) {
    currentFrequency =
        Number(value) || 0;

    if (!frequency) {
        return;
    }

    frequency.textContent =
        currentFrequency
            ? currentFrequency.toFixed(1)
            : '000.0';
}

function renderVolume(value) {
    const numeric =
        Math.max(
            0,
            Math.min(
                100,
                Number(value) || 0
            )
        );

    if (volume) {
        volume.value =
            numeric;
    }

    if (volumeValue) {
        volumeValue.textContent =
            `${numeric}%`;
    }
}

function changeFrequency(delta) {
    let value =
        currentFrequency || 1;

    value += delta;

    if (value < 1) {
        value =
            maxFrequency;
    }

    if (value > maxFrequency) {
        value = 1;
    }

    renderFrequency(value);
}

/* ============================================================
   RADIO POSITION
============================================================ */

function loadPosition() {
    try {
        const saved =
            localStorage.getItem(
                POSITION_KEY
            );

        if (!saved) {
            return;
        }

        const parsed =
            JSON.parse(saved);

        if (
            typeof parsed.x === 'number' &&
            typeof parsed.y === 'number'
        ) {
            position.x =
                Math.max(
                    0,
                    Math.min(
                        100,
                        parsed.x
                    )
                );

            position.y =
                Math.max(
                    0,
                    Math.min(
                        100,
                        parsed.y
                    )
                );
        }
    } catch (error) {
        position.x =
            DEFAULT_POSITION.x;

        position.y =
            DEFAULT_POSITION.y;
    }
}

function savePosition() {
    try {
        localStorage.setItem(
            POSITION_KEY,
            JSON.stringify(position)
        );
    } catch (error) {
        // Ignorar errores de almacenamiento.
    }
}

function clampPosition(x, y) {
    if (!device) {
        return {
            x,
            y
        };
    }

    const width =
        device.offsetWidth;

    const height =
        device.offsetHeight;

    const viewportWidth =
        window.innerWidth;

    const viewportHeight =
        window.innerHeight;

    const margin = 10;

    const minX = margin;
    const minY = margin;

    const maxX =
        Math.max(
            minX,
            viewportWidth -
                width -
                margin
        );

    const maxY =
        Math.max(
            minY,
            viewportHeight -
                height -
                margin
        );

    return {
        x: Math.max(
            minX,
            Math.min(
                maxX,
                x
            )
        ),

        y: Math.max(
            minY,
            Math.min(
                maxY,
                y
            )
        )
    };
}

function positionToPixels() {
    return {
        x:
            window.innerWidth *
            (position.x / 100),

        y:
            window.innerHeight *
            (position.y / 100)
    };
}

function applyPosition() {
    if (!device) {
        return;
    }

    const pixels =
        positionToPixels();

    const clamped =
        clampPosition(
            pixels.x,
            pixels.y
        );

    position.x =
        (clamped.x /
            window.innerWidth) *
        100;

    position.y =
        (clamped.y /
            window.innerHeight) *
        100;

    device.style.left =
        `${clamped.x}px`;

    device.style.top =
        `${clamped.y}px`;

    device.style.transform =
        'none';
}

function centerPosition() {
    if (!device) {
        return;
    }

    const width =
        device.offsetWidth;

    const height =
        device.offsetHeight;

    const x =
        Math.max(
            10,
            (window.innerWidth -
                width) / 2
        );

    const y =
        Math.max(
            10,
            (window.innerHeight -
                height) / 2
        );

    position.x =
        (x /
            window.innerWidth) *
        100;

    position.y =
        (y /
            window.innerHeight) *
        100;

    applyPosition();
    savePosition();
}

function startDrag(event) {
    if (
        !device ||
        !dragHandle
    ) {
        return;
    }

    if (
        event.button !== undefined &&
        event.button !== 0
    ) {
        return;
    }

    if (
        event.target.closest(
            'button, input, a'
        )
    ) {
        return;
    }

    dragging = true;

    dragPointerId =
        event.pointerId;

    const rect =
        device.getBoundingClientRect();

    dragOffsetX =
        event.clientX -
        rect.left;

    dragOffsetY =
        event.clientY -
        rect.top;

    device.classList.add(
        'dragging'
    );

    dragHandle.classList.add(
        'dragging'
    );

    dragHandle.setPointerCapture(
        event.pointerId
    );

    event.preventDefault();
}

function moveDrag(event) {
    if (
        !dragging ||
        event.pointerId !==
            dragPointerId ||
        !device
    ) {
        return;
    }

    const next =
        clampPosition(
            event.clientX -
                dragOffsetX,
            event.clientY -
                dragOffsetY
        );

    position.x =
        (next.x /
            window.innerWidth) *
        100;

    position.y =
        (next.y /
            window.innerHeight) *
        100;

    device.style.left =
        `${next.x}px`;

    device.style.top =
        `${next.y}px`;

    device.style.transform =
        'none';

    event.preventDefault();
}

function stopDrag(event) {
    if (
        !dragging ||
        (
            event.pointerId !== undefined &&
            event.pointerId !==
                dragPointerId
        )
    ) {
        return;
    }

    dragging = false;

    if (device) {
        device.classList.remove(
            'dragging'
        );
    }

    if (dragHandle) {
        dragHandle.classList.remove(
            'dragging'
        );
    }

    try {
        if (
            dragHandle &&
            dragHandle.hasPointerCapture(
                dragPointerId
            )
        ) {
            dragHandle.releasePointerCapture(
                dragPointerId
            );
        }
    } catch (error) {
        // Ignorar errores de pointer capture.
    }

    dragPointerId = null;

    savePosition();
}

/* ============================================================
   ANTENNA WINDOW POSITION
============================================================ */

function loadAntennaPosition() {
    try {
        const saved =
            localStorage.getItem(
                ANTENNA_POSITION_KEY
            );

        if (!saved) {
            return;
        }

        const parsed =
            JSON.parse(saved);

        if (
            typeof parsed.x === 'number' &&
            typeof parsed.y === 'number'
        ) {
            antennaPosition.x =
                parsed.x;

            antennaPosition.y =
                parsed.y;
        }
    } catch (error) {
        antennaPosition.x = null;
        antennaPosition.y = null;
    }
}

function saveAntennaPosition() {
    if (
        typeof antennaPosition.x !==
            'number' ||
        typeof antennaPosition.y !==
            'number'
    ) {
        return;
    }

    try {
        localStorage.setItem(
            ANTENNA_POSITION_KEY,
            JSON.stringify({
                x:
                    antennaPosition.x,

                y:
                    antennaPosition.y
            })
        );
    } catch (error) {
        // Ignorar errores de almacenamiento.
    }
}

function clampAntennaPosition(
    x,
    y
) {
    if (!antennaWindow) {
        return {
            x,
            y
        };
    }

    const margin = 10;

    const width =
        antennaWindow.offsetWidth;

    const height =
        antennaWindow.offsetHeight;

    const maxX =
        Math.max(
            margin,
            window.innerWidth -
                width -
                margin
        );

    const maxY =
        Math.max(
            margin,
            window.innerHeight -
                height -
                margin
        );

    return {
        x: Math.max(
            margin,
            Math.min(
                maxX,
                x
            )
        ),

        y: Math.max(
            margin,
            Math.min(
                maxY,
                y
            )
        )
    };
}

function applyAntennaPosition() {
    if (!antennaWindow) {
        return;
    }

    if (
        typeof antennaPosition.x !==
            'number' ||
        typeof antennaPosition.y !==
            'number'
    ) {
        antennaWindow.style.left =
            '50%';

        antennaWindow.style.top =
            '50%';

        antennaWindow.style.transform =
            'translate(-50%, -50%)';

        return;
    }

    const position =
        clampAntennaPosition(
            antennaPosition.x,
            antennaPosition.y
        );

    antennaPosition.x =
        position.x;

    antennaPosition.y =
        position.y;

    antennaWindow.style.left =
        `${position.x}px`;

    antennaWindow.style.top =
        `${position.y}px`;

    antennaWindow.style.transform =
        'none';
}

function centerAntennaPosition() {
    if (!antennaWindow) {
        return;
    }

    const x =
        Math.max(
            10,
            (
                window.innerWidth -
                antennaWindow.offsetWidth
            ) / 2
        );

    const y =
        Math.max(
            10,
            (
                window.innerHeight -
                antennaWindow.offsetHeight
            ) / 2
        );

    antennaPosition.x =
        x;

    antennaPosition.y =
        y;

    applyAntennaPosition();
    saveAntennaPosition();
}

function startAntennaDrag(
    event
) {
    if (
        !antennaWindow ||
        !antennaDragHandle
    ) {
        return;
    }

    if (
        event.button !== undefined &&
        event.button !== 0
    ) {
        return;
    }

    if (
        event.target.closest(
            'button, input, a'
        )
    ) {
        return;
    }

    const rect =
        antennaWindow.getBoundingClientRect();

    antennaDragging = true;

    antennaDragPointerId =
        event.pointerId;

    antennaDragOffsetX =
        event.clientX -
        rect.left;

    antennaDragOffsetY =
        event.clientY -
        rect.top;

    antennaWindow.classList.add(
        'dragging'
    );

    antennaDragHandle.classList.add(
        'dragging'
    );

    antennaDragHandle.setPointerCapture(
        event.pointerId
    );

    event.preventDefault();
}

function moveAntennaDrag(
    event
) {
    if (
        !antennaDragging ||
        event.pointerId !==
            antennaDragPointerId ||
        !antennaWindow
    ) {
        return;
    }

    const position =
        clampAntennaPosition(
            event.clientX -
                antennaDragOffsetX,

            event.clientY -
                antennaDragOffsetY
        );

    antennaPosition.x =
        position.x;

    antennaPosition.y =
        position.y;

    antennaWindow.style.left =
        `${position.x}px`;

    antennaWindow.style.top =
        `${position.y}px`;

    antennaWindow.style.transform =
        'none';

    event.preventDefault();
}

function stopAntennaDrag(
    event
) {
    if (
        !antennaDragging ||
        (
            event.pointerId !== undefined &&
            event.pointerId !==
                antennaDragPointerId
        )
    ) {
        return;
    }

    antennaDragging = false;

    if (antennaWindow) {
        antennaWindow.classList.remove(
            'dragging'
        );
    }

    if (antennaDragHandle) {
        antennaDragHandle.classList.remove(
            'dragging'
        );
    }

    try {
        if (
            antennaDragHandle &&
            antennaDragHandle.hasPointerCapture(
                antennaDragPointerId
            )
        ) {
            antennaDragHandle.releasePointerCapture(
                antennaDragPointerId
            );
        }
    } catch (error) {
        // Ignorar errores de pointer capture.
    }

    antennaDragPointerId =
        null;

    saveAntennaPosition();
}

/* ============================================================
   ANTENNA HELPERS
============================================================ */

function antennaStateLabel(
    state
) {
    switch (state) {
        case 'active':
            return translate(
                'antenna_state_active'
            );

        case 'maintenance':
            return translate(
                'antenna_state_maintenance'
            );

        case 'broken':
            return translate(
                'antenna_state_broken'
            );

        default:
            return translate(
                'antenna_state_offline'
            );
    }
}

function antennaTypeLabel(
    type
) {
    if (type === 'world') {
        return translate(
            'antenna_type_world'
        );
    }

    return translate(
        'antenna_type_player'
    );
}

function antennaHealthClass(
    health
) {
    const value =
        Number(health) || 0;

    if (value < 30) {
        return 'critical';
    }

    if (value < 60) {
        return 'warning';
    }

    return 'good';
}

function setAntennaText(
    id,
    value
) {
    const element =
        document.getElementById(id);

    if (!element) {
        return;
    }

    element.textContent =
        value === undefined ||
        value === null ||
        value === ''
            ? '--'
            : value;
}

function renderAntennaHealth(
    health
) {
    const numeric =
        Math.max(
            0,
            Math.min(
                100,
                Number(health) || 0
            )
        );

    const valueElement =
        document.getElementById(
            'antennaHealthValue'
        );

    const barElement =
        document.getElementById(
            'antennaHealthBar'
        );

    if (valueElement) {
        valueElement.textContent =
            `${Math.floor(numeric)}%`;
    }

    if (barElement) {
        barElement.style.width =
            `${numeric}%`;

        barElement.classList.remove(
            'good',
            'warning',
            'critical'
        );

        barElement.classList.add(
            antennaHealthClass(
                numeric
            )
        );
    }
}

function renderAntennaState(
    antenna
) {
    if (!antenna) {
        return;
    }

    const state =
        antenna.state ||
        'offline';

    setAntennaText(
        'antennaId',
        antenna.id
    );

    setAntennaText(
        'antennaType',
        antennaTypeLabel(
            antenna.type
        )
    );

    setAntennaText(
        'antennaOwner',
        antenna.owner ||
            translate(
                'antenna_system'
            )
    );

    setAntennaText(
        'antennaRadius',
        antenna.radius !== undefined
            ? Math.floor(
                Number(
                    antenna.radius
                ) || 0
            )
            : '--'
    );

    const stateElement =
        document.getElementById(
            'antennaState'
        );

    if (stateElement) {
        stateElement.textContent =
            antennaStateLabel(
                state
            );

        stateElement.classList.remove(
            'active',
            'maintenance',
            'broken',
            'offline'
        );

        stateElement.classList.add(
            state
        );
    }

    const headerState =
        document.getElementById(
            'antennaHeaderState'
        );

    if (headerState) {
        headerState.textContent =
            antennaStateLabel(
                state
            );

        headerState.classList.remove(
            'active',
            'maintenance',
            'broken',
            'offline'
        );

        headerState.classList.add(
            state
        );
    }

    const networkState =
        document.getElementById(
            'antennaNetworkState'
        );

    if (networkState) {
        networkState.textContent =
            state === 'active'
                ? translate(
                    'antenna_network_online'
                )
                : translate(
                    'antenna_network_offline'
                );
    }

    renderAntennaHealth(
        antenna.health
    );
}

function renderAntennaNetwork(
    antenna
) {
    if (!antenna) {
        return;
    }

    setAntennaText(
        'antennaSignalNetwork',
        antenna.state === 'active'
            ? translate('signal_ok')
            : translate('signal_none')
    );

    setAntennaText(
        'antennaPlayers',
        antenna.players !== undefined
            ? antenna.players
            : 0
    );

    setAntennaText(
        'antennaDistance',
        antenna.distance !== undefined
            ? Math.floor(
                Number(
                    antenna.distance
                ) || 0
            )
            : 0
    );
}

function renderCost(
    id,
    costs
) {
    const element =
        document.getElementById(id);

    if (!element) {
        return;
    }

    if (
        !Array.isArray(costs) ||
        costs.length === 0
    ) {
        element.textContent =
            translate(
                'antenna_no_cost'
            );

        return;
    }

    element.textContent =
        costs
            .map(cost => {
                const amount =
                    Number(
                        cost.amount
                    ) || 0;

                const item =
                    cost.item ||
                    cost.key ||
                    '';

                return `${amount}x ${translateMaterial(item)}`;
            })
            .join(' + ');
}

function renderMaterials(
    antenna
) {
    const container =
        document.getElementById(
            'antennaMaterials'
        );

    if (!container) {
        return;
    }

    const costs = [];

    if (
        Array.isArray(
            antenna.repairCosts
        )
    ) {
        costs.push(
            ...antenna.repairCosts
        );
    }

    if (
        Array.isArray(
            antenna.maintenanceCosts
        )
    ) {
        costs.push(
            ...antenna.maintenanceCosts
        );
    }

    const unique =
        new Map();

    costs.forEach(cost => {
        const key =
            cost.item ||
            cost.key;

        if (!key) {
            return;
        }

        if (!unique.has(key)) {
            unique.set(
                key,
                {
                    ...cost
                }
            );
        }
    });

    container.innerHTML = '';

    if (unique.size === 0) {
        const empty =
            document.createElement(
                'div'
            );

        empty.className =
            'antenna-material';

        empty.textContent =
            translate(
                'antenna_no_materials'
            );

        container.appendChild(
            empty
        );

        return;
    }

    unique.forEach(
        material => {
            const row =
                document.createElement(
                    'div'
                );

            row.className =
                'antenna-material';

            if (
                material.available === false
            ) {
                row.classList.add(
                    'missing'
                );
            } else {
                row.classList.add(
                    'available'
                );
            }

            const label =
                document.createElement(
                    'strong'
                );

            label.textContent =
                translateMaterial(
                    material.item ||
                    material.key
                );

            const amount =
                document.createElement(
                    'small'
                );

            amount.textContent =
                `${material.amount || 0}`;

            row.appendChild(
                label
            );

            row.appendChild(
                amount
            );

            container.appendChild(
                row
            );
        }
    );
}

function setOperationButton(
    id,
    enabled
) {
    const button =
        document.getElementById(id);

    if (!button) {
        return;
    }

    button.disabled =
        !enabled ||
        antennaBusy;
}

function updateAntennaButtons(
    antenna
) {
    if (!antenna) {
        return;
    }

    setOperationButton(
        'antennaRepair',
        antenna.canRepair === true
    );

    setOperationButton(
        'antennaMaintain',
        antenna.canMaintain === true
    );

    setOperationButton(
        'antennaRemove',
        antenna.canRemove === true
    );
}

function showOperationStatus(
    title,
    message,
    visible = true
) {
    const status =
        document.getElementById(
            'antennaOperationStatus'
        );

    const titleElement =
        document.getElementById(
            'antennaOperationTitle'
        );

    const messageElement =
        document.getElementById(
            'antennaOperationMessage'
        );

    if (status) {
        status.classList.toggle(
            'hidden',
            !visible
        );
    }

    if (titleElement) {
        titleElement.textContent =
            title;
    }

    if (messageElement) {
        messageElement.textContent =
            message;
    }
}

function setAntennaBusy(
    busy
) {
    antennaBusy =
        Boolean(busy);

    updateAntennaButtons(
        currentAntenna
    );

    if (antennaBusy) {
        showOperationStatus(
            translate(
                'antenna_processing'
            ),
            translate(
                'antenna_please_wait'
            ),
            true
        );
    } else {
        showOperationStatus(
            '',
            '',
            false
        );
    }
}

/* ============================================================
   ANTENNA TERMINAL
============================================================ */

function openAntennaTerminal(
    data
) {
    if (!data) {
        return;
    }

    antennaTerminalOpen = true;
    antennaBusy = false;

    currentAntenna =
        data.antenna || null;

    currentAntennaId =
        currentAntenna
            ? currentAntenna.id
            : null;

    const terminal =
        document.getElementById(
            'antennaTerminal'
        );

    if (terminal) {
        terminal.classList.remove(
            'hidden'
        );

        terminal.setAttribute(
            'aria-hidden',
            'false'
        );
    }

    applyLocale(data);

    if (currentAntenna) {
        renderAntennaState(
            currentAntenna
        );

        renderAntennaNetwork(
            currentAntenna
        );

        renderMaterials(
            currentAntenna
        );

        renderCost(
            'antennaRepairCost',
            currentAntenna.repairCosts
        );

        renderCost(
            'antennaMaintenanceCost',
            currentAntenna.maintenanceCosts
        );

        updateAntennaButtons(
            currentAntenna
        );
    }

    showOperationStatus(
        '',
        '',
        false
    );

    requestAnimationFrame(
        () => {
            applyAntennaPosition();
        }
    );
}

function closeAntennaTerminal(
    notifyClient = true
) {
    antennaTerminalOpen =
        false;

    antennaBusy = false;
    currentAntenna = null;
    currentAntennaId = null;

    const terminal =
        document.getElementById(
            'antennaTerminal'
        );

    if (terminal) {
        terminal.classList.add(
            'hidden'
        );

        terminal.setAttribute(
            'aria-hidden',
            'true'
        );
    }

    showOperationStatus(
        '',
        '',
        false
    );

    if (notifyClient) {
        post(
            'antennaClose'
        );
    }
}

function refreshAntennaTerminal(
    antenna
) {
    if (
        !antennaTerminalOpen ||
        !antenna
    ) {
        return;
    }

    currentAntenna =
        antenna;

    currentAntennaId =
        antenna.id;

    renderAntennaState(
        antenna
    );

    renderAntennaNetwork(
        antenna
    );

    renderMaterials(
        antenna
    );

    renderCost(
        'antennaRepairCost',
        antenna.repairCosts
    );

    renderCost(
        'antennaMaintenanceCost',
        antenna.maintenanceCosts
    );

    updateAntennaButtons(
        antenna
    );
}

function requestAntennaOperation(
    operation,
    callback
) {
    if (
        !currentAntennaId ||
        !currentAntenna
    ) {
        return;
    }

    if (antennaBusy) {
        return;
    }

    if (!callback) {
        return;
    }

    setAntennaBusy(true);

    post(
        callback,
        {
            id:
                currentAntennaId
        }
    ).catch(() => {
        setAntennaBusy(false);
    });
}

/* ============================================================
   INITIAL POSITION
============================================================ */

loadPosition();
loadAntennaPosition();

window.addEventListener(
    'resize',
    () => {
        applyPosition();
        savePosition();

        applyAntennaPosition();

        if (
            antennaPosition.x !== null &&
            antennaPosition.y !== null
        ) {
            saveAntennaPosition();
        }
    }
);

if (dragHandle) {
    dragHandle.addEventListener(
        'pointerdown',
        startDrag
    );

    dragHandle.addEventListener(
        'pointermove',
        moveDrag
    );

    dragHandle.addEventListener(
        'pointerup',
        stopDrag
    );

    dragHandle.addEventListener(
        'pointercancel',
        stopDrag
    );

    dragHandle.addEventListener(
        'dblclick',
        event => {
            if (
                event.target.closest(
                    'button, input, a'
                )
            ) {
                return;
            }

            centerPosition();
        }
    );
}

if (antennaDragHandle) {
    antennaDragHandle.addEventListener(
        'pointerdown',
        startAntennaDrag
    );

    antennaDragHandle.addEventListener(
        'pointermove',
        moveAntennaDrag
    );

    antennaDragHandle.addEventListener(
        'pointerup',
        stopAntennaDrag
    );

    antennaDragHandle.addEventListener(
        'pointercancel',
        stopAntennaDrag
    );

    antennaDragHandle.addEventListener(
        'dblclick',
        event => {
            if (
                event.target.closest(
                    'button, input, a'
                )
            ) {
                return;
            }

            centerAntennaPosition();
        }
    );
}

/* ============================================================
   RADIO BUTTONS
============================================================ */

const closeButton =
    document.getElementById(
        'close'
    );

if (closeButton) {
    closeButton.addEventListener(
        'click',
        () => post('close')
    );
}

const joinButton =
    document.getElementById(
        'join'
    );

if (joinButton) {
    joinButton.addEventListener(
        'click',
        () => post(
            'join',
            {
                frequency:
                    currentFrequency
            }
        )
    );
}

const leaveButton =
    document.getElementById(
        'leave'
    );

if (leaveButton) {
    leaveButton.addEventListener(
        'click',
        () => post('leave')
    );
}

const upButton =
    document.getElementById(
        'up'
    );

if (upButton) {
    upButton.addEventListener(
        'click',
        () => changeFrequency(1)
    );
}

const downButton =
    document.getElementById(
        'down'
    );

if (downButton) {
    downButton.addEventListener(
        'click',
        () => changeFrequency(-1)
    );
}

if (volume) {
    volume.addEventListener(
        'input',
        () => {
            if (volumeValue) {
                volumeValue.textContent =
                    `${volume.value}%`;
            }

            post(
                'volume',
                {
                    volume:
                        Number(
                            volume.value
                        )
                }
            );
        }
    );
}

const channelButton =
    document.getElementById(
        'channel'
    );

if (channelButton) {
    channelButton.addEventListener(
        'click',
        () => post(
            'frequency',
            {
                frequency:
                    currentFrequency
            }
        )
    );
}

/* ============================================================
   ANTENNA BUTTONS
============================================================ */

const antennaClose =
    document.getElementById(
        'antennaClose'
    );

if (antennaClose) {
    antennaClose.addEventListener(
        'click',
        () => {
            closeAntennaTerminal(
                true
            );
        }
    );
}

const antennaRepair =
    document.getElementById(
        'antennaRepair'
    );

if (antennaRepair) {
    antennaRepair.addEventListener(
        'click',
        () => {
            requestAntennaOperation(
                'repair',
                'antennaRepair'
            );
        }
    );
}

const antennaMaintain =
    document.getElementById(
        'antennaMaintain'
    );

if (antennaMaintain) {
    antennaMaintain.addEventListener(
        'click',
        () => {
            requestAntennaOperation(
                'maintenance',
                'antennaMaintenance'
            );
        }
    );
}

const antennaRemove =
    document.getElementById(
        'antennaRemove'
    );

if (antennaRemove) {
    antennaRemove.addEventListener(
        'click',
        () => {
            requestAntennaOperation(
                'remove',
                'antennaRemove'
            );
        }
    );
}

/* ============================================================
   KEYBOARD
============================================================ */

document.addEventListener(
    'keydown',
    event => {
        if (
            antennaTerminalOpen &&
            event.key === 'Escape'
        ) {
            event.preventDefault();

            closeAntennaTerminal(
                true
            );

            return;
        }

        if (antennaTerminalOpen) {
            return;
        }

        if (event.key === 'Escape') {
            post('close');

            return;
        }

        if (event.key === 'ArrowUp') {
            event.preventDefault();

            changeFrequency(1);

            return;
        }

        if (event.key === 'ArrowDown') {
            event.preventDefault();

            changeFrequency(-1);

            return;
        }

        if (event.key === 'Enter') {
            post(
                'join',
                {
                    frequency:
                        currentFrequency
                }
            );
        }
    }
);

/* ============================================================
   NUI MESSAGE HANDLER
============================================================ */

window.addEventListener(
    'message',
    event => {
        const data =
            event.data || {};

        if (
            data.locale ||
            data.translations
        ) {
            applyLocale(data);
        }

        /* ----------------------------------------------------
           RADIO OPEN
        ---------------------------------------------------- */

        if (
            data.action === 'open'
        ) {
            if (!radio) {
                return;
            }

            radio.classList.remove(
                'hidden'
            );

            radio.setAttribute(
                'aria-hidden',
                'false'
            );

            maxFrequency =
                Number(
                    data.maxFrequency
                ) || 500;

            renderFrequency(
                data.frequency
            );

            renderVolume(
                data.volume
            );

            renderSignal(
                data.signal
            );

            renderConnection(
                data.on
            );

            requestAnimationFrame(
                () => {
                    applyPosition();
                }
            );

            return;
        }

        /* ----------------------------------------------------
           RADIO CLOSE
        ---------------------------------------------------- */

        if (
            data.action === 'close'
        ) {
            if (!radio) {
                return;
            }

            radio.classList.add(
                'hidden'
            );

            radio.setAttribute(
                'aria-hidden',
                'true'
            );

            return;
        }

        /* ----------------------------------------------------
           RADIO STATE
        ---------------------------------------------------- */

        if (
            data.action === 'state'
        ) {
            if (
                data.frequency !==
                undefined
            ) {
                renderFrequency(
                    data.frequency
                );
            }

            if (
                data.signal !==
                undefined
            ) {
                renderSignal(
                    data.signal
                );
            }

            if (
                data.on !==
                undefined
            ) {
                renderConnection(
                    data.on
                );
            }

            if (
                data.volume !==
                undefined
            ) {
                renderVolume(
                    data.volume
                );
            }

            return;
        }

        /* ----------------------------------------------------
           RADIO SIGNAL
        ---------------------------------------------------- */

        if (
            data.action === 'signal'
        ) {
            renderSignal(
                data.signal
            );

            if (
                data.on !==
                undefined
            ) {
                renderConnection(
                    data.on
                );
            }

            if (
                data.frequency !==
                undefined
            ) {
                renderFrequency(
                    data.frequency
                );
            }

            return;
        }

        /* ----------------------------------------------------
           ANTENNA OPEN
        ---------------------------------------------------- */

        if (
            data.action ===
                'antennaOpen' ||
            data.action ===
                'openAntenna'
        ) {
            openAntennaTerminal(
                data
            );

            return;
        }

        /* ----------------------------------------------------
           ANTENNA UPDATE
        ---------------------------------------------------- */

        if (
            data.action ===
                'antennaUpdate'
        ) {
            setAntennaBusy(
                false
            );

            refreshAntennaTerminal(
                data.antenna
            );

            return;
        }

        /* ----------------------------------------------------
           ANTENNA CLOSE
        ---------------------------------------------------- */

        if (
            data.action ===
                'antennaClose'
        ) {
            closeAntennaTerminal(
                false
            );

            return;
        }

        /* ----------------------------------------------------
           OPERATION STARTED
        ---------------------------------------------------- */

        if (
            data.action ===
                'antennaOperation'
        ) {
            setAntennaBusy(
                true
            );

            if (data.antenna) {
                refreshAntennaTerminal(
                    data.antenna
                );
            }

            return;
        }

        /* ----------------------------------------------------
           OPERATION RESULT
        ---------------------------------------------------- */

        if (
            data.action ===
                'antennaOperationResult'
        ) {
            setAntennaBusy(
                false
            );

            if (data.antenna) {
                refreshAntennaTerminal(
                    data.antenna
                );
            }

            if (data.success) {
                showOperationStatus(
                    translate(
                        'antenna_operation_complete'
                    ),
                    data.message ||
                        translate(
                            'antenna_operation_complete'
                        ),
                    true
                );

                setTimeout(
                    () => {
                        if (
                            antennaTerminalOpen
                        ) {
                            showOperationStatus(
                                '',
                                '',
                                false
                            );
                        }
                    },
                    2500
                );
            }

            return;
        }
    }
);