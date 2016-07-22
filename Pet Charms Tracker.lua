-- Author: Sklug
-- Program: To determine how many pet charms are needed to make every pet of yours Rare
--          But, also the ability to filter duplicates


-- Slash Commands
SLASH_PETCHARMSTRACKER1 = '/pct';
SLASH_PETCHARMSTRACKER2 = '/petcharms';
SLASH_PETCHARMSTRACKER3 = '/charms';

-- Instance Variables Initializing Base Uncalculated Value
local numPetsOwned = 0;
local numRareOwned = 0;
local numNonRare = 0;
local percentTotalRare = 0;
local charmsStillNeeded = 0;

-----------------------
-- Items to Purchase --
-----------------------
-- WoD Garrison Vendors (Giada Goldleash - Frostwall; Tiffy Trapspring - Lunarfall)
-- Item = {name,petID,CharmsCost,ItemID(pets)...}
-- TOYS -- 
local Toys = {"Magic Pet Mirror",127696,500,"Spirit Wand",127695,100,"Indestructible Bone",127707,50};

-- PETS -- 
local Pets = {"Lost Netherpup",93142,200,127705,"Glowing Sporebat",88575,100,127701,"Bloodthorn Hatchling",88514,50,127704,"Dusty Sporewing",88415,50,127703};


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

-- Printed Results... eventually to be converted to actual results.
function PrintedResults()
	SetCurrentPetInfo();
	numCharms = GetNumCurrentCharms();

	local toysResult = "\n ----- TOYS ----- ";
	local petsResult = "\n ----- PETS ----- ";
	local charmsNeededForAllToys = 0;
	local charmsNeededForAllPets = 0;
	-- Building Toys String
	for i = 2,#Toys,3 do
		if IsToyOwned(Toys[i]) == true then
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
		if IsPetOwned(Pets[i]) == true then
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

	print("     ---------------------------------------\n---- PET CHARM TRACKER ----\n---------------------------------------");
	if #toysResult > 19 then
		print(toysResult);
	end
	if #petsResult > 19 then
		print(petsResult);
	end
	
	if charmsNeededForAllToys == 0 then
		print("Congratulations! You Have Already Learned All Purchaseable Toys!");
	elseif charmsNeededForAllPets == 0 then
		print("You need " .. charmsNeededForAllToys .. " charms to obtain all Toys.");
	end

	if charmsNeededForAllPets == 0 then
		print("Congratulations! You Have Already Learned All Purchaseable Battle Pets!");
	elseif charmsNeededForAllToys == 0 then
		print("You need " .. charmsNeededForAllPets .. " charms to obtain all Battle Pets.");
	end
	
	if charmsNeededForAllToys > 0 and charmsNeededForAllPets > 0 then
		print("You need " .. charmsNeededForAllToys + charmsNeededForAllPets .. " charms to obtain all toys and pets!");
	end

	print "\n ----- RARE UPGRADES ----- \n";
	print("You have a total of " .. numPetsOwned .. " pets!");
	print("You have " .. numRareOwned .. " pets that are Rare quality (" .. percentTotalRare .. "%).");
	print("You have " .. numNonRare .. " pets that still need to be upgraded!");
	print("You need a total of " .. numNonRare*15 .. " Pet Charms to upgrade all pets!");
	print("You currently have " .. GetNumCurrentCharms() .. ".");
	print("You only need a total of " .. (numNonRare*15 - GetNumCurrentCharms()) .." more to Upgrade all Pets to Rare Quality!");
end

-- On Initializing through Slash Command
SlashCmdList["PETCHARMSTRACKER"] = function()
	PrintedResults();
end

-- Initializing
-- TESTING


