local json = loadfile("./json.lua")()


TOBJECT = 1
TUINT = 2
TINT = 3
TBOOL = 4
TSTRING = 5
TDATETIME = 5

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
        return { self.name }
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
        self.paramters[name] = { writable, value, "xsd:TSTRING" }
    else
        self.paramters[name] = { writable, value, type }
    end
end

function Node:getParamterValue(name)
    return json.encode({
        parameter = self.name .. "." .. name,
        value = self.paramters[name][2]
    })
end

function Node:getParamterValueJson(childNode, paramName)
    path = table.concat(self:getPath(childNode), ".") .. "." .. paramName

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
            type = childNode.paramters[paramName][PARAM_TYPE]
        })
    end
end

function Node:getParamterNameJson(childNode, paramName)
    path = table.concat(self:getPath(childNode), ".") .. "." .. paramName
    return json.encode({
        parameter = path,
        writable = childNode.paramters[paramName][PARAM_WRITABLE]
    })
end

function Node:getNodeNameJson(childNode)
    if (childNode == nil) then

    end
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
    v = Node.new(name, type, RW_BOTH, maxLen, defValue)
    node:addChild(v)
end

function newTreeObject(name, RW_BOTH)
    return Node.new(name, TOBJECT, RW_BOTH)
end

--==========================================================
InternetGatewayDevice = newTreeObject("InternetGatewayDevice", RD_ONLY)

addTreeNode(InternetGatewayDevice, "DeviceSummary", TSTRING, RD_ONLY, "1024",
        "InternetGatewayDevice:1.1[](Baseline:1, EthernetLAN:1, WiFiLAN:1, ADSLWAN:1, EthernetWAN:1, QoS:1, Bridging:1, Time:1, IPPing:1, DeviceAssociation:1, UDPConnReq:1, Download:1, DownloadTCP:1, Upload:1, UploadTCP:1, UDPEcho:1, UDPEchoPlus:1), VoiceService:1.0[](Endpoint:1, SIPEndpoint:1, TAEndpoint:1)")

addTreeNode(InternetGatewayDevice, "LANDeviceNumberOfEntries", TUINT, RD_ONLY, "0", "1")
addTreeNode(InternetGatewayDevice, "WANDeviceNumberOfEntries", TUINT, RD_ONLY, "0", "4")

function init_Capabilities()
    Capabilities = newTreeObject("Capabilities", RD_ONLY)

    PerformanceDiagnostic = newTreeObject("PerformanceDiagnostic", RD_ONLY)
    addTreeNode(PerformanceDiagnostic, "DownloadTransports", TUINT, RD_ONLY, "0", "1")
    addTreeNode(PerformanceDiagnostic, "UploadTransports", TUINT, RD_ONLY, "0", "1")
    Capabilities:addChild(PerformanceDiagnostic)

    InternetGatewayDevice:addChild(Capabilities)
end

function init_DeviceInfo()
    DeviceInfo = newTreeObject("DeviceInfo", RD_ONLY)

    addTreeNode(DeviceInfo, "Manufacturer", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "ManufacturerOUI", TSTRING, RD_ONLY, "6", "")
    addTreeNode(DeviceInfo, "ModelName", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "Description", TSTRING, RD_ONLY, "256", "")
    addTreeNode(DeviceInfo, "ProductClass", TSTRING, RD_ONLY, "64", "")
    -- addTreeNode(DeviceInfo, "ProductType", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "SerialNumber", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "HardwareVersion", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "SoftwareVersion", TSTRING, RD_ONLY, "64", "")
    --addTreeNode(DeviceInfo, "HarmonyOSVersion", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "FirmwareVersion", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "ModemFirmwareVersion", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "EnabledOptions", TSTRING, RD_ONLY, "64", "")

    addTreeNode(DeviceInfo, "AdditionalHardwareVersion", TSTRING, RD_ONLY, "64", "")
    addTreeNode(DeviceInfo, "AdditionalSoftwareVersion", TSTRING, RD_ONLY, "64", "")
                            
    addTreeNode(DeviceInfo, "SpecVersion", TSTRING, RD_ONLY, "16", "")
    addTreeNode(DeviceInfo, "ProvisioningCode", TSTRING, RW_BOTH, "64", "")
    addTreeNode(DeviceInfo, "UpTime", TUINT, RD_ONLY, "0", "0")
    addTreeNode(DeviceInfo, "FirstUseDate", TUINT, RD_ONLY, "0", "0")

    addTreeNode(DeviceInfo, "DeviceLog", TSTRING, RD_ONLY, "32000", "")

    addTreeNode(DeviceInfo, "VendorConfigFileNumberOfEntries", TUINT, RD_ONLY, "32", "0")

    VendorConfigFile = newTreeObject("VendorConfigFile", RD_ONLY)
    --VendorConfigFile.{i}.
    -- Name
    -- Version
    -- Date
    -- Description
    DeviceInfo:addChild(VendorConfigFile)


--[[
    addTreeNode(DeviceInfo, "X_ATP_IconType", TSTRING, RD_ONLY, "32", "")
    addTreeNode(DeviceInfo, "X_ATP_LocalMac", "int", RW_BOTH, "0", "-1")

    X_ATP_Antenna = Node.new("X_ATP_Antenna", TOBJECT, RD_ONLY)
    DeviceInfo:addChild(X_ATP_Antenna)

    X_ATP_AdaptImage = newTreeObject("X_ATP_AdaptImage", RD_ONLY)
    addTreeNode(X_ATP_AdaptImage, "Band", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_AdaptImage, "WpsResetKeyShare", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_AdaptImage, "SoftShutDown", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_AdaptImage, "SmartHomeID", TSTRING, RD_ONLY, "8", "0000")
    addTreeNode(X_ATP_AdaptImage, "PowerKeyEnable", TBOOL, RD_ONLY, "0", "1")
    addTreeNode(X_ATP_AdaptImage, "HibrgDevAccessDeny", TBOOL, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_AdaptImage, "GigahomeType", TUINT, RD_ONLY, "0", "0")
    
    SpreadName = newTreeObject("SpreadName", RD_ONLY)
    addTreeNode(SpreadName, "Language", TUINT, RD_ONLY, "0", "0")
    addTreeNode(SpreadName, "Name", TSTRING, RD_ONLY, "64", "")
    X_ATP_AdaptImage:addChild(SpreadName)
]]
    DeviceInfo:addChild(X_ATP_AdaptImage)
    InternetGatewayDevice:addChild(DeviceInfo)
end

function init_DeviceConfig()
    DeviceConfig = newTreeObject("DeviceConfig", RD_ONLY)

    addTreeNode(DeviceConfig, "PersistentData", TBOOL, RW_BOTH, "0", "")
    addTreeNode(DeviceConfig, "ConfigFile", TSTRING, RD_ONLY, "32", "")

    InternetGatewayDevice:addChild(DeviceConfig)
end

