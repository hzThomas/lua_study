local json = loadfile("./json.lua")()


TOBJECT = 1
TUINT = 2
TINT = 3
TBOOL = 4
TSTRING = 5

RD_ONLY = "0"
RW_BOTH = "1"

PARAM_WRITABLE = 1
PARAM_VALUE = 2
PARAM_TYPE = 3

Node = {}
Node.__index = Node


function Node.new(name, type, RW_BOTH, maxLen, defValue)
    local self = setmetatable({}, Node)
    self.name = name
    self.RW_BOTH = RW_BOTH
    self.maxLen = maxLen
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
        return {self.name}
    else
        for _, child in ipairs(self.children) do
            local path = child:getPath(node)
            if path then
                table.insert(path, 1, self.name)
                return path 
            end
        end
    end
end

function isTSTRING(param)
    return type(param)
end

function Node:addParamter(name, type, writable, maxLen, value)
    --print("addParamter".. isTSTRING(name))
    if (type == nil) then
        self.paramters[name] = {writable, value, "xsd:TSTRING"}
    else
        self.paramters[name] = {writable, value, type}
    end
end 

function Node:getParamterValue(name)
    return json.encode({
        parameter = self.name ..".".. name,
        value = self.paramters[name][2]
    })
end

function Node:getParamterValueJson(childNode, paramName)
    path = table.concat(self:getPath(childNode), ".") .."."..paramName

    tp = childNode.paramters[paramName][PARAM_TYPE]
    if (tp == "xsd:TSTRING") then
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
        return "xsd:TSTRING"
    elseif (type == "int") then
        return "xsd:unsignedInt"
    elseif (type == "bool") then
        return "xsd:TBOOL"
    elseif (.type == "dateTime") then
        return "xsd:dateTime"
    end

    return "xsd:TSTRING"
]]
end

function Node:getNameJson()
    path = self.name .. "."
    return json.encode({
        parameter = path,
        writable = "0"
    })
end

function printTree(node, depth)
    depth = depth or 0
    local indent = string.rep("  ", depth)
    print(indent .. node.name)
    for _, child in ipairs(node.children) do
        printTree(child, depth + 1)
    end
end

function addTreeNode(node, name, type, RW_BOTH, maxLen, defValue)
    v = Node.new(name, type, RW_BOTH,  maxLen,defValue)
    node:addChild(v)
end

function newTreeObject(name,  RW_BOTH)
    return Node.new(name, TOBJECT, RW_BOTH)
end


--==========================================================
InternetGatewayDevice = Node.new("InternetGatewayDevice", TOBJECT, RD_ONLY)

InternetGatewayDevice:addChild(Node.new("DeviceSummary", TSTRING,  RD_ONLY, "1024", "InternetGatewayDevice:1.1[](Baseline:1, EthernetLAN:1, WiFiLAN:1, ADSLWAN:1, EthernetWAN:1, QoS:1, Bridging:1, Time:1, IPPing:1, DeviceAssociation:1, UDPConnReq:1, Download:1, DownloadTCP:1, Upload:1, UploadTCP:1, UDPEcho:1, UDPEchoPlus:1), VoiceService:1.0[](Endpoint:1, SIPEndpoint:1, TAEndpoint:1)"))

InternetGatewayDevice:addChild(Node.new("LANDeviceNumberOfEntries",  TUINT, RD_ONLY, "0", "1"))
InternetGatewayDevice:addChild(Node.new("WANDeviceNumberOfEntries",  TUINT, RD_ONLY, "0", "4"))


DeviceConfig = Node.new("DeviceConfig", TOBJECT, RD_ONLY)  
InternetGatewayDevice:addChild(DeviceConfig)

DeviceConfig:addChild(Node.new("ConfigFile",  TSTRING,  RD_ONLY,    "32000", "1"))
DeviceInfo = Node.new("DeviceInfo", TOBJECT, RD_ONLY)
InternetGatewayDevice:addChild(DeviceInfo)

DeviceInfo:addChild(Node.new("Manufacturer",   TSTRING,  RD_ONLY,    "64",    ""))
DeviceInfo:addChild(Node.new("ManufacturerOUI",   TSTRING,  RD_ONLY,    "6", ""))
DeviceInfo:addChild(Node.new("ModelName",   TSTRING, RD_ONLY, "64",   ""))
DeviceInfo:addChild(Node.new("Description",   TSTRING, RD_ONLY, "256",   ""))
DeviceInfo:addChild(Node.new("ProductClass",   TSTRING, RD_ONLY, "64" ,   ""))
DeviceInfo:addChild(Node.new("ProductType",   TSTRING, RD_ONLY, "64" ,   ""))
DeviceInfo:addChild(Node.new("SerialNumber",   TSTRING, RD_ONLY, "64" ,   ""))
DeviceInfo:addChild(Node.new("HardwareVersion",   TSTRING, RD_ONLY, "64"   ,   ""))
DeviceInfo:addChild(Node.new("SoftwareVersion",   TSTRING, RD_ONLY, "64"   ,   ""))
DeviceInfo:addChild(Node.new("HarmonyOSVersion",   TSTRING, RD_ONLY, "64"    ,   ""))
DeviceInfo:addChild(Node.new("FirmwareVersion",   TSTRING, RD_ONLY, "64"   ,   ""))
DeviceInfo:addChild(Node.new("ModemFirmwareVersion",   TSTRING, RD_ONLY, "64",   ""))
DeviceInfo:addChild(Node.new("AdditionalSoftwareVersion",   TSTRING, RD_ONLY, "64",   ""))
DeviceInfo:addChild(Node.new("SpecVersion", TSTRING, RD_ONLY, "16", ""))
DeviceInfo:addChild(Node.new("ProvisioningCode", TSTRING,  RW_BOTH, "64", ""))
DeviceInfo:addChild(Node.new("UpTime", TUINT, RD_ONLY,    "0", "0"))
DeviceInfo:addChild(Node.new("DeviceLog", TSTRING, RD_ONLY, "32000" , ""))
DeviceInfo:addChild(Node.new("X_ATP_IconType", TSTRING,  RD_ONLY, "32",   ""))
DeviceInfo:addChild(Node.new("X_ATP_LocalMac", "int", RW_BOTH,   "0", "-1"))

X_ATP_Antenna = Node.new("X_ATP_Antenna", TOBJECT, RD_ONLY)  
DeviceInfo:addChild(X_ATP_Antenna)

X_ATP_AdaptImage = Node.new("X_ATP_AdaptImage", TOBJECT, RD_ONLY)  
DeviceInfo:addChild(X_ATP_AdaptImage)

X_ATP_AdaptImage:addChild(Node.new("Band", TUINT, RD_ONLY, "0", "0"))
X_ATP_AdaptImage:addChild(Node.new("WpsResetKeyShare", TUINT, RD_ONLY, "0", "0"))
X_ATP_AdaptImage:addChild(Node.new("SoftShutDown", TUINT, RD_ONLY,    "0", "0"))
X_ATP_AdaptImage:addChild(Node.new("SmartHomeID",   TSTRING, RD_ONLY, "8", "0000"))
X_ATP_AdaptImage:addChild(Node.new("PowerKeyEnable", TBOOL, RD_ONLY,   "0", "1"))
X_ATP_AdaptImage:addChild(Node.new("HibrgDevAccessDeny", TBOOL, RD_ONLY,"0", "0"))
X_ATP_AdaptImage:addChild(Node.new("GigahomeType", TUINT, RD_ONLY, "0", "0"))

SpreadName = Node.new("SpreadName", TOBJECT, RD_ONLY)  
X_ATP_AdaptImage:addChild(SpreadName)

SpreadName:addChild(Node.new("Language",   TUINT, RD_ONLY,    "0", "0"))
SpreadName:addChild(Node.new("Name", TSTRING, RD_ONLY, "64",    ""))

Time = Node.new("Time", TOBJECT, RD_ONLY)  
InternetGatewayDevice:addChild(Time)


Time:addChild(Node.new("Enable",   TBOOL, RW_BOTH,   "0", "0"))
Time:addChild(Node.new("Status", TSTRING, RD_ONLY, "32",    "Disabled"))
Time:addChild(Node.new("NTPServer1", TSTRING, RW_BOTH,   "64",    ""))
Time:addChild(Node.new("NTPServer2", TSTRING, RW_BOTH,   "64",    ""))
Time:addChild(Node.new("NTPServer3", TSTRING, RW_BOTH,   "64",    ""))
Time:addChild(Node.new("NTPServer4", TSTRING, RW_BOTH,   "64",    ""))
Time:addChild(Node.new("NTPServer5", TSTRING, RW_BOTH,  "64",    ""))
Time:addChild(Node.new("CurrentLocalTime", "dateTime",    RD_ONLY,  "20",    ""))
Time:addChild(Node.new("LocalTimeZoneName", TSTRING,  RW_BOTH,   "64",    "GMT+0"))
Time:addChild(Node.new("CurrentTimeZone",   TSTRING, RD_ONLY, "64",    "GMT+00:00"))

UserInterface = Node.new("UserInterface", TOBJECT, RD_ONLY)  
InternetGatewayDevice:addChild(UserInterface)
UserInterface:addChild(Node.new("X_ATP_AutoCheckEnable",   TBOOL, RW_BOTH,   "0", "0"))
UserInterface:addChild(Node.new("X_ATP_ForceHotaEnable",   TBOOL, RW_BOTH,   "0", "1"))
UserInterface:addChild(Node.new("X_ATP_UpdateState",   TUINT, RW_BOTH,   "0", "0"))
UserInterface:addChild(Node.new("X_ATP_UpdateMacList", TSTRING,  RW_BOTH,   "256",   ""))
UserInterface:addChild(Node.new("X_ATP_BeginTime", TUINT, RW_BOTH,   "0", "180"))
UserInterface:addChild(Node.new("X_ATP_EndTime",   TUINT, RW_BOTH,   "0", "300"))
UserInterface:addChild(Node.new("X_ATP_LatestHotaTime",    TSTRING,  RW_BOTH,   "64",    ""))


