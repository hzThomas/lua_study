-- script.lua

local json = loadfile("/usr/share/cwmp/json.lua")()
local sys = require("sys")
local uci = require("uci")

-- Fault codes
ERR_NONE = 0
ERR_REQUEST_DENIED = 1
ERR_INTERNAL_ERROR = 2
ERR_INVALID_ARGUMENTS = 3
ERR_RESOURCES_EXCEEDED = 4
ERR_INVALID_PARAMETER_NAME = 5
ERR_INVALID_PARAMETER_TYPE = 6
ERR_INVALID_PARAMETER_VALUE = 7
ERR_NON_WRITABLE_PARAMETER = 8
ERR_NOTIFICATION_REJECTED = 9
ERR_DOWNLOAD_FAILURE = 10
ERR_UPLOAD_FAILURE = 11
ERR_FILE_TRANSFER_AUTHENTICATION_FAILURE = 12
ERR_FILE_TRANSFER_UNSUPPORTED_PROTOCOL = 13
ERR_DOWNLOAD_FAIL_MULTICAST_GROUP = 14
ERR_DOWNLOAD_FAIL_CONTACT_SERVER = 15
ERR_DOWNLOAD_FAIL_ACCESS_FILE = 16
ERR_DOWNLOAD_FAIL_COMPLETE_DOWNLOAD = 17
ERR_DOWNLOAD_FAIL_FILE_CORRUPTED = 18
ERR_DOWNLOAD_FAIL_FILE_AUTHENTICATION = 19



PATH_DEVICEINFO = "InternetGatewayDevice.DeviceInfo."
PATH_MANAGEMENT_SERVER = "InternetGatewayDevice.ManagementServer."
PATH_IP = "InternetGatewayDevice.IP."
PATH_IP_INTERFACE = "InternetGatewayDevice.IP.Interface."
PATH_IP_DIAGNOSTICS = "InternetGatewayDevice.IP.Diagnostics."


-- ========================================================================


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
        return { self.data }
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

local function isString(x)
    if (type(x) == 'string') then
        return true
    else
        return false
    end
end

function Node:addParamter(name, writable, value, type)
    if (name == nil) then
        return false
    elseif (isString(name) == false) then
        return false
    end

    if (value == nil) then
        return false
    elseif (writable ~= "1" and writable ~= "0") then
        return false
    end

    if (value == nil) then
        return false
    end
    if (type == nil) then
        return false
    end

    self.paramters[name] = { writable, value, type }
end

function Node:getParamterValue(name)
    return json.encode({
        parameter = self.data .. "." .. name,
        value = self.paramters[name][2]
    })
end

function Node:getParamterValueJson(childNode, paramName)
    local path = table.concat(self:getPath(childNode), ".") .. "." .. paramName
    return json.encode({
        parameter = path,
        value = childNode.paramters[paramName][PARAM_VALUE]
    })
end

function Node:getParamterNameJson(childNode, paramName)
    local path = table.concat(self:getPath(childNode), ".") .. "." .. paramName
    return json.encode({
        parameter = path,
        writable = childNode.paramters[paramName][PARAM_WRITABLE]
    })
end

function Node:getNodeNameJson(childNode)
    local path = table.concat(self:getPath(childNode), ".") .. "."
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

function PrintTree(node, depth)
    depth = depth or 0
    local indent = string.rep("  ", depth)
    print(indent .. node.data)
    for _, child in ipairs(node.children) do
        PrintTree(child, depth + 1)
    end
end

-- ========================================================================
-- InternetGatewayDevice

Root    = Node.new("InternetGatewayDevice")
DevInfo = Node.new("DeviceInfo")
MServer = Node.new("ManagementServer.")
IP      = Node.new("IP")


MemStatus = Node.new("MemoryStatus")

IpInterface = Node.new("IpInterface")

Root:addChild(DevInfo)
Root:addChild(MServer)
Root:addChild(IP)

DevInfo:addChild(MemStatus)

DevInfo:addParamter("SpecVersion", "0", "", "xsd:string")

DevInfo.addParamter("ProvisioningCode", "0", "HZ-JM", "xsd:string")
DevInfo.addParamter("Manufacturer", "0", "", "xsd:string")
DevInfo.addParamter("ManufacturerOUI", "0", "HZJM", "xsd:string")
DevInfo.addParamter("ProductClass", "0", "JMTR002", "xsd:string")
DevInfo.addParamter("SerialNumber", "0", "HZJM007788", "xsd:string")
DevInfo.addParamter("HardwareVersion", "0", "cm286_v1.0", "xsd:string")
DevInfo.addParamter("SoftwareVersion", "0", "v0.88", "xsd:string")
DevInfo.addParamter("UpTime", "0", "", "xsd:string")
DevInfo.addParamter("DeviceLog", "0", "", "xsd:string")

