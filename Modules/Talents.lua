local DF = LibStub('AceAddon-3.0'):GetAddon('DragonflightUI')
local mName = 'Talents'
local Module = DF:NewModule(mName, 'AceConsole-3.0')

Mixin(Module, DragonFlightUITalentsMixin)

ActiveTalentIDs = {
    --mage
    [86] = true,
    [87] = true,
    [29] = true,
    [32] = true,
    [36] = true,
    [69] = true,
    [71] = true
    --
}

local db
local background

local defaults = {
    profile = {
        talentSize = 36,
        padding = 22,
        scale = 1.0
    }
}

local function getOption(info)
    return db[info[#info]]
end

local function setOption(info, value)
    local key = info[1]
    Module.db.profile[key] = value
end

local function setDefaultValues()
    for k, v in pairs(defaults.profile) do Module.db.profile[k] = v end
end

local options = {
    type = 'group',
    name = 'DragonflightUI - ' .. mName,
    get = getOption,
    set = setOption,
    args = {
        toggle = {
            type = 'toggle',
            name = 'Enable',
            get = function()
                return DF:GetModuleEnabled(mName)
            end,
            set = function(info, v)
                DF:SetModuleEnabled(mName, v)
            end,
            order = 1
        },

        reload = {
            type = 'execute',
            name = '/reload',
            desc = 'reloads UI',
            func = function()
                ReloadUI()
            end,
            order = 1.1
        },
        defaults = {
            type = 'execute',
            name = 'Defaults',
            desc = 'Sets Config to default values',
            func = setDefaultValues,
            order = 1.1
        },
        config = { type = 'header', name = 'Config - Player', order = 100 },
        talentSize = {
            type = 'range',
            name = 'Talent size',
            desc = 'Talent button size',
            min = 32,
            max = 64,
            bigStep = 1,
            order = 103.1
        },
        padding = {
            type = 'range',
            min = 0,
            max = 60,
            bigStep = 1,
            name = 'Padding',
            desc = 'Padding',
            order = 1.3
        },
        scale = {
            type = 'range',
            min = 0.2,
            max = 2.0,
            bigStep = 0.1,
            name = 'scale',
            order = 1.4
        },
    }
}

function Module:OnInitialize()
    DF:Debug(self, 'Module ' .. mName .. ' OnInitialize()')
    self.db = DF.db:RegisterNamespace(mName, defaults)
    db = self.db.profile

    self:SetEnabledState(DF:GetModuleEnabled(mName))
    DF:RegisterModuleOptions(mName, options)
end

function Module:OnEnable()
    DF:Debug(self, 'Module ' .. mName .. ' OnEnable()')
    if DF.Wrath then
        Module.Wrath()
    else
        Module.Era()
    end
end

function Module.Wrath()
    local Hide = function(self)
        self:Hide()
    end
    PlayerTalentFrameTab1:HookScript("OnShow", Hide);
    PlayerTalentFrameTab2:HookScript("OnShow", Hide);
    PlayerTalentFrameTab3:HookScript("OnShow", Hide);
    PlayerTalentFrameBackgroundTopLeft:HookScript("OnShow", Hide);
    PlayerTalentFrameBackgroundBottomLeft:HookScript("OnShow", Hide);
    PlayerTalentFrameBackgroundBottomRight:HookScript("OnShow", Hide);
    PlayerTalentFrameBackgroundTopRight:HookScript("OnShow", Hide);
    PlayerTalentFrameScrollFrame:HookScript("OnShow", Hide);

    PlayerTalentFrameTopLeft:HookScript("OnShow", Hide);
    PlayerTalentFrameTopRight:HookScript("OnShow", Hide);
    PlayerTalentFrameBottomRight:HookScript("OnShow", Hide);
    PlayerTalentFrameBottomLeft:HookScript("OnShow", Hide);
    PlayerTalentFramePortrait:HookScript("OnShow", Hide);
    PlayerTalentFramePointsBar:HookScript("OnShow", Hide);
    local sizeX, sizeY = Module:GetWindowSize()
    PlayerTalentFrame:SetSize(sizeX, sizeY)

    PlayerTalentFrameCloseButton:ClearAllPoints()
    PlayerTalentFrameCloseButton:SetPoint("TOPRIGHT", PlayerTalentFrame, "TOPRIGHT", 0, 0)

    background = CreateFrame("FRAME", "MyBackground", PlayerTalentFrame, "BackdropTemplate")
    
    --background:SetPoint("CENTER", 22, -35)
    background:ClearAllPoints()
    background:SetPoint("CENTER", PlayerTalentFrame, "CENTER", 0, 0)

    background:SetSize(sizeX, sizeY) 
    local backdropInfo =
    {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    }

    background:SetBackdrop(backdropInfo)
    background.classImage = background:CreateTexture("TalentBakground", "BACKGROUND")
    background.classImage:SetTexture('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\Classes\\mage')
    background.classImage:ClearAllPoints()
    background.classImage:SetPoint("CENTER", background, "CENTER")
    background.classImage:SetTexCoord(0, 1614 / 2048, 0, 776 / 1024)

    background.classImage:SetSize(sizeX - 2, sizeY - 2) -- Set these to whatever height/width is needed

    for i = 1, GetNumTalentTabs() do
        for j = 1, GetNumTalents(i) do
            print(i, j, GetTalentInfo(i, j))
            Module:DoButton(i, j)
        end
    end

    local setPoint = PlayerTalentFrame.SetPoint
    hooksecurefunc(PlayerTalentFrame, "SetPoint", function(self)
        self:ClearAllPoints()
        setPoint(self, 'CENTER')
    end)

    PlayerTalentFrame:HookScript("OnShow", function(self)
        -- background.texture:SetAllPoints(background)
        -- background.texture:SetTexture('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\Classes\\mage_small')
        -- background.texture:SetColorTexture(1, 1, 1, 1)
        background:Show()
    end)
end

function Module:GetWindowSize()
    return 1614 * Module.db.profile.scale, 776 * Module.db.profile.scale
end

function Module:DoButton(i, j)
    local size = Module.db.profile.talentSize
    local borderSize = 4;

    local _, iconTexture, tier, column, rank, maxRank, _, available, _, _, talentID = GetTalentInfo(i,
        j)
    local newButton = CreateFrame("Button", nil, PlayerTalentFrame)
    local buttonPosX, buttonPosY = Module:GetButtonPosition(column, tier, i)

    newButton:SetPoint("TOPLEFT", buttonPosX, buttonPosY)
    newButton:SetSize(size, size)
    newButton:EnableMouseMotion(true)

    local prereqsY, prereqsX, _, _ = GetTalentPrereqs(i, j);
    if prereqsX and prereqsY then
        --local prereqPosX, prereqPosY = Module:GetButtonPosition(column + 1, tier, i)
        local prereqPosX, prereqPosY = Module:GetButtonPosition(prereqsX, prereqsY, i)

        Module:ConnectTalents(buttonPosX, buttonPosY, prereqPosX, prereqPosY)
    end

    local mask = newButton:CreateMaskTexture()

    local isActiveTalent = Module:IsActiveTalent(talentID)

    if isActiveTalent then
        mask:SetMask('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\talentsmasknodechoiceflyout')
    else
        mask:SetMask('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\talentsmasknodecircle')
    end

    mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(size, size)
    mask:SetPoint("CENTER")

    newButton.background = newButton:CreateTexture("ButtonBackground", "BACKGROUND")

    local backgroundTexture, borderTexture;
    if isActiveTalent then
        backgroundTexture = 'Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\active_background'
        if rank == maxRank then
            borderTexture = 'Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\active_gold'
        else
            borderTexture = 'Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\active_border'
        end
    else
        backgroundTexture = 'Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\passive_background'
        if rank == maxRank then
            borderTexture = 'Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\passive_gold'
        else
            borderTexture = 'Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\passive_border'
        end
    end

    newButton.background:SetTexture(backgroundTexture)
    newButton.background:AddMaskTexture(mask)
    newButton.background:SetAllPoints(newButton)

    newButton.icon = newButton:CreateTexture("Icon", "ARTWORK")
    newButton.icon:SetTexture(iconTexture)
    newButton.icon:SetTexCoord(2 / 64, (64 - 2) / 64, 2 / 64, (64 - 2) / 64)
    newButton.icon:AddMaskTexture(mask)
    newButton.icon:SetSize(size - borderSize, size - borderSize)
    newButton.icon:SetPoint("CENTER", newButton, "CENTER")

    newButton.border = newButton:CreateTexture("Border", "OVERLAY")
    newButton.border:SetTexture(borderTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "TRILINEAR")
    newButton.border:AddMaskTexture(mask)
    newButton.border:SetSize(size, size)
    newButton.border:SetPoint("CENTER", newButton, "CENTER")

    if available and rank == 0 then
        newButton.icon:SetDesaturated(1)
    end

    newButton:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self)
        GameTooltip:SetTalent(i, j)
        GameTooltip:Show()
    end)

    newButton:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function Module:GetButtonPosition(column, row, tab)
    local padding = Module.db.profile.padding
    local size = Module.db.profile.talentSize
    local windowWidth, _ = Module:GetWindowSize()

    --assuming 4 columns per tree and 3 trees
    local reqTabSize = size * 4 + padding * 3
    local tabSpace = windowWidth / 3

    return ((tab - 1) * tabSpace + (tabSpace - reqTabSize) / 2) + (column - 1) * (size + padding),
        -row * (size + padding)
