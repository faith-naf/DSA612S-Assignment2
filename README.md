# DSA612S-Assignment2

## Project Overview
    A distributed smart public transport ticketing system for buses and trains, replacing the outdated system.

---

## Objectives
    - Design and implement microservices with clear boundaries and APIs.
    - Apply event-driven design using Kafka topics and producers/consumers.
    - Model and persist data in a database and reason about trade-offs.
    - Containerise services and orchestrate them for multi-service deployment.

---

## System Components
The system is divided into six microservices:

    - Passenger Service: Register/login, manage accounts and view tickets.
    - Transport Service: Create and manage routes/trips and publish schedule updates.
    - Ticketing Service: Handle ticket requests and lifecycle.
    - Payment Service: Simulate payments, confirm transactions via Kafka events.
    - Notification Service: Send updates when trips change or tickets are validated.
    - Admin Service: Manage routes, trips, ticket sales reports and publish service disruptions or schedule changes.

---

## Key Technologies
    - Ballerina
    - Kafka
    - MongoDB
    - Docker