MemStatus.addParamter("Total", "0", "38632", "xsd:unsignedInt")
MemStatus.addParamter("Free", "0", "2220", "xsd:unsignedInt")



IpInterface.addParamter("Enable", "0")
IpInterface.addParamter("Name", "0")
IpInterface.addParamter("Type", "0")


Stats = Node.new("Stats")
Stats.addParamter("BytesSent", "0")
Stats.addParamter("BytesReceived", "0")
Stats.addParamter("PacketsSent", "0")
Stats.addParamter("PacketsReceived", "0")
Stats.addParamter("ErrorsSent", "0")
Stats.addParamter("ErrorsReceived", "0")
Stats.addParamter("DiscardPacketsSent", "0")
Stats.addParamter("DiscardPacketsReceived", "0")

-- json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4AddressNumberOfEntries", writable = "0" }),
IPv4Address = Node.new("IPv4Address")
Stats.addParamter("IPv4Address.", "1")
Stats.addParamter("IPAddress", "1")
Stats.addParamter("AddressingType", "0")
Stats.addParamter("Enable", "0")
Stats.addParamter("SubnetMask", "0")


---------------

local function rutrn_error_info(fault_code)
    local info = "none error"
    if (fault_code == ERR_INVALID_ARGUMENTS) then
        info = "ERR_INVALID_ARGUMENTS"
    end

    return json.encode({ fault_code = ERR_NONE, err_info = info })
end

-- {"command":"upload", "url":"http://.../upload.cgi", "file_type":"config", "user_name":"admin", "password":"admin"}
local function action_upload(json_cmd)
    local url = json_cmd.url
    if (url == nil) then
        return 'url is nil'
    end

    local file_type = json_cmd.file_type
    if (file_type == nil) then
        return 'file_type is nil'
    end

    local user_name = json_cmd.user_name
    local password = json_cmd.password
    if ((user_name == nil) and (password == nil)) then
        return 'user_name is nil'
    end

    --os.execute("curl");
    --curl -u username:password -T /path/to/local/file http://example.com/upload/path
    return ""
end

local function action_download(json_cmd)
    local url = json_cmd.url
    local file_type = json_cmd.file_type
    local file_size = json_cmd.file_size
    local user_name = json_cmd.user_name
    local password = json_cmd.password

    --os.execute("curl");
    --curl -u admin:password123 -o example.zip https://example.com/files/example.zip
end

local function action_end(json_cmd)
    return json.encode({
        command = "end",
        respend = "OK"
    })
end

local function action_exit(json_cmd)
    return json.encode({
        command = "exit",
        respend = "OK"
    })
end

local function func_shell(cmd)
    local handle = io.popen(cmd)
    if handle then
        local result = handle:read("*a")
        handle:close()
        sys.info(result)
    else
        sys.info("Cannt run command")
    end
end

local function action_test(json_cmd)
    sys.info("hello, world")

    local x = uci.cursor()
    local uci_name = x:get("easycwmp", "local", "username")

    local imei = ""

    func_shell("ifconfig")

    local share_data = json.decode(sys.get_shared_data())
    if (share_data.imei ~= nil) then
        imei = share_data.imei
    end

    sys.info("imei: " .. imei)

    return json.encode({
        command = "test",
        name = '"' .. uci_name .. '"',
        respend = "OK"
    })
end

local function action_update_value_change(json_cmd)
    return json.encode({
        command = "update_value_change",
        respend = "OK"
    })
end

local function action_check_value_change(json_cmd)
    return json.encode({
        command = "check_value_change",
        parameter = "InternetGatewayDevice.DeviceInfo.SpecVersion",
        value = "1.0",
        notification = "no",
        type = "xsd:string",
        respend = "OK"
    })
end

--{"command": "inform", "class": "parameter"}
--{"command": "inform", "class": "device_id"}
local function action_inform_device_id(json_cmd)
    return json.encode({
        command = "inform",
        device_id = "1234567890",
        device_type = "1234567890",
        manufacturer = "OpenWrt",
        oui = "HZJM",
        product_class = "Generic",
        serial_number = "HZJM0001"
    })
