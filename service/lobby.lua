local skynet = require "skynet"
local urllib = require "http.url"
local staticfile = require "staticfile"
local log = require "log"
local string = string
local json = require "json"
local roomid

local userservice
local roomkeeper

local content = staticfile["index.html"]

local function main()
	return content
end

local function gen_result(result)

	return json:encode(result)
end

local action = {}

function action.getname(userid, username, args, result)
	result.status = "ok"
	result.username = username
end

function action.setname(userid, username, args, result)
	local userid, username = skynet.call(userservice, "lua", userid, args.username)
	result.status = "ok"
	result.username = username
end

function action.create(userid, username, args, result)
	local ok, roomid = skynet.call(roomkeeper, "lua", "open")
	if ok then
		result.status = "join"
		result.roomid = roomid
	else
		result.status = "error"
		result.error = roomid
	end
end

function action.join(userid, username, args, result)
	local roomid = tonumber(args.roomid)
	if roomid and skynet.call(roomkeeper, "lua", "query", roomid) then
		result.status = "join"
		result.roomid = roomid
	else
		result.status = "error"
		result.error = "Invalid room id"
	end
end

skynet.start(function()
	userservice = assert(skynet.uniqueservice "userid")
	roomkeeper = assert(skynet.uniqueservice "roomkeeper")
	local ok, rid = skynet.call(roomkeeper, "lua", "open")
	assert(ok, "创建初始化room失败")
	roomid = rid

	local result = {}
	skynet.dispatch("lua", function(_,_, cmd, userid, username, body)
		if cmd == "web" then
			skynet.ret(skynet.pack(main(httpheader)))
		elseif cmd == 'roomid' then
			skynet.ret(skynet.pack(roomid))
		elseif cmd == "api" then
			-- lobby api
			local args = urllib.parse_query(body)
			if args then
				local f = action[args.action]
				if f then
					f(userid, username, args, result)
					result.roomid = roomid
				else
					result.status = "error"
					result.error = "Invalid Action"
				end
			else
				result.status = "ok"
				result.username = username
			end

			skynet.ret(skynet.pack(gen_result(result)))
		end
	end)
end)
