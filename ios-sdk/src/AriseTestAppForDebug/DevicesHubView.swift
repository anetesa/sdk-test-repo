import SwiftUI
import AriseMobile

struct DevicesHubView: View {
    let ariseSdk: AriseMobileSdk?
    
    @State private var devices: [DeviceInfo] = []
    @State private var isLoading = false
    @State private var errorMessage: String = ""
    @State private var manualDeviceId: String = ""
    @State private var showManualInput = false
    
    var body: some View {
        VStack(spacing: 16) {
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: fetchDevices) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.down.circle")
                    }
                    Text("Fetch Devices")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoading)
            
            Button(action: { showManualInput.toggle() }) {
                HStack {
                    Image(systemName: showManualInput ? "eye.slash" : "magnifyingglass")
                    Text(showManualInput ? "Hide Manual Input" : "Get Device by ID")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if showManualInput {
                VStack(spacing: 12) {
                    TextField("Enter Device ID (UUID)", text: $manualDeviceId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    NavigationLink(destination: DeviceDetailView(ariseSdk: ariseSdk, deviceId: manualDeviceId)) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("View Device Details")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(manualDeviceId.isEmpty ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(manualDeviceId.isEmpty)
                }
                .padding(.horizontal)
            }
            
            if devices.isEmpty && !isLoading {
                Text("No devices loaded yet.")
                    .foregroundColor(.secondary)
            } else {
                List(devices, id: \.deviceId) { device in
                    NavigationLink(destination: DeviceDetailView(ariseSdk: ariseSdk, deviceId: device.deviceId ?? "")) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.deviceName ?? "Unknown device")
                                .font(.headline)
                            Text("Status: \(device.tapToPayStatus ?? "Unknown")")
                                .font(.subheadline)
                            if let date = device.lastLoginAt {
                                Text("Last login: \(date.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if !device.userProfiles.isEmpty {
                                Text("Users: \(device.userProfiles.map { ($0.firstName ?? "") + " " + ($0.lastName ?? "") }.joined(separator: ", "))")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Devices")
    }
    
    private func fetchDevices() {
        errorMessage = ""
        guard let ariseSdk else {
            errorMessage = "SDK not initialized"
            return
        }
        
        isLoading = true
        Task {
            do {
                let response = try await ariseSdk.getDevices()
                await MainActor.run {
                    self.devices = response.devices
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}


