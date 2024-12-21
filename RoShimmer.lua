--[[
    THIS SCRIPT MADE BY ^
    
             _                              _ 
     /\     | |                            | |
    /  \    | |__    _ __ ___     ___    __| |
   / /\ \   | '_ \  | '_ ` _ \   / _ \  / _` |
  / ____ \  | | | | | | | | | | |  __/ | (_| |
 /_/    \_\ |_| |_| |_| |_| |_|  \___|  \__,_|
                                              
    Back-end Engineer & Game Dev on Roblox!
    
    Portfolio: https://ahmedsayedv2.vercel.app
    Discord Username: ahmedsayed0
]]--

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

export type ShimmerConfig = {
	-- Basic Configuration
	time: number?,
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?,
	repeatCount: number?,
	reverses: boolean?,
	delayTime: number?,

	-- Gradient Configuration
	gradientRotation: number?,
	gradientTransparency: {number}?,
	gradientWidth: number?,
	shimmerColor: Color3 | ColorSequence?,
	shimmerOpacity: number?,

	-- Advanced Features
	multiColorShimmer: boolean?,
	colorKeypoints: {ColorSequenceKeypoint}?,
	useRainbowEffect: boolean?,
	rainbowSpeed: number?,

	-- Animation Options
	useCustomAnimation: boolean?,
	customEasingFunction: ((time: number) -> number)?,
	pulseEffect: boolean?,
	pulseScale: number?,
	pulseSpeed: number?,

	-- Visual Effects
	blurEffect: boolean?,
	blurSize: number?,
	glowEffect: boolean?,
	glowColor: Color3?,
	glowTransparency: number?,
	glowSize: number?,

	-- Behavior
	followParentCorners: boolean?,
	followParentPadding: boolean?,
	reactToHover: boolean?,
	hoverAmplification: number?,
	zIndex: number?,

	-- Events
	onComplete: (() -> ())?,
	onLoop: (() -> ())?,
	onStart: (() -> ())?
}

-- Create a type for frame references
type Frame = Instance
type UIGradient = Instance
type UICorner = Instance
type BlurEffect = Instance
type UIStroke = Instance
type Tween = Instance
type RBXScriptConnection = {
	Disconnect: (self: RBXScriptConnection) -> ()
}

export type ShimmerInstance = {
	_frame: Frame,
	_gradient: UIGradient,
	_corner: UICorner?,
	_blur: BlurEffect?,
	_glow: UIStroke?,
	_tween: Tween,
	_config: ShimmerConfig,
	_connections: {RBXScriptConnection},
	_isHovered: boolean,
	PlaybackState: Enum.PlaybackState?,

	-- Public Methods
	GetFrame: (self: ShimmerInstance) -> Frame,
	GetGradient: (self: ShimmerInstance) -> UIGradient,
	GetCorner: (self: ShimmerInstance) -> UICorner?,
	GetConfig: (self: ShimmerInstance) -> ShimmerConfig,
	Play: (self: ShimmerInstance) -> (),
	Pause: (self: ShimmerInstance) -> (),
	Cancel: (self: ShimmerInstance) -> (),
	Destroy: (self: ShimmerInstance) -> (),
	UpdateConfig: (self: ShimmerInstance, newConfig: ShimmerConfig) -> (),

	-- New Public Methods
	SetBlur: (self: ShimmerInstance, enabled: boolean) -> (),
	SetGlow: (self: ShimmerInstance, enabled: boolean) -> (),
	ToggleRainbow: (self: ShimmerInstance, enabled: boolean) -> (),
	SetPulse: (self: ShimmerInstance, enabled: boolean) -> (),
	AddEventListener: (self: ShimmerInstance, eventName: string, callback: () -> ()) -> RBXScriptConnection
}

-- Default configuration with new options
local DEFAULT_CONFIG: ShimmerConfig = {
	-- Basic Configuration
	time = 1,
	style = Enum.EasingStyle.Linear,
	direction = Enum.EasingDirection.InOut,
	repeatCount = -1,
	reverses = false,
	delayTime = 0,

	-- Gradient Configuration
	gradientRotation = 15,
	gradientTransparency = {1, 1, 0.55, 1, 1},
	gradientWidth = 0.35,
	shimmerColor = Color3.new(1, 1, 1),
	shimmerOpacity = 1,

	-- Advanced Features
	multiColorShimmer = false,
	colorKeypoints = {
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 230, 230)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
	},
	useRainbowEffect = false,
	rainbowSpeed = 1,

	-- Animation Options
	useCustomAnimation = false,
	customEasingFunction = nil,
	pulseEffect = false,
	pulseScale = 1.05,
	pulseSpeed = 1,

	-- Visual Effects
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
	zIndex = 1,

	-- Events
	onComplete = nil,
	onLoop = nil,
	onStart = nil
}

