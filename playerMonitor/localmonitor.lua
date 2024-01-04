local monitor = peripheral.wrap("right")
local playerDetector = peripheral.wrap("top")
local pcPos = {x = 0, y = 0, z = 0}

local function getDistance(playerName)
    local playerPos = playerDetector.getPlayerPos(playerName)
    if playerPos == nil then
        monitor.setTextColor(colors.white)
        monitor.write(playerName)
        monitor.setTextColor(colors.lightGray)
        monitor.write(": ")
        monitor.setTextColor(colors.yellow)
        monitor.write("not found")
    else
        local distance = math.sqrt((playerPos.x - pcPos.x)^2 + (playerPos.y - pcPos.y)^2 + (playerPos.z - pcPos.z)^2)
        if distance > 10000 then monitor.setTextColor(colors.green) end
        if distance < 10000 and distance > 4000 then monitor.setTextColor(colors.orange) end
        if distance <= 4000 then monitor.setTextColor(colors.red) end
        monitor.write(playerName)
        monitor.setTextColor(colors.lightGray)
        monitor.write(": ")
        if distance > 10000 then monitor.setTextColor(colors.green) end
        if distance < 10000 and distance > 4000 then monitor.setTextColor(colors.orange) end
        if distance <= 4000 then monitor.setTextColor(colors.red) end
        monitor.write(math.floor(distance))
        monitor.setTextColor(colors.lightGray)
        monitor.write("m")
    end
end

monitor.clear()
while true do
    monitor.clear()
    monitor.setCursorPos(1, 2)
    getDistance("Forest_cat")
    monitor.setCursorPos(1, 4)
    getDistance("wotan_spielt")
    sleep(10)
end