X_ATP_Web = Node.new("X_ATP_Web", TOBJECT, RD_ONLY)  
UserInterface:addChild(X_ATP_Web)

IPPingDiagnostics = Node.new("IPPingDiagnostics", RD_ONLY)  
InternetGatewayDevice:addChild(IPPingDiagnostics)

IPPingDiagnostics:addChild(Node.new("DiagnosticsState", TSTRING, RW_BOTH,   "32","None"))
IPPingDiagnostics:addChild(Node.new("Interface",   TSTRING,  RW_BOTH,   "256",   ""))
IPPingDiagnostics:addChild(Node.new("Host",    TSTRING,  RW_BOTH,   "256",   ""))
IPPingDiagnostics:addChild(Node.new("NumberOfRepetitions", TUINT, RW_BOTH,   "0","0"))
IPPingDiagnostics:addChild(Node.new("Timeout", TUINT, RW_BOTH,   "0","0"))
IPPingDiagnostics:addChild(Node.new("DataBlockSize",   TUINT, RW_BOTH,   "0","0"))
IPPingDiagnostics:addChild(Node.new("Result",  TUINT, RD_ONLY,    "0","0"))
IPPingDiagnostics:addChild(Node.new("DSCP",    TUINT, RW_BOTH,   "0","0"))
IPPingDiagnostics:addChild(Node.new("SuccessCount",    TUINT, RD_ONLY,    "0","0"))
IPPingDiagnostics:addChild(Node.new("FailureCount",    TUINT, RD_ONLY,    "0","0"))
IPPingDiagnostics:addChild(Node.new("AverageResponseTime", TUINT, RD_ONLY,    "0","0"))
IPPingDiagnostics:addChild(Node.new("MinimumResponseTime", TUINT, RD_ONLY,    "0","0"))
IPPingDiagnostics:addChild(Node.new("MaximumResponseTime", TUINT, RD_ONLY,    "0","0"))
IPPingDiagnostics:addChild(Node.new("Reply",   TSTRING, RD_ONLY, "256",   ""))
IPPingDiagnostics:addChild(Node.new("Type",    TUINT, RD_ONLY,    "0","0"))


TraceRouteDiagnostics = Node.new("TraceRouteDiagnostics", TOBJECT, RD_ONLY)  
InternetGatewayDevice:addChild(TraceRouteDiagnostics)

TraceRouteDiagnostics:addChild(Node.new("DiagnosticsState",    TSTRING, RW_BOTH,   "32","None"))
TraceRouteDiagnostics:addChild(Node.new("Interface",   TSTRING, RW_BOTH,   "256",   ""))
TraceRouteDiagnostics:addChild(Node.new("Host",    TSTRING, RW_BOTH,   "256",   ""))
TraceRouteDiagnostics:addChild(Node.new("NumberOfTries",   TUINT, RW_BOTH,   "0","3"))
TraceRouteDiagnostics:addChild(Node.new("Timeout", TUINT, RW_BOTH,   "0","5000"))
TraceRouteDiagnostics:addChild(Node.new("DataBlockSize",   TUINT, RW_BOTH,   "0","38"))
TraceRouteDiagnostics:addChild(Node.new("Result",  TUINT, RD_ONLY,   "0","0"))
TraceRouteDiagnostics:addChild(Node.new("DSCP",    TUINT, RW_BOTH,   "0","0"))
TraceRouteDiagnostics:addChild(Node.new("MaxHopCount", TUINT, RW_BOTH,   "0","30"))
TraceRouteDiagnostics:addChild(Node.new("ResponseTime",    TUINT, RD_ONLY,   "0","0"))
TraceRouteDiagnostics:addChild(Node.new("RouteHopsNumberOfEntries",    TUINT, RD_ONLY,   "0","0"))


RouteHops = Node.new("RouteHops", TOBJECT, RD_ONLY)  
TraceRouteDiagnostics:addChild(RouteHops)

RouteHops:addChild(Node.new("HopHost",   TSTRING, RD_ONLY, "256",""))
RouteHops:addChild(Node.new("HopHostAddress",   TSTRING, RD_ONLY, "256",""))
RouteHops:addChild(Node.new("HopErrorCode", TUINT, RD_ONLY,   "0","0"))
RouteHops:addChild(Node.new("HopRTTimes",   TSTRING, RD_ONLY, "16",""))


CrashDiagnostics = Node.new("CrashDiagnostics", TOBJECT, RD_ONLY)  
InternetGatewayDevice:addChild(CrashDiagnostics)

CrashDiagnostics:addChild(Node.new("DiagnosticsState", TSTRING, RW_BOTH,   "32","None"))
CrashDiagnostics:addChild(Node.new("CrashFileState",   TBOOL, RW_BOTH,  "0","0"))
CrashDiagnostics:addChild(Node.new("Action",   TSTRING, RW_BOTH,   "32","None"))
CrashDiagnostics:addChild(Node.new("DiagnoseTag",  TSTRING, RW_BOTH,   "32",""))
CrashDiagnostics:addChild(Node.new("Mac",  TSTRING, RW_BOTH,   "32",""))
CrashDiagnostics:addChild(Node.new("AuthorizeEnable",  TBOOL, RW_BOTH,  "0","0"))
CrashDiagnostics:addChild(Node.new("UILanguage",   TUINT, RW_BOTH,   "0","0"))


X_ATP_WiFi = Node.new("X_ATP_WiFi", TOBJECT,RD_ONLY)  
InternetGatewayDevice:addChild(X_ATP_WiFi)


LANDevice = Node.new("LANDevice", TOBJECT,RD_ONLY)  
InternetGatewayDevice:addChild(LANDevice)

LANDevice:addChild(Node.new("LANEthernetInterfaceNumberOfEntries", TUINT, RD_ONLY,"0","4"))
LANDevice:addChild(Node.new("LANWLANConfigurationNumberOfEntries", TUINT, RD_ONLY,"0","4"))

LANDevice = Node.new("X_ATP_WlanRadio", TOBJECT,RD_ONLY)  
InternetGatewayDevice:addChild(X_ATP_WlanRadio)

--X_ATP_WlanRadio:addChild(Node.new("SupportBandwidth", TSTRING, RD_ONLY, "32", ""))
--X_ATP_WlanRadio:addChild(Node.new("ChannelStatus", TSTRING, RD_ONLY, "32", ""))
     
WLANConfiguration = Node.new("WLANConfiguration", TOBJECT, RD_ONLY)  
LANDevice:addChild(WLANConfiguration)


WLANConfiguration:addChild(Node.new("Enable", TBOOL, RW_BOTH,  "0","1"))
WLANConfiguration:addChild(Node.new("Status",  TSTRING, RD_ONLY, "16",""))
WLANConfiguration:addChild(Node.new("BSSID", TSTRING,  RD_ONLY,    "32",""))
WLANConfiguration:addChild(Node.new("X_ATP_OperatingFrequencyBand",   TSTRING, RD_ONLY, "16","2.4GHz"))
WLANConfiguration:addChild(Node.new("Channel",   TINT, RW_BOTH,   "0","6"))
WLANConfiguration:addChild(Node.new("AutoChannelEnable", TBOOL, RW_BOTH,  "0","0"))
WLANConfiguration:addChild(Node.new("PossibleChannels", TSTRING, RD_ONLY, "1024",  ""))
WLANConfiguration:addChild(Node.new("ChannelsInUse", TSTRING,  RD_ONLY,    "256" ,  "6"))
WLANConfiguration:addChild(Node.new("RegulatoryDomain",  TSTRING, RW_BOTH,   "16","GB"))
WLANConfiguration:addChild(Node.new("NetworkSyncCode",   TUINT, RW_BOTH,   "0","0"))
WLANConfiguration:addChild(Node.new("ActionType",    TUINT, RW_BOTH,   "0","0"))
WLANConfiguration:addChild(Node.new("SSID",  TSTRING, RW_BOTH,   "32","SSID"))
WLANConfiguration:addChild(Node.new("BeaconType",    TSTRING, RW_BOTH,   "32","Basic"))
WLANConfiguration:addChild(Node.new("MACAddressControlEnabled",  TBOOL, RW_BOTH,  "0","1"))
WLANConfiguration:addChild(Node.new("Standard",   TSTRING, RD_ONLY, "8",""))
WLANConfiguration:addChild(Node.new("WEPKeyIndex",   TINT, RW_BOTH ,  "0","1"))
WLANConfiguration:addChild(Node.new("WEPEncryptionLevel",   TSTRING, RD_ONLY, "64",""))
WLANConfiguration:addChild(Node.new("BasicEncryptionModes",  TSTRING, RW_BOTH,   "31","WEPEncryption"))
WLANConfiguration:addChild(Node.new("BasicAuthenticationMode",   TSTRING, RW_BOTH,   "31","None"))
WLANConfiguration:addChild(Node.new("WPAEncryptionModes",    TSTRING, RW_BOTH,   "31","TKIPEncryption"))
WLANConfiguration:addChild(Node.new("WPAAuthenticationMode", TSTRING, RW_BOTH,   "31","PSKAuthentication"))
WLANConfiguration:addChild(Node.new("IEEE11iEncryptionModes",    TSTRING, RW_BOTH,   "31","AESEncryption"))
WLANConfiguration:addChild(Node.new("IEEE11iAuthenticationMode", TSTRING, RW_BOTH,   "31","PSKAuthentication"))
WLANConfiguration:addChild(Node.new("SSIDAdvertisementEnabled",  TBOOL, RW_BOTH,  "0","1"))
WLANConfiguration:addChild(Node.new("WMMEnable", TBOOL, RW_BOTH,  "0","0"))
WLANConfiguration:addChild(Node.new("TotalBytesSent",    TUINT, RD_ONLY,   "0","0"))
WLANConfiguration:addChild(Node.new("TotalBytesReceived",    TUINT, RD_ONLY,   "0","0"))
WLANConfiguration:addChild(Node.new("TotalPacketsSent",  TUINT, RD_ONLY,   "0","0"))
WLANConfiguration:addChild(Node.new("TotalPacketsReceived",  TUINT, RD_ONLY,   "0","0"))
WLANConfiguration:addChild(Node.new("TotalAssociations", TUINT, RD_ONLY,   "0","0"))
WLANConfiguration:addChild(Node.new("X_ATP_Wlan11NBWControl",    TSTRING, RW_BOTH,   "16","20"))
WLANConfiguration:addChild(Node.new("X_ATP_MixedEncryptionModes", TSTRING, RW_BOTH,   "31","TKIPEncryption"))
WLANConfiguration:addChild(Node.new("X_ATP_WlanChipMaxAssoc",    TUINT, RW_BOTH,   "0","0"))
WLANConfiguration:addChild(Node.new("X_ATP_ChannelBusyness", TUINT, RD_ONLY,   "0","0"))
WLANConfiguration:addChild(Node.new("X_ATP_ChannelUsage",    TUINT, RD_ONLY,   "0","0"))
WLANConfiguration:addChild(Node.new("X_ATP_FreePower",   TINT, RD_ONLY,    "0","0"))


      
PreSharedKey = Node.new("PreSharedKey", TOBJECT, RD_ONLY)  
WLANConfiguration:addChild(PreSharedKey)

