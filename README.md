
██████╗ ███████╗ █████╗ ██████╗ ███╗   ███╗███████╗ 
██╔══██╗██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝ 
██████╔╝█████╗  ███████║██║  ██║██╔████╔██║█████╗   
██╔══██╗██╔══╝  ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝   
██║  ██║███████╗██║  ██║██████╔╝██║ ╚═╝ ██║███████╗ 
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝ 
---------------------------------------------------------------------------

# Universal Resource Technical Documentation

Resource Name: `cb_localradio`
Version: `1.0.0`
Author: CB Studios
Type: FiveM Script / Survival Radio Network

---------------------------------------------------------------------------

# Resource Overview

CB Local Radio is a physical local radio network designed for FiveM survival,
zombie and post-apocalyptic servers.

The resource creates a radio communication system where players must have
access to a physical radio and be inside the coverage of an active antenna
network.

Unlike a traditional global radio system, communication is controlled by
physical antenna coverage and network connections.

The resource includes:

* Physical player-built antennas.
* Existing GTA V antenna infrastructure.
* Antenna health and degradation.
* Antenna maintenance.
* Antenna repair.
* Antenna destruction.
* Minimum distance between player-built antennas.
* Automatic antenna network linking.
* Chained networks.
* Physical radio coverage.
* Network-based signal detection.
* Radio frequency management.
* PMA-Voice integration.
* Custom NUI.
* Server-side persistence.
* Server-side validation.
* Framework/inventory abstraction through HateBridge.

---------------------------------------------------------------------------

# Resource Structure

The resource uses the following structure:

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

---------------------------------------------------------------------------

# Installation

## 1. Install the dependencies

Install and configure the required dependencies before starting
`cb_localradio`.

Required:

* FiveM
* HateBridge
* oxmysql
* pma-voice

The resource uses HateBridge as its framework and inventory abstraction.

The resource itself does not directly require a specific inventory resource.

## 2. Install the resource

Place the resource inside your server resources directory.

Example:

```text
resources/[cb]/cb_localradio
```

## 3. Configure the resource

Open:

```text
cb_localradio/config.lua
```

Configure the resource according to your server requirements.

## 4. Start the dependencies

Example:

```cfg
ensure oxmysql
ensure hate-bridge
ensure pma-voice
ensure cb_localradio
```

Make sure the actual resource names match the names used by your server.

## 5. Restart the resource

After configuration:

```text
restart cb_localradio
```

---------------------------------------------------------------------------

# Dependencies

CB Local Radio requires:

### HateBridge

Used as the abstraction layer between CB Local Radio and the server's
framework/inventory implementation.

The resource communicates with the bridge instead of directly depending on a
specific inventory implementation.

### oxmysql

Used for persistent database operations.

### pma-voice

Used for radio voice communication.

### FiveM

Required to run the resource.

---------------------------------------------------------------------------

# Framework and Inventory Compatibility

CB Local Radio is designed around HateBridge.

The resource does not hard-code inventory functionality into the main radio
system.

Inventory operations are routed through the bridge API.

The resource can therefore use the inventory implementation supported by the
installed HateBridge configuration.

The following operations are abstracted through the bridge:

* Item checking.
* Item counting.
* Item removal.
* Item addition.
* Usable item registration.
* Player identification.
* Notifications.
* Progress bars.
* Database operations.

Do not add direct inventory exports to `cb_localradio` unless the resource
architecture is intentionally changed.

---------------------------------------------------------------------------

# Configuration

The main configuration file is:

```text
config.lua
```

The configuration contains the following sections:

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

## Items

Example:

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

These names must match the items registered by the inventory system used by
HateBridge.

---------------------------------------------------------------------------

# Radio System

The radio can be opened using:

```text
/localradio
```

The default key is:

```text
F7
```

These settings can be changed in `config.lua`:

```lua
Config.Radio.command
Config.Radio.key
```

## Frequency Range

The default frequency range is:

```lua
minFrequency = 1
maxFrequency = 500
```

Players can only connect to frequencies within the configured range.

## Signal Requirement

When:

```lua
requireSignal = true
```

players must be inside an active antenna network to join a radio frequency.

## Leaving Coverage

When:

```lua
leaveWhenOutOfCoverage = true
```

the player is automatically removed from the radio channel when they leave
the active network coverage.

---------------------------------------------------------------------------

# Antenna System

CB Local Radio supports two types of antenna infrastructure.

## Player-Built Antennas

