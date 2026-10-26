-- Respawn + Die TP + God Mode + Bolinha Azul (Corrigido para Torre de Abraço Troll)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local deathPos = nil
local godMode = false
local blueBall = nil
local healConnection = nil
local ballConnection = nil

-- Cria a bolinha azul (segura)
local function createBlueBall(character)
	if blueBall and blueBall.Parent then
		blueBall:Destroy()
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	blueBall = Instance.new("Part")
	blueBall.Name = "BlueBall"
	blueBall.Size = Vector3.new(1.1, 1.1, 1.1)
	blueBall.Shape = Enum.PartType.Ball
	blueBall.Material = Enum.Material.Neon
	blueBall.Color = Color3.fromRGB(0, 170, 255)
	blueBall.CanCollide = false
	blueBall.Anchored = true
	blueBall.CastShadow = false
	blueBall.Parent = character

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(0, 170, 255)
	light.Brightness = 1.8
	light.Range = 7
	light.Parent = blueBall
end

-- God Mode seguro (não causa morte infinita)
local function setGodMode(character, enabled)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if enabled then
		humanoid.MaxHealth = 999999
		humanoid.Health = 999999

		-- Loop de cura constante (mais estável nesses jogos)
		if healConnection then healConnection:Disconnect() end
		healConnection = RunService.Heartbeat:Connect(function()
			if humanoid and humanoid.Parent and godMode then
				if humanoid.Health < humanoid.MaxHealth then
					humanoid.Health = humanoid.MaxHealth
				end
			end
		end)
	else
		if healConnection then
			healConnection:Disconnect()
			healConnection = nil
		end
		humanoid.MaxHealth = 100
		humanoid.Health = 100
	end
end

-- Cria a GUI
local function createGui()
	pcall(function()
		if player.PlayerGui:FindFirstChild("RespawnGui") then
			player.PlayerGui.RespawnGui:Destroy()
		end
	end)

	local gui = Instance.new("ScreenGui")
	gui.Name = "RespawnGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player.PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 200, 0, 160)
	frame.Position = UDim2.new(0.5, -100, 0.72, 0)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local function makeButton(text, yPos, color)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -16, 0, 36)
		btn.Position = UDim2.new(0, 8, 0, yPos)
		btn.Text = text
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		btn.BackgroundColor3 = color
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Parent = frame
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		return btn
	end

	local respawnBtn = makeButton("Respawn", 10, Color3.fromRGB(50, 50, 50))
	local tpBtn     = makeButton("Die TP", 52, Color3.fromRGB(50, 50, 50))
	local godBtn    = makeButton("God Mode: OFF", 94, Color3.fromRGB(40, 80, 40))

	local credit = Instance.new("TextLabel")
	credit.Size = UDim2.new(1, 0, 0, 18)
	credit.Position = UDim2.new(0, 0, 1, -20)
	credit.BackgroundTransparency = 1
	credit.Text = "Credits: Datuna_YT"
	credit.TextScaled = true
	credit.TextColor3 = Color3.fromRGB(160, 160, 160)
	credit.Parent = frame

	-- Botões
	respawnBtn.MouseButton1Click:Connect(function()
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			deathPos = char.HumanoidRootPart.CFrame
			char:BreakJoints()
		end
	end)

	tpBtn.MouseButton1Click:Connect(function()
		local char = player.Character
		if deathPos and char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = deathPos
		end
	end)

	godBtn.MouseButton1Click:Connect(function()
		godMode = not godMode
		godBtn.Text = godMode and "God Mode: ON" or "God Mode: OFF"
		godBtn.BackgroundColor3 = godMode and Color3.fromRGB(30, 130, 30) or Color3.fromRGB(40, 80, 40)

		if player.Character then
			setGodMode(player.Character, godMode)
		end
	end)

	-- Arrastar
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Quando o personagem spawna
local function onCharacterAdded(character)
	task.wait(0.4)

	createBlueBall(character)

	if godMode then
		setGodMode(character, true)
	end

	-- Mantém a bolinha na cabeça
	if ballConnection then ballConnection:Disconnect() end
	ballConnection = RunService.Heartbeat:Connect(function()
		if blueBall and blueBall.Parent and character:FindFirstChild("HumanoidRootPart") then
			blueBall.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 3.3, 0)
		end
	end)
end

-- Inicia
createGui()

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)
