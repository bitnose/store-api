//
//  CustomerObject+Validatable+Reflectable.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor

/// # Extension for the CustomerObject to make it conform to Validatable and Reflectable.
/// - Validatable allows you to validate types with Vapor
/// - Reflectable provides a way to discover the internal components of a type
/// - Because you use key paths, Vapor creates type-safe validations.

/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Add a validator to ensure RegisterData's email is a valid email address.
///
/// # Custom Validator
/// 4. Use Validation's add(_:_:) to add a custom validator for the data. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validation fails.
/// 5. Ensure that the firstname is not an empty string and that maximum character count is less than 21, and that the string doesn't contain any special characters or numbers.
/// 6. Otherwise, throw BasicValidationError with the message.
/// 7. Use Validation's add(_:_:) to add a custom validator for the data. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validation fails.
/// 8. Ensure that the lastname is not an empty string and that maximum character count is less than 21, and that the string doesn't contain any special characters or numbers.
/// 9. Otherwise, throw BasicValidationError with the message.
/// 10. Return the validations for Vapor to test.

extension CustomerObject: Validatable, Reflectable {
    
    static func validations() throws -> Validations<CustomerObject> { // 1
        
        var validations = Validations(CustomerObject.self) // 2
        try validations.add(\.email, .email && .count(5...60)) // 3
        
        validations.add("First name") { model in // 4
            guard !model.firstname.isEmpty, model.firstname.count < 21,
                !model.firstname.containsSpecialCharactersOrNumbers else { // 5
                    throw BasicValidationError("The first name can't contain special characters or numbers.") // 6
            }
        }
        validations.add("Last name") { model in // 7
            guard !model.lastname.isEmpty, model.lastname.count < 21, !model.lastname.containsSpecialCharactersOrNumbers else { // 8
                    throw BasicValidationError("The first name can't contain special characters or numbers.") // 9
                }
            }
        return validations // 10
    }
}
