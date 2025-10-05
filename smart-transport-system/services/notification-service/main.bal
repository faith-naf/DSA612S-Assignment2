import ballerina/http;
import ballerina/log;
import ballerina/uuid;

service /admin on new http:Listener(8086) {
    
    resource function get health() returns json {
        return {
            status: "UP",
            services: "Admin Service",
            port: 8086
        };
    }
    
    resource function get reports/tickets() returns json {
        log:printInfo("Generating ticket sales report");
        return {
            total_sales: 0,
            total_tickets: 0,
            report_date: "2025-10-02"
        };
    }
    
    resource function get reports/revenue() returns json {
        log:printInfo("Generating revenue report");
        return {
            total_revenue: 0.00,
            report_date: "2025-10-02"
        };
    }
    
    resource function post disruptions(@http:Payload json disruption) returns json|error {
        log:printInfo("Publishing service disruption");
        
        string disruptionId = uuid:createType4AsString();
        
        return {
            success: true,
            disruption_id: disruptionId,
            message: "Disruption published successfully"
        };
    }
}