import SwiftUI
import AriseMobile
import CoreLocation
import Combine
import UIKit

struct TTPHubView: View {
    let ariseSdk: AriseMobileSdk?
    
    @State private var compatibilityResult: TTPCompatibilityResult?
    @State private var ttpStatus: TTPStatus?
    @State private var isLoading = false
    @State private var isLoadingStatus = false
    @State private var errorMessage: String = ""
    @State private var statusErrorMessage: String = ""
    @State private var isPreparing = false
    @State private var prepareError: String = ""
    @State private var isPrepared = false
    @State private var isResuming = false
    @State private var resumeError: String = ""
    @State private var isResumed = false
    @State private var isActivating = false
    @State private var activateError: String = ""
    @State private var activateStatus: TTPStatus?
    @State private var educationalInfoError: String = ""
    @State private var isShowingEducationalInfo = false
    @State private var transactionAmount: String = "10.00"
    @State private var currencyCode: String = "USD"
    @State private var orderId: String = ""
    @State private var surchargeRate: String = ""
    @State private var isPerformingTransaction = false
    @State private var transactionError: String = ""
    @State private var transactionResult: TTPTransactionResult?
    @State private var isPerformingTransactionWithAbort = false
    @State private var abortTask: Task<Void, Never>?
    @State private var isPerformingAdvancedTransaction = false
    @State private var isDebitCard = false
    @State private var calculationResult: CalculateAmountResponse?
    @State private var isListeningEvents = false
    @State private var events: [EventItem] = []
    @State private var eventStreamError: String = ""
    @State private var eventStreamTask: Task<Void, Never>?
    @StateObject private var locationManager = LocationManager()
    
    struct EventItem: Identifiable {
        let id = UUID()
        let timestamp: Date
        let event: TTPEvent
        let description: String
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                if !errorMessage.isEmpty {
                    errorMessageView
                }
                
                compatibilityCheckSection
                
                Divider()
                    .padding(.vertical, 10)
                
                statusCheckSection
                
                Divider()
                    .padding(.vertical, 10)
                
                prepareSection
                
                Divider()
                    .padding(.vertical, 10)
                

                resumeSection

                activateSection

                Divider()
                    .padding(.vertical, 10)
                
                performTransactionSection
                
                Divider()
                    .padding(.vertical, 10)
                
                eventsStreamSection
                
                Divider()
                    .padding(.vertical, 10)
                
                educationalInfoSection
                
                compatibilityResultView
                
                ttpStatusView
                
