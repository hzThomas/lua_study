-- script.lua

local json = loadfile("./json.lua")()
--local sys = require("sys")
--local uci = require("uci")

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
    --print("addParamter".. isString(name))
    if (type == nil) then
        self.paramters[name] = {writable, value, "xsd:string"}
    else
        self.paramters[name] = {writable, value, type}
    end
end 

function Node:getParamterValue(name)
    return json.encode({
        parameter = self.data ..".".. name,
        value = self.paramters[name][2]
    })
end

function Node:getParamterValueJson(childNode, paramName)
    path = table.concat(self:getPath(childNode), ".") .."."..paramName

    tp = childNode.paramters[paramName][PARAM_TYPE]
    if (tp == "xsd:string") then
        return json.encode({
            parameter = path,
            value = childNode.paramters[paramName][PARAM_VALUE]
        })
    else

    return json.encode({
        parameter = path,
        value = childNode.paramters[paramName][PARAM_VALUE],
        type =  childNode.paramters[paramName][PARAM_TYPE]
    })
    end
end

function Node:getParamterNameJson(childNode, paramName)
    path = table.concat(self:getPath(childNode), ".") .."."..paramName
    return json.encode({
        parameter = path,
        writable = childNode.paramters[paramName][PARAM_WRITABLE]
    })
end

function Node:getNodeNameJson(childNode)
    if (childNode == nil) then

    end
    local path = table.concat(self:getPath(childNode), ".") .."."
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

function Node:getNameJson()
    path = self.data .. "."
    return json.encode({
        parameter = path,
        writable = "0"
    })
end

function printTree(node, depth)
    depth = depth or 0
    local indent = string.rep("  ", depth)
    print(indent .. node.data)
    for _, child in ipairs(node.children) do
        printTree(child, depth + 1)
    end
end


-- ========================================================================
-- InternetGatewayDevice

Root    = Node.new("InternetGatewayDevice")
DevInfo = Node.new("DeviceInfo")
MServer = Node.new("ManagementServer")
IP      = Node.new("IP")

MemStatus = Node.new("MemoryStatus")

Iface  = Node.new("Interface")
Iface1 = Node.new("1")
Iface2 = Node.new("2")
Iface3 = Node.new("3")
Iface4 = Node.new("4")
Iface5 = Node.new("5")
Iface6 = Node.new("6")
Iface7 = Node.new("7")
Iface8 = Node.new("8")
Iface9 = Node.new("9")

Stats1 = Node.new("Stats")
Stats2 = Node.new("Stats")
Stats3 = Node.new("Stats")
Stats4 = Node.new("Stats")
Stats5 = Node.new("Stats")
Stats6 = Node.new("Stats")
Stats7 = Node.new("Stats")
Stats8 = Node.new("Stats")
Stats9 = Node.new("Stats")

IPv4Addr1 = Node.new("IPv4Address")
IPv4Addr2 = Node.new("IPv4Address")
IPv4Addr3 = Node.new("IPv4Address")
IPv4Addr4 = Node.new("IPv4Address")
IPv4Addr5 = Node.new("IPv4Address")
IPv4Addr6 = Node.new("IPv4Address")
IPv4Addr7 = Node.new("IPv4Address")
IPv4Addr8 = Node.new("IPv4Address")
IPv4Addr9 = Node.new("IPv4Address")

Diags = Node.new("Diagnostics")
IPPing = Node.new("IPPing")

local function iface_add_ip_addr(if_x, x)
    if_x:addParamter("IPv4AddressNumberOfEntries", "0", "1",  "xsd:unsignedInt")
    x:addParamter("IPv4Address.", "1", "", "xsd:string")
    x:addParamter("IPAddress", "1", "", "xsd:string")
    x:addParamter("AddressingType", "0", "", "xsd:string")
    x:addParamter("Enable", "0", "", "xsd:string")
    x:addParamter("SubnetMask", "0", "", "xsd:string")
   
end

