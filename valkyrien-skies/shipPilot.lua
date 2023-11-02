-- minecraft version is: 1.18.2
-- cc-tweaked version is: 1.101.0
-- valkyrien- computers version is: 1.0.1+e01d52e7d8
-- valkyrien skies version is: 2.1.0-beta9
-- vs eureka version is: 1.1.0-beta5

-- This script nees a ship reader from valkyrien computers and a helm from eureka
-- also use an ender modem and an ender pocket computer


local reader = peripheral.wrap("back")
local helm = peripheral.wrap("right")
local modem = peripheral.find("modem")
local receiveChannel = 6789
local sendDebugChannel = 5671
local password = "abcde1234"
local command = "waiting"
local heightCommand = "waiting"
local travelHeight = 210 -- TravelHeight as Y-coordinates
local redstoneSide = "front"

local rotX, rotY, rotZ, rotW = reader.getRotation()
local posX, posY, posZ = reader.getWorldspacePosition()
local start = {x = posX, y = posY, z = posZ}
local target = {x = -8061, y = 12, z = -763}
local maxTolerance = 4
local maxDistance = 4
local maxYDistance = 4
local yDifference

-- determine the vektor between start and target coordinates
local function getTargetVector()
    local start = {x = posX, y = posY, z = posZ}
    local targetVector = {x = target.x - start.x, z = target.z - start.z}
    return targetVector
end
local targetVector = getTargetVector()

-- determine the distance between start and target coordinates
local function getTargetDistance(targetVector)
    local targetDistance = math.sqrt(targetVector.x^2 +  targetVector.z^2)
    return targetDistance
end
local targetDistance = getTargetDistance(targetVector)

-- Radians into degrees
local function radiansToDegrees(radians)
    local degrees = radians * (180 / math.pi)
    return degrees
end

-- Function to turn a quaternion into degrees
local function quaternionToDegrees(rotX, rotY, rotZ, rotW)
    local pitch = math.asin(2 * rotW * rotX - 2 * rotY * rotZ)
    --local yaw = math.atan(2 * rotW * rotY + 2 * rotZ * rotX, 1 - 2 * rotX * rotX - 2 * rotY * rotY) -- if this fails then try math.atan2 instad of math.atan
    local yaw = math.atan2(2*rotY*rotW-2*rotX*rotZ,1-2*rotY*rotY-2*rotZ*rotZ)

    pitch = pitch * 180 / math.pi
    yaw = yaw * 180 / math.pi
  
    return (yaw * -1) -- put here [+ 90, -90, or +-180] if the autoping is not working correctly
end

-- determine the angle between the targetvector and the vector from the ship pointing towards south (angle=0)
local function skalar(targetVector, targetDistance, start)
    local southVector = {x = start.x - start.x, z = start.z - start.z +1}
    local kreuzprodukt = targetVector.x * southVector.x + targetVector.z * southVector.z
    local southVectorLength = math.sqrt(southVector.x^2 + southVector.z^2)
    local vectorLengthsMultiplied = targetDistance * southVectorLength
    local kreuzproduktBetrag = math.sqrt(kreuzprodukt^2)
    local cosAngle = kreuzprodukt / vectorLengthsMultiplied
    local angle = radiansToDegrees(math.acos(cosAngle)) 
    -- determine if the angle is positive or negative
    if targetVector.x >= 0 then
        angle = angle * -1
    end
    return angle-- angle is now in degrees
end



local shipRot = quaternionToDegrees(rotX, rotY, rotZ, rotW)
local angle = skalar(targetVector, targetDistance, start)



local function calcDiffernce(shipRot, angle)
    

    -- creating 360 degree versions of the angles
    local fullShipRot = shipRot
    local fullAngle = angle

    if shipRot < 0 then
        fullShipRot = shipRot + 360
        -- print("Ship Rotation 360 version: ".. shipRot + 360)
    end

    if angle < 0 then
        fullAngle = angle + 360
        -- print("Angle 360 version: ".. angle + 360)
    end

    local D = (fullAngle - fullShipRot) % 360

    if D > 180 then
        D = D - 360
    end
    return D
end

local D = calcDiffernce(shipRot, angle)

