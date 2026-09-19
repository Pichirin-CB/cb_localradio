RadioUtils = {}

function RadioUtils.distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function RadioUtils.round(value, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

function RadioUtils.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function RadioUtils.deepcopy(value)
    if type(value) ~= 'table' then return value end
    local result = {}
    for k, v in pairs(value) do
        result[k] = RadioUtils.deepcopy(v)
    end
    return result
end
