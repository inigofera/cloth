# cloth - Scalable Architecture

This document outlines the scalable layered architecture implemented for cloth.

## Architecture Overview

The project follows a **Clean Architecture** pattern with clear separation of concerns and dependency inversion principles. This design ensures:

- **Testability**: Each layer can be tested independently
- **Maintainability**: Clear boundaries between layers
- **Scalability**: Easy to swap implementations or add new features
- **Flexibility**: Future cloud sync, analytics, and other features can be added seamlessly

## Layer Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   UI Widgets    │  │   State Mgmt    │  │  Providers  │  │
│  │   (Flutter)     │  │  (Riverpod)     │  │ (Riverpod)  │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   Use Cases     │  │  Validation     │  │  Business   │  │
│  │  (Interactors)  │  │   Rules         │  │   Logic     │  │ 
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │  Repositories   │  │   Data Models   │  │   Storage   │  │
│  │  (Interfaces)   │  │    (Hive)       │  │  (Hive)     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │    Entities     │  │   Value Objects │  │  Interfaces │  │
│  │  (Core Models)  │  │   (Enums)       │  │ (Contracts) │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Layer Details

### 1. Domain Layer (`lib/domain/`)

**Purpose**: Contains business entities and core business rules.

**Components**:
- **Entities**: `ClothingItem`, `Outfit` - Core business objects
- **Repositories**: Abstract interfaces defining data contracts
- **Value Objects**: Enums and constants used throughout the project

**Key Features**:
- Pure Dart classes with no external dependencies
- Immutable data structures using `equatable`
- Business logic validation methods
- Soft deletion support for data integrity

### 2. Data Layer (`lib/data/`)

**Purpose**: Implements data persistence and external data sources.

**Components**:
- **Models**: Hive-annotated classes for local storage
- **Repositories**: Concrete implementations of domain interfaces
- **Data Sources**: Hive boxes and future cloud APIs

**Key Features**:
- Hive for fast local storage
- Cloud sync preparation (cloudId, lastSyncedAt fields)
- Data transformation between domain and storage models
- Efficient querying and indexing

### 3. Business Logic Layer (`lib/domain/usecases/`)

**Purpose**: Orchestrates business operations and enforces business rules.

**Components**:
- **Use Cases**: Single-responsibility business operations
- **Validation**: Business rule enforcement
- **Coordination**: Complex operations involving multiple entities

**Key Features**:
- Input validation and sanitization
- Business rule enforcement
- Error handling and meaningful error messages
- Transaction-like operations for data consistency

### 4. Presentation Layer (`lib/presentation/`)

**Purpose**: Handles UI, state management, and user interactions.

**Components**:
- **Widgets**: Flutter UI components
- **Providers**: Riverpod state management
- **Screens**: Complete screens and navigation

**Key Features**:
- Riverpod for reactive state management
- Clean separation between UI and business logic
- Responsive design with Material 3
- Error handling and loading states

## Dependency Injection

**Purpose**: Manages dependencies and allows easy swapping of implementations.

**Implementation**: Uses `get_it` for service location.

**Benefits**:
- Easy testing with mock implementations
- Runtime configuration changes
- Lazy initialization of services
- Clean dependency graph

## Testing Strategy

### Unit Testing
- **Domain Layer**: Test entities and business rules
- **Use Cases**: Test business logic and validation
- **Repositories**: Test data operations with mocks

### Integration Testing
- **Data Layer**: Test Hive storage operations
- **Provider Integration**: Test Riverpod state management
- **End-to-End**: Test complete user workflows

### Mock Implementations
```dart
class MockClothingItemRepository implements ClothingItemRepository {
  // Implement methods for testing
}
```

## Performance Considerations

### Local Storage
- Hive provides fast key-value storage
- Efficient indexing for common queries
- Lazy loading for large datasets

### State Management
- Riverpod's automatic disposal prevents memory leaks
- Selective rebuilding for optimal performance
- Async state handling for smooth UX

### Data Loading
- Pagination for large lists
- Caching strategies for frequently accessed data
- Background sync for cloud operations

## Migration Paths

### From Local to Cloud
1. Implement cloud repositories alongside local ones
2. Add sync service for gradual migration
3. Implement conflict resolution
4. Add user preference for storage choice

### From Hive to SQLite
1. Create SQLite repository implementations
2. Add data migration service
3. Implement gradual migration
4. Maintain backward compatibility

### From Riverpod to Bloc
1. Create Bloc implementations
2. Add adapter layer for gradual migration
3. Implement feature flags
4. A/B test performance differences

## Best Practices

### Code Organization
- Keep layers loosely coupled
- Use interfaces for dependency inversion
- Implement single responsibility principle
- Follow consistent naming conventions

### Error Handling
- Use meaningful error messages
- Implement proper error boundaries
- Log errors for debugging
- Provide user-friendly error states

### Performance
- Profile and optimize bottlenecks
- Implement efficient data structures
- Use appropriate caching strategies
- Monitor memory usage

### Security
- Validate all inputs
- Sanitize data before storage
- Implement proper authentication
- Secure sensitive data
