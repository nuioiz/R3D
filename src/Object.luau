const Mesh = require("./Mesh")
type Mesh = Mesh.Mesh

const Object = {}
Object.__index = Object

export type Object = setmetatable<{
	cframe: CFrame,
	mesh: Mesh,
}, typeof(Object)>

function Object.new(cframe: CFrame, mesh: Mesh): Object
	return setmetatable({
		cframe = cframe,
		mesh = mesh,
	}, Object)
end

function Object.localToWorld(self: Object, ...: Vector3): ...Vector3
	return self.cframe:PointToWorldSpace(...)
end

return table.freeze(Object)
