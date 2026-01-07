import Foundation

/// Network client for ARISE API authentication requests
/// Handles OAuth 2.0 Client Credentials and token refresh flows
internal class AriseAuthApi: @unchecked Sendable, AriseAuthApiProtocol {
    
    let logger = AriseLogger.shared
    let environmentSettings: EnvironmentSettings
    private let _session: AriseSessionProtocol
    private let _tokenStorage: AriseTokenStorageProtocol
    
    init(environmentSettings: EnvironmentSettings, session: AriseSessionProtocol, tokenStorage: AriseTokenStorageProtocol) {
        self.environmentSettings = environmentSettings
        self._session = session
        self._tokenStorage = tokenStorage
    }
    
    /// Perform OAuth 2.0 Client Credentials authentication.
    /// - Parameters:
    ///   - clientId: Client ID from ARISE merchant portal
    ///   - clientSecret: Client Secret from ARISE merchant portal
    /// - Returns: AuthenticationResult containing access token and metadata
    /// - Throws: AuthenticationError if authentication fails
    func authenticate(
        clientId: String,
        clientSecret: String
    ) async throws -> AuthenticationResult {
        
        logger.info("Starting ARISE authentication")
        let scope = "offline_access"
        
        return try await performTokenRequest(
            bodyParameters: [
                "grant_type": "client_credentials",
                "client_id": clientId,
                "client_secret": clientSecret,
                "scope": scope
            ],
            logTag: "[auth]"
        )
    }

    /// Refresh access token using stored client credentials and refresh token.
    /// - Returns: AuthenticationResult containing access token and metadata
    /// - Throws: AuthenticationError if required data is missing or refresh fails
    func refreshToken() async throws -> AuthenticationResult {
        logger.info("Starting ARISE token refresh")
        let scope = "offline_access"

        // Read required values from session/storage
        // Try memory first
        var clientId = _session.clientId
        var clientSecret = _session.clientSecret
        var refreshToken = _session.token?.refreshToken
        // Fallback to storage if needed
        if clientId == nil || clientSecret == nil {
            if let creds = _tokenStorage.loadCredentials() {
                clientId = creds.clientId
                clientSecret = creds.clientSecret
            }
        }
        if refreshToken == nil {
            refreshToken = _tokenStorage.load()?.refreshToken
        }
        guard let clientId, let clientSecret else {
            logger.error("Missing client credentials for refresh")
            throw AuthenticationError.unknown("Missing client credentials")
        }
        guard let refreshToken else {
            logger.error("Missing refresh token for refresh")
            throw AuthenticationError.unknown("Missing refresh token")
        }

        return try await performTokenRequest(
            bodyParameters: [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": clientId,
                "client_secret": clientSecret,
                "scope": scope
            ],
            logTag: "[refresh]"
        )
    }
        
    func formURLEncodedString(from parameters: [String: String]) -> String {
        parameters
            .map { key, value in
                let k = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let v = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(k)=\(v)"
            }
            .joined(separator: "&")
    }
    
    func performTokenRequest(bodyParameters: [String: String], logTag: String) async throws -> AuthenticationResult {
        guard let url = URL(string: "\(environmentSettings.authApiBaseUrl)/oauth2/token") else {
            logger.error("Invalid OAuth endpoint URL: \(environmentSettings.authApiBaseUrl)")
            throw AuthenticationError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = formURLEncodedString(from: bodyParameters)
        request.httpBody = bodyString.data(using: String.Encoding.utf8)
        
        var logBody = "[request body redacted]"
        #if DEBUG
        logBody = "\(bodyString, default: "")"
        #endif
        
        // Log request without sensitive body data
        logger.verbose("\(request.httpMethod ?? "") \(url.absoluteString)  \( logBody)")
        
        var responseData: Data?
        var httpResponse: HTTPURLResponse?
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            responseData = data
            httpResponse = response as? HTTPURLResponse
        } catch let urlError as URLError {
            logger.error("Network error: \(urlError.localizedDescription) \(logTag)")
            let errorMessage: String
            switch urlError.code {
            case .timedOut:
                errorMessage = "Request timed out"
            case .notConnectedToInternet:
                errorMessage = "No internet connection"
            case .cannotFindHost, .cannotConnectToHost:
                errorMessage = "Cannot connect to server"
            default:
                errorMessage = urlError.localizedDescription
            }
            throw AuthenticationError.networkError(errorMessage)
        } catch {
            logger.error("Unexpected network error: \(error.localizedDescription) \(logTag)")
            throw AuthenticationError.networkError(error.localizedDescription)
        }
        
        guard let httpResponse = httpResponse else {
            logger.error("Invalid HTTP response type")
            throw AuthenticationError.invalidResponse
        }
        
        logger.info("📥 Response: \(httpResponse.statusCode) \(logTag)")
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                logger.error("Request failed: Invalid credentials (401) \(logTag)")
                throw AuthenticationError.invalidCredentials
            }
            if let data = responseData, let body = String(data: data, encoding: .utf8) {
                logger.debug("Response body: \(body)")
            }
            logger.error("Request failed: HTTP \(httpResponse.statusCode) \(logTag)")
            throw AuthenticationError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        do {
            guard let responseData = responseData else {
                logger.error("No response data available \(logTag)")
                throw AuthenticationError.invalidResponse
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let token = try decoder.decode(OAuthTokenResponse.self, from: responseData)
            logger.info("✅ Request successful \(logTag)")
            logger.debug("Token type: \(token.tokenType), Expires in: \(token.expiresIn)s")
            return AuthenticationResult(
                accessToken: token.accessToken,
                refreshToken: token.refreshToken,
                expiresIn: token.expiresIn,
                tokenType: token.tokenType
            )
        } catch {
            if let data = responseData, let body = String(data: data, encoding: .utf8) {
                logger.debug("Response body: \(body)")
            }
            logger.error("Failed to decode response: \(error.localizedDescription) \(logTag)")
            throw AuthenticationError.invalidResponse
        }
    }
    
    struct OAuthTokenResponse: Decodable {
        let accessToken: String
        let tokenType: String
        let expiresIn: Int
        let refreshToken: String?
    }
}