local Shimmer = {}
Shimmer.__index = Shimmer

-- Utility Functions
local function createNumberSequence(transparencyPoints: {number}): NumberSequence
	local sequence = {}
	local pointCount = #transparencyPoints
	local step = 1 / (pointCount - 1)

	for i, transparency in ipairs(transparencyPoints) do
		table.insert(sequence, NumberSequenceKeypoint.new((i - 1) * step, transparency))
	end

	return NumberSequence.new(sequence)
end

local function lerpColor(color1: Color3, color2: Color3, alpha: number): Color3
	return Color3.new(
		color1.R + (color2.R - color1.R) * alpha,
		color1.G + (color2.G - color1.G) * alpha,
		color1.B + (color2.B - color1.B) * alpha
	)
end

local function createRainbowColor(time: number): ColorSequence
	local hue = time % 1
	local color = Color3.fromHSV(hue, 1, 1)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue + 0.3) % 1, 1, 1)),
		ColorSequenceKeypoint.new(1, color)
	})
end

local function createShimmer(parent: GuiObject, config: ShimmerConfig): Frame
	local frame = Instance.new("Frame")
	frame.Name = "UIShimmer"

	-- Handle shimmer color
	if typeof(config.shimmerColor) == "Color3" then
		frame.BackgroundColor3 = config.shimmerColor :: Color3
	else
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
	end

	-- Handle opacity
	frame.BackgroundTransparency = if config.shimmerOpacity then 1 - config.shimmerOpacity else 0

	-- Basic frame properties
	frame.ClipsDescendants = true
	frame.Size = UDim2.fromScale(1, 1)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.BorderSizePixel = 0
	frame.ZIndex = config.zIndex or 1
	frame.Visible = false
	frame.Parent = parent

	-- Create gradient
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = config.gradientRotation or 15

	-- Handle gradient color
	if typeof(config.shimmerColor) == "ColorSequence" then
		gradient.Color = config.shimmerColor :: ColorSequence
	else
		gradient.Color = ColorSequence.new(config.shimmerColor or Color3.new(1, 1, 1))
	end

	-- Handle gradient transparency
	if config.gradientTransparency then
		gradient.Transparency = createNumberSequence(config.gradientTransparency)
	else
		gradient.Transparency = createNumberSequence({1, 1, 0.55, 1, 1})
	end

	-- Handle gradient offset
	gradient.Offset = Vector2.new(-1 - (config.gradientWidth or 0.35), 0)
	gradient.Parent = frame

	-- Add Blur Effect if enabled
	if config.blurEffect then
		local blur = Instance.new("BlurEffect")
		blur.Size = config.blurSize or 10
		blur.Parent = frame
	end

	-- Add Glow Effect if enabled
	if config.glowEffect then
		local glow = Instance.new("UIStroke")
		glow.Color = config.glowColor or Color3.new(1, 1, 1)
		glow.Transparency = config.glowTransparency or 0.5
		glow.Thickness = config.glowSize or 2
		glow.Parent = frame
	end

	return frame
