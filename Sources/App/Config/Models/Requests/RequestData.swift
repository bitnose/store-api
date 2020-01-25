//
//  RequestData.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor

// MARK: - Datatypes for decoding requests
/**
 # API: Create Order Object
 -  totalPrice : Float
 -  totalTaxes: Float
 - deliveryFee: Float
 - orderStatus: OrderStatus
 - userID : User.ID
 - isHomeDelivery: Bool
 - CustomerObject
 - [OrderAddressObject]
 - [OrderItemObject]
 - PickUpOrderObject?
 - HomeDeliveryOrderObject?
 */
struct PlacedOrderObject : Content{
//    let totalPrice: Float
//    let totalTaxes: Float
//    let deliveryFee: Float
//    let orderStatus : OrderStatus
//    let userID : User.ID
    let isHomeDelivery: Bool
    let customerObject: CustomerObject
    let orderAddressObject: [OrderAddressObject]
    let orderItemObject: [OrderItemObject]
    let pickUpOrderObject: PickUpOrderObject?
    let homeDeliveryOrderObject: HomeDeliveryOrderObject?
}
/**
 # CustomerObject
 - firstname: String
 - lastname : String
 - email : String
 */
struct CustomerObject : Content{
    let firstname: String
    let lastname : String
    let email : String
}
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
/**
 # OrderItem Object
 - productID : Product.ID
 - productQuantity: Int
 - status: String
 - totalPrice: Float
 */
struct OrderItemObject: Content {
    let productID : Product.ID
    let productQuantity: Int
//    let status: String
//    let totalPrice: Float
}

/**
 # PickUpOrder object
 - pickUpID : PickUp.ID
 - note: String
 - finalDeliveryFee: Float
 - status: String
 */
struct PickUpOrderObject: Content {
    let pickUpID : PickUp.ID
    let note: String
//    let finalDeliveryFee: Float
//    let status: String
}

/**
 # HomeDeliveryOrder object
 - homeDeliveryID : HomeDelivery.ID
 - note: String
 - finalDeliveryFee: Float
 - status: String
 
 */
struct HomeDeliveryOrderObject: Content {
    let homeDeliveryID : HomeDelivery.ID
    let note: String
//    let finalDeliveryFee: Float
//    let status: String
}
