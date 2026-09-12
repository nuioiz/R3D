const Camera = require("./Camera")
type Camera = Camera.Camera

const Mesh = require("./Mesh")
type Mesh = Mesh.Mesh

const Texture = require("./Texture")
type Texture = Texture.Texture

type Matrix4 = { { number } }
type Vector4 = { number }

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

local cubeCFrame = CFrame.new(0, 0, -5)

const Renderer = {}
Renderer.__index = Renderer

export type Renderer = setmetatable<{
	target: Texture,
}, typeof(Renderer)>

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

function Renderer.render(self: Renderer, camera: Camera, dt: number)
	const target = self.target
	const size = target:getSize()
	const aspect = size.X / size.Y

	target:clear(0xFF000000)

	target:present()

	cubeCFrame *= CFrame.Angles(dt * 0.7 * ANIM_SPEED, dt * ANIM_SPEED, 0)

	const projected = {}
	for i, vert in cube.vertices do
		const worldPos = cubeCFrame:PointToWorldSpace(vert)
		const viewPos = camera:worldToView(worldPos)
		const clipPos = camera:viewToClip(aspect, viewPos)
		if clipPos.w <= 0 then
			continue
		end

		const ndcPos = clipPos:perspectiveDivide()

		local screenPos = Vector3.new((ndcPos.X / 2 + 0.5) * size.X, (1 - (ndcPos.Y / 2 + 0.5)) * size.Y, ndcPos.Z)

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
