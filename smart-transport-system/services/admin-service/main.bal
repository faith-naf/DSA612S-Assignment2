import ballerina/http;
import ballerina/log;

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
            total_tickets: 0
        };
    }
}