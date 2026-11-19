-- Template Duel Links Skill Script
-- You can only use this Skill's second and third effects once per Duel.
-- 1: Your opponent takes no effect damage from your card effects, except by the effect of "Icejade Curse".
-- 2: Reveal 1 Level 7 WATER Tuner monster in your hand, and send 1 card from your hand to the Graveyard, then add up to 2 "Icejade" cards from your Deck to your hand and Set 1 "Icejade Cenote Enion Cradle" from outside your Deck to your field.
-- 3: If your opponent controls a monster, or you control a face-up Level 10 Synchro Monster, Set 1 "Icejade" monster from your Deck with a different name than face-up monsters you control (Its battle position can be changed). Then, Set 1 "Icejade" Spell/Trap from your hand or Deck to your field (It can be activated this turn.).
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

function s.revfilter(c)
	return not c:IsPublic() and c:IsLevel(7) and c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.addfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x16E)
end

function s.enioncradle(c)
	return c:IsCode(07142724)
end

function s.effect1_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 1.. name it e_con1 please :v
	local e_con1 = Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 2, nil)
		and Duel.GetLocationCount(tp, LOCATION_SZONE) >= 1
	-- Duel.IsExistingMatchingCard(s.grandbash, tp, LOCATION_DECK, 0, 1, nil) and

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
		local b2 = Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_HAND, 0, 1, nil)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
		local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_HAND, 0, 1, 1, nil)

		if Duel.SendtoGrave(g, REASON_EFFECT) then
			if
				Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil)
			then
				local tg = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1, 2, nil)
				if #tg > 0 then
					Duel.SendtoHand(tg, nil, REASON_EFFECT)

					local enote = Duel.CreateToken(tp, 07142724)
					Duel.SSet(tp, enote)
				end
			end
		end
	end
end

function s.level10(c)
	return c:IsLevel(10) and c:IsType(TYPE_SYNCHRO)
end

function s.spfilter(c,tp)
    -- Check if it is a monster and belongs to the archetype
    if not (c:IsMonster() and c:IsSetCard(0x16E)) then return false end
    
    -- Get all face-up monsters the player controls
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    
    -- Return true only if none of those face-up monsters share this card's name
    return not g:IsExists(Card.IsCode,1,nil,c:GetCode())
end

function s.backrowfilter(c)
	return c:IsSpellTrapCard() and c:IsSetCard(0x16E)
end

function s.effect2_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 2.. name it e_con2 please :v
	local e_con2 = (
		Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
		or Duel.IsExistingMatchingCard(s.level10, tp, LOCATION_MZONE, 0, 1, nil)
	) and Duel.GetLocationCount(tp, LOCATION_MZONE) >= 1 and Duel.GetLocationCount(tp, LOCATION_SZONE) >= 1 and Duel.IsExistingMatchingCard(s.backrowfilter, tp, LOCATION_DECK, 0, 1, nil)
	-- Restriction
	-- For once per Duel
	local restrict_2 = Duel.HasFlagEffect(tp, id + 1)

	-- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
	-- local restrict_2 = Duel.GetFlagEffect(tp, id+1) < x.

	return aux.CanActivateSkill(tp) and e_con2 and not restrict_2
end

function s.effect2_op(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, tp)
    local c=g:GetFirst()
    if c and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)~=0 then
        local back = Duel.SelectMatchingCard(tp, s.backrowfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        local b=back:GetFirst()
        if b then
            -- 1. Check the card type details HERE while it is still revealed/tracked out of the deck
            local is_trap = b:IsTrap()
            local is_quickplay = b:IsType(TYPE_QUICKPLAY)
            
            -- 2. Set the card to the field
            if Duel.SSet(tp, b)~=0 then
                -- 3. Create the effect modifying its activation rules
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                -- Use standard disable reset so it stays active while face-down this turn
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
                
                if is_trap then
                    e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
                    b:RegisterEffect(e1)
                elseif is_quickplay then
                    e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
                    b:RegisterEffect(e1)
                end
            end
        end
    end
end

