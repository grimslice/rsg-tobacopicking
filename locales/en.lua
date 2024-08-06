local Translations = {
    error = {
        no_plant_nearby = 'No tobacco plant nearby',
    },
    progress = {
        picking_tobacco = 'Picking Tobacco...',
    },
    success = {
        tobacco_picked = 'You picked some tobacco',
    },
    target = {
        pick_tobacco = 'Pick Tobacco',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})