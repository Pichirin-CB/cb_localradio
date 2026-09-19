# CB Local Radio

![CB Studios](https://img.shields.io/badge/CB%20Studios-CB%20Local%20Radio-black)
![FiveM](https://img.shields.io/badge/FiveM-Resource-orange)
![Version](https://img.shields.io/badge/Version-1.0.0-gold)
![License](https://img.shields.io/badge/License-MIT-blue)

---

## Resource Information

**Resource:** `cb_localradio`
**Version:** `1.0.0`
**Author:** CB Studios
**Type:** FiveM / Survival Local Radio Network
**License:** MIT

---

## Overview

**CB Local Radio** is a physical local radio network designed for FiveM survival, zombie and post-apocalyptic servers.

Unlike a traditional global radio system, CB Local Radio requires players to have access to a physical radio and active antenna coverage.

The radio network is based on physical infrastructure placed throughout the game world.

Players can:

* Use a physical radio item.
* Connect to configurable radio frequencies.
* Build their own radio antennas.
* Repair damaged antennas.
* Maintain antenna infrastructure.
* Remove antennas they own.
* Use existing GTA V world antennas.
* Extend coverage through connected antenna networks.
* Lose radio access when leaving active coverage.
* Communicate through PMA-Voice.

CB Local Radio uses **HateBridge** as its framework and inventory abstraction layer.

It does not directly depend on a specific inventory implementation.

---

# Features

## Radio System

* Physical radio item requirement.
* Local radio network.
* Configurable frequency range.
* Signal verification.
* Physical coverage requirements.
* Automatic channel removal outside coverage.
* Configurable radio volume.
* Custom NUI.
* PMA-Voice integration.
* Server-side channel management.

## Antenna System

* Player-built antennas.
* Existing GTA V world antennas.
* Antenna health/integrity.
* Automatic degradation.
* Maintenance system.
* Repair system.
* Broken antenna state.
* Antenna ownership.
* Minimum construction distance.
* Configurable antenna coverage radius.
* Configurable item return probability when removing antennas.

## Network System

* Automatic antenna linking.
* Configurable connection distance.
* Chained antenna networks.
* Network refresh system.
* Physical coverage detection.
* Server-side network synchronization.

Example:

```text
A <--------> B <--------> C
```

When network chaining is enabled, `A`, `B` and `C` can operate as part of the same connected network.

---

# Dependencies

CB Local Radio requires:

* FiveM
* HateBridge
* oxmysql
* pma-voice

---

# HateBridge

CB Local Radio uses **HateBridge** as the abstraction layer between the resource and the framework/inventory system.

HateBridge provides a unified API for supported frameworks and server systems.

## Official Repository

https://github.com/HATE-dev/hate-bridge

## Documentation

https://hate-development.gitbook.io/hate-development-docs/hate-framework-bridge

CB Local Radio uses the bridge for:

* Framework abstraction.
* Item checks.
* Item removal.
* Item addition.
* Usable item registration.
* Notifications.
* Progress handling.

CB Local Radio should not directly access framework-specific inventory exports.

---

# Architecture

```text
CB Local Radio
      │
      ├── HateBridge
      │      ├── Framework abstraction
      │      ├── Inventory abstraction
      │      ├── Item checks
      │      ├── Item removal
      │      ├── Item addition
      │      ├── Notifications
      │      └── Progress handling
      │
      ├── oxmysql
      │      └── Database persistence
      │
      └── pma-voice
             ├── Radio voice transport
             ├── Radio PTT
             ├── Radio animation
             ├── Radio audio
             └── Radio submix
```

The resource intentionally separates radio infrastructure from voice transport.

CB Local Radio controls the radio network.

PMA-Voice controls actual voice transmission.

---

# Installation

## 1. Install Dependencies

Install and configure:

```text
oxmysql
HateBridge
pma-voice
```

HateBridge repository:

```text
https://github.com/HATE-dev/hate-bridge
```

HateBridge documentation:

```text
https://hate-development.gitbook.io/hate-development-docs/hate-framework-bridge
```

Make sure all dependencies are working before starting CB Local Radio.

---

## 2. Install CB Local Radio

Place the resource inside your resources directory.

Example:

```text
resources/
└── [cb]/
    └── cb_localradio/
```

---

## 3. Configure the Resource

Open:

```text
cb_localradio/config.lua
```

Main configuration sections:

```lua
Config.Debug
Config.Items
Config.Antenna
Config.Network
Config.Radio
Config.Blips
Config.Radius
Config.WorldAntennas
Config.Messages
```

---

# Server Configuration

A recommended start order is:

```cfg
ensure oxmysql
ensure ox_lib

ensure pma-voice
ensure hate-bridge
ensure cb_localradio
```

If your server uses different resource folder names, adjust the `ensure` lines accordingly.

---

# PMA-Voice Configuration

CB Local Radio uses **PMA-Voice** for actual radio voice communication.

CB Local Radio controls:

* Radio frequency.
* Radio channel assignment.
* Signal.
* Antenna coverage.
* Antenna networks.
* Radio volume.
* Radio NUI.

PMA-Voice controls:

* Radio push-to-talk.
* Voice transmission.
* Radio animation.
* Radio audio.
* Radio submix.
* Radio voice transport.

This separation is intentional.

---

## Recommended PMA-Voice Settings

Add or verify the following in `server.cfg`:

```cfg
setr voice_useNativeAudio true
setr voice_defaultCycle "GRAVE"
setr voice_defaultVolume 0.3
setr voice_enableRadios 1
setr voice_enableRadioAnim 1
setr voice_enableSubmix 1
setr voice_enableCalls 0
setr voice_defaultRadio "LMENU"
setr voice_onClickVolume 10
setr voice_offClickVolume 3
setr voice_syncData 1
setr voice_useSendingRangeOnly false
set mumble_allowExternalConnections true
```

The default PMA-Voice radio push-to-talk key is:

```text
LEFT ALT
```

CB Local Radio does not register another radio-talk key.

---

# Radio Controls

## Open Radio

Default command:

```text
/localradio
```

Default key:

```text
F7
```

The key can be changed with:

```lua
Config.Radio.key
```

The command can be changed with:

```lua
Config.Radio.command
```

---

## Radio Push-to-Talk

Radio transmission is controlled by PMA-Voice.

Default:

```text
LEFT ALT
```

Configured through:

```cfg
setr voice_defaultRadio "LMENU"
```

Do not add another radio transmission key to CB Local Radio.

---

# Radio Frequencies

The default frequency range is:

```lua
minFrequency = 1
maxFrequency = 500
```

Players can connect to any valid frequency inside that range.

Example:

```text
100
125
250
500
```

---

# Signal Requirement

The following configuration controls whether a signal is required:

```lua
Config.Radio.requireSignal
```

Default:

```lua
requireSignal = true
```

When enabled, the player must be inside active antenna coverage before joining a radio frequency.

---

# Leaving Coverage

The following option controls automatic channel removal:

```lua
Config.Radio.leaveWhenOutOfCoverage
```

Default:

```lua
leaveWhenOutOfCoverage = true
```

When enabled, leaving antenna coverage automatically removes the player from the PMA-Voice radio channel.

---

# Radio Volume

Default radio volume:

```lua
defaultVolume = 50
```

The player can adjust the radio volume through the NUI.

The value is passed to PMA-Voice.

---

# Items

Default configuration:

```lua
Config.Items = {
    radio = 'radio',
    antennaKit = 'radio_antenna',
    repairKit = 'radio_repair_kit',
    maintenanceKit = 'radio_maintenance_kit',
    cable = 'radio_cable',
    metal = 'scrap_metal',
    electronics = 'electronic_parts'
}
```

The actual inventory implementation is handled through HateBridge.

The configured item names must exist in the inventory system used by the server.

---

# Items Used by CB Local Radio

The current resource actively uses:

```text
radio
radio_antenna
radio_repair_kit
radio_maintenance_kit
```

---

## Radio

Item:

```text
radio
```

The player must have a radio before opening or using the local radio system.

---

## Antenna Kit

Item:

```text
radio_antenna
```

Used to construct a player antenna.

The item is removed when the antenna is successfully installed.

When removing an owned antenna, the resource can optionally return the kit.

The return behavior is controlled by:

```lua
Config.Antenna.construction.itemReturnOnRemove
Config.Antenna.construction.returnPercent
```

Example:

```lua
itemReturnOnRemove = true
returnPercent = 75
```

This means there is a **75% probability** of receiving one `radio_antenna` back when removing the antenna.

---

## Repair Kit

Item:

```text
radio_repair_kit
```

Used to repair a broken antenna.

The amount repaired is controlled by:

```lua
Config.Antenna.repair.health
```

Default:

```lua
health = 35.0
```

---

## Maintenance Kit

Item:

```text
radio_maintenance_kit
```

Used for antenna maintenance and repair of non-broken antennas.

The amount restored is controlled by:

```lua
Config.Antenna.maintenance.health
```

Default:

```lua
health = 15.0
```

---

# Additional Configured Materials

The configuration also contains:

```text
radio_cable
scrap_metal
electronic_parts
```

These items are currently configured for future crafting, scavenging or server-specific integrations.

They are not currently consumed by the antenna construction, repair or maintenance logic.

---

# Antenna System

CB Local Radio supports two antenna types:

```text
Player Antennas
World Antennas
```

---

# Player Antennas

Players can construct antennas using:

```text
radio_antenna
```

The construction system supports:

* Placement.
* Position validation.
* Rotation.
* Construction progress.
* Construction animation.
* Minimum distance validation.
* Ownership.
* Removal.
* Optional item return.

Configuration:

```lua
Config.Antenna.construction
```

---

# Antenna Construction

Default construction duration:

```lua
duration = 15000
```

The construction animation is configured through:

```lua
Config.Antenna.construction.animation
```

---

# Minimum Antenna Distance

Player antennas cannot be installed too close to another antenna.

Default:

```lua
minimumDistance = 500.0
```

This prevents unnecessary antenna clustering.

---

# Removing Antennas

Only the owner of a player-built antenna can remove it.

Default key:

```text
H
```

The server validates:

* Antenna existence.
* Antenna type.
* Player distance.
* Antenna ownership.

---

# Antenna Item Return

The return system is controlled by:

```lua
itemReturnOnRemove = true
returnPercent = 75
```

`returnPercent` represents a probability.

Examples:

```text
0   = 0% chance
25  = 25% chance
50  = 50% chance
75  = 75% chance
100 = 100% chance
```

The resource returns one antenna kit when the probability check succeeds.

---

# World Antennas

Existing GTA V antenna infrastructure can be configured through:

```lua
Config.WorldAntennas
```

Example:

```lua
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
}
```

Each world antenna supports:

* Unique ID.
* World model.
* Coordinates.
* Heading.
* Coverage radius.

---

# Antenna Health

Every antenna has an integrity value.

Degradation is controlled through:

```lua
Config.Antenna.degradation
```

Default:

```lua
degradation = {
    enabled = true,
    intervalMinutes = 60,
    amount = 5.0,
    minimumHealthBeforeMaintenance = 95.0
}
```

This means antennas gradually lose integrity over time.

---

# Antenna States

Antennas can have three states:

```text
active
maintenance
broken
```

The state is calculated from the antenna health.

Default:

```lua
brokenAt = 0.0
maintenanceAt = 60.0
```

Therefore:

```text
Health <= 0
    = broken

Health < 60
    = maintenance

Health >= 60
    = active
```

---

# Broken Antennas

When an antenna reaches:

```text
Health <= 0
```

it becomes broken.

Broken antennas do not provide active radio coverage.

A broken antenna must be repaired before returning to active operation.

---

# Repair

Broken antennas can be repaired using:

```text
radio_repair_kit
```

The amount repaired is configured through:

```lua
Config.Antenna.repair.health
```

Default:

```lua
health = 35.0
```

The repair system includes:

* Progress duration.
* Animation.
* Server-side item validation.
* Server-side distance validation.
* Server-side antenna state validation.

Default repair key:

```text
E
```

---

# Maintenance

Antennas can receive maintenance before becoming completely broken.

Maintenance uses:

```text
radio_maintenance_kit
```

The amount restored is configured through:

```lua
Config.Antenna.maintenance.health
```

Default:

```lua
health = 15.0
```

Default maintenance key:

```text
G
```

---

# Antenna Interaction

The current version uses direct proximity interaction.

It does not require:

```text
ox_target
qb-target
qtarget
```

The default interaction keys are:

| Key | Action               |
| --- | -------------------- |
| E   | Repair               |
| G   | Maintenance          |
| H   | Remove owned antenna |

The available action depends on the antenna state and player ownership.

---

# Progress System

CB Local Radio uses HateBridge for progress handling.

Depending on the server environment, the bridge can use supported progress systems.

The resource also contains a fallback progress implementation.

The fallback supports:

* Progress percentage.
* Animation.
* Movement restrictions.
* Combat restrictions.
* Action cancellation.

Default cancellation key:

```text
X
```

---

# Antenna Networks

Antennas automatically form radio networks according to:

```lua
Config.Network.linkDistance
```

Default:

```lua
linkDistance = 1200.0
```

Antennas inside the configured connection distance can become part of the same network.

---

# Network Chaining

Chaining is controlled by:

```lua
Config.Network.allowChaining
```

Default:

```lua
allowChaining = true
```

With chaining enabled:

```text
A <----> B <----> C
```

can operate as a connected network.

This allows antenna infrastructure to extend radio coverage across multiple connected antenna nodes.

---

# Network Refresh

Network refresh interval:

```lua
Config.Network.refreshSeconds
```

Default:

```lua
refreshSeconds = 5
```

Player signal check interval:

```lua
Config.Network.playerCheckSeconds
```

Default:

```lua
playerCheckSeconds = 2
```

---

# Physical Coverage

Radio signal is determined by the player's physical position relative to active antenna coverage.

The system checks the player's position against active antenna coverage.

Conceptually:

```text
              ANTENNA A
             /         \
            /           \
        PLAYER         ANTENNA B
            \           /
             \         /
              NETWORK
```

Inside coverage:

```text
SIGNAL: ACTIVE
```

Outside coverage:

```text
SIGNAL: LOST
```

If configured, the player is automatically removed from the radio channel.

---

# Blips

Blips can be enabled through:

```lua
Config.Blips.enabled
```

World antenna blips:

```lua
Config.Blips.showWorldAntennas
```

Player antenna blips:

```lua
Config.Blips.showPlayerAntennas
```

Default colors:

```lua
colors = {
    active = 2,
    maintenance = 17,
    broken = 1,
    offline = 40
}
```

---

# Coverage Radius

Coverage visualization can be enabled through:

```lua
Config.Radius.enabled
```

Maximum visualization distance:

```lua
Config.Radius.drawDistance
```

Coverage visualization supports:

* Active antennas.
* Maintenance antennas.
* Broken antennas.

---

# NUI

CB Local Radio includes a custom NUI.

Files:

```text
web/
├── index.html
├── style.css
└── app.js
```

The NUI handles:

* Radio interface.
* Frequency input.
* Signal state.
* Radio state.
* Volume control.
* Channel joining.
* Channel leaving.

CB Local Radio does not use the `qb-radio` NUI.

---

# Commands

## Open Radio

```text
/localradio
```

The command can be changed through:

```lua
Config.Radio.command
```

---

# Default Controls

| Action               | Key      |
| -------------------- | -------- |
| Open radio           | F7       |
| Radio transmission   | Left ALT |
| Cancel progress      | X        |
| Repair antenna       | E        |
| Maintain antenna     | G        |
| Remove owned antenna | H        |

Radio transmission is controlled by PMA-Voice.

---

# Database

CB Local Radio uses:

```text
oxmysql
```

for persistent antenna data.

Database operations are performed server-side.

The client does not directly access the database.

The database stores antenna information including:

* Antenna ID.
* Type.
* Owner.
* Model.
* Coordinates.
* Heading.
* Radius.
* Health.
* State.
* Maintenance timestamps.
* Degradation timestamps.

---

# Server-Side Validation

Important gameplay operations are validated on the server.

This includes:

* Antenna placement.
* Minimum antenna distance.
* Item requirements.
* Item removal.
* Item return.
* Antenna ownership.
* Repair.
* Maintenance.
* Antenna distance.
* Antenna state.
* Network synchronization.

Client-side values are not authoritative.

---

# Resource Structure

```text
cb_localradio/
│
├── fxmanifest.lua
├── README.md
├── config.lua
│
├── client/
│   ├── bridge.lua
│   ├── main.lua
│   ├── antennas.lua
│   ├── radio.lua
│   └── placement.lua
│
├── server/
│   ├── bridge.lua
│   ├── main.lua
│   └── antennas.lua
│
├── shared/
│   └── utils.lua
│
└── web/
    ├── index.html
    ├── style.css
    └── app.js
```

---

# Configuration Reference

## Debug

```lua
Config.Debug = false
```

---

## Items

```lua
Config.Items = {
    radio = 'radio',
    antennaKit = 'radio_antenna',
    repairKit = 'radio_repair_kit',
    maintenanceKit = 'radio_maintenance_kit',
    cable = 'radio_cable',
    metal = 'scrap_metal',
    electronics = 'electronic_parts'
}
```

---

## Antenna

```lua
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
    interactionDistance = 3.0
}
```

---

## Construction

```lua
Config.Antenna.construction = {
    duration = 15000,
    itemReturnOnRemove = true,
    returnPercent = 75
}
```

---

## Repair

```lua
Config.Antenna.repair = {
    duration = 10000,
    health = 35.0
}
```

---

## Maintenance

```lua
Config.Antenna.maintenance = {
    duration = 6000,
    health = 15.0
}
```

---

## Network

```lua
Config.Network = {
    linkDistance = 1200.0,
    allowChaining = true,
    refreshSeconds = 5,
    playerCheckSeconds = 2
}
```

---

## Radio

```lua
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
```

---

# Troubleshooting

## Resource Does Not Start

Check:

```text
fxmanifest.lua
```

Verify:

* `oxmysql` is running.
* `hate-bridge` is running.
* `pma-voice` is running.
* Dependencies start before `cb_localradio`.
* No dependency errors appear in the server console.

---

# Radio Does Not Open

Check:

* Player owns the `radio` item.
* `Config.Items.radio` matches the inventory item.
* HateBridge is running.
* `Config.Radio.enabled` is `true`.
* `/localradio` works.
* F7 is not being blocked by another resource.

---

# Radio Says "No Signal"

Check:

* Player position.
* Antenna coverage.
* Antenna state.
* Antenna health.
* Network linking.
* `Config.Network.linkDistance`.
* `Config.Radio.requireSignal`.
* `Config.Radio.usePhysicalCoverage`.

---

# Radio Does Not Transmit

Check:

* PMA-Voice is running.
* Radio support is enabled.
* The player has joined a radio frequency.
* No other resource is overriding the PMA-Voice radio channel.
* `voice_defaultRadio` is configured correctly.

Recommended:

```cfg
setr voice_enableRadios 1
setr voice_defaultRadio "LMENU"
```

Hold:

```text
LEFT ALT
```

while connected to a radio channel.

---

# Radio Animation Does Not Play

Check:

```cfg
setr voice_enableRadioAnim 1
```

The radio animation is handled by PMA-Voice.

---

# Radio Audio Effects Do Not Work

Check:

```cfg
setr voice_useNativeAudio true
setr voice_enableSubmix 1
```

These settings allow PMA-Voice audio/submix functionality to operate.

---

# Antenna Cannot Be Placed

Check:

* Player owns `radio_antenna`.
* Item name is correct.
* Player is not too close to another antenna.
* HateBridge is running.
* Placement system is running.
* Server-side validation is not rejecting the placement.

---

# Antenna Does Not Provide Signal

Check:

* Antenna health.
* Antenna state.
* Network connection.
* `Config.Network.linkDistance`.
* `Config.Network.allowChaining`.
* Network refresh interval.
* Player position.
* World antenna configuration.

---

# Repair Does Not Work

For a broken antenna, check:

```text
radio_repair_kit
```

For a damaged but non-broken antenna, check:

```text
radio_maintenance_kit
```

Also verify:

* Player is close enough.
* Antenna exists.
* Antenna is in a valid state.
* Player owns the required item.
* HateBridge is correctly connected to the inventory.

---

# Maintenance Does Not Work

Check:

```text
radio_maintenance_kit
```

Also verify:

* Player is close enough.
* Antenna health is below the configured maintenance threshold.
* Player has the required item.
* HateBridge is running.

---

# NUI Does Not Open

Check:

```text
web/index.html
web/style.css
web/app.js
```

Verify `fxmanifest.lua` contains:

```lua
ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
```

Check the FiveM client console for NUI errors.

---

# Updating

Before updating CB Local Radio:

1. Stop the resource.
2. Back up the current resource.
3. Replace the resource files.
4. Compare the new `config.lua` with your existing configuration.
5. Verify item names.
6. Verify HateBridge configuration.
7. Verify PMA-Voice configuration.
8. Start the resource again.

Do not overwrite a customized configuration without checking your existing settings.

---

# Compatibility Notes

CB Local Radio is designed to remain independent from a specific framework or inventory implementation.

The resource communicates with the framework/inventory layer through:

```text
HateBridge
```

Official repository:

```text
https://github.com/HATE-dev/hate-bridge
```

Official documentation:

```text
https://hate-development.gitbook.io/hate-development-docs/hate-framework-bridge
```

Do not add direct inventory calls such as:

```lua
exports.ox_inventory
```

directly into CB Local Radio.

Inventory-specific functionality should remain inside HateBridge.

---

# PMA-Voice Responsibilities

## CB Local Radio

Handles:

```text
Physical radio item
Frequency
Signal
Coverage
Antenna network
Radio channel assignment
Radio volume
NUI
```

## PMA-Voice

Handles:

```text
Voice transport
Radio push-to-talk
Radio animation
Radio audio
Radio submix
Radio transmission
```

This separation prevents both systems from competing for the same radio controls.

---

# HateBridge Responsibilities

HateBridge provides the abstraction used by CB Local Radio for:

```text
Framework detection
Inventory abstraction
Item checks
Item removal
Item addition
Usable item registration
Notifications
Progress handling
```

Official repository:

```text
https://github.com/HATE-dev/hate-bridge
```

Official documentation:

```text
https://hate-development.gitbook.io/hate-development-docs/hate-framework-bridge
```

---

# Recommended Server Configuration

```cfg
ensure oxmysql
ensure ox_lib

ensure pma-voice
ensure hate-bridge
ensure cb_localradio
```

Recommended PMA-Voice settings:

```cfg
setr voice_useNativeAudio true
setr voice_defaultCycle "GRAVE"
setr voice_defaultVolume 0.3
setr voice_enableRadios 1
setr voice_enableRadioAnim 1
setr voice_enableSubmix 1
setr voice_enableCalls 0
setr voice_defaultRadio "LMENU"
setr voice_onClickVolume 10
setr voice_offClickVolume 3
setr voice_syncData 1
setr voice_useSendingRangeOnly false
set mumble_allowExternalConnections true
```

---

# Testing Checklist

After installation, verify:

```text
[ ] HateBridge starts successfully
[ ] oxmysql starts successfully
[ ] pma-voice starts successfully
[ ] cb_localradio starts successfully
[ ] Player owns the radio item
[ ] F7 opens the radio
[ ] /localradio opens the radio
[ ] Frequency can be selected
[ ] Antenna provides signal
[ ] Radio channel is assigned
[ ] Left ALT transmits
[ ] Radio animation works
[ ] Radio volume changes
[ ] Leaving coverage removes signal
[ ] Antenna can be constructed
[ ] Antenna can be repaired
[ ] Antenna can be maintained
[ ] Owner can remove an antenna
[ ] Antenna return probability works
[ ] Antenna networks link correctly
[ ] Chained networks work
[ ] World antennas provide coverage
```

---

# Support

When reporting an issue, provide:

```text
Resource:
CB Local Radio

Version:
1.0.0

FiveM Server Build:

Framework:

Inventory:

HateBridge Version:

pma-voice Version:

oxmysql Version:

Server Console Error:

Client Console Error:

Description:
```

Complete console errors and screenshots are recommended.

---

# Credits

**CB Studios**

CB Local Radio integrates external dependencies including:

* HateBridge
* oxmysql
* pma-voice

HateBridge:

https://github.com/HATE-dev/hate-bridge

Each external dependency remains subject to its own license and terms.

---

# Links

## CB Studios

**Store**

https://pichirin-cb.tebex.io/

**Documentation**

https://docs.pichirincb.com/

**Discord**

https://discord.gg/hsx6AvBg5s

---

## HateBridge

**GitHub Repository**

https://github.com/HATE-dev/hate-bridge

**Documentation**

https://hate-development.gitbook.io/hate-development-docs/hate-framework-bridge

---

# License

CB Local Radio is released under the MIT License.

See:

```text
LICENSE
```

for the complete license text.

---

**CB Studios — Local infrastructure for survival servers.**
