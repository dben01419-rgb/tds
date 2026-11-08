-- Converts the comment-delimited wave format used by several TDS strategy
-- sources into the timed Strategies X API.  This runs before the strategy is
-- compiled, so the comments can carry timing information without changing
-- the strategy's visible syntax.
local Compat = {}

local function append(args, suffix)
	return args .. suffix
end

function Compat.Transform(source)
	if type(source) ~= "string" then
		return source
	end

	local wave = nil
	local out = {}
	for line in source:gmatch("[^\r\n]*\r?\n?") do
		local found = line:match("%-%-%s*%[%s*[Ww]ave%s+(%d+)%s*%]%s*%-%-")
		if found then
			wave = tonumber(found)
		end

		if wave then
			local indent, args, tail = line:match("^(%s*TDS:%s*Place%s*%()(.*)(%)%s*[%r\n]*$)")
			if indent then
				line = indent .. append(args, ", " .. wave) .. tail
			else
				indent, args, tail = line:match("^(%s*TDS:%s*Upgrade%s*%()(.*)(%)%s*[%r\n]*$)")
				if indent then
					local first, second = args:match("^%s*([^,]+)%s*,%s*([^,]+)%s*$")
					if first and second and (tonumber(second) == 1 or tonumber(second) == 2) then
						line = indent .. first .. ", " .. wave .. ", 0, 0, false, " .. second .. tail
					elseif not args:find(",", 1, true) then
						-- Use the full legacy shape here.  A two-argument call with
						-- wave 1 or 2 is otherwise indistinguishable from path 1/2.
						line = indent .. args .. ", " .. wave .. ", 0, 0, false, 1" .. tail
					else
						line = indent .. append(args, ", " .. wave) .. tail
					end
				else
					indent, args, tail = line:match("^(%s*TDS:%s*Sell%s*%()(.*)(%)%s*[%r\n]*$)")
					if indent then
						line = indent .. append(args, ", " .. wave) .. tail
					else
						indent, args, tail = line:match("^(%s*TDS:%s*Ability%s*%()(.*)(%)%s*[%r\n]*$)")
					if indent then
						local data = args:match("^%s*[^,]+%s*,%s*[^,]+%s*,%s*(.+)%s*$")
						if data then
							local prefix = args:match("^(.-,%s*.-,%s*)")
							line = indent .. prefix .. wave .. ", 0, 0, false, " .. data .. tail
						else
							line = indent .. append(args, ", " .. wave) .. tail
						end
					else
						indent, args, tail = line:match("^(%s*TDS:%s*SetOption%s*%()(.*)(%)%s*[%r\n]*$)")
						if indent then
							line = indent .. append(args, ", " .. wave) .. tail
						else
							indent, args, tail = line:match("^(%s*TDS:%s*VoteSkip%s*%()(.*)(%)%s*[%r\n]*$)")
							-- VoteSkip's explicit argument is already its wave.
						end
					end
					end
				end
			end
		end
		table.insert(out, line)
	end
	return table.concat(out)
end

return Compat
