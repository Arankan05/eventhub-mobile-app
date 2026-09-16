const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs');
const cors = require('cors');
const path = require('path');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Database Initialization
const dbPath = path.resolve(__dirname, 'eventhub.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) console.error('Database connection error:', err.message);
  else {
    console.log('Connected to SQLite database.');
    db.run("PRAGMA foreign_keys = ON");
  }
});

db.serialize(() => {
  // Users Table
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user'
  )`);

  // Events Table
  db.run(`CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    organizerId INTEGER,
    name TEXT NOT NULL,
    image TEXT,
    description TEXT,
    date TEXT,
    time TEXT,
    location TEXT,
    category TEXT,
    price REAL,
    availableSeats INTEGER,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(organizerId) REFERENCES users(id)
  )`);

  // Bookings Table
  db.run(`CREATE TABLE IF NOT EXISTS bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER,
    eventId INTEGER,
    numberOfSeats INTEGER,
    totalPrice REAL,
    bookingDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'CONFIRMED',
    FOREIGN KEY(userId) REFERENCES users(id),
    FOREIGN KEY(eventId) REFERENCES events(id)
  )`);

  // Seed Events if table is empty
  db.get("SELECT COUNT(*) as count FROM events", (err, row) => {
    if (row && row.count === 0) {
      const sampleEvents = [
        [1, 'AI & Technology Workshop', 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800', 'Join us for an intensive workshop on the latest AI trends and hands-on coding sessions.', '2026-10-15', '10:00', 'Jaffna', 'Technology', 1500.0, 50],
        [1, 'Northern Music Festival', 'https://images.unsplash.com/photo-1459749411177-042180ce673c?w=800', 'Experience the soul-stirring melodies of the North at our annual music extravaganza.', '2026-11-20', '18:00', 'Jaffna', 'Music', 2000.0, 100],
        [1, 'University Sports Meet', 'https://images.unsplash.com/photo-1504450758481-7338ef7524a7?w=800', 'The biggest inter-university sports competition of the year. Come cheer for your team!', '2026-09-25', '08:00', 'Vavuniya', 'Sports', 1000.0, 80],
        [1, 'Entrepreneurship Meetup', 'https://images.unsplash.com/photo-1475721027785-f74eca99a6f2?w=800', 'Connect with fellow entrepreneurs, share ideas, and build the future of business.', '2026-12-05', '14:00', 'Jaffna', 'Business', 1200.0, 60]
      ];

      const stmt = db.prepare("INSERT INTO events (organizerId, name, image, description, date, time, location, category, price, availableSeats) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
      sampleEvents.forEach(event => stmt.run(event));
      stmt.finalize();
      console.log('Sample events seeded.');
    }
  });
});

// Auth Routes
app.post('/api/auth/register', (req, res) => {
  const { name, email, phone, password, role } = req.body;
  const hashedPassword = bcrypt.hashSync(password, 10);

  const query = `INSERT INTO users (name, email, phone, password, role) VALUES (?, ?, ?, ?, ?)`;
  db.run(query, [name, email, phone, hashedPassword, role], function(err) {
    if (err) {
      return res.status(400).json({ message: 'Email already exists or invalid data' });
    }
    res.status(201).json({ id: this.lastID, name, email, phone, role });
  });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;

  db.get(`SELECT * FROM users WHERE email = ?`, [email], (err, user) => {
    if (err || !user || !bcrypt.compareSync(password, user.password)) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    delete user.password;
    res.json({ user, token: 'fake-jwt-token' });
  });
});

// User Routes
app.get('/api/users/:id', (req, res) => {
  db.get(`SELECT id, name, email, phone, role FROM users WHERE id = ?`, [req.params.id], (err, user) => {
    if (err || !user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  });
});

app.put('/api/users/:id', (req, res) => {
  const { name, phone } = req.body;
  db.run(`UPDATE users SET name = ?, phone = ? WHERE id = ?`, [name, phone, req.params.id], function(err) {
    if (err) return res.status(400).json({ message: err.message });
    db.get(`SELECT id, name, email, phone, role FROM users WHERE id = ?`, [req.params.id], (err, user) => {
      res.json(user);
    });
  });
});

// Event Routes
app.get('/api/events', (req, res) => {
  db.all(`SELECT * FROM events ORDER BY createdAt DESC`, [], (err, rows) => {
    if (err) return res.status(500).json({ message: err.message });
    res.json(rows);
  });
});

app.get('/api/events/:id', (req, res) => {
  db.get(`SELECT * FROM events WHERE id = ?`, [req.params.id], (err, row) => {
    if (err || !row) return res.status(404).json({ message: 'Event not found' });
    res.json(row);
  });
});

app.post('/api/events', (req, res) => {
  const { organizerId, name, image, description, date, time, location, category, price, availableSeats } = req.body;
  const query = `INSERT INTO events (organizerId, name, image, description, date, time, location, category, price, availableSeats) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
  db.run(query, [organizerId, name, image, description, date, time, location, category, price, availableSeats], function(err) {
    if (err) return res.status(400).json({ message: err.message });
    res.status(201).json({ id: this.lastID, ...req.body, createdAt: new Date().toISOString() });
  });
});

