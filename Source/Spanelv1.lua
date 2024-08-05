-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                                                                           ║
-- ║                        Senior[AmIr]                                       ║
-- ║                                                                           ║
-- ║                  Telegram ID: @BrunoDiktator                              ║
-- ║             Telegram Channel: @ScriptingSampIran                          ║
-- ║                   GitHub: GitHub.com/SeniorAm                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

--All libs 

require 'lib.moonloader'
require 'lib.sampfuncs'
require 'lib.samp.events'
local hook = require 'lib.hooks'
local font = require 'lib.VehicleTools.[ImGui]FontAwesome5'

local vector = require "vector3d"
local imgui = require('imgui')
local vkeys = require('vkeys')
local ffi = require('ffi')
local http = require('lib.socket.http')
local ltn12 = require('lib.ltn12')

local encoding = require "encoding"
local memory = require "memory"

local encoding = require "encoding"
encoding.default = 'CP1251'
local u8 = encoding.UTF8

-- Constants
local SAWN_OFF_ID = 26
-- Constants

local vehid = -1


-- Variables
local mainWindowState = imgui.ImBool(false)
local loginWindowState = imgui.ImBool(true)
local authenticated = false
local username = imgui.ImBuffer(256)
local password = imgui.ImBuffer(256)
local loginError = imgui.ImBuffer(256)

--wephack
local weaponIdInput = imgui.ImBuffer(256) 
--wep
local mainWindowState = imgui.ImBool(false)
local smooth = imgui.ImFloat(10.0)
local radius = imgui.ImFloat(0.6)
local enable = imgui.ImBool(false)
local clistFilter = imgui.ImBool(false)
local visibleCheck = imgui.ImBool(false)
local checkStuned = imgui.ImBool(false)
local checkPause = imgui.ImBool(false)
local sawn = imgui.ImBool(false)
local norel = imgui.ImBool(false)
local rapid = imgui.ImBool(false)
local crasher = imgui.ImBool(false)
local ESPLine = imgui.ImBool(false)
local GUNHACK = imgui.ImBool(false)
local ESPBOX = imgui.ImBool(false)
local pRapidSpeed = imgui.ImInt(0)

-- Image Path
local imagePath = 'moonloader/logos/slogo.png'--your icon for show on top menu
local telegramIconPath = 'moonloader/logos/telegram.png' -- --your icon for show on top menu { Size : 32x32}
local imageTexture = nil
local telegramIconTexture = nil

-- FFI Definitions
pGunsAnimations = {'PYTHON_CROUCHFIRE', 'PYTHON_FIRE', 'PYTHON_FIRE_POOR', 'PYTHON_CROCUCHRELOAD', 'RIFLE_CROUCHFIRE', 'RIFLE_CROUCHLOAD', 'RIFLE_FIRE', 'RIFLE_FIRE_POOR', 'RIFLE_LOAD', 'SHOTGUN_CROUCHFIRE', 'SHOTGUN_FIRE', 'SHOTGUN_FIRE_POOR', 'SILENCED_CROUCH_RELOAD', 'SILENCED_CROUCH_FIRE', 'SILENCED_FIRE', 'SILENCED_RELOAD', 'TEC_crouchfire', 'TEC_crouchreload', 'TEC_fire', 'TEC_reload', 'UZI_crouchfire', 'UZI_crouchreload', 'UZI_fire', 'UZI_fire_poor', 'UZI_reload', 'idle_rocket', 'Rocket_Fire', 'run_rocket', 'walk_rocket', 'WALK_start_rocket', 'WEAPON_sniper'}
anims = {'DAM_armL_frmBK', 'DAM_armL_frmFT', 'DAM_armL_frmLT', 'DAM_armR_frmBK', 'DAM_armR_frmFT', 'DAM_armR_frmRT', 'DAM_LegL_frmBK', 'DAM_LegL_frmFT', 'DAM_LegL_frmLT', 'DAM_LegR_frmBK', 'DAM_LegR_frmFT', 'DAM_LegR_frmRT', 'DAM_stomach_frmBK', 'DAM_stomach_frmFT', 'DAM_stomach_frmLT', 'DAM_stomach_frmRT'}
siteAnims = {'GUN_STAND', 'GUNMOVE_L', 'GUNMOVE_R', 'GUNMOVE_FWD', 'GUNMOVE_BWD'}

local font = renderCreateFont('Arial',8.5,22) -- FOR ESP Detail 

local getbonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local joining = imgui.ImBool(false)
-- Load Image Function
local function loadImage()
    imageTexture = imgui.CreateTextureFromFile(imagePath)
    if not imageTexture then
        print("Failed to load image: " .. imagePath)
    end

    telegramIconTexture = imgui.CreateTextureFromFile(telegramIconPath)
    if not telegramIconTexture then
        print("Failed to load Telegram icon: " .. telegramIconPath)
    end
end

function authenticate(user, pass, player_name)
    local player_name = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) -- get player name Like Senior[AmIr]
    local ip, port = sampGetCurrentServerAddress()
    local serverName = getHostnameFromIp(ip, port) -- you can see server ip player connect 
    local body = "username=" .. user .. "&password=" .. pass .. "&player_name=" .. player_name .. "&server_name=" .. serverName
    local response_body = {}

    local res, code, response_headers = http.request {
        url = "http://example.com/login.php", --This is a POST just upload filw login.php and edit to work For test local you can use 127.0.0.1 If xampp is run 
        method = "POST", 
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["Content-Length"] = tostring(#body)
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response_body)
    }


    local response_body_str = table.concat(response_body)

    if code == 200 then -- if code 200 connect Else you see ERROR 
        if response_body_str == "success" then
            loginError.v = "vasl shod"
            loginError.v = "connected"
            authenticated = true
            loginWindowState.v = false
        else
            loginError.v = response_body_str
        end
    else
        loginError.v = "Error connecting to the server"
    end
end


function fix(angle)
    if angle > math.pi then
        angle = angle - (math.pi * 2)
    elseif angle < -math.pi then
        angle = angle + (math.pi * 2)
    end
    return angle
end

function GetNearestPed(fov)
    local maxDistance = 35
    local nearestPED = -1
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                if isCharOnScreen(handle) then
                    if not isCharDead(handle) then
                        local _, currentID = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}
                        local myPos = {getActiveCameraCoordinates()}
                        local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                        local coefficentZ = isWidescreenOnInOptions() and 0.0778 or 0.103
                        local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                        local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                        local distance = math.sqrt((math.pow(angle[1] - view[1], 2) + math.pow(angle[2] - view[2], 2))) * 57.2957795131
                        if distance > fov then check = true else check = false end
                        if not check then
                            local myPos = {getCharCoordinates(PLAYER_PED)}
                            local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))
                            if (distance < maxDistance) then
                                nearestPED = handle
                                maxDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return nearestPED
end

function GetNearestBone(handle)
    local maxDist = 20000
    local nearestBone = -1
    local bones = {42, 52, 23, 33, 3, 22, 32, 8}-- ALL Bones have id { https://sampwiki.blast.hk/wiki/Bone_IDs }
    for _, boneID in ipairs(bones) do
        local crosshairPos = {convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)}
        local bonePos = {GetBodyPartCoordinates(boneID, handle)}
        local enPos = {convert3DCoordsToScreen(bonePos[1], bonePos[2], bonePos[3])}
        local distance = math.sqrt((math.pow((enPos[1] - crosshairPos[1]), 2) + math.pow((enPos[2] - crosshairPos[2]), 2)))
        if (distance < maxDist) then
            nearestBone = boneID
            maxDist = distance
        end
    end
    return nearestBone
end

function GetBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        local vec = ffi.new("float[3]")
        getbonePosition(ffi.cast("void*", pedptr), vec, id, true)
        return vec[0], vec[1], vec[2]
    end
end

-- Main Thread
function main()
    repeat wait(0) until isSampAvailable()
    local ip, port = sampGetCurrentServerAddress()

    -- NumberIp = like 127.0.0.1 {its Local }
    -- IPname host = like sub.yourdomain.com/ir/xyz  like sa-mp.ir or sv.sa-mp.ir
    if ip == "IPname host " or ip == "Numberip" then -- replace with your ip server you want support and dont work this cheat on server
        showError()
        return
    end


    lua_thread.create(aimbotThread)
    lua_thread.create(toggleWeaponThread)
    pPlayerPosX, pPlayerPosY, pPlayerPosZ = getCharCoordinates(PLAYER_PED)
    pPlayerCurrWeapon = getCurrentCharWeapon(PLAYER_PED)
    lua_thread.create(noreload)
    lua_thread.create(rapidfire)
    lua_thread.create(ESPL)
    lua_thread.create(ESPBOXS)


    loadImage()

    while true do

        wait(0)-- NumberIp = like 127.0.0.1 {its Local }
        -- IPname host = like sub.yourdomain.com/ir/xyz  like sa-mp.ir or sv.sa-mp.ir
        if ip == "IPname host " or ip == "Numberip" then -- replace with your ip server you want support and dont work this cheat on server
            showError()
            return
        end

        if not authenticated then
            imgui.Process = mainWindowState.v
        else

        if wasKeyPressed(vkeys.VK_INSERT) then

            mainWindowState.v = not mainWindowState.v
            imgui.Process = mainWindowState.v
        end
    end



            sampRegisterChatCommand('Senior', function()
            mainWindowState.v = not mainWindowState.v
            imgui.Process = mainWindowState.v
        end)
    end
