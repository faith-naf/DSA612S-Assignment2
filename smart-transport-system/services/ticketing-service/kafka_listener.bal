import ballerina/log;
import ballerina/uuid;
import ballerinax/kafka;
import ballerinax/mongodb;

// Kafka consumer configuration
kafka:ConsumerConfiguration consumerConfig = {
    groupId: "ticketing-group",
    topics: ["ticket.requests"],
    offsetReset: kafka:OFFSET_RESET_EARLIEST,
    autoCommit: true
};

// Kafka consumer
listener kafka:Listener kafkaConsumer = new (kafka:DEFAULT_URL, consumerConfig);

// Kafka producer for sending responses
final kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL);

// MongoDB client (same as in main.bal)
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

// Service to listen to ticket requests
service on kafkaConsumer {
    
    remote function onConsumerRecord(kafka:Caller caller, kafka:ConsumerRecord[] records) returns error? {
        
        foreach kafka:ConsumerRecord record in records {
            string message = check string:fromBytes(record.value);
            log:printInfo("Received ticket request: " + message);
            
            // Parse the message
            json ticketRequest = check message.fromJsonString();
            
            // Create ticket
            string ticketId = uuid:createType4AsString();
            
            map<json> ticket = {
                "ticket_id": ticketId,
                "user_id": check ticketRequest.user_id,
                "trip_id": check ticketRequest.trip_id,
                "ticket_type": check ticketRequest.ticket_type,
                "price": 50.0,
                "status": "CREATED",
                "purchase_time": check ticketRequest.timestamp
            };
            
            // Save to MongoDB
            mongodb:Database db = check mongoDb->getDatabase("transport_system");
            mongodb:Collection ticketCollection = check db->getCollection("tickets");
            
            check ticketCollection->insertOne(ticket);
            
            log:printInfo("Ticket created: " + ticketId);
            
            // Send payment request to Kafka
            json paymentRequest = {
                "event_type": "PAYMENT_REQUESTED",
                "ticket_id": ticketId,
                "user_id": check ticketRequest.user_id,
                "amount": 50.0,
                "timestamp": check ticketRequest.timestamp
            };
            
            check kafkaProducer->send({
                topic: "payments.processed",
                value: paymentRequest.toJsonString()
            });
            
            log:printInfo("Payment request sent for ticket: " + ticketId);
        }
    }

}

