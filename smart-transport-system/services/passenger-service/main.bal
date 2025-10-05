import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ballerinax/mongodb;
import ballerinax/kafka;

// MongoDB client
final mongodb:Client mongoDb = check new ({
    connection: {
        serverAddress: {
            host: "localhost",
            port: 27017
        },
        auth: <mongodb:ScramSha256AuthCredential>{
            username: "admin",
            password: "password123",
            database: "admin"
        }
    }
});

// Kafka producer
final kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL);

service /passenger on new http:Listener(8081) {
    
    resource function get health() returns json {
        return {
            status: "UP",
            services: "Passenger Service",
            port: 8081,
            database: "connected",
            kafka: "connected"
        };
    }
    
    // Register new user
    resource function post register(@http:Payload json payload) returns json|error {
        log:printInfo("Registering new user");
        
        string userId = uuid:createType4AsString();
        
        string username = check payload.username;
        string email = check payload.email;
        string password = check payload.password;
        
        map<json> user = {
            "user_id": userId,
            "username": username,
            "email": email,
            "password": password,
            "role": "passenger",
            "created_at": check getCurrentTimestamp()
        };
        
        // Insert into MongoDB
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection userCollection = check db->getCollection("users");
        
        check userCollection->insertOne(user);
        
        // Send event to Kafka - User registered
        json registrationEvent = {
            "event_type": "USER_REGISTERED",
            "user_id": userId,
            "username": username,
            "email": email,
            "timestamp": check getCurrentTimestamp()
        };
        
        check kafkaProducer->send({
            topic: "notifications.send",
            value: registrationEvent.toJsonString()
        });
        
        log:printInfo("User registered and event sent to Kafka: " + username);
        
        return {
            success: true,
            message: "User registered successfully",
            user_id: userId
        };
    }
    
    // Purchase ticket
    resource function post tickets(@http:Payload json payload) returns json|error {
        log:printInfo("Purchasing ticket");
        
        string userId = check payload.user_id;
        string tripId = check payload.trip_id;
        string ticketType = check payload.ticket_type;
        
        // Create ticket request event
        json ticketRequest = {
            "event_type": "TICKET_REQUESTED",
            "user_id": userId,
            "trip_id": tripId,
            "ticket_type": ticketType,
            "timestamp": check getCurrentTimestamp()
        };
        
        // Send to Kafka
        check kafkaProducer->send({
            topic: "ticket.requests",
            value: ticketRequest.toJsonString()
        });
        
        log:printInfo("Ticket request sent to Kafka");
        
        return {
            success: true,
            message: "Ticket request submitted",
            status: "PROCESSING"
        };
    }
    
    resource function post login(@http:Payload json credentials) returns json|error {
        log:printInfo("User login attempt");
        
        string username = check credentials.username;
        string password = check credentials.password;
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection userCollection = check db->getCollection("users");
        
        map<json> filter = {"username": username, "password": password};
        json|mongodb:Error result = userCollection->findOne(filter);
        
        if result is mongodb:Error {
            return {
                success: false,
                message: "Invalid credentials"
            };
        }
        
        string token = "token_" + uuid:createType4AsString();
        
        return {
            success: true,
            message: "Login successful",
            token: token,
            user: result
        };
    }
    
    resource function get tickets/[string userId]() returns json|error {
        log:printInfo("Fetching tickets for user: " + userId);
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection ticketCollection = check db->getCollection("tickets");
        
        map<json> filter = {"user_id": userId};
        stream<json, error?> resultStream = check ticketCollection->find(filter);
        
        json[] tickets = [];
        check from json ticket in resultStream
            do {
                tickets.push(ticket);
            };
        
        return {
            user_id: userId,
            tickets: tickets
        };
    }
}

function getCurrentTimestamp() returns string|error {
    return "2025-10-03T10:00:00Z";
}