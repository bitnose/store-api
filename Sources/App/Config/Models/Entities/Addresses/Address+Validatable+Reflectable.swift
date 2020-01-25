//
//  Address+Validatable+Reflectable.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor

/// # Extension for the Address to make it conform to Validatable and Reflectable.
/// - Validatable allows you to validate types with Vapor
/// - Reflectable provides a way to discover the internal components of a type
/// - Because you use key paths, Vapor creates type-safe validations.

/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Validate that the string contains 1-30 characters.
/// 4. Validate that the value of the int is less than 999999.
/// 5. Return the validations for Vapor to test.

extension Address: Validatable, Reflectable {
    
    static func validations() throws -> Validations<Address> { // 1
        
        var validations = Validations(Address.self) // 2
        try validations.add(\.city, .count(1...30)) // 3
        try validations.add(\.street, .count(1...30)) // 3
        try validations.add(\.country, .count(1...30)) // 3
        try validations.add(\.postalcode, .range(...999999)) // 4
      
        return validations // 5
    }
}