local function iface_add_stats_params(if_x, x)
    x:addParamter("BytesSent", "0", "0", "xsd:unsignedInt")
    x:addParamter("BytesReceived", "0", "0", "xsd:unsignedInt")
    x:addParamter("PacketsSent", "0", "0", "xsd:unsignedInt")
    x:addParamter("PacketsReceived", "0", "0", "xsd:unsignedInt")
    x:addParamter("ErrorsSent", "0", "0", "xsd:unsignedInt")
    x:addParamter("ErrorsReceived", "0", "0", "xsd:unsignedInt")
    x:addParamter("DiscardPacketsSent", "0", "0", "xsd:unsignedInt")
    x:addParamter("DiscardPacketsReceived", "0", "0", "xsd:unsignedInt")
    
end

local function iface_x_init(if_x, ipaddr, stat)
    if_x:addParamter("Enable", "0", "0", "xsd:bool")
    if_x:addParamter("Name", "0", "", "xsd:string")
    if_x:addParamter("Type",  "0", "", "xsd:string")

    iface_add_ip_addr(if_x, ipaddr)
    
    iface_add_stats_params(if_x, stat)

    if_x:addChild(stat)
    if_x:addChild(ipaddr)

    Iface:addChild(if_x)
end

local function iface_init()   
    iface_x_init(Iface1, IPv4Addr1, Stats1)
    iface_x_init(Iface2, IPv4Addr2, Stats2)
    iface_x_init(Iface3, IPv4Addr3, Stats3)
    iface_x_init(Iface4, IPv4Addr4, Stats4)
    iface_x_init(Iface5, IPv4Addr5, Stats5)
    iface_x_init(Iface6, IPv4Addr6, Stats6)
    iface_x_init(Iface7, IPv4Addr7, Stats7)
    iface_x_init(Iface8, IPv4Addr8, Stats8)
    iface_x_init(Iface9, IPv4Addr9, Stats9)
    IP:addChild(Iface)   
end


local function IP_diagnostics_init()
    IPPing:addParamter("DiagnosticsState" ,"0", "None")
    IPPing:addParamter("Host", "1", "")
    IPPing:addParamter("NumberOfRepetitions", "0", "3", "xsd:unsignedInt")
    IPPing:addParamter("Timeout", "1", "1000", "xsd:unsignedInt")
    IPPing:addParamter("DataBlockSize", "0", "64", "xsd:unsignedInt")
    IPPing:addParamter("SuccessCount", "0", "0", "xsd:unsignedInt")
    IPPing:addParamter("FailureCount", "0", "0", "xsd:unsignedInt")
    IPPing:addParamter("AverageResponseTime", "0", "0", "xsd:unsignedInt")
    IPPing:addParamter("MinimumResponseTime", "0", "0", "xsd:unsignedInt")
    IPPing:addParamter("MaximumResponseTime", "0", "0", "xsd:unsignedInt")

    Diags:addChild(IPPing)

    IP:addChild(Diags)
end

LANDevice = Node.new("LANDevice")
LANHostConfigManagement = Node.new("LANHostConfigManagement")
DHCPStaticAddress=Node.new("DHCPStaticAddress")

WLANConfiguration = Node.new("WLANConfiguration")

WLANConfiguration1 = Node.new("1")


Hosts = Node.new("Hosts")

Host1 = Node.new("Host1")

