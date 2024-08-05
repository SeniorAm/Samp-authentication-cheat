-- This file is part of broadcaster library
-- Licensed under MIT License
-- Copyright (c) 2019 Ranx
-- https://github.com/r4nx/broadcaster
-- Version 0.3.0

local handlers = {}

local logger = require 'log'
logger.usecolor = false
logger.level = 'info'

local proto = require 'broadcaster.proto'
local utils = require 'broadcaster.utils'
local encoder = require 'broadcaster.encoder'
local charset = require 'broadcaster.charset'
local magic = require 'broadcaster.magic'

local inspect = require 'inspect'

-- Args:
--    handlerId <string> - unique handler id
--    callback <function> - callback function
--    rawData <bool> [optional] - do not decode data before passing to callback
function EXPORTS.registerHandler(handlerId, callback, rawData)
    -- Doing some check in advance to avoid undefined behavior
    if type(handlerId) ~= 'string' or not encoder.check(handlerId, charset.MESSAGE_ENCODE) then
        error(('invalid handler id ("%s")'):format(handlerId))
    end
    if handlers[handlerId] ~= nil then
        error(('handler id collision: handler "%s" has been already registered'):format(handlerId))
    end    
    if type(callback) ~= 'function' then
        error(('callback object is not a function (handler id "%s")'):format(handlerId))
    end

    handlers[handlerId] = {callback, rawData}
    logger.info(('registered handler "%s"'):format(handlerId))
end

-- Args:
--    handlerId <string> - handler id to unregister
-- Returns:
--    bool - true if unregistered successfully
function EXPORTS.unregisterHandler(handlerId)
    if handlers[handlerId] ~= nil then
        handlers[handlerId] = nil
        logger.info(('unregistered handler "%s"'):format(handlerId))
        return true
    end
    return false
end

local function bitsToBitStream(bits)
    local bs = raknetNewBitStream()
    for _, bValue in ipairs(bits) do
        raknetBitStreamWriteBool(bs, bValue == 1 and true or false)
    end
    return bs
end

-- Args:
--    message <string> - message to send
--    handlerId <string> - remote handler id
function EXPORTS.sendMessage(message, handlerId)
    if type(message) ~= 'string' or not encoder.check(message, charset.MESSAGE_ENCODE) then
        error(('invalid message ("%s")'):format(message))
    end
    if type(handlerId) ~= 'string' or not encoder.check(handlerId, charset.MESSAGE_ENCODE) then
        error(('invalid handler id ("%s")'):format(handlerId))
    end

    local encodedMessage = encoder.encode(message, charset.MESSAGE_ENCODE)
    local encodedHandlerId = encoder.encode(handlerId, charset.MESSAGE_ENCODE)

    logger.debug('sendMessage > encodedMessage: ' .. inspect(encodedMessage))
    logger.debug('sendMessage > encodedHandlerId: ' .. inspect(encodedHandlerId))

    local packets = proto.packData(encodedMessage, encodedHandlerId)
    logger.debug('sendMessage > packets:\n  ' .. inspect(packets))
    for _, p in ipairs(packets) do
        local bs = bitsToBitStream(p)
        raknetBitStreamSetWriteOffset(bs, 16)
        raknetSendRpc(magic.RPC_OUT, bs)
        raknetDeleteBitStream(bs)
    end
end

function EXPORTS.disableContentLengthLimit()
    if magic.MAX_SESSION_CONTENT_LENGTH ~= math.huge then
        magic.MAX_SESSION_CONTENT_LENGTH = math.huge
        logger.info('Disabled content length limit')
    end
end

function EXPORTS._printHandlers()
    print('Handlers:')
    for handlerId, handlerData in pairs(handlers) do
        print(handlerId, inspect(handlerData))
    end
end

function EXPORTS._printSessions()
    print('Sessions:\n' .. inspect(proto.getSessions()))
end

local function bitStreamToBits(bs)
    local bits = {}
    for _ = 1, raknetBitStreamGetNumberOfUnreadBits(bs) do
        bits[#bits + 1] = raknetBitStreamReadBool(bs) and 1 or 0
    end
    return bits
end

local function sessionHandler(session)
    logger.trace('>> broadcaster.lua:sessionHandler')
    local handlerId = encoder.decode(session.handlerId, charset.MESSAGE_DECODE)
    logger.debug(('got handler id: "%s"'):format(handlerId))
    local handler, rawData = unpack(handlers[handlerId] or {})
    if handler ~= nil then
        if rawData then
            handler(session.data)
        else
            handler(encoder.decode(session.data, charset.MESSAGE_DECODE))
        end
    else
        logger.warn('handler not found, all handlers:\n  ' .. inspect(handlers))
    end
end

local function rpcHandler(rpcId, bs)
    if rpcId == magic.RPC_IN and utils.tableLength(handlers) > 0 then
        raknetBitStreamResetReadPointer(bs)

        local bits = bitStreamToBits(bs)
        logger.debug(string.rep(' ', 4) .. '[^] received bits: ' .. inspect(bits))

        if #bits == magic.PACKETS_LEN then
            proto.processPacket(bits, sessionHandler)
        else
            logger.warn(('bs length is not %d (%d instead)'):format(magic.PACKETS_LEN, #bits))
        end
    end
end

function main()
    logger.trace('>> broadcaster.lua:main')
    addEventHandler('onReceiveRpc', rpcHandler)
    wait(-1)
end
