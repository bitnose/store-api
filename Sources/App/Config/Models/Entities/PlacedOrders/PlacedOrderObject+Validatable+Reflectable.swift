//
//  PlacedOrderObject+Validatable+Reflectable.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//
import Foundation
import Vapor

/// # Extension for the PlacedOrderObject to make it conform to Validatable and Reflectable.
/// - Validatable allows you to validate types with Vapor
/// - Reflectable provides a way to discover the internal components of a type
/// - Because you use key paths, Vapor creates type-safe validations.

/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
///
/// # Custom Validator
/// Use Validation's add(_:_:) to add a custom validator for the data. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validation fails.
///
/// 3. Custom Validator: Add a validator to ensure that the array is not empty ie. products are selected.  Throw  a validation error if the validation fails.
/// 3A. Validate each element in the array by looping the array through
/// 4. Custom Validator: Add a validator to ensure that the array is not empty ie. addresses are selected the count of the elements is maximum 2 ie less than 3. Throwa validation error if the validation fails.
/// 5. Custom Validator: Validate that we have correct address data.
/// 6. If the count of the array is 2, make two arrays by filtering the first array with the different values.
/// 7. Arr = The array of objects which have the value of the billingAddress attribute true.
/// 8. Arr2  = The array of objects which have the value of the shippingAddress attribute true.
/// 9. Ensure that there are 1 object in both arrays. Otherwise, throw BasicValidationError with the message.
/// 10. If the array has only one element, ensure that the both boolean values are true. Otherwise, throw BasicValidationError with the message.
/// 11. Custom Validator:
/// 12. If the value is true ensure that homeDeliveryOrderObject is not nil and that pickUpOrderObject is nil.
/// 13. Otherwise, throw BasicValidationError with the message.
/// 14. Use Validation's add(_:_:) to add a custom validator for the data. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validation fails.
/// 15.  If the boolean value is false ensure that homeDeliveryOrderObject is nil and that pickUpOrderObject is not nil.
/// 16. Return validations.

extension PlacedOrderObjectV2: Validatable, Reflectable {
    
    static func validations() throws -> Validations<PlacedOrderObjectV2> { // 1
        
        var validations = Validations(PlacedOrderObjectV2.self) // 2
        
//        validations.add("OrderItemObjects") { model in // 3
//            guard !model.orderItemObject.isEmpty else{ throw BasicValidationError("There are no order items selected")}
//
//            for item in model.orderItemObject { try item.validate() } // 3A
//        }
        
        validations.add("OrderAddressObjects") { model in // 4
            guard !model.orderAddressObject.isEmpty && model.orderAddressObject.count<3 else{ throw BasicValidationError("There are no order addresses added")}
        }
         validations.add("OrderAddressObjects") { model in // 5
            
            if model.orderAddressObject.count == 2 { // 6
                let arr = model.orderAddressObject.filter{ $0.billingAddress == true} // 7
                let arr2 = model.orderAddressObject.filter{$0.shippingAddress == true} // 8
                
                guard arr.count == 1 && arr2.count == 1 else {throw BasicValidationError("Invalid address data: Too many addresses.")} // 9
            } else {
                try model.orderAddressObject.first!.validate()
            }
        }
        validations.add("Shipping") { model in // 11
            // 12
            if model.isHomeDelivery == true {
                guard model.homeDeliveryOrderObject != nil && model.pickUpOrderObject == nil else { throw BasicValidationError("Invalid data: Error with the   HomeDelivery data.") // 13
                }
            } else { // 14
                guard model.homeDeliveryOrderObject == nil && model.pickUpOrderObject != nil else { throw BasicValidationError("Invalid data: Error with the PickUp data.") // 15
                }
            }
        }
        return validations // 16
    }
}
