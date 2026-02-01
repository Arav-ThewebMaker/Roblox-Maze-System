local boardW = 20;
local cellW = 7.5;
local h = 13;

local nodeClass = require(script.NodeClass);
local stackModule = require(script.Stack);

local nodes = {};

function createNewMaze()
	local index = 1;
	for i = 1, boardW do
		for j = 1, boardW do
			local currentNode = nodeClass.new(i, j, cellW, h, boardW);
			currentNode:spawnWalls();
			nodes[index] = currentNode;
			index += 1;
		end
	end
end

function createMarker(position, color, name)
	local marker = Instance.new("Part")
	marker.Size = Vector3.new(cellW - 3, 9, cellW - 3)
	marker.Position = position
	marker.Anchored = true
	marker.CanCollide = false
	marker.Material = Enum.Material.Neon
	marker.Color = color
	marker.Name = name
	marker.Parent = workspace
end

function createEntranceAndExit()
	-- START (top-left)
	local startNode = nodes[1]
	startNode.walls[1]:Destroy() -- TOP wall

	createMarker(
		Vector3.new(startNode.x, 24, startNode.y),
		Color3.fromRGB(0, 255, 100),
		"START"
	)

	-- END (bottom-right)
	local endIndex = boardW * boardW
	local endNode = nodes[endIndex]
	endNode.walls[3]:Destroy() -- BOTTOM wall

	createMarker(
		Vector3.new(endNode.x, 24, endNode.y),
		Color3.fromRGB(255, 60, 60),
		"END"
	)
end


function removeWalls(currentNode, nextNode)
	local y = (currentNode.i - nextNode.i);
	local x = (currentNode.j - nextNode.j);
	
	if x == 1  then
		currentNode.walls[2]:Destroy();
		nextNode.walls[4]:Destroy();
	elseif x == -1 then
		currentNode.walls[4]:Destroy();
		nextNode.walls[2]:Destroy();
	end
	
	if y == 1  then
		currentNode.walls[1]:Destroy();
		nextNode.walls[3]:Destroy();
	elseif y == -1 then
		currentNode.walls[3]:Destroy();
		nextNode.walls[1]:Destroy();
	end
end

function calculateMaze()
	local nodeStack = stackModule.new(cellW * cellW);
	local current = nodes[1];
	
	--Mark first one as visited and push onto stack
	current.visited = true;
	nodeStack:push(current);
	
	--Create the currentNodePointerMesh
	local pointer = Instance.new("Part")
	pointer.Size = Vector3.new(cellW, h, cellW);
	pointer.Name = "Pointer"
	pointer.Position = Vector3.new(current.x, 22,current.y)
	pointer.Parent = workspace;
	pointer.Anchored = true;
	pointer.CanCollide = false;
	pointer.Material = Enum.Material.Neon;
	pointer.Color = Color3.new(0.309804, 1, 0.470588);
	
	while not nodeStack:isEmpty() do
		current = nodeStack:pop()
		current:changeWallColours()
		pointer.Position = Vector3.new(current.x, 22, current.y)

		local neighbour = current:checkNeighbours(nodes)

		if neighbour then
			nodeStack:push(current)
			removeWalls(current, neighbour)
			neighbour.visited = true
			neighbour.parent = current
			nodeStack:push(neighbour)
			
		end
		task.wait(0.0005)
	end
	pointer:Destroy()
end

function calculateAStarSolution(startNode, endNode)
	local openSet = {startNode}
	local closedSet = {}

	startNode.g = 0
	startNode.h = math.abs(startNode.i - endNode.i) + math.abs(startNode.j - endNode.j)
	startNode.f = startNode.g + startNode.h

	while #openSet > 0 do
		-- Find node with lowest f
		table.sort(openSet, function(a,b) return a.f < b.f end)
		local current = table.remove(openSet, 1)
		table.insert(closedSet, current)

		-- If reached end, stop
		if current == endNode then break end

		-- Check neighbors
		local neighbors = {}
		local top    = nodes[current:calculateStackNodeIndex(current.i - 1, current.j)]
		local bottom = nodes[current:calculateStackNodeIndex(current.i + 1, current.j)]
		local left   = nodes[current:calculateStackNodeIndex(current.i, current.j - 1)]
		local right  = nodes[current:calculateStackNodeIndex(current.i, current.j + 1)]

		if top    and not table.find(closedSet, top) and not top.walls[1] then table.insert(neighbors, top) end
		if bottom and not table.find(closedSet, bottom) and not bottom.walls[3] then table.insert(neighbors, bottom) end
		if left   and not table.find(closedSet, left) and not left.walls[2] then table.insert(neighbors, left) end
		if right  and not table.find(closedSet, right) and not right.walls[4] then table.insert(neighbors, right) end

		for _, neighbor in ipairs(neighbors) do
			local tentative_g = current.g + 1
			if not table.find(openSet, neighbor) or tentative_g < neighbor.g then
				neighbor.g = tentative_g
				neighbor.h = math.abs(neighbor.i - endNode.i) + math.abs(neighbor.j - endNode.j)
				neighbor.f = neighbor.g + neighbor.h
				neighbor.parent = current
				if not table.find(openSet, neighbor) then
					table.insert(openSet, neighbor)
				end
			end
		end
	end

	-- Reconstruct solution path
	local solutionPath = {}
	local temp = endNode
	while temp do
		table.insert(solutionPath, temp)
		temp = temp.parent
	end

	-- Visualize solution
	for _, node in ipairs(solutionPath) do
		local marker = Instance.new("Part")
		marker.Size = Vector3.new(cellW - 1, 0.2, cellW - 1)
		marker.Position = Vector3.new(node.x, 17.1, node.y)
		marker.Anchored = true
		marker.Material = Enum.Material.Neon
		marker.Color = Color3.fromRGB(0, 255, 0)
		marker.CanCollide = false
		marker.Parent = workspace
		task.wait(0.05) -- For Path visualization
	end
end

wait(1)
createNewMaze()
calculateMaze()
createEntranceAndExit()
local startNode = nodes[1]
local endNode = nodes[boardW * boardW]
calculateAStarSolution(startNode, endNode)
