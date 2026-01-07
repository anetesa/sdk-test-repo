import SwiftUI

struct TransactionsHubView: View {
    var body: some View {
        List {
            Section("Transactions") {
                NavigationLink("Get Transactions", destination: TransactionsListView())
                NavigationLink("Submit AUTH Transaction", destination: AuthTransactionView())
                NavigationLink("Submit SALE Transaction", destination: SaleTransactionView())
            }
            
            Section("Configuration") {
                NavigationLink("Get Payment Settings", destination: PaymentSettingsView())
            }
        }
        .navigationTitle("Transactions")
        .listStyle(.insetGrouped)
    }
}







