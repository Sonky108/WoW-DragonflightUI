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
    Module.ApplySettings()
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
        }
    }
}

function Module:OnInitialize()
    DF:Debug(self, 'Module ' .. mName .. ' OnInitialize()')

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
    PlayerTalentFrame:SetSize(1000, 500)

    PlayerTalentFrameCloseButton:ClearAllPoints()
    PlayerTalentFrameCloseButton:SetPoint("TOPRIGHT", PlayerTalentFrame, "TOPRIGHT", 0, 0)
    
    background = CreateFrame("FRAME", "MyBackground", PlayerTalentFrame)
    --background:SetPoint("CENTER", 22, -35)
    background:ClearAllPoints()
    background:SetPoint("CENTER", PlayerTalentFrame, "CENTER", 0, 0)

    background:SetSize(PlayerTalentFrame:GetWidth(), PlayerTalentFrame:GetHeight()) -- Set these to whatever height/width is needed 

    background.texture = background:CreateTexture("TalentBakground", "BACKGROUND")
    background.texture:SetTexture('Interface\\AddOns\\DragonflightUI\\Textures\\Talents\\Classes\\mage')
    background.texture:ClearAllPoints()
    background.texture:SetAllPoints(background)
    background.texture:SetTexCoord(0, 1614 / 2048, 0, 388 / 512)

    background.texture:SetSize(PlayerTalentFrame:GetWidth(), PlayerTalentFrame:GetHeight())  -- Set these to whatever height/width is needed 

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
    local size = 40;
    local padding = 60;
    local borderSize = 3;

    local name, iconTexture, tier, column, rank, maxRank, isExceptional, available, hopsa, kol, koniec = GetTalentInfo(i, j)
    local newButton = CreateFrame("Button", nil, PlayerTalentFrame)
    newButton:SetPoint("TOPLEFT", (i - 1) * 300 + column * padding, -tier * padding)
    newButton:SetSize(size, size) -- Set these to whatever height/width is needed 

    newButton:EnableMouseMotion(true)
    print(GetTalentPrereqs(i,j))

   
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

function Module:IsActiveTalent(ID)
    return ActiveTalentIDs[ID]
end

function Module:ConnectTalents(fromI, fromJ, toI, toJ)

end

-- Era
function Module.Era()
    Module.Wrath()
end