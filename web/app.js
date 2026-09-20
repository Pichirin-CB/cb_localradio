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

let antennaTerminalOpen = false;
let currentAntenna = null;
let currentAntennaId = null;
let antennaBusy = false;

/* ============================================================
   HELPERS
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

function translate(key) {
    if (
        translations &&
        Object.prototype.hasOwnProperty.call(
            translations,
            key
        )
    ) {
        return translations[key];
    }

    return key;
}

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
        translations = data.translations;
    }

    document.documentElement.lang = locale;

    document
        .querySelectorAll('[data-i18n]')
        .forEach(element => {
            const key = element.dataset.i18n;

            element.textContent = translate(key);
        });

    document
        .querySelectorAll('[data-i18n-aria]')
        .forEach(element => {
            const key = element.dataset.i18nAria;

            element.setAttribute(
                'aria-label',
                translate(key)
            );
        });
}

/* ============================================================
   RADIO STATE
============================================================ */

function renderSignal(signal) {
    currentSignal = Boolean(signal);

    if (!led || !signalText) {
        return;
    }

    if (currentSignal) {
        led.classList.add('ok');

        signalText.textContent = translate(
            'signal_ok'
        );
    } else {
        led.classList.remove('ok');

        signalText.textContent = translate(
            'signal_none'
        );
    }
}

function renderConnection(connected) {
    currentConnected = Boolean(connected);

    if (!networkState) {
        return;
    }

    if (currentConnected) {
        networkState.textContent = translate(
            'connected'
        );

        networkState.classList.add('connected');
    } else {
        networkState.textContent = translate(
            'disconnected'
        );

        networkState.classList.remove('connected');
    }
}

function renderFrequency(value) {
    currentFrequency = Number(value) || 0;

    if (!frequency) {
        return;
    }

    frequency.textContent = currentFrequency
        ? currentFrequency.toFixed(1)
        : '000.0';
}

function renderVolume(value) {
    const numeric = Math.max(
        0,
        Math.min(
            100,
            Number(value) || 0
        )
    );

    if (volume) {
        volume.value = numeric;
    }

    if (volumeValue) {
        volumeValue.textContent = `${numeric}%`;
    }
}

function changeFrequency(delta) {
    let value = currentFrequency || 1;

    value += delta;

    if (value < 1) {
        value = maxFrequency;
    }

    if (value > maxFrequency) {
        value = 1;
    }

    renderFrequency(value);
}

/* ============================================================
   POSITION
============================================================ */

function loadPosition() {
    try {
        const saved = localStorage.getItem(
            POSITION_KEY
        );

        if (!saved) {
            return;
        }

        const parsed = JSON.parse(saved);

        if (
            typeof parsed.x === 'number' &&
            typeof parsed.y === 'number'
        ) {
            position.x = Math.max(
                0,
                Math.min(
                    100,
                    parsed.x
                )
            );

            position.y = Math.max(
                0,
                Math.min(
                    100,
                    parsed.y
                )
            );
        }
    } catch (error) {
        position.x = DEFAULT_POSITION.x;
        position.y = DEFAULT_POSITION.y;
    }
}

function savePosition() {
    try {
        localStorage.setItem(
            POSITION_KEY,
            JSON.stringify(position)
        );
    } catch (error) {
        // Ignore storage errors.
    }
}

