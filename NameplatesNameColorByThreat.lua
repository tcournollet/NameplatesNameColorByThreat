local function updateNameplatesNameColor(frame)
    local unit = frame.displayedUnit;

    if not unit or not unit:match('nameplate%d*') then return end;
    if not C_NamePlate.GetNamePlateForUnit(unit) then return end;
    if (not frame.name:IsShown()) then return end;
    if (frame.UpdateNameOverride and frame:UpdateNameOverride()) then return end;
    if (not ShouldShowName(frame)) then return end;
    if (CompactUnitFrame_IsTapDenied(frame) or (UnitIsDead(unit) and not UnitIsPlayer(unit))) then return end;

    local status = UnitThreatSituation("player", unit);
    if (status) then
        if (status > 0) then
            frame.name:SetVertexColor(GetThreatStatusColor(status));
        else
            frame.name:SetVertexColor(1.0, 1.0, 1.0);
        end
    end
end

local initFrameName = "NameplatesNameColorByThreatFrame";
local initFrame = _G[initFrameName];
local isInitFrameExist = false;
if (initFrame and initFrame:GetObjectType() == "Frame") then
    isInitFrameExist = true;
end

if  (not isInitFrameExist) then
    initFrame = CreateFrame("Frame", initFrameName);
    initFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

    local function onEvent(self, event, ...)
        if (event == "PLAYER_ENTERING_WORLD") then
            local initialLogin, reloadingUI = ...;
            if (initialLogin or reloadingUI) then
                hooksecurefunc("CompactUnitFrame_UpdateName", updateNameplatesNameColor)

                local trackThreatFrameName = "UpdateNameColorByThreatFrame";
                local trackThreatFrame = _G[trackThreatFrameName];

                if (not trackThreatFrame or trackThreatFrame:GetObjectType() ~= "Frame") then
                    local trackThreatFrame = CreateFrame("Frame", trackThreatFrameName);
                    trackThreatFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");

                    local function onEvent(self, event, ...)
                        if (event == "UNIT_THREAT_SITUATION_UPDATE") then
                            updateNameplatesNameColor(self);
                        end
                    end

                    trackThreatFrame:SetScript("OnEvent", onEvent);
                end

                self:UnregisterAllEvents();
            end
        end
    end

    initFrame:SetScript("OnEvent", onEvent);
end