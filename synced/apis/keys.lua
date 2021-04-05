-- Find these keys by copying this into a CC terminal that has the "lua" program open:
-- while true do type, num = os.pullEvent("key") print(num) end
local keys_number_string = {
	"backslash", -- 0
	nil,"one","two","three","four", -- 1
	"five","six","seven","eight","nine", -- 6
	"zero","minus","equals","backspace","tab", -- 11
	"q","w","e","r","t", -- 16
	"y","u","i","o","p", -- 21
	"leftBracket","rightBracket","enter","leftCtrl","a", -- 26
	"s","d","f","g","h", -- 31
	"j","k","l","semiColon","apostrophe", -- 36
	"grave","leftShift",nil,"z","x", -- 41
	"c","v","b","n","m", -- 46
	"comma","period","slash","rightShift",nil, -- 51
	"leftAlt","space","capsLock","f1","f2", -- 56
	"f3","f4","f5","f6","f7", -- 61
	"f8","f9","f10",nil,nil, -- 66
	nil,nil,nil,nil,nil, -- 71
	nil,nil,nil,nil,nil, -- 76
	nil,nil,nil,nil,nil, -- 81
	nil,nil,"f12",nil,nil, -- 86
	nil,nil,nil,nil,nil, -- 91
	nil,nil,nil,nil,nil, -- 96
	nil,nil,nil,nil,nil, -- 101
	nil,nil,nil,nil,nil, -- 106
	nil,nil,nil,nil,nil, -- 111
	nil,nil,nil,nil,nil, -- 116
	nil,nil,nil,nil,nil, -- 121
	nil,nil,nil,nil,nil, -- 126
	nil,nil,nil,nil,nil, -- 131
	nil,nil,nil,nil,nil, -- 136
	nil,nil,nil,"circumflex","at", -- 141
	"colon","underscore",nil,nil,nil, -- 146
	nil,nil,nil,nil,nil, -- 151
	nil,"rightCtrl",nil,nil,nil, -- 156
	nil,nil,nil,nil,nil, -- 161
	nil,nil,nil,nil,nil, -- 166
	nil,nil,nil,nil,nil, -- 171
	nil,nil,nil,nil,nil, -- 176
	nil,nil,nil,nil,nil, -- 181
	nil,nil,nil,nil,nil, -- 186
	nil,nil,nil,nil,nil, -- 191
	nil,nil,nil,"home","up", -- 196
	"pageUp",nil,"left",nil,nil, -- 201
	nil,"end","down","pageDown","right", -- 206
	"delete",nil,nil,nil,nil, -- 211
}


local keys_string_number = {}
for n_key, s_key in pairs(keys_number_string) do
	keys_string_number[s_key] = n_key
end
keys_string_number["return"] = keys_string_number.enter


function start_listening(on_key_fn)
	local event, key_num = os.pullEvent("key")
	on_key_fn(get_name(key_num), key_num)
end


function get_name(key_num)
	return keys_number_string[key_num + 1]
end
