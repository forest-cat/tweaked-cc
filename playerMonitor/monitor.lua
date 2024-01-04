local monitor = peripheral.wrap("right")
local playerDetector = peripheral.wrap("top")
local pcPos = {x = 0, y = 0, z = 0}

monitor.clear()
while true do
    local lengthNum = 0
    local playerList = playerDetector.getOnlinePlayers()
    for i, playerName in pairs(playerList) do
        if playerName == "wotan_spielt" then
            table.remove(playerList, i)
        end
    end
    for i, playerName in pairs(playerList) do
        if playerName == "Forest_cat" then
            table.remove(playerList, i)
        end
    end

    for i, playerName in pairs(playerList) do
        lengthNum = lengthNum + 1
        local playerPos = playerDetector.getPlayerPos(playerName)
        if lengthNum < 8 then
            monitor.setCursorPos(1, i*2)
        else
            monitor.setCursorPos(1, i)
        end
        if playerPos == nil then
            monitor.clearLine()
            monitor.setTextColor(colors.white)
            monitor.write(playerName)
            monitor.setTextColor(colors.lightGray)
            monitor.write(": ")
            monitor.setTextColor(colors.yellow)
            monitor.write("Position not found")
        else
            local distance = math.sqrt((playerPos.x - pcPos.x)^2 + (playerPos.y - pcPos.y)^2 + (playerPos.z - pcPos.z)^2)
            monitor.clearLine()
            if distance > 10000 then monitor.setTextColor(colors.green) end
            if distance < 10000 and distance > 4000 then monitor.setTextColor(colors.orange) end
            if distance <= 4000 then monitor.setTextColor(colors.red) end
            monitor.write(playerName)
            monitor.setTextColor(colors.lightGray)
            monitor.write(": ")
            monitor.setTextColor(colors.white)
            monitor.write(math.ceil(playerPos.x) .. " ")
            monitor.write(math.ceil(playerPos.y) .. " ")
            monitor.write(math.ceil(playerPos.z) .. " ")
            monitor.setTextColor(colors.lightGray)
            monitor.write(" | ")
            if distance > 10000 then monitor.setTextColor(colors.green) end
            if distance < 10000 and distance > 4000 then monitor.setTextColor(colors.orange) end
            if distance <= 4000 then monitor.setTextColor(colors.red) end
            monitor.write(math.floor(distance))
            monitor.setTextColor(colors.lightGray)
            monitor.write("m")
        end
    end
    sleep(10)
end