const Mesh = require("./Mesh")
const Texture = require("./Texture")

type Mesh = Mesh.Mesh
type Texture = Texture.Texture

type Matrix4 = { { number } }
type Vector4 = { number }

const FOV = 70
const NEAR = 0.1
const FAR = 1000
const ANIM_SPEED = 1

const cube = Mesh.new({
	vertices = {
		Vector3.new(0, 0, 0),
		Vector3.new(1, 0, 0),
		Vector3.new(0, 1, 0),
		Vector3.new(1, 1, 0),
		Vector3.new(0, 0, 1),
		Vector3.new(1, 0, 1),
		Vector3.new(0, 1, 1),
		Vector3.new(1, 1, 1),
	},
	indices = {
		{ 4, 8, 2 },
		{ 2, 8, 6 },
		{ 7, 8, 3 },
		{ 3, 8, 4 },
		{ 8, 7, 6 },
		{ 6, 7, 5 },
		{ 7, 3, 5 },
		{ 5, 3, 1 },
		{ 1, 2, 5 },
		{ 5, 2, 6 },
		{ 3, 4, 1 },
		{ 1, 4, 2 },
	},
})

const cameraCFrame = CFrame.new(0, 0, -1)
local cubeCFrame = CFrame.identity

const Renderer = {}
Renderer.__index = Renderer

export type Renderer = setmetatable<{
	target: Texture,
}, typeof(Renderer)>

const function makeProjectionMatrix(aspect: number): Matrix4
	const fovRad = 1 / math.tan(math.rad(FOV) / 2)
	const rangeInv = 1 / (NEAR - FAR)
	return {
		{ fovRad / aspect, 0, 0, 0 },
		{ 0, fovRad, 0, 0 },
		{ 0, 0, (NEAR + FAR) * rangeInv, 2 * NEAR * FAR * rangeInv },
		{ 0, 0, -1, 0 },
	}
end

const function mulMatVec(m: Matrix4, v: Vector4): Vector4
	const out = { 0, 0, 0, 0 }
	for row = 1, 4 do
		local sum = 0
		for col = 1, 4 do
			sum += m[row][col] * v[col]
		end
		out[row] = sum
	end
	return out
end

const function worldToCamera(pos: Vector3): Vector3
	return cameraCFrame:PointToObjectSpace(pos) :: Vector3
end

function Renderer.new(target: Texture): Renderer
	return setmetatable({
		target = target,
	}, Renderer)
end

function Renderer.drawWireframe(self: Renderer, p0: Vector2, p1: Vector2, p2: Vector2, color: Color3)
	const view = self.target._view
	view:DrawLine(p0, p1, color, 0, Enum.ImageCombineType.Overwrite)
	view:DrawLine(p1, p2, color, 0, Enum.ImageCombineType.Overwrite)
	view:DrawLine(p2, p0, color, 0, Enum.ImageCombineType.Overwrite)
end

function Renderer.render(self: Renderer, dt: number)
	const target = self.target
	const size = target:getSize()
	const aspect = size.X / size.Y
	const projMatrix = makeProjectionMatrix(aspect)

	target:clear(0xFF000000)

	target:present()

	cubeCFrame *= CFrame.Angles(dt * 0.7 * ANIM_SPEED, dt * ANIM_SPEED, 0)

	const projected = {}
	for i, vert in cube.vertices do
		const worldPos = cubeCFrame:PointToWorldSpace(vert)
		const camPos = worldToCamera(worldPos)

		const v = { camPos.X, camPos.Y, -camPos.Z, 1 }
		const clip = mulMatVec(projMatrix, v)

		if clip[4] <= 0 then
			continue
		end

		const ndc = Vector3.new(clip[1] / clip[4], clip[2] / clip[4], clip[3] / clip[4])

		local screenPos = Vector3.new((ndc.X * 0.5 + 0.5) * size.X, (1 - (ndc.Y * 0.5 + 0.5)) * size.Y, ndc.Z)

		screenPos = screenPos:Min(Vector3.new(size.X - 1, size.Y - 1, 0)):Max(Vector3.zero)

		projected[i] = screenPos
	end

	for _, tri in cube.indices do
		const p0 = projected[tri[1]]
		const p1 = projected[tri[2]]
		const p2 = projected[tri[3]]

		if p0 and p1 and p2 then
			self:drawWireframe(
				Vector2.new(p0.X, p0.Y),
				Vector2.new(p1.X, p1.Y),
				Vector2.new(p2.X, p2.Y),
				Color3.new(1, 1, 1)
			)
		end
	end
end

return table.freeze(Renderer)
