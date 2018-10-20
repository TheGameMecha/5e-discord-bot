--Discordia bot variables
local discordia = require('discordia')
local client = discordia.Client()

--Bot Variables
local bot_version = "VERSION 0.1"
local token = 'NTAzMDM5NTY5MDkyOTM1Njgx.Dqwu2g.z8saxIhnmhIhpxCEt9lb9g2aLXI'
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

--Creates a callback for when the bot has finished loading
client:on('ready', function()
	client:setUsername(botName)
	print('Logged in as '.. client.user.username)
	xpTable = readAll("xpTable.tbl")
end)

--Creates a callback for when a user sends a message
client:on('messageCreate', function(message)
	if string.find(message.content, "!") == 1 then
		if message.content == '!xp' then
			message.channel:send(xpTable)
		elseif message.content == '!bot' then
			message.channel:send("This bot " .. bot_version .. " was created by " .. botCreator .. ".")
		else 
			message.channel:send("Invalid Command.")
		end
	end
end)

--Starts the bot
client:run('Bot ' .. token)