function init_ManagementServer()
    ManagementServer = newTreeObject("ManagementServer", RD_ONLY)

    addTreeNode(ManagementServer, "EnableCWMP",  TBOOL, RW_BOTH, "0", "1")
    addTreeNode(ManagementServer, "URL", TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "Username", TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "Password", TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "PeriodicInformEnable",  TBOOL, RW_BOTH, "0", "0")
    addTreeNode(ManagementServer, "PeriodicInformInterval",  TBOOL, RW_BOTH, "0", "7200")
    addTreeNode(ManagementServer, "PeriodicInformTime", TDATETIME,  RW_BOTH, "0", "")
    addTreeNode(ManagementServer, "ParameterKey",TSTRING, RD_ONLY, "128", "")

    addTreeNode(ManagementServer, "ConnectionRequestURL", TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "ConnectionRequestUsername",TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "ConnectionRequestPassword",TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "UpgradesManaged", TBOOL, RD_ONLY, "128", "")

    addTreeNode(ManagementServer, "KickURL", TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "DownloadProgressURL", TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "DefaultActiveNotificationThrottle", TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "UDPConnectionRequestAddress", TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "UDPConnectionRequestAddressNotificationLimit", TUINT, RD_ONLY, "", "0")
    
    addTreeNode(ManagementServer, "STUNEnable", TBOOL, RD_ONLY, "0", "0")
    addTreeNode(ManagementServer, "STUNServerAddress",TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "STUNServerPort",TUINT, RD_ONLY, "", "0")
    addTreeNode(ManagementServer, "STUNUsername",TSTRING, RD_ONLY, "128", "")
    addTreeNode(ManagementServer, "STUNPassword",TSTRING, RD_ONLY, "128", "")

    addTreeNode(ManagementServer, "STUNMaximumKeepAlivePeriod",TUINT, RD_ONLY, "", "120")
    addTreeNode(ManagementServer, "STUNMinimumKeepAlivePeriod",TUINT, RD_ONLY, "", "60")
    addTreeNode(ManagementServer, "NATDetected", TBOOL, RD_ONLY, "0", "0")
    

    addTreeNode(ManagementServer, "ManageableDeviceNumberOfEntries", TUINT, RD_ONLY, "0", "0")
    addTreeNode(ManagementServer, "ManageableDeviceNotificationLimit", TUINT, RD_ONLY, "0", "0")


    --ManageableDevice.{i}
    -- ManufacturerOUI
    -- SerialNumber
    -- ProductClass
    -- Host

