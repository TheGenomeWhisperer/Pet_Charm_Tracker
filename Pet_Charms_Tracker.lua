-- Author: Sklug
-- Program: To determine how many pet charms are needed to make every pet of yours Rare
--          But, also the ability to filter duplicates


-- Slash Commands
SLASH_PETCHARMSTRACKER1 = '/charms';

-- Instance Variables Initializing Base Uncalculated Value - To Set these values, run "SetCurrentPetInfo()"
local numPetsOwned = 0;
local numRareOwned = 0;
local numNonRare = 0;
local percentTotalRare = 0;
local charmsStillNeeded = 0;

-- Charms to Obtain from each Zones
local numCharmsFromDraenorZones = 0;
-- To Add Tanaan Jungle Fights.
-- To Add Legion
-----------------------
-- Items to Purchase --
-----------------------
-- WOD GARRISON VENDORS (Giada Goldleash - Frostwall; Tiffy Trapspring - Lunarfall)
-- Item = {name,petID,CharmsCost,ItemID(pets)...}
-- TOYS -- 
local Toys = {"Magic Pet Mirror",127696,500,
				"Spirit Wand",127695,100,
					"Indestructible Bone",127707,50};

-- PETS -- 
local Pets = {"Lost Netherpup",93142,200,127705,
				"Glowing Sporebat",88575,100,127701,
					"Bloodthorn Hatchling",88514,50,127704,
						"Dusty Sporewing",88415,50,127703};


-- GUI Tracker Frames --
-- local PetBattle_EventFrame = CreateFrame("Frame");

-- Counts Pets Rare and NonRare
function SetCurrentPetInfo()
	local _, owned = C_PetJournal.GetNumPets();
	local nonRare = 0;
	for i = 1, owned do

		local petID,_,_,_, level,_,_,_,_,_,_,_,_,_,_, isTradeable,_,_ = C_PetJournal.GetPetInfoByIndex(i);
		local _,_,_,_, rarity = C_PetJournal.GetPetStats(petID);

		if rarity < 4 then
			nonRare = nonRare + 1;
		end
	end

	numPetsOwned = owned;
	numRareOwned = owned - nonRare;
	numNonRare = nonRare;
	percentTotalRare = math.floor(((numRareOwned/owned) * 100)+.5);
end

-- Returns number of currently owne Pet Charms.
function GetNumCurrentCharms()
	return GetItemCount(116415,true);
end

-- Returns true if item is owned
function IsToyOwned(itemID)
	return PlayerHasToy(itemID);
end

-- Returns true if player has learned at least 1 of the given pet\
function IsPetOwned(itemID)
	local isOwned = false;
	local _, numOwned = C_PetJournal.GetNumPets();
	for i = 1,numOwned - 1 do
		local _,_,owned,_,_,_,_,_,_,_,id = C_PetJournal.GetPetInfoByIndex(i);
		if itemID == id then
			if owned == true then
				isOwned = true;
			end
			break;
		end
	end
	return isOwned;
end

-- Returns an "int" ID of the current building info on the plot, or a -1 if there is no building currently built.
function GetGarrisonBuildingInfo(plotID)
	local builtID = C_Garrison.GetOwnedBuildingInfo(plotID); if builtID == nil then return -1 else return builtID end;
end

-- Menagerie Building IDs in order of rank 1-3: 42,167,168
-- Function returns rank ID of pet Menagerie building, or a -1 if none built.
function GetPetMenagerieLevel()
	local level = -1;
	local buildingID = GetGarrisonBuildingInfo(81);
	if buildingID == 42 then
		level = 1;
	elseif buildingID == 167 then
		level = 2;
	elseif buildingID == 168 then
		level = 3;
	end
	return level;
end

-- Returns Garrison level as an int
function GetGarrisonLevel()
	local level = C_Garrison.GetGarrisonInfo(LE_GARRISON_TYPE_6_0);
		if level == nil then
			level = -1 
		end; 
	return level;
end

-- Returns the int number of pet charms one can obtain from the Garrison account wide daily
-- Garrison Menagerie rank 1-2 means 4 charms per day, however rank 3 means 4-5 charms per day, so a 4.5 multiplier
-- A Global variable is used due to being important in other functions without needing to rework through this method.
function GetPotentialMenagerieCharms()
	local numCharmsFromGarrison = 0;
	if GetGarrisonLevel() == 3 then
		if IsQuestFlaggedCompleted(36483) == true or IsQuestFlaggedCompleted(36662) == true or IsQuestFlaggedCompleted(37645) == true or IsQuestFlaggedCompleted(37644) == true then -- Account wide quests, if any of the 4 is completed, wait til reset is necessary
			numCharmsFromGarrison = 0;
		else 
			local menagerieLevel = GetPetMenagerieLevel();
			if menagerieLevel == 3 then
				numCharmsFromGarrison = 4.5   -- You can get 4-5 charms from the rank 3 reward bag.
			elseif  menagerieLevel > 0 then
				numCharmsFromGarrison = 4  -- Scrappin Quest rewards 4
			end
		end
	end
	return numCharmsFromGarrison;
