-- ************************** LBC META *****************************
-- * lbc_name = MorganaIsKool.lua
-- * lbc_version = 1.1
-- * lbc_date = 10/08/2014 // use correct date format mm/dd/yyyy
-- * lbc_status = 3 // 0 = unknowen; 1 = alpha/wip; 2 = beta; 3 = ready; 4 = required; 5 = outdated
-- * lbc_type = 3 // 0 = others; 1 = binaries; 2 = libs; 3 = champion; 4 = hotkey; 5 = utility
-- * lbc_creator = KoolKaracter
-- * lbc_champion = Morgana // if this script is for a special champ
-- * lbc_tags = Morgana, AP, Mage, Kool, kool, iskool, koolkaracter
-- * lbc_link = http://leaguebot.net/forum/Upload/showthread.php?tid=4493
-- * lbc_source = https://raw.githubusercontent.com/koolkaracter/Scripts/AutoKool/Champs/MorganaIsKool.lua
-- * lbc_update = // only if you have a new version on a new source
-- ************************** LBC META *****************************


local ScriptName = 'MorganaIsKool'									
local Version = '1.1'												
local Author = 'Koolkaracter'												
--[[	
   _____                                            .___          ____  __.            .__   
  /     \   ___________  _________    ____ _____    |   | ______ |    |/ _|____   ____ |  |  
 /  \ /  \ /  _ \_  __ \/ ___\__  \  /    \\__  \   |   |/  ___/ |      < /  _ \ /  _ \|  |  
/    Y    (  <_> )  | \/ /_/  > __ \|   |  \/ __ \_ |   |\___ \  |    |  (  <_> |  <_> )  |__
\____|__  /\____/|__|  \___  (____  /___|  (____  / |___/____  > |____|__ \____/ \____/|____/
        \/            /_____/     \/     \/     \/           \/          \/                  
                                                                                                       
]]



require 'yprediction'
require 'spell_damage'
require 'winapi'
require 'SKeys'
require 'Utils'
require 'vals_lib'
require 'spell_shot'
local yayo = require 'yayo'
local uiconfig = require 'uiconfig'
local send = require 'SendInputScheduled'
local YP = YPrediction()
local target = nil
local myAlly = nil
local attempts = 0
local lastAttempt = 0
local Q,W,E,R = 'Q','W','E','R'
local skillOrder = {}
local qRange, wRange, eRange, rRange = 1100, 900, 750, 600      						
local qSpeed, wSpeed, eSpeed, rSpeed = 1200, nil, 1750, nil     						
local qDelay, wDelay, eDelay, rDelay = .5, .5, .5, .5          						  
local qWidth, wWidth, eWidth, rWidth = 80, 280, nil, nil								
local qCollision, wCollision, eCollision, rCollision = true, false, false, false		
local tsRange = 1150
local CCList = {"Stun_glb", 
"AlZaharNetherGrasp_tar", 
"InfiniteDuress_tar", 
"SwapArrow_red", 
"LuxLightBinding_tar", 
"RunePrison_tar", 
"DarkBinding_tar", 
"Amumu_SadRobot_Ultwrap", 
"Amumu_Ultwrap", 
"RengarEMax_tar", 
"VarusRHitFlash", 
"Global_Taunt",
"LOC_Stun", 
"LOC_Suppress"}																	--Change this				

------------------------------------------------------------  
---------------------------Menu-----------------------------
------------------------------------------------------------
Cfg, menu = uiconfig.add_menu('Morgana Is Kool', 250)
local submenu = menu.submenu('1. Skill Options', 300)
submenu.label('lbS1', '--AutoCarry Mode--')
submenu.checkbox('Q_AC_ON', 'Use Q', true)
submenu.checkbox('W_AC_ON', 'Use W', true)
submenu.label('lbS2', '----Mixed Mode----')
submenu.checkbox('Q_M_ON', 'Use Q', true)
submenu.checkbox('W_M_ON', 'Use W', true)
submenu.label('lbS3', '----Lane Clear----')
submenu.checkbox('W_LC_ON', 'Use W', true)
submenu.label('lbS4', '----Misc Options----')
submenu.checkbox('Auto_E_ON', 'Auto Use E', false)
submenu.checkbox('Auto_W_ON', 'Auto Use W on CC\'ed Targ', true)

local submenu = menu.submenu('2. Target Selector', 300)
submenu.slider('TS_Mode', 'Target Selector Mode', 1,2,1, {'TS Primary', 'Get Weakest'})
submenu.checkbox('TS_Circles', 'Use Circles To ID Target(s)', true)
submenu.keydown('TS', 'Target Selection Hotkey', 0x01)

local submenu = menu.submenu('3. Draw Range', 150)
submenu.checkbox('qRange', 'Show Q Range ', true)
submenu.slider('qRangeColor', 'Color of Q Indicator?', 1, 6, 1, {"Green","Red", "Aqua", "Light Purple", "Blue", "Dark Purple"})
submenu.checkbox('wRange', 'Show W Range', false)
submenu.slider('wRangeColor', 'Color of W Indicator?', 1, 6, 1, {"Green","Red", "Aqua", "Light Purple", "Blue", "Dark Purple"})
submenu.checkbox('eRange', 'Show E Range', true)
submenu.slider('eRangeColor', 'Color of E Indicator?', 1, 6, 1, {"Green","Red", "Aqua", "Light Purple", "Blue", "Dark Purple"})
submenu.checkbox('rRange', 'Show R Range', false)
submenu.slider('rRangeColor', 'Color of R Indicator?', 1, 6, 1, {"Green","Red", "Aqua", "Light Purple", "Blue", "Dark Purple"})

local submenu = menu.submenu('4. Item Options', 225)
submenu.label('lbI1', '--Offensive Items--')
submenu.checkbox('BFT', '---Blackfire Torch---', true)
submenu.checkbox('DFG', '---Deathfire Grasp---', true)
submenu.checkbox('FQC', '---Frost Queens Claim---', true)
submenu.checkbox('TWS', '----Twin  Shadows----', true)
submenu.label('lbI1', '--Defensive Items--')
submenu.checkbox('ZH', 'Auto Use Zhonyas/Witchcap', true)
submenu.slider('ZHValue', 'Use Zhonyas/Witchcap at X% health', 0, 100, 20)
submenu.checkbox('SE', 'Auto Use Seraphs Embrace', true)
submenu.slider('SEValue', 'Use Seraphs Embrace at X% health', 0, 100, 20)

local submenu = menu.submenu('5. Summoner Spell Options', 300)
submenu.checkbox('Auto_Ignite_ON', 'Ignite', true)
submenu.checkbutton('Auto_Ignite_Self_ON', 'Ignite Self Cast (creates circle when killable)', false)
submenu.checkbox('Auto_Exhaust_ON', 'Exhaust', true)
submenu.slider('AutoExhaustValue', 'Auto Exhaust Value', 0, 100, 30)
submenu.checkbox('Auto_Barrier_ON', 'Barrier', true)
submenu.slider('AutoBarrierValue', 'Auto Barrier Value', 0, 100, 15)
submenu.checkbox('Auto_Clarity_ON', 'Clarity', true)
submenu.slider('AutoClarityValue', 'Auto Clarity Value', 0, 100, 40)
submenu.checkbox('Auto_Heal_ON', 'Heal', true)
submenu.checkbox('Auto_HealAlly_ON', 'Use Heal To Protect Allies', true)
submenu.slider('AutoHealValue', 'Auto Heal Value', 0, 100, 15)


local submenu = menu.submenu('6. Potion Options', 300)
submenu.checkbox('Health_Potion_ON', 'Health Potions', true)
submenu.slider('Health_Potion_Value', 'Health Potion Value', 0, 100, 75)
submenu.checkbox('Biscuit_ON', 'Biscuit', true)
submenu.slider('Biscuit_Value', 'Biscuit Value', 0, 100, 60)
submenu.checkbox('Chrystalline_Flask_ON', 'Chrystalline Flask', true)
submenu.slider('Chrystalline_Flask_Value', 'Chrystalline Flask Value', 0, 100, 75)
submenu.checkbox('Elixir_of_Fortitude_ON', 'Elixir of Fortitude', true)
submenu.slider('Elixir_of_Fortitude_Value', 'Elixir of Fortitude Value', 0, 100, 30)
submenu.checkbox('Mana_Potion_ON', 'Mana Potions', true)
submenu.slider('Mana_Potion_Value', 'Mana Potion Value', 0, 100, 75)

local submenu = menu.submenu('7. Kill Steal Options', 300)
submenu.checkbutton('KillSteal_ON', 'Single Spell Kill Steal', true)
submenu.checkbox('KSQ', 'KS with Q', true)
submenu.checkbox('KSW', 'KS with W', true)
submenu.checkbox('KSR', 'KS with R', false)
submenu.checkbox('KSDFG', 'KS with DFG', true)
submenu.checkbox('KSBFT', 'KS with BFT', true)
submenu.checkbox('KSIGN', 'KS with Ignite', true)

local submenu = menu.submenu('8. Misc Options', 300)
submenu.checkbox('ShowPHP', 'Show Your % of HP', true)
submenu.label('lbM1', '--Auto Level--')
submenu.checkbox('ALevel_ON', 'Use Auto Leveler', false)
submenu.slider('lvlOrder', 'Skill Leveling Order', 1, 6 , 3, {'RQWE', 'RQEW', 'RWQE', 'RWEQ','REQW', 'REWQ'})

menu.label('lb01', ' ')
menu.label('lb02', 'MorganaIsKool Version '..tostring(Version) ..' by KoolKaracter')
------------------------------------------------------------  
------------------------End Of Menu-------------------------
------------------------------------------------------------


------------------------------------------------------------
------------------------Main Function-----------------------
------------------------------------------------------------
function Main()
	TargetSelector()
	RangeIndicators()
	UseDefensiveItems()
	AutoSummoners()
	AutoPots()
	GetAlly()
	if Cfg['1. Skill Options'].Auto_W_ON and target ~= nil then UseW(target) end
	if Cfg['7. Kill Steal Options'].KillSteal_ON then KillSteal() end
	if Cfg['8. Misc Options'].ShowPHP then ShowPercentHP() end
	if Cfg['8. Misc Options'].ALevel_ON then AutoLvl() end
	
	if yayo.Config.AutoCarry then 
		if target ~= nil then 
			if Cfg['1. Skill Options'].Q_AC_ON then UseQ(target) end
			if Cfg['1. Skill Options'].W_AC_ON then UseW(target) end

		end
	end
	
	if yayo.Config.Mixed then 
		if target ~= nil then 
			if Cfg['1. Skill Options'].Q_M_ON then UseQ(target) end
			if Cfg['1. Skill Options'].W_M_ON then UseW(target) end

		end
	end
	
	if yayo.Config.LaneClear and Cfg['1. Skill Options'].W_LC_ON then ClearWithW() end
end
------------------------------------------------------------
--------------------End Of Main Function--------------------
------------------------------------------------------------


------------------------------------------------------------
---------------------------Skills---------------------------						
------------------------------------------------------------
function UseQ(targ)
	if targ ~= nil and GetDistance(targ, myHero) < qRange and IsSpellReady('Q') and ValidTarget(targ) and targ.dead ~= 1 then 
		CastPosition,  HitChance,  Position = YP:GetLineCastPosition(targ, qDelay, qWidth, qRange, wSpeed, myHero, qCollision)
		if CastPosition and HitChance >= 2 then 
			local x, y, z = CastPosition.x, CastPosition.y, CastPosition.z                
			CastSpellXYZ('Q', x, y, z)
		end
	end
end
 
function UseW(targ)
	if targ ~= nil and ValidTarget(targ) and GetDistance(targ, myHero) < wRange and targ.dead ~= 1 and IsSpellReady('W') and EnemyIsCCed(targ) then
		wPos = GetMEC(wWidth, wRange, targ)
		if wPos ~= nil then
			CastSpellXYZ("W", wPos.x, wPos.y, wPos.z)
		end
	end
end

function EnemyIsCCed(targ)
	local CCed = false
	local i = 1
	if targ ~= nil and targ.dead ~= 1 and targ.visible == 1 and ValidTarget(targ) then
		while CCList[i] ~= nil do
			if IsBuffed(targ, CCList[i]) then 
				CCed = true
			end

			i = i + 1
		end
	end

	return CCed
end

---Spell Clearing functions---
function ClearWithW()
	local targMinion = GetLowestHealthEnemyMinion(wRange)
	if targMinion ~= nil and targMinion.dead ~= 1 and ValidTarget(targMinion) and targMinion.visible == 1 then 
		UseWOnMinions(targMinion)
	end	
end

function UseWOnMinions(targ)
	if targ ~= nil and GetDistance(targ, myHero) < wRange and ValidTarget(targ) and IsSpellReady('W') then
		wPos = GetMinionMEC(wWidth, wRange, targ)
		if wPos ~= nil then
			CastSpellXYZ("W", wPos.x, wPos.y, wPos.z)
		end
	end
end

function GetMinionMEC(radius, range, targMin)
    assert(type(radius) == "number" and type(range) == "number" and (targMin == nil or targMin.team ~= nil), "GetMEC: wrong argument types (expected <number>, <number>, <object> or nil)")
    local points = {}
    for i = 1, objManager:GetMaxCreatures() do
        local object = objManager:GetCreature(i)
        if (targMin == nil and ValidTarget(object, (range + radius))) or (targMin and ValidTarget(object, (range + radius), (targMin.team ~= myHero.team)) and (ValidTargetNear(object, radius * 2, targMin) or object.networkID == targMin.networkID)) then
            table.insert(points, Vector(object))
        end
    end
    return _CalcSpellPosForGroup(radius, range, points)
end
--AutoE function
function OnProcessSpell(unit, spell)
	if unit ~= nil and spell ~= nil and unit.team ~= myHero.team and unit.type == 20 then
		startPos = spell.startPos
		endPos = spell.endPos
		if spell.target ~= nil then
			local targetSpell = spell.target
			if myAlly and myAlly.charName == targetSpell.charName then
					autoE(myAlly)
			end
			if myHero.charName == targetSpell.charName then
					autoE(myHero)
			end                    
		end
		if myAlly ~= nil then
			local shot = SpellShotTarget(unit, spell, myAlly)
			if shot ~= nil then
				spellShot = shot
				if spellShot.shot then
						autoE(myAlly)     
				end
			end
		end
		local shot = SpellShotTarget(unit, spell, myHero)
		if shot ~= nil then
			spellShot = shot
			if spellShot.shot then
				autoE(myHero)     
			end
		end
	end
end

function autoE(ally)
	if CanCastSpell("E") and Cfg['1. Skill Options'].Auto_E_ON then
			CastSpellTarget("E", ally)
	end    
end

function GetAlly()
	for i = 1, objManager:GetMaxHeroes() do
		local allyH = objManager:GetHero(i)
		if (allyH ~= nil and allyH.team == myHero.team and allyH.visible == 1 and GetDistance(myHero, allyH) < 750) or allyH == myHero then
			myAlly = allyH
		end
	end                         
end

------------------------------------------------------------
------------------------End Of Skills-----------------------
------------------------------------------------------------


------------------------------------------------------------
------------------------Target Selector---------------------
------------------------------------------------------------
function TargetSelector()
--TS Mode 1 (TS Primary)		
	if Cfg['2. Target Selector'].TS_Mode == 1 then
		if Cfg['2. Target Selector'].TS then
			for i = 1, objManager:GetMaxHeroes() do
				local enemy = objManager:GetHero(i)
				if enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and GetDistance(enemy,mousePos) < 150 then
					targetPri = enemy
				end
			end
		end
		if target ~= nil and (GetDistance(target, myHero) > tsRange or target.visible ~= 1) then target = nil end
		if 	targetPri ~= nil and ValidTarget(targetPri, tsRange) then
			target = targetPri
			yayo.ForceTarget(target)
		elseif target == nil or (targetPri ~= nil and ValidTarget(targetPri, tsRange) ~= 1) then
			target = GetWeakEnemy('MAGIC', tsRange)
			target = target
			yayo.ForceTarget(target)
		end
		if targetPri ~= nil and (targetPri.dead == 1 or myHero.dead == 1) then targetPri = nil end
		if target ~= nil and (target.dead==1 or myHero.dead==1) then 
				target = nil
		end
		if Cfg['2. Target Selector'].TS_Circles then 
			if targetPri ~= nil and targetPri ~= target then
				CustomCircle(100,10,9,targetPri)  --yellow
			end
			if target ~= nil then
				CustomCircle(100,10,1,target) -- green
			end
		end 
-- TS Mode 2 (Get Weakest)
	elseif Cfg['2. Target Selector'].TS_Mode == 2 then
		target = GetWeakEnemy('MAGIC', tsRange)
		yayo.ForceTarget(target)
		if target ~= nil and (GetDistance(target, myHero) > tsRange or target.visible ~= 1) then target = nil end
		if Cfg['2. Target Selector'].TS_Circles and target ~= nil then 
			CustomCircle(100,10,1,target)
		end
	else
		--Do nothing
	end
end
------------------------------------------------------------
--------------------End Of Target Selector------------------
------------------------------------------------------------


------------------------------------------------------------
-----------------------Range Indicators---------------------
------------------------------------------------------------
function RangeIndicators()
	--local qColor, wColor, eColor, rColor = GetColors()
	if Cfg['3. Draw Range'].qRange then
		DrawCircleObject(myHero, qRange, Cfg['3. Draw Range'].qRangeColor)
	end
	if Cfg['3. Draw Range'].wRange then
		DrawCircleObject(myHero, wRange, Cfg['3. Draw Range'].wRangeColor)
	end
	if Cfg['3. Draw Range'].eRange then
		DrawCircleObject(myHero, eRange, Cfg['3. Draw Range'].eRangeColor)
	end
	if Cfg['3. Draw Range'].rRange then
		DrawCircleObject(myHero, rRange, Cfg['3. Draw Range'].rRangeColor)
	end
end
------------------------------------------------------------
--------------------End Of Range Indicators-----------------
------------------------------------------------------------


------------------------------------------------------------
--------------------------Use Items-------------------------
------------------------------------------------------------
function UseOffensiveItems(target)
    AttackRange = myHero.range+(GetDistance(GetMinBBox(myHero)))

    if target ~= nil then
  			if Cfg['4. Item Options'].DFG and (GetDistance(myHero, target) < 750) then -- IR
				UseItemOnTarget(3128, target) -- Deathfire Grasp
			end        
			if Cfg['4. Item Options'].BFT and (GetDistance(myHero, target) < 750) then -- IR
				UseItemOnTarget(3188, target) -- Blackfire Torch
			end  
			if CfgKoolSettings['1. Kool Offensive Items'].DFG and (GetDistance(myHero, target) < 750) then -- IR
				UseItemOnTarget(3128, target) -- Deathfire Grasp
			end 			
			if Cfg['4. Item Options'].TWS and (GetDistance(myHero, target) < AttackRange+10) then -- IR
				UseItemOnTarget(3023, target) -- Twin Shadows on Summoners Rift & Howling Abyss
				UseItemOnTarget(3290, target) -- Twin Shadows on Crystal Scar & Twisted Treeline
			end    			
     end
end

function UseDefensiveItems()
	if IsBuffed(myHero, "FountainHeal") ~= true and IsBuffed(ally, 'TeleportHome.troy') ~= true  and IsBuffed(ally, 'TeleportHomeImproved.troy') ~= true then

		if Cfg['4. Item Options'].ZH and myHero.health <= (myHero.maxHealth*(Cfg['4. Item Options'].ZHValue / 100)) then --If health is below the slider % value
	        UseItemOnTarget(3157,myHero) -- Zhonya's Hourglass
	        UseItemOnTarget(3090,myHero) -- Wooglet's Witchap
	    end
               
		if Cfg['4. Item Options'].SE and myHero.health <= (myHero.maxHealth*(Cfg['4. Item Options'].SEValue / 100)) then --If health is below the slider % value
	        UseItemOnTarget(3040,myHero) -- Seraph's Embrace
	    end
	end
end
------------------------------------------------------------
-----------------------End Of Use Items---------------------
------------------------------------------------------------


------------------------------------------------------------
------------------------Summoner Spells---------------------
------------------------------------------------------------
local Summoners =
                {
                    Ignite = {Key = nil, Name = 'summonerdot'},
                    Exhaust = {Key = nil, Name = 'summonerexhaust'},
                    Heal = {Key = nil, Name = 'summonerheal'},
                    Clarity = {Key = nil, Name = 'summonermana'},
                    Barrier = {Key = nil, Name = 'summonerbarrier'},
                }

if myHero ~= nil then
    for _, Summoner in pairs(Summoners) do
        if myHero.SummonerD == Summoner.Name then
            Summoner.Key = "D"
        elseif myHero.SummonerF == Summoner.Name then
            Summoner.Key = "F"
        end
    end
end

function AutoSummoners()
        if Cfg['5. Summoner Spell Options'].Auto_Ignite_ON then SummonerIgnite() end
        if Cfg['5. Summoner Spell Options'].Auto_Barrier_ON then SummonerBarrier() end
        if Cfg['5. Summoner Spell Options'].Auto_Heal_ON then SummonerHeal() end
        if Cfg['5. Summoner Spell Options'].Auto_Exhaust_ON then SummonerExhaust() end
        if Cfg['5. Summoner Spell Options'].Auto_Clarity_ON then SummonerClarity() end
end
 
function SummonerIgnite()
--print( Cfg['5. Summoner Spell Options'].Auto_Ignite_Self_ON)
--[[
This Ignite scripts calculates the targets health regen and
determines if you can kill the target taking in account their
natural health regen. This does not yet take into account health
regen from items... Some day perhaps!
]]--	

	if myHero.SummonerD == 'summonerdot'  or myHero.SummonerF == 'summonerdot' then --Dont waist time/energy if you dont have ignite 
		if myHero.SummonerD == 'summonerdot' then 
			ignKey = Keys.D
		else 
			ignKey = Keys.F
		end		

		for i = 1, objManager:GetMaxHeroes() do
            		local targetIgnite = objManager:GetHero(i)
			if targetIgnite ~= nil and targetIgnite.team ~= myHero.team and targetIgnite.visible == 1 and GetDistance(myHero, targetIgnite) < 700 then 
				local targetName = champdb[targetIgnite.name]
				local damage = (myHero.selflevel*20)+50
				local targetRegenPerSec = (targetName.healthRegenBase + (targetName.healthRegenLevel * targetIgnite.selflevel))
				local ignDamageAfterRegen = (damage-((targetRegenPerSec*5)/2))  
				local targCircle = 0

				if Cfg['5. Summoner Spell Options'].Auto_Ignite_Self_ON then 
					if (ignKey == Keys.D and myHero.SpellTimeD > 1) or (ignKey == Keys.F and myHero.SpellTimeF > 1 )then
						if targetIgnite.health < ignDamageAfterRegen and GetDistance(myHero, targetIgnite) < 600 then
							CustomCircle(80,8,2,targetIgnite)--RED
							targCircle = 2	--Ready to Cast     	                       		
						elseif targetIgnite.health < ignDamageAfterRegen and GetDistance(myHero, targetIgnite) > 599 and GetDistance(myHero, targetIgnite) < 700 then
							CustomCircle(80,8,8,targetIgnite) --ORANGE
							targCircle = 1 --Ready to cast but target is just out of range (100 away)
						else
							targCircle = 0
						end
					
						if targCircle == 2 and IsKeyDown(ignKey) then CastSummonerIgn(targetIgnite) end --Cast ignite on killable target when ignite key is pressed
					end
				elseif  Cfg['5. Summoner Spell Options'].Auto_Ignite_Self_ON == false then 
					if targetIgnite.health < ignDamageAfterRegen and GetDistance(myHero, targetIgnite) < 600 then CastSummonerIgn(targetIgnite) end

				end 				                   		
			end
		end
	end
end
 
 
function SummonerBarrier()
                if myHero.SummonerD == 'summonerbarrier' or myHero.SummonerF == 'summonerbarrier' then
                        if myHero.health < myHero.maxHealth*(Cfg['5. Summoner Spell Options'].AutoBarrierValue / 100) then
                                CastSummonerBar()
                        end
                end
end
 
function SummonerHeal()
        if myHero.SummonerD == 'summonerheal' or myHero.SummonerF == 'summonerheal' then
                if Cfg['5. Summoner Spell Options'].Auto_HealAlly_ON then --will activate when alley within range is below X%
                        for h = 1, objManager:GetMaxHeroes() do
                                        local allyH = objManager:GetHero(h)
                                        if (allyH ~= nil and allyH.team == myHero.team and allyH.visible == 1 and GetDistance(myHero, allyH) < 700) or allyH == myHero then
                                                        if allyH.health <= (allyH.maxHealth*(Cfg['5. Summoner Spell Options'].AutoHealValue / 100)) then --If health is below the slider % value
															CastSummonerHea()                            
                                                        end
                                        end
                        end
                else --HealAlly not on, will just activate on self
                        if myHero.health < myHero.maxHealth*(Cfg['5. Summoner Spell Options'].AutoHealValue / 100) then
                                CastSummonerHea()
                        end
                end
        end
end
 
function SummonerExhaust()
        if target ~= nil then
                if myHero.SummonerD == 'summonerexhaust' or myHero.SummonerF == 'summonerexhaust' then
                        if myHero.health < myHero.maxHealth*(Cfg['5. Summoner Spell Options'].AutoExhaustValue / 100) and GetDistance(myHero, target) < 650 then
                                if myHero.health < target.health then
                                        CastSummonerExh(target)
                                end
                        end
                end
        end
end
 
function SummonerClarity()
                if myHero.SummonerD == 'summonermana' or myHero.SummonerF == 'summonermana' then
                        if myHero.mana < myHero.maxMana*(Cfg['5. Summoner Spell Options'].AutoClarityValue / 100) then
                                CastSummonerCla()
                        end
                end
end

function CastSummonerIgn(target)
    if ValidTarget(target) and Summoners.Ignite.Key ~= nil then
        CastSpellTarget(Summoners.Ignite.Key, target)
    end
end

function CastSummonerExh(target)
    if ValidTarget(target) and Summoners.Exhaust.Key ~= nil then
        CastSpellTarget(Summoners.Exhaust.Key, target)
    end
end

function CastSummonerHea(x, y, z)
    local unit
    if x == nil then
        unit = myHero
    elseif type(x) ~= 'number' then
        unit = x        
    end
    if unit then
        x, y, z = unit.x, unit.y, unit.z
    end
    if Summoners.Heal.Key ~= nil then
        CastSpellXYZ(Summoners.Heal.Key, x, y, z)
    end
end

function CastSummonerCla()
    if Summoners.Clarity.Key ~= nil then
        CastSpellTarget(Summoners.Clarity.Key, myHero)
    end
end

function CastSummonerBar()
    if Summoners.Barrier.Key ~= nil then
        CastSpellTarget(Summoners.Barrier.Key, myHero)
    end
end
------------------------------------------------------------
---------------------End Of Summoner Spells-----------------
------------------------------------------------------------


------------------------------------------------------------
--------------------------Use Potions-------------------------
------------------------------------------------------------
function AutoPots()
        if IsBuffed(myHero, "FountainHeal") ~= true and IsBuffed(ally, 'TeleportHome.troy') ~= true  and IsBuffed(ally, 'TeleportHomeImproved.troy') ~= true then
                if Cfg['6. Potion Options'].Health_Potion_ON and myHero.health < myHero.maxHealth * (Cfg['6. Potion Options'].Health_Potion_Value / 100) and IsBuffed(myHero, 'Global_Item_HealthPotion') ~= true and IsBuffed(myHero, 'GLOBAL_Item_HealthPotion') ~= true then
                        usePotion()
                end
                if Cfg['6. Potion Options'].Biscuit_ON and myHero.health < myHero.maxHealth * (Cfg['6. Potion Options'].Biscuit_Value / 100) and IsBuffed(myHero, 'Global_Item_HealthPotion')~= true and IsBuffed(myHero, 'GLOBAL_Item_HealthPotion') ~= true then
                        useBiscuit()
                end    
                if Cfg['6. Potion Options'].Chrystalline_Flask_ON and myHero.health < myHero.maxHealth * (Cfg['6. Potion Options'].Chrystalline_Flask_Value / 100) and IsBuffed(myHero, 'Global_Item_HealthPotion') ~= true and IsBuffed(myHero, 'GLOBAL_Item_HealthPotion') ~= true then
                        useFlask()
                end    
                if Cfg['6. Potion Options'].Elixir_of_Fortitude_ON and myHero.health < myHero.maxHealth * (Cfg['6. Potion Options'].Elixir_of_Fortitude_Value / 100) and IsBuffed(myHero, 'PotionofGiantStrength_itm') ~= true  then
                        useElixir()
                end
                if Cfg['6. Potion Options'].Mana_Potion_ON and myHero.mana < myHero.maxMana * (Cfg['6. Potion Options'].Mana_Potion_Value / 100) and IsBuffed(myHero, 'Global_Item_ManaPotion') ~= true and IsBuffed(myHero, 'GLOBAL_Item_ManaPotion') ~= true then
                        useManaPot()
                end
        end
end
 
 
function usePotion()
        UseItemOnTarget(2003,myHero)
end
 
function useBiscuit()
        UseItemOnTarget(2010,myHero)
end
 
function useFlask()
        UseItemOnTarget(2041,myHero)
end
 
function useElixir()
        UseItemOnTarget(2037,myHero)
end
 
function useManaPot()
        UseItemOnTarget(2004,myHero)
end
------------------------------------------------------------
-----------------------End Of Use Potions-------------------
------------------------------------------------------------


------------------------------------------------------------
-----------------------Kill Steal Function------------------
------------------------------------------------------------
function KillSteal()

	for i = 1, objManager:GetMaxHeroes() do
          local ksTarg = objManager:GetHero(i)
		  
			if Cfg['7. Kill Steal Options'].KSQ and ksTarg ~= nil and ksTarg.team ~= myHero.team and ValidTarget(ksTarg) and GetDistance(myHero, ksTarg) < qRange and getDmg('Q', ksTarg, myHero) >= ksTarg.health then UseQ(ksTarg) end
			if Cfg['7. Kill Steal Options'].KSW and ksTarg ~= nil and ksTarg.team ~= myHero.team and ValidTarget(ksTarg) and GetDistance(myHero, ksTarg) < wRange and getDmg('W', ksTarg, myHero) >= ksTarg.health then UseW(ksTarg) end
			if Cfg['7. Kill Steal Options'].KSR and ksTarg ~= nil and ksTarg.team ~= myHero.team and ValidTarget(ksTarg) and GetDistance(myHero, ksTarg) < rRange and getDmg('R', ksTarg, myHero) >= ksTarg.health then UseR(ksTarg) end
			if Cfg['7. Kill Steal Options'].KSDFG and ksTarg ~= nil and ksTarg.team ~= myHero.team and ValidTarget(ksTarg) and GetDistance(myHero, ksTarg) < 750 and getDmg('DFG', ksTarg, myHero) >= ksTarg.health then UseItemOnTarget(3128, ksTarg) end
			if Cfg['7. Kill Steal Options'].KSBFT and ksTarg ~= nil and ksTarg.team ~= myHero.team and ValidTarget(ksTarg) and GetDistance(myHero, ksTarg) < 750 and getDmg('BLACKFIRE', ksTarg, myHero) >= ksTarg.health then UseItemOnTarget(3188, ksTarg) end
			if Cfg['7. Kill Steal Options'].KSIGN and ksTarg ~= nil and ksTarg.team ~= myHero.team and ValidTarget(ksTarg) and GetDistance(myHero, ksTarg) < 600 and getDmg('IGNITE', ksTarg, myHero) >= ksTarg.health  and (Cfg['5. Summoner Spell Options'].Auto_Ignite_Self_ON ~= true) then CastSummonerIgn(ksTarg) end
	end
end
------------------------------------------------------------
-------------------End Of Kill Steal Function---------------
------------------------------------------------------------


------------------------------------------------------------
--------------------Miscellaneous Functions-----------------
------------------------------------------------------------
function ShowPercentHP()
 
        local myHP = ((myHero.health / myHero.maxHealth) * 100)
        myHP = string.format('%d%%', myHP)
        DrawTextObject(myHP,myHero,Color.White)
       
end

function Level_Spell(letter)  
     if letter == Q then send.key_press(0x69)
     elseif letter == W then send.key_press(0x6a)
     elseif letter == E then send.key_press(0x6b)
     elseif letter == R then send.key_press(0x6c) 
	 end
end

function GetSkillOrder()
	if Cfg['8. Misc Options'].lvlOrder == 1 then 
		skillOrder = {Q,W,Q,E,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E}
	end
	if Cfg['8. Misc Options'].lvlOrder == 2 then 
		skillOrder = {Q,E,Q,W,Q,R,Q,E,Q,E,R,E,E,W,W,R,W,W}
	end
	if Cfg['8. Misc Options'].lvlOrder == 3 then 
		skillOrder = {W,Q,W,E,W,R,W,Q,W,Q,R,Q,Q,E,E,R,E,E}
	end	
	if Cfg['8. Misc Options'].lvlOrder == 4 then 
		skillOrder = {W,E,W,Q,W,R,W,E,W,E,R,E,E,Q,Q,R,Q,Q}
	end		
	if Cfg['8. Misc Options'].lvlOrder == 5 then 
		skillOrder = {E,Q,E,W,E,R,E,Q,E,Q,R,Q,Q,W,W,R,W,W}
	end
	if Cfg['8. Misc Options'].lvlOrder == 6 then 
		skillOrder = {E,W,E,Q,E,R,E,W,E,W,R,W,W,Q,Q,R,Q,Q}
	end	
end

function AutoLvl()
    if IsChatOpen() == 0 then
		GetSkillOrder()
        spellLevelSum = GetSpellLevel(Q) + GetSpellLevel(W) + GetSpellLevel(E) + GetSpellLevel(R)

        if attempts <= 10 or (attempts > 10 and GetTickCount() > lastAttempt+1500) then
            if spellLevelSum < myHero.selflevel then
                if lastSpellLevelSum ~= spellLevelSum then attempts = 0 end
                letter = skillOrder[spellLevelSum+1]
                Level_Spell(letter, spellLevelSum)
                attempts = attempts+1
                lastAttempt = GetTickCount()
                lastSpellLevelSum = spellLevelSum
            else
                attempts = 0
            end
        end
    end
	send.tick()
end
------------------------------------------------------------
----------------End Of Miscellaneous Functions--------------
------------------------------------------------------------


SetTimerCallback('Main')
