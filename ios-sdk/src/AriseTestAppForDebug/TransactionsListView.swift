import SwiftUI
import AriseMobile

struct TransactionsListView: View {
    @State private var filters: TransactionFilters?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var result: TransactionsResponse?
    @State private var ariseSdk: AriseMobileSdk?
    
    // Filter UI state
    @State private var page: String = "0"
    @State private var pageSize: String = "20"
    @State private var asc: Bool? = nil
    @State private var orderBy: String = ""
    @State private var createMethodId: String = ""
    @State private var createdById: String = ""
    @State private var batchId: String = ""
    @State private var noBatch: Bool? = nil
    @State private var showAdvancedFilters: Bool = false
    @State private var fakeTransactionId: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Get Transactions")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Retrieve transactions list with filters")
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
                .padding(.top, 20)
                
                // Filters Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Filters (Optional)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Page:")
                                .frame(width: 100, alignment: .leading)
                            TextField("0", text: $page)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .submitLabel(.done)
                        }
                        
                        HStack {
                            Text("Page Size:")
                                .frame(width: 100, alignment: .leading)
                            TextField("20", text: $pageSize)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .submitLabel(.done)
                        }
                        
                        Divider()
                        
                        Toggle("Advanced Filters", isOn: $showAdvancedFilters)
                        
                        if showAdvancedFilters {
                            HStack {
                                Text("Ascending:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("Sort Order", selection: $asc) {
                                    Text("None").tag(nil as Bool?)
                                    Text("True").tag(true as Bool?)
                                    Text("False").tag(false as Bool?)
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            HStack {
                                Text("Order By:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Field name", text: $orderBy)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .submitLabel(.done)
                            }
                            
                            HStack {
                                Text("Create Method ID:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("Optional", text: $createMethodId)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .submitLabel(.done)
                            }
                            
                            HStack {
                                Text("Created By ID:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("UUID", text: $createdById)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .submitLabel(.done)
                            }
                            
                            HStack {
                                Text("Batch ID:")
                                    .frame(width: 100, alignment: .leading)
                                TextField("UUID", text: $batchId)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .submitLabel(.done)
                            }
                            
                            HStack {
                                Text("No Batch:")
                                    .frame(width: 100, alignment: .leading)
                                Picker("No Batch", selection: $noBatch) {
                                    Text("None").tag(nil as Bool?)
                                    Text("True").tag(true as Bool?)
                                    Text("False").tag(false as Bool?)
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                    }
                    
                    Button(action: fetchTransactions) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "magnifyingglass")
                            }
                            Text("Get Transactions")
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
                if let result = result {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Results")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        // Pagination Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Total: \(result.total)")
                            }
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                            
                            // Test 404 Error Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Test 404 Error")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                                
                                HStack {
                                    TextField("e.g., 00000000-0000-0000-0000-000000000000", text: $fakeTransactionId)
                                        .textFieldStyle(.roundedBorder)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .font(.caption)
                                    
                                    Button(action: {
                                        // Fill with example fake UUID
                                        fakeTransactionId = "00000000-0000-0000-0000-000000000000"
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.caption)
                                            .padding(6)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(4)
                                    }
                                    
                                    if let ariseSdk = ariseSdk, !fakeTransactionId.isEmpty {
                                        NavigationLink(destination: TransactionDetailView(transactionId: fakeTransactionId, ariseSdk: ariseSdk)) {
                                            Text("Test")
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.orange)
                                                .foregroundColor(.white)
                                                .cornerRadius(6)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        Button(action: {}) {
                                            Text("Test")
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(6)
                                        }
                                        .disabled(true)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                        }
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                        
                        // Transactions List
                        if result.items.isEmpty {
                            Text("No transactions found")
                                .foregroundColor(Color(.secondaryLabel))
                                .padding()
                        } else {
                            Text("Transactions (\(result.items.count))")
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                            
                            ForEach(result.items.prefix(10), id: \.id) { transaction in
                                if let ariseSdk = ariseSdk {
                                    NavigationLink(destination: TransactionDetailView(transactionId: transaction.id, ariseSdk: ariseSdk)) {
                                        TransactionRowView(transaction: transaction)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                TransactionRowView(transaction: transaction)
                                }
                            }
                            
                            if result.items.count > 10 {
                                Text("... and \(result.items.count - 10) more")
                                    .font(.caption)
                                    .foregroundColor(Color(.secondaryLabel))
                                    .padding(.top, 4)
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
        .navigationTitle("Transactions List")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            initializeSdkIfNeeded()
        }
    }
    
    private func fetchTransactions() {
        isLoading = true
        errorMessage = ""
        result = nil
        
        guard let ariseSdkInstance = getSdk() else {
            errorMessage = "SDK not initialized"
            isLoading = false
            return
        }
        
        // Build filters from UI state
        let builtFilters: TransactionFilters
        do {
            builtFilters = try TransactionFilters(
                page: Int(page).flatMap { $0 >= 0 ? $0 : nil },
                pageSize: Int(pageSize).flatMap { $0 > 0 ? $0 : nil },
                asc: asc,
                orderBy: orderBy.isEmpty ? nil : orderBy,
                createMethodId: Int(createMethodId).flatMap { $0 > 0 ? $0 : nil },
                createdById: createdById.isEmpty ? nil : createdById,
                batchId: batchId.isEmpty ? nil : batchId,
                noBatch: noBatch
            )
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return
        }
        
        Task {
            do {
                let transactionsResult = try await ariseSdkInstance.getTransactions(filters: builtFilters)
                await MainActor.run {
                    self.result = transactionsResult
                    self.errorMessage = ""
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.result = nil
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

struct TransactionRowView: View {
    let transaction: TransactionSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(transaction.id.prefix(8))
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
                Spacer()
                Text(formatCurrency(transaction.totalAmount, currency: transaction.currencyCode))
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text(transaction.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(transaction.status).opacity(0.2))
                    .foregroundColor(statusColor(transaction.status))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            if let customerName = transaction.customerName {
                Text(customerName)
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date?) -> String {
        if(date == nil){
            return "nil"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date!)

    }
    
    private func formatCurrency(_ amount: Double, currency: String?) -> String {
        let currencyCode = currency ?? "USD"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount) \(currencyCode)"
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "completed", "approved", "settled":
            return .green
        case "pending", "processing":
            return .orange
        case "failed", "declined", "rejected":
            return .red
        default:
            return .blue
        }
    }
}

#Preview {
    NavigationView {
        TransactionsListView()
    }
}

