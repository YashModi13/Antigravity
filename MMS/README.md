# MMS System - Gold Silver Diran Business Management

Complete Angular 19 + Spring Boot application for managing Gold, Silver, and Diran business with interest calculations and timeout management.

## Project Structure

```
MMS/
├── src/                          # Angular Frontend
│   ├── app/
│   │   ├── auth/                # Authentication module
│   │   │   ├── login/           # Login component
│   │   │   ├── auth.service.ts  # Auth service
│   │   │   └── auth.guard.ts    # Route guard
│   │   ├── dashboard/           # Dashboard component
│   │   ├── modules/             # Feature modules
│   │   │   ├── gold/            # Gold CRUD
│   │   │   ├── silver/          # Silver CRUD
│   │   │   ├── silver/          # Silver CRUD
│   │   │   ├── diran/           # Diran CRUD
│   │   │   ├── deposits/        # Deposit List
│   │   │   ├── entry/           # Deposit Entry/Edit
│   │   │   ├── interest/        # Interest calculation

│   │   │   └── timeout/         # Timeout settings
│   │   ├── services/            # API services
│   │   └── app.routes.ts        # Routing config
│   ├── index.html
│   ├── main.ts
│   └── styles.scss
├── backend/                      # Spring Boot Backend
│   ├── src/main/java/com/mms/system/
│   │   ├── entity/              # JPA entities
│   │   ├── repository/          # Data repositories
│   │   ├── service/             # Business logic
│   │   ├── controller/          # REST endpoints
│   │   ├── dto/                 # Data transfer objects
│   │   ├── security/            # JWT security
│   │   ├── config/              # Configuration
│   │   └── MmsApplication.java  # Main class
│   ├── src/main/resources/
│   │   └── application.yml      # Configuration
│   └── pom.xml                  # Maven dependencies
├── package.json                 # Angular dependencies
├── tsconfig.json               # TypeScript config
└── angular.json                # Angular config
```

## Prerequisites

- Node.js 18+ and npm
- Java 17+
- Maven 3.6+
- PostgreSQL 12+

## Database Setup

1. Create PostgreSQL database:
```sql
CREATE DATABASE mms_db;
```

2. Create test user (optional):
```sql
INSERT INTO users (username, password, email, full_name) 
VALUES ('admin', '$2a$10$...', 'admin@mms.com', 'Admin User');
```

## Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Update `src/main/resources/application.yml` with your PostgreSQL credentials

3. Build and run:
```bash
mvn clean install
mvn spring-boot:run
```

Backend runs on `http://localhost:8080`

## Frontend Setup

1. Install dependencies:
```bash
npm install
```

2. Start development server:
```bash
npm start
```

Frontend runs on `http://localhost:4200`

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login user

### Gold Management
- `GET /api/gold` - Get all gold records
- `POST /api/gold` - Create gold record
- `PUT /api/gold/{id}` - Update gold record
- `DELETE /api/gold/{id}` - Delete gold record

### Silver Management
- `GET /api/silver` - Get all silver records
- `POST /api/silver` - Create silver record
- `PUT /api/silver/{id}` - Update silver record
- `DELETE /api/silver/{id}` - Delete silver record

### Diran Management
- `GET /api/diran` - Get all diran records
- `POST /api/diran` - Create diran record
- `PUT /api/diran/{id}` - Update diran record
- `DELETE /api/diran/{id}` - Delete diran record

### Deposit Management
- `GET /api/deposits` - Get all deposits
- `GET /api/deposits/{id}` - Get deposit details
- `POST /api/deposits` - Create deposit
- `PUT /api/deposits/{id}` - Update deposit


### Interest Calculation
- `POST /api/interest/calculate` - Calculate simple and compound interest

### Timeout Settings
- `GET /api/timeout/settings` - Get timeout settings
- `PUT /api/timeout/settings` - Update timeout settings

## Features

✅ User Authentication with JWT
✅ Login Page with validation
✅ Dashboard with navigation
✅ Gold CRUD operations
✅ Silver CRUD operations
✅ Diran CRUD operations
✅ Deposits Management (View, Edit)
✅ Interest Calculation (Simple & Compound)

✅ Timeout Configuration
✅ Responsive UI with Bootstrap
✅ PostgreSQL integration
✅ CORS enabled

## Default Login Credentials

Username: `admin`
Password: `admin` (after hashing with BCrypt)

## Technology Stack

**Frontend:**
- Angular 19
- TypeScript
- Bootstrap 5
- RxJS

**Backend:**
- Spring Boot 3.1.5
- Spring Data JPA
- Spring Security
- JWT (JJWT)
- PostgreSQL

## Notes

- JWT secret should be changed in production
- Update CORS origins for production
- Implement proper error handling
- Add input validation on both frontend and backend
- Use HTTPS in production
