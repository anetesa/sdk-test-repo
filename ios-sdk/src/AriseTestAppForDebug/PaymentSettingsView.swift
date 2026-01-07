import SwiftUI
import AriseMobile

struct PaymentSettingsView: View {
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var paymentSettings: PaymentSettingsResponse?
    @State private var ariseSdk: AriseMobileSdk?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Payment Settings")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Retrieve payment configuration settings")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
                .padding(.top, 20)
                
                // Action Button
                VStack(alignment: .leading, spacing: 15) {
                    Text("Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Button(action: fetchPaymentSettings) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "gear")
                            }
                            Text("Get Payment Settings")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.6 : 1.0)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Error Section
                if !errorMessage.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Error")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Results Section
                if let settings = paymentSettings {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Payment Settings")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        // Currency Settings
                        SettingsSection(title: "Currency Settings", icon: "dollarsign.circle.fill", color: .green) {
                            if settings.availableCurrencies.isEmpty {
                                Text("No currencies available")
                                    .foregroundColor(Color(.secondaryLabel))
                            } else {
                                ForEach(settings.availableCurrencies, id: \.id) { currency in
                                    HStack {
                                        Text("ID: \(currency.id)")
                                            .font(.caption)
                                        Spacer()
                                        if let name = currency.name {
                                            Text(name)
                                                .fontWeight(.semibold)
                                        } else {
                                            Text("N/A")
                                                .foregroundColor(Color(.secondaryLabel))
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        // ZCP Configuration
                        SettingsSection(title: "Zero Cost Processing (ZCP)", icon: "percent", color: .purple) {
                            if let zcpId = settings.zeroCostProcessingOptionId {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Option ID:")
                                        Spacer()
                                        Text("\(zcpId)")
                                            .fontWeight(.semibold)
                                    }
                                    if let zcpName = settings.zeroCostProcessingOption {
                                        HStack {
                                            Text("Option Name:")
                                            Spacer()
                                            Text(zcpName)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                            } else {
                                Text("Not configured")
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                if let surchargeRate = settings.defaultSurchargeRate {
                                    HStack {
                                        Text("Default Surcharge Rate:")
                                        Spacer()
                                        Text("\(surchargeRate, specifier: "%.2f")%")
                                            .fontWeight(.semibold)
                                    }
                                }
                                if let cashDiscountRate = settings.defaultCashDiscountRate {
                                    HStack {
                                        Text("Default Cash Discount Rate:")
                                        Spacer()
                                        Text("\(cashDiscountRate, specifier: "%.2f")%")
                                            .fontWeight(.semibold)
                                    }
                                }
                                if let dualPricingRate = settings.defaultDualPricingRate {
                                    HStack {
                                        Text("Default Dual Pricing Rate:")
                                        Spacer()
                                        Text("\(dualPricingRate, specifier: "%.2f")%")
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                        
                        // Tips Configuration
                        SettingsSection(title: "Tips Configuration", icon: "hand.raised.fill", color: .orange) {
                            HStack {
                                Text("Tips Enabled:")
                                Spacer()
                                Text(settings.isTipsEnabled ? "Yes" : "No")
                                    .fontWeight(.semibold)
                                    .foregroundColor(settings.isTipsEnabled ? .green : .red)
                            }
                            
                            if let tipsOptions = settings.defaultTipsOptions, !tipsOptions.isEmpty {
                                Divider()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Default Tip Options:")
                                        .fontWeight(.medium)
                                    ForEach(Array(tipsOptions.enumerated()), id: \.offset) { index, tip in
                                        HStack {
                                            Text("Option \(index + 1):")
                                            Spacer()
                                            Text("\(tip, specifier: "%.2f")%")
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Card Types
                        SettingsSection(title: "Card Types", icon: "creditcard.fill", color: .blue) {
                            if settings.availableCardTypes.isEmpty {
                                Text("No card types available")
                                    .foregroundColor(Color(.secondaryLabel))
                            } else {
                                ForEach(settings.availableCardTypes, id: \.id) { cardType in
                                    HStack {
                                        Text("ID: \(cardType.id)")
                                            .font(.caption)
                                        Spacer()
                                        if let name = cardType.name {
                                            Text(name)
                                                .fontWeight(.semibold)
                                        } else {
                                            Text("N/A")
                                                .foregroundColor(Color(.secondaryLabel))
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        // Transaction Types
                        SettingsSection(title: "Transaction Types", icon: "arrow.triangle.2.circlepath", color: .teal) {
                            if settings.availableTransactionTypes.isEmpty {
                                Text("No transaction types available")
                                    .foregroundColor(Color(.secondaryLabel))
                            } else {
                                ForEach(settings.availableTransactionTypes, id: \.id) { transactionType in
                                    HStack {
                                        Text("ID: \(transactionType.id)")
                                            .font(.caption)
                                        Spacer()
                                        if let name = transactionType.name {
                                            Text(name)
                                                .fontWeight(.semibold)
                                        } else {
                                            Text("N/A")
                                                .foregroundColor(Color(.secondaryLabel))
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        // Payment Processors
                        SettingsSection(title: "Payment Processors", icon: "building.2.fill", color: .indigo) {
                            if settings.availablePaymentProcessors.isEmpty {
                                Text("No payment processors available")
                                    .foregroundColor(Color(.secondaryLabel))
                            } else {
                                ForEach(Array(settings.availablePaymentProcessors.enumerated()), id: \.offset) { index, processor in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            if let name = processor.name {
                                                Text(name)
                                                    .fontWeight(.semibold)
                                            } else {
                                                Text("Processor \(index + 1)")
                                                    .fontWeight(.semibold)
                                            }
                                            Spacer()
                                            if processor.isDefault == true {
                                                Text("Default")
                                                    .font(.caption)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.green.opacity(0.2))
                                                    .foregroundColor(.green)
                                                    .cornerRadius(4)
                                            }
                                        }
                                        
                                        if let id = processor.id {
                                            Text("ID: \(id)")
                                                .font(.caption)
                                                .foregroundColor(Color(.secondaryLabel))
                                        }
                                        
                                        if let type = processor.type {
                                            Text("Type: \(type)")
                                                .font(.caption)
                                                .foregroundColor(Color(.secondaryLabel))
                                        }
                                        
                                        if let timeSlots = processor.settlementBatchTimeSlots, !timeSlots.isEmpty {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Settlement Time Slots:")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                ForEach(Array(timeSlots.enumerated()), id: \.offset) { _, slot in
                                                    if let hours = slot.hours, let minutes = slot.minutes {
                                                        HStack {
                                                            Text("\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))")
                                                                .font(.caption)
                                                            if let timezone = slot.timezoneName {
                                                                Text("(\(timezone))")
                                                                    .font(.caption)
                                                                    .foregroundColor(Color(.secondaryLabel))
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.top, 4)
                                        }
                                        
                                        if index < settings.availablePaymentProcessors.count - 1 {
                                            Divider()
                                                .padding(.vertical, 4)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        // AVS Options
                        if let avs = settings.avs {
                            SettingsSection(title: "Address Verification System (AVS)", icon: "shield.fill", color: .red) {
                                HStack {
                                    Text("AVS Enabled:")
                                    Spacer()
                                    if let isEnabled = avs.isEnabled {
                                        Text(isEnabled ? "Yes" : "No")
                                            .fontWeight(.semibold)
                                            .foregroundColor(isEnabled ? .green : .red)
                                    } else {
                                        Text("N/A")
                                            .foregroundColor(Color(.secondaryLabel))
                                    }
                                }
                                
                                if let profileId = avs.profileId {
                                    Divider()
                                    HStack {
                                        Text("Profile ID:")
                                        Spacer()
                                        Text("\(profileId)")
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                if let profile = avs.profile {
                                    Divider()
                                    HStack {
                                        Text("Profile:")
                                        Spacer()
                                        Text(profile)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                        
                        // Receipt Preferences
                        SettingsSection(title: "Receipt Preferences", icon: "printer.fill", color: .gray) {
                            HStack {
                                Text("Customer Card Saving Enabled:")
                                Spacer()
                                Text(settings.isCustomerCardSavingByTerminalEnabled ? "Yes" : "No")
                                    .fontWeight(.semibold)
                                    .foregroundColor(settings.isCustomerCardSavingByTerminalEnabled ? .green : .red)
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Payment Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            initializeSdkIfNeeded()
        }
    }
    
    private func fetchPaymentSettings() {
        isLoading = true
        errorMessage = ""
        paymentSettings = nil
        
        guard let ariseSdkInstance = getSdk() else {
            errorMessage = "SDK not initialized"
            isLoading = false
            return
        }
        
        Task {
            do {
                let settings = try await ariseSdkInstance.getPaymentSettings()
                await MainActor.run {
                    self.paymentSettings = settings
                    self.errorMessage = ""
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.paymentSettings = nil
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func initializeSdkIfNeeded() {
        if ariseSdk == nil {
            do {
                let newSdk = try AriseMobileSdk(environment: .uat)
                newSdk.setLogLevel(.verbose)
                ariseSdk = newSdk
            } catch {
                errorMessage = "Failed to initialize SDK: \(error.localizedDescription)"
            }
        }
    }
    
    private func getSdk() -> AriseMobileSdk? {
        if ariseSdk == nil {
            initializeSdkIfNeeded()
        }
        return ariseSdk
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            content
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        PaymentSettingsView()
    }
}

