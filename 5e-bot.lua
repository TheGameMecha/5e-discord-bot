--Discordia bot variables
local discordia = require('discordia')
local client = discordia.Client()

--Bot Variables
local bot_version = "VERSION 0.1"
local token = '' --loaded from token.tkn
local botCreator = "TheGameMechanic#9693"
local botName = "5e Bot"

--Data Variables
local xpTable = ""


--Reads data from a file and returns it
function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

--Roll a dice! Can be any number (even non-real dice)
function rollDice(diceSize)
	result = 0
	result = result + math.random(1, diceSize)
	return result
end

--Split a given string
function split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

--This is where we read the token
token = readAll('token.tkn')

--Creates a callback for when the bot has finished loading
client:on('ready', function()
	client:setUsername(botName)
	print('Logged in as '.. client.user.username)
	-- Load all strings
	xpTable = readAll("Tables/xpTable.tbl")
end)

--Creates a callback for when a user sends a message
client:on('messageCreate', function(message)
	if string.find(message.content, "!") == 1 then
		if message.content == '!xp' then
			message.channel:send(xpTable)
		elseif message.content == '!bot' then
			message.channel:send("This bot " .. bot_version .. " was created by " .. botCreator .. ".")
		elseif string.find(message.content, "!roll %dd%d") then
			splitVar = split(message.content, '%s')
			diceVar = split(splitVar[2], 'd')
			
			rollingMessage = 'Rolling ' .. diceVar[1] .. 'd' .. diceVar[2]
			print (rollingMessage)
			message.channel:send(rollingMessage)
			
			
			numDice = tonumber(diceVar[1])
			diceSize = tonumber(diceVar[2])
			
			outputText = ""
			sum = 0
			roll = 0
			for i=1, numDice do
				roll = rollDice(diceSize)
				sum = sum + roll
				outputText = outputText .. "Roll " .. i .. ": " .. roll .. "\n"
			end
			outputText = outputText .. "Total: " .. sum .. "\n"
			print(outputText)
			message.channel:send(outputText)
		else 
			message.channel:send("Invalid Command.")
		end
	end
end)

--Starts the bot
client:run('Bot ' .. token)