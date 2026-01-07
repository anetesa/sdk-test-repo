import SwiftUI
import AriseMobile

struct TransactionDetailView: View {
    let transactionId: String
    let ariseSdk: AriseMobileSdk
    @State private var transaction: TransactionDetails?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var captureAmountInput: String = ""
    @State private var isCapturing: Bool = false
    @State private var captureSuccessMessage: String = ""
    @State private var refundAmountInput: String = ""
    @State private var isRefunding: Bool = false
    @State private var refundSuccessMessage: String = ""
    @State private var isVoiding: Bool = false
    @State private var voidSuccessMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Transaction Details")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("ID: \(transactionId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.top, 20)
                
                // Loading State
                if isLoading {
                    ProgressView("Loading transaction details...")
                        .padding()
                }
                
                // Error State
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
                
                // Transaction Details
                if let transaction = transaction {
                    VStack(spacing: 15) {
                        // Capture Transaction Section
                        VStack(spacing: 8) {
                            if !captureSuccessMessage.isEmpty {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(captureSuccessMessage)
                                        .foregroundColor(.green)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                if let available = captureAvailableAmount(for: transaction) {
                                    Text("Available to capture: \(formatCurrency(available))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }

                                TextField("Capture amount (leave blank for full)", text: $captureAmountInput)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(!supportsPartialCapture(for: transaction))

                                if !supportsPartialCapture(for: transaction) {
                                    Text("Partial capture is not available for this transaction.")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Button(action: {
                                captureTransaction()
                            }) {
                                HStack {
                                    if isCapturing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "creditcard")
                                    }
                                    Text(isCapturing ? "Capturing..." : "Capture Transaction")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isCapturing || !canCaptureTransaction(transaction) ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(isCapturing || !canCaptureTransaction(transaction))
                        }
                        .padding(.horizontal)

                        // Refund Transaction Section
                        VStack(spacing: 8) {
                            if !refundSuccessMessage.isEmpty {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(refundSuccessMessage)
                                        .foregroundColor(.green)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                if let available = refundAvailableAmount(for: transaction) {
                                    Text("Available to refund: \(formatCurrency(available))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Enter a refund amount for this transaction.")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }

                                TextField("Refund amount (leave blank for full)", text: $refundAmountInput)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            Button(action: {
                                refundTransaction()
                            }) {
                                HStack {
                                    if isRefunding {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.uturn.backward")
                                    }
                                    Text(isRefunding ? "Processing Refund..." : "Refund Transaction")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isRefunding || !canRefundTransaction(transaction) ? Color.gray : Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(isRefunding || !canRefundTransaction(transaction))
                        }
                        .padding(.horizontal)

                        // Void Transaction Button
                        VStack(spacing: 8) {
                            if !voidSuccessMessage.isEmpty {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(voidSuccessMessage)
                                        .foregroundColor(.green)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                voidTransaction()
                            }) {
                                HStack {
                                    if isVoiding {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                    Text(isVoiding ? "Voiding..." : "Void Transaction")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isVoiding ? Color.gray : (canVoidTransaction(transaction) ? Color.red : Color.gray))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(isVoiding || !canVoidTransaction(transaction))
                        }
                        .padding(.horizontal)
                        
                        // Basic Information
                        DetailSection(title: "Basic Information") {
                            DetailRow(label: "Transaction ID", value: transaction.transactionId ?? "N/A")
                            DetailRow(label: "Date/Time", value: formatDate(transaction.transactionDateTime))
                            DetailRow(label: "Order Number", value: transaction.orderNumber ?? "N/A")
                            DetailRow(label: "Status", value: transaction.status ?? "N/A")
                            DetailRow(label: "Status ID", value: transaction.statusId.map { "\($0)" } ?? "N/A")
                        }
                        
                        // Amount Information
                        if let amount = transaction.amount {
                            DetailSection(title: "Amount Details") {
                                DetailRow(label: "Base Amount", value: formatCurrency(amount.baseAmount))
                                DetailRow(label: "Total Amount", value: formatCurrency(amount.totalAmount))
                                DetailRow(label: "Surcharge Amount", value: formatCurrency(amount.surchargeAmount))
                                DetailRow(label: "Tip Amount", value: formatCurrency(amount.tipAmount))
                                DetailRow(label: "Currency", value: transaction.currency ?? "N/A")
                                DetailRow(label: "Currency ID", value: transaction.currencyId.map { "\($0)" } ?? "N/A")
                            }
                        }
                        
                        // Deprecated Amount Fields
                        if let baseAmount = transaction.baseAmount {
                            DetailSection(title: "Amount (Deprecated)") {
                                DetailRow(label: "Base Amount", value: formatCurrency(baseAmount))
                                DetailRow(label: "Total Amount", value: formatCurrency(transaction.totalAmount))
                            }
                        }
                        
                        // Processor Information
                        DetailSection(title: "Processor") {
                            DetailRow(label: "Processor ID", value: transaction.processorId ?? "N/A")
                            DetailRow(label: "Processor", value: transaction.processor ?? "N/A")
                        }
                        
                        // Transaction Type Information
                        DetailSection(title: "Transaction Type") {
                            DetailRow(label: "Operation Type ID", value: transaction.operationTypeId.map { "\($0)" } ?? "N/A")
                            DetailRow(label: "Operation Type", value: transaction.operationType ?? "N/A")
                            DetailRow(label: "Transaction Type ID", value: transaction.transactionTypeId.map { "\($0)" } ?? "N/A")
                            DetailRow(label: "Transaction Type", value: transaction.transactionType ?? "N/A")
                        }
                        
                        // Payment Method
                        DetailSection(title: "Payment Method") {
                            DetailRow(label: "Payment Method Type ID", value: transaction.paymentMethodTypeId.map { "\($0)" } ?? "N/A")
                            DetailRow(label: "Payment Method Type", value: transaction.paymentMethodType ?? "N/A")
                            DetailRow(label: "Card Token Type", value: formatCardTokenType(transaction.cardTokenType))
                        }
                        
                        // Customer Information
                        DetailSection(title: "Customer") {
                            DetailRow(label: "Customer ID", value: transaction.customerId ?? "N/A")
                            DetailRow(label: "Customer PAN", value: transaction.customerPan ?? "N/A")
                        }
                        
                        // Merchant Information
                        DetailSection(title: "Merchant") {
                            DetailRow(label: "Merchant Name", value: transaction.merchantName ?? "N/A")
                            DetailRow(label: "Merchant Address", value: transaction.merchantAddress ?? "N/A")
                            DetailRow(label: "Merchant Phone", value: transaction.merchantPhoneNumber ?? "N/A")
                            DetailRow(label: "Merchant Email", value: transaction.merchantEmailAddress ?? "N/A")
                            DetailRow(label: "Merchant Website", value: transaction.merchantWebsite ?? "N/A")
                        }
                        
                        // Transaction Details
                        DetailSection(title: "Transaction Details") {
                            DetailRow(label: "Auth Code", value: transaction.authCode ?? "N/A")
                            DetailRow(label: "Response Code", value: transaction.responseCode ?? "N/A")
                            DetailRow(label: "Response Description", value: transaction.responseDescription ?? "N/A")
                            
                            if let source = transaction.source {
                                DetailRow(label: "Source Type ID", value: source.typeId.map { "\($0)" } ?? "N/A")
                                DetailRow(label: "Source Type", value: source.type ?? "N/A")
                                DetailRow(label: "Source ID", value: source.id ?? "N/A")
                                DetailRow(label: "Source Name", value: source.name)
                            }
                        }
                        
                        // Card Authentication
                        DetailSection(title: "Card Authentication") {
                            DetailRow(label: "Authentication Method", value: transaction.cardholderAuthenticationMethod ?? "N/A")
                            DetailRow(label: "CVM Result", value: transaction.cvmResultMsg ?? "N/A")
                            DetailRow(label: "Card Data Source", value: transaction.cardDataSource ?? "N/A")
                        }
                        
                        // Available Operations
                        if let operations = transaction.availableOperations, !operations.isEmpty {
                            DetailSection(title: "Available Operations") {
                                ForEach(Array(operations.enumerated()), id: \.offset) { index, operation in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Operation \(index + 1)")
                                            .fontWeight(.semibold)
                                        DetailRow(label: "Type ID", value: operation.typeId.map { "\($0)" } ?? "N/A")
                                        DetailRow(label: "Type", value: operation.type ?? "N/A")
                                        DetailRow(label: "Available Amount", value: formatCurrency(operation.availableAmount))
                                        
                                        if let tips = operation.suggestedTips, !tips.isEmpty {
                                            Text("Suggested Tips:")
                                                .fontWeight(.medium)
                                                .padding(.top, 4)
                                            ForEach(Array(tips.enumerated()), id: \.offset) { tipIndex, tip in
                                                HStack {
                                                    Text("•")
                                                    Text("\(tip.tipPercent, specifier: "%.2f")% (\(formatCurrency(tip.tipAmount)))")
                                                }
                                                .font(.caption)
                                                .padding(.leading, 16)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    if index < operations.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchTransactionDetails()
        }
    }
    
    private func fetchTransactionDetails() {
        isLoading = true
        errorMessage = ""
        transaction = nil
        
        Task {
            do {
                let transactionDetails = try await ariseSdk.getTransactionDetails(id: transactionId)
                await MainActor.run {
                    if let details = transactionDetails {
                        self.transaction = details
                        self.errorMessage = ""
                        self.captureAmountInput = ""
                        self.refundAmountInput = ""
                    } else {
                        // Transaction not found (404)
                        self.transaction = nil
                        self.errorMessage = "Transaction not found (404)\n\nTransaction ID: \(transactionId)\n\nThe transaction with this ID does not exist or you don't have permission to access it."
                        self.captureAmountInput = ""
                        self.refundAmountInput = ""
                    }
                    self.isLoading = false
                    self.refundAmountInput = ""
                }
            } catch let error as AriseApiError {
                await MainActor.run {
                    self.transaction = nil
                    // Format error message based on error type
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.refundAmountInput = ""
                }
            } catch {
                await MainActor.run {
                    self.transaction = nil
                    self.errorMessage = "Error\n\nTransaction ID: \(transactionId)\n\n\(error.localizedDescription)"
                    self.isLoading = false
                    self.refundAmountInput = ""
                }
            }
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: Double?) -> String {
        guard let amount = amount else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = transaction?.currency ?? "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
    
    private func formatCardTokenType(_ tokenType: CardTokenType?) -> String {
        guard let tokenType = tokenType else { return "N/A" }
        switch tokenType {
        case .local:
            return "Local (1)"
        case .network:
            return "Network (2)"
        }
    }
    
    private func captureOperation(for transaction: TransactionDetails) -> TransactionOperation? {
        return transaction.availableOperations?.first(where: { operation in
            if let typeId = operation.typeId, typeId == 3 {
                return true
            }
            if let type = operation.type?.lowercased(), type == "capture" {
                return true
            }
            return false
        })
    }

    private func captureAvailableAmount(for transaction: TransactionDetails) -> Double? {
        return captureOperation(for: transaction)?.availableAmount
    }

    private func supportsPartialCapture(for transaction: TransactionDetails) -> Bool {
        guard let operation = captureOperation(for: transaction) else { return false }
        return operation.availableAmount != nil
    }

    private func canCaptureTransaction(_ transaction: TransactionDetails) -> Bool {
        guard let operation = captureOperation(for: transaction) else { return false }
        if let available = operation.availableAmount {
            return available > 0
        }
        // When available amount is not provided, rely on total amount metadata
        if let total = transaction.amount?.totalAmount {
            return total > 0
        }
        return true
    }

    private func refundOperation(for transaction: TransactionDetails) -> TransactionOperation? {
        return transaction.availableOperations?.first(where: { operation in
            if let typeId = operation.typeId, typeId == 5 {
                return true
            }
            if let type = operation.type?.lowercased() {
                return type.contains("refund") || type.contains("return")
            }
            return false
        })
    }

    private func refundAvailableAmount(for transaction: TransactionDetails) -> Double? {
        return refundOperation(for: transaction)?.availableAmount
    }

    private func canRefundTransaction(_ transaction: TransactionDetails) -> Bool {
        guard let operation = refundOperation(for: transaction) else { return false }
        if let available = operation.availableAmount {
            return available > 0
        }
        // When available amount is not provided, allow manual entry
        return true
    }

    /// Check if transaction can be voided
    private func canVoidTransaction(_ transaction: TransactionDetails) -> Bool {
        let status = transaction.status?.lowercased() ?? ""
        let statusId = transaction.statusId ?? 0
        
        // Void is allowed for: Authorized (1), Captured (2), PartiallyAuthorized (7)
        let voidableStatusIds: [Int32] = [1, 2, 7]
        let voidableStatuses = ["authorized", "captured", "partiallyauthorized"]
        
        return voidableStatusIds.contains(statusId) || voidableStatuses.contains(status)
    }
    
    /// Capture the transaction
    private func captureTransaction() {
        guard let transaction = transaction else { return }
        guard canCaptureTransaction(transaction) else { return }

        isCapturing = true
        errorMessage = ""
        captureSuccessMessage = ""

        let trimmed = captureAmountInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let amountValue: Double

        if !trimmed.isEmpty {
            let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
            guard let parsed = Double(normalized) else {
                isCapturing = false
                errorMessage = "Invalid capture amount."
                return
            }

            if parsed <= 0 {
                isCapturing = false
                errorMessage = "Capture amount must be greater than 0."
                return
            }

            if let available = captureAvailableAmount(for: transaction), parsed - available > 0.0001 {
                isCapturing = false
                errorMessage = "Capture amount exceeds remaining authorized amount (" + formatCurrency(available) + ")."
                return
            }

            amountValue = parsed
        } else {
            guard let total = transaction.amount?.totalAmount else {
                isCapturing = false
                errorMessage = "Capture amount is not available for this transaction."
                return
            }
            amountValue = total
        }

        Task {
            do {
                let result = try await ariseSdk.captureTransaction(transactionId: transactionId, amount: amountValue)
                await MainActor.run {
                    self.isCapturing = false
                    self.captureAmountInput = ""
                    let capturedText = formatCurrency(amountValue)
                    self.captureSuccessMessage = "Capture successful! Captured: \(capturedText)"
                    fetchTransactionDetails()
                }
            } catch let error as AriseApiError {
                await MainActor.run {
                    self.isCapturing = false
                    self.errorMessage = error.localizedDescription
                    
                }
            } catch {
                await MainActor.run {
                    self.isCapturing = false
                    self.errorMessage = "Error capturing transaction\n\n\(error.localizedDescription)"
                }
            }
        }
    }

    private func refundTransaction() {
        guard let transaction = transaction else { return }
        guard let operation = refundOperation(for: transaction) else { return }

        isRefunding = true
        errorMessage = ""
        refundSuccessMessage = ""

        let trimmed = refundAmountInput.trimmingCharacters(in: .whitespacesAndNewlines)
        var amountToRefund: Double?

        if !trimmed.isEmpty {
            let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
            guard let parsed = Double(normalized) else {
                isRefunding = false
                errorMessage = "Invalid refund amount."
                return
            }

            if parsed <= 0 {
                isRefunding = false
                errorMessage = "Refund amount must be greater than 0."
                return
            }

            if let available = operation.availableAmount, parsed - available > 0.0001 {
                isRefunding = false
                errorMessage = "Refund amount exceeds remaining refundable amount (" + formatCurrency(available) + ")."
                return
            }

            amountToRefund = parsed
        } else if let available = operation.availableAmount, available > 0 {
            amountToRefund = available
        } else {
            isRefunding = false
            errorMessage = "Refund amount is required for this transaction."
            return
        }

        guard let finalAmount = amountToRefund else {
            isRefunding = false
            errorMessage = "Refund amount could not be determined."
            return
        }

        Task {
            do {
                let request = RefundRequest(
                    transactionId: transactionId,
                    amount: finalAmount,
                    cardDataSource: transaction.cardDataSourceId ?? .internet
                )
                let result = try await ariseSdk.refundTransaction(request: request)
                await MainActor.run {
                    self.isRefunding = false
                    self.refundAmountInput = ""
                    let refundedText = formatCurrency(result.transactionReceipt?.amount?.totalAmount ?? finalAmount)
                    self.refundSuccessMessage = "Refund successful! Refunded: \(refundedText)"
                    self.errorMessage = ""
                    fetchTransactionDetails()
                }
            } catch let error as AriseApiError {
                await MainActor.run {
                    self.isRefunding = false
                    self.refundSuccessMessage = ""
                    self.errorMessage = "Network Error\n\n\(error.errorDescription)"

                }
            } catch {
                await MainActor.run {
                    self.isRefunding = false
                    self.refundSuccessMessage = ""
                    self.errorMessage = "Error refunding transaction\n\n\(error.localizedDescription)"
                }
            }
        }
    }

    /// Void the transaction
    private func voidTransaction() {
        isVoiding = true
        errorMessage = ""
        voidSuccessMessage = ""
        
        Task {
            do {
                let result = try await ariseSdk.voidTransaction(transactionId: transactionId)
                await MainActor.run {
                    self.isVoiding = false
                    self.voidSuccessMessage = "Transaction voided successfully!\nNew status: \(result.status ?? "N/A")"
                    // Refresh transaction details to show updated status
                    fetchTransactionDetails()
                }
            } catch let error as AriseApiError {
                await MainActor.run {
                    self.isVoiding = false
                    self.errorMessage = error.localizedDescription
                }
            } catch {
                await MainActor.run {
                    self.isVoiding = false
                    self.errorMessage = "Error voiding transaction\n\n\(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Helper Views

struct DetailSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                content
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .fontWeight(.medium)
                .frame(width: 140, alignment: .leading)
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
            Spacer()
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationView {
        // Note: Preview requires a real SDK instance, so this is just a placeholder
        Text("Transaction Detail Preview")
    }
}

