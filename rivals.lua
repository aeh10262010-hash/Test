-- [[ 核心服務 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- [[ 功能變數 ]]
local TargetPos = CFrame.new(9000, 9000, 9000)
local Projectiles = {}
local currentTarget = nil
local KickEnabled = false
local TpEnabled = false

-- [[ 清理舊 UI ]]
if CoreGui:FindFirstChild("w7w7_HVH") then
    CoreGui["w7w7_HVH"]:Destroy()
end

-- [[ UI 建立 ]]
local sg = Instance.new("ScreenGui")
sg.Name = "w7w7_HVH"
sg.Parent = CoreGui
sg.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = sg
MainFrame.Size = UDim2.new(0, 300, 0, 160)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

-- 彩虹頂條
local RainbowLine = Instance.new("Frame", MainFrame)
RainbowLine.Size = UDim2.new(1, 0, 0, 3)
RainbowLine.BorderSizePixel = 0
local UIGradient = Instance.new("UIGradient", RainbowLine)
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
    ColorSequenceKeypoint.new(0.5, Color3.new(0,1,0)),
    ColorSequenceKeypoint.new(1, Color3.new(0,0,1))
})

-- 標題
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "w7w7 HUB : HVH+"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.Code
Title.TextSize = 20
Title.BackgroundTransparency = 1

-- 右上角關閉按鈕
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- [[ 按鈕工廠 ]]
local function NewButton(name, yPos)
    local Frame = Instance.new("Frame", MainFrame)
    Frame.Size = UDim2.new(0, 150, 0, 35)
    Frame.Position = UDim2.new(0.5, -75, 0, yPos)
    Frame.BackgroundTransparency = 1

    local Ind = Instance.new("Frame", Frame)
    Ind.Size = UDim2.new(0, 8, 0, 8)
    Ind.Position = UDim2.new(0, 0, 0.5, -4)
    Ind.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, -15, 1, 0)
    Btn.Position = UDim2.new(0, 15, 0, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = name .. " OFF"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Instance.new("UICorner", Btn)

    return Btn, Ind
end

local TPBtn, TPInd = NewButton("TP", 55)
local KickBtn, KickInd = NewButton("KICK", 100)

-- [[ 交互邏輯 ]]
local function UpdateUI(btn, ind, state, name)
    btn.Text = name .. (state and " ON" or " OFF")
    ind.BackgroundColor3 = state and Color3.new(0, 1, 0) or Color3.new(0.6, 0, 0)
end

TPBtn.MouseButton1Click:Connect(function()
    TpEnabled = not TpEnabled
    UpdateUI(TPBtn, TPInd, TpEnabled, "TP")
    if not TpEnabled then currentTarget = nil end
end)

KickBtn.MouseButton1Click:Connect(function()
    KickEnabled = not KickEnabled
    UpdateUI(KickBtn, KickInd, KickEnabled, "KICK")
end)

-- 彩虹循環動畫
RunService.RenderStepped:Connect(function()
    local t = tick()
    UIGradient.Offset = Vector2.new(math.sin(t) * 0.5, 0)
end)

-- [[ 核心功能循環 ]]
RunService.Heartbeat:Connect(function()
    -- KICK 邏輯
    if KickEnabled then
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = TargetPos
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end
            for p in pairs(Projectiles) do
                if p and p.Parent then
                    p.CFrame = TargetPos
                    p.AssemblyLinearVelocity = Vector3.zero
                else Projectiles[p] = nil end
            end
        end)
    end

    -- TP 邏輯
    if TpEnabled and currentTarget and currentTarget.Character then
        local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and myRoot then
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            myRoot.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

-- TP 目標切換
task.spawn(function()
    while true do
        if TpEnabled then
            local plrs = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then table.insert(plrs, p) end
            end
            for _, plr in ipairs(plrs) do
                if not TpEnabled then break end
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    currentTarget = plr
                    task.wait(1.5)
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 子彈追蹤
workspace.ChildAdded:Connect(function(obj)
    if obj:IsA("BasePart") then
        task.wait(0.1)
        if obj.Name == "CoreProjectile" or obj.AssemblyLinearVelocity.Magnitude > 50 then
            Projectiles[obj] = true
        end
    end
end)

-----------------------------------------------------------
-- [[ 以下為追加區：整合第二串代碼的 Void (K8X 閃爍邏輯) ]]
-----------------------------------------------------------

-- 1. 調整 UI 高度並新增 Void 按鈕
MainFrame.Size = UDim2.new(0, 300, 0, 230) -- 加高以放下 void 和 Y 顯示
local VoidBtn, VoidInd = NewButton("void", 145)
local VoidEnabled = false

-- 2. 移植 Y 座標文本顯示
local YText = Instance.new("TextLabel", MainFrame)
YText.Size = UDim2.new(1, 0, 0, 30)
YText.Position = UDim2.new(0, 0, 0, 185)
YText.BackgroundTransparency = 1
YText.TextColor3 = Color3.fromRGB(0, 255, 180)
YText.Font = Enum.Font.GothamBlack
YText.TextSize = 14
YText.Text = "Y: 0"

-- 3. 移植閃爍邏輯變數
local lastPos = nil
local fakeY = -21827262828
local currentValue = 2147483647
local flip = true

VoidBtn.MouseButton1Click:Connect(function()
    VoidEnabled = not VoidEnabled
    UpdateUI(VoidBtn, VoidInd, VoidEnabled, "void")
    
    if VoidEnabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            lastPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        fakeY = -21827262828
    else
        -- 關閉時瞬移回原位
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and lastPos then
            LocalPlayer.Character.HumanoidRootPart.CFrame = lastPos
            LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

-- 4. 移植計數器與 Y 軸邏輯
task.spawn(function()
    while true do
        if VoidEnabled then
            fakeY = fakeY + math.random(1000, 3000)
            currentValue = currentValue + (fakeY - currentValue) * 0.1
            YText.Text = "Y: " .. math.floor(currentValue)
            
            -- 執行第二串代碼的核心閃爍 (K8X 核心)
            pcall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local min, max = 10000000000, 100000000000
                    local randX = math.random(min, max)
                    local randY = math.random(min, max)
                    local randZ = math.random(min, max)
                    if not flip then
                        randX, randY, randZ = -randX, -randY, -randZ
                    end
                    flip = not flip
                    hrp.CFrame = CFrame.new(randX, randY, randZ)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end)
        else
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    YText.Text = "Y: " .. math.floor(LocalPlayer.Character.HumanoidRootPart.Position.Y)
                end
            end)
        end
        task.wait(0.12)
    end
end)
