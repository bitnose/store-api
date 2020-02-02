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
 - isHomeDelivery: Bool
 - CustomerObject
 - [OrderAddressObject]
 - [OrderItemObject]
 - PickUpOrderObject?
 - HomeDeliveryOrderObject?
 */
struct PlacedOrderObject : Content{
    let isHomeDelivery: Bool
    let customerObject: CustomerObject
    let orderAddressObject: [OrderAddressObject]
    let orderItemObject: [OrderItemObject]
    let pickUpOrderObject: PickUpOrderObject?
    let homeDeliveryOrderObject: HomeDeliveryOrderObject?
}


struct PlacedOrderObjectV2 : Content{
    let isHomeDelivery: Bool
    let customerObject: CustomerObject
    let orderAddressObject: [OrderAddressObject]
 //   let orderItemObject: [OrderItemObject]
    let pickUpOrderObject: PickUpOrderObject?
    let homeDeliveryOrderObject: HomeDeliveryOrderObject?
}




