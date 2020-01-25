//
//  User+Validation.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor

/// # Extension for the RegisterPostData to make it conform to Validatable and Reflectable.
/// - Validatable allows you to validate types with Vapor
/// - Reflectable provides a way to discover the internal components of a type
/// - Because you use key paths, Vapor creates type-safe validations.

/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Add a validator to ensure RegisterData's email is a valid email address.
/// # Custom Validator
/// 4. Use Validation's add(_:_:) to add a custom validator for the data. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validation fails.
/// 5. Verify that password is a strong password.
/// 6.  If not, throw BasicValidationError.
/// 7. Use Validation's add(_:_:) to add a custom validator for the data. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validation fails.
/// 8. If the firstname is not nil.
/// 9. Ensure that the firstname is not an empty string and that maximum character count is less than 20, and that the string doesn't contain any special characters or numbers.
/// 11. Otherwise, throw BasicValidationError with the message.
/// 12. Use Validation's add(_:_:) to add a custom validator for the data. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validation fails.
/// 13. Ensure that the lastname is not an empty string and that maximum character count is less than 20, and that the string doesn't contain any special characters or numbers.
/// 14. Otherwise, throw BasicValidationError with the message.
/// 15. Return the validations for Vapor to test.

extension RegisterPostData: Validatable, Reflectable {
    
    static func validations() throws -> Validations<RegisterPostData> { // 1
        
        var validations = Validations(RegisterPostData.self) // 2
        try validations.add(\.email, .email && .count(5...60)) // 3

        validations.add("Strong password") { model in // 4
            guard model.password.isStrongPassword else { // 5
                throw BasicValidationError("Password must be 8 characters and contain uppercase letters, numerals and lower case letters") // 6
            }
        }
        validations.add("First name") { model in // 7
            if model.firstname != nil { // 8
                guard !model.firstname!.isEmpty, model.firstname!.count < 20, !model.firstname!.containsSpecialCharactersOrNumbers else { // 9
                    throw BasicValidationError("The first name can't contain special characters or numbers.") // 10
                }
            }
        }
        validations.add("Last name") { model in // 11
            if model.lastname != nil { // 12
                guard !model.lastname!.isEmpty, model.lastname!.count < 20, !model.lastname!.containsSpecialCharactersOrNumbers else { // 13
                    throw BasicValidationError("The first name can't contain special characters or numbers.") // 14
                }
            }
        }
        return validations // 15
    }
}