end

-- Returns information on still available battles and total possible charms.
-- Global variable also used to keep track of total charms as it is used elsewhere.
-- TO DO - Build a string
function GetDraenorZoneBattles(printResults)
	local grid = {};
	numCharmsFromDraenorZones = 0;

	local results = "\n ----- Draenor Daily Pet Battles Remaining ----- \n\n";

	-- Cymre Brightblade (Gorgrond)
	if not IsQuestFlaggedCompleted(37201) then
		numCharmsFromDraenorZones = numCharmsFromDraenorZones + 2;
		-- Building array
		grid[#grid + 1] = {"Cymre Blightblad:", "     Gorgrond","(+2)"};
	end
	-- Gargara (Frostfire Ridge)
	if not IsQuestFlaggedCompleted(37205) then
		numCharmsFromDraenorZones = numCharmsFromDraenorZones + 2;
		grid[#grid + 1] = {"Gargara:", "           Frostfire Ridge","(+2)"};
	end
	-- Tarr the Terrible (Nagrand)
	if not IsQuestFlaggedCompleted(37206) then
		numCharmsFromDraenorZones = numCharmsFromDraenorZones + 2;
		grid[#grid + 1] = {"Tarr the Terrible:", "        Nagrand","(+2)"};
	end
	-- Taralune (Talador)
	if not IsQuestFlaggedCompleted(37208) then
		numCharmsFromDraenorZones = numCharmsFromDraenorZones + 2;
		grid[#grid + 1] = {"Taralune:", "                      Talador","(+2)"};
	end
	-- Vesharr (Spires of Arak)
	if not IsQuestFlaggedCompleted(37207) then
		numCharmsFromDraenorZones = numCharmsFromDraenorZones + 2;
		grid[#grid + 1] = {"Vesharr:", "             Spires of Arak","(+2)"};
	end
	-- Ashlei (Shadowmoon Valley)
	if not IsQuestFlaggedCompleted(37203) then
		numCharmsFromDraenorZones = numCharmsFromDraenorZones + 2;
		grid[#grid + 1] = {"Ashlei:", "     Shadowmoon Valley","(+2)"};
	end

	-- Reporting Results
	if printResults == true then
		print(results);
		for i = 1,#grid do
			print(grid[i][1] .. "     " .. grid[i][2] .. "     " .. grid[i][3]);
		end
		if numCharmsFromDraenorZones < 1 then
			print("Awesome! You have already completed all 6 Pet Master Battles.")
		end
		local _,itemLink = GetItemInfo(116415);
		print("\n ----- Total Remaining: " .. numCharmsFromDraenorZones .. " x " .. itemLink);
	end
	
end

-- Tanaan Jungle Fights
-- Returns the results of charms one will get from the Fel-Touched Pet Supplies
function GetTanaanJungleFights(printResults)
	


end

-- Returns Information on the Toys you still need to get
function GetToysInfo()
	local charmsNeededForAllToys = 0;
	local toysResult = "\n ----- TOYS ----- ";

	-- Building Toys String
	for i = 2,#Toys,3 do
		if IsToyOwned(Toys[i]) == false then
			local _,link = GetItemInfo(Toys[i]);
			toysResult = (toysResult .. "\nNEED: " .. link .. "\nCOST: " .. Toys[i+1]);
			if Toys[i+1] <= numCharms then
				toysResult = (toysResult .. "" .. "\n----------") -- Placeholder " (Can Buy)" or something
			else
				toysResult = (toysResult  .. "\n----------");
			end
			charmsNeededForAllToys = charmsNeededForAllToys + Toys[i+1];
		end
	end
	
	if #toysResult > 19 then
		print("\n---------------------------------------\n---- PET CHARM TRACKER ----\n---------------------------------------");
		print(toysResult);
	end
	if charmsNeededForAllToys == 0 then
		print("\n---------------------------------------\n---- PET CHARM TRACKER ----\n---------------------------------------");
		print("Congratulations! You Have Already Learned All Purchaseable Toys!");
	else
		print("You need " .. charmsNeededForAllToys .. " charms to obtain all remaining Toys.");
	end
end

--Returns Information on the Pets you still need to get
function GetPetsToBuyInfo()
	local charmsNeededForAllPets = 0;
	local petsResult = "\n ----- PETS ----- ";

	-- Building Pets String
	for i = 2,#Pets,4 do
		if IsPetOwned(Pets[i]) == false then
			local _,link = GetItemInfo(Pets[i+2]);
			petsResult = (petsResult .. "\nNEED: " .. link .. "\nCOST: " .. Pets[i+1]);
			if Pets[i+1] <= numCharms then
				petsResult = (petsResult .. "" .. "\n----------") -- Placeholder " (Can Buy)" or something
			else
				petsResult = (petsResult  .. "\n----------");
			end
			charmsNeededForAllPets = charmsNeededForAllPets + Pets[i+1];
		end
	end

	if #petsResult > 19 then
		print("\n---------------------------------------\n---- PET CHARM TRACKER ----\n---------------------------------------");
		print(petsResult);
	end
	if charmsNeededForAllPets == 0 then
		print("\n---------------------------------------\n---- PET CHARM TRACKER ----\n---------------------------------------");
		print("Congratulations! You Have Already Learned All Purchaseable Battle Pets!");
	else
		print("You need " .. charmsNeededForAllPets .. " charms to obtain all remaining Battle Pets.");
	end
end

-- Core function to set all the charms across the entire game.  Other functions are compartmentalized for easy access if needed. 
-- This sums them all (Garrison, Tanaan, Wod Zones, and all Legion ones)
function SetNumPotentialCharms()
	local totalCharms = 0;

	-- From the Garrison Menagerie
	totalCharms = totalCharms + GetPotentialMenagerieCharms();

	-- From Tanaan Jungle battles.
end
	
-- Building the GUI
function PetCharmsGUI()
	message("TEST CHARMS ADDON");
end

-- Printed Results... eventually to be converted to actual results in GUI - But txt output example for now.
function PrintedResults()
	SetCurrentPetInfo();
	numCharms = GetNumCurrentCharms();

	local toysResult = "\n ----- TOYS ----- ";
	local petsResult = "\n ----- PETS ----- ";
	local charmsNeededForAllToys = 0;
	local charmsNeededForAllPets = 0;
	-- Building Toys String
	for i = 2,#Toys,3 do
		if IsToyOwned(Toys[i]) == false then
			local _,link = GetItemInfo(Toys[i]);
			toysResult = (toysResult .. "\nNEED: " .. link .. "\nCOST: " .. Toys[i+1]);
			if Toys[i+1] <= numCharms then
				toysResult = (toysResult .. "" .. "\n----------") -- Placeholder " (Can Buy)" or something
			else
				toysResult = (toysResult  .. "\n----------");
			end
			charmsNeededForAllToys = charmsNeededForAllToys + Toys[i+1];
		end
	end

	-- Building Pets String
	for i = 2,#Pets,4 do
		if IsPetOwned(Pets[i]) == false then
			local _,link = GetItemInfo(Pets[i+2]);
			petsResult = (petsResult .. "\nNEED: " .. link .. "\nCOST: " .. Pets[i+1]);
			if Pets[i+1] <= numCharms then
				petsResult = (petsResult .. "" .. "\n----------") -- Placeholder " (Can Buy)" or something
			else
				petsResult = (petsResult  .. "\n----------");
			end
			charmsNeededForAllPets = charmsNeededForAllPets + Pets[i+1];
		end
	end

	print("\n---------------------------------------\n---- PET CHARM TRACKER ----\n---------------------------------------");
	if #toysResult > 19 then
		print(toysResult);
	end
	if #petsResult > 19 then
		print(petsResult);
	end
	
	if charmsNeededForAllToys == 0 then
		print("Congratulations! You Have Already Learned All Purchaseable Toys!");
	elseif charmsNeededForAllPets == 0 then
		print("You need " .. charmsNeededForAllToys .. " charms to obtain all remaining Toys.");
	end

	if charmsNeededForAllPets == 0 then
		print("Congratulations! You Have Already Learned All Purchaseable Battle Pets!");
	elseif charmsNeededForAllToys == 0 then
		print("You need " .. charmsNeededForAllPets .. " charms to obtain all remaining Battle Pets.");
	end
	
	if charmsNeededForAllToys > 0 and charmsNeededForAllPets > 0 then
		print("You need " .. charmsNeededForAllToys + charmsNeededForAllPets .. " charms to obtain all remaining toys and pets!");
	end

	print "\n ----- RARE UPGRADE INFO ----- \n";
	print("You have a total of " .. numPetsOwned .. " pets!");
	print("You have " .. numRareOwned .. " pets that are Rare quality (" .. percentTotalRare .. "%).");
	print("You have " .. numNonRare .. " pets that still need to be upgraded!");
	print("You need a total of " .. numNonRare*15 .. " Pet Charms to upgrade all pets!");
	print("You currently have " .. GetNumCurrentCharms() .. ".");
	print("You only need a total of " .. (numNonRare*15 - GetNumCurrentCharms()) .." more to Upgrade all Pets to Rare Quality!");
end

-- On Initializing through Slash Command
SlashCmdList["PETCHARMSTRACKER"] = function(input)
	if input == nil or input:trim() == "" then
		PrintedResults();
	else
		-- Draenor Charms
		if input == "wod" or input == "draenor" then
			GetDraenorZoneBattles(true);
		-- Legion Charms
		elseif input == "legion" then
			print("Legion Battle Pet Masters:\n --Data to be added on August 30th with Legion Launch!!!");
		-- Focusing ONLY on Toys not Obtain
		elseif input == "toys" then
			GetToysInfo();
		elseif input == "pet" or input == "pets" then
			GetPetsToBuyInfo();
		end

	end
	
	-- To add /charms toys
	-- To add /charms pets
	--PetCharmsGUI();
end

-- Initializing
-- TESTING