PreSharedKey:addChild(Node.new("KeyPassphrase",  TSTRING, RW_BOTH,  "64", ""))

      
WEPKey = Node.new("WEPKey", TOBJECT, RD_ONLY)  
WLANConfiguration:addChild(WEPKey)

WLANConfiguration:addChild(Node.new("WEPKey.WEPKey", TSTRING, RW_BOTH,   "128",   ""))
      
AssociatedDevice = Node.new("AssociatedDevice", TOBJECT, RW_BOTH)
WLANConfiguration:addChild(AssociatedDevice)

AssociatedDevice:addChild(Node.new("AssociatedDeviceMACAddress ",   TSTRING, RD_ONLY, "32",""))
AssociatedDevice:addChild(Node.new("AssociatedDeviceRssi", TSTRING,  RD_ONLY,    "8","0"))
AssociatedDevice:addChild(Node.new("AssociatedDeviceRate", TSTRING , RD_ONLY ,   "16","300 Mbps"))
AssociatedDevice:addChild(Node.new("AssociatedDeviceIPAddress",   TSTRING, RD_ONLY, "64",""))
AssociatedDevice:addChild(Node.new("AssociatedDeviceName TSTRING",  RD_ONLY,    "64",""))
AssociatedDevice:addChild(Node.new("X_ATP_DeviceLostPackgeRate",   TUINT, RD_ONLY, "0","0"))
AssociatedDevice:addChild(Node.new("X_ATP_DevicePer",  TUINT, RD_ONLY,   "0","0"))

WPS = Node.new("WPS", TOBJECT, RD_ONLY)  
WLANConfiguration:addChild(WPS)

WPS:addChild(Node.new("Enable",   TBOOL, RW_BOTH,  "0","0"))
WPS:addChild(Node.new("DevicePassword",    TSTRING, RW_BOTH,   "16",""))

Stats = Node.new("Stats", TOBJECT, RD_ONLY)  
WLANConfiguration:addChild(Stats)
Stats:addChild(Node.new("ErrorsSent",  TUINT, RD_ONLY,   "0","0"))
Stats:addChild(Node.new("ErrorsReceived",  TUINT, RD_ONLY,   "0","0"))
Stats:addChild(Node.new("DiscardPacketsSent",  TUINT, RD_ONLY,   "0","0"))
Stats:addChild(Node.new("DiscardPacketsReceived",  TUINT, RD_ONLY,   "0","0"))

Hosts = Node.new("Hosts", TOBJECT, RD_ONLY)  
WLANConfiguration:addChild(Hosts)

Hosts:addChild(Node.new("HostNumberOfEntries",   TUINT, RD_ONLY,   "0","0"))
Hosts:addChild(Node.new("X_ATP_ActiveHostNumberOfEntries",   TUINT, RD_ONLY,   "0","0"))
Hosts:addChild(Node.new("X_ATP_WiFiUserNum", TUINT, RD_ONLY,   "0","0"))

Host = Node.new("Host", TOBJECT, RD_ONLY)  
addTreeNode(Host, "IPAddress", TSTRING, RD_ONLY, "16", "")

addTreeNode(Host, "AddressSource",   TSTRING, RD_ONLY, "16","")
addTreeNode(Host, "LeaseTimeRemaining", TINT, RD_ONLY,    "0","0")
addTreeNode(Host, "MACAddress",   TSTRING, RD_ONLY, "32","")
addTreeNode(Host, "HostName", TSTRING,  RD_ONLY,    "64","")
addTreeNode(Host, "InterfaceType",  TSTRING, RD_ONLY, "16","")
addTreeNode(Host, "Active",   TBOOL, RD_ONLY,    "0","0")
Hosts:addChild(Host)

LANHostConfigManagement = Node.new("LANHostConfigManagement", TOBJECT, RD_ONLY)  
addTreeNode(LANHostConfigManagement,"MACAddress",   TSTRING, RD_ONLY, "32","")
addTreeNode(LANHostConfigManagement,"DHCPServerEnable",    TBOOL, RW_BOTH,  "0","0")
addTreeNode(LANHostConfigManagement,"DHCPServerConfigurable",  TBOOL, RW_BOTH,  "0","1")
addTreeNode(LANHostConfigManagement,"DHCPRelay",   TBOOL, RW_BOTH,  "0","1")
addTreeNode(LANHostConfigManagement,"SubnetMask",  TSTRING, RW_BOTH,   "256",  "")
addTreeNode(LANHostConfigManagement,"MinAddress",  TSTRING, RW_BOTH,   "16","192.168.1.2")
addTreeNode(LANHostConfigManagement,"MaxAddress",  TSTRING, RW_BOTH,   "16","192.168.1.254")
addTreeNode(LANHostConfigManagement,"ReservedAddresses",   TSTRING, RW_BOTH,   "256",   "")
addTreeNode(LANHostConfigManagement,"DNSServers",  TSTRING, RW_BOTH,   "64","192.168.1.1,192.168.1.1")
addTreeNode(LANHostConfigManagement,"StaticDnsServers",    TSTRING, RW_BOTH,   "64","")
addTreeNode(LANHostConfigManagement,"DeviceName",  TSTRING, RW_BOTH,   "253",   "")
addTreeNode(LANHostConfigManagement,"DomainName",  TSTRING, RW_BOTH,   "63","home")
addTreeNode(LANHostConfigManagement,"DHCPLeaseTime",   TINT, RW_BOTH,   "0","86400")
addTreeNode(LANHostConfigManagement,"UseAllocatedWAN", TSTRING, RW_BOTH,   "16","Normal")
addTreeNode(LANHostConfigManagement,"AssociatedConnection",    TSTRING, RW_BOTH,   "256" ,  "")
addTreeNode(LANHostConfigManagement,"IPInterfaceNumberOfEntries",  TUINT, RD_ONLY,   "0","1")
addTreeNode(LANHostConfigManagement,"DHCPStaticAddressNumberOfEntries",    TUINT, RD_ONLY,   "0","0")
addTreeNode(LANHostConfigManagement,"DHCPOptionNumberOfEntries",   TUINT, RD_ONLY,   "0","0")
addTreeNode(LANHostConfigManagement,"DHCPConditionalPoolNumberOfEntries",  TUINT, RD_ONLY,   "0","0")

IPInterface = newTreeObject("IPInterface", RW_BOTH)
addTreeNode(IPInterface,"IPInterfaceIPAddress",    TSTRING, RW_BOTH,   "16","192.168.1.1")
addTreeNode(IPInterface,"IPInterfaceSubnetMask",   TSTRING, RW_BOTH,   "16","255.255.255.0")
addTreeNode(IPInterface,"IPInterfaceAddressingType",   TSTRING, RW_BOTH,   "16","DHCP")
LANHostConfigManagement:addChild(IPInterface)
LANDevice:addChild(LANHostConfigManagement)

   
LANEthernetInterfaceConfig = newTreeObject("LANEthernetInterfaceConfig", RD_ONLY)    
addTreeNode(LANEthernetInterfaceConfig, "Enable",   TBOOL, RD_ONLY,    "0","1")
addTreeNode(LANEthernetInterfaceConfig, "Status",   TSTRING, RD_ONLY, "16","")
addTreeNode(LANEthernetInterfaceConfig, "Name", TSTRING, RW_BOTH,   "16","")
addTreeNode(LANEthernetInterfaceConfig, "MACAddress",   TSTRING, RD_ONLY, "32","")

LANEthStats = newTreeObject("Stats", RD_ONLY)    
  
addTreeNode(LANEthStats, "BytesSent",  TUINT, RD_ONLY,   "0","0")
addTreeNode(LANEthStats, "BytesReceived",  TUINT, RD_ONLY,   "0","0")
addTreeNode(LANEthStats, "PacketsSent",    TUINT, RD_ONLY,   "0","0")
addTreeNode(LANEthStats, "PacketsReceived",    TUINT, RD_ONLY,   "0","0")
LANEthernetInterfaceConfig:addChild(LANEthStats)
LANDevice:addChild(LANEthernetInterfaceConfig)



