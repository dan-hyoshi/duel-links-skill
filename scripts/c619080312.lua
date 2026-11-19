-- Template Duel Links Skill Script
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

	-- local edmg = Effect.CreateEffect(c)
	-- edmg:SetType(EFFECT_TYPE_FIELD)
	-- edmg:SetCode(EFFECT_CHANGE_DAMAGE)
	-- edmg:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- edmg:SetTargetRange(0, 1)
	-- edmg:SetValue(s.damval)
	-- Duel.RegisterEffect(edmg, tp)

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

-- function s.damval(e, re, val, r, rp, rc)
-- 	-- Check if the damage is coming from a card effect AND you (tp) are the one causing it
-- 	Debug.Message("test: " ..tostring(r))
-- 	Debug.Message("test: " ..tostring(rc))

-- 	if (r & REASON_EFFECT) ~= 0 and rp == e:GetHandlerPlayer() then
-- 		-- If the card causing the damage is one of your allowed cards, inflict normal damage
-- 		if rc and (rc:IsCode(06560411) or rc:IsCode(69053263)) then
-- 			return val
-- 		end
-- 		-- Otherwise, change your effect damage to 0
-- 		return 0
-- 	end
-- end

function s.costfilter(c)
	return (c:IsCode(92595825) or c:IsCode(66100116)) and not c:IsPublic()
end

function s.addfilter(c, e, tp)
	return c:ListsCode(73580471) and c:IsAbleToHand()
end

function s.effect1_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 1.. name it e_con1 please :v
	local e_con1 = Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 2, nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, nil)

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
	local g1 = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_HAND, 0, 1, 1, nil)

	local sg = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 2, 2, nil, e, tp)

	if #sg == 2 then
		Duel.SendtoHand(sg, tp, REASON_EFFECT)

		local g2 = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, 1, nil)

		Duel.SendtoDeck(g2, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
	end
end

function s.exfilter(c, e, tp)
	return c:IsCode(33955120)
end

function s.effect2_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 2.. name it e_con2 please :v
	local e_con2 = (
		Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 06560411), tp, LOCATION_MZONE, 0, 1, nil)
	) and Duel.IsExistingMatchingCard(s.exfilter, tp, LOCATION_EXTRA | LOCATION_GRAVE, 0, 1, nil)

	-- Restriction
	-- For once per Duel
	local restrict_2 = Duel.HasFlagEffect(tp, id + 1)

	-- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
	-- local restrict_2 = Duel.GetFlagEffect(tp, id+1) < x.

	return aux.CanActivateSkill(tp) and e_con2 and not restrict_2
end

function s.effect2_op(e, tp, eg, ep, ev, re, r, rp)
	-- Effect 2 Operation here.. do whatever the effect do :v

	local th = Duel.SelectMatchingCard(tp, s.exfilter, tp, LOCATION_EXTRA | LOCATION_GRAVE, 0, 1, 1, nil)

	if #th > 0 then
		-- special summon the selected monster ignoring its summoning condition/treated as Synchro Summon even from GY
		local tc = th:GetFirst()

		-- 1. Check if the monster is coming from the Graveyard
		if tc:IsLocation(LOCATION_GRAVE) then
			-- Mark its built-in summoning procedure as completely fulfilled
			tc:SetStatus(STATUS_PROC_COMPLETE, true)
		end

		-- 2. Perform the Special Summon step
		-- Parameters: card, summon_type, summon_player, target_player, ignore_conditions, ignore_position, position
		if Duel.SpecialSummonStep(tc, SUMMON_TYPE_SYNCHRO, tp, tp, true, false, POS_FACEUP) then
			-- 3. Set the official summon metadata so it counts as a Synchro Summoned monster on the field
			tc:CompleteProcedure()
		end

		-- 4. Finalise the summon sequence
		Duel.SpecialSummonComplete()

		local glow = Duel.CreateToken(tp, 67441435)
		Duel.SendtoGrave(glow, REASON_EFFECT)

	end


end
