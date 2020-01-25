//
//  OrderAddressObject+Reflectable+Validatable.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor

/// # Extension for the OrderAddressObject to make it conform to Validatable and Reflectable.
/// - Validatable allows you to validate types with Vapor
/// - Reflectable provides a way to discover the internal components of a type
/// - Because you use key paths, Vapor creates type-safe validations.

/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Custom Validator:
/// 4. Ensure that the address is for shipping and billing.
/// 5. Throw an error otherwise.
/// 6. Return the validations for Vapor to test.

extension OrderAddressObject: Validatable, Reflectable {

    static func validations() throws -> Validations<OrderAddressObject> { // 1
        
        var validations = Validations(OrderAddressObject.self) // 2
    
        validations.add("OrderAddressObject") { model in // 3
            guard model.billingAddress == true && model.shippingAddress == true else { // 4
                throw BasicValidationError("Invalid address type: Both values must be true.") // 5
            }
        }
        return validations // 4
    }
}