end

local function action_inform_parameter(json_cmd)
    local json_resp = {
        Root:getParamterValueJson(DevInfo, "SpecVersion"),
        Root:getParamterValueJson(DevInfo, "ProvisioningCode"),
        Root:getParamterValueJson(DevInfo, "Manufacturer"),
        Root:getParamterValueJson(DevInfo, "ManufacturerOUI"),
        Root:getParamterValueJson(DevInfo, "ProductClass"),
        Root:getParamterValueJson(DevInfo, "SerialNumber"),
        Root:getParamterValueJson(DevInfo, "HardwareVersion"),
        Root:getParamterValueJson(DevInfo, "SoftwareVersion"),

        json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestURL", value = "" }),
        json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ParameterKey", value = "" }),
    }

    return table.concat(json_resp, "\n")
end
local function action_apply_service(json_cmd)
    return json.encode({
        command = "apply_service",
        respend = "OK"
    })
end

local function action_apply_service(json_cmd)
    return json.encode({
        command = "apply_service",
        respend = "OK",
        fault_code = 0
    })
end

local function action_apply_parameter(json_cmd)
    return json.encode({
        command = "apply_parameter",
        respend = "OK",
        fault_code = 0
    })
end

local function action_apply_download(json_cmd)
    return json.encode({
        command = "apply_download",
        status = "success",
        --config_load = "success",
        fault_code = 0
    })
end

local function action_apply_value(json_cmd)
    return json.encode({
        status = "success",
        fault_code = 0,
        param_key = json_cmd.argument
        -- parameter
        -- config_load
    })
end

local function action_apply_notification(json_cmd)
    return json.encode({
        status = "success",
        fault_code = 0
        -- parameter
        -- config_load
    })
end

local function action_apply_object(json_cmd)
    return json.encode({
        status = "success",
        fault_code = 0,
        param_key = json_cmd.argument
        -- parameter
        -- config_load
    })
end