WANDevice = newTreeObject("WANDevice", RD_ONLY)        

addTreeNode(WANDevice, "WANConnectionNumberOfEntries", TUINT, RD_ONLY,"0","0")

WANCommonInterfaceConfig = newTreeObject("WANCommonInterfaceConfig", RD_ONLY)
addTreeNode(WANCommonInterfaceConfig, "WANAccessType",   TSTRING, RD_ONLY, "16","")
addTreeNode(WANCommonInterfaceConfig, "Layer1UpstreamMaxBitRate",   TUINT, RD_ONLY,   "0","0")
addTreeNode(WANCommonInterfaceConfig, "Layer1DownstreamMaxBitRate", TUINT, RD_ONLY,   "0","0")
addTreeNode(WANCommonInterfaceConfig, "EnabledForInternet", TBOOL, RW_BOTH,  "0","1")
addTreeNode(WANCommonInterfaceConfig, "PhysicalLinkStatus", TSTRING,  RD_ONLY ,   "16","")
addTreeNode(WANCommonInterfaceConfig, "WANAccessProvider",   TSTRING, RD_ONLY, "256" ,  "")
addTreeNode(WANCommonInterfaceConfig, "TotalBytesSent", TSTRING,   RD_ONLY  ,  "256"  , "")
addTreeNode(WANCommonInterfaceConfig, "TotalBytesReceived", TSTRING,   RD_ONLY ,   "256",   "")
addTreeNode(WANCommonInterfaceConfig, "TotalPacketsSent",   TSTRING,   RD_ONLY  ,  "256" ,  "")
addTreeNode(WANCommonInterfaceConfig, "TotalPacketsReceived",   TSTRING,   RD_ONLY  ,  "256",   "")
addTreeNode(WANCommonInterfaceConfig, "X_ATP_TotalBytes ",   TSTRING, RD_ONLY, "32","")
addTreeNode(WANCommonInterfaceConfig, "MaximumActiveConnections",   TUINT, RD_ONLY,   "0","0")
addTreeNode(WANCommonInterfaceConfig, "NumberOfActiveConnections",  TUINT, RD_ONLY,   "0","0")

Connection = newTreeObject("Connection", RD_ONLY)
addTreeNode(Connection, "Connection.ActiveConnectionDeviceContainer", TSTRING,  RD_ONLY,    "256",   "")
addTreeNode(Connection, "Connection.ActiveConnectionServiceID",   TSTRING, RD_ONLY, "256",   "")
WANCommonInterfaceConfig:addChild(Connection)

WANDevice:addChild(WANCommonInterfaceConfig)


X_ATP_WANUMTSInterfaceConfig = newTreeObject("X_ATP_WANUMTSInterfaceConfig", RD_ONLY)
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Enable", TBOOL, RD_ONLY,    "0","1")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Mode",   TSTRING, RD_ONLY, "32","Auto")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Order",   TSTRING, RD_ONLY, "32","Auto")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Band",   TSTRING, RD_ONLY, "32","Any")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "AutoSearchEnable",   TBOOL, RD_ONLY,   "0","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RegistedNetwork",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "UpLoadData", TSTRING,  RD_ONLY,    "32","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownLoadData",   TSTRING, RD_ONLY, "32","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "CurrentUpstreamRate  ",   TSTRING, RD_ONLY, "32","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "CurrentDownstreamRate",   TSTRING, RD_ONLY, "32","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "UpstreamMaxRate  ",   TSTRING, RD_ONLY, "32","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownstreamMaxRate",   TSTRING, RD_ONLY, "32","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SignalQuality",  TINT,  RD_ONLY,    "0","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ServiceStatus",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ServiceDomain",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RoamStatus", TSTRING,  RD_ONLY,    "256",   "")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SystemMode", TSTRING , RD_ONLY,    "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SIMStatus",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SysSubMode", TSTRING,  RD_ONLY,    "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "PLMN",   TSTRING, RD_ONLY, "8","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RSRQ",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RSRP",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RSSI",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SINR",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RSCP",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ECIO",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RAT",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "TAC",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RAC",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "LAC",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "bandwidth",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "castatus ",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "txpower  ",   TSTRING, RD_ONLY, "64","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "MCS",   TSTRING, RD_ONLY, "128",   "")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Earfcn", TSTRING,  RD_ONLY,    "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "TDD",   TSTRING, RD_ONLY, "64","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RRC",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "bandid", TSTRING,  RD_ONLY,    "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownlinkRank",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownlinkTM", TSTRING, RD_ONLY,    "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "UplinkMaxThrp",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownlinkMaxThrp",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ResetMaxThrp",   TSTRING, RW_BOTH,   "32","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "AccessStatus",   TSTRING, RD_ONLY, "64","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "eNodeBId",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ulFreq", TSTRING,  RD_ONLY,    "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "dlFreq", TSTRING,  RD_ONLY,    "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RoamAllowDialup",    TBOOL, RW_BOTH,  "0","0")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "attach_apn", TSTRING,  RD_ONLY,    "100",   "")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "QCI",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_WANUMTSInterfaceConfig, "CaCombination", TSTRING, RD_ONLY, "256",   "")


X_ATP_Stats = newTreeObject("Stats", RD_ONLY)
addTreeNode(X_ATP_Stats, "BytesSent",   TSTRING, RD_ONLY, "32","0")
addTreeNode(X_ATP_Stats, "BytesReceived",   TSTRING, RD_ONLY, "32","0")
addTreeNode(X_ATP_Stats, "PacketsSent",  TUINT, RD_ONLY,  "0","0")
addTreeNode(X_ATP_Stats, "PacketsReceived",  TUINT, RD_ONLY,   "0","0")
addTreeNode(X_ATP_Stats, "CurrentMonthDownload", TSTRING,  RD_ONLY, "32","")
addTreeNode(X_ATP_Stats, "CurrentMonthUpload",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_Stats, "MonthDuration", TUINT, RD_ONLY, "0","0")
addTreeNode(X_ATP_Stats, "MonthLastClearYear",   TUINT, RD_ONLY,   "0","0")
addTreeNode(X_ATP_Stats, "MonthLastClearMonth",  TUINT, RD_ONLY,   "0","0")
addTreeNode(X_ATP_Stats, "MonthLastClearDay",    TUINT, RD_ONLY,   "0","0")
X_ATP_WANUMTSInterfaceConfig:addChild(X_ATP_Stats)


X_ATP_signal =newTreeObject("X_ATP_signal", RD_ONLY)
addTreeNode(X_ATP_signal, "psc_ca_cellid", TSTRING,  RD_ONLY,    "32","")
addTreeNode(X_ATP_signal, "psc_ca_dl", TSTRING,  RD_ONLY,    "32","")
addTreeNode(X_ATP_signal, ".psc_ca_ul", TSTRING,  RD_ONLY,    "32","")
addTreeNode(X_ATP_signal, "psc_ca_status", TSTRING,  RD_ONLY,    "32","")

Scc = newTreeObject("Scc", RD_ONLY)  
addTreeNode(Scc, "scc_ca_cellid", TSTRING, RW_BOTH,   "32","")
addTreeNode(Scc, "scc_ca_dl", TSTRING, RW_BOTH,   "32","")
addTreeNode(Scc, "scc_ca_ul", TSTRING, RW_BOTH,   "32","")
addTreeNode(Scc, "scc_ca_status", TSTRING, RW_BOTH,   "32","")
X_ATP_signal:addChild(Scc)

X_ATP_WANUMTSInterfaceConfig:addChild(X_ATP_signal)


X_ATP_lmt_signal = newTreeObject("X_ATP_lmt_signal", RD_ONLY)  
addTreeNode(X_ATP_lmt_signal, "ri  ",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_lmt_signal, "cqi0",   TSTRING, RD_ONLY, "32","")
addTreeNode(X_ATP_lmt_signal, "cqi1",   TSTRING, RD_ONLY, "32","")
X_ATP_WANUMTSInterfaceConfig:addChild(X_ATP_lmt_signal)

WANDevice:addChild(X_ATP_WANUMTSInterfaceConfig)


WANConnectionDevice = newTreeObject("WANConnectionDevice", RW_BOTH)

addTreeNode(WANConnectionDevice, "WANIPConnectionNumberOfEntries",  TUINT, RD_ONLY, "0","0")


WANPPPConnection = newTreeObject("WANPPPConnection", RD_ONLY)  
addTreeNode(WANPPPConnection, "Enable", TBOOL, RW_BOTH,  "0","0")
addTreeNode(WANPPPConnection, "ConnectionStatus",    TSTRING, RW_BOTH,   "32","")
addTreeNode(WANPPPConnection, "ConnectionType",  TSTRING, RW_BOTH,   "16","IP_Routed")
addTreeNode(WANPPPConnection, "DefaultGateway",  TSTRING,  RD_ONLY,    "16","")
addTreeNode(WANPPPConnection, "Name ",   TSTRING, RD_ONLY, "256",   "")
addTreeNode(WANPPPConnection, "Uptime",  TUINT, RD_ONLY,   "0","0")
addTreeNode(WANPPPConnection, "LastConnectionError",   TSTRING, RD_ONLY, "64","ERROR_NONE")
addTreeNode(WANPPPConnection, "Username",    TSTRING, RW_BOTH,   "128" ,  "")
addTreeNode(WANPPPConnection, "Password",    TSTRING, RW_BOTH,   "128",   "")
addTreeNode(WANPPPConnection, "ExternalIPAddress",   TSTRING, RD_ONLY, "16","")
addTreeNode(WANPPPConnection, "SubnetMask",  TSTRING,  RD_ONLY,    "16","")
addTreeNode(WANPPPConnection, "X_ATP_MaxMTUSize",    TUINT, RW_BOTH,   "0","1492")
addTreeNode(WANPPPConnection, "DNSEnabled",  TBOOL, RW_BOTH,  "0","1")
addTreeNode(WANPPPConnection, "DNSServers",  TSTRING, RW_BOTH,   "64","")
addTreeNode(WANPPPConnection, "MACAddress",  TSTRING, RW_BOTH,   "32","")
addTreeNode(WANPPPConnection, "ConnectionTrigger",   TSTRING, RW_BOTH,   "16","")

