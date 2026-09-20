RadioUtils = {}

function RadioUtils.distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z

    return math.sqrt(
        dx * dx +
        dy * dy +
        dz * dz
    )
end

function RadioUtils.round(value, decimals)
    local mult = 10 ^ (decimals or 0)

    return math.floor(
        value * mult + 0.5
    ) / mult
end

function RadioUtils.clamp(value, min, max)
    if value < min then
        return min
    end

    if value > max then
        return max
    end

    return value
end

function RadioUtils.deepcopy(value)
    if type(value) ~= 'table' then
        return value
    end

    local result = {}

    for k, v in pairs(value) do
        result[k] = RadioUtils.deepcopy(v)
    end

    return result
end

-- ============================================================
-- LOCALIZATION
-- ============================================================

function RadioUtils.getLocale()
    local locale = Config.Locale or 'en'

    if Config.Locales
        and Config.Locales[locale] then

        return locale
    end

    return 'en'
end

function RadioUtils.locale(key, ...)
    local locale = RadioUtils.getLocale()

    local language = Config.Locales
        and Config.Locales[locale]

    local english = Config.Locales
        and Config.Locales.en

    local value = language
        and language[key]

    if value == nil then
        value = english
            and english[key]
    end

    if value == nil then
        return key
    end

    if select('#', ...) > 0 then
        return string.format(
            value,
            ...
        )
    end

    return value
end

function RadioUtils.localeTable()
    local locale = RadioUtils.getLocale()

    local selected = Config.Locales
        and Config.Locales[locale]

    local english = Config.Locales
        and Config.Locales.en

    local result = {}

    if english then
        for key, value in pairs(english) do
            result[key] = value
        end
    end

    if selected then
        for key, value in pairs(selected) do
            result[key] = value
        end
    end

    return result
end