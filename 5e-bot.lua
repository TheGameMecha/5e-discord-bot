--Discordia bot variables
local discordia = require('discordia')
local client = discordia.Client()

--Includes
--JSON
json = require "json"

--Bot Variables
local bot_version = "Version 0.1"
local token = '' --loaded from token.tkn
local botCreator = "TheGameMechanic#9693"
local botName = "5e Bot"

--Data Variables
local xpTable = ""
local helpTable = ""

--Rolling Dice variables
local dicePattern = string.upper("!roll ") .."%d+" .. string.upper("d") .. "%d+"
--These values refer to number of DIGITS, not values
local maxDiceNum = 2 --number of dice to roll
local maxDiceSize = 3 --size of dice (d20 for example)


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

function tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end


--This is where we read the token
token = readAll('token.tkn')

--Creates a callback for when the bot has finished loading
client:on('ready', function()
	client:setUsername(botName)
	print('Logged in as '.. client.user.username)
	-- Load all strings
	xpTable = readAll("Tables/xpTable.tbl")
	helpTable = readAll("Tables/help.tbl")
	
	srdJson = readAll("Tables/5esrd.json")
	decodedSrd = json.decode(srdJson)
end)

--Creates a callback for when a user sends a message
client:on('messageCreate', function(message)
	if string.find(message.content, "!") == 1 then
		if string.upper(message.content) == string.upper('!xp') then
			message.channel:send(xpTable)
		elseif string.upper(message.content) == string.upper('!bot') then
			message.channel:send("I am " .. bot_version .. "; My creator is " .. botCreator .. ".")
		elseif string.find(string.upper(message.content), dicePattern) then
			splitVar = split(message.content, '%s')
			diceVar = split(splitVar[2], 'd')
			
			if string.len(diceVar[1]) > maxDiceNum then
				print ("Number of dice is too large")
				message.channel:send("Number of dice is too large")
				return 
			elseif string.len(diceVar[2]) > maxDiceSize then
				print ("Size of dice is too large")
				message.channel:send("Size of dice is too large")
				return
			end

			numDice = tonumber(diceVar[1])
			diceSize = tonumber(diceVar[2])

			rollingMessage = 'Rolling ' .. diceVar[1] .. 'd' .. diceVar[2]
			print (rollingMessage)
			message.channel:send(rollingMessage)
			
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
		elseif string.find(string.upper(message.content), string.upper("!srd")) then
			text = split(message.content, "%s")
		
		elseif string.find(string.upper(message.content), string.upper("!help")) then
			message.channel:send(helpTable)
		else 
			message.channel:send("Invalid Command.")
		end
	end
end)

--Starts the bot
client:run('Bot ' .. token)