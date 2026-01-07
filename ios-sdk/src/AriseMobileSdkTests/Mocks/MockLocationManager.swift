import Foundation
import CoreLocation
@testable import AriseMobile

/// Mock implementation of CLLocationManager for testing location permissions
final class MockLocationManager: CLLocationManager {
    
    // MARK: - Configuration
    
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var shouldRequestAuthorization = true
    
    // MARK: - Call Tracking
    
    private(set) var requestWhenInUseAuthorizationCallCount = 0
    private(set) var requestAlwaysAuthorizationCallCount = 0
    
    // MARK: - Override Properties
    
    override var authorizationStatus: CLAuthorizationStatus {
        return mockAuthorizationStatus
    }
    
    // MARK: - Override Methods
    
    override func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCallCount += 1
        if shouldRequestAuthorization {
            // Simulate authorization change after request
            // In real tests, you might want to use a callback or async mechanism
            mockAuthorizationStatus = .authorizedWhenInUse
        }
    }
    
    override func requestAlwaysAuthorization() {
        requestAlwaysAuthorizationCallCount += 1
        if shouldRequestAuthorization {
            mockAuthorizationStatus = .authorizedAlways
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        mockAuthorizationStatus = .notDetermined
        shouldRequestAuthorization = true
        requestWhenInUseAuthorizationCallCount = 0
        requestAlwaysAuthorizationCallCount = 0
    }
}

