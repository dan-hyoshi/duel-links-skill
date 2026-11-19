

local s, id = GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c, 2, false, nil, nil)
	local e1 = Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SKILL_FLIP, tp, id | (1 << 32))
	Duel.Hint(HINT_CARD, tp, id)
	local c = e:GetHandler()

	local egr = Effect.CreateEffect(c)
	egr:SetType(EFFECT_TYPE_FIELD)
	egr:SetCode(EFFECT_REVERSE_DAMAGE)
	egr:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE)
	egr:SetTargetRange(1, 0)
	egr:SetValue(s.rev)
	Duel.RegisterEffect(egr, tp)
end

function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end