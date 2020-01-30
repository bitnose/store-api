//
//  EmailSender.swift
//  App
//
//  Created by Sötnos on 29.1.2020.
//

import Foundation
import Service
import SwiftSMTP

// MARK: - Class responsible of sending emails

/** # EmailSender
 - header : A filepath to the file which contains a header html for the email.
 - footer: A filepath to the file which contains a footer html for the email.
 - config : SMTPConfig object which repserents environment variables for the SMTP Service.
 */
final class EmailSender : ServiceType {
    
    private let header: String
    private let footer: String
    private let config: SMTPConfig
    
    // Init
    private init(header: String, footer: String, config: SMTPConfig) {
        self.header = header
        self.footer = footer
        self.config = config
    }
    
    /**
     # MakeService static function, ie initializes the EmailSender
     - parameters:
        - for worker: Containers are used to create instances of services that your application needs in a configurable way (Request, Response, Application)
        - throws: Abort
     -  returns: EmailSender Object what is used to send emails
     
     1. Make a new service: DirectoryConfig represents a configured working directory.
     2. Create a header  string what is a filepath to the mail-header.html file.
     3. Create a footer string what is a filepath to the mail-footer.html file.
     4. Create and Return EmailSender.
     */
    static func makeService(for worker: Container) throws -> EmailSender {
        let directoryConfig = try worker.make(DirectoryConfig.self) // 1
        let header = try String(contentsOfFile: directoryConfig.workDir + "Resources/mail-header.html") // 2
        let footer = try String(contentsOfFile: directoryConfig.workDir + "Resources/mail-footer.html") // 3
        return EmailSender(header: header, footer: footer, config: try worker.make()) // 4
    }
    
    /**
     # Send function to send email
      - parameters:
        - to email: Receiver's email address
        - name: Receiver's name
        - subject: The subject of the mail
        - content: The content of the mail.
          - throws: Abort
       -  returns: EmailSender Object what is used to send emails

     1. Create a constant which represents a html.
     2: Create a mail object.
     3. The seder of the mail.
     4. The receiver of the mail.
     5. The siubject of the mail.
     6. The content of the mail.
     7. Make an instance of SMTP what is used to connect to an SMTP server and send the mail. Add all the configuration data.
     8. Call method to send the mail.
     */
    
    func send(to email: String, name: String, subject: String = "***", content: String) {
        
        let html = header + content + footer // 1
        let mail = Mail( // 2
                        from: Mail.User( // 3
                        name: "Store",
                        email: config.email),
                        
                        to: [Mail.User( // 4
                        name: name,
                        email: email)],
                        
                        subject: subject, // 5
                        text: html) // 6
        
        SMTP(hostname: config.host, // 7
             email: config.email,
             password: config.password,
             port: Int32(config.port),
             tlsMode: .requireSTARTTLS,
             tlsConfiguration: nil,
             timeout: 100)
            .send(mail) // 8
    }
}
