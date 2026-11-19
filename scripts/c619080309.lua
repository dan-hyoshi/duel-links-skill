-- Template Duel Links Skill Script
-- The Courage to Rise
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

    if false then return end -- Do chenage false to actual condition of the skill.

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

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetTargetRange(1, 0)
	e0:SetCondition(s.limitCon)
	e0:SetTarget(s.splimit)
	Duel.RegisterEffect(e0, tp)
	local e0N=e0:Clone()
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
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.effect2_op)
	Duel.RegisterEffect(e3, tp)
end

-- SUMMON LIMIT
function s.limitCon(e, tp, eg, ep, ev, re, r, rp)
	local tp = e:GetHandlerPlayer()
	return Duel.GetTurnPlayer() == tp
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    if c:IsLocation(LOCATION_EXTRA) then return false end -- Excludes Extra Deck
    return not c:IsSetCard(SET_CENTUR_ION)
end

-- EFFECT 1
function s.revealfilter(c)
	return not c:IsPublic() and (c:IsSetCard(SET_CENTUR_ION) and c:IsType(TYPE_MONSTER))
end

function s.thfilter1(c)
	return c:IsSetCard(SET_CENTUR_ION) and c:IsAbleToHand()
end

function s.effect1_target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.thfilter1, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.effect1_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 1.. name it e_con1 please :v
	local e_con1 = Duel.IsExistingMatchingCard(s.revealfilter, tp, LOCATION_HAND, 0, 1, nil) 

    -- Restriction
    -- For once per Duel
    local restrict_1 = Duel.HasFlagEffect(tp, id) 

    -- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
    -- local restrict_1 = Duel.GetFlagEffect(tp, id) < x.
	
	return aux.CanActivateSkill(tp) and e_con1 and not restrict_1
end

function s.effect1_op(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local g1 = Duel.SelectMatchingCard(tp, s.revealfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
	Duel.ConfirmCards(1 - tp, g1)
	Duel.ShuffleHand(tp)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.effect2_con(e, tp, eg, ep, ev, re, r, rp)
	-- Condition for Effect 2.. name it e_con2 please :v
	local e_con2 = Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 
        or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15982593),tp,LOCATION_MZONE,0,1,nil)
	-- Restriction
    -- For once per Duel
    local restrict_2 = Duel.HasFlagEffect(tp, id+1) 

    -- For once per turn, x per duel, etc. Once Per Turn, Twice per Duel then, change the x with 2.
    -- local restrict_2 = Duel.GetFlagEffect(tp, id+1) < x.

	return aux.CanActivateSkill(tp) and e_con2 and not restrict_2
end

-- Effect 2 Filters
function s.thfilter2(c)
    return c:IsSetCard(0x1ad) and c:IsAbleToHand()
end
function s.placementfilter(c,tp)
    return c:IsSetCard(0x19b) and c:IsType(TYPE_MONSTER) 
        and (c:IsAbleToGrave() or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden()))
end

-- Effect 2 Logic
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.effect2_op(e, tp, eg, ep, ev, re, r, rp)
	-- Effect 2 Operation here.. do whatever the effect do :v
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
    Duel.ConfirmCards(1-tp,g)
    
    -- Optional Branch: Place or Send 1 Centur-Ion Monster from Deck
    if Duel.IsExistingMatchingCard(s.placementfilter,tp,LOCATION_DECK,0,1,nil,tp)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
        local tc=Duel.SelectMatchingCard(tp,s.placementfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
        if not tc then return end
        
        -- Determine legal options based on current backrow space
        local can_place = Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not tc:IsForbidden()
        local can_grave = tc:IsAbleToGrave()
        
        local op=0
        if can_place and can_grave then
            op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
        elseif can_place then
            op=Duel.SelectOption(tp,aux.Stringid(id,3))
        else
            op=Duel.SelectOption(tp,aux.Stringid(id,4))+1
        end
        
        if op==0 then
            -- Place face-up on the field as a Continuous Trap
            if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetCode(EFFECT_CHANGE_TYPE)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
                e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
                tc:RegisterEffect(e1)
            end
        else
            -- Send to Graveyard
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    end
end