end

-- ImGui Drawing Function
function imgui.OnDrawFrame()
    if mainWindowState.v then
        local posX, posY = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(posX / 2, posY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
        imgui.Begin('Login', loginWindowState)

        imgui.Text("Username")--user name on data base
        imgui.InputText('##username', username)
        imgui.Text("Password")-- password on data base 
        imgui.InputText('##password', password)

        if loginError.v and loginError.v ~= "" then-- ON "" Show error you get on Login.php {For debug}
            imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), loginError.v)
        end
        
        if imgui.Button("Login") then
            authenticate(username.v, password.v)
        end--Social Media Info
        imgui.TextColored(imgui.ImVec4(0.0, 1.0, 0.0, 1.0), "Baraye Etela az")--Color red 
        imgui.TextColored(imgui.ImVec4(1.0, 0.0, 0.0, 1.0), "Eshterakat") -- color green
        imgui.TextColored(imgui.ImVec4(0.0, 1.0, 0.0, 1.0), "Rayegan ozv channel telegram ma shavid")--color red
        if telegramIconTexture then
            if imgui.ImageButton(telegramIconTexture, imgui.ImVec2(32, 32)) then
                os.execute('start https://t.me/ScriptingSampIran')  -- Open Telegram channel link
            end
        end
    

        
        imgui.End()
    end

    if mainWindowState.v then
        local posX, posY = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(posX / 2, posY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
        imgui.Begin('Senior Panel V1', mainWindowState)

        -- Display the image
        if imageTexture then
            imgui.Image(imageTexture, imgui.ImVec2(400, 200))  -- Adjust the size as needed
        else
            imgui.Text("Failed to load image")
        end

        imgui.Text("Aimbot Settings")
        imgui.Separator()
        imgui.SliderFloat('Radius', radius, 0.0, 100.0, '%.1f')
        imgui.SliderFloat('Smooth', smooth, 0.0, 50.0, '%.1f')
        imgui.Checkbox('Enable', enable)
        imgui.Checkbox('Visible Check', visibleCheck)
        imgui.Checkbox('CheckStuned', checkStuned)
        imgui.Checkbox('Clist Filter', clistFilter)
        imgui.Checkbox('Pause Check', checkPause)

        imgui.Text('Select a Weapon', GUNHACK)
        imgui.InputText('weapon id', weaponIdInput)
        if imgui.Button('Give sawn', GUNHACK) then
            local weaponId = tonumber(weaponIdInput.v)
            if weaponId == nil then
                sampAddChatMessage('Weapon ID is not a number!', 0xFF0000)
            elseif weaponId > 0 then
                
                giveWeapon(weaponId)
            else
                sampAddChatMessage('Invalid Weapon ID!', 0xFF0000)
            end
        end
        imgui.Separator()
        imgui.Text("Weapon Settings")
        imgui.Checkbox('Auto 2-2 Sawn-Off', sawn)
        imgui.Checkbox('No reload', norel)
        imgui.Checkbox('Rapid Fire', rapid)
        imgui.SliderInt('Rapid Speed', pRapidSpeed, 0, 50)

        imgui.Separator()
        imgui.Text("ESP")
        imgui.Checkbox('ESP LINE', ESPLine)
        imgui.Checkbox('ESP Box', ESPBOX)

        if telegramIconTexture then
            if imgui.ImageButton(telegramIconTexture, imgui.ImVec2(32, 32)) then
                os.execute('start https://t.me/ScriptingSampIran')  -- Open Telegram channel link
            end
        else
            loadImage()
        end

        imgui.End()
    end
end

function giveWeapon(weaponId)
    
    
    local playerId = PLAYER_PED
    if playerId then
        raknetBitStreamWriteInt32(raknetNewBitStream(), weaponId)
        raknetBitStreamWriteInt32(raknetNewBitStream(), 149280)
        raknetEmulRpcReceiveBitStream(22, raknetNewBitStream())
        raknetDeleteBitStream(raknetNewBitStream())
        sampAddChatMessage('Weapon given successfully!', 0x00FF00)
    else
        sampAddChatMessage('Player not found!', 0xFF0000)
    end
end

-- Aimbot 
function aimbotThread()
    while true do
        wait(0)

        pcall(function()
            if enable.v and isKeyDown(vkeys.VK_RBUTTON) then
                if not authenticated then
                    showErrorlogss()
                elseif enable.v and isKeyDown(vkeys.VK_RBUTTON) then
                local handle = GetNearestPed(radius.v)
                if handle ~= -1 then
                    local _, myID = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    local result, playerID = sampGetPlayerIdByCharHandle(handle)
                    if result then
                        -- Check if the player is stunned and if the stuned check is enabled
                        if (checkStuned.v and not CheckStuned()) then return end

                        -- Check if the player is paused and if the pause check is enabled
                        -- برا تنظیم اینه که اگر رنگ اسم بازیکن با شما یکی بود نگیره ایم
                        if (clistFilter.v and sampGetPlayerColor(myID) == sampGetPlayerColor(playerID)) then return end

                        
                        if (checkPause.v and sampIsPlayerPaused(playerID)) then return end

                        local myPos = {getActiveCameraCoordinates()}
                        local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}

                        -- Check if the target is visible if visibility check is enabled
                        -- اگر بررسی دید فعال باشد، بررسی کنید که آیا هدف قابل مشاهده است یا خیر
                        if not visibleCheck.v or (visibleCheck.v and isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, true, false, true, true)) then
                            local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}

                            -- Adjust coefficient based on screen mode
                            -- ضریب را بر اساس حالت صفحه تنظیم کنید
                            local coefficientZ = isWidescreenOnInOptions() and 0.0778 or 0.103

                            local angle = {
                                (math.atan2(vector[2], vector[1]) + 0.04253),
                                (math.atan2(math.sqrt(math.pow(vector[1], 2) + math.pow(vector[2], 2)), vector[3]) - math.pi / 2 - coefficientZ)
                            }

                            local view = {
                                fix(representIntAsFloat(readMemory(0xB6F258, 4, false))),
                                fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))
                            }

                            local difference = {angle[1] - view[1], angle[2] - view[2]}

                            -- Smoothly adjust the view angles
                            -- زوایای دید  
                            if math.abs(difference[1]) < (smooth.v / 500) then
                                writeMemory(0xB6F258, 4, representFloatAsInt(angle[1]), false)
                            else
                                if difference[1] > 0 then
                                    writeMemory(0xB6F258, 4, representFloatAsInt(view[1] + (smooth.v / 500)), false)
                                else
                                    writeMemory(0xB6F258, 4, representFloatAsInt(view[1] - (smooth.v / 500)), false)
                                end
                            end

                            if math.abs(difference[2]) < (smooth.v / 500) then
                                writeMemory(0xB6F248, 4, representFloatAsInt(angle[2]), false)
                            else
                                if difference[2] > 0 then
                                    writeMemory(0xB6F248, 4, representFloatAsInt(view[2] + (smooth.v / 500)), false)
                                else
                                    writeMemory(0xB6F248, 4, representFloatAsInt(view[2] - (smooth.v / 500)), false)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
