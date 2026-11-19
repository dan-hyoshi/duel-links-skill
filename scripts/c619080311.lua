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

s.signer_codes = { 25862681, 73580471, 9012916, 70902743 }

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

	local exadd = { 24696097, 44508094, 30983281, 60800381, 50091196 }

	for i = 1, #exadd do
		local extra = Duel.CreateToken(tp, exadd[i])
		Duel.SendtoDeck(extra, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
	end

	-- Activating Converging Wishes from hand.
	local cw = Effect.CreateEffect(c)
	cw:SetType(EFFECT_TYPE_SINGLE)
	cw:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(cw)

	local grantcw = Effect.CreateEffect(c)
	grantcw:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
	grantcw:SetTargetRange(LOCATION_HAND, 0)
	grantcw:SetTarget(function(e, c)
		return c:IsCode(20007374)
	end)
	grantcw:SetLabelObject(cw)
	Duel.RegisterEffect(grantcw, tp)

	-- Summon Limit
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

	return not (
		c:IsSetCard(0x43) -- JUNK
		or c:IsSetCard(0xa3)
		or c:IsSetCard(0x66)
		or (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON))
		or is_tuner
	)
end

-- EFFECT 1
function s.costfilter(c)
	return (c:IsCode(75874514) or (c:IsSetCard(0xa3) and c:IsLevel(4))) and c:IsAbleToDeck()
end
function s.spfilter(c, e, tp)
	return c:IsSetCard(0xa3) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.effect1_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 1.. name it e_con1 please :v
	local e_con1 = Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND, 0, 1, nil)
			and Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 2, nil)
			and Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2
			and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 2, nil, e, tp)
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
		-- Changed to search exactly Shining Star Dragon
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local th = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_DECK, 0, 1, 1, nil, 75874514)
		if #th > 0 then
			Duel.SendtoHand(th, nil, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, th)
		end

		local formula = Duel.CreateToken(tp, 50091196)
		local converter = Duel.CreateToken(tp, 11069680)

		if formula then
			-- Correct API method to mark a card as properly summoned
			formula:SetStatus(STATUS_PROC_COMPLETE, true)
			-- Assign the internal field directly to change its summon type metadata
			formula:CompleteProcedure()
		end

		local gy_group = Group.FromCards(formula, converter)
		Duel.SendtoGrave(gy_group, REASON_EFFECT)
	end
end

function s.effect2_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 2.. name it e_con2 please :v
	local e_con2 = (Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 63436931), tp, LOCATION_MZONE, 0, 1, nil)) and Duel.GetLocationCount(tp, LOCATION_MZONE) >= 3
	-- Restriction
	-- For once per Duel
	local restrict_2 = Duel.HasFlagEffect(tp, id + 1)

	-- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
	-- local restrict_2 = Duel.GetFlagEffect(tp, id+1) < x.

	return aux.CanActivateSkill(tp) and e_con2 and not restrict_2
end

function s.effect2_op(e, tp, eg, ep, ev, re, r, rp)
	-- Effect 2 Operation here.. do whatever the effect do :v
	-- 1. Create and Summon Life Stream Dragon explicitly
	local lsd = Duel.CreateToken(tp, 25165047)
	if lsd then
		lsd:SetStatus(STATUS_PROC_COMPLETE, true)
		lsd:CompleteProcedure()
		Duel.SpecialSummonStep(lsd, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
	end

	-- 2. Pick 2 random dragons out of the remaining 4
	local pool = { 25862681, 73580471, 9012916, 70902743 }
	local selected_codes = {}

	local r1 = Duel.GetRandomNumber(1, 4)
	table.insert(selected_codes, pool[r1])
	table.remove(pool, r1)

	local r2 = Duel.GetRandomNumber(1, 3)
	table.insert(selected_codes, pool[r2])

	-- 3. Summon the 2 random dragons and turn them to Level 2
	for _, code in ipairs(selected_codes) do
		local token = Duel.CreateToken(tp, code)
		if token then
			token:SetStatus(STATUS_PROC_COMPLETE, true)
			token:CompleteProcedure()
			if Duel.SpecialSummonStep(token, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) then
				local e3 = Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_CHANGE_LEVEL)
				e3:SetValue(2)
				e3:SetReset(RESET_EVENT + RESETS_STANDARD)
				token:RegisterEffect(e3)
			end
		end
	end

	Duel.SpecialSummonComplete()
end
