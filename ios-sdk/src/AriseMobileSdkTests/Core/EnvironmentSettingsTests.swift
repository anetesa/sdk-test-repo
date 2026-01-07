import Foundation
import Testing
@testable import AriseMobile

/// Tests for EnvironmentSettings enum
struct EnvironmentSettingsTests {
    
    // MARK: - Enum Cases Tests
    
    @Test("EnvironmentSettings has production case")
    func testEnvironmentSettingsHasProductionCase() {
        let settings = EnvironmentSettings.production
        #expect(settings == .production)
    }
    
    @Test("EnvironmentSettings has uat case")
    func testEnvironmentSettingsHasUatCase() {
        let settings = EnvironmentSettings.uat
        #expect(settings == .uat)
    }
    
    @Test("EnvironmentSettings cases are distinct")
    func testEnvironmentSettingsCasesAreDistinct() {
        let production = EnvironmentSettings.production
        let uat = EnvironmentSettings.uat
        #expect(production != uat)
    }
    
    // MARK: - baseEndpoint Tests
    
    @Test("Production baseEndpoint is correct")
    func testProductionBaseEndpoint() {
        let settings = EnvironmentSettings.production
        let endpoint = settings.baseEndpoint
        #expect(endpoint == "arise.risewithaurora.com")
    }
    
    @Test("UAT baseEndpoint is correct")
    func testUatBaseEndpoint() {
        let settings = EnvironmentSettings.uat
        let endpoint = settings.baseEndpoint
        #expect(endpoint == "uat.arise.risewithaurora.com")
    }
    
    @Test("baseEndpoint does not contain protocol")
    func testBaseEndpointNoProtocol() {
        let production = EnvironmentSettings.production.baseEndpoint
        let uat = EnvironmentSettings.uat.baseEndpoint
        
        #expect(!production.contains("http"))
        #expect(!uat.contains("http"))
    }
    
    // MARK: - authApiBaseUrl Tests
    
    @Test("Production authApiBaseUrl is correct")
    func testProductionAuthApiBaseUrl() {
        let settings = EnvironmentSettings.production
        let url = settings.authApiBaseUrl
        #expect(url == "https://oauth.arise.risewithaurora.com")
    }
    
    @Test("UAT authApiBaseUrl is correct")
    func testUatAuthApiBaseUrl() {
        let settings = EnvironmentSettings.uat
        let url = settings.authApiBaseUrl
        #expect(url == "https://oauth.uat.arise.risewithaurora.com")
    }
    
    @Test("authApiBaseUrl contains https protocol")
    func testAuthApiBaseUrlHasHttps() {
        let production = EnvironmentSettings.production.authApiBaseUrl
        let uat = EnvironmentSettings.uat.authApiBaseUrl
        
        #expect(production.hasPrefix("https://"))
        #expect(uat.hasPrefix("https://"))
    }
    
    @Test("authApiBaseUrl is valid URL")
    func testAuthApiBaseUrlIsValidURL() {
        let productionURL = URL(string: EnvironmentSettings.production.authApiBaseUrl)
        let uatURL = URL(string: EnvironmentSettings.uat.authApiBaseUrl)
        
        #expect(productionURL != nil)
        #expect(uatURL != nil)
    }
    
    // MARK: - apiBaseUrl Tests
    
    @Test("Production apiBaseUrl is correct")
    func testProductionApiBaseUrl() {
        let settings = EnvironmentSettings.production
        let url = settings.apiBaseUrl
        #expect(url == "https://api.arise.risewithaurora.com")
    }
    
    @Test("UAT apiBaseUrl is correct")
    func testUatApiBaseUrl() {
        let settings = EnvironmentSettings.uat
        let url = settings.apiBaseUrl
        #expect(url == "https://api.uat.arise.risewithaurora.com")
    }
    
    @Test("apiBaseUrl contains https protocol")
    func testApiBaseUrlHasHttps() {
        let production = EnvironmentSettings.production.apiBaseUrl
        let uat = EnvironmentSettings.uat.apiBaseUrl
        
        #expect(production.hasPrefix("https://"))
        #expect(uat.hasPrefix("https://"))
    }
    
    @Test("apiBaseUrl is valid URL")
    func testApiBaseUrlIsValidURL() {
        let productionURL = URL(string: EnvironmentSettings.production.apiBaseUrl)
        let uatURL = URL(string: EnvironmentSettings.uat.apiBaseUrl)
        
        #expect(productionURL != nil)
        #expect(uatURL != nil)
    }
    
    @Test("apiBaseUrl and authApiBaseUrl are different")
    func testApiBaseUrlAndAuthApiBaseUrlAreDifferent() {
        let productionApi = EnvironmentSettings.production.apiBaseUrl
        let productionAuth = EnvironmentSettings.production.authApiBaseUrl
        
        #expect(productionApi != productionAuth)
        #expect(productionApi.contains("api."))
        #expect(productionAuth.contains("oauth."))
    }
    
    // MARK: - terminalProfileId Tests
    
    @Test("Production terminalProfileId is set")
    func testProductionTerminalProfileId() {
        let settings = EnvironmentSettings.production
        let profileId = settings.terminalProfileId
        #expect(!profileId.isEmpty)
        #expect(profileId == "4c840000-0000-0000-0fd2-e456682cc625")
    }
    
    @Test("UAT terminalProfileId is set")
    func testUatTerminalProfileId() {
        let settings = EnvironmentSettings.uat
        let profileId = settings.terminalProfileId
        #expect(!profileId.isEmpty)
        #expect(profileId == "4c840000-0000-0000-0fd2-e456682cc625")
    }
    
    @Test("terminalProfileId is valid UUID format")
    func testTerminalProfileIdIsValidUUID() {
        let productionProfileId = EnvironmentSettings.production.terminalProfileId
        let uatProfileId = EnvironmentSettings.uat.terminalProfileId
        
        let productionUUID = UUID(uuidString: productionProfileId)
        let uatUUID = UUID(uuidString: uatProfileId)
        
        #expect(productionUUID != nil)
        #expect(uatUUID != nil)
    }
    
    // MARK: - URL Correctness Tests
    
    @Test("All URLs are well-formed")
    func testAllUrlsAreWellFormed() {
        let production = EnvironmentSettings.production
        let uat = EnvironmentSettings.uat
        
        // Test authApiBaseUrl
        let productionAuthURL = URL(string: production.authApiBaseUrl)
        let uatAuthURL = URL(string: uat.authApiBaseUrl)
        #expect(productionAuthURL != nil)
        #expect(uatAuthURL != nil)
        
        // Test apiBaseUrl
        let productionApiURL = URL(string: production.apiBaseUrl)
        let uatApiURL = URL(string: uat.apiBaseUrl)
        #expect(productionApiURL != nil)
        #expect(uatApiURL != nil)
        
        // Verify schemes
        #expect(productionAuthURL?.scheme == "https")
        #expect(uatAuthURL?.scheme == "https")
        #expect(productionApiURL?.scheme == "https")
        #expect(uatApiURL?.scheme == "https")
    }
    
    @Test("Production and UAT URLs are different")
    func testProductionAndUatUrlsAreDifferent() {
        let production = EnvironmentSettings.production
        let uat = EnvironmentSettings.uat
        
        #expect(production.baseEndpoint != uat.baseEndpoint)
        #expect(production.authApiBaseUrl != uat.authApiBaseUrl)
        #expect(production.apiBaseUrl != uat.apiBaseUrl)
    }
}



