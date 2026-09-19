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

function post(event, data = {}) {
    return fetch(`https://${resource}/${event}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    });
}

function renderSignal(signal) {
    if (signal) {
        led.classList.add('ok');
        signalText.textContent = 'SEÑAL OK';
        networkState.textContent = 'CONECTADA';
    } else {
        led.classList.remove('ok');
        signalText.textContent = 'SIN SEÑAL';
        networkState.textContent = 'SIN COBERTURA';
    }
}

function renderFrequency(value) {
    currentFrequency = Number(value) || 0;
    frequency.textContent = currentFrequency
        ? currentFrequency.toFixed(1)
        : '000.0';
}

function changeFrequency(delta) {
    let value = currentFrequency || 1;
    value += delta;

    if (value < 1) value = maxFrequency;
    if (value > maxFrequency) value = 1;

    renderFrequency(value);
}

document.getElementById('close').addEventListener('click', () => post('close'));
document.getElementById('join').addEventListener('click', () => post('join', {frequency: currentFrequency}));
document.getElementById('leave').addEventListener('click', () => post('leave'));
document.getElementById('up').addEventListener('click', () => changeFrequency(1));
document.getElementById('down').addEventListener('click', () => changeFrequency(-1));

volume.addEventListener('input', () => {
    volumeValue.textContent = `${volume.value}%`;
    post('volume', {volume: Number(volume.value)});
});

document.getElementById('channel').addEventListener('click', () => {
    post('frequency', {frequency: currentFrequency});
});

document.addEventListener('keydown', event => {
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
        post('join', {frequency: currentFrequency});
    }
});

window.addEventListener('message', event => {
    const data = event.data || {};

    if (data.action === 'open') {
        radio.classList.remove('hidden');
        maxFrequency = Number(data.maxFrequency) || 500;
        renderFrequency(data.frequency || 0);
        volume.value = Number(data.volume) || 50;
        volumeValue.textContent = `${volume.value}%`;
        renderSignal(Boolean(data.signal));
    }

    if (data.action === 'close') {
        radio.classList.add('hidden');
    }

    if (data.action === 'state') {
        renderFrequency(data.frequency || 0);
        if (typeof data.signal !== 'undefined') renderSignal(Boolean(data.signal));
        if (typeof data.volume !== 'undefined') {
            volume.value = data.volume;
            volumeValue.textContent = `${data.volume}%`;
        }
    }

    if (data.action === 'signal') {
        renderSignal(Boolean(data.signal));
        renderFrequency(data.frequency || currentFrequency);
    }
});
