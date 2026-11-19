-- I'll Show You Perfection
local s, id = GetID()
function s.initial_effect(c)
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

function s.cydra_filter(c)
	return c:IsCode(CARD_CYBER_DRAGON) and c:IsAbleToGrave()
end

function s.startop(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetMatchingGroup(s.cydra_filter, tp, LOCATION_DECK, 0, nil)
	if #g == 0 then
		return
	end

	-- 2. Prompt the player to select exactly 1 "Cyber Dragon" out of the filtered group
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local sg = Duel.SelectMatchingCard(tp, s.cydra_filter, tp, LOCATION_DECK, 0, 1, 1, nil)

	-- 3. Safely send the selected card to the Graveyard
	if #sg > 0 then
		Duel.SendtoGrave(sg, REASON_EFFECT)
	end

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
	Duel.Hint(HINT_SKILL_FLIP, tp, id | (1 << 32))
	Duel.Hint(HINT_CARD, tp, id)
	local c = e:GetHandler()

	DL.AddSkill(c, tp)

	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
	-- e2:SetCountLimit(1, id)
	e2:SetCondition(s.cyber_dragon_con)
	e2:SetOperation(s.cyber_dragon_op)
	Duel.RegisterEffect(e2, tp)

	-- local e3 = Effect.CreateEffect(c)
	-- e3:SetDescription(aux.Stringid(id, 1))
	-- e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	-- e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	-- e3:SetCode(EVENT_FREE_CHAIN)
	-- e3:SetRange(0x5f)
	-- e3:SetCountLimit(1, id + 1, EFFECT_COUNT_CODE_DUEL)
	-- -- e2:SetCountLimit(1, id)
	-- e3:SetCondition(s.cyber_end_con)
	-- e3:SetOperation(s.cyber_end_op)
	-- Duel.RegisterEffect(e3, tp)
end

local CARD_CYBER_JORMUNGARDR = 19715246
local CARD_CYBERNETIC_OVERFLOW = 82428674

function s.rev_filter(c)
	return (c:IsCode(CARD_CYBER_DRAGON) or c:IsCode(CARD_CYBER_JORMUNGARDR)) and not c:IsPublic()
end

function s.add_cydra_filter(c)
	return c:IsSetCard(SET_CYBER_DRAGON) and c:IsMonster() and c:IsLevelBelow(2) and c:IsAbleToHand()
end

function s.cyber_dragon_con(e, tp, eg, ep, ev, re, r, rp)
	local cydra_con = Duel.IsExistingMatchingCard(s.rev_filter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.add_cydra_filter, tp, LOCATION_DECK, 0, 1, nil)

	return aux.CanActivateSkill(tp) and cydra_con and not Duel.HasFlagEffect(tp, id)
end

function s.cyber_dragon_op(e, tp, eg, ep, ev, re, r, rp)
    -- 1. Reveal 1 "Cyber Dragon" or "Cyber Jormungardr" from hand
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local rg = Duel.SelectMatchingCard(tp, s.rev_filter, tp, LOCATION_HAND, 0, 1, 1, nil)
    if #rg == 0 then return end
    Duel.ConfirmCards(1 - tp, rg)
    Duel.ShuffleHand(tp)

    -- 2. Add up to 2 Level 2 or lower "Cyber Dragon" monsters from Deck to hand
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local sg = Duel.SelectMatchingCard(tp, s.add_cydra_filter, tp, LOCATION_DECK, 0, 1, 2, nil)
    if #sg > 0 then
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end

    -- 3. Set 1 "Cybernetic Overflow" from outside the Deck to the field
    local token = Duel.CreateToken(tp, CARD_CYBERNETIC_OVERFLOW)
    if token and Duel.MoveToField(token, tp, tp, LOCATION_SZONE, POS_FACEDOWN, true) then
        -- This specific property flag override enables Trap activation on the exact turn it is Set
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetReset(RESET_EVENT | RESETS_STANDARD | RESET_PHASE | PHASE_END)
        token:RegisterEffect(e1)
    end
end

-- --- EFFECT 3 FUNCTIONS: Cyber End Challenge & Spell Lock ---

-- function s.grab_cydra_filter(c)
--     return c:IsCode(CARD_CYBER_DRAGON) and c:IsAbleToHand()
-- end

-- function s.cyber_end_con(e, tp, eg, ep, ev, re, r, rp)
--     local ph = Duel.GetCurrentPhase()
--     return (ph == PHASE_MAIN1 or ph == PHASE_MAIN2)
--         and Duel.GetTurnCount() >= 2 -- Enforces from turn 2 onward parameter rule
--         and Duel.IsExistingMatchingCard(s.grab_cydra_filter, tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, nil)
--         and not Duel.HasFlagEffect(tp, id + 100)
-- end

-- function s.cyber_end_op(e, tp, eg, ep, ev, re, r, rp)
--     if not Duel.SelectEffectYesNo(tp, e:GetHandler(), aux.Stringid(id, 1)) then return end
--     Duel.RegisterFlagEffect(tp, id + 100, RESET_PHASE | PHASE_END, 0, 1)

--     -- Add up to 3 "Cyber Dragon" from Deck and/or GY to hand
--     Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
--     local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.grab_cydra_filter), tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, 3, nil)
--     if #g > 0 then
--         Duel.SendtoHand(g, nil, REASON_EFFECT)
--         Duel.ConfirmCards(1 - tp, g)
--     end

