-- minecraft version is: 1.18.2
-- cc-tweaked version is: 1.101.0
-- valkyrien- computers version is: 1.0.1+e01d52e7d8
-- valkyrien skies version is: 2.1.0-beta9
-- vs eureka version is: 1.1.0-beta5

-- This script should be run on an ender pocket computer and in the best case there is an gps system for follow mode
-- also use an ender modem and an ender pocket computer


local x,y,z,follow = ...
local password = "abcde1234"
local shipChannel = 6789
local receiveChannel = 5671
local modem = peripheral.find("modem")

modem.open(receiveChannel)

if follow == nil then
    follow = false
else
    follow = true
end
print("Follow Mode: " .. tostring(follow))

local payload = {x=x, y=y, z=z, password=password, receiveChannel=receiveChannel}

-- shows the log the ship is sending
local function showLog()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if (channel == receiveChannel) and (tostring(message.log) == "break") then
            print("\n--- Stopped ---")
            break
        elseif (channel == receiveChannel) and (tostring(message.log) == "done") then
            print("\n--- Done ---")
            break
        elseif (channel == receiveChannel) and (message.distance ~= nil) then
            print(message.distance .. "m | " .. tostring(message.log))
        elseif channel == receiveChannel then
            print(tostring(message.log))
        end
    end  
end

if follow then
    while true do
        x,y,z = gps.locate()
        y = 211
        payload = {x=x, y=y, z=z, password=password, receiveChannel=receiveChannel}
        modem.transmit(shipChannel, receiveChannel, payload)
        print("Transmitted Position: " .. x .. " " .. y .. " " .. z)
        sleep(10)
    end
else
    modem.transmit(shipChannel, receiveChannel, payload)
    showLog()
end
