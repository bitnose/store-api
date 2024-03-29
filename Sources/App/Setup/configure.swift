import Vapor
import FluentPostgreSQL
import Authentication
import VaporExt

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    // MARK: - Provider configs
    
    /*
     Register providers first:
     1. Register FluentPostgreSQL Provider
     2. Registers the necessary services with your application to ensure authentication works
     */
    
    try services.register(FluentPostgreSQLProvider()) // 1
    try services.register(AuthenticationProvider()) // 2
   
    // MARK: - Router configs
    
    /*
    Register routes to the router
     */
    
    let router = EngineRouter.default()
    try routes(router)
    
    services.register(router, as: Router.self)
    services.register(LogMiddleware.self)
    
    /*
     SMTP Configure & EmailSender
       1. Get the environment keys
       2. Fetch the environment variables
       3. Make a SMTPConfig instance.
       4. Register the configured SMTPConfig.
       5. Register EmailSender.
       */
    
     Environment.dotenv(filename: "smtp-configure.env") // 1
    // 2
    let smtpHost = Environment.get("SMTP_HOST", "")
    let smtpMail = Environment.get("SMTP_EMAIL", "")
    let smtpPassword = Environment.get("SMTP_PASSWORD", "")
    let smtpPort = Environment.get("SMTP_PORT", Int())
    let smtpDomainName = Environment.get("DOMAIN_NAME", "")

    let smtpConfig = SMTPConfig(host: smtpHost,
                                port: smtpPort,
                                email: smtpMail,
                                password: smtpPassword)
    services.register(smtpConfig)
    services.register(EmailSender.self)
    
    // MARK: - Middleware configs
    
    /*
     Register middlewares
     1. Create _empty_ middleware config
     2. Catches errors and converts to HTTP response
     3. Logging middleware: Register before ErrorMiddelare so the LogMiddleware logs the original request from the client unmodified by other middleware.
     4. Register the middlewares
     */
    var middlewares = MiddlewareConfig() // 1
    middlewares.use(LogMiddleware.self) // 3
    middlewares.use(ErrorMiddleware.self) // 2
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    services.register(middlewares) // 4
   
    // MARK: - NIOServerConfigs
    
    // There is a default limit of 1 million bytes for incoming requests, which you can override by registering a custom NIOServerConfig instance like this:
    services.register(NIOServerConfig.default(maxBodySize: 20_000_000))
    
    // MARK: - Database configs
    
    /*
     1. Get the environment keys
     2. Fetch the environment variables
     3. Configure a PostgreSQL database
     4. Register the configured PostgreSQL database to the database config.
     */
    
     Environment.dotenv(filename: "postgres-config.env") // 1
    
    // 2
    let databaseName = Environment.get("POSTGRES_DATABASE_NAME", "")
    let hostname = Environment.get("POSTGRES_HOSTNAME", "")
    let databasePort =  Environment.get("POSTGRES_PORT", Int())
    let username =  Environment.get("POSTGRES_USERNAME", "")
    let password = Environment.get("POSTGRES_PASSWORD", "")
    
    // 3
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: databasePort,
        username: username,
        database: databaseName,
        password: password)
    let database = PostgreSQLDatabase(config: databaseConfig)
    
    // 2
    var databases = DatabasesConfig()
    databases.add(database: database, as: .psql)
    databases.enableLogging(on: .psql)
    services.register(databases)
    
    let serverConfig = NIOServerConfig.default(hostname: "0.0.0.0")
    services.register(serverConfig)
    
    // MARK: - Migration configs
    
    /*
     Configure migrations:
     1. Add Model to the Migration list - Adds the new model to the migrations so Fluent prepares the table in the database
     2. Add Migration to the MigrationConfig : AdminUser
     3. This adds the migration to MigrationConfig so Fluent prepares the database correctly to use the enum. Note this uses add(migration:database:) rather than add(model:database:) since UserType isn’t a model
     */
    
    var migrations = MigrationConfig()
    // 1
    migrations.add(migration: UserType.self, database: .psql)
    migrations.add(migration: TimePeriod.self, database: .psql)
    migrations.add(migration: OrderStatus.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: Product.self, database: .psql)
    migrations.add(model: Language.self, database: .psql)
    migrations.add(model: ProductLanguagePivot.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: CategoryLanguagePivot.self, database: .psql)
    migrations.add(model: ProductCategoryPivot.self, database: .psql)
    migrations.add(model: Address.self, database: .psql)
    migrations.add(model: UserAddressPivot.self, database: .psql)
    migrations.add(model: PlacedOrder.self, database: .psql)
    migrations.add(model: OrderItemPivot.self, database: .psql)
    migrations.add(model: City.self, database: .psql)
    migrations.add(model: PickUpStop.self, database: .psql)
    migrations.add(model: Customer.self, database: .psql)
    migrations.add(model: PickUp.self, database: .psql)
    migrations.add(model: PickUpOrder.self, database: .psql)
    migrations.add(model: HomeDelivery.self, database: .psql)
    migrations.add(model: HomeDeliveryOrder.self, database: .psql)
    migrations.add(model: OrderAddressPivot.self, database: .psql)
    
    
    //MARK: - Migrations based on the environment
    // 1. If the application is in either development or testing environment, (2.) add these models to migrations.
    // 3. Otherwise these migrations won't happen.
    
    switch env {
    case .development, .testing: // 1
         migrations.add(migration: AdminUser.self, database: .psql) // 2
    default: // 3
        break
    }
    
    services.register(migrations) // Register migrations
    
    // MARK: - Command configs
    
    // Add the Fluent commands to your application, which allows you to manually run migrations and allows you to revert your migrations
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
   
    // MARK: - Server configs
    
    // Set up the hostname and port number and register this service
    let serverConfigure = NIOServerConfig.default(hostname: "localhost", port: 9090)
    services.register(serverConfigure)
    // Tells your application to use MemoryKeyedCache when asked for the KeyedCache service. The KeyedCache service is a key-value cache that backs sessions.
 //   config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    
}
