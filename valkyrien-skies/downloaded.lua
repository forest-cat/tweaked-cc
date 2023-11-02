---@diagnostic disable: lowercase-global
--INSTRUCTIONS:
--Download this file to your ship and name this file "remoteShip.lua"
--It takes in one argument, the number for the channel the ship will be communicating on.
--You will need a Eureka ship helm, a computer, a wireless/ender modem, and a ship reader from Valkyrien Computers.
--./remoteShip.lua channel
channel = tonumber(...)

if channel == nil then
	print("Please specify a channel to communicate on")
	os.exit()
end


modem = peripheral.find("modem")
reader = peripheral.find("ship_reader")
helm = peripheral.find("ship_helm")

playerX = 0
playerY = 0
playerZ = 0

function getCoord(s, coord)
    coordStart = string.find(s,coord)
    coordEnd = string.find(s," ",coordStart)
    print("Finding the value of "..coord.." in message: "..s)
    val = string.sub(s,coordStart+2,coordEnd-1)
    print("Value = "..val)
    return tonumber(val)
end

function lowerShip()
    local x,y,z = reader.getWorldspacePosition()
    while y > playerY do
        helm.impulseDown(10)
        sleep(0)
        x,y,z = reader.getWorldspacePosition()
    end
    return true
end

function raiseShip()
    local x,y,z = reader.getWorldspacePosition()
    while y < 100 do
        helm.impulseUp(10)
        sleep(0)
        x,y,z = reader.getWorldspacePosition()
    end
    return true
end

function getYaw()
    rotX,rotY,rotZ,rotW = reader.getRotation()
    shipYaw = math.atan2(2*rotY*rotW-2*rotX*rotZ,1-2*rotY*rotY-2*rotZ*rotZ)
    return shipYaw
end

function getIdealYaw()
    shipX,shipY,shipZ = reader.getWorldspacePosition()
    idealYaw = math.atan2(shipX-playerX,shipZ-playerZ)
    return idealYaw
end

function getDistanceFromPlayer()
    shipX,shipY,shipZ = reader.getWorldspacePosition()
    distanceX = playerX - shipX
    distanceZ = playerZ - shipZ
    distance = math.sqrt(distanceX*distanceX + distanceZ * distanceZ)
    
    return distance
end

function rotateShip()
    idealYaw = getIdealYaw()
    print("idealYaw: "..idealYaw*(180/3.14159))
    facing = false
    while not facing do
        shipYaw = getYaw()
        sleep(0)
        if shipYaw > idealYaw - 0.2 and shipYaw < idealYaw + 0.2 then
           print("shipYaw: "..shipYaw*(180/3.14159))
            facing = true
        else
            helm.impulseRight(1)
        end
    end
end

function moveShip()
    prevDistance = 999999
    shipX,shipY,shipZ = reader.getWorldspacePosition()
    while shipX < playerX - 10 or shipX > playerX + 10 or shipZ < playerZ - 5 or shipZ > playerZ + 5 do
        distance = getDistanceFromPlayer()
       print(distance)
         if distance > prevDistance+1 then
        print(distance)
            helm.impulseRight(30)
            print("idealYaw: "..getIdealYaw()*(180/3.14159))
            print("shipYaw: "..getYaw()*(180/3.14159))
        end
        if getYaw() < getIdealYaw() - 0.05 or shipYaw > getIdealYaw(playerX,playerZ) + 0.05 then
            rotateShip()
        end
        helm.impulseForward(10)
        prevDistance = distance
        sleep(0)
    end    
    return true
end

function navigateShip(msg)
    
    playerX = getCoord(msg,"x")
    playerY = getCoord(msg,"y")
    playerZ = getCoord(msg,"z")

    raiseShip()
    rotateShip()
    moveShip()
    lowerShip()

end



print("Checking if channel "..channel.." is open...")

if not modem.isOpen(channel) then
    print("Opening channel "..channel.."...")
    modem.open(channel)
end
print("Channel open!")
while true do
    print("Listening for messages...")
    local event, modemSide, senderChannel, 
        replyChannel, message, 
        senderDistance = os.pullEvent("modem_message")
	if senderChannel == channel then
    print("------")
    print("Received Message!")
    print("Sender channel: "..senderChannel)
    print("Reply channel: "..replyChannel)
    print("Message contents: "..message)
    print("Sender distance: "..senderDistance.." blocks away")
    print(" ")
        
    if string.find(message, "comeHither") ~= nil then
        print("Correctly formatted message! Navigating to coordinates...")
        navigateShip(message)
        modem.transmit(replyChannel,channel,"Ship moved to coordinates")
        print("Navigation ended.")
    else
        print("Incorrectly formatted message.  Sending reply...")
        modem.transmit(replyChannel, channel, "Incorrect message format.  Ship recall message should look as follows:\n \"comeHither, x:xCoord y:yCoord z:zCoord playerName:playerName\"")
    end
    print("------")
end
end
     
            
    