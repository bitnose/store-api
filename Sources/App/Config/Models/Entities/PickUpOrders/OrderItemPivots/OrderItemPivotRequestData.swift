//
//  OrderItemPivotRequestData.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor

// MARK: - Datatypes for decoding requests

/**
 # OrderItem Object
 - productID : Product.ID
 - productQuantity: Int

 */
struct OrderItemObject: Content {
    let productID : Product.ID
    let productQuantity: Int
}
