# MMS System - Development Guide

## Development Environment Setup

### Prerequisites
- Node.js 18+ (https://nodejs.org/)
- Java 17+ (https://www.oracle.com/java/technologies/downloads/)
- Maven 3.6+ (https://maven.apache.org/)
- PostgreSQL 12+ (https://www.postgresql.org/)
- Git (https://git-scm.com/)
- IDE: VS Code or IntelliJ IDEA

### IDE Setup

#### VS Code
1. Install extensions:
   - Angular Language Service
   - Prettier - Code formatter
   - ESLint
   - Thunder Client (for API testing)

2. Settings (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

#### IntelliJ IDEA
1. Install plugins:
   - Angular
   - Spring Boot
   - Database Tools
   - Lombok

2. Configure:
   - Project SDK: Java 17
   - Node interpreter: Node 18+

---

## Frontend Development

### Project Structure
```
src/
├── app/
│   ├── auth/              # Authentication module
│   ├── dashboard/         # Main dashboard
│   ├── modules/           # Feature modules
│   ├── services/          # Shared services
│   ├── app.routes.ts      # Routing
│   └── app.component.ts   # Root component
├── main.ts                # Bootstrap
├── index.html             # HTML template
└── styles.scss            # Global styles
```

### Development Commands

```bash
# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm build

# Run tests
npm test

# Lint code
npm run lint
```

### Adding New Component

```bash
# Generate component
ng generate component modules/new-feature

# This creates:
# - new-feature.component.ts
# - new-feature.component.html
# - new-feature.component.scss
# - new-feature.component.spec.ts
```

### Adding New Service

```bash
# Generate service
ng generate service services/new-service

# This creates:
# - new-service.service.ts
# - new-service.service.spec.ts
```

### Component Template Example

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-example',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="container">
      <h2>Example Component</h2>
      <!-- Template here -->
    </div>
  `,
  styles: [`
    .container {
      padding: 20px;
    }
  `]
})
export class ExampleComponent implements OnInit {
  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    // Initialize component
  }
}
```

### Styling Guidelines

- Use SCSS for component styles
- Use Bootstrap classes for layout
- Follow BEM naming convention
- Keep component styles scoped

```scss
// Component styles
.container {
  padding: 20px;
  background: white;
  border-radius: 8px;

  &__header {
    font-size: 24px;
    margin-bottom: 20px;
  }

  &__content {
    display: grid;
    gap: 15px;
  }
}
```

### Form Handling

```typescript
// Using FormsModule (Two-way binding)
form = {
  name: '',
  email: '',
  phone: ''
};

onSubmit(): void {
  if (this.validateForm()) {
    this.apiService.create(this.form).subscribe({
      next: (response) => {
        console.log('Success', response);
        this.resetForm();
      },
      error: (error) => {
        console.error('Error', error);
      }
    });
  }
}

validateForm(): boolean {
  return this.form.name && this.form.email && this.form.phone;
}

resetForm(): void {
  this.form = { name: '', email: '', phone: '' };
}
```

### HTTP Requests

```typescript
// GET request
this.apiService.getGoldList().subscribe({
  next: (data) => this.goldList = data,
  error: (err) => console.error(err)
});

// POST request
this.apiService.createGold(data).subscribe({
  next: (response) => console.log('Created', response),
  error: (err) => console.error(err)
});

// PUT request
this.apiService.updateGold(id, data).subscribe({
  next: (response) => console.log('Updated', response),
  error: (err) => console.error(err)
});

// DELETE request
this.apiService.deleteGold(id).subscribe({
  next: () => console.log('Deleted'),
  error: (err) => console.error(err)
});
```

### Debugging

```typescript
// Console logging
console.log('Value:', value);
console.error('Error:', error);
console.warn('Warning:', warning);

// Browser DevTools
// F12 -> Sources tab -> Set breakpoints
// F12 -> Console tab -> Inspect variables

// Angular DevTools
// Install Angular DevTools extension
// F12 -> Angular tab -> Inspect components
```

---

## Backend Development

### Project Structure
```
backend/
├── src/main/java/com/mms/system/
│   ├── entity/            # JPA entities
│   ├── repository/        # Data repositories
│   ├── service/           # Business logic
│   ├── controller/        # REST endpoints
│   ├── dto/               # Data transfer objects
│   ├── security/          # Security components
│   ├── config/            # Configuration
│   └── MmsApplication.java
├── src/main/resources/
│   └── application.yml
└── pom.xml
```

### Development Commands

```bash
# Build project
mvn clean install

# Run application
mvn spring-boot:run

# Run tests
mvn test

# Package application
mvn package

# Skip tests during build
mvn clean install -DskipTests
```

### Adding New Entity

```java
package com.mms.system.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "example")
public class Example {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    // Constructors, getters, setters
}
```

### Adding New Repository

```java
package com.mms.system.repository;

import com.mms.system.entity.Example;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExampleRepository extends JpaRepository<Example, Long> {
    // Custom queries if needed
}
```

### Adding New Service

```java
package com.mms.system.service;

import com.mms.system.entity.Example;
import com.mms.system.repository.ExampleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ExampleService {
    @Autowired
    private ExampleRepository exampleRepository;

    public List<Example> getAll() {
        return exampleRepository.findAll();
    }

    public Example getById(Long id) {
        return exampleRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Not found"));
    }

    public Example create(Example example) {
        return exampleRepository.save(example);
    }

    public Example update(Long id, Example example) {
        Example existing = getById(id);
        // Update fields
        return exampleRepository.save(existing);
    }

    public void delete(Long id) {
        exampleRepository.deleteById(id);
    }
}
```

### Adding New Controller

```java
package com.mms.system.controller;

import com.mms.system.entity.Example;
import com.mms.system.service.ExampleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/example")
@CrossOrigin(origins = "http://localhost:4200")
public class ExampleController {
    @Autowired
    private ExampleService exampleService;

    @GetMapping
    public ResponseEntity<List<Example>> getAll() {
        return ResponseEntity.ok(exampleService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Example> getById(@PathVariable Long id) {
        return ResponseEntity.ok(exampleService.getById(id));
    }

    @PostMapping
    public ResponseEntity<Example> create(@RequestBody Example example) {
        return ResponseEntity.ok(exampleService.create(example));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Example> update(@PathVariable Long id, @RequestBody Example example) {
        return ResponseEntity.ok(exampleService.update(id, example));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        exampleService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

### Exception Handling

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorResponse> handleRuntimeException(RuntimeException ex) {
        ErrorResponse error = new ErrorResponse("Error", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception ex) {
        ErrorResponse error = new ErrorResponse("Error", "Internal server error");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
```

### Logging

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class ExampleService {
    private static final Logger logger = LoggerFactory.getLogger(ExampleService.class);

    public void example() {
        logger.info("Info message");
        logger.warn("Warning message");
        logger.error("Error message");
        logger.debug("Debug message");
    }
}
```

### Debugging

```bash
# Enable debug logging in application.yml
logging:
  level:
    root: INFO
    com.mms.system: DEBUG

# Use IDE debugger
# Set breakpoints in code
# Run: mvn spring-boot:run
# Debug mode will pause at breakpoints
```

---

## Database Development

### Creating Tables

```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    full_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Gold table
CREATE TABLE gold (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    weight NUMERIC(10,2) NOT NULL,
    purity NUMERIC(5,2) NOT NULL,
    price NUMERIC(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Querying Data

```sql
-- Select all
SELECT * FROM gold;

-- Select with conditions
SELECT * FROM gold WHERE purity > 99;

-- Count records
SELECT COUNT(*) FROM gold;

-- Update records
UPDATE gold SET price = 65000 WHERE id = 1;

-- Delete records
DELETE FROM gold WHERE id = 1;
```

### Indexes

```sql
-- Create index for faster queries
CREATE INDEX idx_username ON users(username);
CREATE INDEX idx_gold_purity ON gold(purity);
```

---

## Testing

### Frontend Testing

```typescript
// Example test
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ExampleComponent } from './example.component';

describe('ExampleComponent', () => {
  let component: ExampleComponent;
  let fixture: ComponentFixture<ExampleComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ExampleComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(ExampleComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
```

### Backend Testing

```java
@SpringBootTest
public class ExampleServiceTest {
    @Autowired
    private ExampleService exampleService;

    @Test
    public void testGetAll() {
        List<Example> examples = exampleService.getAll();
        assertNotNull(examples);
    }
}
```

---

## Version Control

### Git Workflow

```bash
# Clone repository
git clone <repository-url>

# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to remote
git push origin feature/new-feature

# Create pull request
# Review and merge
```

### Commit Message Convention

```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor code
test: Add tests
chore: Update dependencies
```

---

## Performance Optimization

### Frontend
- Lazy load modules
- Use OnPush change detection
- Optimize images
- Minify CSS/JS

### Backend
- Add database indexes
- Use pagination
- Cache frequently accessed data
- Optimize queries

---

## Security Best Practices

### Frontend
- Sanitize user input
- Use HTTPS
- Store sensitive data securely
- Validate on client and server

### Backend
- Validate all inputs
- Use parameterized queries
- Implement rate limiting
- Use HTTPS
- Keep dependencies updated

---

## Deployment

### Frontend Deployment
```bash
# Build for production
npm run build

# Deploy dist folder to web server
# Configure web server for SPA routing
```

### Backend Deployment
```bash
# Build JAR
mvn clean package

# Run JAR
java -jar target/mms-system-1.0.0.jar
```

---

## Troubleshooting

### Common Issues

**Port Already in Use**
```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>
```

**Database Connection Error**
- Check PostgreSQL is running
- Verify credentials in application.yml
- Check database exists

**CORS Error**
- Verify frontend URL in backend CORS config
- Check backend is running

**JWT Token Error**
- Clear localStorage
- Login again
- Check JWT secret

---

## Resources

- Angular Documentation: https://angular.io/docs
- Spring Boot Documentation: https://spring.io/projects/spring-boot
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- JWT Documentation: https://jwt.io/
- Bootstrap Documentation: https://getbootstrap.com/docs/

---

## Support

For issues or questions:
1. Check documentation files
2. Review error messages
3. Check browser/IDE console
4. Review backend logs
5. Check database logs
