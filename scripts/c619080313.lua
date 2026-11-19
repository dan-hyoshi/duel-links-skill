-- Template Duel Links Skill Script
-- 1: You cannot Special Summon any monsters from your Extra Deck, except Xyz Monsters. Any effect damage your cards would inflict to your opponent becomes 0.
-- 2: Reveal 1 "Goblin Biker Dugg Charger" or 1 "Goblin Biker Grand Entrance" in your hand, and add up to 2 "Goblin Biker" monsters from your Deck to your hand. Then, you can Set 1 "Goblin Biker Grand Bash" from your Deck to your field.
-- 3: If only your opponent controls a monster, or you control a face-up "Goblin Biker Big Gabonga", Set 1 "Goblin Biker" Trap Card from your Deck to your field (It can be activated this turn.).
local s, id = GetID()
function s.initial_effect(c)
	-- Placing the Skill card to Skill Zone
	aux.AddSkillProcedure(c, 2, false, nil, nil)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetCountLimit(1)
	e1:SetLabel(0)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end

function s.startop(e, tp, eg, ep, ev, re, r, rp)
	-- Skill Condition Here~
	-- Condition can be written directly in flipop or here, but if you want to check for a condition before the skill is flipped, write it here.
	-- If you write in in flipop, just change the initial_effect SetOperation from e1:SetOperation(s.startop) to e1:SetOperation(s.flipop) and remove the startop function entirely. it should be fine :v

	if false then
		return
	end -- Do chenage false to actual condition of the skill.

	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(function()
		return Duel.GetCurrentChain() == 0 and Duel.GetTurnCount() == 1
	end)
	e1:SetOperation(s.flipop)
	e1:SetReset(RESET_PHASE | PHASE_DRAW)
	Duel.RegisterEffect(e1, tp)
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
	-- Skill will be flipped here, and effect can be activated..
	Duel.Hint(HINT_SKILL_FLIP, tp, id | (1 << 32))
	Duel.Hint(HINT_CARD, tp, id)
	local c = e:GetHandler()

	DL.AddSkill(c, tp)

	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetTargetRange(1, 0)
	e0:SetTarget(s.splimit)
	Duel.RegisterEffect(e0, tp)

	-- Skill Effect 1 Here~
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
	-- e2:SetCountLimit(1, id)
	e2:SetCondition(s.effect1_con)
	e2:SetOperation(s.effect1_op)
	Duel.RegisterEffect(e2, tp)

	-- Skill Effect 2 Here if Any~
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(0x5f)
	e3:SetCountLimit(1, id + 1, EFFECT_COUNT_CODE_DUEL) -- If once per Duel
	-- e2:SetCountLimit(1, id) -- If once per turn
	e3:SetCondition(s.effect2_con)
	e3:SetOperation(s.effect2_op)
	Duel.RegisterEffect(e3, tp)
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	-- If the card is being summoned from the Extra Deck...
	if c:IsLocation(LOCATION_EXTRA) then
		-- ...block the summon if it is NOT an Xyz Monster
		return not c:IsType(TYPE_XYZ)
	end

	-- Allow all other summons from any other location (Hand, GY, Deck, etc.)
	return false
end

function s.revfilter(c)
	return not c:IsPublic() and (c:IsCode(24079759) or c:IsCode(90711610))
end

function s.addfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x10AC) and c:IsType(TYPE_MONSTER)
end

function s.grandbash(c)
	return c:IsCode(64327901)
end

function s.effect1_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 1.. name it e_con1 please :v
	local e_con1 = Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 2, nil)
		and Duel.IsExistingMatchingCard(s.grandbash, tp, LOCATION_DECK, 0, 1, nil) and Duel.GetLocationCount(tp, LOCATION_SZONE) >= 1

	-- Restriction
	-- For once per Duel
	local restrict_1 = Duel.HasFlagEffect(tp, id)

	-- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
	-- local restrict_1 = Duel.GetFlagEffect(tp, id) < x.

	return aux.CanActivateSkill(tp) and e_con1 and not restrict_1
end

function s.effect1_op(e, tp, eg, ep, ev, re, r, rp)
	-- Effect 1 Operation here.. do whatever the effect do :v

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	local g1 = Duel.SelectMatchingCard(tp, s.revfilter, tp, LOCATION_HAND, 0, 1, 1, nil)

	if #g1 > 0 then
		Duel.SendtoHand(g1, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g1)

		-- Check if there are legal cards in the deck, then ask the player
		if
			Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil)
			and Duel.SelectYesNo(tp, aux.Stringid(id, 0))
		then -- Replace with your string ID or prompt
			-- Minimum is now safely 1, maximum is 2
			local tg = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1, 2, nil)
			if #tg > 0 then
				Duel.SendtoHand(tg, nil, REASON_EFFECT)
			end

			if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
				local g2 = Duel.SelectMatchingCard(tp, s.grandbash, tp, LOCATION_DECK, 0, 1, 1, nil)
				Duel.SSet(tp, g2)
			end
		end
	end
end

-- 3: If only your opponent controls a monster, or you control a face-up "Goblin Biker Big Gabonga", Set 1 "Goblin Biker" Trap Card from your Deck to your field (It can be activated this turn.).
function s.trapfilter(c)
	return (c:IsSetCard(0x10AC) and c:IsType(TYPE_TRAP))
end

function s.effect2_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 2.. name it e_con2 please :v
	local e_con2 = (Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 34001672), tp, LOCATION_MZONE|LOCATION_EMZONE, 0, 1, nil)) and Duel.GetLocationCount(tp, LOCATION_SZONE) >= 1 and Duel.IsExistingMatchingCard(s.trapfilter, tp, LOCATION_DECK, 0, 1, nil)

	-- Restriction
	-- For once per Duel
	local restrict_2 = Duel.HasFlagEffect(tp, id + 1)

	-- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
	-- local restrict_2 = Duel.GetFlagEffect(tp, id+1) < x.

	return aux.CanActivateSkill(tp) and e_con2 and not restrict_2
end

function s.effect2_op(e, tp, eg, ep, ev, re, r, rp)
	-- Effect 2 Operation here.. do whatever the effect do :v
	local g=Duel.SelectMatchingCard(tp, s.trapfilter,tp, LOCATION_DECK,0,1,1,nil)
	local c=g:GetFirst()
	if c and Duel.SSet(tp,c)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
	end
end