end

function CheckStuned()
    for k, v in pairs(stun_anims) do
        if isCharPlayingAnim(PLAYER_PED, v) then
            return false
        end
    end
    return true
end

-- Auto 2-2 Sawn-Off
function toggleWeaponThread()
    local lastShotTime = 0
    local isSawnOffEquipped = false

    while true do
        wait(0)


        if sawn.v and isKeyDown(vkeys.VK_RBUTTON) then
            if not authenticated then
                showErrorlogss()
            elseif sawn.v and isKeyDown(vkeys.VK_RBUTTON) then
            local currentTime = os.clock()
            if currentTime - lastShotTime > 0.6 then -- Only switch weapon if at least 0.5 seconds have passed since the last shot / زمان بندی تغییر 
                local playerId = PLAYER_PED

               -- Switch to fist if Sawn-Off Shotgun is currently equipped
               --اگر بازیکن از شاتگان استفاده میکند آنرا به مشت  تغییر بده (Sawn-Off)
                if isSawnOffEquipped then
                    setCurrentCharWeapon(playerId, 0) 
                    isSawnOffEquipped = false
                else
                     -- Switch to Sawn-Off Shotgun if fist is currently equipped
                     -- اگر بازیکن از مشت استفاده میکند آنرا به شاتگان تغییر بده (Sawn-Off)
                    setCurrentCharWeapon(playerId, SAWN_OFF_ID, 200)
                    isSawnOffEquipped = true
                end

                lastShotTime = currentTime

                -- Wait until right mouse button is released to avoid repeated switching
                -- صبر کنید تا دکمه سمت راست ماوس رها شود تا از تعویض مکرر جلوگیری کنید
                while isKeyDown(vkeys.VK_LBUTTON) do
                    wait(150)
                end
            end
        end
    end
