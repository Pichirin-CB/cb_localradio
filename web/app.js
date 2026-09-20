const resource = typeof GetParentResourceName === 'function'
    ? GetParentResourceName()
    : 'cb_localradio';

const radio = document.getElementById('radio');
const frequency = document.getElementById('frequency');
const volume = document.getElementById('volume');
const volumeValue = document.getElementById('volumeValue');
const signalText = document.getElementById('signalText');
const networkState = document.getElementById('networkState');
const led = document.getElementById('led');

let currentFrequency = 0;
let maxFrequency = 500;

let locale = 'en';
let translations = {};

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
    if (signal) {
        led.classList.add('ok');

        signalText.textContent = translate(
            'signal_ok'
        );

        networkState.textContent = translate(
            'connected'
        );
    } else {
        led.classList.remove('ok');

        signalText.textContent = translate(
            'signal_none'
        );

        networkState.textContent = translate(
            'no_coverage'
        );
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

window.addEventListener(
    'message',
    event => {
        const data = event.data || {};

        /*
         * Apply translations first.
         *
         * This is important because renderSignal()
         * depends on the translated strings.
         */
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

            renderFrequency(
                data.frequency || currentFrequency
            );
        }
    }
);