local function action_get_name_device(json_cmd)
    if (json_cmd.argument == "0") then
        local json_resp = {
            json.encode({ parameter = "InternetGatewayDevice.", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.DeviceInfo.", writable = "0" }),

            Root:getParamterNameJson(DevInfo, "SpecVersion"),
            Root:getParamterNameJson(DevInfo, "ProvisioningCode"),
            Root:getParamterNameJson(DevInfo, "Manufacturer"),
            Root:getParamterNameJson(DevInfo, "ManufacturerOUI"),
            Root:getParamterNameJson(DevInfo, "ProductClass"),
            Root:getParamterNameJson(DevInfo, "SerialNumber"),
            Root:getParamterNameJson(DevInfo, "HardwareVersion"),
            Root:getParamterNameJson(DevInfo, "SoftwareVersion"),
            Root:getParamterNameJson(DevInfo, "UpTime"),
            Root:getParamterNameJson(DevInfo, "DeviceLog"),

            json.encode({ parameter = "InternetGatewayDevice.DeviceInfo.MemoryStatus.", writable = "0" }),
            Root:getParamterNameJson(MemStatus, "Total"),
            Root:getParamterNameJson(MemStatus, "Free"),

            json.encode({ parameter = "InternetGatewayDevice.IP.", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Enable", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Name", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Type", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4AddressNumberOfEntries", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.1.IPAddress", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.1.AddressingType", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.1.Enable", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.1.SubnetMask", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.BytesSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.BytesReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.PacketsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.PacketsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.ErrorsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.ErrorsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.DiscardPacketsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Stats.DiscardPacketsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Enable", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Name", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Type", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.IPv4AddressNumberOfEntries", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.1.IPAddress", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.1.AddressingType", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.1.Enable", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.1.SubnetMask", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.BytesSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.BytesReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.PacketsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.PacketsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.ErrorsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.ErrorsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.DiscardPacketsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Stats.DiscardPacketsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Enable", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Name", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Type", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4AddressNumberOfEntries", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.1.IPAddress", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.1.AddressingType", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.1.Enable", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.1.SubnetMask", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.BytesSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.BytesReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.PacketsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.PacketsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.ErrorsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.ErrorsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.DiscardPacketsSent", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Stats.DiscardPacketsReceived", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.DiagnosticsState", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.Host", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.NumberOfRepetitions", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.Timeout", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.DataBlockSize", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.SuccessCount", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.FailureCount", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.AverageResponseTime", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.MinimumResponseTime", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.MaximumResponseTime", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.URL", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.Username", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.Password", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.PeriodicInformEnable", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.PeriodicInformInterval", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.PeriodicInformTime", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestURL", writable = "0" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestUsername", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestPassword", writable = "1" }),
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ParameterKey", writable = "0" })
        }
        return table.concat(json_resp, "\n")
    elseif (json_cmd.argument == "1") then
        return json.encode({ parameter = "InternetGatewayDevice.DeviceInfo.", writable = "0" }) .. "\n" ..
            json.encode({ parameter = "InternetGatewayDevice.IP.", writable = "0" }) .. "\n" ..
            json.encode({ parameter = "InternetGatewayDevice.ManagementServer.", writable = "0" }) .. "\n"
    end
end

-- { "command": "get", "class": "value", parameter: "InternetGatewayDevice.IP." }
local function action_get_value_Device_IP(json_cmd)
    local json_resp = {
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Enable", value = "1", type = "xsd:boolean" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Name", value = "loopback" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.Type", value = "Loopback" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.IPv4AddressNumberOfEntries",
            value = "1",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.1.IPAddress", value = "127.0.0.1" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.1.AddressingType", value = "Static" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.1.Enable",
            value = "1",
            type =
            "xsd:boolean"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.1.IPv4Address.1.SubnetMask", value = "255.0.0.0" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.Stats.BytesSent",
            value = "384",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.Stats.BytesReceived",
            value = "384",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.Stats.PacketsSent",
            value = "8",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.Stats.PacketsReceived",
            value = "8",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.Stats.ErrorsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.Stats.ErrorsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.Stats.DiscardPacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.1.Stats.DiscardPacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),

        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Enable", value = "1", type = "xsd:boolean" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Name", value = "lan" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.Type", value = "Normal" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.IPv4AddressNumberOfEntries",
            value = "1",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.1.IPAddress", value = "192.168.0.1" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.1.AddressingType", value = "Static" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.1.Enable",
            value = "1",
            type =
            "xsd:boolean"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.IPv4Address.1.SubnetMask",
            value =
            "255.255.255.0"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.Stats.BytesSent",
            value = "12604",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.Stats.BytesReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.Stats.PacketsSent",
            value = "167",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.Stats.PacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.Stats.ErrorsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.Stats.ErrorsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.Stats.DiscardPacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.2.Stats.DiscardPacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),

        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.3.Enable", value = "1", type = "xsd:boolean" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.3.Name", value = "wan60" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.3.Type", value = "Normal" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.IPv4AddressNumberOfEntries",
            value = "1",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.3.IPv4Address.1.IPAddress", value = "" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.3.IPv4Address.1.AddressingType", value = "Static" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.IPv4Address.1.Enable",
            value = "1",
            type =
            "xsd:boolean"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.3.IPv4Address.1.SubnetMask", value = "" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.Stats.BytesSent",
            value = "10776",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.Stats.BytesReceived",
            value = "352",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.Stats.PacketsSent",
            value = "123",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.Stats.PacketsReceived",
            value = "4",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.Stats.ErrorsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.Stats.ErrorsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.Stats.DiscardPacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.3.Stats.DiscardPacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),

        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.4.Enable", value = "1", type = "xsd:boolean" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.4.Name", value = "wan61" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.4.Type", value = "Normal" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.IPv4AddressNumberOfEntries",
            value = "1",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.4.IPv4Address.1.IPAddress", value = "" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.4.IPv4Address.1.AddressingType", value = "Static" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.IPv4Address.1.Enable",
            value = "1",
            type =
            "xsd:boolean"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.4.IPv4Address.1.SubnetMask", value = "" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.Stats.BytesSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.Stats.BytesReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.Stats.PacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.Stats.PacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.Stats.ErrorsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.Stats.ErrorsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.Stats.DiscardPacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.4.Stats.DiscardPacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),

        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.5.Enable", value = "1", type = "xsd:boolean" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.5.Name", value = "wan67" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.5.Type", value = "Normal" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.IPv4AddressNumberOfEntries",
            value = "1",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.5.IPv4Address.1.IPAddress", value = "" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.5.IPv4Address.1.AddressingType", value = "Static" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.IPv4Address.1.Enable",
            value = "1",
            type =
            "xsd:boolean"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.5.IPv4Address.1.SubnetMask", value = "" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.Stats.BytesSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.Stats.BytesReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.Stats.PacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.Stats.PacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.Stats.ErrorsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.Stats.ErrorsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.Stats.DiscardPacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.5.Stats.DiscardPacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),


        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.6.Enable", value = "1", type = "xsd:boolean" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.6.Name", value = "wan0" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.6.Type", value = "Normal" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.IPv4AddressNumberOfEntries",
            value = "1",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.6.IPv4Address.1.IPAddress", value = "10.120.13.237" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.6.IPv4Address.1.AddressingType", value = "Static" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.IPv4Address.1.Enable",
            value = "1",
            type =
            "xsd:boolean"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.IPv4Address.1.SubnetMask",
            value =
            "255.255.255.0"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.Stats.BytesSent",
            value = "20320",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.Stats.BytesReceived",
            value = "352",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.Stats.PacketsSent",
            value = "136",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.Stats.PacketsReceived",
            value = "4",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.Stats.ErrorsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.Stats.ErrorsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.Stats.DiscardPacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.6.Stats.DiscardPacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Enable", value = "1", type = "xsd:boolean" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Name", value = "wan1" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.Type", value = "Normal" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.IPv4AddressNumberOfEntries",
            value = "1",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.1.IPAddress", value = "" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.1.AddressingType", value = "Static" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.1.Enable",
            value = "1",
            type =
            "xsd:boolean"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Interface.7.IPv4Address.1.SubnetMask", value = "" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.Stats.BytesSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.Stats.BytesReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.Stats.PacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.Stats.PacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.Stats.ErrorsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.Stats.ErrorsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.Stats.DiscardPacketsSent",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Interface.7.Stats.DiscardPacketsReceived",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.DiagnosticsState", value = "None" }),
        json.encode({ parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.Host", value = "" }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.NumberOfRepetitions",
            value = "3",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.Timeout",
            value = "1000",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.DataBlockSize",
            value = "64",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.SuccessCount",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.FailureCount",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.AverageResponseTime",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.MinimumResponseTime",
            value = "0",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.IP.Diagnostics.IPPing.MaximumResponseTime",
            value = "0",
            type =
            "xsd:unsignedInt"
        })
    }

    return table.concat(json_resp, "\n")
