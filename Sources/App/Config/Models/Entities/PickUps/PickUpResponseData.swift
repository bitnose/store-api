//
//  ResponseData.swift
//  App
//
//  Created by Sötnos on 26.1.2020.
//

import Foundation
import Vapor

// MARK: - Datatypes that are used to encode responses


/**
    # PickUpObject : Contains data to api/pickups/cities/city:ID
    - pickUpID
    - deliveryDate
    - timePeriod
    - price
    - pickUpStop
 */
struct PickUpObject : Content {
    let pickUpID : UUID?
    let deliveryDate: Date
    let timePeriod: TimePeriod
    let price : Float
    let pickUpStop : PickUpStopObject
}
