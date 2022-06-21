---@diagnostic disable: undefined-field, lowercase-global
-- NicolaiXeno 14. January 2022

local rrt = {}
rrt.__index = rrt

local Node = {}
Node.__index = Node

local globalvariable = {0}
local oldposition = {0,0}

function lerp(a,b,t)
	return a+(b-a)*t
end

function ellipsoidHeuristic(t,p1,p2)
	if globalvariable[1] ~= 0 then
		return math.sqrt((t[1]-p1[1])^2 + (t[1]-p1[1])^2) + math.sqrt((t[2]-p2[2])^2 + (t[1]-p2[1])^2) <= globalvariable[1]
	else
		return true
	end
end

-- PARAMETERS

function rrt.new(start, goal, obstacleList, randArea, expandDis, goalSampleRate, MaxIter)
	local self = setmetatable({}, rrt)
	self.start = Node.new(start[1], start[2], start[3])
	self.endpoint = Node.new(goal[1], goal[2], goal[3])
	self.Xrand = randArea[1]
	self.Yrand = randArea[2]
	self.Zrand = randArea[3]
	self.expandDis = expandDis
	self.goalSampleRate = goalSampleRate
	self.MaxIter = MaxIter
	self.obstacleList = obstacleList
	return self
end

function rrt:_Start(info)
	local savedIteration = {}
	self.nodeList = {[1]= self.start}

	local i = 1

	for i = 1,20000 do
		local rnd
		if globalvariable[1] ~= 0 then
			rnd = self:_heuristic_random_point()
		else
			rnd = self:_get_random_point()
		end

		--if ellipsoidHeuristic(rnd,{self.start.x,self.start.y},{self.endpoint.x,self.endpoint.y}) then
		local nind = self:_GetNearestListIndex(rnd)
		local newNode = self:_steer(rnd, nind)

		if newNode ~= false then
			if self:_CollisionCheck(newNode, self.obstacleList) then

				local nearinds = self:_find_near_nodes(newNode,5) -- Identifies neighbouring node to the new Node.
				local newNode = self:_choose_parent(newNode, nearinds) -- Identifies nearest node and assigns it as a parent to the new Node.
				self.nodeList[i+99] = newNode


				--print("nearinds")
				--print(nearinds)
				self:_rewire(i+99, newNode, nearinds) -- Evaluate branches and optimise.
				table.insert(self.nodeList[newNode.parent].children,(rrt:_len(self.nodeList[newNode.parent].children))+1,i+99)


				if rrt:_len(self.nodeList) > self.MaxIter then
					local leaves = {}

					for key, node in pairs(self.nodeList) do
						if rrt:_len(node.children) == 0 and rrt:_len(self.nodeList[node.parent].children) > 1 then 
							leaves[key] = key
						end
					end

					if #leaves > 1 then
						local ind = leaves[math.random(1,(#leaves)-1)]
						table.remove(self.nodeList[self.nodeList[ind].parent].children, table.find(self.nodeList,ind))	
						self.nodeList[ind] = nil
					else
						local leaves2 = {}
						for key, node in pairs(self.nodeList) do
							if rrt:_len(node.children) == 0 then
								table.insert(leaves2,(#leaves2)+1,key)
							end
						end

						local ind = leaves2[math.random(1,(#leaves2)-1)]
						table.remove(self.nodeList[self.nodeList[ind].parent].children, table.find(self.nodeList,ind))	
						self.nodeList[ind] = nil

					end
				end
			end
			--end

		end

		--[[if i%100 == 0 then

			for _,v in pairs(workspace.Nodes:GetChildren()) do
				v:Destroy()
			end
			
			for _,node in pairs(self.nodeList) do
				local prt = Instance.new("Part")
				prt.Parent = workspace.Nodes
				prt.Size = Vector3.new(3,3,3)
				prt.Position = Vector3.new(node.x,node.y,node.z)/3
				prt.Anchored = true
				prt.Shape = Enum.PartType.Ball
				prt.Material = Enum.Material.Neon
				if node.parent ~= nil then
					local Magnitude = (Vector3.new(node.x,node.y,node.z)-Vector3.new(self.nodeList[node.parent].x,self.nodeList[node.parent].y,self.nodeList[node.parent].z)).magnitude
					local prt = Instance.new("Part")
					prt.Parent = workspace.Nodes
					prt.Size = Vector3.new(2,2,Magnitude/3)
					prt.Position = Vector3.new(lerp(node.x,self.nodeList[node.parent].x,.5),lerp(node.y,self.nodeList[node.parent].y,.5),lerp(node.z,self.nodeList[node.parent].z,.5))/3
					prt.Anchored = true
					prt.CFrame = CFrame.new(prt.Position,Vector3.new(self.nodeList[node.parent].x,self.nodeList[node.parent].y,self.nodeList[node.parent].z)/3)
					prt.Color = Color3.fromRGB(0,0,0)
					prt.Material = Enum.Material.Neon
				end
			end
			wait()

		end]]
		rrt:_DrawGraph(self.nodeList,self.expandDis,self.start,self.endpoint,false)
		
		warn("Iteration: "..i)
		i = i + 1
	end
	
	for _,node in pairs(self.nodeList) do
		local prt = Instance.new("Part")
		prt.Parent = workspace.Nodes
		prt.Size = Vector3.new(3,3,3)
		prt.Position = Vector3.new(node.x,node.y,node.z)/3
		prt.Anchored = true
		prt.Shape = Enum.PartType.Ball
		prt.Material = Enum.Material.Neon
		if node.parent ~= nil then
			local Magnitude = (Vector3.new(node.x,node.y,node.z)-Vector3.new(self.nodeList[node.parent].x,self.nodeList[node.parent].y,self.nodeList[node.parent].z)).magnitude
			local prt = Instance.new("Part")
			prt.Parent = workspace.Nodes
			prt.Size = Vector3.new(1,1,Magnitude/3)
			prt.Position = Vector3.new(lerp(node.x,self.nodeList[node.parent].x,.5),lerp(node.y,self.nodeList[node.parent].y,.5),lerp(node.z,self.nodeList[node.parent].z,.5))/3
			prt.Anchored = true
			prt.CFrame = CFrame.new(prt.Position,Vector3.new(self.nodeList[node.parent].x,self.nodeList[node.parent].y,self.nodeList[node.parent].z)/3)
			prt.Color = Color3.fromRGB(0,0,0)
			prt.Material = Enum.Material.Neon
		end
	end
	rrt:_DrawGraph(self.nodeList,self.expandDis,self.start,self.endpoint,true)

	return self.nodeList
end

-- Path Validation

function rrt:_DrawGraph(nodelist,expand,start,endpoint,debounce)
	local lastIndex = self:_get_best_last_index(nodelist,expand,endpoint)
	if lastIndex ~= nil then
		local path = self:_gen_final_course(lastIndex,start,endpoint,nodelist)

		local ind = rrt:_len(path)
		local pathlength = 0

		while ind > 1 do
			local distance = ((Vector3.new(path[ind-1][1], path[ind-1][2], path[ind-1][3]))-(Vector3.new(path[ind][1], path[ind][2], path[ind][3]))).magnitude
			if debounce == true then
				local prt = Instance.new("Part")
				prt.Anchored = true
				prt.Parent = workspace.Nodes
				prt.Size = Vector3.new(8,8,8)
				prt.Position = Vector3.new(path[ind-1][1], path[ind-1][2], path[ind-1][3])/3
				prt.Material = Enum.Material.Neon
				prt.Shape = Enum.PartType.Ball
				prt.Color = Color3.fromRGB(42, 255, 19)
			end
			pathlength = pathlength + distance
			ind-=1
		end

		if pathlength < globalvariable[1] then
			globalvariable[1] = pathlength
		elseif globalvariable[1] == 0 then
			globalvariable[1] = pathlength
		end
	else
		globalvariable[1] = 0
	end
end

function rrt:_gen_final_course(goalind,start,endpoint,nodelist)
	local path = {{endpoint.x, endpoint.y, endpoint.z}}

	while nodelist[goalind].parent ~= nil do
		local node = nodelist[goalind]
		table.insert(path,rrt:_len(path) + 1,{node.x, node.y, node.z})
		goalind = node.parent
	end
	table.insert(path,rrt:_len(path) + 1,{start.x, start.y, start.z})
	return path
end


function rrt:_path_validation()
	local lastIndex = self:_get_best_last_index()
	if lastIndex ~= nil then
		while self.nodeList[lastIndex].parent ~= nil do
			local nodeInd = lastIndex
			lastIndex = self.nodeList[lastIndex].parent

			local dx = self.nodeList[nodeInd].x - self.nodeList[lastIndex].x
			local dy = self.nodeList[nodeInd].y - self.nodeList[lastIndex].y
			local d = math.sqrt(dx^2 + dy^2)

			if not self:_check_collision_extend(self.nodeList[lastIndex].x, self.nodeList[lastIndex].y, self.nodeList[nodeInd].x,self.nodeList[nodeInd].y, d) then
				table.remove(self.nodeList.children, nodeInd)					
				self:_remove_branch(nodeInd) 
			end
		end
	end
end

function rrt:_remove_branch(nodeInd)
	for ix in self.nodelist[nodeInd].children do
		self:_remove_branch(ix)
	end

	table.remove(self.nodeList, nodeInd)
end

--TODO Issue found
function rrt:_choose_parent(newNode, nearinds)
	if #nearinds == 0 then
		return newNode
	end

	local dlist = {}

	for _,i in pairs(nearinds) do
		local dx = newNode.x - self.nodeList[i].x
		local dy = newNode.y - self.nodeList[i].y
		local dz = newNode.z - self.nodeList[i].z
		local d = math.sqrt(dx^2 + dy^2 + dz^2)

		if self:_check_collision_extend(self.nodeList[i].x, self.nodeList[i].y, self.nodeList[i].z, newNode.x, newNode.y, newNode.z, d) then
			table.insert(dlist,(#dlist) + 1,self.nodeList[i].cost + d)
		else
			table.insert(dlist,(#dlist) + 1,"inf")
		end
	end

	local mincost = math.min(table.unpack(dlist))
	local minind = nearinds[table.find(dlist,mincost)]

	if mincost == math.huge then
		print("mincost is inf")

		return newNode
	end

	newNode.cost = mincost
	newNode.parent = minind

	return newNode
end

function rrt:_heuristic_random_point()
	local rnd
	if math.random(0, 100) > self.goalSampleRate then
		local start = Vector3.new(self.start.x,self.start.y,self.start.z)
		local endpoint = Vector3.new(self.endpoint.x,self.endpoint.y,self.endpoint.z)

		local MajorAxis = globalvariable[1]
		local FocalLength = (math.sqrt(((start.X-endpoint.X)^2)+((start.Y-endpoint.Y)^2)+((start.Z-endpoint.Z)^2))/2)
		local MinorAxis = math.sqrt(((MajorAxis/2)^2)-FocalLength^2)

		local Center = start+(endpoint-start)*.5

		local xa = math.random(-(MajorAxis/2),MajorAxis/2)

		local intersept = (math.abs(MinorAxis*2)/math.abs(MajorAxis))*math.sqrt(((MajorAxis/2)^2)-xa^2)
		local randomintersepty = math.random(-intersept/2,intersept/2)

		
		local Z1 = math.abs(MinorAxis/2)*math.sqrt(1-xa^2/(MajorAxis/2)^2-randomintersepty^2/(MinorAxis/2)^2)

		local randominterseptz = math.random(-Z1,Z1)

		local randomposition = (CFrame.new(Center,start) * CFrame.new(randominterseptz,randomintersepty,xa)).Position
		
		--[[local prt = Instance.new("Part",workspace.Nodes)
		prt.Anchored = true
		prt.Position = (CFrame.new(workspace.Start.Position+(workspace.End.Position-workspace.Start.Position)*.5,workspace.Start.Position) * CFrame.new(randominterseptz/3,randomintersepty/3,xa/3)).Position
		prt.Size = Vector3.new(4,4,4)
		prt.Shape = Enum.PartType.Ball]]
		
		rnd = {randomposition.X,randomposition.Y,randomposition.Z}
	else
		rnd = {self.endpoint.x, self.endpoint.y, self.endpoint.z}
	end
	return rnd
end


function rrt:_len(t)
	local n = 0

	for _,v in pairs(t) do
		n = n + 1
	end
	return n
end

function rrt:_steer(rnd, nind)

	-- expand tree

	local nearestNode = self.nodeList[nind]

	local dx = rnd[1] - nearestNode.x
	local dy = rnd[2] - nearestNode.y
	local dz = rnd[3] - nearestNode.z
	local d = math.sqrt(dx^2 + dy^2 + dy^2)

	local newNode = Node.new(nearestNode.x, nearestNode.y, nearestNode.z)
	newNode.x = nearestNode.x + (rnd[1]-nearestNode.x) * (self.expandDis/d)
	newNode.y = nearestNode.y + (rnd[2]-nearestNode.y) * (self.expandDis/d)
	newNode.z = nearestNode.z + (rnd[3]-nearestNode.z) * (self.expandDis/d)

	newNode.cost = nearestNode.cost + self.expandDis
	newNode.parent = nind
	--warn(newNode)
	return newNode
end


function rrt:_get_random_point()
	local rnd

	if math.random(0,100) > self.goalSampleRate then
		rnd = {math.random(0, self.Xrand), math.random(0, self.Yrand), math.random(0, self.Zrand)}
	else
		rnd = {self.endpoint.x, self.endpoint.y, self.endpoint.z}
	end

	--warn(rnd[1],rnd[2])
	return rnd
end

function rrt:_get_best_last_index(nodelist,expand,endpoint)
	local disglist = {}

	for key, node in pairs(nodelist) do
		table.insert(disglist,key,math.sqrt(((node.x-endpoint.x)^2) + ((node.y-endpoint.y) ^2) + ((node.z-endpoint.z)^2)))
	end

	local goalinds = {}

	for index, element in pairs(disglist) do
		if element <= expand then
			table.insert(goalinds,index,index)
		end
	end

	if rrt:_len(goalinds) == 0 then
		return nil
	end

	for _,i in pairs(goalinds) do
		if nodelist[i].cost == math.min(nodelist[i].cost) then
			return i
		end
	end

	return nil
end

function rrt:_calc_dist_to_goal(a,b)
	return math.sqrt(a^2 + b^2)
end


function rrt:_find_near_nodes(newNode, value)
	local r = self.expandDis * value

	local dlist = {}
	local dlist2 = {}
	local dlist3 = {}
	local nearinds = {}

	for Index,Child in pairs(self.nodeList) do
		--warn("NodeList: "..Index)
		table.insert(dlist,Index,{(Child.x - newNode.x)^2,(Child.y - newNode.y)^2,(Child.z - newNode.z)^2})
	end

	for Index,Child in pairs(dlist) do
		table.insert(dlist2,Index,Child[1]+Child[2]+Child[3])
	end

	for Index,Child in pairs(dlist2) do
		if Child <= r^2 then
			--warn("Found Node At: "..Index)
			table.insert(dlist3,Index,Child)
		end
	end

	for Index,Child in pairs(self.nodeList) do
		if dlist3[Index] ~= nil then
			--warn("Node Assigned: "..Index)
			table.insert(nearinds,(#nearinds)+1,Index)
		end
	end

	--warn(nearinds)
	return nearinds
end

function rrt:_rewire(newNodeInd, newNode, nearinds)
	local nnode = rrt:_len(self.nodeList)
	for set,element in pairs(nearinds) do
		local nearNode = self.nodeList[element]

		local dx = newNode.x - nearNode.x
		local dy = newNode.y - nearNode.y
		local dz = newNode.z - nearNode.z
		local d = math.sqrt(dx^2 + dy^2 + dz^2)

		local scost = newNode.cost + d

		if nearNode.cost > scost then
			if self:_check_collision_extend(nearNode.x, nearNode.y, nearNode.z, newNode.x, newNode.y, newNode.z, d) then
				table.remove(self.nodeList[nearNode.parent].children,table.find(self.nodeList[nearNode.parent].children,element))

				nearNode.parent = newNodeInd
				nearNode.cost = scost

				table.insert(newNode.children,(#newNode.children) +1,element)

			end
		end
	end
end

function rrt:_check_collision_extend(nix, niy, niz, ix, iy, iz, d)
	local tmpNode = Node.new(nix,niy)

	for i = 1,math.floor(d/20) do
		tmpNode.x = nix + (ix - nix) * ((20*i)/d)
		tmpNode.y = niy + (iy - niy) * ((20*i)/d)
		tmpNode.z = niz + (iz - niz) * ((20*i)/d)
		if not self:_CollisionCheck(tmpNode, self.obstacleList) then
			return false
		end
	end

	return true
end

function rrt:_GetNearestListIndex(rnd) 
	local dlist = {}
	local dlist2 = {}
	local nearinds = {}

	for Index,Child in pairs(self.nodeList) do
		table.insert(dlist,(#dlist)+1,{(Child.x - rnd[1])^2,(Child.y - rnd[2])^2,(Child.z - rnd[3])^2})
	end

	for Index,Child in pairs(dlist) do
		table.insert(dlist2,Index,Child[1]+Child[2]+Child[3])
	end

	for Index,Child in pairs(self.nodeList) do
		table.insert(nearinds,(#nearinds)+1,Index)
	end

	return nearinds[table.find(dlist2,math.min(table.unpack(dlist2)))]
end

function rrt:_CollisionCheck(nodepart, obstacleList)
	for set,element in pairs(obstacleList) do
		local sx,sy,sz,ex,ey,ez = element[1]+4,element[2]+4,element[3]+4,element[4]+4,element[5]+4,element[6]+4
		if nodepart.x > sx and nodepart.x < sx+ex then
			if nodepart.y > sy and nodepart.y < sy+ey then
				if nodepart.z > sz and nodepart.z < sz+ez then
					return false
				end
			end
		end
	end
	return true
end


function Node.new(x,y,z)
	local self = setmetatable({}, Node)

	self.x = x
	self.y = y 
	self.z = z
	self.cost = 0.0
	self.parent = nil
	self.children = {}

	return self 
end

return rrt