                Spacer()
            }
        }
        .navigationTitle("TTP Compatibility")
        .onAppear {
            if compatibilityResult == nil {
                checkCompatibility()
            }
        }
        .onChange(of: locationManager.authorizationStatus) {
            // Refresh compatibility check when location permission changes
            checkCompatibility()
        }
        .onDisappear {
            // Stop event stream when view disappears
            stopEventStream()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("Tap to Pay Compatibility")
                .font(.title)
                .fontWeight(.bold)
            Text("Check if your device supports Tap to Pay")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var errorMessageView: some View {
        Text(errorMessage)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
    }
    
    private var compatibilityCheckSection: some View {
        VStack(spacing: 12) {
            Text("Compatibility Check")
                .font(.headline)
                .fontWeight(.semibold)
            
            Button(action: checkCompatibility) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.circle")
                    }
                    Text("Check Compatibility")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoading)
        }
        .padding(.horizontal)
    }
    
    private var statusCheckSection: some View {
        VStack(spacing: 12) {
            Text("Activation Status")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !statusErrorMessage.isEmpty {
                Text(statusErrorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Button(action: { Task { await getStatus() } }) {
                HStack {
                    if isLoadingStatus {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.clockwise.circle")
                    }
                    Text("Get Status")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoadingStatus)
        }
        .padding(.horizontal)
    }
    
    private var prepareSection: some View {
        VStack(spacing: 12) {
            Text("Prepare Tap to Pay")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !prepareError.isEmpty {
                Text(prepareError)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            if isPrepared {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Tap to Pay is prepared and ready")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button(action: { Task { await prepareTTP() } }) {
                HStack {
                    if isPreparing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "play.circle.fill")
                    }
                    Text("Prepare")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isPreparing)
        }
        .padding(.horizontal)
    }
    

    private var resumeSection: some View {
        VStack(spacing: 12) {
            Text("Resume Tap to Pay")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !resumeError.isEmpty {
                Text(resumeError)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            if isResumed {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Tap to Pay resumed successfully")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button(action: { Task { await resumeTTP() } }) {
                HStack {
                    if isResuming {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.clockwise.circle.fill")
                    }
                    Text("Resume")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isResuming)
        }
        .padding(.horizontal)
    }

    private var activateSection: some View {
        VStack(spacing: 12) {
            Text("Activate Tap to Pay")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !activateError.isEmpty {
                Text(activateError)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            if let status = activateStatus {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: status == .active ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(status == .active ? .green : .orange)
                        Text(status == .active ? "Activation Successful" : "Activation Completed")
                            .foregroundColor(status == .active ? .green : .orange)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Status: \(status.rawValue.capitalized)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button(action: { Task { await activateTTP() } }) {
                HStack {
                    if isActivating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "power.circle.fill")
                    }
                    Text("Activate")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isActivating)
        }
        .padding(.horizontal)
    }
    
    private var performTransactionSection: some View {
        VStack(spacing: 12) {
            Text("Perform Transaction")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !transactionError.isEmpty {
                Text(transactionError)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Enter amount", text: $transactionAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Currency Code (Optional - for deprecated method)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("USD", text: $currencyCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Order ID (Optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("Leave empty if not needed", text: $orderId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction)
                    
                    Button(action: {
                        orderId = UUID().uuidString
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                    .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Surcharge Rate (Optional - for deprecated method)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Enter surcharge rate", text: $surchargeRate)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction)
            }
            
            Button(action: { Task { await performTransaction() } }) {
                HStack {
                    if isPerformingTransaction {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "creditcard.fill")
                    }
                    Text("Perform Simple Transaction")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction || transactionAmount.isEmpty)
            
            // Advanced Transaction Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Advanced Transaction")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Toggle("Is Debit Card", isOn: $isDebitCard)
                    .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction)
                
                Button(action: { Task { await performAdvancedTransaction() } }) {
                    HStack {
                        if isPerformingAdvancedTransaction {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                        }
                        Text("Perform Advanced Transaction")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction || transactionAmount.isEmpty)
            }
            .padding(.top, 8)
            
            // Display calculation result if available
            if let calculation = calculationResult {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Calculation Result:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    if let creditCard = calculation.creditCard {
                        Text("Credit Card Total: \(String(format: "%.2f", creditCard.totalAmount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let debitCard = calculation.debitCard {
                        Text("Debit Card Total: \(String(format: "%.2f", debitCard.totalAmount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Transaction Result
            if let result = transactionResult {
                VStack(spacing: 16) {
                    Text("Transaction Result")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        // Status
                        HStack {
                            Image(systemName: result.status == .approved ? "checkmark.circle.fill" : result.status == .declined ? "xmark.circle.fill" : "exclamationmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(result.status == .approved ? .green : result.status == .declined ? .red : .orange)
                            Text(result.status.rawValue.capitalized)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(result.status == .approved ? .green : result.status == .declined ? .red : .orange)
                        }
                        
                        // Transaction Details
                        VStack(alignment: .leading, spacing: 8) {
                            if let transactionId = result.transactionId {
                                DetailRow(label: "Transaction ID", value: transactionId)
                            }
                            if let authCode = result.authorizationCode {
                                DetailRow(label: "Auth Code", value: authCode)
                            }
                            if let amount = result.authorizedAmount {
                                DetailRow(label: "Amount", value: amount)
                            }
                            if let responseCode = result.authorisationResponseCode {
                                DetailRow(label: "Response Code", value: responseCode)
                            }
                            if let cardBrand = result.cardBrandName {
                                DetailRow(label: "Card Brand", value: cardBrand)
                            }
                            if let maskedCard = result.maskedCardNumber {
                                DetailRow(label: "Card Number", value: maskedCard)
                            }
                            if let cvmAction = result.cvmAction {
                                DetailRow(label: "CVM Action", value: cvmAction)
                            }
                            if let authorizedDate = result.authorizedDate {
                                DetailRow(label: "Date", value: authorizedDate)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(result.status == .approved ? Color.green.opacity(0.1) : result.status == .declined ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.top, 12)
            }
            
            // Deprecated: Old transaction method with abort
            Button(action: { Task { await performTransactionWithAbort() } }) {
                HStack {
                    if isPerformingTransactionWithAbort {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "xmark.circle.fill")
                    }
                    Text("⚠️ Deprecated: Transaction with Abort (5s)")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isPerformingTransaction || isPerformingTransactionWithAbort || isPerformingAdvancedTransaction || transactionAmount.isEmpty || currencyCode.isEmpty)
        }
        .padding(.horizontal)
    }
    
    private var eventsStreamSection: some View {
        VStack(spacing: 12) {
            Text("Events Stream")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !eventStreamError.isEmpty {
                Text(eventStreamError)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    if isListeningEvents {
                        stopEventStream()
                    } else {
                        startEventStream()
                    }
                }) {
                    HStack {
                        Image(systemName: isListeningEvents ? "stop.circle.fill" : "play.circle.fill")
                        Text(isListeningEvents ? "Stop Stream" : "Start Stream")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isListeningEvents ? Color.red : Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                if !events.isEmpty {
                    Button(action: {
                        events.removeAll()
                    }) {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                            Text("Clear")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            
            if isListeningEvents {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    Text("Listening for events...")
                        .foregroundColor(.purple)
                        .font(.caption)
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            }
            
            if !events.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Events (\(events.count))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(events.reversed()) { eventItem in
                                EventRow(eventItem: eventItem)
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    private var educationalInfoSection: some View {
        VStack(spacing: 12) {
            Text("Educational Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !educationalInfoError.isEmpty {
                Text(educationalInfoError)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Button(action: { Task { await showEducationalInfo() } }) {
                HStack {
                    if isShowingEducationalInfo {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "book.fill")
                    }
                    Text("Show Educational Info")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isShowingEducationalInfo)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var compatibilityResultView: some View {
        if let result = compatibilityResult {
                    VStack(spacing: 16) {
                        // Overall Status
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: result.isCompatible ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(result.isCompatible ? .green : .red)
                                Text(result.isCompatible ? "Compatible" : "Not Compatible")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(result.isCompatible ? .green : .red)
                            }
                            
                            if !result.incompatibilityReasons.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Issues:")
                                        .font(.headline)
                                    ForEach(result.incompatibilityReasons, id: \.self) { reason in
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                                .font(.caption)
                                            Text(reason)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(result.isCompatible ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Device Model Check
                        CompatibilityCard(
                            title: "Device Model",
                            isCompatible: result.deviceModelCheck.isCompatible,
                            details: [
                                ("Model", DeviceModelNameMapper.getDeviceName(for: result.deviceModelCheck.modelIdentifier)),
                                ("Identifier", result.deviceModelCheck.modelIdentifier),
                                ("Status", result.deviceModelCheck.isCompatible ? "Compatible (iPhone XS or newer)" : "Not compatible")
                            ]
                        )
                        
                        // iOS Version Check
                        CompatibilityCard(
                            title: "iOS Version",
                            isCompatible: result.iosVersionCheck.isCompatible,
                            details: [
                                ("Current Version", "iOS \(result.iosVersionCheck.version)"),
                                ("Required", "iOS \(result.iosVersionCheck.minimumRequiredVersion) or newer"),
                                ("Status", result.iosVersionCheck.isCompatible ? "Compatible" : "Update required")
                            ]
                        )
                        
                        // Location Permission
                        VStack(spacing: 12) {
                            CompatibilityCard(
                                title: "Location Permission",
                                isCompatible: result.locationPermission == .granted,
                                details: [
                                    ("Status", result.locationPermission.rawValue.capitalized),
                                    ("Required", "Granted")
                                ]
                            )
                            
                            if result.locationPermission != .granted {
                                Button(action: requestLocationPermission) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                        Text(result.locationPermission == .undetermined ? "Request Location Permission" : "Open Settings")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(result.locationPermission == .undetermined ? Color.blue : Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        // Tap to Pay Entitlement
                        CompatibilityCard(
                            title: "Tap to Pay Entitlement",
                            isCompatible: result.tapToPayEntitlement == .available,
                            details: [
                                ("Status", result.tapToPayEntitlement.rawValue.capitalized),
                                ("Required", "Available")
                            ]
                        )
                    }
                    .padding(.horizontal)
        } else if !isLoading {
            VStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                Text("Tap 'Check Compatibility' to see if your device supports Tap to Pay")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var ttpStatusView: some View {
        VStack(spacing: 16) {
            if isLoadingStatus {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading status...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let status = ttpStatus {
                VStack(spacing: 16) {
                    Text("Tap to Pay Status")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: status == .active ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(status == .active ? .green : .red)
                            Text(status == .active ? "Active" : "Inactive")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(status == .active ? .green : .red)
                        }
                        
                        // Debug info
                        Text("Status: \(status.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if status == .inactive {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tap to Pay is not activated")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                                Text("Guide the user through activation process")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(status == .active ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Tap 'Get Status' to check Tap to Pay activation status")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .padding(.horizontal)
    }
    
    private func checkCompatibility() {
        errorMessage = ""
        guard let ariseSdk else {
            errorMessage = "SDK not initialized"
            return
        }
        
        isLoading = true
        
        // checkCompatibility is synchronous and non-blocking
        let result = ariseSdk.ttp.checkCompatibility()
        self.compatibilityResult = result
        self.isLoading = false
    }
    
    private func requestLocationPermission() {
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
            // Open Settings if permission was denied
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        } else {
            // Request permission
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func prepareTTP() async {
        prepareError = ""
        guard let ariseSdk else {
            await MainActor.run {
                prepareError = "SDK not initialized"
            }
            return
        }
        
        await MainActor.run {
            isPreparing = true
            isPrepared = false
        }
        
        do {
            try await ariseSdk.ttp.prepare()
            print("✅ TTP prepared successfully")
            await MainActor.run {
                self.isPrepared = true
                self.isPreparing = false
                self.prepareError = ""
            }
        } catch let ttpError as TTPError {
            print("❌ TTP Error: \(ttpError)")
            await MainActor.run {
                prepareError = ttpError.errorDescription ?? "Unknown TTP error occurred"
                self.isPreparing = false
                self.isPrepared = false
            }
        } catch let apiError as AriseApiError {
            print("❌ API Error preparing TTP: \(apiError)")
            await MainActor.run {
                prepareError = apiError.errorInfo?.details ?? apiError.errorDescription ?? "Unknown API error occurred"
                self.isPreparing = false
                self.isPrepared = false
            }
        } catch {
            print("❌ Error preparing TTP: \(error)")
            await MainActor.run {
                prepareError = "Error: \(error.localizedDescription)"
                self.isPreparing = false
                self.isPrepared = false
            }
        }
    }
    
    private func resumeTTP() async {
        resumeError = ""
        guard let ariseSdk else {
            await MainActor.run {
                resumeError = "SDK not initialized"
            }
            return
        }
        
        await MainActor.run {
            isResuming = true
            isResumed = false
        }
        
        do {
            try await ariseSdk.ttp.resume()
            print("✅ TTP resumed successfully")
            await MainActor.run {
                self.isResumed = true
                self.isResuming = false
                self.resumeError = ""
            }
        } catch let ttpError as TTPError {
            print("❌ TTP Error: \(ttpError)")
            await MainActor.run {
                resumeError = ttpError.errorDescription ?? "Unknown TTP error occurred"
                self.isResuming = false
                self.isResumed = false
            }
        } catch let apiError as AriseApiError {
            print("❌ API Error resuming TTP: \(apiError)")
            await MainActor.run {
                resumeError = apiError.errorInfo?.details ?? apiError.errorDescription ?? "Unknown API error occurred"
                self.isResuming = false
                self.isResumed = false
            }
        } catch {
            print("❌ Error resuming TTP: \(error)")
            await MainActor.run {
                resumeError = "Error: \(error.localizedDescription)"
                self.isResuming = false
                self.isResumed = false
            }
        }
    }

    private func activateTTP() async {
        activateError = ""
        activateStatus = nil
        
        guard let ariseSdk else {
            await MainActor.run {
                activateError = "SDK not initialized"
            }
            return
        }
        
        await MainActor.run {
            isActivating = true
        }
        
        do {
            try await ariseSdk.ttp.activate()
            print("✅ TTP activation completed with status: active")
            await MainActor.run {
                self.activateStatus = .active
                self.isActivating = false
                self.activateError = ""
            }
        } catch let error as TTPError {
            await MainActor.run {
                self.activateError = "TTP Error: \(error.localizedDescription)"
                self.isActivating = false
            }
        } catch let error as AriseApiError {
            await MainActor.run {
                self.activateError = "API Error: \(error.localizedDescription)"
                self.isActivating = false
            }
        } catch {
            await MainActor.run {
                self.activateError = "Unknown error: \(error.localizedDescription)"
                self.isActivating = false
            }
        }
    }
    
    private func getStatus() async {
        statusErrorMessage = ""
        guard let ariseSdk else {
            await MainActor.run {
                statusErrorMessage = "SDK not initialized"
            }
            return
        }
        
        await MainActor.run {
            isLoadingStatus = true
            // Clear previous status to show loading state
            ttpStatus = nil
        }
        
        do {
            let status = try await ariseSdk.ttp.getStatus()
            print("✅ TTP Status received: \(status)")
            await MainActor.run {
                print("✅ Setting ttpStatus to: \(status)")
                self.ttpStatus = status
                self.isLoadingStatus = false
                self.statusErrorMessage = ""
                print("✅ ttpStatus after setting: \(String(describing: self.ttpStatus))")
            }
        } catch let apiError as AriseApiError {
            await MainActor.run {
                statusErrorMessage = apiError.errorInfo?.details ?? "Unknown error occurred"
                self.isLoadingStatus = false
                self.ttpStatus = nil
               
            }
        } catch {
            print("❌ Error getting TTP status: \(error)")
            await MainActor.run {
                if let apiError = error as? AriseApiError {
                    statusErrorMessage = apiError.errorDescription ?? "Unknown error occurred"
                } else {
                    statusErrorMessage = "Error: \(error.localizedDescription)"
                }
                self.isLoadingStatus = false
                // Clear status on error so user can see the error message
                self.ttpStatus = nil
            }
        }
    }
    
    /// Parses a string to Decimal, handling both comma and dot as decimal separators
    private func parseDecimal(from string: String) -> Decimal? {
        // Remove all spaces and normalize decimal separator (comma -> dot)
        let normalized = string
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        
        // Use NSDecimalNumber for reliable parsing that preserves decimal precision
        guard !normalized.isEmpty else { return nil }
        
        // NSDecimalNumber handles dot as decimal separator reliably
        let decimalNumber = NSDecimalNumber(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
        
        // Check if parsing was successful (not NaN or invalid)
        guard decimalNumber != NSDecimalNumber.notANumber else { return nil }
        
        return decimalNumber as Decimal
    }
    
    /// Simple transaction method using new performTransaction(amount:) API
    private func performTransaction() async {
        transactionError = ""
        transactionResult = nil
        
        guard let ariseSdk else {
            await MainActor.run {
                transactionError = "SDK not initialized"
            }
            return
        }
        
        // Parse amount with proper decimal separator handling
        guard let amount = parseDecimal(from: transactionAmount), amount > 0 else {
            await MainActor.run {
                transactionError = "Please enter a valid amount"
            }
            return
        }
        
        await MainActor.run {
            isPerformingTransaction = true
        }
        
        do {
            // Use new simple performTransaction(amount:) method
            // This method automatically handles ZCP Surcharge if enabled
            let result = try await ariseSdk.ttp.performTransaction(amount: amount)
            print("✅ Transaction completed: \(result.status)")
            await MainActor.run {
                self.transactionResult = result
                self.isPerformingTransaction = false
                self.transactionError = ""
            }
        } catch let ttpError as TTPError {
            print("❌ TTP Error: \(ttpError)")
            await MainActor.run {
                transactionError = ttpError.errorDescription ?? "Unknown TTP error occurred"
                self.isPerformingTransaction = false
            }
        } catch let apiError as AriseApiError {
            print("❌ API Error: \(apiError)")
            await MainActor.run {
                transactionError = apiError.errorInfo?.details ?? apiError.errorDescription ?? "Unknown API error occurred"
                self.isPerformingTransaction = false
            }
        } catch {
            print("❌ Error performing transaction: \(error)")
            await MainActor.run {
                transactionError = "Error: \(error.localizedDescription)"
                self.isPerformingTransaction = false
            }
        }
    }
    
    /// Advanced transaction method using performTransaction(calculationResult:isDebitCard:) API
    private func performAdvancedTransaction() async {
        transactionError = ""
        transactionResult = nil
        
        guard let ariseSdk else {
            await MainActor.run {
                transactionError = "SDK not initialized"
            }
            return
        }
        
        // Parse amount with proper decimal separator handling
        guard let amount = parseDecimal(from: transactionAmount), amount > 0 else {
            await MainActor.run {
                transactionError = "Please enter a valid amount"
            }
            return
        }
        
        await MainActor.run {
            isPerformingAdvancedTransaction = true
        }
        
        do {
            // First, calculate amount to get breakdown
            let calculateRequest = CalculateAmountRequest(
                amount: NSDecimalNumber(decimal: amount).doubleValue,
//                percentageOffRate: 30.0,
//                surchargeRate: 4,
//                tipAmount: 10.0,
                currencyId: 1
                
            )
            
            let calculation = try await ariseSdk.calculateAmount(request: calculateRequest)
            
            // Store calculation result for display
            await MainActor.run {
                self.calculationResult = calculation
            }
            
            // Use advanced performTransaction with calculation result
            let result = try await ariseSdk.ttp.performTransaction(
                calculationResult: calculation,
                isDebitCard: isDebitCard
            )
            
            print("✅ Advanced transaction completed: \(result.status)")
            await MainActor.run {
                self.transactionResult = result
                self.isPerformingAdvancedTransaction = false
                self.transactionError = ""
            }
        } catch let ttpError as TTPError {
            print("❌ TTP Error: \(ttpError)")
            await MainActor.run {
                transactionError = ttpError.errorDescription ?? "Unknown TTP error occurred"
                self.isPerformingAdvancedTransaction = false
            }
        } catch let apiError as AriseApiError {
            print("❌ API Error: \(apiError)")
            await MainActor.run {
                transactionError = apiError.errorInfo?.details ?? apiError.errorDescription ?? "Unknown API error occurred"
                self.isPerformingAdvancedTransaction = false
            }
        } catch {
            print("❌ Error performing advanced transaction: \(error)")
            await MainActor.run {
                transactionError = "Error: \(error.localizedDescription)"
                self.isPerformingAdvancedTransaction = false
            }
        }
    }
    
    /// Deprecated: Old transaction method using TTPTransactionRequest
    /// - Warning: This method is deprecated. Use performTransaction() or performAdvancedTransaction() instead.
    @available(*, deprecated, message: "Use performTransaction() or performAdvancedTransaction() instead")
    private func performTransactionWithAbort() async {
        transactionError = ""
        transactionResult = nil
        
        guard let ariseSdk else {
            await MainActor.run {
                transactionError = "SDK not initialized"
            }
            return
        }
        
        // Parse amount with proper decimal separator handling
        guard let amount = parseDecimal(from: transactionAmount), amount > 0 else {
            await MainActor.run {
                transactionError = "Please enter a valid amount"
            }
            return
        }
        
        guard !currencyCode.isEmpty else {
            await MainActor.run {
                transactionError = "Please enter a currency code"
            }
            return
        }
        
        await MainActor.run {
            isPerformingTransactionWithAbort = true
        }
        
        // Cancel any existing abort task
        abortTask?.cancel()
        
        // Create transaction request
        let request = TTPTransactionRequest(
            amount: amount,
            currencyCode: currencyCode,
            tip: nil,
            discount: nil,
            salesTaxAmount: nil,
            federalTaxAmount: nil,
            subTotal: transactionAmount,
            orderId: orderId.isEmpty ? nil : orderId,
            surchargeRate: surchargeRate.isEmpty ? nil : surchargeRate
        )
        
        // Start transaction task
        let transactionTask = Task {
            do {
                let result = try await ariseSdk.ttp.performTransaction(request: request)
                print("✅ Transaction completed: \(result.status)")
                await MainActor.run {
                    self.transactionResult = result
                    self.isPerformingTransactionWithAbort = false
                    self.transactionError = ""
                    self.abortTask = nil
                }
            } catch let ttpError as TTPError {
                print("❌ TTP Error: \(ttpError)")
                await MainActor.run {
                    transactionError = ttpError.errorDescription ?? "Unknown TTP error occurred"
                    self.isPerformingTransactionWithAbort = false
                    self.abortTask = nil
                }
            } catch let apiError as AriseApiError {
                print("❌ API Error: \(apiError)")
                await MainActor.run {
                    transactionError = apiError.errorInfo?.details ?? apiError.errorDescription ?? "Unknown API error occurred"
                    self.isPerformingTransactionWithAbort = false
                    self.abortTask = nil
                }
            } catch {
                print("❌ Error performing transaction: \(error)")
                await MainActor.run {
                    transactionError = "Error: \(error.localizedDescription)"
                    self.isPerformingTransactionWithAbort = false
                    self.abortTask = nil
                }
            }
        }
        
        // Schedule abort after 5 seconds
        abortTask = Task {
            do {
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                
                // Check if transaction is still running
                if !transactionTask.isCancelled {
                    print("⏱️ Aborting transaction after 5 seconds...")
                    do {
                        let aborted = try await ariseSdk.ttp.abortTransaction()
                        if aborted {
                            print("✅ Transaction aborted successfully")
                            await MainActor.run {
                                transactionError = "Transaction was aborted after 5 seconds"
                                self.isPerformingTransactionWithAbort = false
                            }
                        }
                    } catch let ttpError as TTPError {
                        print("❌ Error aborting transaction: \(ttpError)")
                        await MainActor.run {
                            transactionError = "Failed to abort: \(ttpError.errorDescription ?? "Unknown error")"
                        }
                    } catch {
                        print("❌ Error aborting transaction: \(error)")
                        await MainActor.run {
                            transactionError = "Failed to abort: \(error.localizedDescription)"
                        }
                    }
                }
                
                // Cancel transaction task
                transactionTask.cancel()
            } catch {
                // Task was cancelled
                print("Abort task cancelled")
            }
        }
        
        // Wait for transaction to complete or be cancelled
        await transactionTask.value
    }
    
    private func showEducationalInfo() async {
        educationalInfoError = ""
        guard let ariseSdk else {
            await MainActor.run {
                educationalInfoError = "SDK not initialized"
            }
            return
        }
        
        guard #available(iOS 18.0, *) else {
            await MainActor.run {
                educationalInfoError = "Educational content requires iOS 18.0 or later"
            }
            return
        }
        
        guard let presenter = currentViewController() else {
            await MainActor.run {
                educationalInfoError = "Unable to find a presenter for educational content"
            }
            return
        }
        
        await MainActor.run {
            isShowingEducationalInfo = true
        }
        
        do {
            try await ariseSdk.ttp.showEducationalInfo(from: presenter)
            await MainActor.run {
                isShowingEducationalInfo = false
                educationalInfoError = ""
            }
        } catch let ttpError as TTPError {
            await MainActor.run {
                educationalInfoError = ttpError.errorDescription ?? "Unknown TTP error occurred"
                isShowingEducationalInfo = false
            }
        } catch {
            await MainActor.run {
                educationalInfoError = "Error: \(error.localizedDescription)"
                isShowingEducationalInfo = false
            }
        }
    }
    
    private func currentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var currentViewController = rootViewController
        while let presentedViewController = currentViewController.presentedViewController {
            currentViewController = presentedViewController
        }
        
        return currentViewController
    }
    
    private func startEventStream() {
        eventStreamError = ""
        guard let ariseSdk else {
            eventStreamError = "SDK not initialized"
            return
        }
        
        isListeningEvents = true
        
        eventStreamTask = Task {
            do {
                let stream = try ariseSdk.ttp.eventsStream()
                
                for await event in stream {
                    let eventItem = EventItem(
                        timestamp: Date(),
                        event: event,
                        description: formatEvent(event)
                    )
                    
                    await MainActor.run {
                        events.append(eventItem)
                        // Keep only last 100 events
                        if events.count > 100 {
                            events.removeFirst(events.count - 100)
                        }
                    }
                }
                
                await MainActor.run {
                    isListeningEvents = false
                }
            } catch let ttpError as TTPError {
                await MainActor.run {
                    eventStreamError = "TTP Error: \(ttpError.errorDescription ?? "Unknown error")"
                    isListeningEvents = false
                }
            } catch {
                await MainActor.run {
                    eventStreamError = "Error: \(error.localizedDescription)"
                    isListeningEvents = false
                }
            }
        }
    }
    
    private func stopEventStream() {
        eventStreamTask?.cancel()
        eventStreamTask = nil
        isListeningEvents = false
    }
    
    private func formatEvent(_ event: TTPEvent) -> String {
        switch event {
        case .readerEvent(let readerEvent):
            switch readerEvent {
            case .updateProgress(let progress):
                return "Reader Progress: \(progress)%"
            case .notReady:
                return "Reader: Not Ready"
            case .readyForTap:
                return "Reader: Ready for Tap"
            case .cardDetected:
                return "Reader: Card Detected"
            case .removeCard:
                return "Reader: Remove Card"
            case .readCompleted:
                return "Reader: Read Completed"
            case .readRetry:
                return "Reader: Read Retry"
            case .readCancelled:
                return "Reader: Read Cancelled"
            case .pinEntryRequested:
                return "Reader: PIN Entry Requested"
            case .pinEntryCompleted:
                return "Reader: PIN Entry Completed"
            case .userInterfaceDismissed:
                return "Reader: UI Dismissed"
            case .readNotCompleted:
                return "Reader: Read Not Completed"
            }
            
        case .customEvent(let customEvent):
            switch customEvent {
            case .preparing:
                return "Custom: Preparing"
            case .ready:
                return "Custom: Ready"
            case .readerNotReady(let reason):
                return "Custom: Reader Not Ready - \(reason)"
            case .cardDetected:
                return "Custom: Card Detected"
            case .cardReadSuccess:
                return "Custom: Card Read Success"
            case .cardReadFailure:
                return "Custom: Card Read Failure"
            case .authorizing:
                return "Custom: Authorizing"
            case .approved:
                return "Custom: Transaction Approved"
            case .declined:
                return "Custom: Transaction Declined"
            case .errorOccurred:
                return "Custom: Error Occurred"
            case .inProgress:
                return "Custom: In Progress"
            case .updateReaderProgress(let progress):
                return "Custom: Reader Progress \(progress)%"
            case .unknownEvent(let description):
                return "Custom: Unknown Event - \(description)"
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}

struct CompatibilityCard: View {
    let title: String
    let isCompatible: Bool
    let details: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isCompatible ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCompatible ? .green : .red)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(details, id: \.0) { detail in
                    HStack {
                        Text(detail.0 + ":")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(detail.1)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(isCompatible ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(10)
    }
}

struct EventRow: View {
    let eventItem: TTPHubView.EventItem
    
    private var eventColor: Color {
        switch eventItem.event {
        case .readerEvent(let readerEvent):
            switch readerEvent {
            case .updateProgress, .readyForTap, .cardDetected, .readCompleted, .pinEntryCompleted:
                return .blue
            case .readRetry, .readCancelled, .readNotCompleted:
                return .orange
            default:
                return .gray
            }
        case .customEvent(let customEvent):
            switch customEvent {
            case .approved:
                return .green
            case .declined, .errorOccurred, .cardReadFailure, .readerNotReady:
                return .red
            case .preparing, .ready, .authorizing, .inProgress, .cardReadSuccess:
                return .blue
            default:
                return .gray
            }
        }
    }
    
    private var eventIcon: String {
        switch eventItem.event {
        case .readerEvent(let readerEvent):
            switch readerEvent {
            case .updateProgress:
                return "arrow.up.circle.fill"
            case .cardDetected:
                return "creditcard.fill"
            case .readCompleted:
                return "checkmark.circle.fill"
            case .readRetry, .readCancelled:
                return "xmark.circle.fill"
            default:
                return "waveform.circle.fill"
            }
        case .customEvent(let customEvent):
            switch customEvent {
            case .approved:
                return "checkmark.circle.fill"
            case .declined:
                return "xmark.circle.fill"
            case .errorOccurred:
                return "exclamationmark.triangle.fill"
            case .preparing, .ready:
                return "gear.circle.fill"
            case .authorizing:
                return "lock.circle.fill"
            default:
                return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: eventIcon)
                .foregroundColor(eventColor)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(eventItem.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatTime(eventItem.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(8)
        .background(eventColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}
