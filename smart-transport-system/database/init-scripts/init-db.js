// Switch to transport_system database
db = db.getSiblingDB('transport_system');

// Create collections
db.createCollection('users');
db.createCollection('routes');
db.createCollection('trips');
db.createCollection('tickets');
db.createCollection('payments');

print('✅ Collections created successfully!');

// Create indexes for better performance
db.users.createIndex({ "username": 1 }, { unique: true });
db.users.createIndex({ "email": 1 }, { unique: true });
db.routes.createIndex({ "route_id": 1 }, { unique: true });
db.trips.createIndex({ "trip_id": 1 }, { unique: true });
db.tickets.createIndex({ "ticket_id": 1 }, { unique: true });
db.tickets.createIndex({ "user_id": 1 });
db.payments.createIndex({ "payment_id": 1 }, { unique: true });

print('✅ Indexes created successfully!');

// Insert sample data for testing
db.routes.insertOne({
    route_id: "route_001",
    name: "City Center - Airport",
    type: "bus",
    stops: [
        { stop_id: "stop_001", name: "City Center Station", order: 1 },
        { stop_id: "stop_002", name: "Main Street", order: 2 },
        { stop_id: "stop_003", name: "Airport Terminal", order: 3 }
    ],
    active: true
});

db.routes.insertOne({
    route_id: "route_002",
    name: "North Line",
    type: "train",
    stops: [
        { stop_id: "stop_004", name: "Central Station", order: 1 },
        { stop_id: "stop_005", name: "North Park", order: 2 },
        { stop_id: "stop_006", name: "Industrial Area", order: 3 }
    ],
    active: true
});

print('✅ Sample routes inserted!');

// Insert sample trips
db.trips.insertOne({
    trip_id: "trip_001",
    route_id: "route_001",
    departure_time: new Date("2025-10-03T08:00:00Z"),
    arrival_time: new Date("2025-10-03T09:00:00Z"),
    status: "scheduled",
    vehicle_info: {
        vehicle_id: "bus_101",
        capacity: 50
    }
});

db.trips.insertOne({
    trip_id: "trip_002",
    route_id: "route_002",
    departure_time: new Date("2025-10-03T10:00:00Z"),
    arrival_time: new Date("2025-10-03T11:30:00Z"),
    status: "scheduled",
    vehicle_info: {
        vehicle_id: "train_201",
        capacity: 200
    }
});

print('✅ Sample trips inserted!');

print('🎉 Database initialization completed successfully!');
