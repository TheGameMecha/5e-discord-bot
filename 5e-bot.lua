--Discordia bot variables
local discordia = require('discordia')
local client = discordia.Client()

--Includes
--JSON
json = require "include/json"
--randomlua
require('include/randomlua')

l1 = lcg(0) -- Linear congruential generator (Ansi C params)  
l2 = lcg(0, 'nr') --Linear congruential generator (Numerical recipes params)  
l3 = lcg(0, 'mvc') -- Linear congruential generator (Microsoft Visual C params)  
c1 = mwc(0) -- Multiply-with-carry (Ansi C params)  
c2 = mwc(0, 'nr') -- Multiply-with-carry (Numerical recipes params)  
c3 = mwc(0, 'mvc') -- Multiply-with-carry (Microsoft Visual C params)  
m = twister(0) -- Mersenne twister  

m:randomseed(os.time()) --set seed to os time

--Bot Variables
local bot_version = "Version 0.1"
local token = '' --loaded from token.tkn
local botCreator = "TheGameMechanic#9693"
local botName = "5e Bot"
local commandDelim = "&"


--Data Variables
local xpTable = ""
local helpTable = ""

--Rolling Dice variables
local dicePattern = string.upper("roll ") .."%d+" .. string.upper("d") .. "%d+"
--These values refer to number of DIGITS, not values
local maxDiceNum = 2 --number of dice to roll
local maxDiceSize = 3 --size of dice (d20 for example)

math.randomseed(os.time())
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
	result = result + m:random(1,diceSize)--math.random(1, diceSize)
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

function removeDelim(inputstring)
	returnVal = split(inputstring, commandDelim)
	return returnVal[1]
end

function tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end


function getLowest(input)
	lowest = input[1]
	for i = 1, #input do
		if lowest > input[i] then
			lowest = input[i]
		end
	end
	return lowest
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
	if string.find(message.content, commandDelim) == 1 then
		inputMessage = ""
		inputMessage = removeDelim(message.content)
		if string.upper(inputMessage) == string.upper('xp') then
			message.channel:send(xpTable)
		elseif string.upper(inputMessage) == string.upper('bot') then
			message.channel:send("I am " .. bot_version .. "; My creator is " .. botCreator .. ".")
		elseif string.find(string.upper(inputMessage), dicePattern) then
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
		elseif string.find(string.upper(inputMessage), string.upper("srd")) then
			text = split(inputMessage, "%s")
		elseif string.upper(inputMessage) == string.upper("rollstats") then
			diceArray = {}
			finalOutput = ""
			for i = 1, 6 do
				for x = 1, 4 do
					diceArray[x] = rollDice(6)
				end
				
				output = ""
				lowestFound = false
				for y = 1, #diceArray do
					
					if diceArray[y] == getLowest(diceArray) and lowestFound == false then
						output = output .. "~~" .. diceArray[y] .. "~~"
						lowestFound = true
					else
						output = output .. diceArray[y]
					end
					
					if y ~= #diceArray then
						output = output .. ", "
					end
					
				end
				sum = 0
				for z = 1, #diceArray do
						
					sum = sum + diceArray[z]
				end
				sum = sum - getLowest(diceArray)
				output = output .. " = " .. sum
				finalOutput = finalOutput .. output .. "\n"
			end
			
			message.channel:send(finalOutput)
		elseif string.find(string.upper(inputMessage), string.upper("help")) then
			message.channel:send(helpTable)
		else 
			message.channel:send("Invalid Command.")
		end
	end
end)

--Starts the bot
client:run('Bot ' .. token)