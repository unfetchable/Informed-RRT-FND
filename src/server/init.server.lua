--Nicolai, Edited on March 19th 2022, 19:53 GMT+1
local TS = game:GetService("TweenService")
local RRT = require(script.RRT)


local fidelity = 1
local offset = 3
local MaxIteration = 5000
local Nodes = 200

local start = workspace.Start.Position
local endpoint = workspace.End.Position
local m = (start-endpoint).Magnitude

local SA = Vector3.new(1000,600,1000)


local StartTime = tick()
warn("Begun iteration with: {Nodes: "..Nodes.." MaxIteration: "..MaxIteration.."}")

local rrt = RRT.new({start.X*offset, start.Y*offset,start.Z*offset},{endpoint.X*offset, endpoint.Y*offset,endpoint.Z*offset}, {SA.X,SA.Y,SA.Z}, 25,35,Nodes,MaxIteration)
local nodelist = RRT._Start(rrt)

warn("Completed iteration at: "..tick()-StartTime.." Seconds using "..script.Name)