addTreeNode(WANPPPConnection, "X_ATP_IPv4Enable",    TBOOL, RW_BOTH,  "0","1")
addTreeNode(WANPPPConnection, "X_ATP_IPv6Enable",    TBOOL, RW_BOTH,  "0","0")
addTreeNode(WANPPPConnection, "X_ATP_IPv6ConnectionStatus",  TSTRING , RD_ONLY,    "32","")
addTreeNode(WANPPPConnection, "X_ATP_IPv6AddressingType",    TSTRING, RW_BOTH,   "8","SLAAC")
addTreeNode(WANPPPConnection, "X_ATP_IPv6PrefixList",   TSTRING, RD_ONLY, "128" ,  "")
addTreeNode(WANPPPConnection, "X_ATP_IPv6DefaultGateway",    TSTRING, RW_BOTH,   "64","")
addTreeNode(WANPPPConnection, "X_ATP_IPv6DNSEnabled",    TBOOL, RW_BOTH,  "0","1")
addTreeNode(WANPPPConnection, "X_ATP_IPv6DNSServers",    TSTRING, RW_BOTH,   "128" ,  "")
addTreeNode(WANPPPConnection, "X_ATP_IPv6Address",   TSTRING, RW_BOTH,   "64","")
addTreeNode(WANPPPConnection, "X_ATP_IPv6PrefixLength",  TUINT, RW_BOTH,   "0","0")
addTreeNode(WANPPPConnection, "X_ATP_TotalConnectTime",  TUINT, RD_ONLY,   "0","0")

addTreeNode(WANPPPConnection, "PortMappingNumberOfEntries",  TUINT, RD_ONLY,   "0","0")
WANPPP_PortMapping = newTreeObject("PortMapping", RW_BOTH)  
addTreeNode(WANPPP_PortMapping, "Enabled",  TBOOL, RW_BOTH,  "0","0")
addTreeNode(WANPPP_PortMapping, "ExternalPort",    TUINT, RW_BOTH,   "0","0")
addTreeNode(WANPPP_PortMapping, "ExternalPortEndRange",    TUINT, RW_BOTH,   "0","0")
addTreeNode(WANPPP_PortMapping, "InternalPort",    TUINT, RW_BOTH,   "0","0")
addTreeNode(WANPPP_PortMapping, "InternalPortEndRange",    TUINT, RW_BOTH,   "0","0")
addTreeNode(WANPPP_PortMapping, "Protocol",     TSTRING, RW_BOTH,   "16","TCP/UDP")
addTreeNode(WANPPP_PortMapping, "InternalClient",  TSTRING, RW_BOTH,   "256" ,  "")
addTreeNode(WANPPP_PortMapping, "Description",  TSTRING, RW_BOTH,   "128" ,  "")
WANPPPConnection:addChild(WANPPP_PortMapping)

X_ATP_DMZ = newTreeObject("X_ATP_DMZ", RD_ONLY)  
addTreeNode(X_ATP_DMZ, "DMZEnable",    TBOOL, RW_BOTH,  "0","0")
addTreeNode(X_ATP_DMZ, "DMZHostIPAddress", TSTRING, RW_BOTH,   "16","")
WANPPPConnection:addChild(X_ATP_DMZ)
WANConnectionDevice:addChild(WANPPPConnection)

WANIPConnection = newTreeObject("WANIPConnection", RD_ONLY)  
addTreeNode(WANIPConnection, "Enable",  TBOOL, RW_BOTH,  "0","0")
addTreeNode(WANIPConnection, "ConnectionStatus",    TSTRING, RW_BOTH,   "32","")
addTreeNode(WANIPConnection, "ConnectionType",  TSTRING, RW_BOTH,   "16","IP_Routed")
addTreeNode(WANIPConnection, "Name",   TSTRING, RD_ONLY, "256",   "")
addTreeNode(WANIPConnection, "LastConnectionError", TSTRING  ,RD_ONLY,    "64","ERROR_NONE")
addTreeNode(WANIPConnection, "AddressingType",  TSTRING, RW_BOTH,   "8","")
addTreeNode(WANIPConnection, "ExternalIPAddress",   TSTRING, RW_BOTH,   "16","")
addTreeNode(WANIPConnection, "SubnetMask",  TSTRING, RW_BOTH,   "16","")
addTreeNode(WANIPConnection, "DefaultGateway",  TSTRING, RW_BOTH,   "16","")
addTreeNode(WANIPConnection, "DNSEnabled",  TBOOL, RW_BOTH,  "0","1")
addTreeNode(WANIPConnection, "DNSServers",  TSTRING, RW_BOTH,   "64","")
addTreeNode(WANIPConnection, "MaxMTUSize",  TUINT, RW_BOTH,   "0","1500")
addTreeNode(WANIPConnection, "X_ATP_WANDHCPOption60",   TSTRING, RW_BOTH,   "64","")
addTreeNode(WANIPConnection, "ConnectionTrigger",   TSTRING, RW_BOTH,   "16","AlwaysOn")
addTreeNode(WANIPConnection, "PortMappingNumberOfEntries",  TUINT, RD_ONLY,   "0","0")
addTreeNode(WANIPConnection, "X_ATP_IPv4Enable",    TBOOL, RW_BOTH,  "0","1")
addTreeNode(WANIPConnection, "X_ATP_IPv6Enable",    TBOOL, RW_BOTH,  "0","0")
addTreeNode(WANIPConnection, "X_ATP_IPv6ConnectionStatus",   TSTRING, RD_ONLY, "32","")
addTreeNode(WANIPConnection, "X_ATP_IPv6AddressingType",    TSTRING, RW_BOTH,   "8","SLAAC")
addTreeNode(WANIPConnection, "X_ATP_IPv6PrefixList",   TSTRING, RD_ONLY, "128",   "")
addTreeNode(WANIPConnection, "X_ATP_IPv6DefaultGateway",    TSTRING, RW_BOTH,   "64","")
addTreeNode(WANIPConnection, "X_ATP_IPv6DNSEnabled",    TBOOL, RW_BOTH,  "0","1")
addTreeNode(WANIPConnection, "X_ATP_IPv6DNSServers",    TSTRING, RW_BOTH,   "128",   "")
addTreeNode(WANIPConnection, "X_ATP_IPv6Address",   TSTRING, RW_BOTH,   "128",   "")
addTreeNode(WANIPConnection, "X_ATP_IPv6PrefixLength",  TUINT, RW_BOTH,   "0","0")

WANIP_PortMapping = newTreeObject("PortMapping", RW_BOTH)  
addTreeNode(WANIP_PortMapping, "Enabled",  TBOOL, RW_BOTH,  "0","0")
addTreeNode(WANIP_PortMapping, "ExternalPort",    TUINT, RW_BOTH,   "0","0")
addTreeNode(WANIP_PortMapping, "ExternalPortEndRange",    TUINT, RW_BOTH,   "0","0")
addTreeNode(WANIP_PortMapping, "InternalPort",    TUINT, RW_BOTH,   "0","0")
addTreeNode(WANIP_PortMapping, "InternalPortEndRange",    TUINT, RW_BOTH,   "0","0")
addTreeNode(WANIP_PortMapping, "Protocol", TSTRING, RW_BOTH,   "16","TCP/UDP")
addTreeNode(WANIP_PortMapping, "InternalClient",  TSTRING, RW_BOTH,   "256",   "")
addTreeNode(WANIP_PortMapping, "Description",  TSTRING, RW_BOTH,   "128",   "")
WANIPConnection:addChild(WANIP_PortMapping)

WANConnectionDevice:addChild(WANIPConnection)
WANDevice:addChild(WANConnectionDevice)

InternetGatewayDevice:addChild(WANDevice)

Layer2Bridging = newTreeObject("Layer2Bridging", RD_ONLY)
Bridge = newTreeObject("Bridge", RD_ONLY) 
addTreeNode(Bridge, "X_ATP_DNSMode", TUINT, RW_BOTH,   "0","0" )
Layer2Bridging:addChild(Bridge)

InternetGatewayDevice:addChild(Layer2Bridging)


Services = newTreeObject("Services", RD_ONLY)  


X_ATP_NetworkSetting = newTreeObject("X_ATP_NetworkSetting", RD_ONLY)  
addTreeNode(X_ATP_NetworkSetting, "NetworkPriority", TSTRING, RW_BOTH,   "64","")
Services:addChild(X_ATP_NetworkSetting)



VoiceService = newTreeObject("VoiceService", RD_ONLY)  
addTreeNode(VoiceService, "VoiceProfileNumberOfEntries", TUINT, RD_ONLY,   "0","0")
addTreeNode(VoiceService, "X_ATP_UmtsEnable",    TBOOL, RW_BOTH,  "0","1")
addTreeNode(VoiceService, "X_ATP_UmtsClipEnable",    TBOOL, RW_BOTH,  "0","0")
addTreeNode(VoiceService, "X_ATP_UmtsNumber",    TSTRING, RW_BOTH,   "32","")
addTreeNode(VoiceService, "X_ATP_VoipEnable",    TBOOL, RW_BOTH,  "0","1")


