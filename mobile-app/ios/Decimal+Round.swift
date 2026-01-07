//
//  Decimal+Round.swift
//  Arise
//
//  Created by Alexandr on 20.06.2025.
//

extension Decimal {
  func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
          var result = Decimal()
          var value = self
          NSDecimalRound(&result, &value, scale, mode)
          return result
      }
}
