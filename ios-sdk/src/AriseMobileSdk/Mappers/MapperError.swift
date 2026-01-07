
import Foundation

enum MapperError: LocalizedError {
    
    case missingField(fieldName: String, entityName: String)
    
    var errorDescription: String? {
        switch self {
        case .missingField(let fieldName, let entity):
            return "Missing required field: \(fieldName) in \(entity)"
        }
    }

}