function clampPosition(x, y) {
    if (!device) {
        return {
            x,
            y
        };
    }

    const width = device.offsetWidth;
    const height = device.offsetHeight;

    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;

    const margin = 10;

    const minX = margin;
    const minY = margin;

    const maxX = Math.max(
        minX,
        viewportWidth - width - margin
    );

    const maxY = Math.max(
        minY,
        viewportHeight - height - margin
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

    const pixels = positionToPixels();

    const clamped = clampPosition(
        pixels.x,
        pixels.y
    );

    position.x =
        (clamped.x / window.innerWidth) *
        100;

    position.y =
        (clamped.y / window.innerHeight) *
        100;

    device.style.left = `${clamped.x}px`;
    device.style.top = `${clamped.y}px`;

    device.style.transform = 'none';
}

function centerPosition() {
    if (!device) {
        return;
    }

    const width = device.offsetWidth;
    const height = device.offsetHeight;

    const x =
        Math.max(
            10,
            (window.innerWidth - width) / 2
        );

    const y =
        Math.max(
            10,
            (window.innerHeight - height) / 2
        );

    position.x =
        (x / window.innerWidth) *
        100;

    position.y =
        (y / window.innerHeight) *
        100;

    applyPosition();
    savePosition();
}

function startDrag(event) {
    if (!device || !dragHandle) {
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
    dragPointerId = event.pointerId;

    const rect = device.getBoundingClientRect();

    dragOffsetX =
        event.clientX - rect.left;

    dragOffsetY =
        event.clientY - rect.top;

    device.classList.add('dragging');
    dragHandle.classList.add('dragging');

    dragHandle.setPointerCapture(
        event.pointerId
    );

    event.preventDefault();
}

function moveDrag(event) {
    if (
        !dragging ||
        event.pointerId !== dragPointerId ||
        !device
    ) {
        return;
    }

    const next = clampPosition(
        event.clientX - dragOffsetX,
        event.clientY - dragOffsetY
    );

    position.x =
        (next.x / window.innerWidth) *
        100;

    position.y =
        (next.y / window.innerHeight) *
        100;

    device.style.left = `${next.x}px`;
    device.style.top = `${next.y}px`;
    device.style.transform = 'none';

    event.preventDefault();
}

function stopDrag(event) {
    if (
        !dragging ||
        (
            event.pointerId !== undefined &&
            event.pointerId !== dragPointerId
        )
    ) {
        return;
    }

    dragging = false;

    if (device) {
        device.classList.remove('dragging');
    }

    if (dragHandle) {
        dragHandle.classList.remove('dragging');
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
        // Ignore pointer capture errors.
    }

    dragPointerId = null;

    savePosition();
}

/* ============================================================
   ANTENNA HELPERS
============================================================ */

function getAntennaElement(id) {
    if (!id) {
        return null;
    }

    return document.querySelector(
        `[data-antenna-id="${CSS.escape(String(id))}"]`
    );
}

function antennaStateLabel(state) {
    switch (state) {
        case 'active':
            return translate('antenna_state_active');

        case 'maintenance':
            return translate('antenna_state_maintenance');

        case 'broken':
            return translate('antenna_state_broken');

        default:
            return translate('antenna_state_offline');
    }
}

function antennaTypeLabel(type) {
    if (type === 'world') {
        return translate('antenna_type_world');
    }

    return translate('antenna_type_player');
}

function antennaHealthClass(health) {
    const value = Number(health) || 0;

    if (value <= 0) {
        return 'critical';
    }

    if (value < 30) {
        return 'critical';
    }

    if (value < 60) {
        return 'warning';
    }

    return 'good';
}

function formatHealth(value) {
    const health = Math.max(
        0,
        Math.min(
            100,
            Number(value) || 0
        )
    );

    return Math.floor(health);
}

function renderAntennaHealth(health) {
    const numeric = formatHealth(health);

    const valueElement =
        document.getElementById('antennaHealthValue');

    const barElement =
        document.getElementById('antennaHealthBar');

    const container =
        document.getElementById('antennaHealth');

    if (valueElement) {
        valueElement.textContent =
            `${numeric}%`;
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
            antennaHealthClass(numeric)
        );
    }

    if (container) {
        container.classList.remove(
            'good',
            'warning',
            'critical'
        );

        container.classList.add(
            antennaHealthClass(numeric)
        );
    }
}

function setAntennaText(id, value) {
    const element = document.getElementById(id);

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

function renderAntennaState(antenna) {
    if (!antenna) {
        return;
    }

    const state =
        antenna.state || 'offline';

    const stateElement =
        document.getElementById('antennaState');

    if (stateElement) {
        stateElement.textContent =
            antennaStateLabel(state);

        stateElement.classList.remove(
            'active',
            'maintenance',
            'broken',
            'offline'
        );

        stateElement.classList.add(state);
    }

    setAntennaText(
        'antennaType',
        antennaTypeLabel(antenna.type)
    );

    setAntennaText(
        'antennaOwner',
        antenna.owner || translate('antenna_system')
    );

    setAntennaText(
        'antennaRadius',
        antenna.radius
            ? `${Math.floor(Number(antenna.radius))}m`
            : '--'
    );

    setAntennaText(
        'antennaStatus',
        antennaStateLabel(state)
    );

    renderAntennaHealth(
        antenna.health
    );
}

function renderAntennaSignal(antenna) {
    if (!antenna) {
        return;
    }

    const signal =
        antenna.signal !== undefined
            ? Boolean(antenna.signal)
            : antenna.state === 'active';

    const signalElement =
        document.getElementById('antennaSignal');

    if (!signalElement) {
        return;
    }

    signalElement.textContent = signal
        ? translate('signal_ok')
        : translate('signal_none');

    signalElement.classList.toggle(
        'active',
        signal
    );

    signalElement.classList.toggle(
        'offline',
        !signal
    );
}

function renderAntennaMaterials(materials) {
    const container =
        document.getElementById('antennaMaterials');

    if (!container) {
        return;
    }

    container.innerHTML = '';

    if (
        !materials ||
        typeof materials !== 'object'
    ) {
        return;
    }

    Object.entries(materials).forEach(
        ([key, material]) => {

            const row =
                document.createElement('div');

            row.className =
                'antenna-material';

            const label =
                document.createElement('span');

            label.className =
                'antenna-material-label';

            label.textContent =
                material.label ||
                key;

            const amount =
                document.createElement('span');

            amount.className =
                'antenna-material-amount';

            const required =
                Number(material.required) || 0;

            const available =
                Number(material.available) || 0;

            amount.textContent =
                `${available}/${required}`;

            if (available < required) {
                row.classList.add('missing');
            } else {
                row.classList.add('available');
            }

            row.appendChild(label);
            row.appendChild(amount);

            container.appendChild(row);
        }
    );
}

function canPerformAntennaOperation(
    operation,
    antenna
) {
    if (
        antennaBusy ||
        !antenna
    ) {
        return false;
    }

    const health =
        Number(antenna.health) || 0;

    if (operation === 'repair') {
        return antenna.state === 'broken' ||
            health <= 0;
    }

    if (operation === 'maintenance') {
        return health <
            95;
    }

    if (operation === 'remove') {
        return antenna.type === 'player';
    }

    return false;
}

function setAntennaBusy(value) {
    antennaBusy = Boolean(value);

    document
        .querySelectorAll(
            '[data-antenna-operation]'
        )
        .forEach(button => {
            button.disabled =
                antennaBusy;
        });
}

function updateAntennaButtons(antenna) {
    document
        .querySelectorAll(
            '[data-antenna-operation]'
        )
        .forEach(button => {

            const operation =
                button.dataset.antennaOperation;

            let allowed =
                canPerformAntennaOperation(
                    operation,
                    antenna
                );

            if (
                operation === 'remove' &&
                antenna.type !== 'player'
            ) {
                allowed = false;
            }

            button.disabled =
                !allowed ||
                antennaBusy;
        });
}

function openAntennaTerminal(data) {
    antennaTerminalOpen = true;

    currentAntennaId =
        data.antennaId ||
        data.id ||
        null;

    currentAntenna =
        data.antenna ||
        data;

    const terminal =
        document.getElementById(
            'antennaTerminal'
        );

    if (terminal) {
        terminal.classList.remove('hidden');

        terminal.setAttribute(
            'aria-hidden',
            'false'
        );
    }

    renderAntennaState(
        currentAntenna
    );

    renderAntennaSignal(
        currentAntenna
    );

    renderAntennaMaterials(
        data.materials
    );

    updateAntennaButtons(
        currentAntenna
    );
}

function closeAntennaTerminal(sendCallback = true) {
    antennaTerminalOpen = false;
    currentAntenna = null;
    currentAntennaId = null;
    antennaBusy = false;

    const terminal =
        document.getElementById(
            'antennaTerminal'
        );

    if (terminal) {
        terminal.classList.add('hidden');

        terminal.setAttribute(
            'aria-hidden',
            'true'
        );
    }

    if (sendCallback) {
        post('closeAntenna');
    }
}

function refreshAntennaTerminal(data) {
    if (!antennaTerminalOpen) {
        return;
    }

    if (
        data &&
        data.antenna
    ) {
        currentAntenna =
            data.antenna;
    } else if (
        data &&
        data.id &&
        currentAntenna &&
        data.id === currentAntenna.id
    ) {
        currentAntenna = {
            ...currentAntenna,
            ...data
        };
    } else if (
        data &&
        currentAntenna
    ) {
        currentAntenna = {
            ...currentAntenna,
            ...data
        };
    }

    renderAntennaState(
        currentAntenna
    );

    renderAntennaSignal(
        currentAntenna
    );

    if (data && data.materials) {
        renderAntennaMaterials(
            data.materials
        );
    }

    updateAntennaButtons(
        currentAntenna
    );
}

function requestAntennaOperation(operation) {
    if (
        !currentAntennaId ||
        !currentAntenna
    ) {
        return;
    }

    if (
        !canPerformAntennaOperation(
            operation,
            currentAntenna
        )
    ) {
        return;
    }

    setAntennaBusy(true);

    post(
        'antennaOperation',
        {
            antennaId: currentAntennaId,
            operation
        }
    ).catch(() => {
        setAntennaBusy(false);
        updateAntennaButtons(
            currentAntenna
        );
    });
}

/* ============================================================
   LOAD / POSITION
============================================================ */

loadPosition();

window.addEventListener(
    'resize',
    () => {
        applyPosition();
        savePosition();
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

    /*
     * Double-click the radio header to restore
     * the interface to the center of the screen.
     */
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

/* ============================================================
   RADIO BUTTONS
============================================================ */

const closeButton =
    document.getElementById('close');

if (closeButton) {
    closeButton.addEventListener(
        'click',
        () => post('close')
    );
}

const joinButton =
    document.getElementById('join');

if (joinButton) {
    joinButton.addEventListener(
        'click',
        () => post(
            'join',
            {
                frequency: currentFrequency
            }
        )
    );
}

const leaveButton =
    document.getElementById('leave');

if (leaveButton) {
    leaveButton.addEventListener(
        'click',
        () => post('leave')
    );
}

const upButton =
    document.getElementById('up');

if (upButton) {
    upButton.addEventListener(
        'click',
        () => changeFrequency(1)
    );
}

const downButton =
    document.getElementById('down');

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

            volumeValue.textContent =
                `${volume.value}%`;

            post(
                'volume',
                {
                    volume: Number(volume.value)
                }
            );
        }
    );
}

const channelButton =
    document.getElementById('channel');

if (channelButton) {
    channelButton.addEventListener(
        'click',
        () => post(
            'frequency',
            {
                frequency: currentFrequency
            }
        )
    );
}

/* ============================================================
   ANTENNA BUTTONS
============================================================ */

document
    .querySelectorAll(
        '[data-antenna-operation]'
    )
    .forEach(button => {

        button.addEventListener(
            'click',
            () => {

                const operation =
                    button.dataset.antennaOperation;

                requestAntennaOperation(
                    operation
                );
            }
        );
    });

const antennaClose =
    document.getElementById(
        'antennaClose'
    );

if (antennaClose) {
    antennaClose.addEventListener(
        'click',
        () => closeAntennaTerminal()
    );
}

const antennaBack =
    document.getElementById(
        'antennaBack'
    );

if (antennaBack) {
    antennaBack.addEventListener(
        'click',
        () => closeAntennaTerminal()
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

            closeAntennaTerminal();

            return;
        }

        if (
            antennaTerminalOpen &&
            event.key === 'Enter'
        ) {
            return;
        }

        if (event.key === 'Escape') {
            post('close');
        }

        if (event.key === 'ArrowUp') {
            event.preventDefault();

            changeFrequency(1);
        }

        if (event.key === 'ArrowDown') {
            event.preventDefault();

            changeFrequency(-1);
        }

        if (event.key === 'Enter') {
            post(
                'join',
                {
                    frequency: currentFrequency
                }
            );
        }
    }
);

