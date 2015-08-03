local skynet = require "skynet"
local os = os
local string = string
local math = math

local log = {}

local cache_ti
local cache_str
local function fmttime()
	local ti = math.floor(skynet.time())
	if ti ~= cache_ti then
		cache_ti = ti
		cache_str = os.date("%F %T",ti)
	end
	return cache_str
end

function log.printf(...)
	skynet.error(string.format("[%s] %s",fmttime(),string.format(...)))
end

function log.var_dump(data)
	local max = 0
	local function var_dump_tbl(tbl, tab) 
			local ret = ""
			local last_tab = tab
			if type(tbl) == "string" then 
			    return '"' .. tostring(tbl) .. '"'
			elseif type(tbl) ~= "table" then
				return tostring(tbl)
		    else
		    	ret = ret .. "{\n"
		    	tab = tab .. "\t"
		        for k,v in pairs(tbl) do  
		        	if type(k) == "string" then
		        		k = '"' .. k .. '"'
		        	end		        	
		        	ret = ret .. tab .. tostring(k) .. " = " .. var_dump_tbl(v, tab) .. "\n"
			    end
			    ret = ret .. last_tab .. "}\n"
			end
			return ret   
		end 
	print(var_dump_tbl(data, ""))
end 
return log