end

function Shimmer.new(parent: GuiObject, config: ShimmerConfig?): ShimmerInstance
	assert(typeof(parent) == "Instance" and parent:IsA("GuiObject"), "Invalid parent argument. Expected GuiObject.")

	local self = setmetatable({} :: ShimmerInstance, Shimmer)
	self._config = table.clone(DEFAULT_CONFIG)
	self._connections = {}
	self._isHovered = false

	-- Merge provided config with defaults
	if config then
		for key, value in pairs(config) do
			self._config[key] = value
		end
	end

	local shimmer = createShimmer(parent, self._config)
	self._frame = shimmer
	self._gradient = shimmer:FindFirstChildOfClass("UIGradient")
	self._corner = shimmer:FindFirstChildOfClass("UICorner")
	self._blur = shimmer:FindFirstChildOfClass("BlurEffect")
	self._glow = shimmer:FindFirstChildOfClass("UIStroke")

	self:_createTween()
	self:_setupEffects()
	self:_setupEventHandlers()

	return self
end

function Shimmer:_setupEffects()
	-- Initialize PlaybackState if not already set
	self.PlaybackState = self.PlaybackState or Enum.PlaybackState.Cancelled

	-- Clear existing connections for this section
	for _, connection in ipairs(self._connections) do
		if connection["Connected"] then
			connection:Disconnect()
		end
	end
	table.clear(self._connections)

	-- Setup Rainbow Effect
	if self._config.useRainbowEffect and self._gradient then
		local rainbowConnection = RunService.Heartbeat:Connect(function(deltaTime)
			if self._gradient and self.PlaybackState == Enum.PlaybackState.Playing then
				pcall(function()
					self._gradient.Color = createRainbowColor(os.clock() * (self._config.rainbowSpeed or 1))
				end)
			end
		end)
		table.insert(self._connections, rainbowConnection)
	end

	-- Setup Pulse Effect
	if self._config.pulseEffect and self._frame then
		local pulseConnection = RunService.Heartbeat:Connect(function(deltaTime)
			if self._frame and self.PlaybackState == Enum.PlaybackState.Playing then
				pcall(function()
					local speed = self._config.pulseSpeed or 1
					local scale = self._config.pulseScale or 1.05
					local pulseFactor = 1 + math.sin(os.clock() * speed) * (scale - 1)
					self._frame.Size = UDim2.fromScale(pulseFactor, pulseFactor)
				end)
			end
		end)
		table.insert(self._connections, pulseConnection)
	end

	-- Setup Hover Effect
	if self._config.reactToHover and self._frame and self._gradient then
		local function onHover()
			if not self._frame or not self._gradient then return end

			self._isHovered = true
			if self.PlaybackState == Enum.PlaybackState.Playing then
				pcall(function()
					local amp = self._config.hoverAmplification or 1.2
					self._gradient.Transparency = createNumberSequence({
						1, 1, 0.55 * amp, 1, 1
					})
				end)
			end
		end

		local function onHoverEnd()
			if not self._frame or not self._gradient then return end

			self._isHovered = false
			if self.PlaybackState == Enum.PlaybackState.Playing then
				pcall(function()
					self._gradient.Transparency = createNumberSequence(
						self._config.gradientTransparency or {1, 1, 0.55, 1, 1}
					)
				end)
			end
		end

		-- Connect hover events with error handling
		local enterConnection = self._frame.MouseEnter:Connect(function()
			pcall(onHover)
		end)
		local leaveConnection = self._frame.MouseLeave:Connect(function()
			pcall(onHoverEnd)
		end)

		table.insert(self._connections, enterConnection)
		table.insert(self._connections, leaveConnection)
	end
end

