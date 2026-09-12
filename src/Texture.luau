const AssetService = game:GetService("AssetService")

const Texture = {}
Texture.__index = Texture

export type Texture = setmetatable<{
	read _size: Vector2,
	read _buffer: buffer,
	read _view: EditableImage,
}, typeof(Texture)>

function Texture.new(size: Vector2): Texture
	const view = AssetService:CreateEditableImage({ Size = size })
	assert(view, "Failed to create EditableImage")

	return setmetatable({
		_size = size,
		_buffer = buffer.create(size.X * size.Y * 4),
		_view = view,
	}, Texture)
end

function Texture.loadAsync(content: Content): Texture
	const view = AssetService:CreateEditableImageAsync(content)
	assert(view, "Failed to create EditableImage")

	return setmetatable({
		_size = view.Size,
		_buffer = view:ReadPixelsBuffer(Vector2.zero, view.Size),
		_view = view,
	}, Texture)
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

function Texture.present(self: Texture)
	self._view:WritePixelsBuffer(Vector2.zero, self._size, self._buffer)
end

function Texture.getSize(self: Texture): Vector2
	return self._size
end

function Texture.getBuffer(self: Texture): buffer
	return self._buffer
end

return table.freeze(Texture)
