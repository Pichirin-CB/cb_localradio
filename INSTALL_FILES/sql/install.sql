CREATE TABLE IF NOT EXISTS `cb_localradio_antennas` (
    `id` VARCHAR(64) NOT NULL,
    `type` VARCHAR(16) NOT NULL DEFAULT 'player',
    `owner` VARCHAR(128) NULL,
    `model` VARCHAR(128) NOT NULL,
    `x` DOUBLE NOT NULL,
    `y` DOUBLE NOT NULL,
    `z` DOUBLE NOT NULL,
    `heading` DOUBLE NOT NULL DEFAULT 0,
    `radius` DOUBLE NOT NULL DEFAULT 1000,
    `health` DOUBLE NOT NULL DEFAULT 100,
    `state` VARCHAR(16) NOT NULL DEFAULT 'active',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_maintenance` TIMESTAMP NULL DEFAULT NULL,
    `last_degradation` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_cb_localradio_owner` (`owner`),
    KEY `idx_cb_localradio_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
