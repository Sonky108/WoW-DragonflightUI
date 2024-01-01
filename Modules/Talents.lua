local DF = LibStub('AceAddon-3.0'):GetAddon('DragonflightUI')
local mName = 'Talents'
local Module = DF:NewModule(mName, 'AceConsole-3.0')

Mixin(Module, DragonFlightUITalentsMixin)

ActiveTalentIDs = {[86] = true, [87] = true, [29] = true, [32] = true, [36] = true, [69] = true,
[71] = true}

local db
local background
local function getOption(info)
    return db[info[#info]]
end

local function setOption(info, value)
    local key = info[1]
    Module.db.profile[key] = value
    --Module.ApplySettings()
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
        config = {type = 'header', name = 'Config - Player', order = 100},
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
        WindowWidth = {
            type = 'range',
            min = 500,
            max = 1500,
            bigStep = 10,
            name = 'WindowWidth',
            desc = 'WindowWidth',
            order = 1.4
        },
        WindowHeight = {
            type = 'range',
            min = 400,
            max = 1000,
            bigStep = 1,
            name = 'WindowHeight',
            desc = 'WindowHeight',
            order = 1.5
        }
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
    local Hide = function( self)
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
    PlayerTalentFrame:SetSize(Module.db.profile.WindowWidth, Module.db.profile.WindowHeight)

    PlayerTalentFrameCloseButton:ClearAllPoints()
    PlayerTalentFrameCloseButton:SetPoint("TOPRIGHT", PlayerTalentFrame, "TOPRIGHT", 0, 0)
    
    background = CreateFrame("FRAME", "MyBackground", PlayerTalentFrame)
    --background:SetPoint("CENTER", 22, -35)
    background:ClearAllPoints()
    background:SetPoint("CENTER", PlayerTalentFrame, "CENTER", 0, 0)

    background:SetSize(Module.db.profile.WindowWidth, Module.db.profile.WindowHeight)-- Set these to whatever height/width is needed 

    background.texture = background:CreateTexture("TalentBakground", "BACKGROUND")
    background.texture:SetTexture('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\Classes\\mage')
    background.texture:ClearAllPoints()
    background.texture:SetAllPoints(background)
    background.texture:SetTexCoord(0, 1614 / 2048, 0, 388 / 512)

    background.texture:SetSize(Module.db.profile.WindowWidth, Module.db.profile.WindowHeight) -- Set these to whatever height/width is needed 

    for i = 1, GetNumTalentTabs() do
        for j = 1,  GetNumTalents(i) do
            print(i, j, GetTalentInfo(i, j))
            Module:DoButton(i, j)
        end
    end

    local setPoint = PlayerTalentFrame.SetPoint
    hooksecurefunc(PlayerTalentFrame, "SetPoint", function (self)
        self:ClearAllPoints()
        setPoint(self, 'CENTER')
    end)

    PlayerTalentFrame:HookScript("OnShow", function (self)
        -- background.texture:SetAllPoints(background)
        -- background.texture:SetTexture('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\Classes\\mage_small')
        -- background.texture:SetColorTexture(1, 1, 1, 1)
        background:Show()
    end)
end

function Module:DoButton(i, j)
    local size = Module.db.profile.talentSize;
    local borderSize = 3;

    local name, iconTexture, tier, column, rank, maxRank, isExceptional, available, hopsa, kol, koniec = GetTalentInfo(i, j)
    local newButton = CreateFrame("Button", nil, PlayerTalentFrame)
    local buttonPosX, buttonPosY = Module:GetButtonPosition(column, tier, i)
    newButton:SetPoint("TOPLEFT", buttonPosX, buttonPosY)
    newButton:SetSize(size, size) -- Set these to whatever height/width is needed 

    newButton:EnableMouseMotion(true)
    print(GetTalentPrereqs(i,j))

    local prereqsY, prereqsX, ee, wwae = GetTalentPrereqs(i,j);
    if prereqsX and prereqsY then
        local prereqPosX, prereqPosY = Module:GetButtonPosition(prereqsX + 1, prereqsY, i)
        Module:ConnectTalents(buttonPosX, buttonPosY, prereqPosX, prereqPosY)
    end
   
    local mask = newButton:CreateMaskTexture()

    local isActiveTalent = Module:IsActiveTalent(koniec)

    if isActiveTalent then
        mask:SetMask('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\talentsmasknodechoiceflyout')
    else
        mask:SetMask('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\talentsmasknodecircle')
    end

    mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(size, size)
    mask:SetPoint("CENTER")

    newButton.background = newButton:CreateTexture("ButtonBackground", "BACKGROUND")
    
    local backgroundTexture, borderTexture
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
    --newButton.background:SetTexCoord(2 / 64, (64 - 2) / 64, 2 / 64, (64 - 2) / 64)
    newButton.background:AddMaskTexture(mask)
    newButton.background:SetAllPoints(newButton)

    newButton.icon = newButton:CreateTexture("Icon", "ARTWORK")
    newButton.icon:SetTexture(iconTexture)
    newButton.icon:SetTexCoord(2 / 64, (64 - 2) / 64, 2 / 64, (64 - 2) / 64)
    newButton.icon:AddMaskTexture(mask)
    newButton.icon:SetSize(size - borderSize, size - borderSize)
    newButton.icon:SetPoint("CENTER", newButton, "CENTER")

    newButton.border = newButton:CreateTexture("Border", "OVERLAY")
    newButton.border:SetTexture(borderTexture)
    newButton.border:AddMaskTexture(mask)
    newButton.border:SetSize(size, size)
    newButton.border:SetPoint("CENTER", newButton, "CENTER")

    if available and rank == 0 then
        newButton.icon:SetDesaturated(1)
    end

    newButton:HookScript("OnEnter", function (self)
        --self.texture:SetVertexColor(1.0, 0.0, 0.0)
        GameTooltip:SetOwner(self)
        GameTooltip:SetTalent(i, j)
        GameTooltip:Show()
    end)

    newButton:HookScript("OnLeave", function (self)
        --self.texture:SetVertexColor(1.0, 1.0, 1.0)
        GameTooltip:Hide()
    end)
end

function Module:GetButtonPosition(column, row, tab)
    local padding = Module.db.profile.padding
    local size = Module.db.profile.talentSize
    local windowWidth = Module.db.profile.WindowWidth

    local reqTabSize = size * 4 + padding * 3
    local tabSpace = windowWidth / 3

    return ((tab - 1) * tabSpace + (tabSpace - reqTabSize) / 2) + (column - 1) * (size + padding), -row * (size + padding)
end

function Module:IsActiveTalent(ID)
    return ActiveTalentIDs[ID]
end

function Module:ConnectTalents(toX, toY, fromX, fromY)
    print(toX, toY, fromX, fromY, "CONNECT")
    local size = Module.db.profile.talentSize
    local lineWidth = 16;

    local arrowLine = CreateFrame("FRAME", "ArrowLine", PlayerTalentFrame)
    --background:SetPoint("CENTER", 22, -35)
    arrowLine:ClearAllPoints()
    local anchor = "BOTTOM"
    
    arrowLine:SetPoint(anchor, PlayerTalentFrame, "TOPLEFT", toX  + (size) / 2, toY)
    arrowLine:SetSize(lineWidth, math.sqrt(math.pow(math.abs(toY) - math.abs(fromY), 2) + math.pow(math.abs(toX) - math.abs(fromX), 2)))

    arrowLine.texture = arrowLine:CreateTexture("Line", "ARTWORK")
    arrowLine.texture:SetTexture('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\arrow_line_gold', "CLAMP", "REPEAT", "TRILINEAR")
    arrowLine.texture:SetHorizTile(false)
    arrowLine.texture:SetVertTile(true)

    arrowLine.texture:ClearAllPoints()
    arrowLine.texture:SetAllPoints(arrowLine)

    local from = {fromX, fromY}
    local to = {toX, toY}
    local vec = {toX - fromX, toY - fromY};
    local Left = {0, -1}

    local ansAgain = math.acos(Module:myDot(vec, Left) / (Module:myMag(vec) * Module:myMag(Left)))

    if fromX < toX then
        arrowLine.texture:SetRotation(ansAgain, {x =0.5, y =0})
    else
        arrowLine.texture:SetRotation(-ansAgain, {x =0.5, y =0})
    end
    
    --arrowLine.texture:SetSize(arrowLine:GetWidth(), arrowLine:GetHeight())
    --arrowLine.texture:SetSize(arrowLine:GetHeight(), arrowLine:GetWidth())
    print(math.deg(ansAgain), "ANGUL")
end

-- Era
function Module.Era()
    Module.Wrath()
end

function Module:myDot(a, b)
    return (a[1] * b[1]) + (a[2] * b[2])
end

function Module:myMag(a)
    return math.sqrt((a[1] * a[1]) + (a[2] * a[2]))
end