end

local function action_get_name(json_cmd)
    if (json_cmd.parameter == "InternetGatewayDevice.") then
        return action_get_name_device(json_cmd)
    end
end

local function action_get_value_Device_DeviceInfo(json_cmd)
    local json_resp = {
        Root:getParamterValueJson(DevInfo, "SpecVersion"),
        Root:getParamterValueJson(DevInfo, "ProvisioningCode"),
        Root:getParamterValueJson(DevInfo, "Manufacturer"),
        Root:getParamterValueJson(DevInfo, "ManufacturerOUI"),
        Root:getParamterValueJson(DevInfo, "ProductClass"),
        Root:getParamterValueJson(DevInfo, "SerialNumber"),
        Root:getParamterValueJson(DevInfo, "HardwareVersion"),
        Root:getParamterValueJson(DevInfo, "SoftwareVersion"),
        Root:getParamterValueJson(DevInfo, "UpTime"),
        Root:getParamterValueJson(DevInfo, "DeviceLog"),
        Root:getParamterValueJson(MemStatus, "Total"),
        Root:getParamterValueJson(MemStatus, "Free"),
    }

    return table.concat(json_resp, "\n")
end

-- { "command": "get", "class": "value", parameter= "InternetGatewayDevice.ManagementServer." }
local function action_get_value_Device_ManagementServer(json_cmd)
    local json_resp = {
        json.encode({
            parameter = "InternetGatewayDevice.ManagementServer.URL",
            value =
            "http://39.106.195.193:9090/ACS-server/ACS/hzjimi"
        }),
        json.encode({ parameter = "InternetGatewayDevice.ManagementServer.Username", value = "acs" }),
        json.encode({ parameter = "InternetGatewayDevice.ManagementServer.Password", value = "" }),
        json.encode({
            parameter = "InternetGatewayDevice.ManagementServer.PeriodicInformEnable",
            value = "1",
            type =
            "xsd:boolean"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.ManagementServer.PeriodicInformInterval",
            value = "120",
            type =
            "xsd:unsignedInt"
        }),
        json.encode({
            parameter = "InternetGatewayDevice.ManagementServer.PeriodicInformTime",
            value = "0001-01-01T00:00:00Z",
            type = "xsd:dateTime"
        }),
        json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestURL", value = "" }),
        json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestUsername", value = "easycwmp" }),
        json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestPassword", value = "easycwmp" }),
        json.encode({ parameter = "InternetGatewayDevice.ManagementServer.ParameterKey", value = "unsetCommandKey" }),
    }
    return table.concat(json_resp, "\n")
