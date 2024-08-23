-- lua sc

loadfile("./cwmp.lua")()

-- local resp = Execute_json_command('{ "command": "get_value", "parameter": "Device.IP." }')

-- print(resp)

-- {name, writable, value, type }
--local dev_info = { { "x1", 0, "1" }, { "x2", 1, "2", "int" }, { "x3", 1, "2", "int" } }

--for i, v in ipairs(dev_info) do
--       print(v[1], v[2], v[3], v[4])
--end


--[[
ubus call cm get_link_context
{
        "reqid": 28,
        ,
        "sn": "",
        "celluar_basic_info": {
                "sys_mode": 2,
                "data_mode": 14,
                "rssi": 61,
                "rsrp": 80,
                "rsrq": 12,
                "rssnr": 4,
                "ims_state": 0,
                "IMEI": "352099001761481",
                "IMSI": "460003400550829",
                "ICCID": "898600811922C5081748",
                "network_name": "CMCC",
                "roaming_network_name": "CMCC"
        },
        "contextlist": [
                {
                        "connection_num": 1,
                        "connection_status": 1,
                        "pdp_type": 1,
                        "ip_type": 0,
                        "primary_cid": 1,
                        "qci": 0,
                        "apn": "cmnet.MNC000.MCC460.GPRS",
                        "lte_apn": "cmnet",
                        "usr_2g3g": "any",
                        "pswd_2g3g": "any",
                        "authtype_2g3g": "NONE",
                        "usr_4g": "any",
                        "pswd_4g": "any",
                        "authtype_4g": "NONE",
                        "mtu": 1500,
                        "auto_apn": 1,
                        "connect_mode": 1,
                        "data_on_roaming": 1,
                        "ipv4_ip": "10.8.163.18",
                        "ipv4_dns1": "120.196.165.7",
                        "ipv4_dns2": "221.179.38.7",
                        "ipv4_gateway": "10.8.163.19",
                        "ipv4_submask": "255.255.255.0",
                        "ipv6_ip": "fe80::17eb:d516:6f07:7622",
                        "ipv6_dns1": "2409:8057:2000::8",
                        "ipv6_dns2": "2409:8057:2000:4::8",
                        "ipv6_gateway": "fe80::17eb:d516:6f07:7623",
                        "ipv6_submask": "::"
                }
        ]
}
]]

--[[
local ubus_resp_cm_get_link_context = '\
{\
        "reqid": 28,\
        "sn": "",\
        "celluar_basic_info": {\
                "sys_mode": 2,\
                "data_mode": 14,\
                "rssi": 61,\
                "rsrp": 80,\
                "rsrq": 12,\
                "rssnr": 4,\
                "ims_state": 0,\
                "IMEI": "352099001761481",\
                "IMSI": "460003400550829",\
                "ICCID": "898600811922C5081748",\
                "network_name": "CMCC",\
                "roaming_network_name": "CMCC"\
        },\
        "contextlist": [\
                {\
                        "connection_num": 1,\
                        "connection_status": 1,\
                        "pdp_type": 1,\
                        "ip_type": 0,\
                        "primary_cid": 1,\
                        "qci": 0,\
                        "apn": "cmnet.MNC000.MCC460.GPRS",\
                        "lte_apn": "cmnet",\
                        "usr_2g3g": "any",\
                        "pswd_2g3g": "any",\
                        "authtype_2g3g": "NONE",\
                        "usr_4g": "any",\
                        "pswd_4g": "any",\
                        "authtype_4g": "NONE",\
                        "mtu": 1500,\
                        "auto_apn": 1,\
                        "connect_mode": 1,\
                        "data_on_roaming": 1,\
                        "ipv4_ip": "10.8.163.18",\
                        "ipv4_dns1": "120.196.165.7",\
                        "ipv4_dns2": "221.179.38.7",\
                        "ipv4_gateway": "10.8.163.19",\
                        "ipv4_submask": "255.255.255.0",\
                        "ipv6_ip": "fe80::17eb:d516:6f07:7622",\
                        "ipv6_dns1": "2409:8057:2000::8",\
                        "ipv6_dns2": "2409:8057:2000:4::8",\
                        "ipv6_gateway": "fe80::17eb:d516:6f07:7623",\
                        "ipv6_submask": "::"\
                }\
        ]\
}'

local data = json.decode(ubus_resp_cm_get_link_context)

print(data.reqid)

print(data.celluar_basic_info.IMEI)
print(data.celluar_basic_info.IMSI)
]]

