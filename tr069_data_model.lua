-- lua sc

local tr069_datamodel = {


    deviceType = {

        protocol = "DEVICE_PROTOCOL_DSLFTR069v1",
        manufacturer = "MeiG",
        manufacturerOUI = "A4D4B2",
        productClass = "SLT718_TCR",
        modelName = "SLT718_TCR",
        softwareVersion = "SLT718-TCR_1.0.6_EQ101",

        supportedRPCMethods = {
            "GetRPCMethods",
            "SetParameterValues",
            "GetParameterValues",
            "GetParameterNames",
            "SetParameterAttributes",
            "GetParameterAttributes",
            "AddObject",
            "DeleteObject",
            "Download",
            "Reboot",
            "ScheduleInform",
            "Upload",
            "FactoryReset",
            "Fault",
        },

        dataModel = {
            attributes = {
                notification = {
                    attributeName = "notification",
                    attributeType = "int",
                    minValue = 0,
                    maxValue = 2,
                },
                accessList = {
                    attributeName = "accessList",
                    attributeType = "string",
                    array = "true",
                    attributeLength = 64,
                },
            },

            parameters = {

                InternetGatewayDevice = {
                    parameterName = "InternetGatewayDevice",
                    parameterType = "object",
                    array = "false",
                    parameters = {
                        DeviceSummary = "",           -- string
                        LANDeviceNumberOfEntries = 0, -- unsignedInt
                        WANDeviceNumberOfEntries = 0, -- unsignedInt
                        Services = {
                            parameterName = "Services",
                            parameterType = "object",
                            array = "false",
                            parameters = {},
                        },
                        Capabilities = {
                            parameterName = "Capabilities",
                            parameterType = "object",
                            array = "false",
                            parameters = {
                                {
                                    parameterName = "PerformanceDiagnostic",
                                    parameterType = "object",
                                    array = "false",
                                    parameters = {
                                        DownloadTransports = "",
                                        UploadTransports = "",
                                    },
                                },
                            },
                        },

                        DeviceInfo = {
                            parameterName = "DeviceInfo",
                            parameterType = "object",
                            array = "false",
                            parameters = {
                                Manufacturer = "",
                                ManufacturerOUI = "",

                                ModelName = "",

                                Description = "",

                                ProductClass = "",
                                SerialNumber = "",

                                HardwareVersion = "",
                                SoftwareVersion = ">string",
                                ModemFirmwareVersion = "string",
                                AdditionalHardwareVersion = "string",
                                AdditionalSoftwareVersion = "string",
                                SpecVersion = "string",
                                ProvisioningCode = "string",
                                UpTime = "unsignedInt",
                                FirstUseDate = ">dateTime",
                                IMEI = "string",

                                IMSI = "string",

                                MSISDN = "string",

                                VendorConfigFile = {

                                },
                                MemoryStatus = {
                                    Total = "unsignedInt",
                                    Free = "unsignedInt",
                                },
                                ProcessStatus = {
                                    CPUUsage = "unsignedInt",
                                    ProcessNumberOfEntries = "unsignedInt",
                                },
                                Processor = { Architecture = "string", },
                                VendorLogFile = { },
                            },
                        },

                        ManagementServer = {
                            EnableCWMP = true,
                            URL = "",
                            Username = "",
                            Password = "",
                            PeriodicInformEnable = true,
                            PeriodicInformInterval = 7200,
                            PeriodicInformTime = "", -- dateTime
                            ParameterKey = "",
                            ConnectionRequestURL = "",
                            ConnectionRequestUsername = "",
                            ConnectionRequestPassword = "",
                            ConnectionRequestAuth = 0, -- unsignedInt
                            ConnectionRequestPort = 0,
                            UDPConnectionRequestAddress = "",

                            STUNEnable = false,
                            STUNServerAddress = "",
                            STUNServerPort = 0,
                            STUNUsername = "",
                            STUNPassword = "",

                            STUNMaximumKeepAlivePeriod = 120, -- int
                            STUNMinimumKeepAlivePeriod = 60,  -- unsignedInt
                            NATDetected = false,              -- boolean
                            AliasBasedAddressing = false,     -- boolean
                            CWMPRetryMinimumWaitInterval = 0, -- unsignedInt
                            CWMPRetryIntervalMultiplier = 0,  -- unsignedInt
                        },

                        Time = {
                            Enable = false, -- boolean
                            Status = "",    -- string
                            NTPServer1 = "",
                            NTPServer2 = "",
                            NTPServer3 = "",
                            NTPServer4 = "",
                            NTPServer5 = "",
                            CurrentLocalTime = "", --dateTime
                            Runtime = "",          --dateTime
                        },

                        Layer3Forwarding = {
                            DefaultConnectionService = "", -- string
                        },

                        IPPingDiagnostics = {
                            DiagnosticsState    = "",
                            Interface           = "",
                            Host                = "",
                            NumberOfRepetitions = 0,
                            Timeout             = 0,
                            DataBlockSize       = 0,
                            DSCP                = 0,
                            SuccessCount        = 0,
                            FailureCount        = 0,
                            AverageResponseTime = 0,
                            MinimumResponseTime = 0,
                            MaximumResponseTime = 0,
                        },

                        DownloadDiagnostics = {
                            DiagnosticsState = "",
                            Interface = "",
                            DownloadURL = "",
                            DSCP = 0,                 -- unsignedInt
                            EthernetPriority = 0,     -- unsignedInt
                            ROMTime = "",             -- dateTime
                            BOMTime = "",             -- dateTime
                            EOMTime = "",             -- dateTime
                            TestBytesReceived = 0,    -- unsignedInt
                            TotalBytesReceived = 0,   -- unsignedInt
                            TCPOpenRequestTime = "",  -- dateTime
                            TCPOpenResponseTime = "", -- dateTime
                        },

                        UploadDiagnostics = {
                            DiagnosticsState    = "",
                            Interface           = "",
                            UploadURL           = "",
                            DSCP                = 0,  -- unsignedInt
                            EthernetPriority    = 0,  -- unsignedInt
                            TestFileLength      = 0,  -- unsignedInt
                            ROMTime             = "", -- dateTime
                            BOMTime             = "", -- dateTime
                            EOMTime             = "", -- dateTime
                            TotalBytesSent      = 0,  -- unsignedInt
                            TCPOpenRequestTime  = "", -- dateTime
                            TCPOpenResponseTime = "", --dateTime,
                        },

                        UDPEchoConfig = {
                            Enable                  = false,
                            Interface               = "",
                            SourceIPAddress         = "",
                            UDPPort                 = 0,
                            EchoPlusEnabled         = false,
                            EchoPlusSupported       = false,
                            PacketsReceived         = 0,  -- unsignedInt
                            PacketsResponded        = 0,  -- unsignedInt
                            BytesReceived           = 0,  -- unsignedInt
                            BytesResponded          = 0,  -- unsignedInt
                            TimeFirstPacketReceived = "", --dateTime
                            TimeLastPacketReceived  = "", --dateTime
                        },

                        LANDevice = {
                            parameterName = "LANDevice",
                            parameterType = "object",
                            array = "true",
                            parameters = {
                                {
                                    parameterName = "LANWLANConfigurationNumberOfEntries",
                                    parameterType = "unsignedInt",
                                },
                                {
                                    parameterName = "LANHostConfigManagement",
                                    parameterType = "object",
                                    array = "false",
                                    parameters = {
                                        MACAddress = "string",
                                        DHCPServerEnable = "boolean",
                                        MinAddress = "string",
                                        MaxAddress = "string",
                                        SubnetMask = "string",
                                        DomainName = "string",
                                        IPRouters = "string",

                                        DHCPLeaseTime = "int",
                                        DHCPStaticAddressNumberOfEntries = "unsignedInt",
                                        DHCPStaticAddress = {
                                            {
                                                Enable = "boolean",
                                                Chaddr = "string",
                                                Yiaddr = "string",
                                            },
                                            -- ...
                                            {
                                                Enable = "boolean",
                                                Chaddr = "string",
                                                Yiaddr = "string",
                                            },
                                        },
                                    },
                                },

                                WLANConfiguration = {
                                    {
                                        {
                                            Enable = "boolean",
                                            Status = "string",
                                            BSSID = "string",
                                            Channel = "unsignedInt",
                                            AutoChannelEnable = "boolean",
                                            SSID = "string",
                                            BeaconType = "string",
                                            Standard = "string",
                                            KeyPassphrase = "string",
                                            WPAEncryptionModes = "string",
                                            WPAAuthenticationMode = "string",
                                            SSIDAdvertisementEnabled = "boolean",
                                            X_BandType = "string",
                                            X_BandWidth = "string",
                                            X_CountryCode = "string",
                                            TotalBytesSent = "string",
                                            TotalBytesReceived = "string",
                                            TotalPacketsSent = "string",
                                            TotalPacketsReceived = "string",
                                            TotalAssociations = "unsignedInt",
                                            AssociatedDevice = {},
                                        }
                                        -- ...
                                    },
                                },

                                Hosts = {
                                    parameterName = "Hosts",
                                    parameterType = "object",
                                    array = "false",
                                    parameters = {
                                        {
                                            parameterName = "HostNumberOfEntries",
                                            parameterType = "unsignedInt",
                                        },
                                        {
                                            parameterName = "Host",
                                            parameterType = "object",
                                            array = "true",
                                        },
                                    },
                                },

                            },
                        },


                        WANDevice = {
                            parameterName = "WANDevice",
                            parameterType = "object",
                            array = "true",
                            parameters = {
                                WANConnectionNumberOfEntries = 0, -- unsignedInt

                                WANCommonInterfaceConfig = {
                                    parameterName = "WANCommonInterfaceConfig",
                                    parameterType = "object",
                                    array = "false",
                                    parameters = {
                                        WANAccessType = "",
                                        PhysicalLinkStatus = "",
                                        TotalBytesSent = "",
                                        TotalBytesReceived = "",
                                        TotalPacketsSent = "",
                                        TotalPacketsReceived = "",
                                    },
                                },

                                WANConnectionDevice = {
                                    parameterName = "WANConnectionDevice",
                                    parameterType = "object",
                                    array = "true",
                                    parameters = {
                                        WANIPConnectionNumberOfEntries = 0,  -- "unsignedInt",
                                        WANPPPConnectionNumberOfEntries = 0, -- "unsignedInt",
                                        {
                                            parameterName = "WANIPConnection",
                                            parameterType = "object",
                                            array = "true",
                                            parameters = {
                                                ConnectionStatus           = "",    -- "string"
                                                PossibleConnectionTypes    = "",    -- "string"
                                                ConnectionType             = "",    -- "string"
                                                Name                       = "",    -- "string"
                                                Uptime                     = 0,     -- "unsignedInt"

                                                LastConnectionError        = "",    -- "string"
                                                NATEnabled                 = false, -- "boolean"

                                                AddressingType             = "",    -- "string"
                                                ExternalIPAddress          = "",    -- "string"
                                                SubnetMask                 = "",    -- "string"
                                                DefaultGateway             = "",    -- "string"
                                                DNSEnabled                 = false, -- "boolean"
                                                DNSServers                 = "",    -- "string"
                                                MaxMTUSize                 = 1500,  -- "unsignedInt"
                                                MACAddress                 = "",    -- "string"
                                                PortMappingNumberOfEntries = 0,     -- "unsignedInt"
                                                RegisterNetworkType        = "",    -- "string"
                                                CellID                     = 0,     -- "unsignedInt"
                                                RSRP                       = 0,     -- "unsignedInt"
                                                RSRQ                       = 0,     -- "unsignedInt"
                                                RSSI                       = 0,     -- "unsignedInt"
                                                SINR                       = 0,     -- "unsignedInt"
                                                PCI                        = 0,     -- "unsignedInt"
                                                ECGI                       = "",    -- "string"
                                            },
                                        },


                                        WANPPPConnection = {
                                            ConnectionStatus = "",        -- string
                                            PossibleConnectionTypes = "", -- string
                                            ConnectionType = "",
                                            Name = "",
                                            Uptime = 0,         -- unsignedInt
                                            LastConnectionError = "",
                                            NATEnabled = false, -- boolean
                                            AddressingType = "",
                                            ExternalIPAddress = "",
                                            SubnetMask = "",
                                            DefaultGateway = "",            -- string
                                            DNSEnabled = false,             -- boolean
                                            DNSServers = "",                -- string
                                            MaxMTUSize = 1500,              -- unsignedInt
                                            MACAddress = "",                -- string
                                            PortMappingNumberOfEntries = 0, --"unsignedInt",
                                        },
                                    },
                                },

                            },
                        },

                    },
                },

            },

        },
    },
}

