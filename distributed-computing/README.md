# Distributed Computing

> A restaurant reservation platform built as four independent Spring Boot microservices, communicating both synchronously (OpenFeign) and asynchronously (Kafka), each owning its own PostgreSQL database.

**Grade:** 11/20 · **ECTS:** 5 · **Year:** 3 · **Institution:** Universidade Lusófona

---

## Overview

The system models the full lifecycle of a restaurant booking: a customer reserves a table, the reservation is validated against real availability, a payment is authorised, and the customer is notified. Rather than building this as one application, it is split into four services that own their own data and communicate over the network — which is the point of the exercise.

## Architecture

```
                    ┌──────────────────────┐
                    │  restaurant-service  │  :8081
                    │  restaurants, menus, │
                    │  availability slots  │
                    └──────────▲───────────┘
                               │ OpenFeign (sync)
                               │ availability / capacity
                    ┌──────────┴───────────┐
   HTTP  ─────────► │  reservation-service │  :8082
                    │  reservations, state │
                    └──────────┬───────────┘
                               │ Kafka (async)
                    ┌──────────┴───────────┐
                    ▼                      ▼
        ┌───────────────────┐   ┌──────────────────────┐
        │  payment-service  │   │ notification-service │
        │       :8084       │   │        :8083         │
        └───────────────────┘   └──────────────────────┘
```

**Database per service** — each of the four services runs its own PostgreSQL 17 instance with its own Flyway migration set. No service reads another service's tables; all cross-service data flows through APIs or events.

### Communication patterns

| Pattern | Used for | Technology |
|---|---|---|
| Synchronous | Reservation checking restaurant availability and capacity before committing | OpenFeign clients with fallbacks |
| Asynchronous | Reservation events fanning out to payment and notification | Kafka topics + `MessageEnvelope` |

Both Feign clients (`RestaurantAvailabilityClient`, `RestaurantCapacityClient`) ship with fallback implementations, so a restaurant-service outage degrades the reservation flow instead of breaking it.

Consumers are **idempotent**: `notification-service` keeps a `processed_events` table so a redelivered Kafka message is not acted on twice.

## Services

### `restaurant-service` (:8081)
Owns restaurants, menu items, and availability slots.
- `/api/restaurants` — full CRUD
- `/api/restaurants/{id}/availability` — query open slots
- `/api/restaurants/{id}/availability/release` — release held seats
- `/api/restaurants/{restaurantId}/menu` — menu CRUD, plus soft-deactivate
- `/api/restaurants/{restaurantId}/slots` — availability slot CRUD

### `reservation-service` (:8082)
Owns the reservation aggregate and its state machine.
- `POST /api/reservations` — create (calls restaurant-service first)
- `POST /api/reservations/{id}/confirm` and `/{id}/cancel` — state transitions
- Publishes reservation events to Kafka

### `notification-service` (:8083)
Consumes reservation events and records notifications.
- `GET /api/notifications` — read model only; writes are event-driven

### `payment-service` (:8084)
Authorises payment against a reservation.
- `POST /api/payments`, `GET /api/payments/reservation/{reservationId}`
- Publishes `PaymentAuthorized` events

## Tech stack

- **Java 24**, **Spring Boot 3.4.4**
- **Spring Cloud OpenFeign** — declarative sync HTTP clients with fallbacks
- **Spring Kafka** — event-driven messaging
- **PostgreSQL 17** — one instance per service
- **Flyway 11.12** — versioned schema migrations
- **Docker Compose** — per-service orchestration
- **Lombok**, DTO/mapper layers, **pgAdmin** for inspection

## Running it

Each service has its own `compose.yml` and they share an external Docker network.

```bash
# 1. Create the shared network (once)
docker network create restaurant-network

# 2. Copy the env template in each service and fill in values
cd restaurant-service && cp .env.example .env

# 3. Bring up each service (restaurant first - others depend on it)
docker compose up --build
```

Repeat steps 2–3 for `reservation-service`, `payment-service`, and `notification-service`. Flyway runs migrations automatically once each database reports healthy. pgAdmin is exposed per service (e.g. `:7782`).

> `.env` files are gitignored. Use `.env.example` as the template — the committed values are placeholders, not real credentials.

## Key takeaways

- **Distributed transactions are the hard part.** Choosing eventual consistency via events, instead of trying to span a transaction across services, is what makes the design work.
- **Sync vs async is a deliberate trade-off.** Availability checks must be synchronous (the answer gates the write); notification must not be (a slow email should never fail a booking).
- **Idempotency is not optional** in an at-least-once delivery system — hence the `processed_events` table.
- **Fallbacks turn an outage into degradation.** A Feign fallback is the difference between a partial failure and a cascading one.
