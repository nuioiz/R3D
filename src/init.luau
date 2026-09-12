const Renderer = require("@self/Renderer")
export type Renderer = Renderer.Renderer

const Camera = require("@self/Camera")
export type Camera = Camera.Camera

const Mesh = require("@self/Mesh")
export type Mesh = Mesh.Mesh
export type Vertex = Mesh.Vertex

const Texture = require("@self/Texture")
export type Texture = Texture.Texture

const R3D = {
	Renderer = Renderer,
	Camera = Camera,
	Mesh = Mesh,
	Texture = Texture,
}

return table.freeze(R3D)
