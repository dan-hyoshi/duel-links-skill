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

function s.startop(e, tp, eg, ep, ev, re, r, rp)
	-- Change ATTRIBUTE_FIRE to whatever attribute you want to check for
	local ct = Duel.GetMatchingGroupCount(Card.IsAttribute, tp, LOCATION_DECK | LOCATION_EXTRA, 0, nil, ATTRIBUTE_DARK)

	-- If you don't have 6 or more monsters matching that attribute, the skill stays face-down
	if ct < 6 then
		return
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
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(0x5f)
	-- e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
	e2:SetCountLimit(1, id)
	e2:SetCondition(s.thcon)
	e2:SetOperation(s.thop)
	Duel.RegisterEffect(e2, tp)
end

function s.thfilter(c)
	return c:ListsCode(CARD_RED_DRAGON_ARCHFIEND) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
	-- Must be the owner's Main Phase, can activate skill rules, valid target exists, and once-per-turn limit checked
	-- return aux.CanActivateSkill(tp)
	-- 	and Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK | LOCATION_GRAVE, 0, 1, nil)
	-- 	and Duel.GetFlagEffect(tp,id)<2

	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp, id) < 2
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
	local b1 = Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, nil)
	local b2 = Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_HAND, 0, 1, nil)

	if not (b1 or b2) then
		return
	end

	local op = 0
	if b1 and b2 then
		op = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
	elseif b1 then
		op = Duel.SelectOption(tp, aux.Stringid(id, 1))
	else
		op = Duel.SelectOption(tp, aux.Stringid(id, 2)) + 1
	end

	if op == 0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
		local g = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, 1, nil)
		-- SEQ_DECKSHUFFLE puts it back, but we still need the physical Shuffle command
		if #g == 0 or Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then
			return
		end
		-- THIS LINE FIXES IT: Forces the system to mix up your deck array
		Duel.ShuffleDeck(tp)
	else
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
		local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_HAND, 0, 1, 1, nil)
		if #g == 0 or Duel.SendtoGrave(g, REASON_EFFECT) == 0 then
			return
		end
	end

	local draw_count = 2
	if Duel.GetTurnCount() == 2 and Duel.GetTurnPlayer() == tp then
		draw_count = 3
	end

	if Duel.Draw(tp, draw_count, REASON_EFFECT) > 0 then
		Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	end
end
