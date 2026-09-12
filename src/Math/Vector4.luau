const Vector4 = {}
Vector4.__index = Vector4

export type Vector4 = setmetatable<{
	x: number,
	y: number,
	z: number,
	w: number,
}, typeof(Vector4)>

function Vector4.new(x: number?, y: number?, z: number?, w: number?)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		z = z or 0,
		w = w or 0,
	}, Vector4)
end

function Vector4.perspectiveDivide(v: Vector4): Vector3
	return Vector3.new(v.x, v.y, v.z) / v.w
end

return table.freeze(Vector4)
