//
//  Product+Price.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

extension Product {
    
    /**
     # Method to compute the price for the order item
     - parameters:
        - req: Request
        - count: Quantity of the same kind of products in order
        - productID: The unique identifier of the seleted product
     
     1. Find the product with the given ID. Unwrap the future.
     2. Change the type of count from Int to Float.
     3. Calculate the price.
     4. Return the price.
     
     */
    static func calculatePrice(_ req: Request, count: Int, productID: Product.ID) throws -> Future<Float> {
        
        return Product.find(productID, on: req).unwrap(or: Abort(.notFound)).map(to: Float.self) { foundProduct in // 1
            let quantity = Float(count) // 2
            let price = foundProduct.price * quantity // 3
            return price // 4
        }
    }
    
}
