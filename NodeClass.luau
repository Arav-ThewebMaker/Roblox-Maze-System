local nodeClass = {};
nodeClass.__index = nodeClass;

function nodeClass.new(i, j, w, h, boardW)
	local self = setmetatable({}, nodeClass);
	self.i = i;
	self.j = j;
	
	self.x = j * w;
	self.y = i * w;
	
	self.g = 0   -- distance from start
	self.h = 0   -- heuristic to end
	self.f = 0   -- total cost
	self.parent = nil

	
	self.wallColour = Color3.new(0.207843, 0.207843, 0.207843);
	
	if self.x == w and self.y == w then
		self.wallColour = Color3.new(0, 0, 0);
	end
	
	self.w = w;
	self.boardW = boardW;
	
	self.h = h;
	self.stroke = 3;
	
	self.visited = false;
	self.parent = nil;
	
	self.walls = {};
	return self;
end

function nodeClass:changeWallColours()
	for i, v in pairs(self.walls) do
		v.Color = Color3.new(0.207843, 0.207843, 0.207843);
	end
end

function nodeClass:spawnWalls()
	--TOP WALL
	self:createWall(Vector3.new(self.w,self.h, self.stroke), Vector3.new(self.x, 24, self.y - self.w/2), "TOP");
	--LEFT WALL
	self:createWall(Vector3.new(self.stroke,self.h, self.w), Vector3.new(self.x - self.w/2, 24, self.y), "LEFT");
	--BOTTOM WALL
	self:createWall(Vector3.new(self.w,self.h, self.stroke), Vector3.new(self.x, 24, self.y + self.w/2), "BOTTOM");
	--RIGHT WALL
	self:createWall(Vector3.new(self.stroke,self.h, self.w), Vector3.new(self.x + self.w/2, 24, self.y), "RIGHT");
end

function nodeClass:createWall(size, position, name)
	local wall = Instance.new("Part");
	wall.CanCollide = false
	wall.Anchored = true;
	wall.Name = name;
	wall.Size = size;
	wall.Position = position;
	wall.CanCollide = true
	wall.Parent = game.Workspace.Maze;
	wall.Color = self.wallColour;
	wall.Material = Enum.Material.SmoothPlastic;
	table.insert(self.walls, wall);
end

function nodeClass:calculateStackNodeIndex(i, j)
	if i < 1 or j < 1 or i > self.boardW or j > self.boardW then
		return nil
	end
	return (i - 1) * self.boardW + j
end

function nodeClass:checkNeighbours(nodes)
	local neighbours = {}

	-- neighbor coordinates
	local top    = nodes[self:calculateStackNodeIndex(self.i - 1, self.j)]
	local bottom = nodes[self:calculateStackNodeIndex(self.i + 1, self.j)]
	local left   = nodes[self:calculateStackNodeIndex(self.i, self.j - 1)]
	local right  = nodes[self:calculateStackNodeIndex(self.i, self.j + 1)]

	-- Only add unvisited
	if top and not top.visited then table.insert(neighbours, top) end
	if right and not right.visited then table.insert(neighbours, right) end
	if bottom and not bottom.visited then table.insert(neighbours, bottom) end
	if left and not left.visited then table.insert(neighbours, left) end

	if #neighbours > 0 then
		-- pick a single random neighbor
		local randomIndex = math.random(1, #neighbours)
		return neighbours[randomIndex]
	else
		return nil
	end
end


return nodeClass;