local function correctDirection()
    print("correcting course")
    while math.sqrt(D^2) > maxTolerance do
        posX, posY, posZ = reader.getWorldspacePosition()
        start = {x = posX, y = posY, z = posZ}
        targetVector = getTargetVector()
        targetDistance = getTargetDistance(targetVector)
        rotX, rotY, rotZ, rotW = reader.getRotation()
        shipRot = quaternionToDegrees(rotX, rotY, rotZ, rotW)
    
        -- checking difference
        D = calcDiffernce(shipRot, angle)
    
        if D < 0 then
            helm.impluseLeft(1)
        else
            helm.impulseRight(1)
        end
    
        -- print("TargetAngle: "..angle)   
        -- print("ShipAngle: "..shipRot)
        -- print("TargetAngle: "..angle)
        sleep(0.001)
    end
end

local function reachTravelHeight()
    while true do
        while heightCommand == "engage" do
            posX, posY, posZ = reader.getWorldspacePosition()
            while (posY < travelHeight) and (heightCommand == "engage") do
                helm.impulseUp(3)
                posX, posY, posZ = reader.getWorldspacePosition()
                sleep(0.001)
            end
            if (posY >= travelHeight) then
                heightCommand = "waiting"
                print("Reached TravelHeight: " .. travelHeight .. "m")
                modem.transmit(sendDebugChannel, receiveChannel, {log = "Reached TravelHeight: " .. travelHeight .. "m"})
                command = "drive"
            end
            sleep(0.001)
        end
        sleep(0.001)
    end
end

local function driveShip()
    while true do
        while command == "drive" do
            posX, posY, posZ = reader.getWorldspacePosition()
            start = {x = posX, y = posY, z = posZ}
            
            rotX, rotY, rotZ, rotW = reader.getRotation()
            shipRot = quaternionToDegrees(rotX, rotY, rotZ, rotW)
            
            target = target
            targetVector = getTargetVector()
            targetDistance = getTargetDistance(targetVector)
            angle = skalar(targetVector, targetDistance, start)
            D = calcDiffernce(shipRot, angle)
            if math.sqrt(D^2) > maxTolerance then
                correctDirection()
            elseif targetDistance > maxDistance then
                helm.impulseForward(5)
            else
                yDifference = tonumber(target.y) - posY
                while (math.sqrt((tonumber(target.y) - posY)^2) > maxYDistance) and command == "drive" do
                    posX, posY, posZ = reader.getWorldspacePosition()
                    if yDifference < 0 then
                        helm.impulseDown(3)
                    elseif yDifference >= 0 then
                        helm.impulseUp(3)
                    end
                    sleep(0.001)
                end
                
                target = target
                targetVector = getTargetVector()
                targetDistance = getTargetDistance(targetVector)
                if targetDistance <= maxDistance then
                    command = "waiting"
                    modem.transmit(sendDebugChannel, receiveChannel, {log = "Destination reached: " .. tonumber(math.ceil(posX)) .. " " .. tonumber(math.ceil(posY)) .. " " .. tonumber(math.ceil(posZ))})
                    modem.transmit(sendDebugChannel, receiveChannel, {log = "done"})
                    print("Destination reached")
                    redstone.setAnalogOutput(redstoneSide, 15)
                    break
                end
            end
            sleep(0.001)
        end
        sleep(0.1)
    end
end

local function commandManagement()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        
        if (channel == receiveChannel) and (message.password == password) then
            command = "waiting"
            target.x = message.x
            target.y = message.y
            target.z = message.z
            sleep(0.5)
            heightCommand = "engage"
            redstone.setAnalogOutput(redstoneSide, 0)
            targetVector = getTargetVector()
            targetDistance = getTargetDistance(targetVector)
            print("Confirming TravelHeight: " .. travelHeight .. "m")
            modem.transmit(sendDebugChannel, receiveChannel, {log = "Confirming TravelHeight: " .. travelHeight .. "m"})
            print("New Destination confirmed: " .. tonumber(math.ceil(targetDistance)) .. "m")
            modem.transmit(sendDebugChannel, receiveChannel, {log = "New Destination confirmed", distance = tonumber(math.ceil(targetDistance))})
        end
    end
    
end

modem.open(receiveChannel)
redstone.setAnalogOutput(redstoneSide, 15)
print("---Autopilot engaged---\n")

parallel.waitForAll(commandManagement, driveShip, reachTravelHeight)