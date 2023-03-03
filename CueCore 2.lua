local masterIntensity = (NamedControl.GetValue("masterIntensity"))
local masterRate = (NamedControl.GetValue("masterRate"))
local masterFade = NamedControl.GetValue("masterFade")
local Track = NamedControl.GetValue("Track")
local Enable = NamedControl.GetPosition("Enable")
local Connected = false
local fadeMultiplier = nil
local blinkTimer = 0
NamedControl.SetPosition("Connected", 0)

local Intensity = {
    [1] = (NamedControl.GetValue("Intensity1")),
    [2] = (NamedControl.GetValue("Intensity2")),
    [3] = (NamedControl.GetValue("Intensity3")),
    [4] = (NamedControl.GetValue("Intensity4")),
    [5] = (NamedControl.GetValue("Intensity5")),
    [6] = (NamedControl.GetValue("Intensity6"))
}

local Rate = {
    [1] = (NamedControl.GetValue("Rate1")),
    [2] = (NamedControl.GetValue("Rate2")),
    [3] = (NamedControl.GetValue("Rate3")),
    [4] = (NamedControl.GetValue("Rate4")),
    [5] = (NamedControl.GetValue("Rate5")),
    [6] = (NamedControl.GetValue("Rate6"))
}

function HandleData(socket, packet)

    if packet.Data:match("cue=%d") then
        if Connected == false then
            NamedControl.SetPosition("Connected", 1)
            Connected = true
        end
        local playBack = packet.Data:match("%-%d%-")
        playBack = string.gsub(playBack, "-", "")
        local Cue = packet.Data:match "=%d"
        Cue = string.gsub(Cue, "=", "")
        NamedControl.SetValue("Cue" .. playBack, Cue)

    elseif packet.Data:match("fade=") then
        local fadeTime = string.gsub(packet.Data, "core%-pb%-fade=", "")
        NamedControl.SetText("fadeTime", "Fade Duration: " .. fadeTime)
    end
end

function Initialize()

    for i = 1, 6 do
        MyUdp:Send(IP, 7000, "core-pb-" .. i .. "-go+")
        MyUdp:Send(IP, 7000, "core-pb-" .. i .. "-go-")
    end
end

MyUdp = UdpSocket.New()
MyUdp:Open(Device.LocalUnit.ControlIP, 0)
MyUdp.Data = HandleData



function TimerClick()

    playList = NamedControl.GetValue("playList")
    IP = NamedControl.GetText("IP")


    if NamedControl.GetPosition("Connect") == 1 then
        Initialize()
        NamedControl.SetPosition("Connect", 0)
    end

    if NamedControl.GetPosition("Disconnect") == 1 then
        Connected = false
        NamedControl.SetPosition("Connected", 0)
        NamedControl.SetPosition("Disconnect", 0)
    end

    if Connected then

        blinkTimer = blinkTimer + 1

        if blinkTimer == 10 then
            NamedControl.SetPosition("Active", 0)

        elseif blinkTimer == 20 then
            NamedControl.SetPosition("Active", 1)
            MyUdp:Send(IP, 7000, "core-blink")
            blinkTimer = 0
        end

        for i = 1, 6 do
            if NamedControl.GetPosition("Go+" .. i) == 1 then
                MyUdp:Send(IP, 7000, "core-pb-" .. i .. "-go+")
                NamedControl.SetPosition("Go+" .. i, 0)
            end
            if NamedControl.GetPosition("Go-" .. i) == 1 then
                MyUdp:Send(IP, 7000, "core-pb-" .. i .. "-go-")
                NamedControl.SetPosition("Go-" .. i, 0)
            end
            if NamedControl.GetPosition("Release" .. i) == 1 then
                MyUdp:Send(IP, 7000, "core-pb-" .. i .. "-release")
                NamedControl.SetPosition("Release" .. i, 0)
            end
            if NamedControl.GetValue("Jump" .. i) == 1 then
                MyUdp:Send(IP, 7000, "core-pb-" .. i .. "-jump=" .. (NamedControl.GetValue("jumpValue" .. i)))
                NamedControl.SetPosition("Jump" .. i, 0)
            end
            if NamedControl.GetValue("Intensity" .. i) ~= Intensity[i] then
                MyUdp:Send(IP, 7000, "core-pb-" .. i .. "-intensity=" .. (NamedControl.GetValue("Intensity" .. i) / 100))
                Intensity[i] = NamedControl.GetValue("Intensity" .. i)
            end
            if NamedControl.GetValue("Rate" .. i) ~= Rate[i] then
                MyUdp:Send(IP, 7000, "core-pb-" .. i .. "-rate=" .. (NamedControl.GetValue("Rate" .. i) / 100))
                Rate[i] = NamedControl.GetValue("Rate" .. i)
            end

            if NamedControl.GetPosition("masterRelease") == 1 then
                MyUdp:Send(IP, 7000, "core-pb-release")
                NamedControl.SetPosition("masterRelease", 0)
            end
            if NamedControl.GetValue("masterIntensity") ~= masterIntensity then
                MyUdp:Send(IP, 7000, "core-pb-intensity=" .. (NamedControl.GetValue("masterIntensity") / 100))
                masterIntensity = NamedControl.GetValue("masterIntensity")
            end
            if NamedControl.GetValue("masterRate") ~= masterRate then
                MyUdp:Send(IP, 7000, "core-pb-rate=" .. (NamedControl.GetValue("masterRate") / 100))
                masterRate = NamedControl.GetValue("masterRate")
            end
            if NamedControl.GetValue("masterFade") ~= masterFade then
                MyUdp:Send(IP, 7000, "core-pb-fade=" .. (NamedControl.GetValue("masterFade")))
                masterFade = NamedControl.GetValue("masterFade")
            end
        end
    end
end

MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(.25)


--Comands not used
-- if NamedControl.GetPosition("Zero") == 1 then
--     MyUdp:Send(IP, 7000, "core-pb-fade=0")
--     NamedControl.SetValue("masterFade", 0)
--     NamedControl.SetPosition("Zero", 0)
-- end

-- if NamedControl.GetValue("Track") ~= Track then
--     MyUdp:Send(IP, 7000, "core-tr-select=" .. (NamedControl.GetValue("Track")))
--     Track = NamedControl.GetValue("Track")
-- end
-- if NamedControl.GetPosition("Erase") == 1 then
--     MyUdp:Send(IP, 7000, "core-tr-erase")
--     NamedControl.SetPosition("Erase", 0)
-- end
-- if NamedControl.GetPosition("Record") == 1 then
--     MyUdp:Send(IP, 7000, "core-tr-record")
--     NamedControl.SetPosition("Record", 0)
-- end
-- if NamedControl.GetPosition("Stop") == 1 then
--     MyUdp:Send(IP, 7000, "core-tr-stop")
--     NamedControl.SetPosition("Stop", 0)
-- end
-- if NamedControl.GetPosition("Button") == 1 then
--     MyUdp:Send(IP, 7000, "core-al-1-enable=false")
--     NamedControl.SetPosition("Button", 0)
-- end
-- if NamedControl.GetPosition("Enable") ~= Enable then
--     print(Enable)
--     Enable = NamedControl.GetPosition("Enable")
-- end
