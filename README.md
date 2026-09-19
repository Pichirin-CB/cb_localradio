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

# Overview

**CB Local Radio** is a physical local radio network designed for **FiveM survival, zombie and post-apocalyptic servers**.

Unlike a traditional global radio system, CB Local Radio requires players to have access to a physical radio and to be connected to an active antenna network.

Radio communication is controlled by the physical infrastructure of the server.

Players can:

* Build radio antennas.
* Connect antennas into networks.
* Extend coverage through chained antenna networks.
* Maintain damaged antennas.
* Repair broken antennas.
* Remove antennas they own.
* Use existing GTA V world antenna infrastructure.
* Connect to configurable radio frequencies.
* Communicate through PMA-Voice.
* Lose radio access when leaving network coverage.

The resource uses **HateBridge** as its framework and inventory abstraction layer.

It does **not directly depend on a specific inventory implementation**.

---

# Features

## Radio System

* Physical radio item requirement.
* Local radio network.
* Configurable frequency range.
* Signal verification.
* Automatic loss of radio access outside coverage.
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
* Partial item return when removing antennas.
* Configurable antenna coverage radius.

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

When chaining is enabled, `A`, `B` and `C` can operate as part of the same network even when `A` and `C` are not directly connected.

---

# Dependencies

CB Local Radio requires:

* FiveM
* HateBridge
* oxmysql
* pma-voice

## Dependency Architecture

The resource uses:

```text
CB Local Radio
      │
      ├── HateBridge
      │      ├── Framework abstraction
      │      ├── Inventory abstraction
      │      ├── Notifications
      │      └── Progress handling
      │
      ├── oxmysql
      │      └── Database persistence
      │
      └── pma-voice
             └── Radio voice transport
```

The resource should not directly add framework-specific inventory exports unless the bridge architecture is intentionally changed.

---

# Installation

## 1. Install Dependencies

Install and configure:

```text
oxmysql
HateBridge
pma-voice
```

Make sure all dependencies are working correctly before starting CB Local Radio.

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

## 3. Configure `config.lua`

Open:

```text
cb_localradio/config.lua
```

The main configuration contains:

```lua
Config.Items
Config.Antenna
Config.Network
Config.Radio
Config.Blips
Config.Radius
Config.Target
Config.WorldAntennas
Config.Messages
```

Configure the resource according to your server.

---

# Resource Start Order

Because `cb_localradio` declares `pma-voice` as a dependency, PMA-Voice must be available before CB Local Radio starts.

A recommended order is:

```cfg
ensure oxmysql
ensure ox_lib

ensure [voice]

ensure hate-bridge
ensure cb_localradio
```

If your PMA-Voice resource is not inside `[voice]`, replace the collection with the actual resource name.

For example:

```cfg
ensure pma-voice
ensure hate-bridge
ensure cb_localradio
```

Do not start `cb_localradio` before its required dependencies.

---

# PMA-Voice Configuration

CB Local Radio uses **PMA-Voice for voice transmission**.

CB Local Radio controls:

* Radio frequency.
* Radio channel assignment.
* Radio volume.
* Signal availability.
* Coverage restrictions.

PMA-Voice controls the actual voice transmission and radio push-to-talk system.

This separation is intentional.

## Recommended Server Configuration

Add or update the PMA-Voice configuration in `server.cfg`:

