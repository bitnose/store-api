////
////  SMTPHelper.swift
////  App
////
////  Created by Sötnos on 29.1.2020.
////
//
//import Foundation
//import Service
//import SwiftSMTP
//
///**
// # SMTPHelper struct is responsible of sending emails.
//    - smtp : SMTP
//    - config = SMTPConfiguration instance
// */
//
//struct SMTPHelper {
//
//    let smtp : SMTP
//    private let config = SMTPConfiguration()
//
//    // Inits
//    init() {
//       // Set up configurations
//        let smtpConfig = config.setup()
//        self.smtp = SMTP(hostname: smtpConfig.host, email: smtpConfig.email, password: smtpConfig.password, port: Int32(smtpConfig.port), tlsMode: .requireSTARTTLS, tlsConfiguration: nil)
//
//    }
//
//    /**
//     # WELCOMING MAIL
//     - parameters:
//        - name : The name of the user
//        - email : The email address of the user
//     - throws : Abort
//
//     1. Method sends an email to the email address and returns nothing.
//     2. Add a Sender of the mail
//     3. Add a Receiver of the mail
//     4. Create a mail object.
//     5.  Send the created mail.  In the closure, check if there are any errors, if yes print them out.
//     */
//    func sendWelcomingMail(name: String, email: String) {
//
//        let sender = Mail.User(name: "Store", email: config.setup().email) // 2
//        let receiver = Mail.User(name: name, email: email) // 3
//
//              // 4
//        let mail = Mail(
//                  from: sender,
//                  to: [receiver],
//                  subject: "Confirmation",
//                  text:
//            """
//
//            Hi \(name)!
//
//            Thank you for registering to our application!
//
//
//            Best Regards,
//            Store team
//
//            """
//
//              )
//
//              // 5
//              smtp.send(mail) { error in
//                  if let error = error {
//                      print(error, "Couldn't send.")
//                  }
//              }
//        }
//
//
//
//
//        /**
//         # WELCOMING MAIL
//         - parameters:
//            - name : The name of the user
//            - email : The email address of the user
//            - order: PlacedOrderObject
//
//         1. Method sends an email to the email address and returns nothing.
//         2. Add a Sender of the mail
//         3. Add a Receiver of the mail
//         4. Create a mail object.
//         5.  Send the created mail.  In the closure, check if there are any errors, if yes print them out.
//         */
//    func sendOrderConfirmation(name: String, email: String, order: PlacedOrder) {
//
//            let sender = Mail.User(name: "Store", email: config.setup().email) // 2
//            let receiver = Mail.User(name: name, email: email) // 3
//
//
//
//
//
//                  // 4
//            let mail = Mail(
//                      from: sender,
//                      to: [receiver],
//                      subject: "Confirmation",
//                      text:
//                """
//
//                Hi \(name),
//
//                Thank you for your order.
//
//
//                    Order price: \(order.totalPrice)
//                    Payment Method:
//                    Order number:
//
//
//                SHIPPING
//
//                    Shipping Method:
//                    Shipping Address:
//
//
//                PRODUCTS
//
//                    Product1
//                        Price
//                        Quantity
//
//                    Product2
//                        Price
//                        Quantity
//
//                TOTAL
//
//                        Payment Method
//                        Delivery
//                        Products
//                TOTAL
//
//
//
//
//                Best Regards,
//                Store team
//
//                """
//
//                  )
//
//                  // 5
//                  smtp.send(mail) { error in
//                      if let error = error {
//                          print(error, "Couldn't send.")
//                      }
//                  }
//            }
//
//
//
//
//
//
//
//
//
//
//
//
//    // MARK: - RESET PASSWORD MAIL
//
//    /**
//     # RESET PASSWORD MAIL
//     - parameters:
//        - name : The name of the user
//        - email : The email address of the user
//     - throws : Abort
//
//     1. Method sends an email to the email address and returns nothing.
//     2. Add a Sender of the mail
//     3. Add a Receiver of the mail
//     4. Create a mail object.
//     5.  Send the created mail.  In the closure, check if there are any errors, if yes print them out.
//     */
//
//    func sendResetPasswordEmail(name: String, email: String, resetTokenString:String) { // 1
//
//        let sender = Mail.User(name: "Store", email: config.setup().email) // 2
//        let receiver = Mail.User(name: name, email: email) // 3
//
//        // 4
//        let mail = Mail(
//            from: sender,
//            to: [receiver],
//            subject: "Reset Your Password",
//            text: """
//
//            Hi \(name)!
//
//            You've requested to reset your password.  Click this link to reset your password: https://eegj.fr/resetPassword?token=\(resetTokenString)
//
//            If it wasn't you, just ignore this email.
//
//
//            Best Regards,
//            Store team
//
//            """
//
//        )
//
//        // 5
//        smtp.send(mail) { error in
//            if let error = error {
//                print(error, "Couldn't send.")
//            }
//        }
//    }
//
//
//}
//
//
//
