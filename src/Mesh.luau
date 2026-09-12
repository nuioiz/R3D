const Mesh = {}
Mesh.__index = Mesh

export type Vertex = Vector3

export type Mesh = setmetatable<{
	vertices: { Vertex },
	indices: { { number } },
}, typeof(Mesh)>

function Mesh.new(data: { vertices: { Vertex }, indices: { { number } } }): Mesh
	return setmetatable(data, Mesh)
end

return table.freeze(Mesh)
