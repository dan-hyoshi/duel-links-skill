-- Template Duel Links Skill Script
-- Rescue-ACE:
-- You can only use this Skill's second and third effects once per Duel.
-- 1: You cannot Normal or Special Summon monsters (excluding Special Summons from the Extra Deck) with 3000 or less ATK, except "Rescue-ACE" monsters. Any effect damage your cards would inflict to your opponent becomes 0.
-- 2: Reveal 1 Level 6 or higher "Rescue-ACE" monster in your hand, and shuffle 1 card from your hand into the Deck. Then, add up to 2 "Rescue-ACE" cards from your Deck to your hand.
-- 3: If only your opponent controls a monster, play 1 "Rescue-ACE Hydrant" from your hand or Deck face-up to your field, and Set 1 "Rescue-ACE" Spell/Trap from your hand or Deck to your field (it can be activated this turn).
local s, id = GetID()
function s.initial_effect(c)
    -- Placing the Skill card to Skill Zone
	aux.AddSkillProcedure(c, 2, false, nil, nil)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetDescription(aux.Stringid(id,0))
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

    if false then return end -- Do change false to actual condition of the skill.

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

	local edmg = Effect.CreateEffect(c)
	edmg:SetType(EFFECT_TYPE_FIELD)
	edmg:SetCode(EFFECT_CHANGE_DAMAGE)
	edmg:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	edmg:SetTargetRange(0, 1)
	edmg:SetValue(s.damval)
	Duel.RegisterEffect(edmg, tp)

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
	if c:IsLocation(LOCATION_EXTRA) then
		return false
	end -- Excludes Extra Deck
	return not (c:IsAttackAbove(3000) or c:IsSetCard(0x18c))
end

function s.damval(e, re, val, r, rp, rc)
	if (r & REASON_EFFECT) ~= 0 then
		return 0
	end
	return val
end

-- 2: Reveal 1 Level 6 or higher "Rescue-ACE" monster in your hand, and shuffle 1 card from your hand into the Deck. Then, add up to 2 "Rescue-ACE" cards from your Deck to your hand.
function s.revfilter(c)
	return not c:IsPublic() and c:IsLevelAbove(6) and c:IsSetCard(0x18c)
end

function s.addfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x18c)
end

function s.effect1_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 1.. name it e_con1 please :v
	local e_con1 = Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 2, nil)

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

	if #g1 ~= 0 then
		local b2 = Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, nil)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
		local g = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, 1, nil)

		if Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) then
			if
				Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil)
			then
				local tg = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1, 2, nil)
				if #tg > 0 then
					Duel.SendtoHand(tg, nil, REASON_EFFECT)
				end
			end
		end
	end
end

function s.effect2_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 2.. name it e_con2 please :v

	-- Restriction
    -- For once per Duel
    local restrict_2 = Duel.HasFlagEffect(tp, id+1) 

    -- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
    -- local restrict_2 = Duel.GetFlagEffect(tp, id+1) < x.

	return aux.CanActivateSkill(tp) and e_con2 and not restrict_2
end

function s.effect2_op(e, tp, eg, ep, ev, re, r, rp)
	-- Effect 2 Operation here.. do whatever the effect do :v
end
