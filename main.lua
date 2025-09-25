----<< Setup Global Variables >>----
if not getgenv().CioKiTTY then
	getgenv().CioKiTTY = {}
end

getgenv().CioKiTTY["highlight-pool"] = {}

----<< Pool Folder >>----
local highlightPoolFolder = Instance.new("Folder")
highlightPoolFolder.Name = "highlight-pool"
highlightPoolFolder.Parent = gethui and gethui() or game:GetService("CoreGui")

----<< Main Module >>----
local HighlightPool = {}
HighlightPool.__index = HighlightPool

function HighlightPool.new(poolSize: number?)
	local self = setmetatable({}, HighlightPool)

	self.unallocated = {}
	self.allocated = {}

    self.folder = Instance.new("Folder")
    self.folder.Parent = highlightPoolFolder

	if poolSize and poolSize > 0 then
		for i = 1, poolSize, 1 do
            local obj = Instance.new("Highlight")
            obj.Parent = self.folder

			self:Register(obj)
		end
	end

	return self
end

function HighlightPool:Register(obj: Highlight)
	table.insert(self.unallocated, obj)
end

function HighlightPool:Has(owner)
	return self.allocated[owner] ~= nil
end

function HighlightPool:Get(owner): Highlight?
	return self.allocated[owner]
end

function HighlightPool:Allocate(owner)
	if #self.unallocated == 0 then
		return nil
	end

	if self:Has(owner) then
		self:Release(owner)
	end

	local obj: Highlight = table.remove(self.unallocated, 1)
	self.allocated[owner] = obj

	return obj
end

function HighlightPool:Release(owner)
	local obj = self:Get(owner)
	if not obj then
		return false
	end

	self.allocated[owner] = nil
	table.insert(self.unallocated, obj)

	return true
end

function HighlightPool:ReleaseAll()
	local owners = {}
	for owner in pairs(self.allocated) do
		table.insert(owners, owner)
	end

    for _, owner in ipairs(owners) do
        self:Release(owner)
    end
end

function HighlightPool:Clear()
    for _, obj: Highlight in pairs(self.allocated) do
        obj:Destroy()
    end

    for _, obj: Highlight in pairs(self.unallocated) do
        obj:Destroy()
    end

    table.clear(self.allocated)
    table.clear(self.unallocated)
end

function HighlightPool:Destroy()
    if self.folder then
        self.folder:Destroy()
        self.folder = nil
    end
end

----<< Store to Global >>-----
getgenv().CioKiTTY['highlight-pool'].module = HighlightPool
getgenv().CioKiTTY['highlight-pool'].folder = highlightPoolFolder