end

function Module:IsActiveTalent(ID)
    return ActiveTalentIDs[ID]
end

function Module:ConnectTalents(toX, toY, fromX, fromY)
    local size = Module.db.profile.talentSize

    --well, when drawing line between two adjacent atlent buttons, move from point up to the middle of the button
    if toY == fromY then
        toY = toY - size / 2
        fromY = toY
        fromX = fromX - size / 2
    else
        fromY = fromY - size
    end

    local lineWidth = 8;

    local arrowLine = CreateFrame("FRAME", "ArrowLine", PlayerTalentFrame)
    arrowLine:ClearAllPoints()
    arrowLine:SetPoint("BOTTOM", PlayerTalentFrame, "TOPLEFT", toX + (size) / 2, toY)
    arrowLine:SetSize(lineWidth,
        math.sqrt(math.pow(math.abs(toY) - math.abs(fromY), 2) + math.pow(math.abs(toX) - math.abs(fromX), 2)))

    arrowLine.texture = arrowLine:CreateTexture("Line", "ARTWORK")
    arrowLine.texture:SetTexture('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\arrow_line_gold', "CLAMP",
        "REPEAT", "TRILINEAR")
    arrowLine.texture:SetHorizTile(false)
    arrowLine.texture:SetVertTile(true)
    arrowLine.texture:ClearAllPoints()
    arrowLine.texture:SetAllPoints(arrowLine)

    arrowLine.pointerTexture = arrowLine:CreateTexture("Pointer", "ARTWORK")
    arrowLine.pointerTexture:SetTexture('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\arrow_gold', "CLAMP",
        "REPEAT", "TRILINEAR")

    arrowLine.pointerTexture:SetDrawLayer("ARTWORK", 7)

    local arrowSize = 20
    arrowLine.pointerTexture:SetSize(arrowSize, arrowSize)
    arrowLine.pointerTexture:SetPoint("BOTTOM", PlayerTalentFrame, "TOPLEFT", toX + size / 2, toY)

    local vec = { toX - fromX, toY - fromY };
    local dir = { 0, -1 }

    local ansAgain = math.acos(Module:Dot(vec, dir) / (Module:Mag(vec) * Module:Mag(dir)))

    if fromX < toX then
        arrowLine.texture:SetRotation(ansAgain, { x = 0.5, y = 0 })
        arrowLine.pointerTexture:SetRotation(ansAgain, { x = 0.5, y = 0 })
    else
        arrowLine.texture:SetRotation(-ansAgain, { x = 0.5, y = 0 })
        arrowLine.pointerTexture:SetRotation(-ansAgain, { x = 0.5, y = 0 })
    end
end

function Module.MakeBorder()
    local bottomLeft = PlayerTalentFrame:CreateTexture("Border", "ARTWORK")
    bottomLeft:SetTexture('Interface\\Common\\ThinBorder-BottomLeft')
    bottomLeft:ClearAllPoints()
    bottomLeft:SetPoint("BOTTOMLEFT", PlayerTalentFrame, "BOTTOMLEFT")
    bottomLeft:SetSize(32, 32)
end


-- Era
function Module.Era()
    Module.Wrath()
end

function Module:Dot(a, b)
    return (a[1] * b[1]) + (a[2] * b[2])
end

function Module:Mag(a)
    return math.sqrt((a[1] * a[1]) + (a[2] * a[2]))
end
