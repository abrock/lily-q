
maxUndos = 10

noteNamesInternational = {
    nederlands = {
        "feses", "ceses", "geses", "deses", "aeses", "eeses", "beses", -- double flats
        "fes", "ces", "ges", "des", "as", "es", "bes",
        "f", "c", "g", "d", "a", "e", "b",
        "fis", "cis", "gis", "dis", "ais", "eis", "bis",
        "fisis", "cisis", "gisis", "disis", "aisis", "eisis", "bisis",
    },
}

offsetsToIntervals = {
    [-12] = 0,
    [-11] = 5,
    [-10] = -2,
    [-9] = 3,
    [-8] = -4,
    [-7] = 1,
    [-6] = 6,
    [-5] = -1, --des to c is one semitone down
    [-4] = 4,
    [-3] = -3,
    [-2] = 2,
    [-1] = -5,
    [0] = 0,
    [1] = 5,
    [2] = -2,
    [3] = 3,
    [4] = -4,
    [5] = 1,
    [6] = -6,
    [7] = -1,
    [8] = 4,
    [9] = -3,
    [10] = 2,
    [11] = -5,
    [12] = 0
}

offsets = {
    [0] = 0,
    7, -- c# is plus 7
    2,
    -3,
    4,
    -1,
    6,
    1,
    8,
    3,
    -2,
    5,
}

keyNotes = {}
do
    local note = 11
    for i = -7, 7 do
        keyNotes[i] = (( note + 11 ) % 12 ) + 61
        note = ( note + 7 ) % 12
    end
end


steps = {
    c = 0,
    d = 1,
    e = 2,
    f = 3,
    g = 4, 
    a = 5,
    b = 6,
}

local char = string.char
local byte = string.byte

function RealSendMidiEvent(...)
    local s = ...
    if type(s) == "number" then
        s = char(...)
    end
    SendMidiData(s)
end

function SendMidiEvent(...)
    -- send patch first
    RealSendMidiEvent(char(0xc0 | MIDIOutputChannel, PreferredPatch))
    RealSendMidiEvent(...)
    SendMidiEvent = RealSendMidiEvent
    RealSendMidiEvent = nil
    MIDIOutputChannel = nil
end


-- Keyboard output
local lower = string.lower
local shiftMask = 0x1000
local removeMask = shiftMask - 1

local shiftCodes = "~`!1@2#3$4%5^6&7*8(9)0_-+={[}]|\\:;\"'<,>.?/"

-- this table of keycodes is from /usr/include/linux/input.h

local keyCodes = {
    ["1"] = 2,
    ["2"] = 3,
    ["3"] = 4,
    ["4"] = 5,
    ["5"] = 6,
    ["6"] = 7,
    ["7"] = 8,
    ["8"] = 9,
    ["9"] = 10,
    ["0"] = 11,
    ["-"] = 12,
    ["="] = 13,
    ["\127"] = 14,
    ["\t"] =15,
    ["q"] = 16,
    ["w"] = 17,
    ["e"] = 18,
    ["r"] = 19,
    ["t"] = 20,
    ["y"] = 21,
    ["u"] = 22,
    ["i"] = 23,
    ["o"] = 24,
    ["p"] = 25,
    ["["] = 26,
    ["]"] = 27,
    ["\n"] = 28,
--    KEY_LEFTCTRL            29
    ["a"] = 30,
    ["s"] = 31,
    ["d"] = 32,
    ["f"] = 33,
    ["g"] = 34,
    ["h"] = 35,
    ["j"] = 36,
    ["k"] = 37,
    ["l"] = 38,
    [";"] = 39,
    ["'"] = 40,
    ["`"] = 41,
--    KEY_LEFTSHIFT           42
    ["\\"] = 43,
    ["z"] = 44,
    ["x"] = 45,
    ["c"] = 46,
    ["v"] = 47,
    ["b"] = 48,
    ["n"] = 49,
    ["m"] = 50,
    [","] = 51,
    ["."] = 52,
    ["/"] = 53,
    [" "] = 57,
}

setmetatable(keyCodes, {
    __index = function(t,c)
        local n
        if c:match("%u") then
            n = keyCodes[lower(c)]
        else
            n = keyCodes[shiftCodes:match("%" .. c .. "(.)")]
        end
        if n then
            n = n | shiftMask
            rawset(t, c, n) -- cache it
            return n
         end
         return false -- cause an error
    end })

function SendString(s, deletingFlag)
    for c in s:gmatch(".") do
        local shift = false
        local code = keyCodes[c]
        if code then
            if code & shiftMask ~= 0 then
                shift = true
                code = code & removeMask
            end
            SendKeystroke(code, shift)
         end
    end
	if (not deletingFlag) and currentUndo then
        lastStringSent = s
        currentUndo.codeSent = s
        eventsSent[#eventsSent+1] = currentUndo
        if #eventsSent > maxUndos then
            table.remove(eventsSent, 1)
        end
        currentUndo = nil
    end

end

--[[
function PrintMyTable()
    for k, v in pairs(MyTable) do
        print(k, v)
    end
end
--]]


