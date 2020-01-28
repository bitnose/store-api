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
