DL = DL or {}

function DL.AddSkill(c, tp)
	Duel.SetLP(tp, 4000)
	-- Lock Most Left and Right monster Zones and 2nd and 4th Spell/Trap Zones.
	local e_lock = Effect.CreateEffect(c)
	e_lock:SetType(EFFECT_TYPE_FIELD)
	e_lock:SetCode(EFFECT_DISABLE_FIELD)
	e_lock:SetOperation(DL.zone_lock_val)
	Duel.RegisterEffect(e_lock, tp)
end

function DL.zone_lock_val()
	return 0x0A11
end

function DL.AddSkillPendulum(c, tp)
	Duel.SetLP(tp, 4000)
	-- Lock only most left and right monster zones.
	local e_lock = Effect.CreateEffect(c)
	e_lock:SetType(EFFECT_TYPE_FIELD)
	e_lock:SetCode(EFFECT_DISABLE_FIELD)
	e_lock:SetOperation(DL.zone_lock_val_pend)
	Duel.RegisterEffect(e_lock, tp)
end

function DL.zone_lock_val_pend()
	return 0x11
end