local function LANDevice_init ()

    LANDevice:addParamter("LANWLANConfigurationNumberOfEntries", "1", "0", "xsd:unsignedInt")
    LANHostConfigManagement:addParamter("MACAddress", "0", "")
    LANHostConfigManagement:addParamter("MaxAddress", "0", "")
    LANHostConfigManagement:addParamter("SubnetMask", "0", "255.255.255.0")
    LANHostConfigManagement:addParamter("DomainName", "0", "")
    LANHostConfigManagement:addParamter("IPRouters", "0", "")
    LANHostConfigManagement:addParamter("DHCPLeaseTime", "0", "120", "xsd:unsignedInt")

    LANHostConfigManagement:addParamter("DHCPStaticAddressNumberOfEntries", "0", "1", "xsd:unsignedInt")
    DHCPStaticAddress:addParamter("Enable", "0", "1", "xsd:boolean")
    DHCPStaticAddress:addParamter("Chaddr", "0", "8.8.8.8")
    DHCPStaticAddress:addParamter("Yiaddr", "0", "114.114.114.114")

    LANHostConfigManagement:addChild(DHCPStaticAddress)
    LANDevice:addChild(LANHostConfigManagement)

    WLANConfiguration1:addParamter("Enable", "0", "0", "xsd:boolean")
    WLANConfiguration1:addParamter("Status", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("BSSID", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("Channel", "0", "0", "xsd:unsignedInt")
    WLANConfiguration1:addParamter("AutoChannelEnable", "0", "0", "xsd:boolean")
    WLANConfiguration1:addParamter("SSID", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("BeaconType", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("Standard", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("KeyPassphrase", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("WPAEncryptionModes", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("WPAAuthenticationMode", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("SSIDAdvertisementEnabled", "0", "0", "xsd:boolean")
    WLANConfiguration1:addParamter("X_BandType", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("X_BandWidth", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("X_CountryCode", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("TotalBytesSent", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("TotalBytesReceived", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("TotalPacketsSent", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("TotalPacketsReceived", "0", "0", "xsd:string")
    WLANConfiguration1:addParamter("TotalAssociations", "0", "0", "xsd:unsignedInt")
    --WLANConfiguration1:addParamter("AssociatedDevice", "0", = {},

    WLANConfiguration:addChild(WLANConfiguration1)
    LANDevice:addChild(WLANConfiguration)

    Hosts:addParamter("HostNumberOfEntries", "0", "1", "xsd:unsignedInt")
    Hosts:addChild(Host1)
    LANDevice:addChild(Hosts)
    
    Root:addChild(LANDevice)

end

WANCommonInterfaceConfig = Node.new("WANCommonInterfaceConfig")
WANPPPConnection = Node.new("WANPPPConnection")
WANConnectionDevice  = Node.new("WANConnectionDevice")
WANDevice = Node.new("WANDevice")
WANConnection = Node.new("WANConnection")
WANIPConnection=Node.new("WANIPConnection")
WANIPConnection1=Node.new("WANIPConnection1")

local function WANDevice_init()

    WANCommonInterfaceConfig:addParamter("WANAccessType", "0", "1")
    WANCommonInterfaceConfig:addParamter("PhysicalLinkStatus","0", "0", "xsd:unsignedInt")
    WANCommonInterfaceConfig:addParamter("TotalBytesSent","0", "0", "xsd:unsignedInt")
    WANCommonInterfaceConfig:addParamter("TotalBytesReceived","0", "0", "xsd:unsignedInt")
    WANCommonInterfaceConfig:addParamter("TotalPacketsSent","0", "0", "xsd:unsignedInt")
    WANCommonInterfaceConfig:addParamter("TotalPacketsReceived","0", "0", "xsd:unsignedInt")

    WANDevice:addParamter("WANConnectionNumberOfEntries", "0", "1", "xsd:unsignedInt")

    WANConnectionDevice:addChild(WANPPPConnection)

    WANConnectionDevice:addParamter("WANIPConnectionNumberOfEntries", "0", "0","xsd:unsignedInt")

    WANConnectionDevice:addParamter("WANPPPConnectionNumberOfEntries", "0", "0", "xsd:unsignedInt")

    WANIPConnection1:addParamter("ConnectionStatus", "0", "")
    WANIPConnection1:addParamter("PossibleConnectionTypes",  "0", "")
    WANIPConnection1:addParamter("ConnectionType", "0", "")
    WANIPConnection1:addParamter("Name", "0", "")
    WANIPConnection1:addParamter("Uptime", "0", "")
    WANIPConnection1:addParamter("LastConnectionError", "0","")
    WANIPConnection1:addParamter("NATEnabled", "0", "0", "xsd:boolean")
    WANIPConnection1:addParamter("AddressingType",  "0"  ,"")
    WANIPConnection1:addParamter("ExternalIPAddress", "0","")
    WANIPConnection1:addParamter("SubnetMask", "0","")
    WANIPConnection1:addParamter("DefaultGateway", "0","")
    WANIPConnection1:addParamter("DNSEnabled", "0", "0", "xsd:boolean")
    WANIPConnection1:addParamter("DNSServers", "0", "" )
    WANIPConnection1:addParamter("MaxMTUSize", "0", "1500", "xsd:unsignedInt")
    WANIPConnection1:addParamter("MACAddress", "0", "")
    WANIPConnection1:addParamter("PortMappingNumberOfEntries", "0", "0", "xsd:unsignedInt")
    WANIPConnection1:addParamter("RegisterNetworkType", "0", "")
    WANIPConnection1:addParamter("CellID", "0",  "0",   "xsd:unsignedInt")
    WANIPConnection1:addParamter("RSRP", "0",    "0",   "xsd:unsignedInt")
    WANIPConnection1:addParamter("RSRQ", "0",    "0",   "xsd:unsignedInt")
    WANIPConnection1:addParamter("RSSI", "0",    "0",   "xsd:unsignedInt")
    WANIPConnection1:addParamter("SINR", "0",    "0",   "xsd:unsignedInt")
    WANIPConnection1:addParamter("PCI",  "0",     "0",  "xsd:unsignedInt")
    WANIPConnection1:addParamter("ECGI", "0",  "")
                                            
    
    WANPPPConnection:addParamter("ConnectionStatus", "0",  "",      "xsd:string")
    WANPPPConnection:addParamter("PossibleConnectionTypes", "0", "",      "xsd:string")
    WANPPPConnection:addParamter("ConnectionType", "1","",      "xsd:string")
    WANPPPConnection:addParamter("Name", "0", "",      "xsd:string")
    WANPPPConnection:addParamter("Uptime", "0", "0",   "xsd:unsignedInt")
    WANPPPConnection:addParamter("LastConnectionError", "0","")
    WANPPPConnection:addParamter("NATEnabled", "0", "0", "xsd:boolean")
    WANPPPConnection:addParamter("AddressingType","0", "")
    WANPPPConnection:addParamter("ExternalIPAddress", "0", "0")
    WANPPPConnection:addParamter("SubnetMask", "0", "")
    WANPPPConnection:addParamter("DefaultGateway", "0", "")
    WANPPPConnection:addParamter("DNSEnabled", "0",  "0", "xsd:boolean")
    WANPPPConnection:addParamter("DNSServers",  "0",  "" )
    WANPPPConnection:addParamter("MaxMTUSize", "0", "1500", "xsd:unsignedInt")
    WANPPPConnection:addParamter("MACAddress",  "0",  "" )
    WANPPPConnection:addParamter("PortMappingNumberOfEntries", "0", "0", "xsd:unsignedInt")

    WANIPConnection:addChild(WANIPConnection1)
    WANDevice:addChild(WANCommonInterfaceConfig)
    WANConnection:addChild(WANIPConnection)
    WANDevice:addChild(WANConnectionDevice)
   

    Root:addChild(WANDevice)


end
--===============================================================

local function MServer_init()
    MServer:addParamter("URL", "1", "http://39.106.195.193:9090/ACS-server/ACS/hzjimi")
    MServer:addParamter("Username", "1", "acs")
    MServer:addParamter("Password", "1", "acs")
    MServer:addParamter("PeriodicInformEnable", "1", "1", "xsd:boolean")
    MServer:addParamter("PeriodicInformInterval", "1", "120", "xsd:unsignedInt")
    MServer:addParamter("PeriodicInformTime", "1", "0001-01-01T00:00:00Z","xsd:dateTime")
    MServer:addParamter("ConnectionRequestURL", "1", "" )
    MServer:addParamter("ConnectionRequestUsername", "1", "easycwmp")
    MServer:addParamter("ConnectionRequestPassword", "1", "easycwmp")
    MServer:addParamter("ParameterKey", "1", "unsetCommandKey")
    Root:addChild(MServer)
end

local function IP_init()
    iface_init()
    IP_diagnostics_init()
    
    
    Root:addChild(IP)
end


local function DevInfo_init()
    DevInfo:addChild(MemStatus)
    DevInfo:addParamter("SpecVersion", "0", "123", "xsd:string")
    DevInfo:addParamter("ProvisioningCode", "0", "HZ-JM", "xsd:string")
    DevInfo:addParamter("Manufacturer", "0", "", "xsd:string")
    DevInfo:addParamter("ManufacturerOUI", "0", "HZJM", "xsd:string")
    DevInfo:addParamter("ProductClass", "0", "JMTR002", "xsd:string")
    DevInfo:addParamter("SerialNumber", "0", "HZJM007788", "xsd:string")
    DevInfo:addParamter("HardwareVersion", "0", "cm286_v1.0", "xsd:string")
    DevInfo:addParamter("SoftwareVersion", "0", "v0.88", "xsd:string")
    DevInfo:addParamter("UpTime", "0", "", "xsd:string")
    DevInfo:addParamter("DeviceLog", "0", "", "xsd:string")

    MemStatus:addParamter("Total", "0", "38632", "xsd:unsignedInt")
    MemStatus:addParamter("Free", "0", "2220", "xsd:unsignedInt")

    Root:addChild(DevInfo)
end

MServer_init()

DevInfo_init()

IP_init()

LANDevice_init()

WANDevice_init()

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

local function act_get_name_Iface_x(t, if_x , ip_x, stats_x)
    table.insert(t,Root:getNodeNameJson(if_x))
    table.insert(t,Root:getParamterNameJson(if_x, "Enable"))
    table.insert(t,Root:getParamterNameJson(if_x, "Name"))
    table.insert(t,Root:getParamterNameJson(if_x, "Type"))
    table.insert(t,Root:getParamterNameJson(if_x, "IPv4AddressNumberOfEntries"))
    table.insert(t,Root:getNodeNameJson(ip_x, "IPv4Address"))
    table.insert(t,Root:getParamterNameJson(ip_x, "IPAddress"))
    table.insert(t,Root:getParamterNameJson(ip_x, "AddressingType"))
    table.insert(t,Root:getParamterNameJson(ip_x, "Enable"))
    table.insert(t,Root:getParamterNameJson(ip_x, "SubnetMask"))
    table.insert(t,Root:getNodeNameJson(stats_x, "Stats"))
    table.insert(t,Root:getParamterNameJson(stats_x, "BytesSent"))
    table.insert(t,Root:getParamterNameJson(stats_x, "BytesReceived"))
    table.insert(t,Root:getParamterNameJson(stats_x, "PacketsSent"))
    table.insert(t,Root:getParamterNameJson(stats_x, "PacketsReceived"))
    table.insert(t,Root:getParamterNameJson(stats_x, "ErrorsSent"))
    table.insert(t,Root:getParamterNameJson(stats_x, "ErrorsReceived"))
    table.insert(t,Root:getParamterNameJson(stats_x,  "DiscardPacketsSent"))
    table.insert(t,Root:getParamterNameJson(stats_x,  "DiscardPacketsReceived"))
end

local function get_name_Iface(t)
        
    table.insert(t, Root:getNodeNameJson(Iface))

    act_get_name_Iface_x(t, Iface1, IPv4Addr1, Stats1)
    act_get_name_Iface_x(t, Iface2, IPv4Addr2, Stats2)
    act_get_name_Iface_x(t, Iface3, IPv4Addr3, Stats3)
    act_get_name_Iface_x(t, Iface4, IPv4Addr4, Stats4)
    act_get_name_Iface_x(t, Iface5, IPv4Addr5, Stats5)
    act_get_name_Iface_x(t, Iface6, IPv4Addr6, Stats6)
    act_get_name_Iface_x(t, Iface7, IPv4Addr7, Stats7)
    act_get_name_Iface_x(t, Iface8, IPv4Addr8, Stats8)
    act_get_name_Iface_x(t, Iface9, IPv4Addr9, Stats9)
    
end

local function  get_value_Iface_x(t, if_x , ip_x, stats_x)

    table.insert(t,Root:getParamterValueJson(if_x, "Enable"))
    table.insert(t,Root:getParamterValueJson(if_x, "Name"))
    table.insert(t,Root:getParamterValueJson(if_x, "Type"))
    table.insert(t,Root:getParamterValueJson(if_x, "IPv4AddressNumberOfEntries"))
    
    table.insert(t,Root:getParamterValueJson(ip_x, "IPAddress"))
    table.insert(t,Root:getParamterValueJson(ip_x, "AddressingType"))
    table.insert(t,Root:getParamterValueJson(ip_x, "Enable"))
    table.insert(t,Root:getParamterValueJson(ip_x, "SubnetMask"))
    
    table.insert(t,Root:getParamterValueJson(stats_x, "BytesSent"))
    table.insert(t,Root:getParamterValueJson(stats_x, "BytesReceived"))
    table.insert(t,Root:getParamterValueJson(stats_x, "PacketsSent"))
    table.insert(t,Root:getParamterValueJson(stats_x, "PacketsReceived"))
    table.insert(t,Root:getParamterValueJson(stats_x, "ErrorsSent"))
    table.insert(t,Root:getParamterValueJson(stats_x, "ErrorsReceived"))
    table.insert(t,Root:getParamterValueJson(stats_x,  "DiscardPacketsSent"))
    table.insert(t,Root:getParamterValueJson(stats_x,  "DiscardPacketsReceived"))
end

local function act_get_val_Iface(t)
    
    get_value_Iface_x(t, Iface1, IPv4Addr1, Stats1)
    get_value_Iface_x(t, Iface2, IPv4Addr2, Stats2)
    get_value_Iface_x(t, Iface3, IPv4Addr3, Stats3)
    get_value_Iface_x(t, Iface4, IPv4Addr4, Stats4)
    get_value_Iface_x(t, Iface5, IPv4Addr5, Stats5)
    get_value_Iface_x(t, Iface6, IPv4Addr6, Stats6)
    get_value_Iface_x(t, Iface7, IPv4Addr7, Stats7)
    get_value_Iface_x(t, Iface8, IPv4Addr8, Stats8)
    get_value_Iface_x(t, Iface9, IPv4Addr9, Stats9)
end

local function get_name_deviceInfo(t)
    table.insert(t, Root:getNodeNameJson(DevInfo))
    table.insert(t, Root:getParamterNameJson(DevInfo, "SpecVersion"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "ProvisioningCode"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "Manufacturer"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "ManufacturerOUI"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "ProductClass"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "SerialNumber"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "HardwareVersion"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "SoftwareVersion"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "UpTime"))
    table.insert(t, Root:getParamterNameJson(DevInfo, "DeviceLog"))

    table.insert(t, Root:getNodeNameJson(MemStatus))
    table.insert(t, Root:getParamterNameJson(MemStatus, "Total"))
    table.insert(t, Root:getParamterNameJson(MemStatus, "Free"))
end

local function get_name_Diagnostics(t)

    table.insert(t, Root:getNodeNameJson(Diags))
    table.insert(t, Root:getNodeNameJson(IPPing))

    table.insert(t, Root:getParamterNameJson(IPPing, "DiagnosticsState"))
    table.insert(t, Root:getParamterNameJson(IPPing, "Host"))
    table.insert(t, Root:getParamterNameJson(IPPing, "NumberOfRepetitions"))
    table.insert(t, Root:getParamterNameJson(IPPing, "Timeout"))
    table.insert(t, Root:getParamterNameJson(IPPing, "DataBlockSize"))
    table.insert(t, Root:getParamterNameJson(IPPing, "SuccessCount"))
    table.insert(t, Root:getParamterNameJson(IPPing, "FailureCount"))
    table.insert(t, Root:getParamterNameJson(IPPing, "AverageResponseTime"))
    table.insert(t, Root:getParamterNameJson(IPPing, "MinimumResponseTime"))
    table.insert(t, Root:getParamterNameJson(IPPing, "MaximumResponseTime"))
end

local function get_value_Diagnostics(t)
    table.insert(t, Root:getParamterValueJson(IPPing, "DiagnosticsState"))
    table.insert(t, Root:getParamterValueJson(IPPing, "Host"))
    table.insert(t, Root:getParamterValueJson(IPPing, "NumberOfRepetitions"))
    table.insert(t, Root:getParamterValueJson(IPPing, "Timeout"))
    table.insert(t, Root:getParamterValueJson(IPPing, "DataBlockSize"))
    table.insert(t, Root:getParamterValueJson(IPPing, "SuccessCount"))
    table.insert(t, Root:getParamterValueJson(IPPing, "FailureCount"))
    table.insert(t, Root:getParamterValueJson(IPPing, "AverageResponseTime"))
    table.insert(t, Root:getParamterValueJson(IPPing, "MinimumResponseTime"))
    table.insert(t, Root:getParamterValueJson(IPPing, "MaximumResponseTime"))
end

local function get_name_ManagementServer(t)
    table.insert(t, Root:getNodeNameJson(MServer))
    table.insert(t, Root:getParamterNameJson(MServer, "URL"))
    table.insert(t, Root:getParamterNameJson(MServer, "Username"))
    table.insert(t, Root:getParamterNameJson(MServer, "Password"))
    table.insert(t, Root:getParamterNameJson(MServer, "PeriodicInformEnable"))
    table.insert(t, Root:getParamterNameJson(MServer, "PeriodicInformInterval"))
    table.insert(t, Root:getParamterNameJson(MServer, "PeriodicInformTime"))
    table.insert(t, Root:getParamterNameJson(MServer, "ConnectionRequestURL"))
    table.insert(t, Root:getParamterNameJson(MServer, "ConnectionRequestUsername"))
    table.insert(t, Root:getParamterNameJson(MServer, "ConnectionRequestPassword"))
    table.insert(t, Root:getParamterNameJson(MServer, "ParameterKey"))
end

local function get_value_ManagementServer(t)
    table.insert(t, Root:getParamterValueJson(MServer, "URL"))
    table.insert(t, Root:getParamterValueJson(MServer, "Username"))
    table.insert(t, Root:getParamterValueJson(MServer, "Password"))
    table.insert(t, Root:getParamterValueJson(MServer, "PeriodicInformEnable"))
    table.insert(t, Root:getParamterValueJson(MServer, "PeriodicInformInterval"))
    table.insert(t, Root:getParamterValueJson(MServer, "PeriodicInformTime"))
    table.insert(t, Root:getParamterValueJson(MServer, "ConnectionRequestURL"))
    table.insert(t, Root:getParamterValueJson(MServer, "ConnectionRequestUsername"))
    table.insert(t, Root:getParamterValueJson(MServer, "ConnectionRequestPassword"))
    table.insert(t, Root:getParamterValueJson(MServer, "ParameterKey"))
end

local function action_get_name_device(json_cmd)
    if (json_cmd.argument == "0") then
        
        local t = {}

        table.insert(t, Root:getNameJson())

        get_name_deviceInfo(t)    
        get_name_Iface(t)
        get_name_Diagnostics(t)            
        get_name_ManagementServer(t)

        return table.concat(t, "\n")
    elseif (json_cmd.argument == "1") then

        local t = {}

        table.insert(t, Root:getNodeNameJson(DevInfo))
        table.insert(t, Root:getNodeNameJson(IP))
        table.insert(t, Root:getNodeNameJson(MServer))

        return table.concat(t, "\n")
    end
end

-- { "command": "get", "class": "value", parameter: "InternetGatewayDevice.IP." }
local function action_get_value_Device_IP(json_cmd)
    local t = {}
    act_get_val_Iface(t)
     get_value_Diagnostics(t)
    s = table.concat(t, "\n")
    t = nil
    return s
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
    local t = {}
    get_value_ManagementServer(t)
    return table.concat(t, "\n")
end

-- { "command": "get", "class": "value", parameter= "InternetGatewayDevice.ManagementServer.PeriodicInformInterval" }
local function action_get_value_Device_ManagementServer_PeriodicInformInterval(json_cmd)
    return Root:getParamterValueJson(MServer, "PeriodicInformInterval")
end

-- { "command": "get_value", parameter= "InternetGatewayDevice.ManagementServer.ConnectionRequestUsername" }
local function action_get_value__Device_ManagementServer_ConnectionRequestUsername(json_cmd)
    return Root:getParamterValueJson(MServer, "ConnectionRequestUsername")
end

--{ "command": "get_value", "parameter": "InternetGatewayDevice.ManagementServer.ConnectionRequestPassword" }
local function action_get_value__Device_ManagementServer_ConnectionRequestPassword(json_cmd)
    return Root:getParamterValueJson(MServer, "ConnectionRequestPassword")
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
        return action_get_value_funtions[json_cmd.parameter](json_cmd)
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


-- test code --
printTree(Root)

print(Execute_json_command('{"command":"get_name", "parameter":"InternetGatewayDevice.", "argument":"0"}'))

print(Execute_json_command('{"command":"get_name", "parameter":"InternetGatewayDevice.", "argument":"1"}'))

print(Execute_json_command('{"command":"get_value", "parameter":"InternetGatewayDevice.IP."}'))

print(Execute_json_command('{"command":"get_value", "parameter":"InternetGatewayDevice.DeviceInfo."}'))

print(Execute_json_command('{"command":"get_value", "parameter":"InternetGatewayDevice.ManagementServer."}'))

print("===============")

print(action_get_value_Device_ManagementServer_PeriodicInformInterval())

print(action_get_value__Device_ManagementServer_ConnectionRequestUsername())

print(action_get_value__Device_ManagementServer_ConnectionRequestPassword())


printTree(Root)
