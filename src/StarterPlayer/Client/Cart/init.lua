-- Currently does not replicate to other clients
-- Would need to make the characters invisible to other clients, or replicate the cart

local cart = {}

local tweenService = game:GetService("TweenService")
local collectionService = game:GetService("CollectionService")

local player = game.Players.LocalPlayer
local assets = game.ReplicatedStorage.Assets
local cartModel = assets.Cart
local usingCart -- cloned model being used

local camera = workspace.CurrentCamera
local cameraShaker = require(script.Parent.CameraShaker)
local speedConfig = require(script.SpeedConfig)
local switchCamera = false
local speedPerStud = speedConfig[1]

local nodes = collectionService:GetTagged("CartNode")
local cartNodes = {}
for i,v in pairs(nodes) do
	cartNodes[v.Name] = v
end

local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end)
camShake:Start()

local function getHumanoid()
    local chr = player.Character or player.CharacterAdded:Wait()
	if not chr then return end
	
	local hum = chr.Humanoid
	if not hum then return end
	
	if hum.Health < 1 then return end
end

function cart.start()
    local hum = getHumanoid()
    if not hum then return end
    if usingCart then return end

	usingCart = cartModel:Clone()
	
	local cartSound = assets.Sounds.Minecart:Clone()
	cartSound.Parent = usingCart
	cartSound:Play()

	usingCart.Parent = workspace
	usingCart.Seat:Sit(hum)

	camShake:ShakeSustain(cameraShaker.Presets.Vibration)
	
    -- Cart reaching all the nodes
	for i = 1, #nodes do
		if not usingCart then camShake:StopSustained(0) return end
		
		local n = cartNodes[tostring(i)]
		local goal = {}
		goal.CFrame = n.CFrame
		
		local dist = (usingCart.Primary.Position - n.Position).magnitude
		
		local speedChange = speedConfig[i]
		if speedChange then
			speedPerStud = speedChange
		end
		
		local _speed = speedPerStud * dist
		
		local tween = tweenService:Create(usingCart.Primary, TweenInfo.new(_speed,  Enum.EasingStyle.Linear, Enum.EasingDirection.Out), goal):Play()
		tween.Completed:Wait()
	end
	
	camShake:StopSustained(1)
	
	--local tween = tweenService:Create(player.PlayerGui.ScreenGui.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {BackgroundTransparency = 0}):Play()
	--tween.Completed:Wait()
	usingCart:Destroy()
end

-- Will load the cart at every node, so we can see how it fits onto each point in the track
function cart.debug()
	for i = 1, #nodes do
        local node = cartNodes[tostring(i)]
        if node then
            local debugCart = cartModel:Clone()
            debugCart.Parent = workspace
            tweenService:Create(debugCart.Primary, TweenInfo.new(0,  Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = node.CFrame}):Play()
        end
	end
end

return cart