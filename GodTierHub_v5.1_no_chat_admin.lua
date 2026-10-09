-- ==================================================
-- 🥚 GOD TIER HUB — FULL VERSION v5.1 (đã sửa lỗi)
-- ✅ 8 TAB | CÓ NÚT THU GỌN [−] | GIAO DIỆN TỰ DỰNG — KHÔNG TẢI MÃ TỪ INTERNET
-- ✅ Tương thích: Delta, Fluxus, ArceusX, Hydrogen...
-- ==================================================

-- ══════════════════════════════════════════════════
-- 🏆 BẢNG ĐỘ HIẾM
-- ══════════════════════════════════════════════════
local RARITY_LIST = {
    "Divine", "Limited", "Eternal", "Secret", "Cosmic",
    "Exclusive", "Exotic", "Rainbow", "Mythic", "Legendary",
    "Epic", "SuperRare", "Celestial", "Rare", "Uncommon", "Common"
}

-- ══════════════════════════════════════════════════
-- ⚙️ CẤU HÌNH TOÀN BỘ
-- ══════════════════════════════════════════════════
_G.GOD = {
    Steal = {
        Enabled = false, OnlyDivine = true, MinRarity = "Divine",
        FlySpeed = 450, GrabDelay = 0.05, AutoReturn = true,
        BasePosition = Vector3.new(0, 50, 0), RejoinWhenEmpty = false,
        AutoSell = false, SellThreshold = 10000000, ScanInterval = 0.4,
        MaxScanRange = 1000, PrioritizeHighest = true, IgnoreCarried = true
    },
    Blyxo = {
        ESP_Enabled = false, ShowEggs = true, ShowPlayers = false, ShowPets = true,
        ShowGuards = true, ShowMachines = true, ShowRarity = true, ShowDistance = true,
        ShowValue = true, AlertDivine = true, AlertLimited = true,
        Chams = false, TracerLines = false, BoxESP = false, MaxESPRange = 500
    },
    Chilli = {
        GodMode = false, AntiKnockback = false, NoFallDamage = false, NoClip = false,
        AutoRespawn = false, SpeedBoost = false, WalkSpeed = 32, InfiniteJump = false,
        AntiVoid = true, AntiAFK = true, NoSlopeSlowdown = false, AntiRagdoll = false, AntiDrop = false
    },
    InfiniteYield = {
        Fly = false, NoClip = false, ClickTeleport = false, JumpPower = 50,
        Gravity = 196.2, NoclipSpeed = 16, InstantPrompt = true
    },
    Dark = {
        FPSBoost = false, NoFog = false, Fullbright = false, LowGraphics = false,
        ServerHop = false, AntiIdle = true, ParticlesOff = true
    },
    Fluxus = {
        FOV = 70, Zoom = 1, NoCameraShake = false, CustomGravity = false
    },
    Rayfield = {
        NotifySound = true, AutoSaveConfig = true, ShowStats = true, NotifyDuration = 3
    },
    Colors = {
        Divine = Color3.fromRGB(255,215,0), Limited = Color3.fromRGB(255,80,80),
        Eternal = Color3.fromRGB(180,50,255), Secret = Color3.fromRGB(50,200,255),
        Cosmic = Color3.fromRGB(80,255,180), Exclusive = Color3.fromRGB(255,50,150),
        Rainbow = Color3.fromRGB(255,120,0), Mythic = Color3.fromRGB(150,80,220),
        Legendary = Color3.fromRGB(255,165,0), Epic = Color3.fromRGB(120,80,200),
        Rare = Color3.fromRGB(50,150,255), Default = Color3.fromRGB(150,150,150)
    }
}

-- ══════════════════════════════════════════════════
-- 🔌 DỊCH VỤ & BIẾN TOÀN CỤC
-- (bản cũ viết "local P = ..., TS = ..." trên một dòng — cú pháp không hợp lệ nên FlowAuth báo lỗi dòng 65-68)
-- ══════════════════════════════════════════════════
local P = game:GetService("Players")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local TServ = game:GetService("TeleportService")
local WS = game:GetService("Workspace")
local LG = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")
local LP = P.LocalPlayer

-- (bản cũ: "local Char, Hum, Root, ESP_Objs = {}, {}, {}" khiến Root là bảng rỗng và ESP_Objs = nil)
local Char, Hum, Root = nil, nil, nil
local ESP_Objs = {}
local Stats = {Eggs = 0, Divine = 0, TotalValue = 0, SoldValue = 0, StartTime = os.time()}

