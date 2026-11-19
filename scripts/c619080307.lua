-- Template Duel Links Skill Script
-- Beasts from the Abyss
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

s.listed_names = { 95515789, 68468459, 69120785 }
s.listed_series = { 0x189 }

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

	-- Skill Effect 1 Here~
	-- Reveal Bystial or Cartesia, add 1 Bystial and 1 monster that mention albaz
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
	-- e2:SetCountLimit(1, id)
	-- e2:SetCost(s.effect1_cost)
	e2:SetCondition(s.effect1_con)
	e2:SetOperation(s.effect1_op)
	e2:SetTarget(s.effect1_target)
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
	e3:SetTarget(s.effect2_target)
	Duel.RegisterEffect(e3, tp)

	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 2))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1, 0)
	e4:SetTarget(s.splimit)
	Duel.RegisterEffect(e4, tp)
end

-- SUMMON LIMITATION
function s.splimit(e, c, sump, sumtype, sumpos, targetp)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsLevelAbove(8) and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT)))
end

-- EFFECT 1
function s.revealfilter(c)
	return not c:IsPublic() and (c:IsCode(95515789) or c:IsSetCard(0x189))
end
function s.tgfilter(c)
	return c:IsCode(68468459) and c:IsAbleToGrave()
end
function s.thfilter1(c)
	return c:IsSetCard(0x189) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and (c:ListsCode(68468459) and not c:IsCode(68468459))
end

function s.effect1_target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.thfilter1, tp, LOCATION_DECK, 0, 1, nil)
			and Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 2, tp, LOCATION_DECK)
end

function s.effect1_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 1.. name it e_con1 please :v
	local e_con1 = Duel.IsExistingMatchingCard(s.revealfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil)

	-- Restriction
	-- For once per Duel
	local restrict_1 = Duel.HasFlagEffect(tp, id)

	-- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
	-- local restrict_1 = Duel.GetFlagEffect(tp, id) < x.

	return aux.CanActivateSkill(tp) and e_con1 and not restrict_1
end

function s.effect1_op(e, tp, eg, ep, ev, re, r, rp)
	-- COST:
	-- Reveal 1 from hand
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local g1 = Duel.SelectMatchingCard(tp, s.revealfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
	Duel.ConfirmCards(1 - tp, g1)
	Duel.ShuffleHand(tp)

	-- Send Fallen of Albaz from Deck to GY as part of the cost sequence
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g2 = Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	Duel.SendtoGrave(g2, REASON_COST)

	-- EFFECT:
	-- Effect 1 Operation here.. do whatever the effect do :v
	local g1 = Duel.GetMatchingGroup(s.thfilter1, tp, LOCATION_DECK, 0, nil)
	local g2 = Duel.GetMatchingGroup(s.thfilter2, tp, LOCATION_DECK, 0, nil)
	if #g1 == 0 or #g2 == 0 then
		return
	end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local sg1 = g1:Select(tp, 1, 1, nil)

	-- Remove already selected card from options if it overlaps definitions
	g2:RemoveCard(sg1:GetFirst())

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local sg2 = g2:Select(tp, 1, 1, nil)

	sg1:Merge(sg2)
	if #sg1 == 2 then
		Duel.SendtoHand(sg1, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, sg1)
	end
end

-- EFFECT 2
function s.effect2_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 2.. name it e_con2 please :v
	local e_con2 = Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0
		and Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
	-- Restriction
	-- For once per Duel
	local restrict_2 = Duel.HasFlagEffect(tp, id + 1)

	-- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
	-- local restrict_2 = Duel.GetFlagEffect(tp, id+1) < x.

	return aux.CanActivateSkill(tp) and e_con2 and not restrict_2
end

function s.addfilter(c)
	return c:IsSetCard(0x189) and c:IsAbleToHand()
end

function s.effect2_target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, 0) -- Target player 0 indicates outside card generation
end

function s.effect2_op(e, tp, eg, ep, ev, re, r, rp)
	-- Effect 2 Operation here.. do whatever the effect do :v
	-- Generate "The Bystial Alba Los" from outside the Duel/Deck directly to the GY
	local token = Duel.CreateToken(tp, 69120785)
	if token and Duel.SendtoGrave(token, REASON_EFFECT) > 0 then
		-- Add 1 Bystial monster from Deck to hand
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local g = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
		if #g > 0 then
			Duel.SendtoHand(g, nil, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, g)
		end
	end
end
