const AssetService = game:GetService("AssetService")

const Texture = {}
Texture.__index = Texture

export type Texture = setmetatable<{
	_size: Vector2,
	_buffer: buffer,
	_view: EditableImage?,
}, typeof(Texture)>

function Texture.new(size: Vector2): Texture
	return setmetatable({
		_size = size,
		_buffer = buffer.create(size.X * size.Y * 4),
	}, Texture) :: Texture
end

function Texture.loadAsync(content: Content): Texture
	const temp = AssetService:CreateEditableImageAsync(content)
	assert(temp)

	const self = setmetatable({
		_size = temp.Size,
		_buffer = temp:ReadPixelsBuffer(Vector2.zero, temp.Size),
	}, Texture) :: Texture

	temp:Destroy()

	return self
end

function Texture.clear(self: Texture, color: number?)
	const buf = self._buffer
	const len = buffer.len(buf)

	buffer.writeu32(buf, 0, color or 0)

	local filled = 4
	while filled < len do
		const count = math.min(filled, len - filled)
		buffer.copy(buf, filled, buf, 0, count)
		filled += count
	end
end

function Texture.resize(self: Texture, size: Vector2)
	self._size = size
	self._buffer = buffer.create(size.X * size.Y * 4)
end

function Texture.present(self: Texture)
	if self._view then
		self._view:WritePixelsBuffer(Vector2.zero, self._size, self._buffer)
	end
end

function Texture.getSize(self: Texture): Vector2
	return self._size
end

function Texture.getBuffer(self: Texture): buffer
	return self._buffer
end

return table.freeze(Texture)