app.put('/api/events/:id', (req, res) => {
  const { name, image, description, date, time, location, category, price, availableSeats } = req.body;
  const query = `UPDATE events SET name=?, image=?, description=?, date=?, time=?, location=?, category=?, price=?, availableSeats=? WHERE id=?`;
  db.run(query, [name, image, description, date, time, location, category, price, availableSeats, req.params.id], function(err) {
    if (err) return res.status(400).json({ message: err.message });
    res.json({ message: 'Event updated' });
  });
});

app.delete('/api/events/:id', (req, res) => {
  db.run(`DELETE FROM events WHERE id = ?`, [req.params.id], function(err) {
    if (err) return res.status(400).json({ message: err.message });
    res.json({ message: 'Event deleted' });
  });
});

// Booking Routes
app.post('/api/bookings', (req, res) => {
  const { userId, eventId, numberOfSeats, totalPrice } = req.body;

  db.serialize(() => {
    db.get(`SELECT availableSeats FROM events WHERE id = ?`, [eventId], (err, event) => {
      if (err || !event) return res.status(404).json({ message: 'Event not found' });
      if (event.availableSeats < numberOfSeats) return res.status(400).json({ message: 'Not enough seats available' });

      db.run(`BEGIN TRANSACTION`, (err) => {
        const query = `INSERT INTO bookings (userId, eventId, numberOfSeats, totalPrice) VALUES (?, ?, ?, ?)`;
        db.run(query, [userId, eventId, numberOfSeats, totalPrice], function(err) {
          if (err) {
            db.run(`ROLLBACK`);
            return res.status(400).json({ message: err.message });
          }

          db.run(`UPDATE events SET availableSeats = availableSeats - ? WHERE id = ?`, [numberOfSeats, eventId], (err) => {
            if (err) {
              db.run(`ROLLBACK`);
              return res.status(400).json({ message: err.message });
            }
            db.run(`COMMIT`);
            res.status(201).json({ id: this.lastID, ...req.body, bookingDate: new Date().toISOString(), status: 'CONFIRMED' });
          });
        });
      });
    });
  });
});

app.get('/api/bookings/user/:userId', (req, res) => {
  const query = `
    SELECT b.*, e.name as eventName, e.image as eventImage, e.date as eventDate
    FROM bookings b
    JOIN events e ON b.eventId = e.id
    WHERE b.userId = ?
    ORDER BY b.bookingDate DESC
  `;
  db.all(query, [req.params.userId], (err, rows) => {
    if (err) return res.status(500).json({ message: err.message });
    res.json(rows);
  });
});

app.put('/api/bookings/:bookingId/cancel', (req, res) => {
  db.get(`SELECT * FROM bookings WHERE id = ?`, [req.params.bookingId], (err, booking) => {
    if (err || !booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.status === 'CANCELLED') return res.status(400).json({ message: 'Already cancelled' });

    db.serialize(() => {
      db.run(`BEGIN TRANSACTION`);
      db.run(`UPDATE bookings SET status = 'CANCELLED' WHERE id = ?`, [req.params.bookingId], (err) => {
        if (err) {
          db.run(`ROLLBACK`);
          return res.status(400).json({ message: err.message });
        }
        db.run(`UPDATE events SET availableSeats = availableSeats + ? WHERE id = ?`, [booking.numberOfSeats, booking.eventId], (err) => {
          if (err) {
            db.run(`ROLLBACK`);
            return res.status(400).json({ message: err.message });
          }
          db.run(`COMMIT`);
          res.json({ message: 'Booking cancelled' });
        });
      });
    });
  });
});

app.get('/api/events/:eventId/bookings', (req, res) => {
  const query = `
    SELECT b.*, u.name as userName, u.email as userEmail
    FROM bookings b
    JOIN users u ON b.userId = u.id
    WHERE b.eventId = ?
  `;
  db.all(query, [req.params.eventId], (err, rows) => {
    if (err) return res.status(500).json({ message: err.message });
    res.json(rows);
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${port}`);
});
