--[[
	Project: lua-tabcfg
	Author: imring
	Version: 1.5
	License: MIT License (https://github.com/imring/lua-tabcfg/blob/master/LICENSE)
	Project in GitHub: https://github.com/imring/lua-tabcfg
]]

local tabcfg = {}

function table.tostring(t, tabulation, m)
	local function check(key, value)
		if type(value) == 'table' then
			return (key and key .. ' = ' or '') .. table.tostring(value, tabulation, m + 1):gsub('^%s+', '')
		elseif type(value) == 'string' then
			return (key and key .. ' = \'' or '\'') .. value:gsub('\'', '\\\'') .. '\''
		else return (key and key .. ' = ' or '') .. tostring(value) end
	end
  
	if type(t) == 'table' then
		local y, o, d = '', 0, {}
		m = m or 0
		if tabulation then for i = 0, m do y = y .. '\t' end end
		local u = y:gsub('\t$', '')
		local n = u .. '{'
		for i, k in ipairs(t) do
			o = o + 1
			n = n .. '\n' .. y .. check(nil, k) .. ','
			d[i] = true
		end
		for i, k in pairs(t) do
			if not d[i] then
				o = o + 1
				local key = type(i) == 'string' and i or '[' .. tostring(i) .. ']'
				n = n .. '\n' .. y .. check(key, k) .. ','
			end
		end
		if o == 0 then return '{}' end
		return n:gsub(',$', '') .. '\n' .. u .. '}'
	else return '' end
end

function table.loadstring(str)
	local a = load('return '..tostring(str))
	if a then
		local b, c = pcall(a)
		if b then return c end
	end
end

function tabcfg.load(path)
	local file = io.open(path, 'r')
	if file then
		local tab = file:read('*a')
		file:close()
		return table.loadstring(tab)
	end
end

function tabcfg.save(tab, path)
	local str = table.tostring(tab, true)
	local file = io.open(path, 'w')
	if file then
		file:write(str)
		file:close()
	end
end

return tabcfg
