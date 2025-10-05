import ballerina/http;
import ballerina/log;
import ballerina/uuid;

service /payment on new http:Listener(8084) {
    
    resource function get health() returns json {
        return {
            status: "UP",
            services: "Payment Service",
            port: 8084
        };
    }
    
    resource function post process(@http:Payload json paymentRequest) returns json|error {
        log:printInfo("Processing payment");
        
        string paymentId = uuid:createType4AsString();
        
        // Simulate payment processing
        return {
            success: true,
            payment_id: paymentId,
            status: "COMPLETED",
            message: "Payment processed successfully"
        };
    }
    
    resource function get payments/[string paymentId]() returns json {
        log:printInfo("Fetching payment: " + paymentId);
        
        return {
            payment_id: paymentId,
            status: "COMPLETED",
            amount: 100.00
        };
    }
}