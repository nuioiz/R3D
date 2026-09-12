const Camera = require("./Camera")
type Camera = Camera.Camera

const Texture = require("./Texture")
type Texture = Texture.Texture

const Object = require("./Object")
type Object = Object.Object

const Vector4 = require("./Math/Vector4")

const LIGHT_DIRECTION = Vector3.new(0, 0, -1).Unit

const Renderer = {}
Renderer.__index = Renderer

export type Renderer = setmetatable<{
	canvas: Texture,
}, typeof(Renderer)>

function Renderer.new(canvas: Texture): Renderer
	return setmetatable({
		canvas = canvas,
	}, Renderer)
end

const function edge(a: Vector2, b: Vector2, p: Vector2): number
	return (b.X - a.X) * (p.Y - a.Y) - (b.Y - a.Y) * (p.X - a.X)
end

function Renderer.drawTriangle(self: Renderer, p0: Vector2, p1: Vector2, p2: Vector2, color: number)
	const resolution, framebuffer = self.canvas:getSize(), self.canvas:getBuffer()

	const min = p0:Min(p1, p2)
	const max = p0:Max(p1, p2)

	const area = edge(p0, p1, p2)
	if area == 0 then
		return
	end

	const w0ColDelta, w0RowDelta = p1.Y - p2.Y, p2.X - p1.X
	const w1ColDelta, w1RowDelta = p2.Y - p0.Y, p0.X - p2.X
	const w2ColDelta, w2RowDelta = p0.Y - p1.Y, p1.X - p0.X

	local w0Row = edge(p1, p2, min)
	local w1Row = edge(p2, p0, min)
	local w2Row = edge(p0, p1, min)

	for y = min.Y, max.Y do
		local w0, w1, w2 = w0Row, w1Row, w2Row

		for x = min.X, max.X do
			if w0 <= 0 and w1 <= 0 and w2 <= 0 then
				const offset = (y * resolution.X + x) * 4
				buffer.writeu32(framebuffer, offset, color)
			end

			w0 += w0ColDelta
			w1 += w1ColDelta
			w2 += w2ColDelta
		end

		w0Row += w0RowDelta
		w1Row += w1RowDelta
		w2Row += w2RowDelta
	end
end

function Renderer.render(self: Renderer, object: Object, camera: Camera)
	const canvas = self.canvas
	const resolution = canvas:getSize()
	const aspect = resolution.X / resolution.Y

	const viewCFrame = camera.cframe:Inverse()
	const tanHalfFov = math.tan(math.rad(camera.fov) / 2)
	const zScale = (camera.far + camera.near) / (camera.far - camera.near)
	const zTranslation = (2 * camera.far * camera.near) / (camera.far - camera.near)

	canvas:clear(0xFF000000)

	const modelView = viewCFrame * object.cframe
	const mesh = object.mesh

	const projected = {}
	for i, vertex in mesh.vertices do
		const view = modelView:PointToWorldSpace(vertex)
		const viewDepth = -view.Z

		const clip = Vector4.new(
			view.X / (tanHalfFov * aspect),
			view.Y / tanHalfFov,
			viewDepth * zScale + zTranslation,
			viewDepth
		)

		if clip.w <= 0 then
			continue
		end

		const ndc = clip.xyz / clip.w

		const screen = Vector3.new(ndc.X / 2 + 0.5, 1 - (ndc.Y / 2 + 0.5), ndc.Z)
			* Vector3.new(resolution.X, resolution.Y, 1)

		projected[i] = Vector2.new(screen.X, screen.Y):Min(resolution - Vector2.one):Max(Vector2.zero):Floor()
	end

	for _, tri in mesh.indices do
		const p0 = projected[tri[1]]
		const p1 = projected[tri[2]]
		const p2 = projected[tri[3]]

		if p0 and p1 and p2 then
			const wp0 = object.cframe:PointToWorldSpace(mesh.vertices[tri[1]])
			const wp1 = object.cframe:PointToWorldSpace(mesh.vertices[tri[2]])
			const wp2 = object.cframe:PointToWorldSpace(mesh.vertices[tri[3]])

			const normal = (wp1 - wp0):Cross(wp2 - wp0).Unit

			const brightness = math.max(normal:Dot(-LIGHT_DIRECTION), 0)
			const intensity = math.floor(brightness * 255)

			const color = bit32.bor(0xFF000000, bit32.lshift(intensity, 16), bit32.lshift(intensity, 8), intensity)

			self:drawTriangle(p0, p1, p2, color)
		end
	end

	canvas:present()
end

return table.freeze(Renderer)