/* ============================================================
   NUI MESSAGES
============================================================ */

window.addEventListener(
    'message',
    event => {

        const data = event.data || {};

        if (
            data.translations ||
            data.locale
        ) {
            applyLocale(data);
        }

        /* ----------------------------------------------------
           RADIO
        ---------------------------------------------------- */

        if (data.action === 'open') {

            if (!radio) {
                return;
            }

            radio.classList.remove('hidden');

            radio.setAttribute(
                'aria-hidden',
                'false'
            );

            maxFrequency =
                Number(data.maxFrequency) || 500;

            renderFrequency(
                data.frequency || 0
            );

            renderVolume(
                data.volume || 50
            );

            renderSignal(
                Boolean(data.signal)
            );

            renderConnection(
                Boolean(data.on)
            );

            requestAnimationFrame(() => {
                applyPosition();
            });
        }

        if (data.action === 'close') {

            if (!radio) {
                return;
            }

            radio.classList.add('hidden');

            radio.setAttribute(
                'aria-hidden',
                'true'
            );
        }

        if (data.action === 'state') {

            renderFrequency(
                data.frequency || 0
            );

            if (
                typeof data.signal !== 'undefined'
            ) {
                renderSignal(
                    Boolean(data.signal)
                );
            }

            if (
                typeof data.on !== 'undefined'
            ) {
                renderConnection(
                    Boolean(data.on)
                );
            }

            if (
                typeof data.volume !== 'undefined'
            ) {
                renderVolume(
                    data.volume
                );
            }
        }

        if (data.action === 'signal') {

            renderSignal(
                Boolean(data.signal)
            );

            if (
                typeof data.on !== 'undefined'
            ) {
                renderConnection(
                    Boolean(data.on)
                );
            }

            renderFrequency(
                data.frequency ||
                currentFrequency
            );
        }

        /* ----------------------------------------------------
           ANTENNA TERMINAL
        ---------------------------------------------------- */

        if (
            data.action === 'antennaOpen' ||
            data.action === 'openAntenna'
        ) {
            openAntennaTerminal(data);
        }

        if (
            data.action === 'antennaClose' ||
            data.action === 'closeAntenna'
        ) {
            closeAntennaTerminal(false);
        }

        if (
            data.action === 'antennaState' ||
            data.action === 'antennaUpdate' ||
            data.action === 'antennaRefresh'
        ) {
            setAntennaBusy(false);

            refreshAntennaTerminal(data);
        }

        if (
            data.action === 'antennaOperation'
        ) {
            setAntennaBusy(
                Boolean(data.busy)
            );

            if (data.antenna) {
                refreshAntennaTerminal(
                    data
                );
            }
        }

        if (
            data.action === 'antennaOperationResult'
        ) {
            setAntennaBusy(false);

            if (data.antenna) {
                refreshAntennaTerminal(
                    data
                );
            }

            if (
                data.close === true
            ) {
                closeAntennaTerminal(false);
            }
        }
    }
);