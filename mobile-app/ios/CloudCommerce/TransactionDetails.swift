//
//  TransactionDetails.swift
//  Arise
//
//  Created by Alexandr on 20.06.2025.
//
import Foundation

struct TransactionDetails: Codable {
    let amount: Decimal
    let currencyCode: String
    let tip: String
    let discount: String
    let salesTaxAmount: String
    let federalTaxAmount: String
    let subTotal: String
    let orderId: String
    let customData: [String: String]?
}