```cfg
# Voice config
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

`LMENU` corresponds to the **Left ALT** key used by PMA-Voice for radio transmission.

Therefore:

```text
LEFT ALT
```

is the default radio push-to-talk key.

PMA-Voice owns the radio transmission key and animation. CB Local Radio does not register a second radio-talk key.

This prevents both resources from attempting to control the same push-to-talk functionality.

---

# Radio Controls

## Open Radio

Default command:

```text
/localradio
```

Default interface key:

```text
F7
```

The F7 key opens the CB Local Radio interface.

The setting can be changed through:

```lua
Config.Radio.command
Config.Radio.key
```

---

## Radio Push-to-Talk

Radio transmission is handled by PMA-Voice.

Default:

```text
LEFT ALT
```

The PMA-Voice setting is:

```cfg
setr voice_defaultRadio "LMENU"
```

Do not create a second `RegisterKeyMapping` for radio transmission inside CB Local Radio.

---

# Radio Frequencies

The default frequency range is:

```lua
minFrequency = 1
maxFrequency = 500
```

Players can only join frequencies inside the configured range.

Example:

```text
Frequency 100
Frequency 125
Frequency 250
Frequency 500
```

---

# Signal Requirement

The following option controls whether a player needs active antenna coverage:

```lua
Config.Radio.requireSignal
```

When enabled:

```lua
requireSignal = true
```

the player must be inside an active antenna network to join a radio frequency.

Without active signal coverage, the player cannot connect to the radio network.

---

# Leaving Radio Coverage

The following option controls automatic channel removal:

```lua
Config.Radio.leaveWhenOutOfCoverage
```

When enabled:

```lua
leaveWhenOutOfCoverage = true
```

the player is automatically removed from the PMA-Voice radio channel when leaving active antenna coverage.

This creates a physical local-radio network instead of a global radio system.

---

# Radio Volume

The default radio volume is:

```lua
defaultVolume = 50
```

The volume can be changed through the radio NUI.

The configured value is passed to PMA-Voice.

---

# Items

Default item configuration:

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

The actual inventory implementation is handled by HateBridge.

The item names configured here must match the items registered in the inventory system behind HateBridge.

---

# Required Items

The default resource uses:

```text
radio
radio_antenna
radio_repair_kit
radio_maintenance_kit
radio_cable
electronic_parts
scrap_metal
```

## Radio

```text
radio
```

Required to use the local radio.

## Antenna Kit

```text
radio_antenna
```

Used to construct player antennas.

## Repair Kit

```text
radio_repair_kit
```

Used to repair broken antennas.

## Maintenance Kit

```text
radio_maintenance_kit
```

Used to maintain damaged antennas.

## Additional Materials

```text
radio_cable
electronic_parts
scrap_metal
```

These items are available for the resource's material configuration and can be used by server configurations or future gameplay integrations.

---

# HateBridge

CB Local Radio uses HateBridge as the abstraction layer between the resource and the server framework/inventory.

The resource communicates through the bridge instead of directly depending on:

```text
ESX
QBCore
Qbox
ox_inventory
```

or another specific inventory implementation.

This allows the resource architecture to remain independent from the underlying framework.

The bridge is responsible for functionality such as:

* Item checks.
* Item removal.
* Item addition.
* Usable item registration.
* Notifications.
* Progress handling.
* Framework abstraction.
* Player-related bridge operations.

Do not add direct inventory exports to CB Local Radio unless the bridge architecture is intentionally being modified.

---

# Antenna System

CB Local Radio supports two antenna types.

## Player Antennas

Players can construct antennas using:

```text
radio_antenna
```

The construction system supports:

* Placement preview.
* Position validation.
* Rotation.
* Construction progress.
* Construction animation.
* Minimum distance checks.
* Ownership.
* Removal.
* Partial item return.

Construction settings are controlled through:

```lua
Config.Antenna.construction
```

---

# Antenna Construction

The default construction duration is:

```lua
duration = 15000
```

The player must complete the construction process before the antenna becomes active.

The construction animation is configured through:

```lua
Config.Antenna.construction.animation
```

---

# Minimum Antenna Distance

Player-built antennas cannot be placed too close to another antenna.

The default minimum distance is:

```lua
minimumDistance = 500.0
```

This prevents players from creating unnecessary antenna clusters.

---

# Removing Player Antennas

Player-owned antennas can be removed.

The configuration supports returning a percentage of the original antenna item:

```lua
itemReturnOnRemove = true
returnPercent = 75
```

Only the antenna owner can normally remove their antenna.

Server-side validation is performed before removal.

---

# World Antennas

Existing GTA V antenna infrastructure can be registered through:

```lua
Config.WorldAntennas
```

World antennas use their existing world models instead of creating duplicate player props.

Each antenna supports:

```lua
{
    id = 'world_ant_01',
    model = 'sc1_23_antenna',
    coords = vector3(...),
    heading = 0.0,
    radius = 1100.0
}
```

Available properties:

* ID.
* Model.
* Coordinates.
* Heading.
* Coverage radius.

---

# Antenna Health

Every antenna has an integrity/health value.

Health degradation is controlled by:

```lua
Config.Antenna.degradation
```

Example:

```lua
degradation = {
    enabled = true,
    intervalMinutes = 60,
    amount = 5.0,
    minimumHealthBeforeMaintenance = 95.0
}
```

This means the antenna can gradually lose integrity over time.

---

# Broken Antennas

The broken threshold is configured through:

```lua
brokenAt = 0.0
```

When an antenna reaches the broken state:

```text
Health <= brokenAt
```

it no longer provides radio coverage.

The antenna must be repaired before it can return to normal operation.

---

# Antenna Repair

Broken antennas can be repaired using:

```text
radio_repair_kit
```

The repair amount is controlled through:

```lua
Config.Antenna.repair.health
```

Default:

```lua
health = 35.0
```

Repair also supports:

* Progress duration.
* Repair animation.
* Server-side validation.
* Distance validation.
* Item validation.

---

# Antenna Maintenance

Antennas can also receive maintenance before becoming completely broken.

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

Maintenance is intended to keep antennas operational and prevent them from reaching the broken state.

---

# Progress System

CB Local Radio uses the bridge architecture for progress actions.

The resource can use supported progress systems through HateBridge.

The bridge can integrate with:

```text
qb-progressbar
ox_lib
```

depending on the installed server configuration.

If no compatible progress system is available, CB Local Radio provides its own fallback progress handling.

This fallback includes:

* Progress percentage.
* Animation.
* Movement restrictions.
* Action cancellation.

The fallback can be cancelled using:

```text
X
```

---

# Antenna Networks

Antennas automatically form networks according to their configured connection distance.

The maximum connection distance is:

```lua
Config.Network.linkDistance
```

Default:

```lua
linkDistance = 1200.0
```

---

# Network Chaining

Network chaining can be enabled with:

```lua
allowChaining = true
```

When enabled:

```text
A <----> B <----> C
```

can operate as one network.

A player near `C` can receive signal from the same network even if `C` is not directly connected to `A`.

The network is built through connected antenna nodes.

---

# Network Refresh

The network refresh interval is controlled through:

```lua
refreshSeconds = 5
```

Player signal checks are controlled through:

```lua
playerCheckSeconds = 2
```

These values can be adjusted depending on server requirements.

---

# Physical Coverage

Signal is determined by actual player position relative to active antenna coverage.

The player is checked against the coverage areas generated by the active antenna network.

Conceptually:

```text
          ANTENNA A
          /       \
         /         \
      PLAYER      ANTENNA B
         \         /
          \       /
          NETWORK
