# CB Local Radio

**Physical Radio Network for FiveM Survival Servers**

CB Local Radio is a survival-oriented radio network designed around physical infrastructure.

Players need a radio, access to an active antenna network, and valid coverage before they can communicate through the radio system.

The resource is designed for survival, zombie, post-apocalyptic and infrastructure-focused FiveM servers.

---

## Overview

CB Local Radio combines:

- Physical radio items
- Configurable radio frequencies
- Antenna infrastructure
- Signal coverage
- Antenna networks
- Network chaining
- Antenna degradation
- Repair and maintenance
- Persistent antenna storage
- Custom radio NUI
- PMA-Voice integration
- Framework and inventory abstraction through HateBridge

The resource separates **radio infrastructure** from **voice transmission**.

CB Local Radio manages the radio network.

PMA-Voice manages the actual voice communication.

---

## Features

### Radio

- Physical radio item
- Configurable frequency range
- Signal-based radio access
- Automatic loss of radio channel outside coverage
- Adjustable radio volume
- Custom NUI
- PMA-Voice channel integration
- Server-side channel handling

### Antennas

- Player-built antennas
- World antennas
- Configurable coverage radius
- Antenna ownership
- Antenna health
- Automatic degradation
- Repair system
- Maintenance system
- Broken antenna state
- Antenna removal
- Optional antenna-kit recovery

### Radio Networks

- Automatic antenna linking
- Configurable connection distance
- Network chaining
- Persistent antenna infrastructure
- Physical coverage detection
- Server-side network synchronization

### Infrastructure

- oxmysql persistence
- HateBridge integration
- Inventory abstraction
- Framework abstraction
- Direct proximity interaction
- Custom NUI
- Included inventory item definitions
- Included inventory icons
- Included SQL installer

---

# Requirements

The following resources are required:

| Dependency | Purpose |
| --- | --- |
| `hate-bridge` | Framework and inventory abstraction |
| `oxmysql` | Persistent antenna storage |
| `pma-voice` | Radio voice communication |

`ox_lib` is recommended for environments that use it as part of their server infrastructure.

---

# Installation

## 1. Install Dependencies

Install and configure:

- HateBridge
- oxmysql
- PMA-Voice

### HateBridge

Repository:

https://github.com/HATE-dev/hate-bridge

Documentation:

https://hate-development.gitbook.io/hate-development-docs/hate-framework-bridge

### PMA-Voice

Repository:

https://github.com/AvarianKnight/pma-voice

---

## 2. Install CB Local Radio

Place the resource inside your FiveM resources directory.

Example:

```text
resources/
└── [cb]/
    └── cb_localradio/
````

---

## 3. Install the Database

Run:

```text
INSTALL_FILES/sql/install.sql
```

This creates the database table required for persistent player antennas.

Database table:

```text
cb_localradio_antennas
```

---

## 4. Install Inventory Items

The resource includes item definitions for:

* ox_inventory
* Core Inventory

### ox_inventory

Use:

```text
INSTALL_FILES/ox_inventory_items.lua
```

### Core Inventory

Use:

```text
INSTALL_FILES/core_inventory_items.lua
```

The item names used by the resource are:

| Item                    | Purpose                    |
| ----------------------- | -------------------------- |
| `radio`                 | Portable radio             |
| `radio_antenna`         | Antenna construction kit   |
| `radio_repair_kit`      | Repairs broken antennas    |
| `radio_maintenance_kit` | Maintains damaged antennas |
| `radio_cable`           | Configured material        |
| `scrap_metal`           | Configured material        |
| `electronic_parts`      | Configured material        |

The additional material items are available for future crafting, scavenging or server-specific integrations.

---

## 5. Install Inventory Icons

Inventory icons are included in:

```text
INSTALL_FILES/inventory_icon/
```

Included icons:

```text
electronic_parts.png
radio.png
radio_antenna.png
radio_cable.png
radio_maintenance_kit.png
radio_repair_kit.png
scrap_metal.png
```

---

## 6. Configure the Resource

Main configuration file:

```text
config.lua
```

The configuration is divided into:

```text
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

## 7. Start the Resources

Recommended order:

```cfg
ensure oxmysql
ensure pma-voice
ensure hate-bridge
ensure cb_localradio
```

If your server uses `ox_lib`, start it before resources that require it.

---

# PMA-Voice Integration

CB Local Radio uses PMA-Voice as the voice transport layer.

### CB Local Radio handles

* Radio item
* Frequencies
* Signal
* Antenna coverage
* Antenna networks
* Channel assignment
* Radio volume
* Radio interface

### PMA-Voice handles

* Radio transmission
* Push-to-talk
* Voice transport
* Radio animation
* Radio audio
* Radio submix

This separation prevents multiple resources from attempting to control the same radio transmission system.

---

## Radio Push-to-Talk

Radio PTT is handled by PMA-Voice.

CB Local Radio does **not** register its own radio-talk key.

The resource intentionally does not use:

```lua
Config.Radio.talkKey
```

Configure the radio key through PMA-Voice.

Example:

```cfg
setr voice_defaultRadio "LMENU"
```