end

-- { "command": "get", "class": "value", parameter= "InternetGatewayDevice.ManagementServer.PeriodicInformInterval" }
local function action_get_value_Device_ManagementServer_PeriodicInformInterval(json_cmd)
    return json.encode({
        parameter = "InternetGatewayDevice.ManagementServer.PeriodicInformInterval",
        value = "120",
        type =
        "xsd:unsignedInt"
    })
end

-- { "command": "get_value", parameter= "InternetGatewayDevice.ManagementServer.ConnectionRequestUsername" }
local function action_get_value__Device_ManagementServer_ConnectionRequestUsername(json_cmd)
    return json.encode({
        parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestUsername",
        value =
        "easycwmp"
    })
end

--{ "command": "get_value", "parameter": "InternetGatewayDevice.ManagementServer.ConnectionRequestPassword" }
local function action_get_value__Device_ManagementServer_ConnectionRequestPassword(json_cmd)
    return json.encode({
        parameter = "InternetGatewayDevice.ManagementServer.ConnectionRequestPassword",
        value =
        "easycwmp"
    })
end

local action_get_value_funtions = {
    ["InternetGatewayDevice.IP."] = action_get_value_Device_IP,
    ["InternetGatewayDevice.DeviceInfo."] = action_get_value_Device_DeviceInfo,
    ["InternetGatewayDevice.ManagementServer."] = action_get_value_Device_ManagementServer,
    ["InternetGatewayDevice.ManagementServer.PeriodicInformInterval"] =
        action_get_value_Device_ManagementServer_PeriodicInformInterval,
    ["InternetGatewayDevice.ManagementServer.ConnectionRequestUsername"] =
        action_get_value__Device_ManagementServer_ConnectionRequestUsername,
    ["InternetGatewayDevice.ManagementServer.ConnectionRequestPassword"] =
        action_get_value__Device_ManagementServer_ConnectionRequestPassword,

}
local function action_get_value(json_cmd)
    if (json_cmd.parameter == nil) then
        return rutrn_error_info(ERR_INVALID_ARGUMENTS)
    else
        action_get_value_funtions[json_cmd.parameter](json_cmd)
    end
end

local function action_get_notification()
    return rutrn_error_info(ERR_INVALID_ARGUMENTS)
end

local function action_reboot(json_cmd)
    return json.encode({
        command = "reboot",
        respend = "OK"
    })
end

local function action_factory_reset(json_cmd)
    return json.encode({
        command = "factory_reset",
        respend = "OK"
    })
end

local function action_set_value(json_cmd)
    -- parameter_name  = json_cmd.parameter
    -- parameter_value = json_cmd.argument
    return json.encode({
        command = "set_value",
        respend = "OK"
    })
end

local function action_set_notification(json_cmd)
    return json.encode({
        command = "set_notification",
        respend = "OK"
    })
end

local function action_add_object(json_cmd)
    return json.encode({
        command = "add_object",
        respend = "OK"
    })
end

local function action_delete_object(json_cmd)
    return json.encode({
        command = "delete_object",
        respend = "OK"
    })
end


local action_funtions = {
    ["get_name"] = action_get_name,
    ["get_value"] = action_get_value,
    ["get_notification"] = action_get_notification,
    ["set_value"] = action_set_value,
    ["set_notification"] = action_set_notification,
    ["apply_value"] = action_apply_value,
    ["apply_notification"] = action_apply_notification,
    ["apply_object"] = action_apply_object,
    ["apply_service"] = action_apply_service,
    ["add_object"] = action_add_object,
    ["delete_object"] = action_delete_object,
    ["download"] = action_download,
    ["upload"] = action_upload,
    ["factory_reset"] = action_factory_reset,
    ["reboot"] = action_reboot,
    ["inform_parameter"] = action_inform_parameter,
    ["inform_device_id"] = action_inform_device_id,
    ["end"] = action_end,
    ["exit"] = action_exit,
    ["test"] = action_test,
}


function Execute_json_command(input_json)
    local json_cmd = json.decode(input_json)

    if (json_cmd.command == nil) then
        return rutrn_error_info(ERR_INVALID_ARGUMENTS)
    end

    if (action_funtions[json_cmd.command] == nil) then
        return rutrn_error_info(ERR_INVALID_ARGUMENTS)
    end

    return action_funtions[json_cmd.command](json_cmd)
end
