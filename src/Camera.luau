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
	return setmetatable(props :: { any }, Camera) :: Camera
end

return table.freeze(Camera)
