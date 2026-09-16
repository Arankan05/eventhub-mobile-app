# EventHub Backend

Simple REST API for EventHub application using Node.js, Express, and SQLite.

## Requirements

- Node.js installed

## Setup

1. Open a terminal in this directory.
2. Run `npm install` to install dependencies.
3. Run `node server.js` to start the server.

The server will run on `http://localhost:3000`.

## API Endpoints

- Auth: `/api/auth/register`, `/api/auth/login`
- Events: `/api/events` (GET, POST, PUT, DELETE)
- Bookings: `/api/bookings` (POST), `/api/bookings/user/:userId` (GET), `/api/bookings/:bookingId/cancel` (PUT)
- Organizer: `/api/events/:eventId/bookings` (GET)
