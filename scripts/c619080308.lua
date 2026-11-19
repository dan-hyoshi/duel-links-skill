-- Template Duel Links Skill Script
-- ???
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
	local e0N = e0:Clone()
	e0N:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e0N, tp)

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

-- SUMMON LIMIT
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	local is_tuner = c:IsType(TYPE_TUNER) or (c:GetOriginalType() & TYPE_TUNER) == TYPE_TUNER

	local is_wind_dragon = c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)

	return not (
		c:IsSetCard(0xa3) -- Stardust
		or c:IsCode(63436931)
		or is_wind_dragon
		or is_tuner
	)
end

-- EFFECT 1
function s.costfilter(c)
	return (c:IsLevel(1) and (c:Attack() == 0) and (c:Defense() == 0) and c:IsAttribute(ATTRIBUTE_LIGHT))
end

function s.spfilter(c, e, tp)
	return c:IsSetCard(0xa3) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.setfilter(c, e, tp)
	return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:ListsCode(44508094)
end

function s.effect1_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 1.. name it e_con1 please :v
	local e_con1 = Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 2, nil)
		and Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2
		and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 2, nil, e, tp)
		and Duel.GetLocationCount(tp, LOCATION_SZONE) >= 2
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
	if #g1 == 0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	local g2 = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, 1, g1:GetFirst())
	g1:Merge(g2)
	if #g1 < 2 or Duel.SendtoDeck(g1, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then
		return
	end

	local sg = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 2, 2, nil, e, tp)
	if #sg == 2 and Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP) > 0 then
		local tset = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK, 0, 2, 2, nil, e, tp)
		
		Duel.SSet(tp, tset)
		-- if Duel.SSet(tp, tset) > 0 then
		-- 	-- Loop through each card in the group
		-- 	local tc = tset:GetFirst()
		-- 	while tc do
		-- 		local e1 = Effect.CreateEffect(e:GetHandler())
		-- 		e1:SetType(EFFECT_TYPE_SINGLE)
		-- 		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		-- 		-- Added RESET_TOGRAVE/RESET_LEAVE to clean it up if the card moves
		-- 		e1:SetReset(RESET_EVENT | RESETS_CANNOT_ACT | RESET_PHASE | PHASE_END)
		-- 		tc:RegisterEffect(e1)

		-- 		tc = tset:GetNext()
		-- 	end
		-- end
	end
end

-- EFFECT 2

function s.addfilter(c)
	return (c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand() and c:IsRace(RACE_DRAGON))
end

function s.gyfilter(c)
	return (c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave() and c:IsRace(RACE_DRAGON))
end

function s.effect2_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 2.. name it e_con2 please :v
	local e_con2 = (
		Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 44508094), tp, LOCATION_MZONE, 0, 1, nil)
	) and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil)
	-- Restriction
	-- For once per Duel
	local restrict_2 = Duel.HasFlagEffect(tp, id + 1)

	-- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
	-- local restrict_2 = Duel.GetFlagEffect(tp, id+1) < x.

	return aux.CanActivateSkill(tp) and e_con2 and not restrict_2
end

function s.effect2_op(e, tp, eg, ep, ev, re, r, rp)
	local th = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #th > 0 then
		Duel.SendtoHand(th, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, th)

		-- Check if there are legal cards in the deck, then ask the player
		if
			Duel.IsExistingMatchingCard(s.gyfilter, tp, LOCATION_DECK, 0, 1, nil)
			and Duel.SelectYesNo(tp, aux.Stringid(id, 0))
		then -- Replace with your string ID or prompt
			-- Minimum is now safely 1, maximum is 2
			local tg = Duel.SelectMatchingCard(tp, s.gyfilter, tp, LOCATION_DECK, 0, 1, 2, nil)
			if #tg > 0 then
				Duel.SendtoGrave(tg, REASON_EFFECT)
			end
		end
	end
end
