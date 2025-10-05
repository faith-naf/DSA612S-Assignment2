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

service /transport on new http:Listener(8082) {
    
    resource function get health() returns json {
        return {
            status: "UP",
            services: "Transport Service",
            port: 8082
        };
    }
    
    // Get all routes
    resource function get routes() returns json|error {
        log:printInfo("Fetching all routes");
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection routeCollection = check db->getCollection("routes");
        
        stream<json, error?> resultStream = check routeCollection->find({});
        
        json[] routes = [];
        check from json route in resultStream
            do {
                routes.push(route);
            };
        
        return {
            count: routes.length(),
            routes: routes
        };
    }
    
    // Create new route
    resource function post routes(@http:Payload json payload) returns json|error {
        log:printInfo("Creating new route");
        
        string routeId = uuid:createType4AsString();
        
        map<json> route = {
            "route_id": routeId,
            "name": check payload.name,
            "transport_type": check payload.transport_type,
            "stops": check payload.stops,
            "active": true
        };
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection routeCollection = check db->getCollection("routes");
        
        check routeCollection->insertOne(route);
        
        return {
            success: true,
            route_id: routeId,
            message: "Route created successfully"
        };
    }
    
    // Get trips for a route
    resource function get trips/[string routeId]() returns json|error {
        log:printInfo("Fetching trips for route: " + routeId);
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection tripCollection = check db->getCollection("trips");
        
        map<json> filter = {"route_id": routeId};
        stream<json, error?> resultStream = check tripCollection->find(filter);
        
        json[] trips = [];
        check from json trip in resultStream
            do {
                trips.push(trip);
            };
        
        return {
            route_id: routeId,
            count: trips.length(),
            trips: trips
        };
    }
    
    // Create new trip
    resource function post trips(@http:Payload json payload) returns json|error {
        log:printInfo("Creating new trip");
        
        string tripId = uuid:createType4AsString();
        
        map<json> trip = {
            "trip_id": tripId,
            "route_id": check payload.route_id,
            "departure_time": check payload.departure_time,
            "arrival_time": check payload.arrival_time,
            "status": "scheduled",
            "vehicle_info": check payload.vehicle_info
        };
        
        mongodb:Database db = check mongoDb->getDatabase("transport_system");
        mongodb:Collection tripCollection = check db->getCollection("trips");
        
        check tripCollection->insertOne(trip);
        
        return {
            success: true,
            trip_id: tripId,
            message: "Trip created successfully"
        };
    }
}

