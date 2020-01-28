//
//  PickUpOrderObject+Reflectable+Validatable.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor

/// # Extension for the PickUpOrderObject to make it conform to Validatable and Reflectable.
/// - Validatable allows you to validate types with Vapor
/// - Reflectable provides a way to discover the internal components of a type
/// - Because you use key paths, Vapor creates type-safe validations.

/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.

/// # Custom Validator
/// 3. Use Validation's add(_:_:) to add a custom validator for the data. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validation fails.
/// 4. If the note is not nil: Ensure that the maximum character count is less than 101
/// 5. Otherwise, throw BasicValidationError with the message.
/// 6. Return the validations for Vapor to test.

extension PickUpOrderObject: Validatable, Reflectable {
    
    static func validations() throws -> Validations<PickUpOrderObject> { // 1

        var validations = Validations(PickUpOrderObject.self) // 2

        validations.add("Note limit") { model in // 3
            if model.note != nil { // 4
                guard model.note!.count < 101 else { throw BasicValidationError("The note is too long.") // 5
                }
            }
        }
        return validations // 10
    }
}