Players can construct antennas using:

```text
radio_antenna
```

The construction process is controlled by:

```lua
Config.Antenna.construction
```

The system supports:

* Construction time.
* Construction animation.
* Minimum distance restrictions.
* Removal by the antenna owner.
* Partial item return when removing an antenna.

## World Antennas

Existing GTA V antenna objects can be registered through:

```lua
Config.WorldAntennas
```

These antennas use the existing world structure instead of spawning a
duplicate visual prop.

Each world antenna can have its own:

* ID.
* Model.
* Coordinates.
* Heading.
* Coverage radius.

---------------------------------------------------------------------------

# Antenna Health

Antennas have a health/integrity value.

The configuration supports:

```lua
Config.Antenna.degradation
```

Health can decrease automatically over time.

Example:

```lua
degradation = {
    enabled = true,
    intervalMinutes = 60,
    amount = 5.0,
    minimumHealthBeforeMaintenance = 95.0
}
```

When an antenna reaches the configured broken threshold, it stops providing
radio coverage.

---------------------------------------------------------------------------

# Antenna Repair

Broken antennas can be repaired using:

```text
radio_repair_kit
```

The repair amount is configured with:

```lua
Config.Antenna.repair.health
```

The repair action also supports:

* Progress duration.
* Repair animation.
* Server-side validation.

---------------------------------------------------------------------------

# Antenna Maintenance

Active antennas require maintenance according to the configured degradation
system.

Maintenance uses:

```text
radio_maintenance_kit
```

The amount restored is configured with:

```lua
Config.Antenna.maintenance.health
```

---------------------------------------------------------------------------

# Antenna Network

Antennas can automatically connect to nearby antennas.

The maximum connection distance is:

```lua
Config.Network.linkDistance
```

Example:

```lua
linkDistance = 1200.0
```

When chaining is enabled:

```lua
allowChaining = true
```

networks can operate as chained systems.

Example:

```text
A <----> B <----> C
```

A does not need to have a direct connection to C.

As long as B connects both sides, the antennas can form part of the same
network.

---------------------------------------------------------------------------

# Physical Coverage

Radio signal is determined by active antenna coverage.

The player position is checked against the coverage areas belonging to the
active antenna network.

Example:

```text
        ANTENNA A
        /        \
       /          \
 PLAYER            ANTENNA B
       \          /
        \        /
        NETWORK
```

If the player leaves the active network coverage, the radio system can remove
the player from the active channel depending on:

```lua
Config.Radio.leaveWhenOutOfCoverage
```

---------------------------------------------------------------------------

# Blips

Antenna blips can be enabled through:

```lua
Config.Blips.enabled
```

The configuration can separately control:

```lua
Config.Blips.showWorldAntennas
Config.Blips.showPlayerAntennas
```

Different colors can be assigned to antenna states:

```lua
colors = {
    active = 2,
    maintenance = 17,
    broken = 1,
    offline = 40
}
```

---------------------------------------------------------------------------

# Coverage Visualization

Coverage visualization can be enabled through:

```lua
Config.Radius.enabled
```

When enabled, the resource can display configured antenna coverage areas.

The display distance can be changed with:

```lua
Config.Radius.drawDistance
```

---------------------------------------------------------------------------

# PMA-Voice Integration

CB Local Radio uses pma-voice for radio voice communication.

The resource controls the PMA radio channel according to the local radio
network state.

The radio system can:

* Set the radio channel.
* Remove the player from the channel.
* Change radio volume.
* Prevent channel access without signal.
* Remove the player from the channel after leaving coverage.

pma-voice must be running correctly on the server.

---------------------------------------------------------------------------

# NUI

CB Local Radio includes its own NUI.

Files:

```text
web/index.html
web/style.css
web/app.js
```

The NUI handles the radio interface and communicates with the client Lua
system through FiveM NUI callbacks.

The resource does not require the qb-radio NUI.

---------------------------------------------------------------------------

# Commands

## Open Radio

```text
/localradio
```

Opens the local radio interface.

## Keybind

Default:

```text
F7
```

The key can be changed through:

```lua
Config.Radio.key
```

---------------------------------------------------------------------------

# Item Requirements

The default item configuration is:

```text
radio
radio_antenna
radio_repair_kit
radio_maintenance_kit
radio_cable
electronic_parts
scrap_metal
```

The actual inventory implementation is handled through HateBridge.

The items must therefore exist in the inventory system configured behind the
bridge.

