-- File: JumpCounter.lua
-- Name: JumpCounter
-- Author: Aic, Zolerii
-- Description: Counts the number of times you jump
-- Version: 0.1.0

local UPDATE_PERIOD = 0.5
local elapsed = 0
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataObj = ldb:NewDataObject("Jump Counter", {type = "data source", text = "0 Jumps"})
local frame = CreateFrame("frame")

-- Write jumps to data broker
frame:SetScript(
    "OnUpdate",
    function(self, elap)
        elapsed = elapsed + elap
        if elapsed < UPDATE_PERIOD then
            return
        end

        elapsed = 0
        local fps = GetFramerate()
        dataObj.text = string.format("%d Jumps", JumpCounter)
    end
)

-- Write data broker tool tip
function dataObj:OnTooltipShow()
    self:AddLine("Total Jumps")
end

function dataObj:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    GameTooltip:ClearLines()
    dataObj.OnTooltipShow(GameTooltip)
    GameTooltip:Show()
end

function dataObj:OnLeave()
    GameTooltip:Hide()
end

local function CreateMilestoneMessage()
    local icon = "|TInterface\\Icons\\INV_Gizmo_supersappercharge:32|t"
    local color = "|cFFDAA520"
    local message = string.format("Congratulations, It's your %sth Jump!", JumpCounter)

    return string.format("%s %s %s %s", icon, color, message, icon)
end

local function AtMilestone()
    return JumpCounter == 10 or JumpCounter == 100 or JumpCounter == 1000 or mod(JumpCounter, 5000) == 0
end

local function AccounceMilestone()
    if AtMilestone() then
        DEFAULT_CHAT_FRAME:AddMessage(CreateMilestoneMessage())
    end
end

local function GetCurrentJumpCount()
    return JumpCounter or 0
end

local function PerformJump()
    JumpCounter = GetCurrentJumpCount() + 1
    AccounceMilestone()
end

hooksecurefunc(
    "JumpOrAscendStart",
    function()
        if not IsFalling() and not IsFlying() then
            PerformJump()
        end
    end
)

-- slash command
for i, v in ipairs({"jc", "jumpcounter", "jumpcount"}) do
    _G["SLASH_JUMPCOUNTER" .. i] = "/" .. v
end

SlashCmdList.JUMPCOUNTER = function(msg)
    if not msg or msg == "" then
        if JumpCounter == nil then
            JumpCounter = 0
        end
        DEFAULT_CHAT_FRAME:AddMessage(string.format("You have jumped %s times.", GetCurrentJumpCount()))
    elseif (msg == "clear") then
        JumpCounter = 0
    end
end
