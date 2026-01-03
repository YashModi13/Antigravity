# MMS System - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT BROWSER                            │
│                    (http://localhost:4200)                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    ANGULAR 19 FRONTEND                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              ROUTING LAYER                               │   │
│  │  - Login Route                                           │   │
│  │  - Dashboard Route (Protected)                           │   │
│  │  - Gold/Silver/Diran Routes                              │   │
│  │  - Interest/Timeout Routes                               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           COMPONENT LAYER                                │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐   │   │
│  │  │   Login     │  │  Dashboard   │  │   Modules    │   │   │
│  │  │ Component   │  │  Component   │  │ (CRUD Pages) │   │   │
│  │  └─────────────┘  └──────────────┘  └──────────────┘   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           SERVICE LAYER                                  │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │   │
│  │  │ AuthService  │  │ ApiService   │  │ HttpInterc.  │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │        LOCAL STORAGE (JWT Token)                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ REST API (JSON)
                              │
┌─────────────────────────────────────────────────────────────────┐
│              SPRING BOOT BACKEND                                 │
│           (http://localhost:8080/api)                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         CONTROLLER LAYER (REST Endpoints)                │   │
│  │  - AuthController      (/auth/login)                     │   │
│  │  - GoldController      (/gold/*)                         │   │
│  │  - SilverController    (/silver/*)                       │   │
│  │  - DiranController     (/diran/*)                        │   │
│  │  - InterestController  (/interest/calculate)             │   │
│  │  - TimeoutController   (/timeout/settings)               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         SERVICE LAYER (Business Logic)                   │   │
│  │  - AuthService         (Login, JWT generation)           │   │
│  │  - GoldService         (CRUD operations)                 │   │
│  │  - SilverService       (CRUD operations)                 │   │
│  │  - DiranService        (CRUD operations)                 │   │
│  │  - InterestService     (Calculations)                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │      REPOSITORY LAYER (Data Access)                      │   │
│  │  - UserRepository      (JPA)                             │   │
│  │  - GoldRepository      (JPA)                             │   │
│  │  - SilverRepository    (JPA)                             │   │
│  │  - DiranRepository     (JPA)                             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         SECURITY LAYER                                   │   │
│  │  - JwtTokenProvider    (Token generation/validation)     │   │
│  │  - SecurityConfig      (Password encoding)               │   │
│  │  - CORS Configuration                                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ JDBC
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    PostgreSQL DATABASE                           │
│                  (localhost:5432/mms_db)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   users      │  │    gold      │  │   silver     │           │
│  │   Table      │  │    Table     │  │   Table      │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                   │
│  ┌──────────────┐                                                │
│  │    diran     │                                                │
│  │    Table     │                                                │
│  └──────────────┘                                                │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Login Flow
```
User Input (Username/Password)
         ↓
LoginComponent
         ↓
AuthService.login()
         ↓
HTTP POST /api/auth/login
         ↓
AuthController.login()
         ↓
AuthService (Backend)
         ↓
UserRepository.findByUsername()
         ↓
Database Query
         ↓
Password Validation (BCrypt)
         ↓
JwtTokenProvider.generateToken()
         ↓
LoginResponse (Token + User)
         ↓
Store Token in localStorage
         ↓
Navigate to Dashboard
```

### 2. CRUD Operation Flow
```
User Action (Add/Edit/Delete)
         ↓
Component Form
         ↓
ApiService.create/update/delete()
         ↓
HTTP Interceptor (Add JWT Token)
         ↓
HTTP POST/PUT/DELETE /api/{resource}
         ↓
Controller
         ↓
Service (Business Logic)
         ↓
Repository (JPA)
         ↓
Database Operation
         ↓
Response (JSON)
         ↓
Component Updates List
         ↓
UI Refresh
```

### 3. Interest Calculation Flow
```
User Input (Principal, Rate, Time)
         ↓
InterestComponent
         ↓
ApiService.calculateInterest()
         ↓
HTTP POST /api/interest/calculate
         ↓
InterestController
         ↓
InterestService.calculateInterest()
         ↓
Calculate Simple Interest: P × R × T / 100
         ↓
Calculate Compound Interest: P(1+R/100)^T - P
         ↓
InterestResponse (Results)
         ↓
Display Results in Component
```

## Technology Stack Details

### Frontend Stack
- **Framework**: Angular 19 (Latest)
- **Language**: TypeScript 5.6
- **Styling**: SCSS + Bootstrap 5
- **HTTP Client**: Angular HttpClient
- **State Management**: RxJS Observables
- **Routing**: Angular Router
- **Forms**: Reactive Forms (FormsModule)

### Backend Stack
- **Framework**: Spring Boot 3.1.5
- **Language**: Java 17
- **ORM**: Spring Data JPA
- **Database**: PostgreSQL 12+
- **Security**: Spring Security + JWT (JJWT)
- **Build Tool**: Maven 3.6+
- **API**: RESTful Web Services

### Database
- **Type**: PostgreSQL
- **Tables**: users, gold, silver, diran
- **Connection**: JDBC
- **Transactions**: Managed by Spring

## Security Architecture

```
┌─────────────────────────────────────────┐
│         Client Request                   │
└─────────────────────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────┐
│    CORS Filter (Validate Origin)         │
└─────────────────────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────┐
│    JWT Token Validation                  │
│    (If Authorization Header Present)     │
└─────────────────────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────┐
│    Spring Security Filter Chain          │
└─────────────────────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────┐
│    Controller Processing                 │
└─────────────────────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────┐
│    Response (JSON)                       │
└─────────────────────────────────────────┘
```

## Deployment Architecture (Production)

```
┌──────────────────────────────────────────────────────┐
│              Load Balancer / Reverse Proxy            │
│                  (Nginx / Apache)                     │
└──────────────────────────────────────────────────────┘
         │                              │
         ↓                              ↓
┌──────────────────────┐      ┌──────────────────────┐
│  Angular Frontend    │      │  Spring Boot API     │
│  (Static Files)      │      │  (Multiple Instances)│
│  Port: 80/443        │      │  Port: 8080+         │
└──────────────────────┘      └──────────────────────┘
                                       │
                                       ↓
                              ┌──────────────────────┐
                              │  PostgreSQL Database │
                              │  (Replicated)        │
                              │  Port: 5432          │
                              └──────────────────────┘
```

## Performance Considerations

1. **Frontend**
   - Lazy loading of modules
   - OnPush change detection
   - Standalone components (reduced bundle size)

2. **Backend**
   - Connection pooling
   - Query optimization with JPA
   - Caching strategies
   - Pagination for large datasets

3. **Database**
   - Indexed columns (id, username)
   - Proper data types (BigDecimal for money)
   - Regular backups

## Scalability

- **Horizontal Scaling**: Multiple backend instances behind load balancer
- **Database Scaling**: Read replicas for queries
- **Caching**: Redis for session/token caching
- **CDN**: For static frontend assets