function Shimmer:_setupEventHandlers()
	if not self._frame or not self._frame.Parent then return end

	-- Handle corner radius updates
	if self._config.followParentCorners then
		local function updateCornerRadius()
			if not self._frame.Parent then return end

			local parentCorner = self._frame.Parent:FindFirstChildOfClass("UICorner")
			if parentCorner then
				if not self._corner then
					self._corner = Instance.new("UICorner")
					self._corner.Parent = self._frame
				end
				self._corner.CornerRadius = parentCorner.CornerRadius
			elseif self._corner then
				self._corner:Destroy()
				self._corner = nil
			end
		end

		local cornerAddedConnection = self._frame.Parent.ChildAdded:Connect(function(child)
			if child:IsA("UICorner") then
				updateCornerRadius()
			end
		end)

		local cornerRemovedConnection = self._frame.Parent.ChildRemoved:Connect(function(child)
			if child:IsA("UICorner") then
				updateCornerRadius()
			end
		end)

		table.insert(self._connections, cornerAddedConnection)
		table.insert(self._connections, cornerRemovedConnection)
		updateCornerRadius()
	end

	-- Handle padding updates
	if self._config.followParentPadding then
		local function updatePadding()
			if not self._frame.Parent then return end

			local padding = self._frame.Parent:FindFirstChildOfClass("UIPadding")
			if not padding then
				self._frame.Size = UDim2.fromScale(1, 1)
				self._frame.Position = UDim2.fromScale(0.5, 0.5)
				return
			end

			local widthScale = padding.PaddingLeft.Scale + padding.PaddingRight.Scale
			local heightScale = padding.PaddingTop.Scale + padding.PaddingBottom.Scale
			local widthOffset = padding.PaddingLeft.Offset + padding.PaddingRight.Offset
			local heightOffset = padding.PaddingTop.Offset + padding.PaddingBottom.Offset
			local heightDiffOffset = padding.PaddingTop.Offset - padding.PaddingBottom.Offset
			local widthDiffOffset = padding.PaddingLeft.Offset - padding.PaddingRight.Offset

			if widthScale < 1 and heightScale < 1 then
				local widthSize = 1 / (1 - widthScale)
				local heightSize = 1 / (1 - heightScale)
				self._frame.Size = UDim2.new(widthSize, widthOffset, heightSize, heightOffset)
				self._frame.Position = UDim2.new(0.5, -widthDiffOffset / 2, 0.5, -heightDiffOffset / 2)
			end
		end

		local function connectPaddingSignals(padding: UIPadding)
			local connections = {
				padding:GetPropertyChangedSignal("PaddingLeft"):Connect(updatePadding),
				padding:GetPropertyChangedSignal("PaddingRight"):Connect(updatePadding),
				padding:GetPropertyChangedSignal("PaddingTop"):Connect(updatePadding),
				padding:GetPropertyChangedSignal("PaddingBottom"):Connect(updatePadding)
			}
			for _, connection in ipairs(connections) do
				table.insert(self._connections, connection)
			end
		end

		local paddingAddedConnection = self._frame.Parent.ChildAdded:Connect(function(child)
			if child:IsA("UIPadding") then
				updatePadding()
				connectPaddingSignals(child)
			end
		end)

		local paddingRemovedConnection = self._frame.Parent.ChildRemoved:Connect(function(child)
			if child:IsA("UIPadding") then
				updatePadding()
			end
		end)

		table.insert(self._connections, paddingAddedConnection)
		table.insert(self._connections, paddingRemovedConnection)

		local existingPadding = self._frame.Parent:FindFirstChildOfClass("UIPadding")
		if existingPadding then
			connectPaddingSignals(existingPadding)
			updatePadding()
		end
	end
end

function Shimmer:_createTween()
	local goalOffset = Vector2.new(1 + self._config.gradientWidth, 0)
	local tweenInfo = TweenInfo.new(
		self._config.time,
		self._config.style,
		self._config.direction,
		self._config.repeatCount,
		self._config.reverses,
		self._config.delayTime
	)

	self._tween = TweenService:Create(
		self._gradient,
		tweenInfo,
		{ Offset = goalOffset }
	)

	-- Connect tween events
	self._tween.Completed:Connect(function()
		if self._config.onComplete then
			self._config.onComplete()
		end
	end)