```

If the player is inside the active network:

```text
SIGNAL: ACTIVE
```

If the player leaves the network:

```text
SIGNAL: LOST
```

When configured, the radio channel is automatically removed.

---

# Blips

Antenna blips can be enabled through:

```lua
Config.Blips.enabled
```

World antennas:

```lua
Config.Blips.showWorldAntennas
```

Player antennas:

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

# Coverage Visualization

Coverage visualization can be enabled with:

```lua
Config.Radius.enabled
```

The maximum visualization distance is controlled through:

```lua
Config.Radius.drawDistance
```

The resource supports different visualization states for:

```text
Active
Maintenance
Broken
```

---

# Target / Interaction

The resource supports configurable interaction settings through:

```lua
Config.Target
```

Example:

```lua
Config.Target = {
    enabled = true,
    distance = 3.0
}
```

The antenna system also provides direct proximity interactions.

Typical antenna actions include:

```text
E  Repair
G  Maintenance
H  Remove
```

The available actions depend on:

* Antenna state.
* Antenna health.
* Ownership.
* Player distance.
* Required items.

---

# NUI

CB Local Radio includes a custom NUI.

Files:

```text
web/
├─ index.html
├─ style.css
└─ app.js
```

The NUI handles:

* Radio interface.
* Frequency input.
* Radio state.
* Signal state.
* Volume control.
* Channel joining.
* Channel leaving.

The resource does not use the `qb-radio` NUI.

---

# Commands

## Open Local Radio

```text
/localradio
```

Opens the CB Local Radio interface.

The command can be changed through:

```lua
Config.Radio.command
```

---

# Default Controls

| Action                       | Default  |
| ---------------------------- | -------- |
| Open radio                   | F7       |
| Radio transmission           | Left ALT |
| Cancel construction/progress | X        |
| Antenna repair               | E        |
| Antenna maintenance          | G        |
| Remove owned antenna         | H        |

The radio transmission key is controlled by **PMA-Voice**, not CB Local Radio.

The PMA-Voice setting is:

```cfg
setr voice_defaultRadio "LMENU"
```

---

# Database

CB Local Radio uses:

```text
oxmysql
```

for persistent server-side data.

Database operations are performed on the server.

The client does not directly access the database.

Antenna state and network-related information are synchronized between server and clients.

---

# Server-Side Validation

Important gameplay operations are validated server-side.

This includes:

* Antenna placement.
* Minimum antenna distance.
* Antenna ownership.
* Item requirements.
* Item removal.
* Item return.
* Repair actions.
* Maintenance actions.
* Antenna state.
* Antenna distance.
* Network synchronization.

Client-side values should not be considered authoritative.

---

# Resource Structure

```text
cb_localradio/
│
├─ fxmanifest.lua
├─ README.md
├─ config.lua
│
├─ client/
│  ├─ bridge.lua
│  ├─ main.lua
│  ├─ antennas.lua
│  ├─ radio.lua
│  └─ placement.lua
│
├─ server/
│  ├─ bridge.lua
│  ├─ main.lua
│  └─ antennas.lua
│
├─ shared/
│  └─ utils.lua
│
└─ web/
   ├─ index.html
   ├─ style.css
   └─ app.js
