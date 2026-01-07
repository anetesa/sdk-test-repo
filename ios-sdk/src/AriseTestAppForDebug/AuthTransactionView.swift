import SwiftUI
import AriseMobile

struct AuthTransactionView: View {
    private enum PriceMode: String, CaseIterable {
        case auto
        case card
        case cash

        var title: String {
            switch self {
            case .auto: return "Auto"
            case .card: return "Card"
            case .cash: return "Cash"
            }
        }

        var boolValue: Bool? {
            switch self {
            case .auto: return nil
            case .card: return true
            case .cash: return false
            }
        }
    }
    @State private var ariseSdk: AriseMobileSdk?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var result: AuthorizationResponse?
    @State private var showResultDetails: Bool = false
    @State private var selectedTransactionId: String?
    
    // Required fields
    @State private var paymentProcessorId: String = "ad830b7f-d21c-4173-90bd-0e090da31072"
    @State private var amount: String = "100.00"
    @State private var currencyId: String = "1" // USD
    @State private var cardDataSourceValue: String = "\(CardDataSource.manual.rawValue)" // Manual entry
    
    // Payment method - either paymentMethodId or card details
    @State private var paymentMethodId: String = ""
    @State private var accountNumber: String = "4111111111111111" // Visa test card
    @State private var securityCode: String = "999"
    @State private var expirationMonth: String = "12"
    @State private var expirationYear: String = "2025"
    
    // Optional fields
    @State private var customerId: String = ""
    @State private var referenceId: String = "12345"
    @State private var tipAmount: String = "0"
    @State private var tipRate: String = ""
    @State private var percentageOffRate: String = ""
    @State private var surchargeRate: String = ""
    
    // Address fields
    @State private var billingLine1: String = "Wall street 1"
    @State private var billingLine2: String = " Ap 12"
    @State private var billingCity: String = "NY"
    @State private var billingStateName: String = "New York"
    @State private var billingPostalCode: String = "75522"
    @State private var billingStateId: String = ""
    @State private var billingCountryId: String = "1" // US
    
    // Contact info
    @State private var firstName: String = "Greg"
    @State private var lastName: String = "Black"
    @State private var companyName: String = "Netflix"
    @State private var email: String = "nomail@gmail.com"
    @State private var mobileNumber: String = "+155555555555"
    
    @State private var showAdvancedFields: Bool = true // Show advanced fields by default to see test data
    
