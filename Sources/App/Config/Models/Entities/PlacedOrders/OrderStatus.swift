//
//  OrderStatus.swift
//  App
//
//  Created by Sötnos on 20.1.2020.
//
import Foundation
import FluentPostgreSQL
import Vapor

/**
 # OrderStatus
 A new enum string type which tells different statuses. 
 FluentPostgreSQL to expose the required types for the enum.
 Create a new String enum type, The type conformances allow Fluent to use the type in the database and prepare the database correctly. The type must be a String enum to conform to Codable.
 
 - shoppingCart - Order not accepted
 - pendingPayment – Order accepted, no payment initiated. Awaiting payment (unpaid).
 - failed – Payment failed or was declined (unpaid) or requires authentication (SCA). Note that this status may not show immediately and instead show as Pending until verified (e.g., PayPal).
 - awaitingCollecting – Payment received (paid) and order is awaiting fulfillment.
 - awaitingShipment - Products are collected and order is awaitng shipment.
 - awaitingPickup - Products are collected and order is awaiting pickup.
 - completed – Order fulfilled and complete – requires no further action.
 - onHold – Awaiting payment – stock is reduced, but you need to confirm payment.
 - cancelled – Cancelled by an admin or the customer.
 - refunded – Refunded by an admin.
 - authenticationRequired — Awaiting action by the customer to authenticate transaction and/or complete SCA requirements.
*/

enum OrderStatus: String, PostgreSQLEnum, PostgreSQLMigration, Content {
    case shoppingCart
    case pendingPayment
    case failed
    case awaitingCollecting
    case awaitingShipment
    case awaitingPickup
    case completed
    case onHold
    case cancelled
    case refunded
    case authenticationRequired
}