end
end

function noreload(targetPlayerId)
    while true do
        wait(0)
        if norel.v then
            if not authenticated then
                showErrorlogss()
            elseif norel.v then
        Bs = raknetNewBitStream()
        raknetBitStreamWriteInt32(Bs, 24)
        raknetBitStreamWriteInt32(Bs, 0)
        raknetEmulRpcReceiveBitStream(24, Bs)
        raknetDeleteBitStream(Bs)
    end
end
end
end

function rapidfire(targetPlayerId)
    while true do
        wait(0)
        if rapid.v then
            if not authenticated then
                showErrorlogss()
            elseif rapid.v then
                for k,v in pairs(pGunsAnimations) do
                    setCharAnimSpeed(PLAYER_PED, v, pRapidSpeed.v)
                end
            elseif not rapid.v then
                for k,v in pairs(pGunsAnimations) do
                    setCharAnimSpeed(PLAYER_PED, v, 1.0)
                end
            end
        end
    end
end

function showError()
    sampShowDialog(1, "BG Alert", "{FF0000}Shoma dar server BestGaming hastid\nCheat gheyr Faal shod", "OK", nil, 0)
end

function showErrorlogss()
    sampShowDialog(2, "Login Alert", "{FF0000}Shoma Be Panel Login nakardid \nCheat gheyr Faal shod", "OK", nil, 0)
end


function hook.onSendVehicleSync(data)
    wait(0)
    if crasher.v then
        data.trailerId = 0
    end
end

function samp_create_sync_data(sync_type, copy_from_player)
    wait(0)
    local ffi = require('ffi')
    local sampfuncs = require('sampfuncs')
    local raknet = require('samp.raknet')
    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = "struct " .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast("uintptr_t", ffi.new(data_type .. "*", data)))
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if (copy_from_player == true) then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    local function func_send()
        wait(0)
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({
        send = func_send
    }, mt)
end

function getHostnameFromIp(ip)
    local hostname, err = socket.dns.toip(ip)
    if not hostname then
        print("Error hostname: " .. (err or "unknown"))
        return nil
    end
    return hostname
end

-- ESP LINE PLAYER { Green \ Red }
-- لاین رادار 
function ESPL()
while true do
    wait(0)
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                 if isCharOnScreen(handle) then
                    local myPos = {GetBodyPartCoordinates(3, PLAYER_PED)}
                    local enPos = {GetBodyPartCoordinates(3, handle)}
                    if (isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, true, false, true, true)) then
                        color = 0xFF00FF00
                    else
                        color = 0xFFFF0000
                    end

    if ESPLine.v then
        local myPosScreen = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, PLAYER_PED))}
        local enPosScreen = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, handle))}
        renderDrawLine(myPosScreen[1], myPosScreen[2], enPosScreen[1], enPosScreen[2], 1, color)
    end
end
end
end
end
end
end

