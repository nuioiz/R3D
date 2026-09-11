const Texture = require("@self/Texture")

export type Texture = Texture.Texture

const R3D = {
	Texture = Texture,
}

return table.freeze(R3D)