The exact key can be changed according to your PMA-Voice configuration.

---

# Using the Radio

## Opening the Radio

Default command:

```text
/localradio
```

Default key:

```text
F7
```

Both can be changed through:

```text
config.lua
```

---

## Connecting to a Frequency

The player must:

1. Own a radio.
2. Have active signal coverage.
3. Select a valid frequency.
4. Connect to the frequency.

Once connected, PMA-Voice handles the radio transmission.

---

## Radio Frequencies

The default frequency range is:

```text
1 - 500
```

This range can be changed through the radio configuration.

---

## Radio Signal

Radio access can require physical antenna coverage.

When signal is enabled:

```text
Inside coverage
    ↓
Radio available

Outside coverage
    ↓
Signal lost
```

The resource can automatically remove the player from the radio channel when they leave active coverage.

---

# Antenna System

CB Local Radio supports two antenna types.

## Player Antennas

Player antennas are constructed using:

```text
radio_antenna
```

Player antennas are persistent and stored in the database.

They support:

* Placement
* Ownership
* Coverage
* Health
* Degradation
* Repair
* Maintenance
* Removal
* Optional item recovery

---

## World Antennas

World antennas are predefined antenna locations configured in:

```text
Config.WorldAntennas
```

These can represent:

* Radio towers
* Communication towers
* Mobile antenna masts
* Existing GTA infrastructure

World antennas do not require players to construct them.

---

# Antenna Coverage

Each antenna has a configurable coverage radius.

The default player antenna radius is:

```text
1000 meters
```

World antennas can use individual coverage values.

Coverage is calculated from the player's physical position.

---

# Antenna Networks

Antennas can automatically connect when they are within the configured network distance.

Default network link distance:

```text
1200 meters
```

Example:

```text
A ───── B ───── C
```

When network chaining is enabled, antenna B can connect the network between A and C.

This allows radio infrastructure to cover larger areas without requiring every antenna to directly reach every other antenna.

---

# Antenna Health

Player antennas have a health value.

Antennas can:

* Operate normally
* Require maintenance
* Become broken

Health degradation can be enabled or disabled through the configuration.

Default degradation:

```text
Every 60 minutes
-5 health
```

---

# Repair

A completely broken antenna can be repaired using:

```text
radio_repair_kit
```

The repair system includes:

* Progress handling
* Animation
* Distance validation
* Item validation
* Server-side validation

---

# Maintenance

Damaged antennas can be maintained using:

```text
radio_maintenance_kit
```

Maintenance restores antenna health without requiring the antenna to become completely broken first.

---

# Antenna Removal

Player-owned antennas can be removed.

The server validates:

* Ownership
* Antenna existence
* Player distance
* Antenna type

When enabled, the resource can return the antenna kit after removal.

The return system uses a configurable probability.

Default:

```text
75%
```

This means the player has a 75% chance of recovering the `radio_antenna` item.

---

# Inventory Integration

CB Local Radio does not directly depend on a specific inventory implementation.

Inventory operations are abstracted through HateBridge.

This allows the resource to work with different inventory systems without adding direct inventory exports throughout the resource.

The resource should not be modified to add direct calls such as:

```lua
exports.ox_inventory
```

unless the integration architecture is intentionally changed.

---

# Framework Integration

Framework-specific functionality is handled through HateBridge.

CB Local Radio itself does not directly implement framework-specific gameplay logic.

This keeps the resource separated from:

* ESX
* QBCore
* Other supported HateBridge environments

---

# Interaction System

CB Local Radio uses direct proximity interaction.

It does not require:

```text
ox_target
qb-target
qtarget
```

Players interact with antennas based on their distance and the current antenna state.

---

# NUI

CB Local Radio includes a custom radio interface.

Files:

```text
web/
├── index.html
├── style.css
└── app.js
```

The interface provides:

* Current frequency
* Signal status
* Radio state
* Frequency selection
* Volume control
* Channel connection
* Channel disconnection

---

# Database

CB Local Radio uses `oxmysql` for persistent antenna storage.

Table:

```text
cb_localradio_antennas
```

Persistent information includes antenna data such as:

* Identifier
* Type
* Owner
* Model
* Coordinates
* Heading
* Radius
* Health
* State
* Maintenance information
* Degradation information

The database is accessed server-side.

---

# Blips

Antenna blips can be enabled through:

```text
Config.Blips
```

The resource supports separate visibility for:

* World antennas
* Player antennas

Blip colors can represent antenna states such as:

```text
Active
Maintenance
Broken
Offline
```

---

# Coverage Visualization

Optional antenna coverage visualization is available through:

```text
Config.Radius
```

It is disabled by default.

When enabled, the system can visualize the approximate coverage radius of antennas.

---

# Configuration

The main configuration file is:

```text
config.lua
```

### Radio

Controls:

* Enable/disable radio
* Command
* Open key
* Minimum frequency
* Maximum frequency
* Default volume
* Signal requirement
* Automatic channel removal outside coverage
* Physical coverage

### Antenna

Controls:

* Default radius
* Minimum distance
* Health degradation
* Player antenna model
* Interaction distance
* Construction
* Repair
* Maintenance