PhyInterface = newTreeObject("PhyInterface", RD_ONLY)  
addTreeNode(PhyInterface, "PhyPort",   TSTRING, RD_ONLY, "2","")
addTreeNode(PhyInterface, "InterfaceID",    TUINT, RD_ONLY,   "0","0")
addTreeNode(PhyInterface, "X_ATP_InCallNumber", TSTRING, RW_BOTH,   "32","")
addTreeNode(PhyInterface, "X_ATP_IncomingLineList", TSTRING, RW_BOTH,   "1024"  "all")
addTreeNode(PhyInterface, "X_ATP_OutgoingLineList", TSTRING, RW_BOTH,   "1024"  "auto")
addTreeNode(PhyInterface, "X_ATP_Name", TSTRING, RW_BOTH,   "32","")
addTreeNode(PhyInterface, "X_ATP_CFUDestPortId",    TINT, RW_BOTH,   "0","-1")
addTreeNode(PhyInterface, "X_ATP_CFBDestPortId",   TINT, RW_BOTH,   "0","-1")
addTreeNode(PhyInterface, "X_ATP_CFNRDestPortId",   TINT,RW_BOTH,   "0","-1")
VoiceService:addChild(PhyInterface)


 
VoiceProfile = newTreeObject("VoiceProfile", RD_ONLY)  
addTreeNode(VoiceProfile, "Enable", TSTRING, RW_BOTH,   "8","Disabled")
addTreeNode(VoiceProfile, "NumberOfLines",  TUINT, RD_ONLY,   "0","0")
addTreeNode(VoiceProfile, "Name",   TSTRING, RW_BOTH,   "64","")
addTreeNode(VoiceProfile, "Region", TSTRING, RW_BOTH,   "2","DE")
addTreeNode(VoiceProfile, "DigitMap",   TSTRING, RW_BOTH,   "512"   "[X*#ABCD].T")
addTreeNode(VoiceProfile, "STUNServer", TSTRING, RW_BOTH,   "256"   "")
addTreeNode(VoiceProfile, "X_ATP_STUNServerPort",   TSTRING, RW_BOTH,   "256"   "3478")
addTreeNode(VoiceProfile, "X_ATP_EnableSharpKey",   TBOOL, RW_BOTH,  "0","1")
addTreeNode(VoiceProfile, "X_ATP_HotLineEnable",    TBOOL, RW_BOTH,  "0","0")
addTreeNode(VoiceProfile, "X_ATP_HotLineIntervalTime",  TUINT, RW_BOTH,   "0","9")
addTreeNode(VoiceProfile, "X_ATP_HotLineNumber",    TSTRING, RW_BOTH,   "64","")
addTreeNode(VoiceProfile, "X_ATP_OffHookTime",  TUINT, RW_BOTH,   "0","250")
addTreeNode(VoiceProfile, "X_ATP_OnHookTime",   TUINT, RW_BOTH,   "0","250")
addTreeNode(VoiceProfile, "X_ATP_MinHookFlash", TUINT, RW_BOTH,   "0","80")
addTreeNode(VoiceProfile, "X_ATP_MaxHookFlash", TUINT, RW_BOTH,   "0","250")
addTreeNode(VoiceProfile, "DTMFMethod", TSTRING, RW_BOTH,   "64","")


Line = newTreeObject("Line", RD_ONLY)
    addTreeNode(Line, "Enable",    TSTRING, RW_BOTH,   "8","Disabled")
    addTreeNode(Line, "DirectoryNumber",   TSTRING, RW_BOTH,   "32","")
    addTreeNode(Line, "Status",   TSTRING, RD_ONLY, "32","Unregistered")
    addTreeNode(Line, "CallState", TSTRING  RD_ONLY,    "32","Idle")
    addTreeNode(Line, "X_ATP_ClipEnable",  TBOOL, RW_BOTH,  "0","1")
    addTreeNode(Line, "X_ATP_FaxOption",   TSTRING, RW_BOTH,   "64","G711A")
    addTreeNode(Line, "X_ATP_FaxDetectType",   TUINT, RW_BOTH,   "0","1")
    addTreeNode(Line, "X_ATP_BusyOnBusy",  TBOOL, RW_BOTH,  "0","1")

    
    Codec = newTreeObject("Codec", RD_ONLY)  
    addTreeNode(Codec, "TransmitCodec ",   TSTRING, RD_ONLY, "64","")
    
    List = newTreeObject("List", RD_ONLY)  
    addTreeNode(List, "Codec",   TSTRING, RD_ONLY, "64","")
    addTreeNode(List, "Enable", TBOOL, RW_BOTH,  "0","1")
    addTreeNode(List, "PacketizationPeriod",    TSTRING, RW_BOTH,   "64","20")
    addTreeNode(List, "SilenceSuppression", TBOOL, RW_BOTH,  "0","0")
    addTreeNode(List, "Priority",   TUINT, RW_BOTH,   "0","1")
    Codec:addChild(List)
    Line:addChild(Codec)


           
    CallingFeatures = newTreeObject("CallingFeatures", RD_ONLY)  
    addTreeNode(CallingFeatures, "CallWaitingEnable", TBOOL, RW_BOTH,  "0","1")
    Line:addChild(CallingFeatures)

    SIP = newTreeObject("SIP", RD_ONLY) 
    addTreeNode(SIP, "AuthUserName",  TSTRING, RW_BOTH,   "128"   "")
    addTreeNode(SIP, "AuthPassword",  TSTRING, RW_BOTH,   "128"   "")
    addTreeNode(SIP, "URI",   TSTRING, RW_BOTH,   "389"   "")
    addTreeNode(SIP, "X_ATP_MWISubscribeURI", TSTRING, RW_BOTH,   "128"   "")
    addTreeNode(SIP, "X_ATP_AreaEnable",  TBOOL, RW_BOTH,  "0","0")
    addTreeNode(SIP, "X_ATP_AreaCode",    TSTRING, RW_BOTH,   "7","")
    addTreeNode(SIP, "X_ATP_SIPLocalPort",    TUINT, RW_BOTH,   "0","0")
    Line:addChild(SIP)    
    VoiceProfile:addChild(Line)


    NumberingPlan = newTreeObject("NumberingPlan", RD_ONLY) 
           
    addTreeNode(NumberingPlan, "InterDigitTimerShort", TUINT, RW_BOTH,   "0","3000")
    addTreeNode(NumberingPlan, "InterDigitTimerLong",  TUINT, RW_BOTH,   "0","10000")
    addTreeNode(NumberingPlan, "X_ATP_StartDigitTimerStd", TUINT, RW_BOTH,   "0","10000")
    addTreeNode(NumberingPlan, "X_ATP_UnResponseInterval", TUINT, RW_BOTH,   "0","60000")
    addTreeNode(NumberingPlan, "X_ATP_HowlToneTime",   TUINT, RW_BOTH,   "0","60000")
    addTreeNode(NumberingPlan, "X_ATP_BusyToneTime",   TUINT, RW_BOTH,   "0","40000")
    addTreeNode(NumberingPlan, "X_ATP_EmergencyRoute", TUINT, RW_BOTH,   "0","1")
    addTreeNode(NumberingPlan, "X_ATP_EmergencyRouteAccount",  TSTRING, RW_BOTH,   "32","")

    NumberingPlan = newTreeObject("X_ATP_OutgoingSuffixInfo", RD_ONLY) 
    addTreeNode(X_ATP_OutgoingSuffixInfo, "SuffixRange", TSTRING, RW_BOTH,   "42","")
    addTreeNode(X_ATP_OutgoingSuffixInfo, "SuffixAssociateNumber",   TSTRING, RW_BOTH,   "40","")
    NumberingPlan:addChild(X_ATP_OutgoingSuffixInfo)
    VoiceProfile:addChild(NumberingPlan)

    
    RTP =newTreeObject("RTP", RD_ONLY)  
    addTreeNode(RTP.LocalPortMin   TUINT, RW_BOTH,   "0","50000")
    addTreeNode(RTP.LocalPortMax   TUINT, RW_BOTH,   "0","50020")
    addTreeNode(RTP.X_ATP_JitterBuffer TBOOL, RW_BOTH,  "0","1")
    addTreeNode(RTP.X_ATP_JitterBufferLength   TUINT, RW_BOTH,   "0","20")
    addTreeNode(RTP.X_ATP_PackLostCompensate   TBOOL, RW_BOTH,  "0","1")
    addTreeNode(RTP.X_ATP_JitterBufferType TUINT, RW_BOTH,   "0","1")
    
    RTCP = newTreeObject("RTCP", RD_ONLY)  
    addTreeNode(Services.VoiceService.VoiceProfile.RTP.RTCP.TxRepeatInterval  TUINT, RW_BOTH,   "0","3000")
    TxRepeatInterval = Node.new("TxRepeatInterval", RD_ONLY)  
    RTCP:addChild(TxRepeatInterval)

    RTP:addChild(RTCP)
    VoiceProfile:addChild(RTP)


SIP = Node.new("SIP", RD_ONLY)  
VoiceProfile:addChild(SIP)