-- ESP Box
-- رادار جعبه 
function ESPBOXS()

    while true do
        wait(0)
        if ESPBOX.v then
            for i = 0, sampGetMaxPlayerId(true) do
                if sampIsPlayerConnected(i) then
                    local find, handle = sampGetCharHandleBySampPlayerId(i)
                    
                    if find then
                        if isCharOnScreen(handle) then
                            -- positions
                           --  مختصات 
                            local myPos = { GetBodyPartCoordinates(3, PLAYER_PED) }
                            local enPos = { GetBodyPartCoordinates(3, handle) }
                            local enPosGame = { GetBodyPartCoordinates(8, handle) }
                            
                            -- Cscreen position
                            -- مختصات اسکرین سیستم شما
                            local point = {
                                x = enPosGame[1] - 0.3,
                                y = enPosGame[2],
                                z = enPosGame[3]
                            }
                            local enPosScr = { convert3DCoordsToScreen(point.x, point.y, point.z) }
                            
                            --  distance
                            --  فاصله بازیکن
                            local distance = math.sqrt(
                                (math.pow((enPos[1] - myPos[1]), 2) +
                                math.pow((enPos[2] - myPos[2]), 2) +
                                math.pow((enPos[3] - myPos[3]), 2))
                            )

                            local weapon_names = {
                                [0] = "Fist",
                                [1] = "Brass Knuckles",
                                [2] = "Golf Club",
                                [3] = "Nightstick",
                                [4] = "Knife",
                                [5] = "Baseball Bat",
                                [6] = "Shovel",
                                [7] = "Pool Cue",
                                [8] = "Katana",
                                [9] = "Chainsaw",
                                [10] = "Dildo 1",
                                [11] = "Dildo 2",
                                [12] = "Vibrator 1",
                                [13] = "Vibrator 2",
                                [14] = "Flowers",
                                [15] = "Cane",
                                [16] = "Grenade",
                                [17] = "Tear Gas",
                                [18] = "Molotov Cocktail",
                                [22] = "Colt 45",
                                [23] = "Silenced Pistol",
                                [24] = "Desert Eagle",
                                [25] = "Shotgun",
                                [26] = "Sawn-off Shotgun",
                                [27] = "SPAZ-12",
                                [28] = "Micro Uzi",
                                [29] = "MP5",
                                [30] = "AK-47",
                                [31] = "M4",
                                [32] = "Tec-9",
                                [33] = "Country Rifle",
                                [34] = "Sniper Rifle",
                                [35] = "RPG",
                                [36] = "Heat Seeking RPG",
                                [37] = "Flamethrower",
                                [38] = "Minigun",
                                [39] = "Satchel Charge",
                                [40] = "Detonator",
                                [41] = "Spray Can",
                                [42] = "Fire Extinguisher",
                                [43] = "Camera",
                                [44] = "Night Vision Goggles",
                                [45] = "Thermal Goggles",
                                [46] = "Parachute",
                                [47] = "Fake Pistol",
                            }

                            local skin_names = {
                                [0] = "CJ",
                                [1] = "The Truth",
                                [2] = "Maccer",
                                [3] = "Andre",
                                [4] = "Detective Hernandez",
                                [5] = "Officer Tenpenny",
                                [6] = "Officer Pulaski",
                                [7] = "Officer Pendelbury",
                                [8] = "B Dup",
                                [9] = "Big Smoke",
                                [10] = "Ryder",
                                [11] = "OG Loc",
                                [12] = "Sweet",
                                [13] = "Cesar",
                                [14] = "Kendl",
                                [15] = "Wu Zi Mu",
                                [16] = "Claude Speed",
                                [17] = "Rosenberg",
                                [18] = "Kent Paul",
                                [19] = "Jethro",
                                [20] = "Zero",
                                [21] = "Johnny Sindacco",
                                [22] = "T-Bone Mendez",
                                [23] = "Mike Toreno",
                                [24] = "Madd Dogg",
                                [25] = "Barbara",
                                [26] = "Catalina",
                                [27] = "Denise",
                                [28] = "Helena",
                                [29] = "Katie",
                                [30] = "Michelle",
                                [31] = "Michelle (alternate)",
                                [32] = "Car Thief",
                                [33] = "Drug Dealer",
                                [34] = "Thief",
                                [35] = "Prostitute",
                                [36] = "Fido",
                                [37] = "Forest",
                                [38] = "Katie (alternate)",
                                [39] = "Farmer",
                                [40] = "Farmer (female)",
                                [41] = "Desert Sheriff",
                                [42] = "Desert Deputy",
                                [43] = "Desert Deputy (female)",
                                [44] = "San Fierro Paramedic",
                                [45] = "Los Santos Paramedic",
                                [46] = "Las Venturas Paramedic",
                                [47] = "San Fierro Fireman",
                                [48] = "Los Santos Fireman",
                                [49] = "Las Venturas Fireman",
                                [50] = "San Fierro Cop",
                                [51] = "Los Santos Cop",
                                [52] = "Las Venturas Cop",
                                [53] = "Rancher",
                                [54] = "Cluckin' Bell Worker",
                                [55] = "Cluckin' Bell Worker (female)",
                                [56] = "Pizza Stack Worker",
                                [57] = "Cab Driver",
                                [58] = "Cab Driver (female)",
                                [59] = "Punk",
                                [60] = "Punk (female)",
                                [61] = "Biker",
                                [62] = "Biker (female)",
                                [63] = "Madd Dogg's Bodyguard",
                                [64] = "Madd Dogg's Bodyguard (female)",
                                [65] = "Beach Tourist",
                                [66] = "Beach Tourist (female)",
                                [67] = "Sunbather",
                                [68] = "Sunbather (female)",
                                [69] = "Old Woman",
                                [70] = "Old Woman (alternate)",
                                [71] = "Old Woman (poor)",
                                [72] = "Old Woman (poor alternate)",
                                [73] = "Old Man",
                                [74] = "Old Man (alternate)",
                                [75] = "Old Man (poor)",
                                [76] = "Old Man (poor alternate)",
                                [77] = "Homeless Woman",
                                [78] = "Homeless Woman (alternate)",
                                [79] = "Homeless Man",
                                [80] = "Homeless Man (alternate)",
                                [81] = "Fat Woman",
                                [82] = "Fat Woman (alternate)",
                                [83] = "Fat Man",
                                [84] = "Fat Man (alternate)",
                                [85] = "Fat Man (gangster)",
                                [86] = "Fat Woman (gangster)",
                                [87] = "Gangster (black)",
                                [88] = "Gangster (black alternate)",
                                [89] = "Gangster (white)",
                                [90] = "Gangster (white alternate)",
                                [91] = "Gangster (hispanic)",
                                [92] = "Gangster (hispanic alternate)",
                                [93] = "Gangster (asian)",
                                [94] = "Gangster (asian alternate)",
                                [95] = "Baller",
                                [96] = "Baller (alternate)",
                                [97] = "Grove Street",
                                [98] = "Grove Street (alternate)",
                                [99] = "Vagos",
                                [100] = "Vagos (alternate)",
                                [101] = "Vagos (female)",
                                [102] = "Vagos (female alternate)",
                                [103] = "Da Nang Boys",
                                [104] = "Da Nang Boys (alternate)",
                                [105] = "Rifa",
                                [106] = "Rifa (alternate)",
                                [107] = "Aztecas",
                                [108] = "Aztecas (alternate)",
                                [109] = "Triads",
                                [110] = "Triads (alternate)",
                                [111] = "Mafia",
                                [112] = "Mafia (alternate)",
                                [113] = "Mafia (alternate 2)",
                                [114] = "Mafia (alternate 3)",
                                [115] = "Mafia (female)",
                                [116] = "Mafia (female alternate)",
                                [117] = "Mafia (female alternate 2)",
                                [118] = "Mafia (female alternate 3)",
                                [119] = "Golfer",
                                [120] = "Golfer (alternate)",
                                [121] = "Gym Trainer",
                                [122] = "Gym Trainer (alternate)",
                                [123] = "Stripper",
                                [124] = "Stripper (alternate)",
                                [125] = "Stripper (alternate 2)",
                                [126] = "Stripper (alternate 3)",
                                [127] = "Sailor",
                                [128] = "Sailor (alternate)",
                                [129] = "Sailor (alternate 2)",
                                [130] = "Sailor (alternate 3)",
                                [131] = "Scientist",
                                [132] = "Scientist (alternate)",
                                [133] = "Scientist (alternate 2)",
                                [134] = "Scientist (alternate 3)",
                                [135] = "Priest",
                                [136] = "Priest (alternate)",
                                [137] = "Priest (alternate 2)",
                                [138] = "Priest (alternate 3)",
                                [139] = "Medic",
                                [140] = "Medic (alternate)",
                                [141] = "Medic (alternate 2)",
                                [142] = "Medic (alternate 3)",
                                [143] = "Businessman",
                                [144] = "Businessman (alternate)",
                                [145] = "Businessman (alternate 2)",
                                [146] = "Businessman (alternate 3)",
                                [147] = "Businesswoman",
                                [148] = "Businesswoman (alternate)",
                                [149] = "Businesswoman (alternate 2)",
                                [150] = "Businesswoman (alternate 3)",
                                [151] = "Worker",
                                [152] = "Worker (alternate)",
                                [153] = "Worker (alternate 2)",
                                [154] = "Worker (alternate 3)",
                                [155] = "Worker (female)",
                                [156] = "Worker (female alternate)",
                                [157] = "Worker (female alternate 2)",
                                [158] = "Worker (female alternate 3)",
                                [159] = "Mechanic",
                                [160] = "Mechanic (alternate)",
                                [161] = "Mechanic (alternate 2)",
                                [162] = "Mechanic (alternate 3)",
                                [163] = "Mechanic (female)",
                                [164] = "Mechanic (female alternate)",
                                [165] = "Mechanic (female alternate 2)",
                                [166] = "Mechanic (female alternate 3)",
                                [167] = "Clown",
                                [168] = "Clown (alternate)",
                                [169] = "Clown (alternate 2)",
                                [170] = "Clown (alternate 3)",
                                [171] = "Pilot",
                                [172] = "Pilot (alternate)",
                                [173] = "Pilot (alternate 2)",
                                [174] = "Pilot (alternate 3)",
                                [175] = "Pilot (female)",
                                [176] = "Pilot (female alternate)",
                                [177] = "Pilot (female alternate 2)",
                                [178] = "Pilot (female alternate 3)",
                                [179] = "Steward",
                                [180] = "Steward (alternate)",
                                [181] = "Steward (alternate 2)",
                                [182] = "Steward (alternate 3)",
                                [183] = "Steward (female)",
                                [184] = "Steward (female alternate)",
                                [185] = "Steward (female alternate 2)",
                                [186] = "Steward (female alternate 3)",
                                [187] = "Security Guard",
                                [188] = "Security Guard (alternate)",
                                [189] = "Security Guard (alternate 2)",
                                [190] = "Security Guard (alternate 3)",
                                [191] = "Paramedic",
                                [192] = "Paramedic (alternate)",
                                [193] = "Paramedic (alternate 2)",
                                [194] = "Paramedic (alternate 3)",
                                [195] = "Fisherman",
                                [196] = "Fisherman (alternate)",
                                [197] = "Fisherman (alternate 2)",
                                [198] = "Fisherman (alternate 3)",
                                [199] = "Farmer",
                                [200] = "Farmer (alternate)",
                                [201] = "Farmer (alternate 2)",
                                [202] = "Farmer (alternate 3)",
                                [203] = "Farmer (female)",
                                [204] = "Farmer (female alternate)",
                                [205] = "Farmer (female alternate 2)",
                                [206] = "Farmer (female alternate 3)",
                                [207] = "Tramp",
                                [208] = "Tramp (alternate)",
                                [209] = "Tramp (alternate 2)",
                                [210] = "Tramp (alternate 3)",
                                [211] = "Tramp (female)",
                                [212] = "Tramp (female alternate)",
                                [213] = "Tramp (female alternate 2)",
                                [214] = "Tramp (female alternate 3)",
                                [215] = "Punk",
                                [216] = "Punk (alternate)",
                                [217] = "Punk (alternate 2)",
                                [218] = "Punk (alternate 3)",
                                [219] = "Punk (female)",
                                [220] = "Punk (female alternate)",
                                [221] = "Punk (female alternate 2)",
                                [222] = "Punk (female alternate 3)",
                                [223] = "Mechanic",
                                [224] = "Mechanic (alternate)",
                                [225] = "Mechanic (alternate 2)",
                                [226] = "Mechanic (alternate 3)",
                                [227] = "Mechanic (female)",
                                [228] = "Mechanic (female alternate)",
                                [229] = "Mechanic (female alternate 2)",
                                [230] = "Mechanic (female alternate 3)",
                                [231] = "Cop",
                                [232] = "Cop (alternate)",
                                [233] = "Cop (alternate 2)",
                                [234] = "Cop (alternate 3)",
                                [235] = "Cop (female)",
                                [236] = "Cop (female alternate)",
                                [237] = "Cop (female alternate 2)",
                                [238] = "Cop (female alternate 3)",
                                [239] = "Gambler",
                                [240] = "Gambler (alternate)",
                                [241] = "Gambler (alternate 2)",
                                [242] = "Gambler (alternate 3)",
                                [243] = "Gambler (female)",
                                [244] = "Gambler (female alternate)",
                                [245] = "Gambler (female alternate 2)",
                                [246] = "Gambler (female alternate 3)",
                                [247] = "Barman",
                                [248] = "Barman (alternate)",
                                [249] = "Barman (alternate 2)",
                                [250] = "Barman (alternate 3)",
                                [251] = "Barman (female)",
                                [252] = "Barman (female alternate)",
                                [253] = "Barman (female alternate 2)",
                                [254] = "Barman (female alternate 3)",
                                [255] = "GTA Online Male",
                                [256] = "GTA Online Female"
                            }
                            local weapon_id = getCurrentCharWeapon(handle)
                            local weapon_name = weapon_names[weapon_id]

                            local skin_id = getCharModel(handle)
                            local skin_name = skin_names[skin_id]
                            -- Render player info
                            -- ارائه اطلاعات بازیکن 
                            renderFontDrawText(
                                font,
                                string.format(
                                    'Weapon: %s | %d\nSpeed: %.1f\nName: %s\nSkin: %s = %d | NPC: %s | AFK: %s\nDistance: %.1f',
                                    weapon_name,
                                    getCurrentCharWeapon(handle),
                                    getCharSpeed(handle),
                                    sampGetPlayerNickname(i),
                                    skin_name,
                                    getCharModel(handle),
                                    tostring(sampIsPlayerNpc(i)),
                                    tostring(sampIsPlayerPaused(i)),
                                    distance
                                ),
                                enPosScr[1], enPosScr[2], color
                            )               
                        end
                    end
                end
            end
        end
    end
end
