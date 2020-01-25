//
//  OrderItemObject+Reflectable+Validatable.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
//
//  PickUpOrderObject+Reflectable+Validatable.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor

/// # Extension for the OrderItemObject to make it conform to Validatable and Reflectable.
/// - Validatable allows you to validate types with Vapor
/// - Reflectable provides a way to discover the internal components of a type
/// - Because you use key paths, Vapor creates type-safe validations.

/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Ensure that the quantity is between 1-50.
/// 4. Return the validations for Vapor to test.

extension OrderItemObject: Validatable, Reflectable {
    
    static func validations() throws -> Validations<OrderItemObject> { // 1
        
        var validations = Validations(OrderItemObject.self) // 2
        try validations.add(\.productQuantity, .range(1...100)) // 3
        
        return validations // 4
    }
}