---------------------------------------------------------------------------

# Server Validation

Important gameplay operations are validated server-side.

This includes functionality such as:

* Antenna construction.
* Antenna distance restrictions.
* Antenna ownership.
* Item requirements.
* Item removal.
* Item returns.
* Antenna state.
* Network state.
* Persistence.

Client-side values should not be considered authoritative.

---------------------------------------------------------------------------

# Database

CB Local Radio uses oxmysql for database communication.

Database operations are accessed through the server bridge layer.

The resource does not require direct database calls from client scripts.

---------------------------------------------------------------------------

# Troubleshooting

## Resource does not start

Check:

* `fxmanifest.lua`.
* Resource folder name.
* Server console errors.
* HateBridge startup.
* oxmysql startup.
* pma-voice startup.

Verify that the required resources are started before:

```text
cb_localradio
```

## Radio does not open

Check:

* The `radio` item exists.
* The item name matches `Config.Items.radio`.
* HateBridge is running.
* HateBridge can access the configured inventory.
* The player actually has the radio item.

## Radio says there is no signal

Check:

* The player is inside antenna coverage.
* The antenna is active.
* The antenna health is above the broken threshold.
* The antenna is correctly registered.
* The antenna network is being generated.
* `Config.Radio.requireSignal` is enabled or disabled as intended.

## Radio does not transmit voice

Check:

* pma-voice is running.
* The player can normally use pma-voice.
* The radio channel is being assigned.
* No other resource is overriding the PMA radio channel.

## Antenna cannot be placed

Check:

* The player has `radio_antenna`.
* The item name matches `Config.Items.antennaKit`.
* The player is not inside the minimum distance restriction.
* HateBridge is running.
* The placement resource is running correctly.

## Antenna is not providing signal

Check:

* Antenna health.
* Network linking distance.
* Antenna state.
* Network refresh interval.
* Player position.
* World antenna configuration.

## NUI does not open

Check:

* `web/index.html`
* `web/style.css`
* `web/app.js`
* `ui_page` in `fxmanifest.lua`.
* NUI errors in the FiveM client console.

---------------------------------------------------------------------------

# Updating the Resource

Before updating:

1. Stop `cb_localradio`.
2. Create a backup of the current resource.
3. Replace the resource files.
4. Compare the new `config.lua` with the previous configuration.
5. Verify item names.
6. Verify HateBridge configuration.
7. Restart the resource.

Do not overwrite custom configuration blindly when updating.

---------------------------------------------------------------------------

# Technical Notes

CB Local Radio is designed around a bridge-based architecture.

The resource should communicate with the server's framework and inventory
through HateBridge rather than directly depending on a specific framework or
inventory implementation.

Avoid adding direct inventory exports to the resource unless the bridge
architecture is intentionally being changed.

The resource also depends on PMA-Voice for voice transport.

The local radio network itself determines whether a player has access to the
radio channel.

Do not install another radio resource that controls the same PMA radio
channels without understanding the interaction between both resources.

---------------------------------------------------------------------------

# Support

When requesting support, provide:

```text
Resource Name:
CB Local Radio

Version:
1.0.0

Server Build:

Framework:

Inventory:

HateBridge Version:

pma-voice Version:

Error Logs:

Description of the Issue:
```

Screenshots and relevant console logs are recommended when reporting UI or
gameplay issues.

 ██████╗██████╗     ███████╗████████╗██╗   ██╗██████╗ ██╗ ██████╗ ███████╗ 
██╔════╝██╔══██╗    ██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║██╔═══██╗██╔════╝ 
██║     ██████╔╝    ███████╗   ██║   ██║   ██║██║  ██║██║██║   ██║███████╗ 
██║     ██╔══██╗    ╚════██║   ██║   ██║   ██║██║  ██║██║██║   ██║╚════██║ 
╚██████╗██████╔╝    ███████║   ██║   ╚██████╔╝██████╔╝██║╚██████╔╝███████║ 
 ╚═════╝╚═════╝     ╚══════╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝ ╚══════╝ 

Store -> https://pichirin-cb.tebex.io/
Documentation -> https://docs.pichirincb.com
Support Discord -> https://discord.gg/hsx6AvBg5s  

---------------------------------------------------------------------------

# Credits

CB Studios

CB Local Radio integrates external dependencies including HateBridge,
oxmysql and pma-voice.

Each external dependency remains subject to its own license and terms.

---------------------------------------------------------------------------

End of documentation
