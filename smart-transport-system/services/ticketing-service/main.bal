import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ballerinax/mongodb;

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

service /ticketing on new http:Listener(8083) {
    
    resource function get health() returns json {
        return {
            status: "UP",
            services: "Ticketing Service",
            port: 8083
        };
    }
    
    // Create ticket
    resource function post tickets(@http:Payload json payload) returns json|error {
        log:printInfo("Creating ticket");
        
        string ticketId = uuid:createType4AsString();
        
        map<json> ticket = {
            "ticket_id": ticketId,
            "user_id": check payload.user_id,
            "trip_id": check payload.trip_id,
            "ticket_type": check payload.ticket_type,
            "price": check payload.price,
            "status": "CREATED",
            "purchase_time": "2025-10-03T10:00:00Z"
        };
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection ticketCollection = check db->getCollection("tickets");
        
        check ticketCollection->insertOne(ticket);
        
        return {
            success: true,
            ticket_id: ticketId,
            status: "CREATED",
            message: "Ticket created successfully"
        };
    }
    
    // Get ticket by ID
    resource function get tickets/[string ticketId]() returns json|error {
        log:printInfo("Fetching ticket: " + ticketId);
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection ticketCollection = check db->getCollection("tickets");
        
        map<json> filter = {"ticket_id": ticketId};
        json|mongodb:Error result = ticketCollection->findOne(filter);
        
        if result is mongodb:Error {
            return {
                success: false,
                message: "Ticket not found"
            };
        }
        
        return result;
    }
    
    // Validate ticket
    resource function put tickets/[string ticketId]/validate() returns json|error {
        log:printInfo("Validating ticket: " + ticketId);
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection ticketCollection = check db->getCollection("tickets");
        
        map<json> filter = {"ticket_id": ticketId};
        map<json> update = {
            "$set": {
                "status": "VALIDATED",
                "validation_time": "2025-10-03T10:00:00Z"
            }
        };
        
        mongodb:UpdateResult|mongodb:Error result = ticketCollection->updateOne(filter, update);
        
        if result is mongodb:Error {
            return {
                success: false,
                message: "Validation failed"
            };
        }
        
        return {
            success: true,
            ticket_id: ticketId,
            status: "VALIDATED",
            message: "Ticket validated successfully"
        };
    }

}

