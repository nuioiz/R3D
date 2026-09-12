const AssetService = game:GetService("AssetService")

const VERTEX_ID_OFFSET = 0x100000000

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

function Mesh.loadAsync(content: Content): Mesh
	const temp = AssetService:CreateEditableMeshAsync(content)
	assert(temp, "Failed to create EditableMesh")

	const vertexIds = temp:GetVertices()
	const vertices = table.create<<Vertex>>(#vertexIds)
	for i, vertexId in vertexIds do
		vertices[i] = temp:GetPosition(vertexId)
	end

	const faceIds = temp:GetFaces()
	const indices = table.create<<{ number }>>(#faceIds)
	for i, faceId in faceIds do
		const v0, v1, v2 = table.unpack(temp:GetFaceVertices(faceId))
		indices[i] = {
			v0 - VERTEX_ID_OFFSET,
			v1 - VERTEX_ID_OFFSET,
			v2 - VERTEX_ID_OFFSET,
		}
	end

	temp:Destroy()

	return Mesh.new({ vertices = vertices, indices = indices })
end

return table.freeze(Mesh)
