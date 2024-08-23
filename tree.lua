local json = loadfile("./json.lua")()



PARAM_WRITABLE = 1
PARAM_VALUE = 2
PARAM_TYPE = 3

Node = {}
Node.__index = Node

function Node.new(data)
    local self = setmetatable({}, Node)
    self.data = data
    self.children = {}
    self.paramters = {}
    return self
end
 
function Node:addChild(node)
    table.insert(self.children, node)
end
 
function Node:removeChild(node)
    for i, child in ipairs(self.children) do
        if child == node then
            table.remove(self.children, i)
            return true
        end
    end
    return false
end
 
-- Delete nodes in the tree
function Node:remove(node)
    -- If it is a child node, delete it directly
    if self:removeChild(node) then
        return true
    end
    -- Recursive search for child nodes
    for _, child in ipairs(self.children) do
        if child:remove(node) then
            return true
        end
    end
    return false
end

function Node:getPath(node)
    if self == node then
        return {self.data}
    else
        for _, child in ipairs(self.children) do
            local path = child:getPath(node)
            if path then
                table.insert(path, 1, self.data)
                return path 
            end
        end
    end
end

function isString(param)
    return type(param)
end

function Node:addParamter(name, writable, value, type)
    print("addParamter".. isString(name))

    self.paramters[name] = {writable, value, type}
end 

function Node:getParamterValue(name)
    return json.encode({
        parameter = self.data ..".".. name,
        value = self.paramters[name][2]
    })
end

function Node:getParamterValueJson(childNode, paramName)
    path = table.concat(self:getPath(childNode), ".") .."."..paramName
    return json.encode({
        parameter = path,
        value = childNode.paramters[paramName][PARAM_VALUE]
    })
end

function Node:getParamterNameJson(childNode, paramName)
    path = table.concat(self:getPath(childNode), ".") .."."..paramName
    return json.encode({
        parameter = path,
        writable = childNode.paramters[paramName][PARAM_WRITABLE]
    })
end


function Node:getNodeNameJson(childNode)
    path = table.concat(self:getPath(childNode), ".") .."."
    return json.encode({
        parameter = path,
        writable = "0"
    })
end


function Node:getParamterType(name)
   return self.paramters[name][3]
--[[
   if (type == nil) then
        return "xsd:string"
    elseif (type == "int") then
        return "xsd:unsignedInt"
    elseif (type == "bool") then
        return "xsd:boolean"
    elseif (.type == "dateTime") then
        return "xsd:dateTime"
    end

    return "xsd:string"
]]
end

function printTree(node, depth)
    depth = depth or 0
    local indent = string.rep("  ", depth)
    print(indent .. node.data)
    for _, child in ipairs(node.children) do
        printTree(child, depth + 1)
    end
end

----- test ----

local InternetGatewayDevice = Node.new("InternetGatewayDevice")

local DeviceInfo            = Node.new("DeviceInfo")


local ManagementServer      = Node.new("ManagementServer.")
local IP                    = Node.new("IP")

local MemoryStatus          = Node.new("MemoryStatus")


local t1          = Node.new("t1")
local t2          = Node.new("t2")
local t11          = Node.new("t11")

InternetGatewayDevice:addChild(DeviceInfo)
InternetGatewayDevice:addChild(ManagementServer)
InternetGatewayDevice:addChild(IP)
DeviceInfo:addChild(MemoryStatus)
DeviceInfo:addParamter("SpecVersion", "0", "1223444", "xsd:string")
MemoryStatus:addChild(t1)
MemoryStatus:addChild(t2)
t1:addChild(t11)
MemoryStatus:addParamter("Total", "0", "0", "xsd:string")
MemoryStatus:addParamter("Free",  "0", "0", "xsd:string")


printTree(InternetGatewayDevice)

print(InternetGatewayDevice:getParamterValueJson(MemoryStatus, "Total"))
print(InternetGatewayDevice:getParamterNameJson(MemoryStatus, "Free"))
print(InternetGatewayDevice:getNodeNameJson(MemoryStatus))

InternetGatewayDevice:remove(t1)
printTree(InternetGatewayDevice)

print("==================================")
--[[
-- 定义一个节点类
Node = {}
Node.__index = Node
 
-- 节点类的构造函数
function Node.new(data)
    local self = setmetatable({}, Node)
    self.data = data
    self.children = {}
    return self
end
 
-- 添加子节点的方法
function Node:addChild(node)
    table.insert(self.children, node)
end
 
 ]]

--[[
-- 主程序
 
-- 创建根节点
local root = Node.new("Root")
 
-- 创建子节点
local child1 = Node.new("Child 1")
local child2 = Node.new("Child 2")
 
-- 将子节点添加到根节点
root:addChild(child1)
root:addChild(child2)
 
-- 创建子节点的子节点
local subChild1 = Node.new("Sub Child 1")
local subChild2 = Node.new("Sub Child 2")


-- 将子节点的子节点添加到子节点
child1:addChild(subChild1)
child2:addChild(subChild2)


-- 创建子节点的子节点的子节点
local subSubChild1 = Node.new("Sub Sub Child 1")
local subSubChild2 = Node.new("Sub Sub Child 2")
subChild1:addChild(subSubChild1) 
subChild1:addChild(subSubChild2)

local subSubSubChild1 = Node.new("Sub Sub Sub Child 1")
local subSubSubChild2 = Node.new("Sub Sub Sub Child 2")
subSubChild1:addChild(subSubSubChild1) 
subSubChild2:addChild(subSubSubChild2)


-- 打印树结构
function printTree(node, depth)
    depth = depth or 0
    local indent = string.rep("  ", depth)
    print(indent .. node.data)
    for _, child in ipairs(node.children) do
        printTree(child, depth + 1)
    end
end
 
-- 打印整个树
printTree(root)

]] 
 