--[[




local device_ip = {
    { "Device.IP.Interface.1.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.1.Name", "loopback" },
    { "Device.IP.Interface.1.Type", "Loopback" },
    {
        "Device.IP.Interface.1.IPv4AddressNumberOfEntries",
        "1",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Interface.1.IPv4Address.1.IPAddress", "127.0.0.1" },
    { "Device.IP.Interface.1.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.1.IPv4Address.1.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.1.IPv4Address.1.SubnetMask", "255.0.0.0" },
    { "Device.IP.Interface.1.Stats.BytesSent", "384", "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.BytesReceived", "384", "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.PacketsSent", "8", "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.PacketsReceived", "8", "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.ErrorsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.ErrorsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.DiscardPacketsSent", "0", "xsd:unsignedInt" },
    {
        "Device.IP.Interface.1.Stats.DiscardPacketsReceived",
        "0",
        type =
        "xsd:unsignedInt"
    },

    { "Device.IP.Interface.2.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.2.Name", "lan" },
    { "Device.IP.Interface.2.Type", "Normal" },
    {
        "Device.IP.Interface.2.IPv4AddressNumberOfEntries",
        "1",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Interface.2.IPv4Address.1.IPAddress", "192.168.0.1" },
    { "Device.IP.Interface.2.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.2.IPv4Address.1.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.2.IPv4Address.1.SubnetMask", "255.255.255.0" },
    { "Device.IP.Interface.2.Stats.BytesSent", "12604", "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.BytesReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.PacketsSent", "167", "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.PacketsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.ErrorsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.ErrorsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.DiscardPacketsSent", "0", "xsd:unsignedInt" },
    {
        "Device.IP.Interface.2.Stats.DiscardPacketsReceived",
        "0",
        type =
        "xsd:unsignedInt"
    },

    { "Device.IP.Interface.3.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.3.Name", "wan60" },
    { "Device.IP.Interface.3.Type", "Normal" },
    {
        "Device.IP.Interface.3.IPv4AddressNumberOfEntries",
        "1",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Interface.3.IPv4Address.1.IPAddress", "" },
    { "Device.IP.Interface.3.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.3.IPv4Address.1.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.3.IPv4Address.1.SubnetMask", "" },
    { "Device.IP.Interface.3.Stats.BytesSent", "10776", "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.BytesReceived", "352", "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.PacketsSent", "123", "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.PacketsReceived", "4", "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.ErrorsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.ErrorsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.DiscardPacketsSent", "0", "xsd:unsignedInt" },
    {
        "Device.IP.Interface.3.Stats.DiscardPacketsReceived",
        "0",
        type =
        "xsd:unsignedInt"
    },

    { "Device.IP.Interface.4.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.4.Name", "wan61" },
    { "Device.IP.Interface.4.Type", "Normal" },
    {
        "Device.IP.Interface.4.IPv4AddressNumberOfEntries",
        "1",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Interface.4.IPv4Address.1.IPAddress", "" },
    { "Device.IP.Interface.4.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.4.IPv4Address.1.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.4.IPv4Address.1.SubnetMask", "" },
    { "Device.IP.Interface.4.Stats.BytesSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.BytesReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.PacketsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.PacketsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.ErrorsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.ErrorsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.DiscardPacketsSent", "0", "xsd:unsignedInt" },
    {
        "Device.IP.Interface.4.Stats.DiscardPacketsReceived",
        "0",
        type =
        "xsd:unsignedInt"
    },

    { "Device.IP.Interface.5.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.5.Name", "wan67" },
    { "Device.IP.Interface.5.Type", "Normal" },
    {
        "Device.IP.Interface.5.IPv4AddressNumberOfEntries",
        "1",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Interface.5.IPv4Address.1.IPAddress", "" },
    { "Device.IP.Interface.5.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.5.IPv4Address.1.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.5.IPv4Address.1.SubnetMask", "" },
    { "Device.IP.Interface.5.Stats.BytesSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.BytesReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.PacketsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.PacketsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.ErrorsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.ErrorsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.DiscardPacketsSent", "0", "xsd:unsignedInt" },
    {
        "Device.IP.Interface.5.Stats.DiscardPacketsReceived",
        "0",
        type =
        "xsd:unsignedInt"
    },


    { "Device.IP.Interface.6.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.6.Name", "wan0" },
    { "Device.IP.Interface.6.Type", "Normal" },
    {
        "Device.IP.Interface.6.IPv4AddressNumberOfEntries",
        "1",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Interface.6.IPv4Address.1.IPAddress", "10.120.13.237" },
    { "Device.IP.Interface.6.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.6.IPv4Address.1.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.6.IPv4Address.1.SubnetMask", "255.255.255.0" },
    { "Device.IP.Interface.6.Stats.BytesSent", "20320", "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.BytesReceived", "352", "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.PacketsSent", "136", "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.PacketsReceived", "4", "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.ErrorsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.ErrorsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.DiscardPacketsSent", "0", "xsd:unsignedInt" },
    {
        "Device.IP.Interface.6.Stats.DiscardPacketsReceived",
        "0",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Interface.7.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.7.Name", "wan1" },
    { "Device.IP.Interface.7.Type", "Normal" },
    {
        "Device.IP.Interface.7.IPv4AddressNumberOfEntries",
        "1",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Interface.7.IPv4Address.1.IPAddress", "" },
    { "Device.IP.Interface.7.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.7.IPv4Address.1.Enable", "1", "xsd:boolean" },
    { "Device.IP.Interface.7.IPv4Address.1.SubnetMask", "" },
    { "Device.IP.Interface.7.Stats.BytesSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.BytesReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.PacketsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.PacketsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.ErrorsSent", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.ErrorsReceived", "0", "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.DiscardPacketsSent", "0", "xsd:unsignedInt" },
    {
        "Device.IP.Interface.7.Stats.DiscardPacketsReceived",
        "0",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Diagnostics.IPPing.DiagnosticsState", "None" },
    { "Device.IP.Diagnostics.IPPing.Host", "" },
    {
        "Device.IP.Diagnostics.IPPing.NumberOfRepetitions",
        "3",
        type =
        "xsd:unsignedInt"
    },
    { "Device.IP.Diagnostics.IPPing.Timeout", "1000", "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.DataBlockSize", "64", "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.SuccessCount", "0", "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.FailureCount", "0", "xsd:unsignedInt" },
    {
        "Device.IP.Diagnostics.IPPing.AverageResponseTime",
        "0",
        type =
        "xsd:unsignedInt"
    },
    {
        "Device.IP.Diagnostics.IPPing.MinimumResponseTime",
        "0",
        type =
        "xsd:unsignedInt"
    },
    {
        "Device.IP.Diagnostics.IPPing.MaximumResponseTime",
        "0",
        type =
        "xsd:unsignedInt"
    })




local device_ip_value = {

    { "Device.IP.Interface.1.Enable",                       "1",            "xsd:boolean" },
    { "Device.IP.Interface.1.Name",                         "loopback" },
    { "Device.IP.Interface.1.Type",                         "Loopback" },
    { "Device.IP.Interface.1.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.1.IPv4Address.1.IPAddress",      "127.0.0.1" },
    { "Device.IP.Interface.1.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.1.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.1.IPv4Address.1.SubnetMask",     "255.0.0.0" },
    { "Device.IP.Interface.1.Stats.BytesSent",              "384",          "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.BytesReceived",          "384",          "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.PacketsSent",            "8",            "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.PacketsReceived",        "8",            "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.1.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },

    { "Device.IP.Interface.2.Enable",                       "1",            "xsd:boolean" },
    { "Device.IP.Interface.2.Name",                         "lan" },
    { "Device.IP.Interface.2.Type",                         "Normal" },
    { "Device.IP.Interface.2.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.2.IPv4Address.1.IPAddress",      "192.168.0.1" },
    { "Device.IP.Interface.2.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.2.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.2.IPv4Address.1.SubnetMask",     "255.255.255.0" },
    { "Device.IP.Interface.2.Stats.BytesSent",              "12604",        "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.BytesReceived",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.PacketsSent",            "167",          "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.PacketsReceived",        "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.2.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },

    { "Device.IP.Interface.3.Enable",                       "1",            "xsd:boolean" },
    { "Device.IP.Interface.3.Name",                         "wan60" },
    { "Device.IP.Interface.3.Type",                         "Normal" },
    { "Device.IP.Interface.3.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.3.IPv4Address.1.IPAddress",      "" },
    { "Device.IP.Interface.3.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.3.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.3.IPv4Address.1.SubnetMask",     "" },
    { "Device.IP.Interface.3.Stats.BytesSent",              "10776",        "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.BytesReceived",          "352",          "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.PacketsSent",            "123",          "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.PacketsReceived",        "4",            "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.3.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },

    { "Device.IP.Interface.4.Enable",                       "1",            "xsd:boolean" },
    { "Device.IP.Interface.4.Name",                         "wan61" },
    { "Device.IP.Interface.4.Type",                         "Normal" },
    { "Device.IP.Interface.4.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.4.IPv4Address.1.IPAddress",      "" },
    { "Device.IP.Interface.4.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.4.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.4.IPv4Address.1.SubnetMask",     "" },
    { "Device.IP.Interface.4.Stats.BytesSent",              "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.BytesReceived",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.PacketsSent",            "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.PacketsReceived",        "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.4.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },

    { "Device.IP.Interface.5.Enable",                       "1",            "xsd:boolean" },
    { "Device.IP.Interface.5.Name",                         "wan67" },
    { "Device.IP.Interface.5.Type",                         "Normal" },
    { "Device.IP.Interface.5.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.5.IPv4Address.1.IPAddress",      "" },
    { "Device.IP.Interface.5.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.5.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.5.IPv4Address.1.SubnetMask",     "" },
    { "Device.IP.Interface.5.Stats.BytesSent",              "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.BytesReceived",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.PacketsSent",            "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.PacketsReceived",        "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.5.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },

    { "Device.IP.Interface.6.Enable",                       "1",            "xsd:boolean" },
    { "Device.IP.Interface.6.Name",                         "wan0" },
    { "Device.IP.Interface.6.Type",                         "Normal" },
    { "Device.IP.Interface.6.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.6.IPv4Address.1.IPAddress",      "10.120.13.237" },
    { "Device.IP.Interface.6.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.6.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.6.IPv4Address.1.SubnetMask",     "255.255.255.0" },
    { "Device.IP.Interface.6.Stats.BytesSent",              "20320",        "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.BytesReceived",          "352",          "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.PacketsSent",            "136",          "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.PacketsReceived",        "4",            "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.6.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Enable",                       "1",            "xsd:boolean" },

    { "Device.IP.Interface.7.Name",                         "wan1" },
    { "Device.IP.Interface.7.Type",                         "Normal" },
    { "Device.IP.Interface.7.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.IPv4Address.1.IPAddress",      "" },
    { "Device.IP.Interface.7.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.7.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.7.IPv4Address.1.SubnetMask",     "" },
    { "Device.IP.Interface.7.Stats.BytesSent",              "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.BytesReceived",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.PacketsSent",            "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.PacketsReceived",        "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },

    { "Device.IP.Interface.7.Name",                         "wan1" },
    { "Device.IP.Interface.7.Type",                         "Normal" },
    { "Device.IP.Interface.7.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.IPv4Address.1.IPAddress",      "" },
    { "Device.IP.Interface.7.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.7.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.7.IPv4Address.1.SubnetMask",     "" },
    { "Device.IP.Interface.7.Stats.BytesSent",              "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.BytesReceived",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.PacketsSent",            "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.PacketsReceived",        "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.7.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },

    { "Device.IP.Interface.8.Name",                         "wan1" },
    { "Device.IP.Interface.8.Type",                         "Normal" },
    { "Device.IP.Interface.8.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.8.IPv4Address.1.IPAddress",      "" },
    { "Device.IP.Interface.8.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.8.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.8.IPv4Address.1.SubnetMask",     "" },
    { "Device.IP.Interface.8.Stats.BytesSent",              "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.8.Stats.BytesReceived",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.8.Stats.PacketsSent",            "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.8.Stats.PacketsReceived",        "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.8.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.8.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.8.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.8.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },

    { "Device.IP.Interface.9.Name",                         "wan1" },
    { "Device.IP.Interface.9.Type",                         "Normal" },
    { "Device.IP.Interface.9.IPv4AddressNumberOfEntries",   "1",            "xsd:unsignedInt" },
    { "Device.IP.Interface.9.IPv4Address.1.IPAddress",      "" },
    { "Device.IP.Interface.9.IPv4Address.1.AddressingType", "Static" },
    { "Device.IP.Interface.9.IPv4Address.1.Enable",         "1",            "xsd:boolean" },
    { "Device.IP.Interface.9.IPv4Address.1.SubnetMask",     "" },
    { "Device.IP.Interface.9.Stats.BytesSent",              "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.9.Stats.BytesReceived",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.9.Stats.PacketsSent",            "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.9.Stats.PacketsReceived",        "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.9.Stats.ErrorsSent",             "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.9.Stats.ErrorsReceived",         "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.9.Stats.DiscardPacketsSent",     "0",            "xsd:unsignedInt" },
    { "Device.IP.Interface.9.Stats.DiscardPacketsReceived", "0",            "xsd:unsignedInt" },


    { "Device.IP.Diagnostics.IPPing.DiagnosticsState",      "None" },
    { "Device.IP.Diagnostics.IPPing.Host",                  "" },
    { "Device.IP.Diagnostics.IPPing.NumberOfRepetitions",   "3",            "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.Timeout",               "1000",         "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.DataBlockSize",         "64",           "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.SuccessCount",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.FailureCount",          "0",            "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.AverageResponseTime",   "0",            "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.MinimumResponseTime",   "0",            "xsd:unsignedInt" },
    { "Device.IP.Diagnostics.IPPing.MaximumResponseTime",   "0",            "xsd:unsignedInt" }
}
]]


Exec_uint_testing()
