--Perpelea Vlad Developed the ellipsoid heuristics
local RRT = require(game.ServerScriptService.Server.RRT)
local real = 3


local start = workspace.Start
local endpoint = workspace.End

local XDIM = 1000
local YDIM = 600
local ZDIM = 1000

local obstacleList = {
}


function registerObstacle(part)
	local x = (part.Position.X - (part.Size.X/2))*real
	local y = (part.Position.Y - (part.Size.Y/2))*real	
	local z = (part.Position.Z - (part.Size.Z/2))*real

	table.insert(obstacleList,(#obstacleList)+1,{x,y,z,part.Size.X*real,part.Size.Y*real,part.Size.Z*real})
end

for _,v in pairs(workspace.Collisions:GetChildren()) do
	registerObstacle(v)
end
--[[
for _,element in pairs(obstacleList) do
    local prt = Instance.new("Part",workspace)
	prt.Anchored = true
	prt.Position = Vector3.new(element[1]+(element[4]/2),element[2]+(element[5]/2),element[3]+(element[6]/2))/real
	prt.Size = Vector3.new(element[4],element[5],element[6])/real
	prt.Color = Color3.fromRGB(0,0,0)
end]]

print(obstacleList)



local rrt = RRT.new({start.Position.X*real, start.Position.Y*real,start.Position.Z*real},{endpoint.Position.X*real, endpoint.Position.Y*real,endpoint.Position.Z*real},obstacleList, {XDIM,YDIM,ZDIM}, 15,15,100)
local nodelist = RRT._Start(rrt)
