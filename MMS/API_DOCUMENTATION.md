# MMS System - API Documentation

## Base URL
```
http://localhost:8080/api
```

## Authentication
All endpoints (except login) require JWT token in Authorization header:
```
Authorization: Bearer <token>
```

---

## Authentication Endpoints

### Login
**POST** `/auth/login`

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@mms.com",
    "fullName": "Admin User"
  }
}
```

**Error Response (401):**
```json
{
  "message": "Invalid password"
}
```

---

## Gold Management Endpoints

### Get All Gold Records
**GET** `/gold`

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Gold Bar 1",
    "weight": 100.50,
    "purity": 99.99,
    "price": 65000.00
  },
  {
    "id": 2,
    "name": "Gold Bar 2",
    "weight": 50.25,
    "purity": 99.99,
    "price": 32500.00
  }
]
```

### Get Gold Record by ID
**GET** `/gold/{id}`

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Gold Bar 1",
  "weight": 100.50,
  "purity": 99.99,
  "price": 65000.00
}
```

### Create Gold Record
**POST** `/gold`

**Request Body:**
```json
{
  "name": "Gold Bar 3",
  "weight": 75.00,
  "purity": 99.99,
  "price": 48750.00
}
```

**Response (200 OK):**
```json
{
  "id": 3,
  "name": "Gold Bar 3",
  "weight": 75.00,
  "purity": 99.99,
  "price": 48750.00
}
```

### Update Gold Record
**PUT** `/gold/{id}`

**Request Body:**
```json
{
  "name": "Gold Bar 3 Updated",
  "weight": 80.00,
  "purity": 99.99,
  "price": 52000.00
}
```

**Response (200 OK):**
```json
{
  "id": 3,
  "name": "Gold Bar 3 Updated",
  "weight": 80.00,
  "purity": 99.99,
  "price": 52000.00
}
```

### Delete Gold Record
**DELETE** `/gold/{id}`

**Response (204 No Content)**

---

## Silver Management Endpoints

### Get All Silver Records
**GET** `/silver`

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Silver Bar 1",
    "weight": 500.00,
    "purity": 99.99,
    "price": 35000.00
  }
]
```

### Create Silver Record
**POST** `/silver`

**Request Body:**
```json
{
  "name": "Silver Bar 2",
  "weight": 250.00,
  "purity": 99.99,
  "price": 17500.00
}
```

### Update Silver Record
**PUT** `/silver/{id}`

**Request Body:**
```json
{
  "name": "Silver Bar 2 Updated",
  "weight": 300.00,
  "purity": 99.99,
  "price": 21000.00
}
```

### Delete Silver Record
**DELETE** `/silver/{id}`

---

## Diran Management Endpoints

### Get All Diran Records
**GET** `/diran`

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Diran Item 1",
    "quantity": 100.00,
    "rate": 500.00,
    "amount": 50000.00
  }
]
```

### Create Diran Record
**POST** `/diran`

**Request Body:**
```json
{
  "name": "Diran Item 2",
  "quantity": 50.00,
  "rate": 600.00,
  "amount": 30000.00
}
```

### Update Diran Record
**PUT** `/diran/{id}`

**Request Body:**
```json
{
  "name": "Diran Item 2 Updated",
  "quantity": 75.00,
  "rate": 600.00,
  "amount": 45000.00
}
```

### Delete Diran Record
**DELETE** `/diran/{id}`

---

## Interest Calculation Endpoints

### Calculate Interest
**POST** `/interest/calculate`

**Request Body:**
```json
{
  "principal": 100000,
  "rate": 8.5,
  "time": 5
}
```

**Response (200 OK):**
```json
{
  "simpleInterest": 42500.00,
  "compoundInterest": 50363.71,
  "totalAmount": 150363.71
}
```

**Calculation Details:**
- Simple Interest = Principal × Rate × Time / 100
- Compound Interest = Principal × (1 + Rate/100)^Time - Principal
- Total Amount = Principal + Compound Interest

---

## Timeout Settings Endpoints

### Get Timeout Settings
**GET** `/timeout/settings`

**Response (200 OK):**
```json
{
  "sessionTimeout": 30,
  "idleTimeout": 15,
  "warningTime": 60,
  "enableAutoLogout": true
}
```

### Update Timeout Settings
**PUT** `/timeout/settings`

**Request Body:**
```json
{
  "sessionTimeout": 45,
  "idleTimeout": 20,
  "warningTime": 120,
  "enableAutoLogout": true
}
```

**Response (200 OK):**
```json
{
  "sessionTimeout": 45,
  "idleTimeout": 20,
  "warningTime": 120,
  "enableAutoLogout": true
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "message": "Invalid input data"
}
```

### 401 Unauthorized
```json
{
  "message": "Invalid or expired token"
}
```

### 403 Forbidden
```json
{
  "message": "Access denied"
}
```

### 404 Not Found
```json
{
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "message": "Internal server error"
}
```

---

## Request/Response Headers

### Request Headers
```
Content-Type: application/json
Authorization: Bearer <jwt_token>
```

### Response Headers
```
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:4200
```

---

## Data Types

| Type | Format | Example |
|------|--------|---------|
| String | Text | "Gold Bar 1" |
| Number | Integer/Decimal | 100, 99.99 |
| BigDecimal | Decimal (2 places) | 65000.00 |
| Boolean | true/false | true |
| Long | Integer | 1, 2, 3 |

---

## Pagination (Future Enhancement)

For large datasets, add pagination:
```
GET /gold?page=0&size=10&sort=id,desc
```

---

## Rate Limiting (Future Enhancement)

Implement rate limiting:
- 100 requests per minute per IP
- 1000 requests per hour per user

---

## CORS Configuration

**Allowed Origins:**
- http://localhost:4200 (Development)
- https://yourdomain.com (Production)

**Allowed Methods:**
- GET, POST, PUT, DELETE, OPTIONS

**Allowed Headers:**
- Content-Type
- Authorization

---

## Testing with cURL

### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```

### Get All Gold
```bash
curl -X GET http://localhost:8080/api/gold \
  -H "Authorization: Bearer <token>"
```

### Create Gold
```bash
curl -X POST http://localhost:8080/api/gold \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "name":"Gold Bar",
    "weight":100.50,
    "purity":99.99,
    "price":65000.00
  }'
```

### Calculate Interest
```bash
curl -X POST http://localhost:8080/api/interest/calculate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "principal":100000,
    "rate":8.5,
    "time":5
  }'
```

---

## Testing with Postman

1. Import collection from API documentation
2. Set environment variable: `token` = JWT token from login
3. Use `{{token}}` in Authorization header
4. Test each endpoint

---

## API Versioning (Future)

For future versions, use:
```
/api/v1/gold
/api/v2/gold
```

---

## Webhook Support (Future)

Implement webhooks for:
- Record creation
- Record updates
- Record deletion
- Interest calculations

---

## GraphQL Support (Future)

Consider GraphQL for:
- Flexible queries
- Reduced over-fetching
- Better performance
