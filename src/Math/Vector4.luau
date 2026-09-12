const Vector4 = {}
Vector4.__index = Vector4

export type Vector4 = setmetatable<{
	read xyz: Vector3,
	read w: number,
}, typeof(Vector4)>

function Vector4.new(x: number?, y: number?, z: number?, w: number?): Vector4
	return setmetatable({
		xyz = Vector3.new(x, y, z),
		w = w or 0,
	}, Vector4)
end

function Vector4.fromVector3(xyz: Vector3, w: number?): Vector4
	return setmetatable({
		xyz = xyz,
		w = w or 0,
	}, Vector4)
end

Vector4.zero = Vector4.new()
Vector4.one = Vector4.new(1, 1, 1, 1)

function Vector4.__unm(v: Vector4): Vector4
	return Vector4.fromVector3(-v.xyz, -v.w)
end

function Vector4.__add(a: Vector4, b: Vector4): Vector4
	return Vector4.fromVector3(a.xyz + b.xyz, a.w + b.w)
end

function Vector4.__sub(a: Vector4, b: Vector4): Vector4
	return Vector4.fromVector3(a.xyz - b.xyz, a.w - b.w)
end

function Vector4.__mul(v: Vector4, s: number): Vector4
	return Vector4.fromVector3(v.xyz * s, v.w * s)
end

function Vector4.__div(v: Vector4, s: number): Vector4
	return Vector4.fromVector3(v.xyz / s, v.w / s)
end

function Vector4.__idiv(v: Vector4, s: number): Vector4
	return Vector4.fromVector3(v.xyz // s, v.w // s)
end

function Vector4.__eq(a: Vector4, b: Vector4): boolean
	return a.xyz == b.xyz and a.w == b.w
end

function Vector4.__len(v: Vector4): number
	return math.sqrt(v:dot(v))
end

function Vector4.__tostring(v: Vector4): string
	return `{v.xyz}, {v.w}`
end

function Vector4.dot(self: Vector4, other: Vector4): number
	return self.xyz:Dot(other.xyz) + self.w * other.w
end

function Vector4.unit(self: Vector4): Vector4
	return self / #self
end

function Vector4.lerp(self: Vector4, goal: Vector4, alpha: number): Vector4
	return self + (goal - self) * alpha
end

function Vector4.abs(self: Vector4): Vector4
	return Vector4.fromVector3(self.xyz:Abs(), math.abs(self.w))
end

function Vector4.min(self: Vector4, ...: Vector4): Vector4
	local xyz, w = self.xyz, self.w
	const n = select("#", ...)
	for i = 1, n do
		const v: Vector4 = select(i, ...)
		xyz = xyz:Min(v.xyz)
		w = math.min(w, v.w)
	end
	return Vector4.fromVector3(xyz, w)
end

function Vector4.max(self: Vector4, ...: Vector4): Vector4
	local xyz, w = self.xyz, self.w
	const n = select("#", ...)
	for i = 1, n do
		const v: Vector4 = select(i, ...)
		xyz = xyz:Max(v.xyz)
		w = math.max(w, v.w)
	end
	return Vector4.fromVector3(xyz, w)
end

return table.freeze(Vector4)
