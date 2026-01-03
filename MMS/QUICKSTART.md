# Quick Start Guide

## 1. Database Setup (PostgreSQL)

```bash
# Create database
createdb mms_db

# Connect and create users table
psql -U postgres -d mms_db

# Run in psql:
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    full_name VARCHAR(255)
);

CREATE TABLE gold (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    weight NUMERIC(10,2) NOT NULL,
    purity NUMERIC(5,2) NOT NULL,
    price NUMERIC(15,2) NOT NULL
);

CREATE TABLE silver (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    weight NUMERIC(10,2) NOT NULL,
    purity NUMERIC(5,2) NOT NULL,
    price NUMERIC(15,2) NOT NULL
);

CREATE TABLE diran (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    quantity NUMERIC(10,2) NOT NULL,
    rate NUMERIC(15,2) NOT NULL,
    amount NUMERIC(15,2) NOT NULL
);

-- Insert test user (password: admin hashed with BCrypt)
INSERT INTO users (username, password, email, full_name) 
VALUES ('admin', '$2a$10$slYQmyNdGzin7olVN3p5be4DlH.PKZbv5H8KnzzVgXXbVxzy2QIDM', 'admin@mms.com', 'Admin User');
```

## 2. Backend Setup

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

Server starts at: `http://localhost:8080`

## 3. Frontend Setup

```bash
npm install
npm start
```

App opens at: `http://localhost:4200`

## 4. Login

- Username: `admin`
- Password: `admin`

## 5. Features to Test

1. **Gold Management** - Add, Edit, Delete gold records
2. **Silver Management** - Add, Edit, Delete silver records
3. **Diran Management** - Add, Edit, Delete diran records
4. **Interest Calculator** - Calculate simple and compound interest
5. **Timeout Settings** - Configure session timeout

## Troubleshooting

### Port Already in Use
```bash
# Change backend port in application.yml
server:
  port: 8081

# Change frontend port
ng serve --port 4201
```

### Database Connection Error
- Verify PostgreSQL is running
- Check credentials in `application.yml`
- Ensure database `mms_db` exists

### CORS Error
- Verify frontend URL in `application.yml` CORS config
- Check backend is running on correct port

### JWT Token Error
- Clear browser localStorage
- Login again
- Check JWT secret in `application.yml`
