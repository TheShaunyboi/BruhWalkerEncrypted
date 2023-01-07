do
    local function AutoUpdate()
		local version = 0.1
		local file_name = "Shauns-ChampionAIO"
		local aio_url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shauns-ChampionAIO.lua"
        local web_version = http:get("https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/Shauns-ChampionAIO.lua.version.txt")
		if tonumber(web_version) ~= version then
			http:download_file(aio_url, file_name)
			console:log("Shaun's AIO Updated Downloaded")
			console:log("Please Reload via F5!")
        end
    end
    AutoUpdate()
end

-- Make download DIR if not found
if not file_manager:directory_exists("Shaun's Sexy Common") then
	file_manager:create_directory("Shaun's Sexy Common")
end

function load_and_run_file(filename)
	-- Open the file and read contents, if not found download from my GitHub
	if not file_manager:file_exists("Shaun's Sexy Common//" .. filename) then
	  -- File not found, try downloading it
	  console:log("Shaun's Champion AIO Message")
	  console:log("Downloading Champion Script..")
	  local url = "https://raw.githubusercontent.com/TheShaunyboi/BruhWalkerEncrypted/main/" .. filename
	  local success = http:download_file(url, "Shaun's Sexy Common//" .. filename)
	  console:log("Downloaded " .. filename .. " Please Reload via F5!")
	  return
	else
	  -- File found, read and run it
	  local filepath = os.getenv('LOCALAPPDATA') .."/leaguesense/scripts/Shaun's Sexy Common/" .. filename
	  local file = io.open(filepath, "r")
	  local contents = file:read("*all")
	  file:close()
	  local chunk, err = load(contents)
	  if err then
		console:log(err)
	  end
	  chunk()
	end
end
	
local champ_name = game.local_player.champ_name
	
if champ_name == "Annie" then
	local lua_name = "AnnieAnnieAnnie.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Blitzcrank" then
	local lua_name = "ArloTheBabyCrank.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Ashe" then
	local lua_name = "Ashe-ArrowMeBaby.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Ashe" then
	local lua_name = "Ashe-ArrowMeBaby.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Lucian" then
	local lua_name = "BLMLucian.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Syndra" then
	local lua_name = "BlueBallsSyndra.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Cassiopeia" then
	local lua_name = "CassioToThePeia.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Ziggs" then
	local lua_name = "DaBombZiggs.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Ahri" then
	local lua_name = "FoxyAhri.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Jax" then
	local lua_name = "HammerMeBaby-Jax.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Lissandra" then
	local lua_name = "IceyBabyLissandra.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Jayce" then
	local lua_name = "JayceyBaby.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Jinx" then
	local lua_name = "JinxOnAmphetamine.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Kalista" then
	local lua_name = "Kalista-WatchMeDanceBaby.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "LeeSin" then
	local lua_name = "KarateKid-Lee.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Kayle" then
	local lua_name = "LesbianKayle.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Lulu" then
	local lua_name = "LuluTheDon.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "MissFortune" then
	local lua_name = "MissToTheFortune.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Nami" then
	local lua_name = "NamiNamiNami.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Nocturne" then
	local lua_name = "NoceyNocNoc.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Kaisa" then
	local lua_name = "OhAyKaisa.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Ezreal" then
	local lua_name = "ProPlay-Ezreal.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Vayne" then
	local lua_name = "ProPlay-Vayne.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Samira" then
	local lua_name = "Samira-TheTransgender.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Azir" then
	local lua_name = "SandyDandyAzir.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Thresh" then
	local lua_name = "Shauns-SimpleThresh.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Sivir" then
	local lua_name = "Shauns-Sivir.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Varus" then
	local lua_name = "SixPackVarus.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Karthus" then
	local lua_name = "SluttyHalloween-Karthus.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Swain" then
	local lua_name = "SwainTheSexyMofo.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Tristana" then
	local lua_name = "TristanaTheYordelPornStar.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Pyke" then
	local lua_name = "UglyManPyke.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Vladimir" then
	local lua_name = "VladToTheImir.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Kennen" then
	local lua_name = "Worlds2021-Kennen.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Xerath" then
	local lua_name = "XerathToTheXerath.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Yone" then
	local lua_name = "YoneToTheYone.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
elseif champ_name == "Zeri" then
	local lua_name = "Zeri-TheNeonRaver.lua"
	if not file_manager:file_exists(lua_name) then
		load_and_run_file(lua_name)
	end
end
