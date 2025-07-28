# lumiform-case-study

[![Swift](https://github.com/alyakan/lumiform-case-study/actions/workflows/CI.yml/badge.svg)](https://github.com/alyakan/lumiform-case-study/actions/workflows/CI.yml)

A SwiftUI iOS app that demonstrates form loading, caching, and image handling with a clean architecture approach.

## Setup

### Prerequisites
- Xcode 15.4 or later
- iOS 15.0+ deployment target

### Getting Started
1. Clone the repository
   ```bash
   git clone https://github.com/alyakan/lumiform-case-study.git
   cd lumiform-case-study
   ```

2. Open the workspace
   ```bash
   open LumiformApp.xcworkspace
   ```

3. Select the `LumiformApp` scheme and run on your preferred iOS simulator or device

That's it! No external dependencies or complex setup required.

Note: To run the unit tests, select the `Lumiform` target, a valid iOS simulator and then hit CMD + U.

## Architecture

### Project Structure

The project consists of two main targets:

#### Lumiform (Core Framework)
- **Target Type**: macOS framework (for faster TDD development)
- **Platform Support**: `macosx`, `iphoneos` and `iphonesimulator` 
- **Coverage**: 99% test coverage
- **Purpose**: Core business logic, networking, and caching

**Key Components:**
- **Form API**: Remote data loading and HTTP client
- **Form Cache**: Local storage and data persistence  
- **Form Feature**: Core domain models and use cases

#### LumiformApp (iOS App)
- **Target Type**: iOS SwiftUI app
- **Purpose**: User interface and app composition
- **Dependencies**: Links against the `Lumiform` framework

### Design Patterns

- **Clean Architecture**: Separation of concerns between UI, business logic, and data layers
- **Dependency Injection**: Framework components are composed at the app level
- **Protocol-Oriented**: Interfaces defined through protocols for testability
- **TDD Approach**: High test coverage with macOS target for faster development cycles

### Key Features

- ✅ Form loading from remote URLs
- ✅ Local caching with timestamp validation
- ✅ Image data loading and caching
- ✅ Error handling for network and storage issues
- ✅ SwiftUI interface with modern UI patterns

## For Code Reviewers

### Where to Start

**Begin with `LumiformApp.swift`** - this is where the composition happens and shows how all the pieces fit together. The app follows a clean architecture approach where:

1. **Dependency Composition**: All dependencies are wired up in the app's `init()` method
2. **Protocol-Based Design**: Each component implements protocols, making them easily testable and swappable
3. **Decorator Pattern**: The `MainQueueDispatchDecorator` ensures UI updates happen on the main thread

### Key Architectural Patterns

#### Open-Closed Principle in Action
The composition functions (`composeFormLoader` and `composeFormImageDataLoader`) demonstrate the Open-Closed Principle:

```swift
// New behaviors can be added without modifying existing code
let remoteLoaderWithCache = RemoteLoaderWithCache(remoteLoader: remoteLoader, formCacher: localLoader)
let remoteLoaderWithLocalFallback = FormLoaderWithFallback(formLoader: remoteLoaderWithCache, fallbackLoader: localLoader)
```

Each decorator adds a single responsibility:
- `RemoteLoaderWithCache`: Caches successful remote responses
- `FormLoaderWithFallback`: Provides local fallback on network failure
- `MainQueueDispatchDecorator`: Ensures main thread dispatch

#### MainQueueDispatchDecorator - Keeping App Details Separate
The `MainQueueDispatchDecorator` is crucial for maintaining clean architecture:

- **Business Logic Independence**: Core form loading logic doesn't know about UI threading
- **View Model Cleanliness**: View models receive callbacks on the main thread without knowing how
- **Testability**: Business logic can be tested without UI concerns

```swift
// Business logic runs on background thread
decoratee.load { [weak self] result in
    // UI updates guaranteed on main thread
    self?.dispatch { completion(result) }
}
```

### Navigation Guide

1. **Start**: `LumiformApp.swift` - See how everything is composed
2. **Core Logic**: `Lumiform/Form Feature/` - Domain models and protocols
3. **Network Layer**: `Lumiform/Form API/` - Remote data loading
4. **Cache Layer**: `Lumiform/Form Cache/` - Local persistence
5. **Composition**: `LumiformApp/FormLoaderCompositions.swift` - How pieces are combined
6. **UI Layer**: `LumiformApp/Form View/` - SwiftUI views and view models

### Testing Strategy

- **Unit Tests**: `LumiformTests/` - Each component tested in isolation
- **Memory Leak Detection**: `XCTestCase+MemoryLeakTracking` ensures no leaks

### Additional Design Patterns

#### Strategy Pattern - Pluggable Data Loading
The app uses the Strategy pattern to make data loading algorithms interchangeable:

```swift
// Different strategies for loading data
protocol FormLoader {
    func load(completion: @escaping (Result) -> Void)
}

// Concrete strategies
RemoteFormLoader(url: url, client: httpClient)     // Network strategy
LocalFormLoader(store: store, currentDate: Date.init) // Cache strategy
```

**Benefits:**
- Easy to swap between remote and local loading
- New strategies can be added without modifying existing code
- Each strategy encapsulates its own loading algorithm

#### MVVM Pattern - Clean UI Architecture
The app implements MVVM (Model-View-ViewModel) with SwiftUI:

```swift
// Model: Domain entities (Form, FormItem, etc.)
// View: SwiftUI views (FormView, FormItemView)
// ViewModel: FormViewModel, FormImageViewModel
```

**Key MVVM Features:**
- **Data Binding**: `@Published` properties automatically update UI
- **Separation of Concerns**: ViewModels handle business logic, Views handle presentation
- **Testability**: ViewModels can be tested independently of UI

#### Template Method Pattern - Data Validation
The `RemoteFormImageDataLoader` uses template method for validation:

```swift
init(client: HTTPClient, dataValidator: @escaping (Data) -> Bool) {
    self.client = client
    self.dataValidator = dataValidator
}
```

**Benefits:**
- Customizable validation logic
- Easy to test with different validators

#### Chain of Responsibility - Fallback Loading
The composition creates a chain of responsibility for data loading:

```swift
RemoteLoaderWithCache → FormLoaderWithFallback → MainQueueDispatchDecorator
```

**Flow:**
1. Try remote loading with caching
2. If remote fails, try local cache
3. Ensure all callbacks happen on main thread

#### Repository Pattern - Data Access Abstraction
The `FormStore` and `FormImageDataStore` protocols implement the Repository pattern:

```swift
public protocol FormStore {
    func insert(_ form: Form, timestamp: Date, completion: @escaping (InsertionResult) -> Void)
    func retrieve(completion: @escaping (RetrievalResult) -> Void)
}
```

**Benefits:**
- Abstracts data source details
- Easy to swap implementations (file system, Core Data, etc.)
- Consistent interface regardless of storage mechanism

#### Adapter Pattern - HTTP Client Abstraction
The `HTTPClient` protocol adapts different HTTP implementations:

```swift
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

// Concrete adapter
URLSessionHTTPClient(session: URLSession)
```

**Benefits:**
- Consistent interface for different HTTP libraries
- Easy to mock for testing
- Can swap URLSession with Alamofire, etc.

## Use Cases

# Load Form from Remote Use Case

## Data

- URL

## Primary course (happy path):

1. Execute "Load Form" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates `Form` object from valid data.
5. System delivers form.

## Invalid data - error course (sad path):

1. System delivers invalid data error.

## No connectivity - error course (sad path):

1. System delivers connectivity error.

# Cache Form Use Case

## Data:

- Form (or the root Form Item)

## Primary course:

1. Execute "Save Form" command with the above data.
2. System deletes old cached data.
3. System encodes the new form.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.

## Deleting error course:

1. System delivers `failedToDeleteOldCache` error.

## Saving error course:

1. System delivers `failedToSaveCache` error.

# Load Form from Cache Use Case

## Primary course:

1. Execute "Load Form" command.
2. System retrieves form data from cache.
3. System validates cache timestamp (optional).
4. System creates `Form` object from cached data.
5. System delivers form.

## Retrieval error course:

1. System delivers `retrievalError`.

## Empty cache course:

1. System delivers `notFound` error.

# Load Form Image Data from Remote Use Case

## Data:

- Image URL

## Primary course:

1. Execute "Load Image Data" command with the above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System delivers image data.

## Invalid data:

1. System delivers invalid data error.

## No connectivity:

1. System delivers connectivity error.

# Cache Image Data Use Case

## Data:

- Image Data
- URL

## Primary course:

1. Execute "Save Image Data" command with the above data.
2. System saves new data for given url, overriding existing images.
3. System delivers success message.

## Saving error course:

1. System delivers `failedToSaveCache` error.

# Load Image Data from Cache Use Case

## Data:

- URL

## Primary course:

1. Execute "Load Image Data" command.
2. System retrieves image data from cache.
3. System validates data.
4. System delivers data.

## Retrieval error course:

1. System delivers `retrievalError`.

## Empty cache course:

1. System delivers `notFound` error.