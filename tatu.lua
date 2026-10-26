-- Torre de Abraço Troll - God Mode + Anti Grab + Bolinha Azul + GUI Moderna
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local deathPos = nil
local godMode = false
local antiGrab = true
local blueBall = nil
local guiOpen = true
local minimized = false

local connections = {}

local function cleanup()
	for _, conn in pairs(connections) do
		if typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		end
	end
	table.clear(connections)
end

-- Bolinha azul permanente
local function createBlueBall(character)
	if blueBall and blueBall.Parent then
		blueBall:Destroy()
	end

	local root = character:WaitForChild("HumanoidRootPart", 5)
	if not root then return end

	blueBall = Instance.new("Part")
	blueBall.Name = "GodBall"
	blueBall.Size = Vector3.new(1.15, 1.15, 1.15)
	blueBall.Shape = Enum.PartType.Ball
	blueBall.Material = Enum.Material.Neon
	blueBall.Color = Color3.fromRGB(0, 180, 255)
	blueBall.CanCollide = false
	blueBall.Anchored = true
	blueBall.CastShadow = false
	blueBall.Parent = character

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(0, 180, 255)
	light.Brightness = 2.2
	light.Range = 9
	light.Parent = blueBall

	-- Mantém a bolinha sempre na cabeça
	local conn = RunService.Heartbeat:Connect(function()
		if blueBall and blueBall.Parent and character:FindFirstChild("HumanoidRootPart") then
			blueBall.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 3.4, 0)
		end
	end)
	table.insert(connections, conn)
end

-- God Mode + Anti Kill
local function applyGodMode(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid.MaxHealth = 999999
	humanoid.Health = 999999

	-- ForceField invisível
	if not character:FindFirstChild("GodFF") then
		local ff = Instance.new("ForceField")
		ff.Name = "GodFF"
		ff.Visible = false
		ff.Parent = character
	end
end

-- Anti Grab (ninguém te pega)
local function startAntiGrab(character)
	local conn = RunService.Heartbeat:Connect(function()
		if not antiGrab or not character or not character.Parent then return end

		for _, obj in pairs(character:GetDescendants()) do
			if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
				local name = string.lower(obj.Name)
				if name:find("grab") or name:find("hug") or name:find("carry") or name:find("hold") or name:find("attach") then
					obj:Destroy()
				end
			end
		end

		-- Remove qualquer Attachment estranho
		for _, obj in pairs(character:GetChildren()) do
			if obj:IsA("Attachment") and (obj.Name:lower():find("grab") or obj.Name:lower():find("hug")) then
				obj:Destroy()
			end
		end
	end)
	table.insert(connections, conn)
end

-- Cura constante
local function startHealLoop(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local conn = RunService.Heartbeat:Connect(function()
		if godMode and humanoid and humanoid.Parent then
			if humanoid.Health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end
	end)
	table.insert(connections, conn)
end

-- ==================== GUI MODERNA ====================
local function createGui()
	pcall(function()
		if player.PlayerGui:FindFirstChild("GodGui") then
			player.PlayerGui.GodGui:Destroy()
		end
	end)

	local gui = Instance.new("ScreenGui")
	gui.Name = "GodGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player.PlayerGui

	-- Frame principal
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 240, 0, 280)
	main.Position = UDim2.new(0.5, -120, 0.5, -140)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	main.BorderSizePixel = 0
	main.Parent = gui
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

	-- LED / Glow
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 180, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.3
	stroke.Parent = main

	-- Título
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -70, 0, 36)
	title.Position = UDim2.new(0, 12, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = "GOD MODE"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 18
	title.TextColor3 = Color3.fromRGB(0, 200, 255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = main

	-- Botão Minimizar
	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 28, 0, 28)
	minBtn.Position = UDim2.new(1, -64, 0, 8)
	minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	minBtn.Text = "–"
	minBtn.TextColor3 = Color3.new(1, 1, 1)
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 18
	minBtn.Parent = main
	Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

	-- Botão Fechar
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -32, 0, 8)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = main
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

	-- Container dos botões
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(1, -20, 1, -55)
	container.Position = UDim2.new(0, 10, 0, 48)
	container.BackgroundTransparency = 1
	container.Parent = main

	local function createToggle(name, y, default)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 42)
		btn.Position = UDim2.new(0, 0, 0, y)
		btn.BackgroundColor3 = default and Color3.fromRGB(0, 100, 160) or Color3.fromRGB(35, 35, 45)
		btn.Text = name .. (default and "  ON" or "  OFF")
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 15
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Parent = container
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		local s = Instance.new("UIStroke")
		s.Color = Color3.fromRGB(0, 180, 255)
		s.Thickness = 1
		s.Transparency = 0.6
		s.Parent = btn

		return btn
	end

	local godBtn = createToggle("God Mode", 0, false)
	local grabBtn = createToggle("Anti Grab", 50, true)
	local respawnBtn = createToggle("Respawn", 100, false)
	local tpBtn = createToggle("Die TP", 150, false)

	-- Créditos
	local credit = Instance.new("TextLabel")
	credit.Size = UDim2.new(1, 0, 0, 20)
	credit.Position = UDim2.new(0, 0, 1, -22)
	credit.BackgroundTransparency = 1
	credit.Text = "Datuna_YT  •  Torre de Abraço"
	credit.Font = Enum.Font.Gotham
	credit.TextSize = 11
	credit.TextColor3 = Color3.fromRGB(120, 120, 140)
	credit.Parent = main

	-- Funções dos botões
	godBtn.MouseButton1Click:Connect(function()
		godMode = not godMode
		godBtn.Text = "God Mode  " .. (godMode and "ON" or "OFF")
		godBtn.BackgroundColor3 = godMode and Color3.fromRGB(0, 100, 160) or Color3.fromRGB(35, 35, 45)

		if player.Character then
			if godMode then
				applyGodMode(player.Character)
			else
				local hum = player.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.MaxHealth = 100
					hum.Health = 100
				end
				if player.Character:FindFirstChild("GodFF") then
					player.Character.GodFF:Destroy()
				end
			end
		end
	end)

	grabBtn.MouseButton1Click:Connect(function()
		antiGrab = not antiGrab
		grabBtn.Text = "Anti Grab  " .. (antiGrab and "ON" or "OFF")
		grabBtn.BackgroundColor3 = antiGrab and Color3.fromRGB(0, 100, 160) or Color3.fromRGB(35, 35, 45)
	end)

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

	-- Minimizar
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 240, 0, 48)
			}):Play()
			container.Visible = false
		else
			container.Visible = true
			TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 240, 0, 280)
			}):Play()
		end
	end)

	-- Fechar
	closeBtn.MouseButton1Click:Connect(function()
		TweenService:Create(main, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		task.wait(0.2)
		gui:Destroy()
		cleanup()
		if blueBall then blueBall:Destroy() end
	end)

	-- Arrastar
	local dragging, dragStart, startPos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Quando spawna
local function onCharacterAdded(character)
	cleanup()
	task.wait(0.5)

	createBlueBall(character)
	startAntiGrab(character)
	startHealLoop(character)

	if godMode then
		applyGodMode(character)
	end
end

-- Inicia
createGui()

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)
