local basalt = require("basalt")
local monitor = peripheral.wrap("right")
local mon_width, mon_height = monitor.getSize()
local main = basalt.createFrame():setMonitor("right")
local reactor = peripheral.wrap("left")
 
main:setBackground(colors.black)
 
--Making the title
local title = main:addLabel()
local frame_width, frame_height = main:getSize()
local titleText = "Fission Reactor Control"
title:setText(titleText)
title:setPosition(((frame_width / 2) - (#titleText / 2)) ,1)
title:setSize(mon_width, 6)

-- Temperature --
local temperatureLabel = main:addLabel()
temperatureLabel:setPosition(2,3)

local temperatureProgress = main:addProgressbar()
local temperaturePercent = (reactor.getTemperature() / 1200) * 100
 
temperatureProgress:setSize(mon_width - 2, 2)
temperatureProgress:setProgress(temperaturePercent)
temperatureProgress:setPosition(2, 5)
 
-- Fuel --
local fuelTitle = main:addLabel()
fuelTitle:setPosition(2, 9)
local fuelProgress = main:addProgressbar()

fuelProgress:setSize(mon_width -2, 2)
fuelProgress:setPosition(2, 11)
fuelProgress:setProgressBar(colors.lightGray)

-- Steam --
local steamTitle = main:addLabel()
steamTitle:setPosition(2, 15)
local steamProgress = main:addProgressbar()

steamProgress:setSize(((mon_width -3) / 2), 2)
steamProgress:setPosition(2, 17)
steamProgress:setProgressBar(colors.white)

-- Nuclear Waste --
local wasteTitle = main:addLabel()
wasteTitle:setPosition(3, 15)
wasteTitle:setAnchor("top")
local wasteProgress = main:addProgressbar()

wasteProgress:setSize(((mon_width -3) / 2), 2)
wasteProgress:setAnchor("top")
wasteProgress:setPosition(3, 17)
wasteProgress:setProgressBar(colors.brown)

-- Coolant --
local coolantTitle = main:addLabel()
coolantTitle:setPosition(2, 21)
local coolantProgress = main:addProgressbar()

coolantProgress:setSize(((mon_width -3) / 2), 2)
coolantProgress:setPosition(2, 23)
coolantProgress:setProgressBar(colors.blue)

-- Status Button --
local statusButton = main:addButton()
statusButton:setAnchor("topRight")
statusButton:setText("")
statusButton:setPosition(-4, 22)
statusButton:setSize(5,3)

-- Button --
local switch = main:addButton()
if reactor.getStatus() then
    switch:setText("Online")
    switch:setBackground(colors.red)
else
    switch:setText("Offline")
    switch:setBackground(colors.green)
end
switch:setAnchor("top")
switch:setSize(26, 3)
switch:setPosition(3, 22)
switch:setForeground(colors.white)

switch:onClick(function(self, event, button, x,y)
    if (event=="mouse_click") then
        switch:setBackground(colors.lightGray)
        statusButton:setBackground(colors.orange)
        if (reactor.getStatus()) then
            switch:setText("Stopping")
            reactor.scram()
        else
            switch:setText("Starting")
            reactor.activate()
        end
    end
end)


 

local function ReactorUpdateLoop()
    while true do
        -- Setting Temperature --
        temperatureLabel:setText("Temperature: " .. string.format("%.2f", reactor.getTemperature()) .. "K")
        local temperaturePercent = (reactor.getTemperature() / 1200) * 100
        -- Temperature Progressbar color checks
        if temperaturePercent < 50 then
            temperatureProgress:setProgressBar(colors.green)
        end
        if temperaturePercent >= 50 and temperaturePercent < 83 then
            temperatureProgress:setProgressBar(colors.orange)
        end
        if temperaturePercent >= 83 then
            temperatureProgress:setProgressBar(colors.red)
        end
            temperatureProgress:setProgress(temperaturePercent)

        -- Setting Fuel --
        fuelTitle:setText("Fissile Fuel: " .. string.format("%d", reactor.getFuel()["amount"]):reverse():gsub("(%d%d%d)", "%1."):reverse() .. "mB" .. " / " .. string.format("%d", reactor.getFuelCapacity()):reverse():gsub("(%d%d%d)", "%1."):reverse() .. "mB")
        local fuelPercent = (reactor.getFuel()["amount"] / reactor.getFuelCapacity()) * 100
        fuelProgress:setProgress(fuelPercent)

        -- Setting Steam --
        local steamPercent = reactor.getHeatedCoolantFilledPercentage() * 100
        steamTitle:setText("Heated Coolant: " .. string.format("%.2f", steamPercent) .. "%")
        steamProgress:setProgress(steamPercent)

        -- Setting Nuclear Waste --
        local wastePercent = reactor.getWasteFilledPercentage() * 100
        wasteTitle:setText("Nuclear Waste: " .. string.format("%.2f", wastePercent) .. "%")
        wasteProgress:setProgress(wastePercent)

        -- Setting Coolant --
        local coolantPercent = reactor.getCoolantFilledPercentage() * 100
        coolantTitle:setText("Coolant: " .. string.format("%.2f", coolantPercent) .. "%")
        coolantProgress:setProgress(coolantPercent)
        
        -- Reactor Button --
        if (reactor.getStatus()) then
            switch:setText("SCRAM")
            switch:setBackground(colors.red)
            statusButton:setBackground(colors.green)
        else
            switch:setText("ACTIVATE")
            switch:setBackground(colors.green)
            statusButton:setBackground(colors.red)
        end
        
        
        os.sleep(0.5)
    end
end

parallel.waitForAll(basalt.autoUpdate, ReactorUpdateLoop)