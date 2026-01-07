//
//  CloudCommerce+MerchantMapping.swift.swift
//  Arise
//
//  Created by Alexandr on 20.06.2025.
//
import Foundation
import CloudCommerce

extension CloudCommerce.Merchant {
    init(from decoded: Arise.Merchant) {
        self.init(
            bannerName: decoded.bannerName,
            categoryCode: decoded.categoryCode,
            terminalProfileId: decoded.terminalProfileId,
            currencyCode: decoded.currencyCode,
            countryCode: decoded.countryCode
        )
    }
}
