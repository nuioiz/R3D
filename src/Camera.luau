const Vector4 = require("./Math/Vector4")
type Vector4 = Vector4.Vector4

const Camera = {}
Camera.__index = Camera

export type CameraProps = {
	cframe: CFrame?,
	fov: number?,
	near: number?,
	far: number?,
}

export type Camera = setmetatable<{
	cframe: CFrame,
	fov: number,
	near: number,
	far: number,
}, typeof(Camera)>

function Camera.new(props: CameraProps?): Camera
	props = props or {} :: CameraProps
	props.cframe = props.cframe or CFrame.identity
	props.fov = props.fov or 70
	props.near = props.near or 0.1
	props.far = props.far or 1000
	return setmetatable(props :: CameraProps, Camera) :: Camera
end

function Camera.worldToView(self: Camera, ...: Vector3): ...Vector3
	return self.cframe:PointToObjectSpace(...)
end

function Camera.viewToClip(self: Camera, aspect: number, ...: Vector3): ...Vector4
	const count = select("#", ...)
	const results = table.create<<Vector4>>(count)
	const tanHalfFov = math.tan(math.rad(self.fov) / 2)

	for i = 1, count do
		const v: Vector3 = select(i, ...)
		const z = -v.Z
		local a = (self.far + self.near) / (self.far - self.near)
		local b = (2 * self.far * self.near) / (self.far - self.near)

		results[i] = Vector4.new(v.X / (tanHalfFov * aspect), v.Y / tanHalfFov, a * z + b, z)
	end

	return table.unpack(results)
end

return table.freeze(Camera)
