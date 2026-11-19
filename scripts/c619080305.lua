-- The Eye of The United Dragon
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

function s.darkmagicianfilter(c)
	return (c:IsCode(CARD_DARK_MAGICIAN) or c:ListsCode(CARD_DARK_MAGICIAN))
end

function s.startop(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetFieldGroup(tp, LOCATION_DECK, 0)
	-- Check for Dark Magician or Card that mention it in the Deck.
	local ct = Group.FilterCount(g, s.darkmagicianfilter, nil)

	-- If you don't have 15 or more Dark Magician or Card that mention it in the Deck, the skill stays face-down
	if ct < 15 then
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

function s.timaeus_filter(c, e, tp)
	return c:IsCode(3078380) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.dm_dragon_filter(c)
	return c:IsFaceup() and c:IsCode(CARD_DARK_MAGICIAN)
end

function s.sp_dm_filter(c, e, tp)
	--Summon DM or DMG with different name from field
	return (c:IsCode(CARD_DARK_MAGICIAN)
		or c:IsCode(CARD_DARK_MAGICIAN_GIRL))
			and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
			and not Duel.IsExistingMatchingCard(
				aux.FaceupFilter(Card.IsCode, c:GetCode()),
				tp,
				LOCATION_MZONE,
				0,
				1,
				nil
			)
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
	e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
	-- e2:SetCountLimit(1, id)
	e2:SetCondition(s.timaeus_con)
	e2:SetOperation(s.timaeus_op)
	Duel.RegisterEffect(e2, tp)

	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(0x5f)
	e3:SetCountLimit(1, id + 1, EFFECT_COUNT_CODE_DUEL)
	-- e2:SetCountLimit(1, id)
	e3:SetCondition(s.darkmagi_con)
	e3:SetOperation(s.darkmagi_op)
	Duel.RegisterEffect(e3, tp)
end

function s.timaeus_con(e, tp, eg, ep, ev, re, r, rp)
	local hand_count = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
	local has_timaeus = Duel.IsExistingMatchingCard(s.timaeus_filter, tp, LOCATION_HAND, 0, 1, nil, e, tp)
	local b1 = has_timaeus
		and hand_count >= 2
		and Duel.IsExistingMatchingCard(s.darkmagicianfilter, tp, LOCATION_DECK, 0, 2, nil)
		and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0

	return aux.CanActivateSkill(tp) and b1 and not Duel.HasFlagEffect(tp, id)
end

function s.timaeus_op(e, tp, eg, ep, ev, re, r, rp)
	--Step 1: Shuffle 1 from Hand (except the Timaeus we want to summon, ideally)
	--Logic: We need to keep Timaeus.
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_HAND, 0, 1, 1, nil)
	if #g == 0 then
		return
	end

	--Check if we shuffled the only Timaeus. If so, effect fails.
	local card_shuffled = g:GetFirst()
	Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)

	--Step 2: Summon Timaeus
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tc = Duel.SelectMatchingCard(tp, s.timaeus_filter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp):GetFirst()

	if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
		--Step 3: Add 2 DM/Mentioners
		local sg = Duel.GetMatchingGroup(s.darkmagicianfilter, tp, LOCATION_DECK, 0, nil)
		if #sg >= 2 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
			local thg = sg:Select(tp, 2, 2, nil)
			Duel.SendtoHand(thg, nil, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, thg)
		end
	end
end

function s.darkmagi_con(e, tp, eg, ep, ev, re, r, rp)
	local cond2 = Duel.IsExistingMatchingCard(s.dm_dragon_filter, tp, LOCATION_MZONE, 0, 1, nil)
		or (Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0)
	local b2 = cond2
		and Duel.IsExistingMatchingCard(s.sp_dm_filter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
		and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0

	return aux.CanActivateSkill(tp) and b2 and not Duel.HasFlagEffect(tp, id + 1)
end

function s.darkmagi_op(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local sc = Duel.SelectMatchingCard(tp, s.sp_dm_filter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp):GetFirst()
	if sc and Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 then
		Duel.ConfirmCards(1 - tp, sc)

		--Add "The Eye of Timaeus" from outside Deck
		Duel.BreakEffect()
		local token = Duel.CreateToken(tp, 1784686) -- The Eye of Timaeus
		Duel.SendtoHand(token, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, token)
	end
end