Services.VoiceService.VoiceProfile.SIP.ProxyServer    TSTRING, RW_BOTH,   "256"   ""
Services.VoiceService.VoiceProfile.SIP.ProxyServerPort    TSTRING, RW_BOTH,   "256"   "5060"
Services.VoiceService.VoiceProfile.SIP.RegistrarServer    TSTRING, RW_BOTH,   "256"   ""
Services.VoiceService.VoiceProfile.SIP.RegistrarServerPort    TSTRING, RW_BOTH,   "256"   "5060"
Services.VoiceService.VoiceProfile.SIP.X_ATP_SIPDomain    TSTRING, RW_BOTH,   "256"   ""
Services.VoiceService.VoiceProfile.SIP.X_ATP_SecondServerSwitch   TBOOL, RW_BOTH,  "0","0"
Services.VoiceService.VoiceProfile.SIP.X_ATP_SecondProxyServer    TSTRING, RW_BOTH,   "256"   ""
Services.VoiceService.VoiceProfile.SIP.X_ATP_SecondProxyServerPort    TSTRING, RW_BOTH,   "256"   "5060"
Services.VoiceService.VoiceProfile.SIP.X_ATP_SecondSIPDomain  TSTRING, RW_BOTH,   "256"   ""
Services.VoiceService.VoiceProfile.SIP.UserAgentPort  TSTRING, RW_BOTH,   "256"   "6050"
Services.VoiceService.VoiceProfile.SIP.X_ATP_SecondRegistrarServer    TSTRING, RW_BOTH,   "256"   ""
Services.VoiceService.VoiceProfile.SIP.X_ATP_SecondRegistrarServerPort    TSTRING, RW_BOTH,   "256"   "5060"
Services.VoiceService.VoiceProfile.SIP.OutboundProxy  TSTRING, RW_BOTH,   "256"   ""
Services.VoiceService.VoiceProfile.SIP.OutboundProxyPort  TSTRING, RW_BOTH,   "256"   "5060"
Services.VoiceService.VoiceProfile.SIP.RegisterExpires    TUINT, RW_BOTH,   "0","300"
Services.VoiceService.VoiceProfile.SIP.RegisterRetryInterval  TUINT, RW_BOTH,   "0","900"
Services.VoiceService.VoiceProfile.SIP.X_ATP_PrackSupport TBOOL, RW_BOTH,  "0","0"
Services.VoiceService.VoiceProfile.SIP.X_ATP_UrgencyUsePriority   TBOOL, RW_BOTH,  "0","1"
Services.VoiceService.VoiceProfile.SIP.X_ATP_SessionExpires   TUINT, RW_BOTH,   "0","3600"
Services.VoiceService.VoiceProfile.SIP.X_ATP_MinSessionExpires    TUINT, RW_BOTH,   "0","90"
Services.VoiceService.VoiceProfile.SIP.X_ATP_HoldMethod   TUINT, RW_BOTH,   "0","0"
Services.VoiceService.VoiceProfile.SIP.X_ATP_InterfaceName  ",   TSTRING, RD_ONLY, "128"   ""

VoiceService:addChild(VoiceProfile)
Services:addChild(VoiceService)

--================================================
Services.X_ATP_ALGAbility object  RD_ONLY        
X_ATP_ALGAbility = Node.new("X_ATP_ALGAbility", RD_ONLY)  
Services:addChild(X_ATP_ALGAbility)

Services.X_ATP_ALGAbility.SIPEnable   TBOOL, RW_BOTH,  "0","0"
Services.X_ATP_ALGAbility.SIPPort TUINT, RW_BOTH,   "0","5060"
Services.X_ATP_Dialup object  RD_ONLY        
X_ATP_Dialup = Node.new("X_ATP_Dialup", RD_ONLY)  
Services:addChild(X_ATP_Dialup)

Services.X_ATP_Dialup.InternetProfileList object  RW_BOTH       
Services.X_ATP_Dialup.InternetProfileList.profile_name  ",   TSTRING, RD_ONLY, "20",""
Services.X_ATP_Dialup.InternetProfileList.apn TSTRING  RD_ONLY    "100"   ""
Services.X_ATP_Dialup.InternetProfileList.username  ",   TSTRING, RD_ONLY, "128"   ""
Services.X_ATP_Dialup.InternetProfileList.auth_mode   TUINT, RD_ONLY,   "0","0"
Services.X_ATP_Dialup.InternetProfileList.ip_type TUINT, RD_ONLY,   "0","0"
Services.X_ATP_Dialup.VOIPAPN object  RD_ONLY        
VOIPAPN = Node.new("VOIPAPN", RD_ONLY)  
X_ATP_Dialup:addChild(VOIPAPN)

Services.X_ATP_Dialup.VOIPAPN.profile_name  ",   TSTRING, RD_ONLY, "20",""
Services.X_ATP_Dialup.VOIPAPN.apn TSTRING, RW_BOTH,   "100"   ""
Services.X_ATP_Dialup.VOIPAPN.username    TSTRING, RW_BOTH,   "128"   ""
Services.X_ATP_Dialup.VOIPAPN.password    TSTRING, RW_BOTH,   "128"   ""
Services.X_ATP_Dialup.VOIPAPN.auth_mode   TUINT, RW_BOTH,   "0","0"
Services.X_ATP_Dialup.VOIPAPN.ip_type TUINT, RW_BOTH,   "0","0"
Services.X_ATP_Dialup.InternetAPN object  RD_ONLY        
InternetAPN = Node.new("InternetAPN", RD_ONLY)  
X_ATP_Dialup:addChild(InternetAPN)


Services.X_ATP_Dialup.InternetAPN.profile_name  ",   TSTRING, RD_ONLY, "20",""
Services.X_ATP_Dialup.InternetAPN.apn TSTRING, RW_BOTH,   "100"   ""
Services.X_ATP_Dialup.InternetAPN.username    TSTRING, RW_BOTH,   "128"   ""
Services.X_ATP_Dialup.InternetAPN.password    TSTRING, RW_BOTH,   "128"   ""
Services.X_ATP_Dialup.InternetAPN.auth_mode   TUINT, RW_BOTH,   "0","0"
Services.X_ATP_Dialup.InternetAPN.ip_type TUINT, RW_BOTH,   "0","0"
Services.ReAttach object  RD_ONLY        
ReAttach = Node.new("ReAttach", RD_ONLY)  
Services:addChild(ReAttach)

Services.ReAttach.EnableReAttach  TUINT, RW_BOTH,   "0","0"
Services.X_ATP_EthernetInterfaceNegotiation   object  RD_ONLY        
X_ATP_EthernetInterfaceNegotiation = Node.new("X_ATP_EthernetInterfaceNegotiation", RD_ONLY)  
Services:addChild(X_ATP_EthernetInterfaceNegotiation)

Services.X_ATP_EthernetInterfaceNegotiation.Status    TBOOL RD_ONLY    "0","0"
Services.X_ATP_EthernetInterfaceNegotiation.PortName",   TSTRING, RD_ONLY, "16",""
Services.X_ATP_EthernetInterfaceNegotiation.NegotiationResult TUINT, RD_ONLY,   "0","0"

InternetGatewayDevice:addChild(Services)

--===================

X_ATP_VPN object  RD_ONLY        
X_ATP_VPN = Node.new("X_ATP_VPN", RD_ONLY)  
InternetGatewayDevice:addChild(X_ATP_VPN)


X_ATP_VPN.L2TP_LAC    object  RD_ONLY        
L2TP_LAC = Node.new("L2TP_LAC", RD_ONLY)  
X_ATP_VPN:addChild(L2TP_LAC)

X_ATP_VPN.L2TP_LAC.HostName   TSTRING, RW_BOTH,   "64","HGW"
X_ATP_VPN.L2TP_LAC.PassWord   TSTRING, RW_BOTH,   "64",""
X_ATP_VPN.L2TP_LAC.Enable TBOOL, RW_BOTH,  "0","0"
X_ATP_VPN.L2TP_LAC.LNSAddress TSTRING, RW_BOTH,   "256"   ""
X_ATP_VPN.L2TP_LAC.PCAuthMode TUINT, RW_BOTH,   "0","0"
X_ATP_VPN.L2TP_LAC.PppUser    TSTRING, RW_BOTH,   "64",""
X_ATP_VPN.L2TP_LAC.PppPass    TSTRING, RW_BOTH,   "64",""
X_ATP_VPN.L2TP_LAC.ConnectionStatus ",   TSTRING, RD_ONLY, "32",""
X_ATP_VPN.L2TP_LAC.KeepAliveTime  TUINT, RW_BOTH,   "0","60"
X_ATP_VPN.PPTP_LAC    object  RD_ONLY        
PPTP_LAC = Node.new("PPTP_LAC", RD_ONLY)  
X_ATP_VPN:addChild(PPTP_LAC)

X_ATP_VPN.PPTP_LAC.Enable TBOOL, RW_BOTH,  "0","0"
X_ATP_VPN.PPTP_LAC.ServerAddress  TSTRING, RW_BOTH,   "256"   ""
X_ATP_VPN.PPTP_LAC.PppUsername    TSTRING, RW_BOTH,   "64",""
X_ATP_VPN.PPTP_LAC.PppPassword    TSTRING, RW_BOTH,   "64",""
X_ATP_VPN.PPTP_LAC.PrimaryDNSServer   TSTRING, RW_BOTH,   "32",""
X_ATP_VPN.PPTP_LAC.SecondaryDNSServer TSTRING, RW_BOTH,   "32",""
X_ATP_VPN.PPTP_LAC.ConnectionStatus ",   TSTRING, RD_ONLY, "32",""
X_ATP_FireWall    object  RW_BOTH       
X_ATP_FireWall = Node.new("X_ATP_FireWall", RD_ONLY)  
InternetGatewayDevice:addChild(X_ATP_FireWall)


X_ATP_FireWall.Switch object  RD_ONLY        
Switch = Node.new("Switch", RD_ONLY)  
X_ATP_FireWall:addChild(Switch)


X_ATP_FireWall.Switch.FirewallMainSwitch  TUINT, RW_BOTH,   "0","1"
X_ATP_FireWall.Switch.FirewallIPFilterSwitch  TUINT, RW_BOTH,   "0","0"
X_ATP_FireWall.Switch.FirewallWanPortPingSwitch   TUINT, RW_BOTH,   "0","1"
X_ATP_FireWall.Switch.firewallmacfilterswitch TUINT, RW_BOTH,   "0","0"
X_ATP_FireWall.Switch.firewallurlfilterswitch TUINT, RW_BOTH,   "0","0"
X_ATP_FireWall.CustUrlFilter  object  RW_BOTH       
CustUrlFilter = Node.new("CustUrlFilter", RD_ONLY)  
X_ATP_FireWall:addChild(CustUrlFilter)

