//
//  ResponseData.swift
//  App
//
//  Created by Sötnos on 20.1.2020.
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

/**
 # PickUpStopObject : Contains data to api/pickups/cities/city:ID
    - id
    -  addressID
    - street
    - postalcode
    - city
    - country
 */
struct PickUpStopObject : Content {
    let id : UUID?
    let addressID: UUID?
    let street : String
    let postalcode: Int
    let city: String
    let country : String
}

/**
 # Data type for the full product info in specific language
 - productID
 - price
 - images
 - productTranslation
 */

struct ProductWithTranslation: Content {
    let id: UUID?
    let price : Float
    let images : [String]
    let productTranslation: ProductLanguagePivot
}