    // Amount calculation preview
    @State private var priceMode: PriceMode = .card
    @State private var calculationResult: CalculateAmountResponse?
    @State private var calculationErrorMessage: String = ""
    @State private var isCalculatingAmount: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Submit AUTH Transaction")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Authorize a payment without immediate capture")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
                .padding(.top, 20)
                
                // Required Fields Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Required Fields")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Payment Processor ID:")
                                .frame(width: 150, alignment: .leading)
                            TextField("UUID", text: $paymentProcessorId)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        HStack {
                            Text("Amount:")
                                .frame(width: 150, alignment: .leading)
                            TextField("0.00", text: $amount)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                        
                        HStack {
                            Text("Currency ID:")
                                .frame(width: 150, alignment: .leading)
                            TextField("1", text: $currencyId)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Card Data Source:")
                                .frame(width: 150, alignment: .leading)
                    TextField("\(CardDataSource.manual.rawValue)", text: $cardDataSourceValue)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Payment Method Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Payment Method")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Payment Method ID:")
                                .frame(width: 150, alignment: .leading)
                            TextField("UUID (optional)", text: $paymentMethodId)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        Text("OR Card Details:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Account Number:")
                                .frame(width: 150, alignment: .leading)
                            TextField("Card number", text: $accountNumber)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Security Code:")
                                .frame(width: 150, alignment: .leading)
                            TextField("CVV", text: $securityCode)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Exp Month:")
                                .frame(width: 150, alignment: .leading)
                            TextField("MM", text: $expirationMonth)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            
                            Text("Exp Year:")
                                .frame(width: 80, alignment: .leading)
                            TextField("YY", text: $expirationYear)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Optional Fields Toggle
                Toggle("Show Advanced Fields", isOn: $showAdvancedFields)
                    .padding(.horizontal)
                
                if showAdvancedFields {
                    // Optional Amount Modifiers
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Amount Modifiers")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Customer ID:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("UUID", text: $customerId)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            HStack {
                                Text("Reference ID:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("Reference ID", text: $referenceId)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            HStack {
                                Text("Tip Amount:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("0.00", text: $tipAmount)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }
                            
                            HStack {
                                Text("Tip Rate (%):")
                                    .frame(width: 150, alignment: .leading)
                                TextField("0.00", text: $tipRate)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }
                            
                            HStack {
                                Text("Discount Rate (%):")
                                    .frame(width: 150, alignment: .leading)
                                TextField("0.00", text: $percentageOffRate)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }
                            
                            HStack {
                                Text("Surcharge Rate (%):")
                                    .frame(width: 150, alignment: .leading)
                                TextField("0.00", text: $surchargeRate)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Price Mode")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Picker("Price Mode", selection: $priceMode) {
                                    ForEach(PriceMode.allCases, id: \.self) { mode in
                                        Text(mode.title).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Billing Address
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Billing Address")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Line 1:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("Street address", text: $billingLine1)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("Line 2:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("Apartment, suite, etc.", text: $billingLine2)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("City:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("City", text: $billingCity)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("State Name:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("State name", text: $billingStateName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("Postal Code:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("ZIP", text: $billingPostalCode)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            }
                            
                            HStack {
                                Text("State ID:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("State ID (optional)", text: $billingStateId)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            }
                            
                            HStack {
                                Text("Country ID:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("1", text: $billingCountryId)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Contact Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("First Name:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("First name", text: $firstName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("Last Name:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("Last name", text: $lastName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("Company Name:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("Company", text: $companyName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("Email:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("email@example.com", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            
                            HStack {
                                Text("Mobile Number:")
                                    .frame(width: 150, alignment: .leading)
                                TextField("Phone", text: $mobileNumber)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.phonePad)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Calculated Amount Preview
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Calculated Amount Preview")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        if isCalculatingAmount {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }

                    Button(action: calculateAmountPreview) {
                        HStack {
                            Image(systemName: "function")
                            Text("Calculate Amount")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isCalculatingAmount)

                    if !calculationErrorMessage.isEmpty {
                        Text(calculationErrorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }

                    if let calculation = calculationResult {
                        VStack(alignment: .leading, spacing: 10) {
                            if let currency = calculation.currency {
                                valueRow("Currency", currency)
                            }
                            if let option = calculation.zeroCostProcessingOption {
                                valueRow("ZCP Mode", option)
                            }

                            if let primary = primaryAmount(from: calculation) {
                                Divider()
                                valueRow("Primary Total", formatCurrency(primary.totalAmount), bold: true)
                            }

                            Divider()
                            VStack(alignment: .leading, spacing: 10) {
                                breakdownBlock(title: "Credit Card", amount: calculation.creditCard)
                                breakdownBlock(title: "Debit Card", amount: calculation.debitCard)
                                breakdownBlock(title: "Cash", amount: calculation.cash)
                                breakdownBlock(title: "ACH", amount: calculation.ach)
                            }
                        }
                    } else if !isCalculatingAmount {
                        Text("Run the calculation to preview totals and breakdown before submitting.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Submit Button
                Button(action: submitAuthTransaction) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "creditcard")
                        }
                        Text("Submit AUTH Transaction")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading || !isFormValid || !isCalculationReady)
                .opacity((isFormValid && isCalculationReady) ? 1.0 : 0.6)
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
                
                // Result Section
                if let result = result {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Authorization Result")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            DetailRow(label: "Transaction ID", value: result.transactionId ?? "N/A")
                            DetailRow(label: "Status", value: result.status ?? "N/A")
                            DetailRow(label: "Type", value: result.type ?? "N/A")
                            DetailRow(label: "Processed Amount", value: formatCurrency(result.processedAmount))
                            DetailRow(label: "Auth Code", value: result.authCode ?? "N/A")
                            
                            if let date = result.transactionDateTime {
                                DetailRow(label: "Date/Time", value: formatDate(date))
                            }
                            
                            if let details = result.details {
                                Divider()
                                Text("Response Details")
                                    .fontWeight(.semibold)
                                    .padding(.top, 8)
                                DetailRow(label: "Code", value: details.code ?? "N/A")
                                DetailRow(label: "Message", value: details.message ?? "N/A")
                                if let hostCode = details.hostResponseCode {
                                    DetailRow(label: "Host Code", value: hostCode)
                                }
                                if let hostMessage = details.hostResponseMessage {
                                    DetailRow(label: "Host Message", value: hostMessage)
                                }
                            }
                            
                            if let transactionId = result.transactionId, ariseSdk != nil {
                                Button(action: {
                                    selectedTransactionId = transactionId
                                    showResultDetails = true
                                }) {
                                    HStack {
                                        Image(systemName: "doc.text.magnifyingglass")
                                        Text("View Transaction Details")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.top, 12)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationTitle("AUTH Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            initializeSdkIfNeeded()
        }
        .onChange(of: amount) { _ in handleCalculationInputChanged() }
        .onChange(of: tipAmount) { _ in handleCalculationInputChanged() }
        .onChange(of: tipRate) { _ in handleCalculationInputChanged() }
        .onChange(of: percentageOffRate) { _ in handleCalculationInputChanged() }
        .onChange(of: surchargeRate) { _ in handleCalculationInputChanged() }
        .onChange(of: currencyId) { _ in handleCalculationInputChanged() }
        .onChange(of: priceMode) { _ in handleCalculationInputChanged() }
        .sheet(isPresented: $showResultDetails) {
            if let transactionId = selectedTransactionId, let ariseSdk = ariseSdk {
                NavigationView {
                    TransactionDetailView(transactionId: transactionId, ariseSdk: ariseSdk)
                        .navigationTitle("Transaction Details")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        guard !paymentProcessorId.isEmpty else { return false }
        guard let amountValue = parseDouble(amount), amountValue > 0 else { return false }
        guard !currencyId.isEmpty, parseInt32(currencyId) != nil else { return false }
        guard !cardDataSourceValue.isEmpty else { return false }
        let hasPaymentMethod = !paymentMethodId.isEmpty
        let hasCardDetails = !accountNumber.isEmpty && !expirationMonth.isEmpty && !expirationYear.isEmpty
        return hasPaymentMethod || hasCardDetails
    }

    private var isCalculationReady: Bool {
        calculationResult != nil && calculationErrorMessage.isEmpty
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

    private func calculateAmountPreview() {
        initializeSdkIfNeeded()
        guard let ariseSdk = ariseSdk else {
            calculationErrorMessage = "SDK not initialized"
            return
        }

        guard let amountValue = parseDouble(amount), amountValue > 0 else {
            calculationErrorMessage = "Enter a valid base amount greater than zero."
            calculationResult = nil
            return
        }

        let request = CalculateAmountRequest(
            amount: amountValue,
            percentageOffRate: parseDouble(percentageOffRate),
            surchargeRate: parseDouble(surchargeRate),
            tipAmount: parseDouble(tipAmount),
            tipRate: parseDouble(tipRate),
            currencyId: parseInt32(currencyId),
            useCardPrice: priceMode.boolValue
        )

        isCalculatingAmount = true
        calculationErrorMessage = ""
        calculationResult = nil

        Task {
            do {
                let response = try await ariseSdk.calculateAmount(request: request)
                await MainActor.run {
                    self.calculationResult = response
                    self.calculationErrorMessage = ""
                    self.isCalculatingAmount = false
                }
            } catch let apiError as AriseApiError {
                await MainActor.run {
                    self.calculationResult = nil
                    self.calculationErrorMessage = errorMessage(for: apiError)
                    self.isCalculatingAmount = false
                }
            } catch {
                await MainActor.run {
                    self.calculationResult = nil
                    self.calculationErrorMessage = error.localizedDescription
                    self.isCalculatingAmount = false
                }
            }
        }
    }

    private func handleCalculationInputChanged() {
        calculationResult = nil
        calculationErrorMessage = ""
    }
    
    private func submitAuthTransaction() {
        guard let ariseSdk = ariseSdk else {
            errorMessage = "SDK not initialized"
            return
        }
        
        isLoading = true
        errorMessage = ""
        result = nil
        
        Task {
            do {
                // Build billing address if provided
                var billingAddress: AddressDto? = nil
                if !billingLine1.isEmpty || !billingCity.isEmpty || !billingPostalCode.isEmpty {
                    billingAddress = AddressDto(
                        line1: billingLine1.isEmpty ? nil : billingLine1,
                        line2: billingLine2.isEmpty ? nil : billingLine2,
                        city: billingCity.isEmpty ? nil : billingCity,
                        postalCode: billingPostalCode.isEmpty ? nil : billingPostalCode,
                        stateName: billingStateName.isEmpty ? nil : billingStateName,
                        stateId: billingStateId.isEmpty ? nil : Int32(billingStateId),
                        countryId: Int32(billingCountryId)
                    )
                }
                
                // Build contact info if provided
                var contactInfo: ContactInfoDto? = nil
                if !firstName.isEmpty || !lastName.isEmpty || !email.isEmpty || !mobileNumber.isEmpty {
                    contactInfo = ContactInfoDto(
                        firstName: firstName.isEmpty ? nil : firstName,
                        lastName: lastName.isEmpty ? nil : lastName,
                        companyName: companyName.isEmpty ? nil : companyName,
                        email: email.isEmpty ? nil : email,
                        mobileNumber: mobileNumber.isEmpty ? nil : mobileNumber,
                        smsNotification: nil
                    )
                }
                
                // Build input
                let amountValue = parseDouble(amount) ?? 0
                let tipAmountValue = parseDouble(tipAmount)
                let tipRateValue = parseDouble(tipRate)
                let discountRateValue = parseDouble(percentageOffRate)
                let surchargeRateValue = parseDouble(surchargeRate)
                let currencyValue = parseInt32(currencyId) ?? 1

                let input = try AuthorizationRequest(
                    paymentProcessorId: paymentProcessorId,
                    amount: amountValue,
                    currencyId: currencyValue,
                    cardDataSource: CardDataSource(rawValue: Int(cardDataSourceValue) ?? CardDataSource.manual.rawValue) ?? .manual,
                    paymentMethodId: paymentMethodId.isEmpty ? nil : paymentMethodId,
                    accountNumber: accountNumber.isEmpty ? nil : accountNumber,
                    securityCode: securityCode.isEmpty ? nil : securityCode,
                    expirationMonth: expirationMonth.isEmpty ? nil : Int32(expirationMonth),
                    expirationYear: expirationYear.isEmpty ? nil : Int32(expirationYear),
                    track1: nil,
                    track2: nil,
                    emvTags: nil,
                    emvPaymentAppVersion: nil,
                    customerId: customerId.isEmpty ? nil : customerId,
                    tipAmount: tipAmountValue,
                    tipRate: tipRateValue,
                    percentageOffRate: discountRateValue,
                    surchargeRate: surchargeRateValue,
                    useCardPrice: priceMode.boolValue,
                    billingAddress: billingAddress,
                    shippingAddress: nil,
                    contactInfo: contactInfo,
                    pin: nil,
                    pinKsn: nil,
                    emvFallbackCondition: nil,
                    emvFallbackLastChipRead: nil,
                    referenceId: referenceId.isEmpty ? nil : referenceId,
                    customerInitiatedTransaction: nil
                )
                
                let authResult = try await ariseSdk.submitAuthTransaction(input: input)
                
                await MainActor.run {
                    self.result = authResult
                    self.errorMessage = ""
                    self.isLoading = false
                    self.selectedTransactionId = authResult.transactionId
                }
            } catch let error as AriseApiError {
                await MainActor.run {
                    self.result = nil
                    self.errorMessage = errorMessage(for: error)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.result = nil
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: Double?) -> String {
        guard let amount = amount else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }

    private func formatRate(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        let percentValue = value * 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        let string = formatter.string(from: NSNumber(value: percentValue)) ?? String(format: "%.2f", percentValue)
        return "\(string)%"
    }

    private func parseDouble(_ value: String) -> Double? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func parseInt32(_ value: String) -> Int32? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Int32(trimmed)
    }

    private func errorMessage(for apiError: AriseApiError) -> String {
       
        return apiError.localizedDescription
    }

    private func primaryAmount(from result: CalculateAmountResponse) -> AmountDto? {
        switch priceMode {
        case .card:
            return result.creditCard ?? result.debitCard ?? result.cash ?? result.ach
        case .cash:
            return result.cash ?? result.creditCard ?? result.debitCard ?? result.ach
        case .auto:
            if let flag = result.useCardPrice {
                return flag ? (result.creditCard ?? result.debitCard) : (result.cash ?? result.ach)
            }
            return result.creditCard ?? result.cash ?? result.debitCard ?? result.ach
        }
    }

    @ViewBuilder
    private func breakdownBlock(title: String, amount: AmountDto?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            if let amount = amount {
                valueRow("Base Amount", formatCurrency(amount.baseAmount))

                if shouldDisplay(amount.percentageOffAmount) {
                    valueRow("Discount Amount", formatCurrency(-amount.percentageOffAmount))
                    valueRow("Discount Rate", formatRate(amount.percentageOffRate))
                }

                if shouldDisplay(amount.cashDiscountAmount) {
                    valueRow("Cash Discount Amount", formatCurrency(-amount.cashDiscountAmount))
                    valueRow("Cash Discount Rate", formatRate(amount.cashDiscountRate))
                }

                if shouldDisplay(amount.surchargeAmount) {
                    valueRow("Surcharge Amount", formatCurrency(amount.surchargeAmount))
                    valueRow("Surcharge Rate", formatRate(amount.surchargeRate))
                }

                if shouldDisplay(amount.tipAmount) {
                    valueRow("Tip Amount", formatCurrency(amount.tipAmount))
                    valueRow("Tip Rate", formatRate(amount.tipRate))
                }

                if shouldDisplay(amount.taxAmount) {
                    valueRow("Tax Amount", formatCurrency(amount.taxAmount))
                    valueRow("Tax Rate", formatRate(amount.taxRate))
                }

                Divider()

                let effectiveRate = amount.baseAmount > 0
                    ? (amount.totalAmount - amount.baseAmount) / amount.baseAmount
                    : 0
                valueRow("Effective Rate", formatRate(effectiveRate))
                valueRow("Total Amount", formatCurrency(amount.totalAmount), bold: true)
            } else {
                Text("Not available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }

    @ViewBuilder
    private func valueRow(_ label: String, _ value: String, bold: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(bold ? .semibold : .regular)
        }
        .font(.caption)
    }

    private func shouldDisplay(_ value: Double) -> Bool {
        abs(value) > 0.0001
    }
}

#Preview {
    NavigationView {
        AuthTransactionView()
    }
}