X_ATP_FireWall.CustUrlFilter.BlackListNumberOfEntries TUINT, RW_BOTH,   "0","0"
X_ATP_FireWall.CustUrlFilter.WhiteListNumberOfEntries TUINT, RW_BOTH,   "0","0"
X_ATP_FireWall.CustUrlFilter.CurrentMode  TUINT, RW_BOTH,   "0","0"
X_ATP_FireWall.CustUrlFilter.WhiteList    object  RW_BOTH       
WhiteList = Node.new("WhiteList", RD_ONLY)  
CustUrlFilter:addChild(WhiteList)

X_ATP_FireWall.CustUrlFilter.WhiteList.Url    TSTRING, RW_BOTH,   "32",""
X_ATP_FireWall.CustUrlFilter.WhiteList.Status TUINT, RW_BOTH,   "0","0"
X_ATP_FireWall.CustUrlFilter.BlackList    object  RW_BOTH       
BlackList = Node.new("BlackList", RD_ONLY)  
CustUrlFilter:addChild(BlackList)

X_ATP_FireWall.CustUrlFilter.BlackList.Url    TSTRING, RW_BOTH,   "32",""
X_ATP_FireWall.CustUrlFilter.BlackList.Status TUINT, RW_BOTH,   "0","0"
X_ATP_Config  object  RD_ONLY        
X_ATP_Config = Node.new("X_ATP_Config", RD_ONLY)  
InternetGatewayDevice:addChild(X_ATP_Config)

X_ATP_Config.sms  object  RD_ONLY        
X_ATP_Config.sms.center_number    TSTRING, RW_BOTH,   "128"   "0"
X_ATP_Config.net  object  RD_ONLY        
X_ATP_Config.X_ATP_App    object  RD_ONLY        
X_ATP_Config.UtExtend object  RW_BOTH       
X_ATP_Config.UtExtend.SsconfHideMediaTag  TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfUserAgentWith3gppGba    int RW_BOTH   "0","2"
X_ATP_Config.UtExtend.MulfBsfAcceptEncodingXml    TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfDeleteNafAcceptEncoding TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfSuptTcpFin  TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfAddNsRuleset    TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfGetExcludeEtag  TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfReqUriExlcudeRulesetNode    TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfDeactiveNotSetAllow TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfUriType int RW_BOTH   "0","0"
X_ATP_Config.UtExtend.MutfPutMsgWithRuleset   TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfParamCfgSbm int RW_BOTH   "0","0"
X_ATP_Config.UtExtend.MutfUseTlsVersion   int RW_BOTH   "0","1"
X_ATP_Config.UtExtend.MutfPutExcludeEtag  TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfAuthRealmSameAsDomain   TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfAuthUriSameAsReqUri TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfCbAddMedia  TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfSuptIr92V10NoReplyTimer TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfSuptIr92VxNoRuleNotAllowPut TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfDerectlyAddAuthorizationInGbaPeriod TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfOnlyConditionsCapParam  TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfAlwaysAccessFragmentXml TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfDelNamespaceInBodyMessage   TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtExtend.MutfUserAgentGbaInComment   TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtCommon object  RW_BOTH       
UtCommon = Node.new("UtCommon", RD_ONLY)  
X_ATP_Config:addChild(UtCommon)

X_ATP_Config.UtCommon.HwUtIms TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtCommon.NafPort TUINT, RW_BOTH,   "0","80"
X_ATP_Config.UtCommon.NafSrvAddr  TSTRING, RW_BOTH,   "256"   ""
X_ATP_Config.UtCommon.NafUseHttps TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtCommon.BsfPort TUINT, RW_BOTH,   "0","8080"
X_ATP_Config.UtCommon.BsfSrvAddr  TSTRING, RW_BOTH,   "256"   ""
X_ATP_Config.UtCommon.BsfUseHttps TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtCommon.AuthUserName    TSTRING, RW_BOTH,   "256"   ""
X_ATP_Config.UtCommon.LocalUserName   TSTRING, RW_BOTH,   "256"   ""
X_ATP_Config.UtCommon.UseXcapNameSpace    TBOOL, RW_BOTH,  "0","1"
X_ATP_Config.UtCommon.UseNodeSelector TBOOL, RW_BOTH,  "0","1"
X_ATP_Config.UtCommon.UseTmpi TBOOL, RW_BOTH,  "0","0"
X_ATP_Config.UtCommon.KsnafBase64 TBOOL, RW_BOTH,  "0","1"
X_ATP_Config.UtCommon.X3gppIntendId   TSTRING, RW_BOTH,   "256"   ""
X_ATP_Config.UtCommon.GbaType TUINT, RW_BOTH,   "0","0"
X_ATP_Config.UtCommon.RootCaPath  TSTRING, RW_BOTH,   "256"   ""
X_ATP_Config.UtCommon.LibPath TSTRING, RW_BOTH,   "256"   ""
X_ATP_Config.UtCommon.HrsLog  TUINT, RW_BOTH,   "0","0"
X_ATP_Config.UtCommon.XcapRootUri TSTRING, RW_BOTH,   "256"   ""
X_ATP_Config.statistic    object  RW_BOTH       
statistic = Node.new("statistic", RD_ONLY)  
X_ATP_Config:addChild(statistic)

X_ATP_Config.statistic.current_month_down TSTRING  RD_ONLY    "32","0"
X_ATP_Config.statistic.current_month_up ",   TSTRING, RD_ONLY, "32","0"
X_ATP_Config.statistic.month_duration TSTRING  RD_ONLY    "32","0"
X_ATP_Config.statistic.month_last_clear_time",   TSTRING, RD_ONLY, "32","0"
Layer3Forwarding  object  RD_ONLY        
Layer3Forwarding = Node.new("Layer3Forwarding", RD_ONLY)  
InternetGatewayDevice:addChild(Layer3Forwarding)

Layer3Forwarding.DefaultConnectionService TSTRING, RW_BOTH,   "256"   ""
Layer3Forwarding.ForwardNumberOfEntries   TUINT, RD_ONLY,   "0","0"
Layer3Forwarding.X_ATP_IPv6Forwarding object  RW_BOTH       
X_ATP_IPv6Forwarding = Node.new("X_ATP_IPv6Forwarding", RD_ONLY)  
Layer3Forwarding:addChild(X_ATP_IPv6Forwarding)

Layer3Forwarding.X_ATP_IPv6Forwarding.DestIPAddress   TSTRING, RW_BOTH,   "64",""
Layer3Forwarding.X_ATP_IPv6Forwarding.PrefixLength    TUINT, RW_BOTH,   "0","128"
Layer3Forwarding.X_ATP_IPv6Forwarding.GatewayIPAddress    TSTRING, RW_BOTH,   "64",""
Layer3Forwarding.X_ATP_IPv6Forwarding.Interface   TSTRING, RW_BOTH,   "256"   ""
Layer3Forwarding.Forwarding   object  RW_BOTH       
Forwarding = Node.new("Forwarding", RD_ONLY)  
Layer3Forwarding:addChild(Forwarding)

Layer3Forwarding.Forwarding.DestIPAddress TSTRING, RW_BOTH,   "16",""
Layer3Forwarding.Forwarding.DestSubnetMask    TSTRING, RW_BOTH,   "16",""
Layer3Forwarding.Forwarding.GatewayIPAddress  TSTRING, RW_BOTH,   "16",""
Layer3Forwarding.Forwarding.Interface TSTRING, RW_BOTH,   "256"   ""
X_ATP_HotaUpg object  RD_ONLY        
X_ATP_HotaUpg = Node.new("X_ATP_HotaUpg", RD_ONLY)  
InternetGatewayDevice:addChild(X_ATP_HotaUpg)

X_ATP_HotaUpg.HotaServiceEnable   TBOOL, RW_BOTH,  "0","0"
X_ATP_AtpMonitor  object  RW_BOTH       
X_ATP_AtpMonitor = Node.new("X_ATP_AtpMonitor", RD_ONLY)  
InternetGatewayDevice:addChild(X_ATP_AtpMonitor)

X_ATP_AtpMonitor.FileSizeMonitor  object  RW_BOTH       
FileSizeMonitor = Node.new("FileSizeMonitor", RD_ONLY)  
X_ATP_AtpMonitor:addChild(FileSizeMonitor)

X_ATP_AtpMonitor.FileSizeMonitor.TimerPeriod  TUINT, RW_BOTH,   "0","0"
X_ATP_AtpMonitor.FileSizeMonitor.FileThreshold    TUINT, RW_BOTH,   "0","0"
X_ATP_AtpMonitor.FileSizeMonitor.TotalThreshold   TUINT, RW_BOTH,   "0","0"
X_ATP_AtpMonitor.ProcessMemMonitor    object  RW_BOTH       
ProcessMemMonitor = Node.new("ProcessMemMonitor", RD_ONLY)  
X_ATP_AtpMonitor:addChild(ProcessMemMonitor)

X_ATP_AtpMonitor.ProcessMemMonitor.TimerPeriod    TUINT, RW_BOTH,   "0","0"
X_ATP_AtpMonitor.ProcessMemMonitor.ProcessMemThreshold    TSTRING, RW_BOTH,   "1024"  ""
X_ATP_AtpMonitor.ProcessMemMonitor.FreeThreshold  TUINT, RW_BOTH,   "0","0"
]]
---===================================

printTree(InternetGatewayDevice)