--     -- Establish the permanent global Duel challenge listener if not already tracking
--     if not Duel.HasFlagEffect(tp, id + 200) then
--         Duel.RegisterFlagEffect(tp, id + 200, 0, 0, 0) -- Master challenge state tracker flag

--         -- Sub-listener A: Global Spell lock restriction rule
--         local e1 = Effect.CreateEffect(e:GetHandler())
--         e1:SetType(EFFECT_TYPE_FIELD)
--         e1:SetCode(EFFECT_CANNOT_ACTIVATE)
--         e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
--         e1:SetTargetRange(1, 0)
--         e1:SetCondition(s.lock_condition)
--         e1:SetTarget(s.lock_target)
--         e1:SetValue(1)
--         Duel.RegisterEffect(e1, tp)

--         -- Sub-listener B: Special Summon success interceptor to unlock Spells permanently
--         local e2 = Effect.CreateEffect(e:GetHandler())
--         e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
--         e2:SetCode(EVENT_SPSUMMON_SUCCESS)
--         e2:SetCondition(s.unlock_condition)
--         e2:SetOperation(s.unlock_operation)
--         Duel.RegisterEffect(e2, tp)
--     end
-- end

-- -- Rules execution for the challenge logic loops
-- function s.lock_condition(e)
--     -- Kept active as long as the player hasn't triggered the successful Cyber End Summon flag
--     return not Duel.HasFlagEffect(e:GetOwnerPlayer(), id + 300)
-- end

-- function s.lock_target(e, re, tp)
--     -- Intercepts and blocks Spell triggers unless they match Polymerization or Power Bond IDs
--     return re:IsActiveType(TYPE_SPELL) 
--         and not (re:GetHandler():IsCode(CARD_POLYMERIZATION) or re:GetHandler():IsCode(CARD_POWER_BOND))
-- end

-- function s.unlock_condition(e, tp, eg, ep, ev, re, r, rp)
--     -- Scan special summoned elements for a matching Cyber End Dragon controlled by the skill owner
--     return eg:IsExists(function(c) return c:IsCode(CARD_CYBER_END_DRAGON) and c:IsSummonPlayer(e:GetOwnerPlayer()) end)
-- end

-- function s.unlock_operation(e, tp, eg, ep, ev, re, r, rp)
--     -- Permanently unlocks regular Spells for the rest of the match
--     Duel.RegisterFlagEffect(e:GetOwnerPlayer(), id + 300, 0, 0, 0)
--     Duel.Hint(HINT_MESSAGE, e:GetOwnerPlayer(), aux.Stringid(id, 2)) -- System prompt: Challenge Completed!
--     e:Reset()
-- end