--[[
    addTreeNode(DeviceConfig, "ConnectionRequestAuth = 0, -- unsignedInt
    addTreeNode(DeviceConfig, "ConnectionRequestPort = 0,
    addTreeNode(DeviceConfig, "UDPConnectionRequestAddress = "",

    addTreeNode(DeviceConfig, "AliasBasedAddressing = false,     -- boolean
    addTreeNode(DeviceConfig, "CWMPRetryMinimumWaitInterval = 0, -- unsignedInt
    addTreeNode(DeviceConfig, "CWMPRetryIntervalMultiplier = 0,  -- unsignedInt
                        

    addTreeNode(DeviceConfig, "PersistentData", TBOOL, RW_BOTH, "0", "")
    addTreeNode(DeviceConfig, "ConfigFile", TSTRING, RD_ONLY, "32", "")
]]
    InternetGatewayDevice:addChild(ManagementServer)
end

function init_Time()
    Time = newTreeObject("Time", TOBJECT, RD_ONLY)

    addTreeNode(Time, "Enable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(Time, "Status", TSTRING, RD_ONLY, "32", "Disabled")
    addTreeNode(Time, "NTPServer1", TSTRING, RW_BOTH, "64", "")
    addTreeNode(Time, "NTPServer2", TSTRING, RW_BOTH, "64", "")
    addTreeNode(Time, "NTPServer3", TSTRING, RW_BOTH, "64", "")
    addTreeNode(Time, "NTPServer4", TSTRING, RW_BOTH, "64", "")
    addTreeNode(Time, "NTPServer5", TSTRING, RW_BOTH, "64", "")
    addTreeNode(Time, "CurrentLocalTime", "dateTime", RD_ONLY, "20", "")
    addTreeNode(Time, "LocalTimeZoneName", TSTRING, RW_BOTH, "64", "GMT+0")
    addTreeNode(Time, "CurrentTimeZone", TSTRING, RD_ONLY, "64", "GMT+00:00")
    InternetGatewayDevice:addChild(Time)
end

function init_UserInterface()
    UserInterface = newTreeObject("UserInterface", RD_ONLY)

    addTreeNode(UserInterface, "UserDatabaseSupported", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(UserInterface, "ButtonColor", TSTRING, RW_BOTH, "64", "")

    InternetGatewayDevice:addChild(UserInterface)
end

function init_TraceRouteDiagnostics()
    IPPingDiagnostics = newTreeObject("IPPingDiagnostics", RD_ONLY)
    addTreeNode(IPPingDiagnostics, "DiagnosticsState", TSTRING, RW_BOTH, "32", "None")
    addTreeNode(IPPingDiagnostics, "Interface", TSTRING, RW_BOTH, "256", "")
    addTreeNode(IPPingDiagnostics, "Host", TSTRING, RW_BOTH, "256", "")
    addTreeNode(IPPingDiagnostics, "NumberOfRepetitions", TUINT, RW_BOTH, "0", "0")
    addTreeNode(IPPingDiagnostics, "Timeout", TUINT, RW_BOTH, "0", "0")
    addTreeNode(IPPingDiagnostics, "DataBlockSize", TUINT, RW_BOTH, "0", "0")
    addTreeNode(IPPingDiagnostics, "Result", TUINT, RD_ONLY, "0", "0")
    addTreeNode(IPPingDiagnostics, "DSCP", TUINT, RW_BOTH, "0", "0")
    addTreeNode(IPPingDiagnostics, "SuccessCount", TUINT, RD_ONLY, "0", "0")
    addTreeNode(IPPingDiagnostics, "FailureCount", TUINT, RD_ONLY, "0", "0")
    addTreeNode(IPPingDiagnostics, "AverageResponseTime", TUINT, RD_ONLY, "0", "0")
    addTreeNode(IPPingDiagnostics, "MinimumResponseTime", TUINT, RD_ONLY, "0", "0")
    addTreeNode(IPPingDiagnostics, "MaximumResponseTime", TUINT, RD_ONLY, "0", "0")
    addTreeNode(IPPingDiagnostics, "Reply", TSTRING, RD_ONLY, "256", "")
    addTreeNode(IPPingDiagnostics, "Type", TUINT, RD_ONLY, "0", "0")
    InternetGatewayDevice:addChild(IPPingDiagnostics)
end

function init_TraceRouteDiagnostics()
    TraceRouteDiagnostics = newTreeObject("TraceRouteDiagnostics", RD_ONLY)
    addTreeNode(TraceRouteDiagnostics, "DiagnosticsState", TSTRING, RW_BOTH, "32", "None")
    addTreeNode(TraceRouteDiagnostics, "Interface", TSTRING, RW_BOTH, "256", "")
    addTreeNode(TraceRouteDiagnostics, "Host", TSTRING, RW_BOTH, "256", "")
    addTreeNode(TraceRouteDiagnostics, "NumberOfTries", TUINT, RW_BOTH, "0", "3")
    addTreeNode(TraceRouteDiagnostics, "Timeout", TUINT, RW_BOTH, "0", "5000")
    addTreeNode(TraceRouteDiagnostics, "DataBlockSize", TUINT, RW_BOTH, "0", "38")
    addTreeNode(TraceRouteDiagnostics, "Result", TUINT, RD_ONLY, "0", "0")
    addTreeNode(TraceRouteDiagnostics, "DSCP", TUINT, RW_BOTH, "0", "0")
    addTreeNode(TraceRouteDiagnostics, "MaxHopCount", TUINT, RW_BOTH, "0", "30")
    addTreeNode(TraceRouteDiagnostics, "ResponseTime", TUINT, RD_ONLY, "0", "0")
    addTreeNode(TraceRouteDiagnostics, "RouteHopsNumberOfEntries", TUINT, RD_ONLY, "0", "0")

    RouteHops = newTreeObject("RouteHops", RD_ONLY)
    addTreeNode(RouteHops, "HopHost", TSTRING, RD_ONLY, "256", "")
    addTreeNode(RouteHops, "HopHostAddress", TSTRING, RD_ONLY, "256", "")
    addTreeNode(RouteHops, "HopErrorCode", TUINT, RD_ONLY, "0", "0")
    addTreeNode(RouteHops, "HopRTTimes", TSTRING, RD_ONLY, "16", "")
    TraceRouteDiagnostics:addChild(RouteHops)
    InternetGatewayDevice:addChild(TraceRouteDiagnostics)
end

function init_CrashDiagnostics()
    CrashDiagnostics = newTreeObject("CrashDiagnostics", RD_ONLY)
    addTreeNode(CrashDiagnostics, "DiagnosticsState", TSTRING, RW_BOTH, "32", "None")
    addTreeNode(CrashDiagnostics, "CrashFileState", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(CrashDiagnostics, "Action", TSTRING, RW_BOTH, "32", "None")
    addTreeNode(CrashDiagnostics, "DiagnoseTag", TSTRING, RW_BOTH, "32", "")
    addTreeNode(CrashDiagnostics, "Mac", TSTRING, RW_BOTH, "32", "")
    addTreeNode(CrashDiagnostics, "AuthorizeEnable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(CrashDiagnostics, "UILanguage", TUINT, RW_BOTH, "0", "0")
    InternetGatewayDevice:addChild(CrashDiagnostics)
end

function init_X_ATP_WiFi()
    X_ATP_WiFi = newTreeObject("X_ATP_WiFi", RD_ONLY)
    InternetGatewayDevice:addChild(X_ATP_WiFi)
end

function init_LANDevice()

    LANDevice = newTreeObject("LANDevice", RD_ONLY)

    addTreeNode(LANDevice, "LANEthernetInterfaceNumberOfEntries", TUINT, RD_ONLY, "0", "4")
    addTreeNode(LANDevice, "LANWLANConfigurationNumberOfEntries", TUINT, RD_ONLY, "0", "4")

    LANDevice = newTreeObject("X_ATP_WlanRadio", RD_ONLY)
    InternetGatewayDevice:addChild(X_ATP_WlanRadio)

    --X_ATP_WlanRadio:addChild(Node.new("SupportBandwidth", TSTRING, RD_ONLY, "32", ""))
    --X_ATP_WlanRadio:addChild(Node.new("ChannelStatus", TSTRING, RD_ONLY, "32", ""))

    WLANConfiguration = newTreeObject("WLANConfiguration", TOBJECT, RD_ONLY)
    
    addTreeNode(WLANConfiguration, "Enable", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WLANConfiguration, "Status", TSTRING, RD_ONLY, "16", "")
    addTreeNode(WLANConfiguration, "BSSID", TSTRING, RD_ONLY, "32", "")
    addTreeNode(WLANConfiguration, "X_ATP_OperatingFrequencyBand", TSTRING, RD_ONLY, "16", "2.4GHz")
    addTreeNode(WLANConfiguration, "Channel", TINT, RW_BOTH, "0", "6")
    addTreeNode(WLANConfiguration, "AutoChannelEnable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(WLANConfiguration, "PossibleChannels", TSTRING, RD_ONLY, "1024", "")
    addTreeNode(WLANConfiguration, "ChannelsInUse", TSTRING, RD_ONLY, "256", "6")
    addTreeNode(WLANConfiguration, "RegulatoryDomain", TSTRING, RW_BOTH, "16", "GB")
    addTreeNode(WLANConfiguration, "NetworkSyncCode", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WLANConfiguration, "ActionType", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WLANConfiguration, "SSID", TSTRING, RW_BOTH, "32", "SSID")
    addTreeNode(WLANConfiguration, "BeaconType", TSTRING, RW_BOTH, "32", "Basic")
    addTreeNode(WLANConfiguration, "MACAddressControlEnabled", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WLANConfiguration, "Standard", TSTRING, RD_ONLY, "8", "")
    addTreeNode(WLANConfiguration, "WEPKeyIndex", TINT, RW_BOTH, "0", "1")
    addTreeNode(WLANConfiguration, "WEPEncryptionLevel", TSTRING, RD_ONLY, "64", "")
    addTreeNode(WLANConfiguration, "BasicEncryptionModes", TSTRING, RW_BOTH, "31", "WEPEncryption")
    addTreeNode(WLANConfiguration, "BasicAuthenticationMode", TSTRING, RW_BOTH, "31", "None")
    addTreeNode(WLANConfiguration, "WPAEncryptionModes", TSTRING, RW_BOTH, "31", "TKIPEncryption")
    addTreeNode(WLANConfiguration, "WPAAuthenticationMode", TSTRING, RW_BOTH, "31", "PSKAuthentication")
    addTreeNode(WLANConfiguration, "IEEE11iEncryptionModes", TSTRING, RW_BOTH, "31", "AESEncryption")
    addTreeNode(WLANConfiguration, "IEEE11iAuthenticationMode", TSTRING, RW_BOTH, "31", "PSKAuthentication")
    addTreeNode(WLANConfiguration, "SSIDAdvertisementEnabled", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WLANConfiguration, "WMMEnable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(WLANConfiguration, "TotalBytesSent", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WLANConfiguration, "TotalBytesReceived", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WLANConfiguration, "TotalPacketsSent", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WLANConfiguration, "TotalPacketsReceived", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WLANConfiguration, "TotalAssociations", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WLANConfiguration, "X_ATP_Wlan11NBWControl", TSTRING, RW_BOTH, "16", "20")
    addTreeNode(WLANConfiguration, "X_ATP_MixedEncryptionModes", TSTRING, RW_BOTH, "31", "TKIPEncryption")
    addTreeNode(WLANConfiguration, "X_ATP_WlanChipMaxAssoc", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WLANConfiguration, "X_ATP_ChannelBusyness", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WLANConfiguration, "X_ATP_ChannelUsage", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WLANConfiguration, "X_ATP_FreePower", TINT, RD_ONLY, "0", "0")
    LANDevice:addChild(WLANConfiguration)


    PreSharedKey = newTreeObject("PreSharedKey", RD_ONLY)
    addTreeNode(PreSharedKey, "KeyPassphrase", TSTRING, RW_BOTH, "64", "")
    WLANConfiguration:addChild(PreSharedKey)

    WEPKey = newTreeObject("WEPKey", RD_ONLY)
    addTreeNode(WEPKey, "WEPKey", TSTRING, RW_BOTH, "128", "")
    WLANConfiguration:addChild(WEPKey)

    AssociatedDevice = newTreeObject("AssociatedDevice", RW_BOTH)
    addTreeNode(AssociatedDevice, "AssociatedDeviceMACAddress ", TSTRING, RD_ONLY, "32", "")
    addTreeNode(AssociatedDevice, "AssociatedDeviceRssi", TSTRING, RD_ONLY, "8", "0")
    addTreeNode(AssociatedDevice, "AssociatedDeviceRate", TSTRING, RD_ONLY, "16", "300 Mbps")
    addTreeNode(AssociatedDevice, "AssociatedDeviceIPAddress", TSTRING, RD_ONLY, "64", "")
    addTreeNode(AssociatedDevice, "AssociatedDeviceName TSTRING", RD_ONLY, "64", "")
    addTreeNode(AssociatedDevice, "X_ATP_DeviceLostPackgeRate", TUINT, RD_ONLY, "0", "0")
    addTreeNode(AssociatedDevice, "X_ATP_DevicePer", TUINT, RD_ONLY, "0", "0")
    WLANConfiguration:addChild(AssociatedDevice)

    WPS = Node.new("WPS", TOBJECT, RD_ONLY)
    WPS:addChild(Node.new("Enable", TBOOL, RW_BOTH, "0", "0"))
    WPS:addChild(Node.new("DevicePassword", TSTRING, RW_BOTH, "16", ""))
    WLANConfiguration:addChild(WPS)

    Stats = Node.new("Stats", TOBJECT, RD_ONLY)
    WLANConfiguration:addChild(Stats)
    Stats:addChild(Node.new("ErrorsSent", TUINT, RD_ONLY, "0", "0"))
    Stats:addChild(Node.new("ErrorsReceived", TUINT, RD_ONLY, "0", "0"))
    Stats:addChild(Node.new("DiscardPacketsSent", TUINT, RD_ONLY, "0", "0"))
    Stats:addChild(Node.new("DiscardPacketsReceived", TUINT, RD_ONLY, "0", "0"))

    Hosts = Node.new("Hosts", TOBJECT, RD_ONLY)
    WLANConfiguration:addChild(Hosts)

    Hosts:addChild(Node.new("HostNumberOfEntries", TUINT, RD_ONLY, "0", "0"))
    Hosts:addChild(Node.new("X_ATP_ActiveHostNumberOfEntries", TUINT, RD_ONLY, "0", "0"))
    Hosts:addChild(Node.new("X_ATP_WiFiUserNum", TUINT, RD_ONLY, "0", "0"))

    Host = Node.new("Host", TOBJECT, RD_ONLY)
    addTreeNode(Host, "IPAddress", TSTRING, RD_ONLY, "16", "")

    addTreeNode(Host, "AddressSource", TSTRING, RD_ONLY, "16", "")
    addTreeNode(Host, "LeaseTimeRemaining", TINT, RD_ONLY, "0", "0")
    addTreeNode(Host, "MACAddress", TSTRING, RD_ONLY, "32", "")
    addTreeNode(Host, "HostName", TSTRING, RD_ONLY, "64", "")
    addTreeNode(Host, "InterfaceType", TSTRING, RD_ONLY, "16", "")
    addTreeNode(Host, "Active", TBOOL, RD_ONLY, "0", "0")
    Hosts:addChild(Host)

    LANHostConfigManagement = Node.new("LANHostConfigManagement", TOBJECT, RD_ONLY)
    addTreeNode(LANHostConfigManagement, "MACAddress", TSTRING, RD_ONLY, "32", "")
    addTreeNode(LANHostConfigManagement, "DHCPServerEnable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(LANHostConfigManagement, "DHCPServerConfigurable", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(LANHostConfigManagement, "DHCPRelay", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(LANHostConfigManagement, "SubnetMask", TSTRING, RW_BOTH, "256", "")
    addTreeNode(LANHostConfigManagement, "MinAddress", TSTRING, RW_BOTH, "16", "192.168.1.2")
    addTreeNode(LANHostConfigManagement, "MaxAddress", TSTRING, RW_BOTH, "16", "192.168.1.254")
    addTreeNode(LANHostConfigManagement, "ReservedAddresses", TSTRING, RW_BOTH, "256", "")
    addTreeNode(LANHostConfigManagement, "DNSServers", TSTRING, RW_BOTH, "64", "192.168.1.1,192.168.1.1")
    addTreeNode(LANHostConfigManagement, "StaticDnsServers", TSTRING, RW_BOTH, "64", "")
    addTreeNode(LANHostConfigManagement, "DeviceName", TSTRING, RW_BOTH, "253", "")
    addTreeNode(LANHostConfigManagement, "DomainName", TSTRING, RW_BOTH, "63", "home")
    addTreeNode(LANHostConfigManagement, "DHCPLeaseTime", TINT, RW_BOTH, "0", "86400")
    addTreeNode(LANHostConfigManagement, "UseAllocatedWAN", TSTRING, RW_BOTH, "16", "Normal")
    addTreeNode(LANHostConfigManagement, "AssociatedConnection", TSTRING, RW_BOTH, "256", "")
    addTreeNode(LANHostConfigManagement, "IPInterfaceNumberOfEntries", TUINT, RD_ONLY, "0", "1")
    addTreeNode(LANHostConfigManagement, "DHCPStaticAddressNumberOfEntries", TUINT, RD_ONLY, "0", "0")
    addTreeNode(LANHostConfigManagement, "DHCPOptionNumberOfEntries", TUINT, RD_ONLY, "0", "0")
    addTreeNode(LANHostConfigManagement, "DHCPConditionalPoolNumberOfEntries", TUINT, RD_ONLY, "0", "0")

    IPInterface = newTreeObject("IPInterface", RW_BOTH)
    addTreeNode(IPInterface, "IPInterfaceIPAddress", TSTRING, RW_BOTH, "16", "192.168.1.1")
    addTreeNode(IPInterface, "IPInterfaceSubnetMask", TSTRING, RW_BOTH, "16", "255.255.255.0")
    addTreeNode(IPInterface, "IPInterfaceAddressingType", TSTRING, RW_BOTH, "16", "DHCP")
    LANHostConfigManagement:addChild(IPInterface)
    LANDevice:addChild(LANHostConfigManagement)


    LANEthernetInterfaceConfig = newTreeObject("LANEthernetInterfaceConfig", RD_ONLY)
    addTreeNode(LANEthernetInterfaceConfig, "Enable", TBOOL, RD_ONLY, "0", "1")
    addTreeNode(LANEthernetInterfaceConfig, "Status", TSTRING, RD_ONLY, "16", "")
    addTreeNode(LANEthernetInterfaceConfig, "Name", TSTRING, RW_BOTH, "16", "")
    addTreeNode(LANEthernetInterfaceConfig, "MACAddress", TSTRING, RD_ONLY, "32", "")

    LANEthStats = newTreeObject("Stats", RD_ONLY)

    addTreeNode(LANEthStats, "BytesSent", TUINT, RD_ONLY, "0", "0")
    addTreeNode(LANEthStats, "BytesReceived", TUINT, RD_ONLY, "0", "0")
    addTreeNode(LANEthStats, "PacketsSent", TUINT, RD_ONLY, "0", "0")
    addTreeNode(LANEthStats, "PacketsReceived", TUINT, RD_ONLY, "0", "0")
    LANEthernetInterfaceConfig:addChild(LANEthStats)
    LANDevice:addChild(LANEthernetInterfaceConfig)
    InternetGatewayDevice:addChild(LANDevice)
end

function init_WANDevice()
    WANDevice = newTreeObject("WANDevice", RD_ONLY)

    addTreeNode(WANDevice, "WANConnectionNumberOfEntries", TUINT, RD_ONLY, "0", "0")

    WANCommonInterfaceConfig = newTreeObject("WANCommonInterfaceConfig", RD_ONLY)
    addTreeNode(WANCommonInterfaceConfig, "WANAccessType", TSTRING, RD_ONLY, "16", "")
    addTreeNode(WANCommonInterfaceConfig, "Layer1UpstreamMaxBitRate", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WANCommonInterfaceConfig, "Layer1DownstreamMaxBitRate", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WANCommonInterfaceConfig, "EnabledForInternet", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WANCommonInterfaceConfig, "PhysicalLinkStatus", TSTRING, RD_ONLY, "16", "")
    addTreeNode(WANCommonInterfaceConfig, "WANAccessProvider", TSTRING, RD_ONLY, "256", "")
    addTreeNode(WANCommonInterfaceConfig, "TotalBytesSent", TSTRING, RD_ONLY, "256", "")
    addTreeNode(WANCommonInterfaceConfig, "TotalBytesReceived", TSTRING, RD_ONLY, "256", "")
    addTreeNode(WANCommonInterfaceConfig, "TotalPacketsSent", TSTRING, RD_ONLY, "256", "")
    addTreeNode(WANCommonInterfaceConfig, "TotalPacketsReceived", TSTRING, RD_ONLY, "256", "")
    addTreeNode(WANCommonInterfaceConfig, "X_ATP_TotalBytes ", TSTRING, RD_ONLY, "32", "")
    addTreeNode(WANCommonInterfaceConfig, "MaximumActiveConnections", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WANCommonInterfaceConfig, "NumberOfActiveConnections", TUINT, RD_ONLY, "0", "0")

    Connection = newTreeObject("Connection", RD_ONLY)
    addTreeNode(Connection, "Connection.ActiveConnectionDeviceContainer", TSTRING, RD_ONLY, "256", "")
    addTreeNode(Connection, "Connection.ActiveConnectionServiceID", TSTRING, RD_ONLY, "256", "")
    WANCommonInterfaceConfig:addChild(Connection)

    WANDevice:addChild(WANCommonInterfaceConfig)


    X_ATP_WANUMTSInterfaceConfig = newTreeObject("X_ATP_WANUMTSInterfaceConfig", RD_ONLY)
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Enable", TBOOL, RD_ONLY, "0", "1")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Mode", TSTRING, RD_ONLY, "32", "Auto")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Order", TSTRING, RD_ONLY, "32", "Auto")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Band", TSTRING, RD_ONLY, "32", "Any")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "AutoSearchEnable", TBOOL, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RegistedNetwork", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "UpLoadData", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownLoadData", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "CurrentUpstreamRate  ", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "CurrentDownstreamRate", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "UpstreamMaxRate  ", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownstreamMaxRate", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SignalQuality", TINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ServiceStatus", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ServiceDomain", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RoamStatus", TSTRING, RD_ONLY, "256", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SystemMode", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SIMStatus", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SysSubMode", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "PLMN", TSTRING, RD_ONLY, "8", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RSRQ", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RSRP", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RSSI", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "SINR", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RSCP", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ECIO", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RAT", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "TAC", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RAC", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "LAC", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "bandwidth", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "castatus ", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "txpower  ", TSTRING, RD_ONLY, "64", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "MCS", TSTRING, RD_ONLY, "128", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "Earfcn", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "TDD", TSTRING, RD_ONLY, "64", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RRC", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "bandid", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownlinkRank", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownlinkTM", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "UplinkMaxThrp", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "DownlinkMaxThrp", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ResetMaxThrp", TSTRING, RW_BOTH, "32", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "AccessStatus", TSTRING, RD_ONLY, "64", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "eNodeBId", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "ulFreq", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "dlFreq", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "RoamAllowDialup", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "attach_apn", TSTRING, RD_ONLY, "100", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "QCI", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_WANUMTSInterfaceConfig, "CaCombination", TSTRING, RD_ONLY, "256", "")


    X_ATP_Stats = newTreeObject("Stats", RD_ONLY)
    addTreeNode(X_ATP_Stats, "BytesSent", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(X_ATP_Stats, "BytesReceived", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(X_ATP_Stats, "PacketsSent", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_Stats, "PacketsReceived", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_Stats, "CurrentMonthDownload", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_Stats, "CurrentMonthUpload", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_Stats, "MonthDuration", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_Stats, "MonthLastClearYear", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_Stats, "MonthLastClearMonth", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_Stats, "MonthLastClearDay", TUINT, RD_ONLY, "0", "0")
    X_ATP_WANUMTSInterfaceConfig:addChild(X_ATP_Stats)


    X_ATP_signal = newTreeObject("X_ATP_signal", RD_ONLY)
    addTreeNode(X_ATP_signal, "psc_ca_cellid", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_signal, "psc_ca_dl", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_signal, ".psc_ca_ul", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_signal, "psc_ca_status", TSTRING, RD_ONLY, "32", "")

    Scc = newTreeObject("Scc", RD_ONLY)
    addTreeNode(Scc, "scc_ca_cellid", TSTRING, RW_BOTH, "32", "")
    addTreeNode(Scc, "scc_ca_dl", TSTRING, RW_BOTH, "32", "")
    addTreeNode(Scc, "scc_ca_ul", TSTRING, RW_BOTH, "32", "")
    addTreeNode(Scc, "scc_ca_status", TSTRING, RW_BOTH, "32", "")
    X_ATP_signal:addChild(Scc)

    X_ATP_WANUMTSInterfaceConfig:addChild(X_ATP_signal)


    X_ATP_lmt_signal = newTreeObject("X_ATP_lmt_signal", RD_ONLY)
    addTreeNode(X_ATP_lmt_signal, "ri  ", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_lmt_signal, "cqi0", TSTRING, RD_ONLY, "32", "")
    addTreeNode(X_ATP_lmt_signal, "cqi1", TSTRING, RD_ONLY, "32", "")
    X_ATP_WANUMTSInterfaceConfig:addChild(X_ATP_lmt_signal)

    WANDevice:addChild(X_ATP_WANUMTSInterfaceConfig)


    WANConnectionDevice = newTreeObject("WANConnectionDevice", RW_BOTH)
    addTreeNode(WANConnectionDevice, "WANIPConnectionNumberOfEntries", TUINT, RD_ONLY, "0", "0")

    WANPPPConnection = newTreeObject("WANPPPConnection", RD_ONLY)
    addTreeNode(WANPPPConnection, "Enable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(WANPPPConnection, "ConnectionStatus", TSTRING, RW_BOTH, "32", "")
    addTreeNode(WANPPPConnection, "ConnectionType", TSTRING, RW_BOTH, "16", "IP_Routed")
    addTreeNode(WANPPPConnection, "DefaultGateway", TSTRING, RD_ONLY, "16", "")
    addTreeNode(WANPPPConnection, "Name ", TSTRING, RD_ONLY, "256", "")
    addTreeNode(WANPPPConnection, "Uptime", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WANPPPConnection, "LastConnectionError", TSTRING, RD_ONLY, "64", "ERROR_NONE")
    addTreeNode(WANPPPConnection, "Username", TSTRING, RW_BOTH, "128", "")
    addTreeNode(WANPPPConnection, "Password", TSTRING, RW_BOTH, "128", "")
    addTreeNode(WANPPPConnection, "ExternalIPAddress", TSTRING, RD_ONLY, "16", "")
    addTreeNode(WANPPPConnection, "SubnetMask", TSTRING, RD_ONLY, "16", "")
    addTreeNode(WANPPPConnection, "X_ATP_MaxMTUSize", TUINT, RW_BOTH, "0", "1492")
    addTreeNode(WANPPPConnection, "DNSEnabled", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WANPPPConnection, "DNSServers", TSTRING, RW_BOTH, "64", "")
    addTreeNode(WANPPPConnection, "MACAddress", TSTRING, RW_BOTH, "32", "")
    addTreeNode(WANPPPConnection, "ConnectionTrigger", TSTRING, RW_BOTH, "16", "")

    addTreeNode(WANPPPConnection, "X_ATP_IPv4Enable", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6Enable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6ConnectionStatus", TSTRING, RD_ONLY, "32", "")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6AddressingType", TSTRING, RW_BOTH, "8", "SLAAC")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6PrefixList", TSTRING, RD_ONLY, "128", "")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6DefaultGateway", TSTRING, RW_BOTH, "64", "")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6DNSEnabled", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6DNSServers", TSTRING, RW_BOTH, "128", "")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6Address", TSTRING, RW_BOTH, "64", "")
    addTreeNode(WANPPPConnection, "X_ATP_IPv6PrefixLength", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANPPPConnection, "X_ATP_TotalConnectTime", TUINT, RD_ONLY, "0", "0")

    addTreeNode(WANPPPConnection, "PortMappingNumberOfEntries", TUINT, RD_ONLY, "0", "0")
    WANPPP_PortMapping = newTreeObject("PortMapping", RW_BOTH)
    addTreeNode(WANPPP_PortMapping, "Enabled", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(WANPPP_PortMapping, "ExternalPort", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANPPP_PortMapping, "ExternalPortEndRange", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANPPP_PortMapping, "InternalPort", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANPPP_PortMapping, "InternalPortEndRange", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANPPP_PortMapping, "Protocol", TSTRING, RW_BOTH, "16", "TCP/UDP")
    addTreeNode(WANPPP_PortMapping, "InternalClient", TSTRING, RW_BOTH, "256", "")
    addTreeNode(WANPPP_PortMapping, "Description", TSTRING, RW_BOTH, "128", "")
    WANPPPConnection:addChild(WANPPP_PortMapping)

    X_ATP_DMZ = newTreeObject("X_ATP_DMZ", RD_ONLY)
    addTreeNode(X_ATP_DMZ, "DMZEnable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(X_ATP_DMZ, "DMZHostIPAddress", TSTRING, RW_BOTH, "16", "")
    WANPPPConnection:addChild(X_ATP_DMZ)
    WANConnectionDevice:addChild(WANPPPConnection)

    WANIPConnection = newTreeObject("WANIPConnection", RD_ONLY)
    addTreeNode(WANIPConnection, "Enable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(WANIPConnection, "ConnectionStatus", TSTRING, RW_BOTH, "32", "")
    addTreeNode(WANIPConnection, "ConnectionType", TSTRING, RW_BOTH, "16", "IP_Routed")
    addTreeNode(WANIPConnection, "Name", TSTRING, RD_ONLY, "256", "")
    addTreeNode(WANIPConnection, "LastConnectionError", TSTRING, RD_ONLY, "64", "ERROR_NONE")
    addTreeNode(WANIPConnection, "AddressingType", TSTRING, RW_BOTH, "8", "")
    addTreeNode(WANIPConnection, "ExternalIPAddress", TSTRING, RW_BOTH, "16", "")
    addTreeNode(WANIPConnection, "SubnetMask", TSTRING, RW_BOTH, "16", "")
    addTreeNode(WANIPConnection, "DefaultGateway", TSTRING, RW_BOTH, "16", "")
    addTreeNode(WANIPConnection, "DNSEnabled", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WANIPConnection, "DNSServers", TSTRING, RW_BOTH, "64", "")
    addTreeNode(WANIPConnection, "MaxMTUSize", TUINT, RW_BOTH, "0", "1500")
    addTreeNode(WANIPConnection, "X_ATP_WANDHCPOption60", TSTRING, RW_BOTH, "64", "")
    addTreeNode(WANIPConnection, "ConnectionTrigger", TSTRING, RW_BOTH, "16", "AlwaysOn")
    addTreeNode(WANIPConnection, "PortMappingNumberOfEntries", TUINT, RD_ONLY, "0", "0")
    addTreeNode(WANIPConnection, "X_ATP_IPv4Enable", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WANIPConnection, "X_ATP_IPv6Enable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(WANIPConnection, "X_ATP_IPv6ConnectionStatus", TSTRING, RD_ONLY, "32", "")
    addTreeNode(WANIPConnection, "X_ATP_IPv6AddressingType", TSTRING, RW_BOTH, "8", "SLAAC")
    addTreeNode(WANIPConnection, "X_ATP_IPv6PrefixList", TSTRING, RD_ONLY, "128", "")
    addTreeNode(WANIPConnection, "X_ATP_IPv6DefaultGateway", TSTRING, RW_BOTH, "64", "")
    addTreeNode(WANIPConnection, "X_ATP_IPv6DNSEnabled", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(WANIPConnection, "X_ATP_IPv6DNSServers", TSTRING, RW_BOTH, "128", "")
    addTreeNode(WANIPConnection, "X_ATP_IPv6Address", TSTRING, RW_BOTH, "128", "")
    addTreeNode(WANIPConnection, "X_ATP_IPv6PrefixLength", TUINT, RW_BOTH, "0", "0")

    WANIP_PortMapping = newTreeObject("PortMapping", RW_BOTH)
    addTreeNode(WANIP_PortMapping, "Enabled", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(WANIP_PortMapping, "ExternalPort", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANIP_PortMapping, "ExternalPortEndRange", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANIP_PortMapping, "InternalPort", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANIP_PortMapping, "InternalPortEndRange", TUINT, RW_BOTH, "0", "0")
    addTreeNode(WANIP_PortMapping, "Protocol", TSTRING, RW_BOTH, "16", "TCP/UDP")
    addTreeNode(WANIP_PortMapping, "InternalClient", TSTRING, RW_BOTH, "256", "")
    addTreeNode(WANIP_PortMapping, "Description", TSTRING, RW_BOTH, "128", "")
    WANIPConnection:addChild(WANIP_PortMapping)

    WANConnectionDevice:addChild(WANIPConnection)
    WANDevice:addChild(WANConnectionDevice)

    InternetGatewayDevice:addChild(WANDevice)
end

function init_Layer2Bridging()
    Layer2Bridging = newTreeObject("Layer2Bridging", RD_ONLY)
    Bridge = newTreeObject("Bridge", RD_ONLY)
    addTreeNode(Bridge, "X_ATP_DNSMode", TUINT, RW_BOTH, "0", "0")
    Layer2Bridging:addChild(Bridge)

    InternetGatewayDevice:addChild(Layer2Bridging)
end

function init_Services()
    Services = newTreeObject("Services", RD_ONLY)

    X_ATP_NetworkSetting = newTreeObject("X_ATP_NetworkSetting", RD_ONLY)
    addTreeNode(X_ATP_NetworkSetting, "NetworkPriority", TSTRING, RW_BOTH, "64", "")
    Services:addChild(X_ATP_NetworkSetting)

    
    --================================================
    X_ATP_ALGAbility = newTreeObject("X_ATP_ALGAbility", RD_ONLY)

    addTreeNode(X_ATP_ALGAbility, "SIPEnable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(X_ATP_ALGAbility, "SIPPort", TUINT, RW_BOTH, "0", "5060")
    Services:addChild(X_ATP_ALGAbility)

    X_ATP_Dialup = newTreeObject("X_ATP_Dialup", RD_ONLY)

    InternetProfileList = newTreeObject("InternetProfileList", RD_ONLY)
    addTreeNode(X_ATP_Dialup, "profile_name", TSTRING, RD_ONLY, "20", "")
    addTreeNode(X_ATP_Dialup, "apn", TSTRING, RD_ONLY, "100", "")
    addTreeNode(X_ATP_Dialup, "username", TSTRING, RD_ONLY, "128", "")
    addTreeNode(X_ATP_Dialup, "auth_mode", TUINT, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_Dialup, "ip_type", TUINT, RD_ONLY, "0", "0")
    X_ATP_Dialup:addChild(InternetProfileList)

    VOIPAPN = newTreeObject("VOIPAPN", RD_ONLY)
    addTreeNode(VOIPAPN, "profile_name", TSTRING, RD_ONLY, "20", "")
    addTreeNode(VOIPAPN, "apn", TSTRING, RW_BOTH, "100", "")
    addTreeNode(VOIPAPN, "username", TSTRING, RW_BOTH, "128", "")
    addTreeNode(VOIPAPN, "password", TSTRING, RW_BOTH, "128", "")
    addTreeNode(VOIPAPN, "auth_mode", TUINT, RW_BOTH, "0", "0")
    addTreeNode(VOIPAPN, "ip_type", TUINT, RW_BOTH, "0", "0")
    X_ATP_Dialup:addChild(VOIPAPN)

    InternetAPN = newTreeObject("InternetAPN", RD_ONLY)
    addTreeNode(InternetAPN, "profile_name", TSTRING, RD_ONLY, "20", "")
    addTreeNode(InternetAPN, "apn", TSTRING, RW_BOTH, "100", "")
    addTreeNode(InternetAPN, "username", TSTRING, RW_BOTH, "128", "")
    addTreeNode(InternetAPN, "password", TSTRING, RW_BOTH, "128", "")
    addTreeNode(InternetAPN, "auth_mode", TUINT, RW_BOTH, "0", "0")
    addTreeNode(InternetAPN, "ip_type", TUINT, RW_BOTH, "0", "0")
    X_ATP_Dialup:addChild(InternetAPN)

    Services:addChild(X_ATP_Dialup)

    ReAttach = newTreeObject("ReAttach", RD_ONLY)
    addTreeNode(ReAttach, "EnableReAttach", TUINT, RW_BOTH, "0", "0")
    Services:addChild(ReAttach)

    X_ATP_EthernetInterfaceNegotiation = newTreeObject("X_ATP_EthernetInterfaceNegotiation", RD_ONLY)
    addTreeNode(X_ATP_EthernetInterfaceNegotiation, "Status", TBOOL, RD_ONLY, "0", "0")
    addTreeNode(X_ATP_EthernetInterfaceNegotiation, "PortName", TSTRING, RD_ONLY, "16", "")
    addTreeNode(X_ATP_EthernetInterfaceNegotiation, "NegotiationResult", TUINT, RD_ONLY, "0", "0")
    Services:addChild(X_ATP_EthernetInterfaceNegotiation)

    InternetGatewayDevice:addChild(Services)
end

--===================
function init_X_ATP_VPN()
    X_ATP_VPN = newTreeObject("X_ATP_VPN", RD_ONLY)

    L2TP_LAC = newTreeObject("L2TP_LAC", RD_ONLY)
    addTreeNode(L2TP_LAC, "HostName", TSTRING, RW_BOTH, "64", "HGW")
    addTreeNode(L2TP_LAC, "PassWord", TSTRING, RW_BOTH, "64", "")
    addTreeNode(L2TP_LAC, "Enable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(L2TP_LAC, "LNSAddress", TSTRING, RW_BOTH, "256", "")
    addTreeNode(L2TP_LAC, "PCAuthMode", TUINT, RW_BOTH, "0", "0")
    addTreeNode(L2TP_LAC, "PppUser", TSTRING, RW_BOTH, "64", "")
    addTreeNode(L2TP_LAC, "PppPass", TSTRING, RW_BOTH, "64", "")
    addTreeNode(L2TP_LAC, "ConnectionStatus", TSTRING, RD_ONLY, "32", "")
    addTreeNode(L2TP_LAC, "KeepAliveTime", TUINT, RW_BOTH, "0", "60")
    X_ATP_VPN:addChild(L2TP_LAC)



    PPTP_LAC = newTreeObject("PPTP_LAC", RD_ONLY)


    addTreeNode(PPTP_LAC, "Enable", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(PPTP_LAC, "ServerAddress", TSTRING, RW_BOTH, "256", "")
    addTreeNode(PPTP_LAC, "PppUsername", TSTRING, RW_BOTH, "64", "")
    addTreeNode(PPTP_LAC, "PppPassword", TSTRING, RW_BOTH, "64", "")
    addTreeNode(PPTP_LAC, "PrimaryDNSServer", TSTRING, RW_BOTH, "32", "")
    addTreeNode(PPTP_LAC, "SecondaryDNSServer", TSTRING, RW_BOTH, "32", "")
    addTreeNode(PPTP_LAC, "ConnectionStatus", TSTRING, RD_ONLY, "32", "")

    X_ATP_VPN:addChild(PPTP_LAC)

    InternetGatewayDevice:addChild(X_ATP_VPN)
end

function init_X_ATP_FireWall()
    X_ATP_FireWall = newTreeObject("X_ATP_FireWall", RD_ONLY)

    Switch = newTreeObject("Switch", RD_ONLY)
    addTreeNode(Switch, "FirewallMainSwitch", TUINT, RW_BOTH, "0", "1")
    addTreeNode(Switch, "FirewallIPFilterSwitch", TUINT, RW_BOTH, "0", "0")
    addTreeNode(Switch, "FirewallWanPortPingSwitch", TUINT, RW_BOTH, "0", "1")
    addTreeNode(Switch, "Firewallmacfilterswitch", TUINT, RW_BOTH, "0", "0")
    addTreeNode(Switch, "Firewallurlfilterswitch", TUINT, RW_BOTH, "0", "0")
    X_ATP_FireWall:addChild(Switch)

    CustUrlFilter = newTreeObject("CustUrlFilter", RD_ONLY)
    addTreeNode(CustUrlFilter, "BlackListNumberOfEntries", TUINT, RW_BOTH, "0", "0")
    addTreeNode(CustUrlFilter, "WhiteListNumberOfEntries", TUINT, RW_BOTH, "0", "0")
    addTreeNode(CustUrlFilter, "CurrentMode", TUINT, RW_BOTH, "0", "0")
    X_ATP_FireWall:addChild(CustUrlFilter)

    WhiteList = newTreeObject("WhiteList", RD_ONLY)
    addTreeNode(WhiteList, "Url", TSTRING, RW_BOTH, "32", "")
    addTreeNode(WhiteList, "Status", TUINT, RW_BOTH, "0", "0")
    CustUrlFilter:addChild(WhiteList)

    BlackList = newTreeObject("BlackList", RD_ONLY)
    addTreeNode(BlackList, "Url", TSTRING, RW_BOTH, "32", "")
    addTreeNode(BlackList, "Status", TUINT, RW_BOTH, "0", "0")
    CustUrlFilter:addChild(BlackList)

    InternetGatewayDevice:addChild(X_ATP_FireWall)
end

function init_X_ATP_Config()
    X_ATP_Config = newTreeObject("X_ATP_Config", RD_ONLY)

    sms = newTreeObject("sms", RD_ONLY)
    addTreeNode(sms, "center_number", TSTRING, RW_BOTH, "128", "0")
    X_ATP_Config:addChild(sms)

    net = newTreeObject("net", RD_ONLY)
    X_ATP_Config:addChild(net)

    X_ATP_App = newTreeObject("X_ATP_App", RD_ONLY)
    X_ATP_Config:addChild(X_ATP_App)

    UtExtend = newTreeObject("UtExtend", RD_ONLY)
    addTreeNode(UtExtend, "SsconfHideMediaTag", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfUserAgentWith3gppGba", TINT, RW_BOTH, "0", "2")
    addTreeNode(UtExtend, "MulfBsfAcceptEncodingXml", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfDeleteNafAcceptEncoding", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfSuptTcpFin", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfAddNsRuleset", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfGetExcludeEtag", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfReqUriExlcudeRulesetNode", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfDeactiveNotSetAllow", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfUriType", TINT, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfPutMsgWithRuleset", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfParamCfgSbm", TINT, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfUseTlsVersion", TINT, RW_BOTH, "0", "1")
    addTreeNode(UtExtend, "MutfPutExcludeEtag", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfAuthRealmSameAsDomain", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfAuthUriSameAsReqUri", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfCbAddMedia", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfSuptIr92V10NoReplyTimer", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfSuptIr92VxNoRuleNotAllowPut", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfDerectlyAddAuthorizationInGbaPeriod", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfOnlyConditionsCapParam", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfAlwaysAccessFragmentXml", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfDelNamespaceInBodyMessage", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtExtend, "MutfUserAgentGbaInComment", TBOOL, RW_BOTH, "0", "0")
    X_ATP_Config:addChild(UtExtend)


    UtCommon = newTreeObject("UtCommon", RD_ONLY)
    addTreeNode(UtCommon, "HwUtIms", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtCommon, "NafPort", TUINT, RW_BOTH, "0", "80")
    addTreeNode(UtCommon, "NafSrvAddr", TSTRING, RW_BOTH, "256", "")
    addTreeNode(UtCommon, "NafUseHttps", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtCommon, "BsfPort", TUINT, RW_BOTH, "0", "8080")
    addTreeNode(UtCommon, "BsfSrvAddr", TSTRING, RW_BOTH, "256", "")
    addTreeNode(UtCommon, "BsfUseHttps", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtCommon, "AuthUserName", TSTRING, RW_BOTH, "256", "")
    addTreeNode(UtCommon, "LocalUserName", TSTRING, RW_BOTH, "256", "")
    addTreeNode(UtCommon, "UseXcapNameSpace", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(UtCommon, "UseNodeSelector", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(UtCommon, "UseTmpi", TBOOL, RW_BOTH, "0", "0")
    addTreeNode(UtCommon, "KsnafBase64", TBOOL, RW_BOTH, "0", "1")
    addTreeNode(UtCommon, "X3gppIntendId", TSTRING, RW_BOTH, "256", "")
    addTreeNode(UtCommon, "GbaType", TUINT, RW_BOTH, "0", "0")
    addTreeNode(UtCommon, "RootCaPath", TSTRING, RW_BOTH, "256", "")
    addTreeNode(UtCommon, "LibPath", TSTRING, RW_BOTH, "256", "")
    addTreeNode(UtCommon, "HrsLog", TUINT, RW_BOTH, "0", "0")
    addTreeNode(UtCommon, "XcapRootUri", TSTRING, RW_BOTH, "256", "")
    X_ATP_Config:addChild(UtCommon)

    statistic = newTreeObject("statistic", RD_ONLY)
    addTreeNode(statistic, "current_month_down", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(statistic, "current_month_up", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(statistic, "month_duration", TSTRING, RD_ONLY, "32", "0")
    addTreeNode(statistic, "month_last_clear_time", TSTRING, RD_ONLY, "32", "0")
    X_ATP_Config:addChild(statistic)

    InternetGatewayDevice:addChild(X_ATP_Config)
end

function init_Layer3Forwarding()
    Layer3Forwarding = newTreeObject("Layer3Forwarding", RD_ONLY)
    addTreeNode(Layer3Forwarding, "DefaultConnectionService", TSTRING, RW_BOTH, "256", "")
    addTreeNode(Layer3Forwarding, "ForwardNumberOfEntries", TUINT, RD_ONLY, "0", "0")

    X_ATP_IPv6Forwarding = newTreeObject("X_ATP_IPv6Forwarding", RD_ONLY)
    addTreeNode(X_ATP_IPv6Forwarding, "DestIPAddress", TSTRING, RW_BOTH, "64", "")
    addTreeNode(X_ATP_IPv6Forwarding, "PrefixLength", TUINT, RW_BOTH, "0", "128")
    addTreeNode(X_ATP_IPv6Forwarding, "GatewayIPAddress", TSTRING, RW_BOTH, "64", "")
    addTreeNode(X_ATP_IPv6Forwarding, "Interface", TSTRING, RW_BOTH, "256", "")
    Layer3Forwarding:addChild(X_ATP_IPv6Forwarding)

    Forwarding = newTreeObject("Forwarding", RD_ONLY)
    addTreeNode(Forwarding, "DestIPAddress", TSTRING, RW_BOTH, "16", "")
    addTreeNode(Forwarding, "DestSubnetMask", TSTRING, RW_BOTH, "16", "")
    addTreeNode(Forwarding, "GatewayIPAddress", TSTRING, RW_BOTH, "16", "")
    addTreeNode(Forwarding, "Interface", TSTRING, RW_BOTH, "256", "")
    Layer3Forwarding:addChild(Forwarding)

    InternetGatewayDevice:addChild(Layer3Forwarding)
end

function init_X_ATP_HotaUpg()
    X_ATP_HotaUpg = newTreeObject("X_ATP_HotaUpg", RD_ONLY)
    addTreeNode(X_ATP_HotaUpg, "HotaServiceEnable", TBOOL, RW_BOTH, "0", "0")
    InternetGatewayDevice:addChild(X_ATP_HotaUpg)
end



---===================================
init_Capabilities()
init_DeviceInfo()
init_DeviceConfig()
init_ManagementServer()
init_Time()
init_TraceRouteDiagnostics()
init_CrashDiagnostics()
init_LANDevice()
init_Layer2Bridging()
init_Layer3Forwarding()
init_Services()
init_X_ATP_WiFi()
init_X_ATP_VPN()
init_X_ATP_FireWall()
init_X_ATP_Config()
init_X_ATP_HotaUpg()

printTree(InternetGatewayDevice)
