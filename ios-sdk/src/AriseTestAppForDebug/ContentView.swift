import SwiftUI
import UIKit
import ProximityReader
import AriseMobile

struct ContentView: View {
    @State private var sdkVersion: String = "Loading..."
    @State private var cloudCommerceVersion: String = "Loading..."
    @State private var deviceId: String = "Loading..."
    @State private var accessToken: String = "Not authenticated"
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var logLevel: LogLevel = .verbose
    @State private var tokenStatus: String = "Unknown"
    @State private var tokenPreview: String = ""
    @State private var ariseSdk: AriseMobileSdk?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("ARISE Mobile SDK Test App")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Test your framework functionality")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // SDK Information Card
                VStack(alignment: .leading, spacing: 15) {
                    Text("SDK Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("ARISE Mobile SDK Version:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(sdkVersion)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("CloudCommerce Version:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(cloudCommerceVersion)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Device ID:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(deviceId)
                                .foregroundColor(.purple)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .font(.system(size: 10, design: .monospaced))
                                .onTapGesture {
                                    UIPasteboard.general.string = deviceId
                                    errorMessage = "Device ID copied to clipboard"
                                }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Access Token:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(accessToken)
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Log Level:")
                                .fontWeight(.medium)
                            Spacer()
                            Picker("Log Level", selection: $logLevel) {
                                ForEach(LogLevel.allCases, id: \.self) { level in
                                    Text(level.description).tag(level)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: logLevel) { newLevel in
                                updateLogLevel(newLevel)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    if !errorMessage.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Error:")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()

                // Token Status Card
                VStack(alignment: .leading, spacing: 15) {
                    Text("Token Status")
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(spacing: 10) {
                        HStack {
                            Text("Access Token:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(tokenStatus)
                                .foregroundColor(tokenStatus == "Present" ? .green : .secondary)
                                .fontWeight(.semibold)
                        }
                        if !tokenPreview.isEmpty {
                            Text(tokenPreview)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        HStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await checkToken()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                    Text("Check Access Token")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.15))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                            }
                            Button(action: {
                                Task {
                                    await restoreSession()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Restore Session")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            }
                            Button(action: {
                                Task {
                                    await clearToken()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear Token")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.15))
                                .foregroundColor(.red)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: refreshVersions) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Refresh SDK Information")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    
                    Button(action: refreshToken) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Refresh Token")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)

                    Button(action: showTapToPayEducationContent) {
                        HStack {
                            Image(systemName: "book")
                            Text("Show Tap to Pay Guide")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Button(action: authenticateWithArise) {
                        HStack {
                            Image(systemName: "key")
                            Text("Authenticate with ARISE")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    
                    NavigationLink(destination: TransactionsHubView()) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                            Text("Transactions Hub")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: DevicesHubView(ariseSdk: getAriseSdk())) {
                        HStack {
                            Image(systemName: "iphone.gen3")
                            Text("Devices Hub")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: TTPHubView(ariseSdk: getAriseSdk())) {
                        HStack {
                            Image(systemName: "waveform.circle.fill")
                            Text("TTP Hub")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                }
            }
            .navigationTitle("SDK Test")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            initializeSdkIfNeeded()
            refreshVersions()
            Task{
               await checkToken()
            }
        }
    }
    
    private func refreshVersions() {
        
        isLoading = true
        errorMessage = ""
        
        guard let ariseSdk = getAriseSdk() else {
            errorMessage = "SDK not initialized"
            isLoading = false
            return
        }
        
        ariseSdk.setLogLevel(logLevel)
        
        // Get AriseMobileSdk version (synchronous)
        sdkVersion = ariseSdk.getVersion()
        
        // Get Device ID (synchronous)
        deviceId = ariseSdk.getDeviceId()
        
        // Get CloudCommerce version (asynchronous with error handling)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let version = try ariseSdk.getCloudCommerceVersion()
                DispatchQueue.main.async {
                    self.cloudCommerceVersion = version
                    self.errorMessage = ""
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.cloudCommerceVersion = "Error"
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func authenticateWithArise() {
        isLoading = true
        errorMessage = ""
        
        guard let ariseSdk = getAriseSdk() else {
            errorMessage = "SDK not initialized"
            isLoading = false
            return
        }
        
        ariseSdk.setLogLevel(.verbose)
        // Test data for local debug

        // for UAT
        //Caio's Barber Shop
//        let clientId = "c77a6b77-2545-4352-98dc-60de53d11eb7"
//        let clientSecret = "cddb9e9c-fa48-4dbc-96e7-86739959e92a"
        
        
        
        // Andriy
        let clientId = "550d101e-48f0-4be7-8083-ac68e9805780"
        let clientSecret = "31771069-4d24-45af-b73d-69cf9e559985"
        
//        let clientId = "0c3578ce-d6cb-4cc8-b892-7f5da4bb6ce1"
//        let clientSecret = "e19461af-02cb-4bc6-8acf-f192153075f9"
          
        //Alex's Car Wash
//        let clientId = "05464bc9-58d9-4dd9-ba8b-fa9f595830c3"
//        let clientSecret = "ee0f27df-a6a6-4a30-ab80-1d8c84e74447"
        
        
    
        // for DEV
//        let clientId = "61f9cc3b-1299-4947-a8fa-2eed705b9e90"
//        let clientSecret = "32e970b1-0faa-4d66-a30d-30db7c7cadd7"
        
        
        
        Task {
            do {
                let authResult = try await ariseSdk.authenticate(clientId: clientId, clientSecret: clientSecret)
                await MainActor.run {
                    self.accessToken = "✅ \(authResult.accessToken.prefix(20))..."
                    print("accessToken \(authResult.accessToken)")
                    self.errorMessage = "Authentication successful! Token expires in \(authResult.expiresIn) seconds"
                    self.isLoading = false
                }
                await checkToken()
            } catch {
                await MainActor.run {
                    self.accessToken = "❌ Authentication failed"
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func updateLogLevel(_ newLevel: LogLevel) {
        getAriseSdk()?.setLogLevel(newLevel)
    }
    
    private func refreshToken() {
        isLoading = true
        errorMessage = ""
        
        guard let ariseSdk = getAriseSdk() else {
            errorMessage = "SDK not initialized"
            isLoading = false
            return
        }
        
        Task {
            do {
                let authResult = try await ariseSdk.refreshAccessToken()
                await MainActor.run {
                    self.accessToken = "✅ \(authResult.accessToken.prefix(20))..."
                    self.errorMessage = "Token refreshed! Expires in \(authResult.expiresIn) seconds"
                    self.isLoading = false
                }
                await checkToken()
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                await checkToken()
            }
        }
    }

    private func checkToken() async {
        guard let ariseSdk = getAriseSdk() else {
            tokenStatus = "Absent"
            tokenPreview = ""
            return
        }
        
        if let token = await ariseSdk.getAccessToken() {
            tokenStatus = "Present"
            let prefix = String(token.prefix(6))
            let suffix = String(token.suffix(4))
            tokenPreview = "Token: \(prefix)...\(suffix)"
        } else {
            tokenStatus = "Absent"
            tokenPreview = ""
        }
    }
    
    private func clearToken() async {
        getAriseSdk()?.clearStoredToken()
        await checkToken()
    }
    
    private func restoreSession() async {
        await checkToken()
    }
    
    private func initializeSdkIfNeeded() {
        if ariseSdk == nil {
            do {
                let newSdk = try AriseMobileSdk(environment: .uat)
                newSdk.setLogLevel(logLevel)
                ariseSdk = newSdk
            } catch {
                errorMessage = "Failed to initialize SDK: \(error.localizedDescription)"
            }
        }
    }
    
    private func getAriseSdk() -> AriseMobileSdk? {
        if ariseSdk == nil {
            initializeSdkIfNeeded()
        }
        return ariseSdk
    }
    
    private func currentViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?
        .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return currentViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
    
    private func showTapToPayEducationContent() {
        guard #available(iOS 18.0, *) else {
            errorMessage = "Tap to Pay guide requires iOS 18.0 or later."
            return
        }
        
        guard let presenter = currentViewController() else {
            errorMessage = "Unable to find a presenter for Tap to Pay guide."
            return
        }
        
        let proximityReaderDiscovery = ProximityReaderDiscovery()
        Task {
            do {
                let content = try await proximityReaderDiscovery.content(for: .payment(.howToTap))
                try await proximityReaderDiscovery.presentContent(content, from: presenter)
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
}