-- Chạy lại script: dọn bản cũ (kết nối sự kiện, GUI, ESP) để không bị chạy chồng
pcall(function() if _G.__GOD_CLEANUP then _G.__GOD_CLEANUP() end end)
local ALIVE = {dead = false}
local CONNS = {}
local function Track(c) CONNS[#CONNS + 1] = c return c end
local function Dead() return ALIVE.dead end

local function SafeDestroy(o) if o then pcall(function() o:Destroy() end) end end

-- ══════════════════════════════════════════════════
-- 🎨 GIAO DIỆN TỰ DỰNG (thay cho thư viện Venyx tải từ GitHub)
-- API giữ nguyên như bản cũ: UI:Tab / Tab:Toggle / Dropdown / Slider / Button / Label / UI:Notify
-- Lý do thay: Venyx.new/Tab/Toggle của repo đó không tồn tại như script gọi, và tải mã lạ từ internet
-- rồi loadstring là rủi ro bảo mật (người đăng repo có thể đổi mã bất cứ lúc nào).
-- ══════════════════════════════════════════════════
local THEME = {
    Bg = Color3.fromRGB(18, 20, 30), Side = Color3.fromRGB(24, 27, 40), Title = Color3.fromRGB(30, 34, 52),
    Row = Color3.fromRGB(30, 34, 50), Accent = Color3.fromRGB(90, 130, 255), Green = Color3.fromRGB(40, 180, 80),
    Red = Color3.fromRGB(200, 60, 60), Text = Color3.fromRGB(230, 230, 240), Dim = Color3.fromRGB(140, 145, 170),
    Track = Color3.fromRGB(50, 55, 80),
}

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
end
local function isPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function GuiParents()
    local list = {}
    pcall(function() if gethui then list[#list + 1] = gethui() end end)
    pcall(function() list[#list + 1] = game:GetService("CoreGui") end)
    list[#list + 1] = LP:WaitForChild("PlayerGui")
    return list
end

local function CreateUI(cfg)
    local UI = {Tabs = {}, ActiveTab = nil}

    for _, p in ipairs(GuiParents()) do
        pcall(function()
            local old = p:FindFirstChild("GodTierHubV5")
            if old then old:Destroy() end
        end)
    end
    local gui = mk("ScreenGui", {Name = "GodTierHubV5", ResetOnSpawn = false, DisplayOrder = cfg.AlwaysOnTop and 1000 or 10,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    for _, p in ipairs(GuiParents()) do
        local ok = pcall(function() gui.Parent = p end)
        if ok and gui.Parent then break end
    end
    UI.Gui = gui

    -- Cỡ cửa sổ co theo màn hình (điện thoại màn hình nhỏ)
    local vp = (WS.CurrentCamera and WS.CurrentCamera.ViewportSize) or Vector2.new(800, 450)
    local w = math.min(cfg.Size.X.Offset, vp.X - 16)
    local h = math.min(cfg.Size.Y.Offset, vp.Y - 40)
    w = math.max(w, 300) h = math.max(h, 220)

    local main = mk("Frame", {Name = "Main", Size = UDim2.new(0, w, 0, h), Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2),
        BackgroundColor3 = THEME.Bg, BorderSizePixel = 0, ClipsDescendants = true}, gui)
    corner(main, 10)

    local titleBar = mk("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = THEME.Title, BorderSizePixel = 0}, main)
    local collapseBtn = mk("TextButton", {Size = UDim2.new(0, 34, 0, 34), BackgroundTransparency = 1, Text = "−",
        TextColor3 = THEME.Text, Font = Enum.Font.GothamBold, TextSize = 22}, titleBar)
    mk("TextLabel", {Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 40, 0, 0), BackgroundTransparency = 1,
        Text = cfg.Name, TextColor3 = THEME.Accent, Font = Enum.Font.GothamBold, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, titleBar)

    local body = mk("Frame", {Size = UDim2.new(1, 0, 1, -34), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1}, main)
    local sbW = math.clamp(math.floor(w * 0.27), 96, 150)
    local sidebar = mk("ScrollingFrame", {Size = UDim2.new(0, sbW, 1, -6), Position = UDim2.new(0, 4, 0, 3), BackgroundColor3 = THEME.Side,
        BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y}, body)
    corner(sidebar, 8)
    local sl = mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
    mk("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, sidebar)
    local pages = mk("Frame", {Size = UDim2.new(1, -(sbW + 12), 1, -6), Position = UDim2.new(0, sbW + 8, 0, 3), BackgroundTransparency = 1}, body)

    -- Kéo di chuyển (chuột + cảm ứng)
    local drag, dragStart, mainStart
    titleBar.InputBegan:Connect(function(i)
        if isPress(i) then drag = true dragStart = i.Position mainStart = main.Position end
    end)
    Track(UIS.InputEnded:Connect(function(i) if isPress(i) then drag = false end end))
    Track(UIS.InputChanged:Connect(function(i)
        if drag and isMove(i) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(mainStart.X.Scale, mainStart.X.Offset + d.X, mainStart.Y.Scale, mainStart.Y.Offset + d.Y)
        end
    end))

    -- Nút thu gọn [−]
    local collapsed, fullH = false, h
    collapseBtn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        body.Visible = not collapsed
        collapseBtn.Text = collapsed and "+" or "−"
        main.Size = UDim2.new(0, main.Size.X.Offset, 0, collapsed and 34 or fullH)
    end)

    -- Đổi kích thước (CanResize)
    if cfg.CanResize then
        local grip = mk("TextButton", {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -26, 1, -26), BackgroundTransparency = 1,
            Text = "◢", TextColor3 = THEME.Dim, Font = Enum.Font.GothamBold, TextSize = 16, ZIndex = 5}, main)
        local rs, rStart, sStart
        grip.InputBegan:Connect(function(i) if isPress(i) then rs = true rStart = i.Position sStart = main.AbsoluteSize end end)
        Track(UIS.InputEnded:Connect(function(i) if isPress(i) then rs = false end end))
        Track(UIS.InputChanged:Connect(function(i)
            if rs and isMove(i) and not collapsed then
                local d = i.Position - rStart
                local nw = math.clamp(sStart.X + d.X, 300, vp.X)
                local nh = math.clamp(sStart.Y + d.Y, 220, vp.Y)
                fullH = nh
                main.Size = UDim2.new(0, nw, 0, nh)
            end
        end))
    end

    -- Thông báo
    local notifHolder = mk("Frame", {Size = UDim2.new(0, 280, 0, 0), Position = UDim2.new(0.5, -140, 0, 8), BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 50}, gui)
    mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, notifHolder)
    local notifOrder = 0
    function UI:Notify(o)
        if Dead() then return end
        notifOrder = notifOrder + 1
        local kids = notifHolder:GetChildren()
        local count = 0
        for _, k in ipairs(kids) do if k:IsA("Frame") then count = count + 1 end end
        if count >= 4 then
            for _, k in ipairs(kids) do if k:IsA("Frame") then k:Destroy() break end end
        end
        local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = THEME.Title,
            BorderSizePixel = 0, LayoutOrder = notifOrder, ZIndex = 50}, notifHolder)
        corner(f, 8)
        mk("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, f)
        mk("UIListLayout", {Padding = UDim.new(0, 1)}, f)
        mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = tostring(o.Title or ""),
            TextColor3 = THEME.Accent, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, ZIndex = 51, LayoutOrder = 1}, f)
        mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = tostring(o.Content or ""),
            TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, ZIndex = 51, LayoutOrder = 2}, f)
        task.delay(tonumber(o.Time) or 3, function() SafeDestroy(f) end)
    end

    -- ===== Tab =====
    local Tab = {}
    Tab.__index = Tab
    local tabCount = 0

    function UI:Tab(o)
        tabCount = tabCount + 1
        local t = setmetatable({Order = 0}, Tab)
        t.Btn = mk("TextButton", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = THEME.Side, BorderSizePixel = 0, Text = tostring(o.Name),
            TextColor3 = THEME.Dim, Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true, LayoutOrder = tabCount, AutoLocalize = false}, sidebar)
        corner(t.Btn, 6)
        t.Page = mk("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, pages)
        mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, t.Page)
        mk("UIPadding", {PaddingRight = UDim.new(0, 4)}, t.Page)
        UI.Tabs[#UI.Tabs + 1] = t
        t.Btn.MouseButton1Click:Connect(function() UI:Select(t) end)
        if not UI.ActiveTab then UI:Select(t) end
        return t
    end

    function UI:Select(t)
        for _, x in ipairs(UI.Tabs) do
            x.Page.Visible = (x == t)
            x.Btn.BackgroundColor3 = (x == t) and THEME.Accent or THEME.Side
            x.Btn.TextColor3 = (x == t) and Color3.new(1, 1, 1) or THEME.Dim
        end
        UI.ActiveTab = t
    end

    local function nextOrder(t) t.Order = t.Order + 1 return t.Order end

    function Tab:Label(o)
        local l = mk("TextLabel", {Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            Text = tostring(o.Text), TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(self)}, self.Page)
        return {Set = function(_, txt) l.Text = tostring(txt) end}
    end

    function Tab:Button(o)
        local b = mk("TextButton", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = THEME.Row, BorderSizePixel = 0, Text = tostring(o.Name),
            TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true, LayoutOrder = nextOrder(self), AutoLocalize = false}, self.Page)
        corner(b, 6)
        b.MouseButton1Click:Connect(function() if o.Callback then pcall(o.Callback) end end)
        return b
    end

    function Tab:Toggle(o)
        local state = o.Default and true or false
        local row = mk("Frame", {Size = UDim2.new(1, -6, 0, 36), BackgroundColor3 = THEME.Row, BorderSizePixel = 0, LayoutOrder = nextOrder(self)}, self.Page)
        corner(row, 6)
        mk("TextLabel", {Size = UDim2.new(1, -62, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = tostring(o.Name),
            TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left}, row)
        local sw = mk("Frame", {Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -50, 0.5, -11), BorderSizePixel = 0}, row)
        corner(sw, 11)
        local dot = mk("Frame", {Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, sw)
        corner(dot, 8)
        local hit = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""}, row)
        local obj = {}
        local function paint()
            sw.BackgroundColor3 = state and THEME.Green or THEME.Track
            dot.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        end
        function obj:Set(v, silent)
            state = v and true or false
            paint()
            if not silent and o.Callback then pcall(o.Callback, state) end
        end
        function obj:Get() return state end
        hit.MouseButton1Click:Connect(function() obj:Set(not state) end)
        paint()
        return obj
    end

    function Tab:Slider(o)
        local min, max = o.Min or 0, o.Max or 100
        local value = o.Default or min
        local step = (max - min) <= 10 and 0.05 or 1 -- khoảng nhỏ (vd độ trễ nhặt 0–2) cần số lẻ
        local row = mk("Frame", {Size = UDim2.new(1, -6, 0, 50), BackgroundColor3 = THEME.Row, BorderSizePixel = 0, LayoutOrder = nextOrder(self)}, self.Page)
        corner(row, 6)
        mk("TextLabel", {Size = UDim2.new(1, -70, 0, 22), Position = UDim2.new(0, 10, 0, 2), BackgroundTransparency = 1, Text = tostring(o.Name),
            TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd}, row)
        local valLbl = mk("TextLabel", {Size = UDim2.new(0, 56, 0, 22), Position = UDim2.new(1, -62, 0, 2), BackgroundTransparency = 1,
            TextColor3 = THEME.Accent, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right}, row)
        local track = mk("Frame", {Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 34), BackgroundColor3 = THEME.Track, BorderSizePixel = 0}, row)
        corner(track, 3)
        local fill = mk("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0}, track)
        corner(fill, 3)
        local hit = mk("TextButton", {Size = UDim2.new(1, -12, 0, 26), Position = UDim2.new(0, 6, 0, 24), BackgroundTransparency = 1, Text = ""}, row)
        local function setValue(v, silent)
            v = math.clamp(v, min, max)
            v = math.floor(v / step + 0.5) * step
            v = tonumber(string.format("%.3f", v))
            value = v
            fill.Size = UDim2.new(max > min and (v - min) / (max - min) or 0, 0, 1, 0)
            valLbl.Text = tostring(v)
            if not silent and o.Callback then pcall(o.Callback, v) end
        end
        local dragging = false
        local function fromInput(pos)
            local w2 = track.AbsoluteSize.X
            if w2 <= 0 then return end
            setValue(min + (max - min) * math.clamp((pos.X - track.AbsolutePosition.X) / w2, 0, 1))
        end
        hit.InputBegan:Connect(function(i) if isPress(i) then dragging = true fromInput(i.Position) end end)
        Track(UIS.InputChanged:Connect(function(i) if dragging and isMove(i) then fromInput(i.Position) end end))
        Track(UIS.InputEnded:Connect(function(i) if isPress(i) then dragging = false end end))
        setValue(value, true)
        return {Set = function(_, v, silent) setValue(v, silent) end, Get = function() return value end}
    end

    function Tab:Dropdown(o)
        local list = o.List or {}
        local current = o.Default or list[1]
        local box = mk("Frame", {Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrder(self)}, self.Page)
        mk("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, box)
        local head = mk("TextButton", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = THEME.Row, BorderSizePixel = 0,
            TextColor3 = THEME.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true, LayoutOrder = 1, AutoLocalize = false}, box)
        corner(head, 6)
        local listFrame = mk("ScrollingFrame", {Size = UDim2.new(1, 0, 0, 140), BackgroundColor3 = THEME.Side, BorderSizePixel = 0, ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, LayoutOrder = 2}, box)
        corner(listFrame, 6)
        mk("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, listFrame)
        mk("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 5)}, listFrame)
        local obj = {}
        local function paint()
            head.Text = tostring(o.Name) .. ":  " .. tostring(current) .. (listFrame.Visible and "  ▴" or "  ▾")
        end
        function obj:Set(v, silent)
            current = v
            listFrame.Visible = false
            paint()
            if not silent and o.Callback then pcall(o.Callback, v) end
        end
        for i, item in ipairs(list) do
            local b = mk("TextButton", {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = THEME.Row, BorderSizePixel = 0, Text = tostring(item),
                TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = 11, LayoutOrder = i, AutoLocalize = false}, listFrame)
            corner(b, 4)
            b.MouseButton1Click:Connect(function() obj:Set(item) end)
        end
        head.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible paint() end)
        paint()
        return obj
    end

    function UI:Destroy() SafeDestroy(gui) end
    return UI
end

local UI = CreateUI({
    Name = "🥚 GOD TIER HUB v5.1",
    Theme = "Midnight",
    Size = UDim2.new(0, 760, 0, 460),
    CanMinimize = true,
    CanResize = true,
    AlwaysOnTop = true
})

-- ══════════════════════════════════════════════════
-- 🛠️ HÀM HỖ TRỢ
-- ══════════════════════════════════════════════════
local function UpdChar()
    Char = LP.Character
    if Char then
        Hum = Char:FindFirstChildOfClass("Humanoid")
        Root = Char:FindFirstChild("HumanoidRootPart")
    else
        Hum, Root = nil, nil
    end
end

local function Rank(r)
    for i, n in ipairs(RARITY_LIST) do
        if string.lower(n) == string.lower(r or "") then return #RARITY_LIST - i + 1 end
    end
    return 0
end

local function Val(r)
    local v = {Divine=5e7,Limited=2.5e7,Eternal=1.5e7,Secret=1e7,Cosmic=7.5e6,
        Exclusive=5e6,Rainbow=2e6,Mythic=1e6,Legendary=5e5,Epic=1e5,Rare=1e4}
    return v[r] or 100
end

local function Notify(t, c, d) UI:Notify({Title = t, Content = c, Time = d or 3}) end

-- ══════════════════════════════════════════════════
-- 🔍 QUÉT TRỨNG
-- Tối ưu máy yếu: dựng chỉ mục các Part tên "egg" MỘT LẦN (quét chia nhỏ khung hình) rồi cập nhật bằng sự kiện
-- DescendantAdded/Removing. Bản cũ gọi workspace:GetDescendants() + string.lower trên mọi Part, mỗi 0.4–0.5 giây.
-- ══════════════════════════════════════════════════
local EGG_IDX = {}
local function IsEggName(name)
    local n = string.lower(name)
    return string.find(n, "egg", 1, true) ~= nil or string.find(n, "trứng", 1, true) ~= nil
end
local function IndexAdd(d)
    if d:IsA("BasePart") and IsEggName(d.Name) then EGG_IDX[d] = true end
end

Track(WS.DescendantAdded:Connect(IndexAdd))
Track(WS.DescendantRemoving:Connect(function(d) EGG_IDX[d] = nil end))
task.spawn(function()
    local all = WS:GetDescendants()
    local t0 = os.clock()
    for i = 1, #all do
        if Dead() then return end
        IndexAdd(all[i])
        if i % 256 == 0 and os.clock() - t0 > 0.004 then
            task.wait()
            t0 = os.clock()
        end
    end
end)

local RAR_CACHE = setmetatable({}, {__mode = "k"})

-- Độ hiếm: tên Part / tên cha / tên ông (như bản cũ) + Attribute / StringValue / TextLabel "rarity" của trứng
local function FindRarityIn(text)
    local l = string.lower(text)
    for _, r in ipairs(RARITY_LIST) do
        if string.find(l, string.lower(r), 1, true) then return r, Rank(r) end
    end
    return nil, 0
end

local function DetectRarity(d)
    local c = RAR_CACHE[d]
    local now = os.clock()
    if c and now - c.t < 5 then return c.rar, c.rnk end

    local rar, rnk = "Unknown", 0
    local names = {d.Name}
    local p1 = d.Parent
    if p1 then
        names[#names + 1] = p1.Name
        if p1.Parent then names[#names + 1] = p1.Parent.Name end
    end
    for _, cn in ipairs(names) do
        local r, k = FindRarityIn(cn)
        if r then rar, rnk = r, k break end
    end
    if rnk == 0 then
        local scope = (p1 and p1:IsA("Model")) and p1 or d
        for k, v in pairs(scope:GetAttributes()) do
            if string.find(string.lower(k), "rarity", 1, true) then
                local r, kk = FindRarityIn(tostring(v))
                if r then rar, rnk = r, kk break end
            end
        end
        if rnk == 0 then
            local n = 0
            for _, x in ipairs(scope:GetDescendants()) do
                n = n + 1
                if n > 60 then break end
                local nm = string.lower(x.Name)
                if x:IsA("StringValue") and string.find(nm, "rarity", 1, true) then
                    local r, kk = FindRarityIn(x.Value)
                    if r then rar, rnk = r, kk break end
                elseif x:IsA("TextLabel") and #x.Text < 24 then
                    local r, kk = FindRarityIn(x.Text)
                    if r then rar, rnk = r, kk break end
                end
            end
        end
    end
    RAR_CACHE[d] = {t = now, rar = rar, rnk = rnk}
    return rar, rnk
end

-- Trứng đang nằm trên người một người chơi (đang được mang) → "carried"
local function IsCarried(d)
    local cur = d.Parent
    while cur and cur ~= WS do
        if cur:IsA("Model") and P:GetPlayerFromCharacter(cur) then return true end
        cur = cur.Parent
    end
    return false
end

-- Danh sách cơ sở (cache 0.25 giây) dùng chung cho ESP và Auto Steal
local BASE_CACHE, BASE_T = {}, 0
local function BaseEggs()
    local now = os.clock()
    if now - BASE_T < 0.25 then return BASE_CACHE end
    BASE_T = now
    local list = {}
    local rp = Root and Root.Parent and Root.Position
    for d in pairs(EGG_IDX) do
        if d.Parent then
            local rar, rnk = DetectRarity(d)
            list[#list + 1] = {
                Inst = d, Name = d.Name, Pos = d.Position, Rarity = rar, Rank = rnk, Value = Val(rar),
                Dist = rp and (d.Position - rp).Magnitude or 99999, Carried = IsCarried(d)
            }
        else
            EGG_IDX[d] = nil
        end
    end
    BASE_CACHE = list
    return list
end

local function ScanEggs(range)
    local eggs = {}
    for _, e in ipairs(BaseEggs()) do
        if e.Dist <= range then eggs[#eggs + 1] = e end
    end
    table.sort(eggs, function(a, b)
        if _G.GOD.Steal.PrioritizeHighest then
            if a.Rank ~= b.Rank then return a.Rank > b.Rank end
            return a.Dist < b.Dist
        end
        return a.Dist < b.Dist
    end)
    return eggs
end

-- ══════════════════════════════════════════════════
-- 🎯 TRỨNG TỐT NHẤT
-- ══════════════════════════════════════════════════
local ALERTED = setmetatable({}, {__mode = "k"})

local function BestEgg()
    -- (bản cũ dùng MaxESPRange cho cả Auto Steal; Auto Steal phải dùng MaxScanRange)
    local eggs = ScanEggs(_G.GOD.Steal.MaxScanRange)
    local minR = Rank(_G.GOD.Steal.MinRarity)
    local best = nil
    for _, e in ipairs(eggs) do
        -- (bản cũ: e.Inst.Parent ~= WS bỏ qua mọi trứng nằm trong Model; ý đúng là bỏ qua trứng đang bị mang)
        local skip = _G.GOD.Steal.IgnoreCarried and e.Carried
        if not skip and e.Rank >= minR then
            if not best or e.Rank > best.Rank or (e.Rank == best.Rank and e.Dist < best.Dist) then
                best = e
            end
        end
    end
    if best and not ALERTED[best.Inst] then
        if best.Rarity == "Divine" and _G.GOD.Blyxo.AlertDivine then
            ALERTED[best.Inst] = true
            Notify("🌟 DIVINE!", best.Name, 5)
        elseif best.Rarity == "Limited" and _G.GOD.Blyxo.AlertLimited then
            ALERTED[best.Inst] = true
            Notify("⚠️ LIMITED!", best.Name, 5)
        end
    end
    return best
end

-- ══════════════════════════════════════════════════
-- ✈️ DI CHUYỂN
-- (bản cũ chỉ Play tween rồi trả về ngay nên nhặt/bay về chạy khi chưa tới nơi; giờ chờ bay xong)
-- ══════════════════════════════════════════════════
local function FlyTo(pos, alive)
    if not Root or not Root.Parent then UpdChar() if not Root then return false end end
    local root = Root
    local dist = (pos - root.Position).Magnitude
    local dur = math.max(0.1, dist / math.max(1, _G.GOD.Steal.FlySpeed))
    local tw = TS:Create(root, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    local finished, state = false, nil
    local c = tw.Completed:Connect(function(s) finished = true state = s end)
    pcall(function() root.Anchored = true end) -- không để trọng lực kéo lệch khi bay
    tw:Play()
    local t0 = os.clock()
    while not finished and os.clock() - t0 < dur + 1.5 do
        if alive and not alive() then break end
        task.wait()
    end
    c:Disconnect()
    if not finished then pcall(function() tw:Cancel() end) end
    pcall(function()
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end)
    return finished and state == Enum.PlaybackState.Completed
end

-- ══════════════════════════════════════════════════
-- 🛡️ BẢO VỆ & TIỆN ÍCH NHÂN VẬT
-- Bản cũ ghi lên Humanoid/Lighting MỖI KHUNG HÌNH và dùng nhiều thuộc tính/enum không tồn tại
-- (FallDamagePerSecond, KnockedBack, CameraShake, FogDensity, LineHandleAdornment.RootPart...) nên lỗi liên tục.
-- Giờ chỉ áp dụng khi bật/tắt, và vòng lặp từng khung hình chỉ làm việc khi có tính năng cần nó.
-- ══════════════════════════════════════════════════
local OrigWalkSpeed = nil
local function ApplyWalkSpeed()
    if not Hum then return end
    if _G.GOD.Chilli.SpeedBoost then
        if not OrigWalkSpeed then OrigWalkSpeed = Hum.WalkSpeed end
        Hum.WalkSpeed = _G.GOD.Chilli.WalkSpeed
    elseif OrigWalkSpeed then
        Hum.WalkSpeed = OrigWalkSpeed
        OrigWalkSpeed = nil
    end
end

local function ApplyGodStates()
    if not Hum then return end
    local on = _G.GOD.Chilli.GodMode or _G.GOD.Chilli.AntiRagdoll
    pcall(function() Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not on) end)
    pcall(function() Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not on) end)
end

-- NoClip: ghi nhớ Part nào được tắt va chạm để trả lại đúng khi tắt
local NC_SAVED = {}
local function ApplyNoClip(on)
    if not Char then return end
    if on then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                NC_SAVED[p] = true
                p.CanCollide = false
            end
        end
    else
        for p in pairs(NC_SAVED) do
            pcall(function() p.CanCollide = true end)
            NC_SAVED[p] = nil
        end
    end
end

-- Fly: LinearVelocity theo hướng camera + MoveDirection
local FLY = {Att = nil, LV = nil, Active = false}
local function StopFly()
    if FLY.LV then SafeDestroy(FLY.LV) FLY.LV = nil end
    if FLY.Att then SafeDestroy(FLY.Att) FLY.Att = nil end
    if FLY.Active and Hum then pcall(function() Hum.PlatformStand = false end) end
    FLY.Active = false
end
local function StartFly()
    if FLY.Active or not Root or not Hum then return end
    local ok = pcall(function()
        FLY.Att = Instance.new("Attachment")
        FLY.Att.Name = "GodFlyAtt"
        FLY.Att.Parent = Root
        FLY.LV = Instance.new("LinearVelocity")
        FLY.LV.Name = "GodFlyLV"
        FLY.LV.Attachment0 = FLY.Att
        FLY.LV.RelativeTo = Enum.ActuatorRelativeTo.World
        FLY.LV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        FLY.LV.MaxForce = math.huge
        FLY.LV.VectorVelocity = Vector3.new(0, 0, 0)
        FLY.LV.Parent = Root
        Hum.PlatformStand = true
    end)
    if ok then FLY.Active = true else StopFly() end
end

local LAST_VOID = 0
local VOID_T = 0
local function HotFlagsOn()
    local G = _G.GOD
    return G.InfiniteYield.Fly or G.Chilli.NoClip or G.InfiniteYield.NoClip or G.Chilli.AntiKnockback
        or G.Chilli.NoFallDamage or G.Chilli.AntiVoid or G.Fluxus.NoCameraShake
end

Track(RS.Heartbeat:Connect(function(dt)
    if not Root or not Root.Parent or not Hum then return end
    local G = _G.GOD
    if not HotFlagsOn() then
        if FLY.Active then StopFly() end
        return
    end

    -- Fly
    if G.InfiniteYield.Fly then
        if not FLY.Active then StartFly() end
        if FLY.LV then
            local cam = WS.CurrentCamera
            local md = Hum.MoveDirection
            if cam and md.Magnitude > 0.05 then
                local o = cam.CFrame:VectorToObjectSpace(md)
                local v = (cam.CFrame.LookVector * -o.Z + cam.CFrame.RightVector * o.X)
                FLY.LV.VectorVelocity = v * (G.InfiniteYield.NoclipSpeed * 3)
            else
                FLY.LV.VectorVelocity = Vector3.new(0, 0, 0)
            end
        end
    elseif FLY.Active then
        StopFly()
    end

    -- NoClip (cả khi bay)
    local wantNC = G.Chilli.NoClip or G.InfiniteYield.NoClip or G.InfiniteYield.Fly
    if wantNC then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                NC_SAVED[p] = true
                p.CanCollide = false
            end
        end
    elseif next(NC_SAVED) then
        ApplyNoClip(false)
    end

    -- Không bị đẩy lùi: cắt vận tốc ngang đột biến (trừ lúc đang bay/tween Anchored)
    if G.Chilli.AntiKnockback and not G.InfiniteYield.Fly and not Root.Anchored then
        local v = Root.AssemblyLinearVelocity
        if Vector3.new(v.X, 0, v.Z).Magnitude > 100 then
            Root.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
        end
    end
    -- Không sát thương rơi: giới hạn tốc độ rơi
    if G.Chilli.NoFallDamage and not Root.Anchored then
        local v = Root.AssemblyLinearVelocity
        if v.Y < -80 then Root.AssemblyLinearVelocity = Vector3.new(v.X, -80, v.Z) end
    end
    if G.Fluxus.NoCameraShake then Hum.CameraOffset = Vector3.new(0, 0, 0) end

    -- Chống rơi vực: kiểm tra thưa (4 lần/giây)
    VOID_T = VOID_T + dt
    if G.Chilli.AntiVoid and VOID_T >= 0.25 then
        VOID_T = 0
        if Root.Position.Y < -80 and os.clock() - LAST_VOID > 3 then
            LAST_VOID = os.clock()
            Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            Root.CFrame = CFrame.new(_G.GOD.Steal.BasePosition)
            Notify("🕳️ Cứu", "Rơi vực → về căn cứ", 2)
        end
    end
end))

-- Nhảy vô hạn (đúng nghĩa: mỗi lần bấm nhảy là nhảy thêm)
Track(UIS.JumpRequest:Connect(function()
    if _G.GOD.Chilli.InfiniteJump and Hum then
        pcall(function() Hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end))

-- Bất tử: đẩy máu về đầy khi bị trừ (theo sự kiện, không chạy mỗi khung hình)
local HealthConn = nil
local function HookChar()
    UpdChar()
    if HealthConn then pcall(function() HealthConn:Disconnect() end) HealthConn = nil end
    if not Hum then return end
    HealthConn = Hum.HealthChanged:Connect(function(h)
        if _G.GOD.Chilli.GodMode and Hum and h < Hum.MaxHealth and h > 0 then
            Hum.Health = Hum.MaxHealth
        end
    end)
    ApplyGodStates()
    ApplyWalkSpeed()
    if _G.GOD.InfiniteYield.JumpPower ~= 50 then
        Hum.UseJumpPower = true
        Hum.JumpPower = _G.GOD.InfiniteYield.JumpPower
    end
    -- Tự hồi sinh
    Hum.Died:Connect(function()
        if _G.GOD.Chilli.AutoRespawn then
            task.wait(1.2)
            pcall(function() LP:LoadCharacter() end) -- chỉ có tác dụng khi game cho phép; game thường tự hồi sinh
        end
    end)
end

Track(LP.CharacterAdded:Connect(function(c)
    -- (bản cũ dùng c.Humanoid ngay lập tức và không cập nhật Root/Hum nên dùng nhân vật cũ đã bị xóa)
    c:WaitForChild("Humanoid", 10)
    c:WaitForChild("HumanoidRootPart", 10)
    NC_SAVED = {}
    StopFly()
    HookChar()
end))

-- Chống AFK (VirtualUser là service, không tạo bằng Instance.new)
pcall(function()
    local VU = game:GetService("VirtualUser")
    Track(LP.Idled:Connect(function()
        if _G.GOD.Chilli.AntiAFK then
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end
    end))
end)

-- Prompt nhặt tức thì (InstantPrompt): không cần giữ phím
pcall(function()
    local PPS = game:GetService("ProximityPromptService")
    Track(PPS.PromptButtonHoldBegan:Connect(function(prompt)
        if _G.GOD.InfiniteYield.InstantPrompt and fireproximityprompt then
            pcall(fireproximityprompt, prompt)
        end
    end))
end)

-- Ánh sáng / FPS: áp dụng khi bật/tắt, giữ lại bằng vòng chậm 1 giây (không phải mỗi khung hình)
local LIGHT_ORIG = nil
local PART_OFF = {}
local function ApplyLighting()
    local D = _G.GOD.Dark
    if D.Fullbright or D.NoFog then
        if not LIGHT_ORIG then
            LIGHT_ORIG = {B = LG.Brightness, GS = LG.GlobalShadows, A = LG.Ambient, FE = LG.FogEnd}
        end
    end
    if D.Fullbright then
        LG.Brightness = 2.5 LG.GlobalShadows = false LG.Ambient = Color3.fromRGB(200, 200, 200)
    elseif LIGHT_ORIG then
        LG.Brightness = LIGHT_ORIG.B LG.GlobalShadows = LIGHT_ORIG.GS LG.Ambient = LIGHT_ORIG.A
    end
    if D.NoFog then
        LG.FogEnd = 100000
        local atm = LG:FindFirstChildOfClass("Atmosphere") -- (FogDensity không phải thuộc tính của Lighting)
        if atm then atm.Density = 0 end
    elseif LIGHT_ORIG then
        LG.FogEnd = LIGHT_ORIG.FE
    end
end

local function ApplyFPSBoost(on)
    if on then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        if _G.GOD.Dark.ParticlesOff then
            task.spawn(function()
                local all = WS:GetDescendants()
                for i = 1, #all do
                    if Dead() or not _G.GOD.Dark.FPSBoost then break end
                    local d = all[i]
                    if d:IsA("ParticleEmitter") and d.Enabled then
                        PART_OFF[d] = true
                        d.Enabled = false
                    end
                    if i % 256 == 0 then task.wait() end
                end
            end)
        end
    else
        for d in pairs(PART_OFF) do
            pcall(function() d.Enabled = true end)
            PART_OFF[d] = nil
        end
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    end
end

task.spawn(function()
    while not Dead() do
        task.wait(1)
        if _G.GOD.Dark.Fullbright or _G.GOD.Dark.NoFog then pcall(ApplyLighting) end
    end
end)

-- ══════════════════════════════════════════════════
-- 👁️ ESP
-- (bản cũ xóa rồi tạo lại TẤT CẢ BillboardGui mỗi 0.5 giây → nháy và nặng; giờ tạo một lần rồi cập nhật chữ)
-- ══════════════════════════════════════════════════
local function ClearESP()
    for part, o in pairs(ESP_Objs) do
        SafeDestroy(o.BG) SafeDestroy(o.HL) SafeDestroy(o.Beam) SafeDestroy(o.A0) SafeDestroy(o.A1)
        ESP_Objs[part] = nil
    end
end

local function DropESP(part, o)
    SafeDestroy(o.BG) SafeDestroy(o.HL) SafeDestroy(o.Beam) SafeDestroy(o.A0) SafeDestroy(o.A1)
    ESP_Objs[part] = nil
end

local function UpdESP()
    local B = _G.GOD.Blyxo
    if not B.ESP_Enabled or not B.ShowEggs then ClearESP() return end
    local eggs = ScanEggs(B.MaxESPRange)
    local C = _G.GOD.Colors
    local keep = {}
    local n = 0
    for _, e in ipairs(eggs) do
        n = n + 1
        if n > 60 then break end
        local part = e.Inst
        keep[part] = true
        local col = C[e.Rarity] or C.Default
        local o = ESP_Objs[part]
        if not o then
            o = {}
            o.BG = Instance.new("BillboardGui")
            o.BG.Name = "GodESP"
            o.BG.AlwaysOnTop = true
            o.BG.Size = UDim2.new(0, 180, 0, 55)
            o.BG.StudsOffset = Vector3.new(0, 3, 0)
            o.BG.MaxDistance = B.MaxESPRange
            o.BG.Adornee = part
            o.BG.Parent = part
            o.L = Instance.new("TextLabel")
            o.L.BackgroundTransparency = 1
            o.L.Font = Enum.Font.GothamBold
            o.L.TextSize = 11
            o.L.Size = UDim2.new(1, 0, 1, 0)
            o.L.Parent = o.BG
            ESP_Objs[part] = o
        end
        -- Chữ theo các công tắc ShowRarity / ShowDistance / ShowValue
        local lines = {e.Name}
        local second = {}
        if B.ShowRarity then second[#second + 1] = e.Rarity end
        if B.ShowDistance then second[#second + 1] = string.format("%.0f studs", e.Dist) end
        if #second > 0 then lines[#lines + 1] = table.concat(second, " • ") end
        if B.ShowValue then lines[#lines + 1] = "$" .. tostring(e.Value) end
        local txt = table.concat(lines, "\n")
        if o.Text ~= txt then o.Text = txt o.L.Text = txt end
        o.L.TextColor3 = col

        if B.Chams then
            if not o.HL then
                o.HL = Instance.new("Highlight")
                o.HL.FillTransparency = 0.6
                o.HL.OutlineTransparency = 0.2
                o.HL.Parent = part
            end
            o.HL.FillColor = col
            o.HL.OutlineColor = col
        elseif o.HL then
            SafeDestroy(o.HL) o.HL = nil
        end

        -- Đường kẻ: dùng Beam (LineHandleAdornment không có RootPart/Attachment0/Attachment1 như bản cũ viết)
        if B.TracerLines and Root and Root.Parent then
            if not o.Beam then
                o.A0 = Instance.new("Attachment") o.A0.Parent = Root
                o.A1 = Instance.new("Attachment") o.A1.Parent = part
                o.Beam = Instance.new("Beam")
                o.Beam.Attachment0 = o.A0
                o.Beam.Attachment1 = o.A1
                o.Beam.Width0 = 0.15 o.Beam.Width1 = 0.15
                o.Beam.FaceCamera = true
                o.Beam.Parent = Root
            end
            o.Beam.Color = ColorSequence.new(col)
        elseif o.Beam then
            SafeDestroy(o.Beam) SafeDestroy(o.A0) SafeDestroy(o.A1)
            o.Beam, o.A0, o.A1 = nil, nil, nil
        end
    end
    for part, o in pairs(ESP_Objs) do
        if not keep[part] or not part.Parent then DropESP(part, o) end
    end
end

local espRun = 0
local function StartESPLoop()
    espRun = espRun + 1
    local id = espRun
    task.spawn(function()
        while not Dead() and espRun == id and _G.GOD.Blyxo.ESP_Enabled do
            local ok, err = pcall(UpdESP)
            if not ok then warn("[GOD HUB] ESP: " .. tostring(err)) end
            task.wait(0.5)
        end
        if espRun == id then ClearESP() end
    end)
end

-- ══════════════════════════════════════════════════
-- 🔄 SERVER HOP / REJOIN
-- (bản cũ "hop" teleport lại ĐÚNG server hiện tại vì dùng game.JobId; giờ chọn server khác còn chỗ)
-- ══════════════════════════════════════════════════
local function ServerHop()
    Notify("🔀 Hop", "Đang tìm server khác...", 2)
    task.spawn(function()
        local ok, res = pcall(function()
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
            return HS:JSONDecode(game:HttpGet(url))
        end)
        if ok and type(res) == "table" and res.data then
            local pool = {}
            for _, s in ipairs(res.data) do
                if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then
                    pool[#pool + 1] = s.id
                end
            end
            if #pool > 0 then
                pcall(function() TServ:TeleportToPlaceInstance(game.PlaceId, pool[math.random(#pool)], LP) end)
                return
            end
        end
        Notify("⚠️ Hop", "Không tìm được server, đang vào lại...", 3)
        pcall(function() TServ:Teleport(game.PlaceId, LP) end)
    end)
end

-- ══════════════════════════════════════════════════
-- 🔄 AUTO STEAL CHÍNH
-- ══════════════════════════════════════════════════
local function ToolCount()
    local n = 0
    local bp = LP:FindFirstChildOfClass("Backpack")
    if Char then for _, c in ipairs(Char:GetChildren()) do if c:IsA("Tool") then n = n + 1 end end end
    if bp then for _, c in ipairs(bp:GetChildren()) do if c:IsA("Tool") then n = n + 1 end end end
    return n
end

-- Nhặt: ClickDetector + ProximityPrompt (bản cũ chỉ ClickDetector con trực tiếp, và luôn tính là đã lấy dù không nhặt được)
local function TryGrab(egg, alive)
    local part = egg.Inst
    local targets = {}
    local scopes = {part}
    if part.Parent and part.Parent ~= WS then scopes[#scopes + 1] = part.Parent end
    for _, s in ipairs(scopes) do
        for _, d in ipairs(s:GetDescendants()) do
            if d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then targets[#targets + 1] = d end
        end
    end
    local before = ToolCount()
    local t0 = os.clock()
    while os.clock() - t0 < 1.5 and alive() do
        if not part:IsDescendantOf(WS) then return true end
        if ToolCount() > before then return true end
        if part.Parent and P:GetPlayerFromCharacter(part.Parent) then return true end -- trứng đã sang tay người chơi
        for _, d in ipairs(targets) do
            pcall(function()
                if d:IsA("ClickDetector") then
                    if fireclickdetector then fireclickdetector(d) end
                elseif fireproximityprompt then
                    fireproximityprompt(d)
                end
            end)
        end
        task.wait(0.15)
    end
    return false
end

-- Bán: cố gắng tìm Prompt/ClickDetector có chữ "sell" (tùy game; không có thì báo)
local SELL_CACHE, SELL_T = nil, 0
local function TrySell()
    local now = os.clock()
    if not SELL_CACHE or not SELL_CACHE.Parent or now - SELL_T > 30 then
        SELL_T = now
        SELL_CACHE = nil
        local all = WS:GetDescendants()
        for i = 1, #all do
            local d = all[i]
            if d:IsA("ProximityPrompt") then
                local a = string.lower((d.ActionText or "") .. " " .. (d.ObjectText or ""))
                if string.find(a, "sell", 1, true) then SELL_CACHE = d break end
            end
            if i % 256 == 0 then task.wait() end
        end
    end
    if SELL_CACHE and fireproximityprompt then
        pcall(fireproximityprompt, SELL_CACHE)
        return true
    end
    return false
end

local autoRunning, autoId = false, 0
local AutoSteal -- khai báo trước (Tab gọi)

AutoSteal = function()
    if autoRunning then return end
    autoRunning = true
    autoId = autoId + 1
    local id = autoId
    local function alive() return _G.GOD.Steal.Enabled and autoId == id and not Dead() end

    local ok, err = pcall(function()
        while alive() do
            task.wait(_G.GOD.Steal.ScanInterval)
            if not alive() then break end
            UpdChar()
            if not Root then
                Notify("⚠️ Đợi", "Tải nhân vật...", 1)
                task.wait(1)
            else
                local Egg = BestEgg()
                if not Egg then
                    if _G.GOD.Steal.RejoinWhenEmpty then
                        Notify("🔄 Hết trứng", "Đổi server...", 2)
                        task.wait(1.5)
                        pcall(function() TServ:Teleport(game.PlaceId, LP) end)
                        return
                    else
                        Notify("🔍 Đang tìm", "Chờ " .. _G.GOD.Steal.MinRarity, 2)
                        task.wait(1.5)
                    end
                else
                    local arrived = FlyTo(Egg.Pos + Vector3.new(0, 3, 0), alive)
                    if arrived and alive() then
                        task.wait(_G.GOD.Steal.GrabDelay)
                        local got = TryGrab(Egg, alive)
                        if got then
                            Stats.Eggs = Stats.Eggs + 1
                            Stats.TotalValue = Stats.TotalValue + Egg.Value
                            if Egg.Rarity == "Divine" then Stats.Divine = Stats.Divine + 1 end
                            Notify("✅ Đã lấy", string.format("%s — %s\nTổng: %d", Egg.Rarity, Egg.Name, Stats.Eggs), 2)
                        else
                            Notify("⚠️ Không nhặt được", Egg.Name, 2)
                        end
                    end
                    -- Về căn cứ (cả khi nhặt không được, để không bị kẹt gần trứng)
                    if _G.GOD.Steal.AutoReturn and alive() then
                        FlyTo(_G.GOD.Steal.BasePosition, alive)
                        task.wait(0.3)
                    end
                    -- Tự bán khi đủ giá trị
                    if _G.GOD.Steal.AutoSell and alive() and Stats.TotalValue - Stats.SoldValue >= _G.GOD.Steal.SellThreshold then
                        if TrySell() then
                            Stats.SoldValue = Stats.TotalValue
                            Notify("💰 Bán", "Đã thử bán trứng", 2)
                        else
                            Notify("💰 Bán", "Không tìm thấy nút bán trong game", 3)
                            Stats.SoldValue = Stats.TotalValue
                        end
                    end
                end
            end
        end
    end)
    if not ok then warn("[GOD HUB] AutoSteal: " .. tostring(err)) end
    pcall(function() if Root then Root.Anchored = false end end)
    autoRunning = false
end

-- ══════════════════════════════════════════════════
-- 🎛️ HÀM BẬT/TẮT (đồng bộ công tắc giao diện)
-- ══════════════════════════════════════════════════
local W = {} -- giữ các công tắc để đồng bộ

local function SetAuto(v)
    _G.GOD.Steal.Enabled = v and true or false
    if W.auto then W.auto:Set(_G.GOD.Steal.Enabled, true) end
    if _G.GOD.Steal.Enabled then task.spawn(AutoSteal) end
end
local function SetESP(v)
    _G.GOD.Blyxo.ESP_Enabled = v and true or false
    if W.esp then W.esp:Set(_G.GOD.Blyxo.ESP_Enabled, true) end
    if _G.GOD.Blyxo.ESP_Enabled then StartESPLoop() end
end
local function SetGod(v)
    _G.GOD.Chilli.GodMode = v and true or false
    if W.god then W.god:Set(_G.GOD.Chilli.GodMode, true) end
    ApplyGodStates()
    if _G.GOD.Chilli.GodMode and Hum and Hum.Health < Hum.MaxHealth and Hum.Health > 0 then Hum.Health = Hum.MaxHealth end
end
local function SetFly(v)
    _G.GOD.InfiniteYield.Fly = v and true or false
    if W.fly then W.fly:Set(_G.GOD.InfiniteYield.Fly, true) end
    if not _G.GOD.InfiniteYield.Fly then StopFly() end
end
local function SetNoClipFlag(v)
    _G.GOD.Chilli.NoClip = v and true or false
    _G.GOD.InfiniteYield.NoClip = _G.GOD.Chilli.NoClip
    if W.nc1 then W.nc1:Set(_G.GOD.Chilli.NoClip, true) end
    if W.nc2 then W.nc2:Set(_G.GOD.Chilli.NoClip, true) end
end

-- ══════════════════════════════════════════════════
-- ⌨️ LỆNH TRONG CHAT
-- ══════════════════════════════════════════════════
local Cmd = {
    fly = function() SetFly(not _G.GOD.InfiniteYield.Fly); Notify("✈️ Fly", _G.GOD.InfiniteYield.Fly and "BẬT" or "TẮT") end,
    god = function() SetGod(not _G.GOD.Chilli.GodMode); Notify("🛡️ God", _G.GOD.Chilli.GodMode and "BẬT" or "TẮT") end,
    esp = function() SetESP(not _G.GOD.Blyxo.ESP_Enabled); Notify("👁️ ESP", _G.GOD.Blyxo.ESP_Enabled and "BẬT" or "TẮT") end,
    auto = function() SetAuto(not _G.GOD.Steal.Enabled); Notify("🟢 Auto", _G.GOD.Steal.Enabled and "BẬT" or "TẮT") end,
    speed = function(s)
        local v = tonumber(s) or 32
        _G.GOD.Chilli.WalkSpeed = v
        if Hum then Hum.WalkSpeed = v end
        Notify("⚡ Tốc độ", tostring(v))
    end,
    tp = function(n)
        if not Root or not n or n == "" then return end
        local key = string.lower(n)
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= LP and string.find(string.lower(p.Name), key, 1, true) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                Root.CFrame = p.Character.HumanoidRootPart.CFrame
                Notify("🌀 TP", "Đến " .. p.Name)
                return -- (bản cũ không dừng nên với tên rỗng/ngắn sẽ dịch chuyển qua hết mọi người)
            end
        end
    end,
    rejoin = function() Notify("🔄 Rejoin", "Đang vào lại...", 2); task.wait(1.5); pcall(function() TServ:Teleport(game.PlaceId, LP) end) end,
    hop = function() ServerHop() end,
    base = function() if Root then _G.GOD.Steal.BasePosition = Root.Position; Notify("📍 Đã lưu", "Căn cứ", 3) end end,
    stats = function()
        local t = math.floor((os.time() - Stats.StartTime) / 60)
        Notify("📊 Thống kê", string.format("Trứng: %d | Divine: %d | Giá trị: %s | %d phút", Stats.Eggs, Stats.Divine, tostring(Stats.TotalValue), t), 6)
    end,
    divine = function() _G.GOD.Steal.MinRarity = "Divine"; if W.dd then W.dd:Set("Divine", true) end; Notify("🌟 Ưu tiên", "Chỉ lấy Divine", 3) end,
    sell = function() _G.GOD.Steal.AutoSell = not _G.GOD.Steal.AutoSell; if W.sell then W.sell:Set(_G.GOD.Steal.AutoSell, true) end; Notify("💰 AutoSell", _G.GOD.Steal.AutoSell and "BẬT" or "TẮT") end,
    help = function() Notify("📜 Lệnh", ";fly ;god ;esp ;auto ;speed ;tp ;rejoin ;hop ;base ;stats ;divine ;sell ;help", 6) end
}

-- Đã bỏ hoàn toàn bộ nhận lệnh từ khung chat; các nút giao diện vẫn hoạt động.\n\n-- Click TP (chuột phải)
Track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if _G.GOD.InfiniteYield.ClickTeleport and i.UserInputType == Enum.UserInputType.MouseButton2 then
        local Cam = WS.CurrentCamera
        local R = Cam:ScreenPointToRay(i.Position.X, i.Position.Y)
        local Res = WS:Raycast(R.Origin, R.Direction * 5000)
        if Res and Root then Root.CFrame = CFrame.new(Res.Position + Vector3.new(0, 3, 0)) end
    end
end))

-- ══════════════════════════════════════════════════
-- 🎨 8 TAB GIAO DIỆN
-- ══════════════════════════════════════════════════

-- TAB 1: TRỘM TRỨNG
local T1 = UI:Tab({Name = "🥚 Trộm Trứng", Icon = "egg"})
W.auto = T1:Toggle({Name = "🟢 Bật Auto Steal", Default = false, Callback = function(s) SetAuto(s) end})
W.only = T1:Toggle({Name = "🌟 Chỉ lấy Divine", Default = true, Callback = function(s)
    _G.GOD.Steal.MinRarity = s and "Divine" or "Mythic"
    if W.dd then W.dd:Set(_G.GOD.Steal.MinRarity, true) end
end})
W.dd = T1:Dropdown({Name = "Lọc từ độ hiếm", List = RARITY_LIST, Default = "Divine", Callback = function(v) _G.GOD.Steal.MinRarity = v end})
T1:Slider({Name = "Tốc độ bay", Min = 50, Max = 800, Default = 450, Callback = function(v) _G.GOD.Steal.FlySpeed = v end})
T1:Slider({Name = "Độ trễ nhặt", Min = 0, Max = 2, Default = 0.05, Callback = function(v) _G.GOD.Steal.GrabDelay = v end})
T1:Toggle({Name = "🔄 Tự về căn cứ", Default = true, Callback = function(s) _G.GOD.Steal.AutoReturn = s end})
T1:Toggle({Name = "🔀 Đổi server khi hết", Default = false, Callback = function(s) _G.GOD.Steal.RejoinWhenEmpty = s end})
W.sell = T1:Toggle({Name = "💰 Tự bán trứng", Default = false, Callback = function(s) _G.GOD.Steal.AutoSell = s end})
T1:Button({Name = "📍 Lưu vị trí căn cứ", Callback = function() Cmd.base() end})
T1:Button({Name = "📊 Thống kê", Callback = function() Cmd.stats() end})

-- TAB 2: BẢO VỆ
local T2 = UI:Tab({Name = "🛡️ Bảo Vệ", Icon = "shield"})
W.god = T2:Toggle({Name = "🛡️ Bất Tử", Default = false, Callback = function(s) SetGod(s) end})
T2:Toggle({Name = "🚫 Chống đẩy lùi", Default = false, Callback = function(s) _G.GOD.Chilli.AntiKnockback = s end})
T2:Toggle({Name = "🍂 Không nhận sát thương rơi", Default = false, Callback = function(s) _G.GOD.Chilli.NoFallDamage = s end})
W.nc1 = T2:Toggle({Name = "👻 NoClip xuyên tường", Default = false, Callback = function(s) SetNoClipFlag(s) end})
T2:Toggle({Name = "💀 Tự hồi sinh", Default = false, Callback = function(s) _G.GOD.Chilli.AutoRespawn = s end})
T2:Toggle({Name = "⚡ Tăng tốc chạy", Default = false, Callback = function(s) _G.GOD.Chilli.SpeedBoost = s; ApplyWalkSpeed() end})
T2:Slider({Name = "Tốc độ chạy", Min = 16, Max = 250, Default = 32, Callback = function(v) _G.GOD.Chilli.WalkSpeed = v; ApplyWalkSpeed() end})
T2:Toggle({Name = "🦘 Nhảy vô hạn", Default = false, Callback = function(s) _G.GOD.Chilli.InfiniteJump = s end})
T2:Toggle({Name = "🕳️ Chống rơi vực", Default = true, Callback = function(s) _G.GOD.Chilli.AntiVoid = s end})
T2:Toggle({Name = "⏰ Chống đá AFK", Default = true, Callback = function(s) _G.GOD.Chilli.AntiAFK = s end})

-- TAB 3: ESP
local T3 = UI:Tab({Name = "👁️ ESP", Icon = "eye"})
W.esp = T3:Toggle({Name = "👁️ Bật ESP", Default = false, Callback = function(s) SetESP(s) end})
T3:Toggle({Name = "🥚 Hiện trứng", Default = true, Callback = function(s) _G.GOD.Blyxo.ShowEggs = s end})
T3:Toggle({Name = "🏷️ Hiện độ hiếm", Default = true, Callback = function(s) _G.GOD.Blyxo.ShowRarity = s end})
T3:Toggle({Name = "📏 Hiện khoảng cách", Default = true, Callback = function(s) _G.GOD.Blyxo.ShowDistance = s end})
T3:Toggle({Name = "💰 Hiện giá trị", Default = true, Callback = function(s) _G.GOD.Blyxo.ShowValue = s end})
T3:Toggle({Name = "🌟 Báo Divine", Default = true, Callback = function(s) _G.GOD.Blyxo.AlertDivine = s end})
T3:Toggle({Name = "⚠️ Báo Limited", Default = true, Callback = function(s) _G.GOD.Blyxo.AlertLimited = s end})
T3:Toggle({Name = "✨ Highlight xuyên tường", Default = false, Callback = function(s) _G.GOD.Blyxo.Chams = s end})
T3:Toggle({Name = "📏 Đường kẻ từ bạn", Default = false, Callback = function(s) _G.GOD.Blyxo.TracerLines = s end})

-- TAB 4: DI CHUYỂN
local T4 = UI:Tab({Name = "✈️ Di Chuyển", Icon = "plane"})
W.fly = T4:Toggle({Name = "✈️ Bay", Default = false, Callback = function(s) SetFly(s) end})
W.nc2 = T4:Toggle({Name = "👻 NoClip", Default = false, Callback = function(s) SetNoClipFlag(s) end})
T4:Toggle({Name = "🖱️ Click TP chuột phải", Default = false, Callback = function(s) _G.GOD.InfiniteYield.ClickTeleport = s end})
T4:Slider({Name = "Tốc độ bay / NoClip", Min = 10, Max = 100, Default = 16, Callback = function(v) _G.GOD.InfiniteYield.NoclipSpeed = v end})
T4:Slider({Name = "Lực nhảy", Min = 10, Max = 200, Default = 50, Callback = function(v)
    _G.GOD.InfiniteYield.JumpPower = v
    if Hum then Hum.UseJumpPower = true Hum.JumpPower = v end
end})
T4:Slider({Name = "Trọng lực", Min = 50, Max = 600, Default = 196, Callback = function(v) WS.Gravity = v end})

-- TAB 5: TỐI ƯU
local T5 = UI:Tab({Name = "⚡ Tối Ưu", Icon = "zap"})
T5:Toggle({Name = "🚀 FPS Boost", Default = false, Callback = function(s) _G.GOD.Dark.FPSBoost = s; ApplyFPSBoost(s) end})
T5:Toggle({Name = "💡 Fullbright", Default = false, Callback = function(s) _G.GOD.Dark.Fullbright = s; ApplyLighting() end})
T5:Toggle({Name = "🌫️ Tắt sương mù", Default = false, Callback = function(s) _G.GOD.Dark.NoFog = s; ApplyLighting() end})
T5:Toggle({Name = "📷 Tắt rung màn hình", Default = false, Callback = function(s) _G.GOD.Fluxus.NoCameraShake = s end})
T5:Slider({Name = "Góc nhìn FOV", Min = 50, Max = 120, Default = 70, Callback = function(v) if WS.CurrentCamera then WS.CurrentCamera.FieldOfView = v end end})
-- (bản cũ chỉ đặt cờ ServerHop mà không làm gì; giờ bật là đổi server rồi tự tắt)
local tHop
tHop = T5:Toggle({Name = "🔀 Server Hop", Default = false, Callback = function(s)
    _G.GOD.Dark.ServerHop = s
    if s then
        ServerHop()
        task.delay(2, function() _G.GOD.Dark.ServerHop = false tHop:Set(false, true) end)
    end
end})

-- TAB 6: LỆNH NHANH
local T6 = UI:Tab({Name = "⌨️ Lệnh", Icon = "terminal"})
T6:Label({Text = "Điều khiển bằng các nút trong hub"})
T6:Button({Name = "✈️ Bật/Tắt Fly", Callback = function() Cmd.fly() end})
T6:Button({Name = "🛡️ Bật/Tắt GodMode", Callback = function() Cmd.god() end})
T6:Button({Name = "👁️ Bật/Tắt ESP", Callback = function() Cmd.esp() end})
T6:Button({Name = "🟢 Bật/Tắt Auto Steal", Callback = function() Cmd.auto() end})
T6:Button({Name = "🔄 Rejoin Server", Callback = function() Cmd.rejoin() end})
T6:Button({Name = "🔀 Server Hop", Callback = function() Cmd.hop() end})
T6:Button({Name = "📍 Lưu Căn Cứ", Callback = function() Cmd.base() end})
T6:Button({Name = "📊 Thống Kê", Callback = function() Cmd.stats() end})

-- TAB 7: CẤU HÌNH
local T7 = UI:Tab({Name = "🎨 Cấu Hình", Icon = "gear"})
T7:Toggle({Name = "🔔 Âm thanh thông báo", Default = true, Callback = function(s) _G.GOD.Rayfield.NotifySound = s end})
T7:Toggle({Name = "💾 Tự lưu cấu hình", Default = true, Callback = function(s) _G.GOD.Rayfield.AutoSaveConfig = s end})
T7:Button({Name = "📜 Xem thứ tự độ hiếm", Callback = function() Notify("🏆 Độ hiếm", "Divine → Limited → Eternal → Secret → Cosmic → Exclusive → Rainbow → Mythic → Legendary → ...", 6) end})

-- TAB 8: THÔNG TIN
local T8 = UI:Tab({Name = "ℹ️ Thông Tin", Icon = "info"})
T8:Label({Text = "🥚 GOD TIER HUB — Phiên bản v5.1"})
T8:Label({Text = "✅ Không cần key | Giao diện tự dựng, không tải mã từ internet"})
T8:Label({Text = "✅ Có nút thu gọn [−] góc trên trái, kéo thanh tiêu đề để di chuyển, kéo góc ◢ để đổi cỡ"})
T8:Label({Text = "✅ Dùng các nút trong hub để điều khiển"})
T8:Label({Text = "Chúc bạn farm được nhiều Divine! 🌟"})

-- Dọn khi chạy lại script
_G.__GOD_CLEANUP = function()
    ALIVE.dead = true
    _G.GOD.Steal.Enabled = false
    _G.GOD.Blyxo.ESP_Enabled = false
    for _, c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
    pcall(StopFly)
    pcall(function() ApplyNoClip(false) end)
    pcall(ClearESP)
    pcall(function() UI:Destroy() end)
end

-- ══════════════════════════════════════════════════
-- ✅ KHỞI ĐỘNG
-- ══════════════════════════════════════════════════
HookChar()
Notify("✅ ĐÃ SẴN SÀNG", "GOD TIER HUB v5.1 — CÓ NÚT THU GỌN", 5)
