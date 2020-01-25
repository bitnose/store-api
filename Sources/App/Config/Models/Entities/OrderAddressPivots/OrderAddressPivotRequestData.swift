//
//  OrderAddressPivotRequestData.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor

// MARK: - Datatypes for decoding requests

/**
 # OrderAddressObject
 - addressID : Address.ID
 - billingAddress: Bool
 - shippingAddress: Bool
 */
struct OrderAddressObject: Content {
    let addressID: Address.ID
    let billingAddress: Bool
    let shippingAddress: Bool
}
