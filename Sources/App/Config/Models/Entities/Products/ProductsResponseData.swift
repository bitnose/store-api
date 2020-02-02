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
 # Data type for the full product info in specific language
 - productID
 - price
 - images
 - productTranslation
 */
struct ProductWithTranslation: Content {
    let id: UUID?
    let price : Decimal
    let images : [String]
    let productTranslation: ProductLanguagePivot
}

