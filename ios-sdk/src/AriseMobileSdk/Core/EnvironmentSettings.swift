internal enum EnvironmentSettings {
    
    case production
    case uat
    
    var baseEndpoint: String {
        switch self {
        case .production:
            return "arise.risewithaurora.com"
        case .uat:
            return "uat.arise.risewithaurora.com"
//            TODO: remove after testing
//            return "dev.arise.risewithaurora.com"
        }
    }
    
    var authApiBaseUrl: String {
        switch self {
        case .production:
            return "https://oauth.arise.risewithaurora.com"
        case .uat:
            return "https://oauth.uat.arise.risewithaurora.com"
//            TODO: remove after testing
//            return "https://oauth.dev.arise.risewithaurora.com"
            
        }
    }
    
    var apiBaseUrl: String {
        switch self {
        case .production:
            return "https://api.arise.risewithaurora.com"
        case .uat:
            return "https://api.uat.arise.risewithaurora.com"
//            TODO: remove after testing
//            return "https://api.dev.arise.risewithaurora.com"
        }
    }
    
    /// Terminal Profile ID for CloudCommerce SDK.
    ///
    /// This value is used when calling CloudCommerce SDK's prepare() method.
    /// Currently using the same value for both production and UAT (Sandbox/MTF environment).
    ///
    /// - Important: For production, this value needs to be updated once the Production
    ///   environment is configured with the new TerminalProfileId from Mastercard.
    var terminalProfileId: String {
        switch self {
        case .production:
            // TODO: Update this value once Production environment is configured
            // This is currently using the Sandbox/MTF TerminalProfileId
            return "4c840000-0000-0000-0fd2-e456682cc625"
        case .uat:
            return "4c840000-0000-0000-0fd2-e456682cc625"
        }
    }
}