```

---

# Configuration Reference

Main configuration sections:

```lua
Config.Debug

Config.Items

Config.Antenna

Config.Network

Config.Radio

Config.Blips

Config.Radius

Config.Target

Config.WorldAntennas

Config.Messages
```

---

# Important Configuration

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

## Network

```lua
Config.Network = {
    linkDistance = 1200.0,
    allowChaining = true,
    refreshSeconds = 5,
    playerCheckSeconds = 2
}
```

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

Then verify:

* Resource folder name.
* HateBridge is running.
* oxmysql is running.
* pma-voice is running.
* Required dependencies are started.
* No dependency errors appear in the server console.

---

## Radio Does Not Open

Check:

* The player owns the `radio` item.
* `Config.Items.radio` matches the inventory item.
* HateBridge is running.
* The inventory is correctly configured behind HateBridge.
* `Config.Radio.enabled` is enabled.
* `/localradio` works from the client console.

---

## Radio Says "No Signal"

Check:

* Player position.
* Antenna coverage.
* Antenna health.
* Antenna state.
* Network linking.
* `Config.Network.linkDistance`.
* `Config.Radio.requireSignal`.
* `Config.Radio.usePhysicalCoverage`.

---

## Radio Does Not Transmit

Check:

* PMA-Voice is running.
* `voice_enableRadios` is set to `1`.
* The player has joined a radio frequency.
* The PMA radio channel is not being overridden by another resource.
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

## Radio Animation Does Not Play

Check:

```cfg
setr voice_enableRadioAnim 1
```

Then restart the entire server.

The radio animation is controlled by PMA-Voice.

CB Local Radio does not replace PMA-Voice's radio animation system.

---

## Radio Has No Radio Audio Effects

Check:

```cfg
setr voice_useNativeAudio true
setr voice_enableSubmix 1
```

These settings allow PMA-Voice's native audio/submix functionality to operate.

---

## Antenna Cannot Be Placed

Check:

* Player owns `radio_antenna`.
* Item name is correct.
* Player is not too close to another antenna.
* HateBridge is running.
* Placement system is running.
* Player is not attempting to place the antenna inside an invalid location.

---

## Antenna Is Not Providing Signal

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

## Repair Does Not Work

Check:

```text
radio_repair_kit
```

and:

```lua
Config.Items.repairKit
```

Also verify:

* Player is close enough.
* Antenna is actually broken.
* HateBridge can remove the required item.
* Server-side validation is passing.

---

## Maintenance Does Not Work

Check:

```text
radio_maintenance_kit
```

and:

```lua
Config.Items.maintenanceKit
```

Also verify:

* Antenna is within interaction distance.
* Antenna health allows maintenance.
* Player has the required item.
* HateBridge is correctly connected to the inventory.

---

## NUI Does Not Open

Check:

```text
web/index.html
web/style.css
web/app.js
```

Also verify:

```lua
ui_page 'web/index.html'
```

inside `fxmanifest.lua`.

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

Do not overwrite a customized `config.lua` without checking your existing settings.

---

# Compatibility Notes

CB Local Radio is designed to remain independent from a specific framework or inventory implementation.

The resource communicates with the server abstraction layer through:

```text
HateBridge
```

The inventory itself should be configured through the framework/inventory system supported by HateBridge.

Do not add:

```lua
exports.ox_inventory
```

or another direct inventory implementation to CB Local Radio unless intentionally modifying the architecture.

---

# PMA-Voice Compatibility Notes

CB Local Radio and PMA-Voice have separate responsibilities.

### CB Local Radio

Handles:

```text
Radio item
Frequency
Signal
Coverage
Antenna network
Radio channel assignment
Radio volume
NUI
```

### PMA-Voice

Handles:

```text
Voice transport
Radio push-to-talk
Radio animation
Radio audio
Radio submix
Radio transmission
```

This separation prevents multiple resources from fighting over the same radio controls.

---

# Recommended Server Configuration

A basic configuration should contain:

```cfg
ensure oxmysql
ensure ox_lib

