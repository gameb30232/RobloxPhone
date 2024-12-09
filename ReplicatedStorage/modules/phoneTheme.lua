local theme = {
    colors = {
        primary = Color3.fromRGB(239, 235, 224),  -- Clay white
        secondary = Color3.fromRGB(46, 193, 126), -- Retro green
        accent = Color3.fromRGB(179, 174, 166),   -- Clay gray
        text = Color3.fromRGB(51, 51, 51),        -- Dark gray
    },
    
    cornerRadius = {
        large = UDim.new(0.15, 0),
        medium = UDim.new(0.1, 0),
        small = UDim.new(0.05, 0),
    },
    
    strokeThickness = {
        large = 3,
        medium = 2,
        small = 1,
    },
    
    -- Animation presets for that stop-motion feel
    animations = {
        bounce = {
            springParams = {
                frequency = 4,
                dampingRatio = 0.7
            },
            duration = 0.4
        },
        pop = {
            springParams = {
                frequency = 5,
                dampingRatio = 0.6
            },
            duration = 0.3
        }
    }
}

return theme 