//
//  RequestData.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor

// MARK: - Datatypes for encoding data


/**
 # Data type for the full product info in specific language
 - productID
 - price
 - productTranslation
 */

struct ProductWithTranslation: Content {
    let id: UUID?
    let price : Double
    let productTranslation: ProductLanguagePivot
}
