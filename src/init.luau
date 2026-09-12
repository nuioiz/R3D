const Mesh = require("@self/Mesh")
const Renderer = require("@self/Renderer")
const Texture = require("@self/Texture")

export type Renderer = Renderer.Renderer
export type Texture = Texture.Texture

export type Mesh = Mesh.Mesh
export type Vertex = Mesh.Vertex

const R3D = {
	Renderer = Renderer,
	Texture = Texture,
	Mesh = Mesh,
}

return table.freeze(R3D)
