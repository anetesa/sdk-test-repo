//
//  NSDictionary+Decoding.swift
//  Arise
//
//  Created by Alexandr on 20.06.2025.
//

extension NSDictionary {
    func decoded<T: Decodable>() throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: [])
        return try JSONDecoder().decode(T.self, from: data)
    }
}