end

-- Public Methods
function Shimmer:GetFrame(): Frame
	return self._frame
end

function Shimmer:GetGradient(): UIGradient
	return self._gradient
end

function Shimmer:GetCorner(): UICorner?
	return self._corner
end

function Shimmer:GetConfig(): ShimmerConfig
	return table.clone(self._config)
end

function Shimmer:Play()
	self._frame.Visible = true
	if self._config.onStart then
		self._config.onStart()
	end
	self._tween:Play()
	self.PlaybackState = Enum.PlaybackState.Playing
end

function Shimmer:Pause()
	self._tween:Pause()
	self.PlaybackState = Enum.PlaybackState.Paused
end

function Shimmer:Cancel()
	self._tween:Cancel()
	self.PlaybackState = Enum.PlaybackState.Cancelled
end

function Shimmer:Destroy()
	self:Cancel()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	self._frame:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

function Shimmer:UpdateConfig(newConfig: ShimmerConfig)
	-- Update the configuration
	for key, value in pairs(newConfig) do
		self._config[key] = value
	end

	-- Update gradient properties
	if typeof(self._config.shimmerColor) == "Color3" then
		self._gradient.Color = ColorSequence.new(self._config.shimmerColor)
	else
		self._gradient.Color = self._config.shimmerColor
	end
	self._gradient.Rotation = self._config.gradientRotation
	self._gradient.Transparency = createNumberSequence(self._config.gradientTransparency)

	-- Update frame properties
	self._frame.BackgroundTransparency = 1 - self._config.shimmerOpacity
	self._frame.ZIndex = self._config.zIndex

	-- Update visual effects
	self:SetBlur(self._config.blurEffect)
	self:SetGlow(self._config.glowEffect)

	-- Recreate the tween with new settings
	self:Cancel()
	self:_createTween()

	-- Restart if it was playing
	if self.PlaybackState == Enum.PlaybackState.Playing then
		self:Play()
	end
end

function Shimmer:SetBlur(enabled: boolean)
	if enabled and not self._blur then
		self._blur = Instance.new("BlurEffect")
		self._blur.Size = self._config.blurSize
		self._blur.Parent = self._frame
	elseif not enabled and self._blur then
		self._blur:Destroy()
		self._blur = nil
	end
end

function Shimmer:SetGlow(enabled: boolean)
	if enabled and not self._glow then
		self._glow = Instance.new("UIStroke")
		self._glow.Color = self._config.glowColor
		self._glow.Transparency = self._config.glowTransparency
		self._glow.Thickness = self._config.glowSize
		self._glow.Parent = self._frame
	elseif not enabled and self._glow then
		self._glow:Destroy()
		self._glow = nil
	end
end

function Shimmer:ToggleRainbow(enabled: boolean)
	self._config.useRainbowEffect = enabled
	if enabled then
		self:_setupEffects()
	end
end

function Shimmer:SetPulse(enabled: boolean)
	self._config.pulseEffect = enabled
	if enabled then
		self:_setupEffects()
	end
end

function Shimmer:AddEventListener(eventName: string, callback: () -> ()): RBXScriptConnection
	assert(type(eventName) == "string", "Event name must be a string")
	assert(type(callback) == "function", "Callback must be a function")

	local connection
	if eventName == "complete" then
		connection = self._tween.Completed:Connect(callback)
	elseif eventName == "loop" then
		self._config.onLoop = callback
		connection = self._tween.Completed:Connect(callback)
	elseif eventName == "start" then
		self._config.onStart = callback
	else
		error("Invalid event name: " .. eventName)
	end

	if connection then
		table.insert(self._connections, connection)
	end

	return connection
end

return Shimmer