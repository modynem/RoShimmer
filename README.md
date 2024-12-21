# 🌟 RoShimmer
A highly configurable and feature-rich shimmer effect library for Roblox UI elements.

## ✨ Features

- **Fully Typed:** Complete type safety with Luau type definitions
- **Highly Configurable:** Extensive customization options for all aspects of the shimmer effect
- **Smart Parent Tracking:** Automatically adapts to parent UI corner radius and padding changes
- **Multiple Effects:**
  - Classic shimmer animation
  - Rainbow color cycling
  - Pulse effect
  - Blur effect
  - Glow effect
- **Interactive:** Supports hover interactions and amplification
- **Event System:** Built-in event handlers for animation complete, loop, and start events
- **Performance Optimized:** Efficient rendering and cleanup mechanisms

## 📦 Installation

```lua
local RoShimmer = require(path.to.RoShimmer)
```

## 🚀 Basic Usage

```lua
-- Create a basic shimmer effect
local shimmer = RoShimmer.new(yourGuiObject)
shimmer:Play()

-- Create a customized shimmer effect
local shimmer = RoShimmer.new(yourGuiObject, {
    time = 1.5,
    gradientRotation = 45,
    shimmerColor = Color3.new(1, 1, 1),
    shimmerOpacity = 0.8
})
shimmer:Play()
```

## 🎨 Advanced Configuration

```lua
local config = {
    -- Animation Settings
    time = 1,
    style = Enum.EasingStyle.Linear,
    direction = Enum.EasingDirection.InOut,
    repeatCount = -1,
    reverses = false,
    delayTime = 0,

    -- Gradient Settings
    gradientRotation = 15,
    gradientTransparency = {1, 1, 0.55, 1, 1},
    gradientWidth = 0.35,
    shimmerColor = Color3.new(1, 1, 1),
    shimmerOpacity = 1,

    -- Special Effects
    useRainbowEffect = false,
    rainbowSpeed = 1,
    pulseEffect = false,
    pulseScale = 1.05,
    pulseSpeed = 1,
    blurEffect = false,
    blurSize = 10,
    glowEffect = false,
    glowColor = Color3.new(1, 1, 1),
    glowTransparency = 0.5,
    glowSize = 2,

    -- Behavior
    followParentCorners = true,
    followParentPadding = true,
    reactToHover = false,
    hoverAmplification = 1.2,
    zIndex = 1
}

local shimmer = RoShimmer.new(yourGuiObject, config)
```

## 🎮 Methods

```lua
-- Control Methods
shimmer:Play()      -- Start the animation
shimmer:Pause()     -- Pause the animation
shimmer:Cancel()    -- Stop the animation
shimmer:Destroy()   -- Clean up the shimmer instance

-- Effect Toggles
shimmer:SetBlur(true)           -- Toggle blur effect
shimmer:SetGlow(true)           -- Toggle glow effect
shimmer:ToggleRainbow(true)     -- Toggle rainbow effect
shimmer:SetPulse(true)          -- Toggle pulse effect

-- Configuration
shimmer:UpdateConfig(newConfig)  -- Update configuration at runtime

-- Event Handling
shimmer:AddEventListener("complete", function()
    print("Animation completed!")
end)
```

## 🌈 What Makes This Different?

1. **Smart Parent Tracking**: Unlike other shimmer libraries, this one automatically adapts to parent UI changes, including corner radius and padding adjustments.

2. **Multiple Effect Combinations**: Combine various effects like rainbow cycling, pulsing, blur, and glow to create unique animations.

3. **Interactive Animations**: Support for hover interactions and dynamic amplification of effects.

4. **Type Safety**: Full Luau type definitions for better development experience and error prevention.

5. **Extensive Configuration**: Nearly every aspect of the shimmer effect can be customized, from basic animation parameters to advanced visual effects.

6. **Runtime Updates**: All configurations can be updated during runtime without recreating the shimmer instance.

## 📝 License

MIT License - feel free to use in any Roblox project!

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## Note
RoShimmer is an improved version of https://devforum.roblox.com/t/shime-shimmer-for-guiobjects/2272199 by @WinnersTakesAll!

## 📧 Contact

- Portfolio: https://ahmedsayedv2.vercel.app
- Discord: ahmedsayed0
