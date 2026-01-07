import SwiftUI
import AriseMobile

struct DeviceDetailView: View {
    let ariseSdk: AriseMobileSdk?
    let deviceId: String
    
    @State private var deviceInfo: DeviceInfo?
    @State private var isLoading = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("Loading device information...")
                        .padding()
                } else if let device = deviceInfo {
                    deviceInfoView(device)
                } else if !errorMessage.isEmpty {
                    errorView
                } else {
                    Text("No device information available")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Device Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !deviceId.isEmpty {
                fetchDeviceInfo()
            } else {
                errorMessage = "Device ID is required"
            }
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: fetchDeviceInfo) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private func deviceInfoView(_ device: DeviceInfo) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Device ID
            infoSection(title: "Device ID", value: device.deviceId ?? "N/A")
            
            Divider()
            
            // Device Name
            infoSection(title: "Device Name", value: device.deviceName ?? "N/A")
            
            Divider()
            
            // Tap to Pay Status
            VStack(alignment: .leading, spacing: 8) {
                Text("Tap to Pay Status")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let status = device.tapToPayStatus {
                    Text(status)
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    Text("Unknown")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                if let statusId = device.tapToPayStatusId {
                    Text("Status ID: \(statusId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("TTP Enabled:")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: device.tapToPayEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(device.tapToPayEnabled ? .green : .red)
                    Text(device.tapToPayEnabled ? "Yes" : "No")
                        .font(.subheadline)
                }
            }
            
            Divider()
            
            // Last Login
            if let lastLogin = device.lastLoginAt {
                infoSection(
                    title: "Last Login",
                    value: lastLogin.formatted(date: .abbreviated, time: .shortened)
                )
            } else {
                infoSection(title: "Last Login", value: "Never")
            }
            
            Divider()
            
            // User Profiles
            VStack(alignment: .leading, spacing: 8) {
                Text("User Profiles")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if device.userProfiles.isEmpty {
                    Text("No user profiles associated")
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(device.userProfiles.indices, id: \.self) { index in
                        let profile = device.userProfiles[index]
                        VStack(alignment: .leading, spacing: 4) {
                            if let firstName = profile.firstName, let lastName = profile.lastName {
                                Text("\(firstName) \(lastName)")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            } else if let firstName = profile.firstName {
                                Text(firstName)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            } else if let lastName = profile.lastName {
                                Text(lastName)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            } else {
                                Text("User \(index + 1)")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            
                            if let email = profile.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if index < device.userProfiles.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func infoSection(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private func fetchDeviceInfo() {
        errorMessage = ""
        guard let ariseSdk else {
            errorMessage = "SDK not initialized"
            return
        }
        
        guard !deviceId.isEmpty else {
            errorMessage = "Device ID is empty"
            return
        }
        
        isLoading = true
        Task {
            do {
                let device = try await ariseSdk.getDeviceInfo(deviceId: deviceId)
                await MainActor.run {
                    self.deviceInfo = device
                    self.isLoading = false
                    self.errorMessage = ""
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.deviceInfo = nil
                }
            }
        }
    }
}