### Network

Controls:

* Link distance
* Network chaining
* Network refresh
* Player signal checks

### Blips

Controls:

* Blip visibility
* World antenna visibility
* Player antenna visibility
* Blip appearance
* State colors

### Radius

Controls:

* Coverage visualization
* Draw distance
* Visualization colors

### World Antennas

Controls:

* Antenna model
* Position
* Heading
* Coverage radius

---

# Resource Structure

```text
cb_localradio/
│
├── fxmanifest.lua
├── config.lua
├── README.md
│
├── INSTALL_FILES/
│   ├── core_inventory_items.lua
│   ├── ox_inventory_items.lua
│   │
│   ├── inventory_icon/
│   │   ├── electronic_parts.png
│   │   ├── radio.png
│   │   ├── radio_antenna.png
│   │   ├── radio_cable.png
│   │   ├── radio_maintenance_kit.png
│   │   ├── radio_repair_kit.png
│   │   └── scrap_metal.png
│   │
│   └── sql/
│       └── install.sql
│
├── client/
│   ├── antennas.lua
│   ├── bridge.lua
│   ├── main.lua
│   ├── placement.lua
│   └── radio.lua
│
├── server/
│   ├── antennas.lua
│   ├── bridge.lua
│   └── main.lua
│
├── shared/
│   └── utils.lua
│
└── web/
    ├── app.js
    ├── index.html
    └── style.css
```

---

# Troubleshooting

## Radio Does Not Open

Check:

* The `radio` item exists in your inventory.
* `Config.Items.radio` matches the registered item name.
* HateBridge is running.
* `Config.Radio.enabled` is enabled.
* `/localradio` works.
* F7 is not being used by another resource.

---

## No Radio Signal

Check:

* Player position.
* Active antenna coverage.
* Antenna health.
* Antenna state.
* Network links.
* Network link distance.
* Network chaining.
* Physical coverage settings.

---

## Radio Does Not Transmit

Check:

* PMA-Voice is running.
* Radio support is enabled in PMA-Voice.
* The player is connected to a frequency.
* The player has active signal.
* No other resource is overriding the PMA-Voice radio channel.
* The configured PMA-Voice radio key is correct.

---

## Antenna Cannot Be Built

Check:

* Player owns `radio_antenna`.
* HateBridge is running.
* Player is not inside the minimum antenna distance.
* Placement is not being cancelled.
* Server-side validation is not rejecting the installation.

---

## Antenna Cannot Be Repaired

Check:

* The antenna is actually broken.
* Player owns `radio_repair_kit`.
* Player is close enough.
* HateBridge is running.
* The antenna exists in the database.

---

## Antenna Cannot Be Maintained

Check:

* The antenna is below the maintenance threshold.
* Player owns `radio_maintenance_kit`.
* Player is close enough.
* HateBridge is running.

---

## Antennas Are Not Linking

Check:

* `Config.Network.linkDistance`
* `Config.Network.allowChaining`
* Antenna state
* Antenna health
* Network refresh interval

Remember that broken antennas do not provide active coverage.

---

## Database Errors

Check:

* `oxmysql` is started.
* `INSTALL_FILES/sql/install.sql` was imported.
* The database connection is working.
* The `cb_localradio_antennas` table exists.

---

# Recommended Installation Checklist

```text
[ ] oxmysql installed
[ ] pma-voice installed
[ ] hate-bridge installed
[ ] cb_localradio installed

[ ] SQL imported
[ ] Radio item registered
[ ] Antenna item registered
[ ] Repair kit registered
[ ] Maintenance kit registered
[ ] Inventory icons installed

[ ] PMA-Voice radio enabled
[ ] PMA-Voice PTT configured
[ ] CB Local Radio started

[ ] Radio opens
[ ] Frequency can be selected
[ ] Signal works
[ ] Radio transmission works

[ ] Antenna can be built
[ ] Antenna coverage works
[ ] Antenna networks work
[ ] Repair works
[ ] Maintenance works
[ ] Antenna removal works
[ ] Database persistence works
```

---

# Credits

## CB Studios

CB Local Radio is developed and maintained by **CB Studios**.

### External Dependencies

**HateBridge**

https://github.com/HATE-dev/hate-bridge

**PMA-Voice**

https://github.com/AvarianKnight/pma-voice

**oxmysql**

https://github.com/overextended/oxmysql

Each external dependency remains subject to its respective license and terms.

---

# Support

When reporting an issue, provide:

```text
CB Local Radio version:
FiveM server build:
Framework:
Inventory:
HateBridge version:
PMA-Voice version:
oxmysql version:

Server console error:
Client console error:

Description:
```

Always provide the complete error message when possible.

---

# CB Studios

**Store**
https://pichirin-cb.tebex.io/

**Documentation**
https://docs.pichirincb.com/

**Discord**
https://discord.gg/hsx6AvBg5s

---

# License

CB Local Radio is released under the MIT License.

See the `LICENSE` file included with the resource for the complete license text.

---

**CB Studios — Build the network. Keep the signal alive.**
