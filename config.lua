Config = {}

Config.Delivery = {
    Depot = vector4(78.9, 112.4, 79.1, 160.0), -- Example coords
    Vehicle = 'benson',
    Pay = 250,
    Locations = {
        vector3(-58.9, 65.4, 71.2),
        vector3(154.2, -189.2, 54.2),
    }
}

Config.Levels = {
    [1] = { xp = 0, multiplier = 1.0 },
    [2] = { xp = 100, multiplier = 1.1 },
    [3] = { xp = 250, multiplier = 1.25 },
    [4] = { xp = 500, multiplier = 1.5 },
    [5] = { xp = 1000, multiplier = 2.0 }
}
