# CB Local Radio

Sistema de radio local para servidores FiveM de supervivencia/zombies.

## Concepto

La radio no tiene alcance global. El jugador necesita estar dentro de la cobertura de una red de antenas físicas.

Incluye:

- Antenas construibles con prop físico.
- Antenas vanilla de GTA V registradas como infraestructura.
- Antenas vanilla empiezan rotas.
- Reparación por materiales.
- Mantenimiento periódico.
- Degradación automática.
- Rotura total.
- Retirada de antenas construidas por jugadores.
- Distancia mínima entre antenas.
- Enlaces automáticos entre antenas.
- Redes encadenadas A -> B -> C.
- Cobertura física.
- Blips de estado.
- Radio opcionalmente con círculo de cobertura.
- NUI propia, sin copiar la NUI GPL de qb-radio.
- PMA-Voice para la voz.
- HateBridge para ESX/QBCore/QBox.
- Persistencia con oxmysql.
- Validaciones server-side.

## Dependencias

- hate-bridge
- oxmysql
- pma-voice
- ox_lib recomendado
- ox_inventory recomendado para tu configuración actual

HateBridge detecta ESX, QBCore y QBox.

## Instalación

1. Importa `sql/install.sql`.
2. Copia `cb_localradio` a `resources/[cb]/`.
3. Añade los items de `install/ox_inventory_items.lua` a `ox_inventory/data/items.lua`.
4. En server.cfg:

ensure oxmysql
ensure pma-voice
ensure hate-bridge
ensure ox_inventory
ensure cb_localradio

5. Asegúrate de que pma-voice está funcionando.
6. Reinicia el servidor.

## Radio

Usa:

/localradio

o la tecla F7.

También puedes cambiar:

Config.Radio.command
Config.Radio.key

## Antenas

Usa el item `radio_antenna`.

La colocación se realiza delante del jugador.

- SHIFT + E confirma.
- G cancela.
- Q/E rota.
- La distancia mínima se controla en servidor.

## Reparación

Las antenas del mundo empiezan con:

health = 0
state = broken

El jugador debe utilizar `radio_repair_kit`.

Cuando una antena está funcionando, pierde integridad con el paso del tiempo.

Cuando baja del porcentaje configurado pasa a mantenimiento.

Cuando llega a 0 queda rota y deja de transmitir.

## Enlaces

Dos antenas se enlazan si la distancia entre ellas es menor o igual a:

Config.Network.linkDistance

Los enlaces forman componentes de red.

Ejemplo:

A <-> B <-> C

Aunque A no esté directamente dentro del radio de C, la red sigue existiendo mientras B conecte ambas antenas.

La cobertura para el jugador es la unión de los radios de las antenas activas de esa red.

## Antenas vanilla

Las posiciones incluidas en `Config.WorldAntennas` se basan en objetos de GTA V identificados en dumps de objetos del juego.

El recurso no crea una copia visual de esas torres: utiliza la estructura vanilla existente y coloca su estado lógico encima.

Para agregar más:

{
    id = 'world_custom_01',
    model = 'nombre_del_prop',
    coords = vector3(x, y, z),
    heading = 0.0,
    radius = 1200.0
}

## NUI

La interfaz incluida en `web/` es una implementación propia de CB Local Radio.

No contiene los archivos HTML/CSS/JS del repositorio qb-radio.

Esto evita incorporar su licencia GPL-3.0 al recurso. qb-radio oficial está publicado bajo GPL-3.0.

## Importante

El item `radio` es el que permite abrir la radio.

El sistema utiliza pma-voice para transportar la voz. La cobertura física decide si el jugador puede permanecer conectado a la frecuencia.

No se debe instalar qb-radio junto con CB Local Radio para la misma radio.

## Configuración principal

`config.lua`

Ahí puedes modificar:

- alcance de antenas
- distancia mínima
- distancia de enlace
- degradación
- reparación
- mantenimiento
- blips
- visualización de radios
- frecuencia mínima/máxima
- item names
- antenas vanilla

## Comandos

/localradio
/placeantenna

`/placeantenna` es un comando de respaldo para pruebas y consume el mismo item al confirmar.

## Créditos

CB Studios.

Integra HateBridge como dependencia externa.

HateBridge mantiene su propia licencia y avisos de copyright.