ensure [voice]

ensure hate-bridge
ensure cb_localradio
```

And the PMA-Voice settings:

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

Adjust the resource names if your server uses different folder names.

---

# Testing Checklist

After installation, test the following:

```text
[ ] HateBridge starts successfully
[ ] oxmysql starts successfully
[ ] pma-voice starts successfully
[ ] cb_localradio starts without errors
[ ] Player receives/owns radio item
[ ] F7 opens radio
[ ] Frequency can be selected
[ ] Antenna provides signal
[ ] Radio channel is assigned
[ ] Left ALT transmits
[ ] Radio animation plays
[ ] Radio volume changes
[ ] Leaving coverage removes signal
[ ] Antenna can be constructed
[ ] Antenna can be repaired
[ ] Antenna can be maintained
[ ] Owner can remove antenna
[ ] Antenna networks link correctly
[ ] Chained networks work
[ ] World antennas provide coverage
```

---

# Support Information

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

Screenshots and complete relevant console errors are recommended.

---

# Credits

**CB Studios**

CB Local Radio integrates external dependencies including:

* HateBridge
* oxmysql
* pma-voice

Each external dependency remains subject to its own license and terms.

---

# Links

**Store:**
https://pichirin-cb.tebex.io/

**Documentation:**
https://docs.pichirincb.com/

**Discord Support:**
https://discord.gg/hsx6AvBg5s

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
