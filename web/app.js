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

function renderSignal(signal) {
    currentSignal = Boolean(signal);

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

    volume.value = numeric;
    volumeValue.textContent = `${numeric}%`;
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
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;

    return {
        x:
            viewportWidth *
            (position.x / 100),

        y:
            viewportHeight *
            (position.y / 100)
    };
}

function applyPosition() {
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
        event.pointerId !== dragPointerId
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

    device.classList.remove('dragging');
    dragHandle.classList.remove('dragging');

    try {
        if (
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

loadPosition();

window.addEventListener(
    'resize',
    () => {
        applyPosition();
        savePosition();
    }
);

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

/* ============================================================
   BUTTONS
============================================================ */

document
    .getElementById('close')
    .addEventListener(
        'click',
        () => post('close')
    );

document
    .getElementById('join')
    .addEventListener(
        'click',
        () => post(
            'join',
            {
                frequency: currentFrequency
            }
        )
    );

document
    .getElementById('leave')
    .addEventListener(
        'click',
        () => post('leave')
    );

document
    .getElementById('up')
    .addEventListener(
        'click',
        () => changeFrequency(1)
    );

document
    .getElementById('down')
    .addEventListener(
        'click',
        () => changeFrequency(-1)
    );

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

document
    .getElementById('channel')
    .addEventListener(
        'click',
        () => post(
            'frequency',
            {
                frequency: currentFrequency
            }
        )
    );

/* ============================================================
   KEYBOARD
============================================================ */

document.addEventListener(
    'keydown',
    event => {

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

        if (data.action === 'open') {

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
    }
);