## Setup instructions
- Flutter 3.35.3
- Run by command line:
  prod: flutter run --dart-define=ENVIRONMENT=prod

- Or config on debug configuration of android studio by adding above command line on "Addition run args" for each env

## Build apk/api with env

- Run by command line:
  iOS:
  flutter build ipa

  Android:
  flutter build appbundle
  flutter build apk

## Core Features

- **News Feed**: Display latest articles with infinite scroll pagination
- **Search**: Real-time article search with optimized API calls
- **Article Details**: Full article content or web view
- **Bookmarks**: Save articles for offline reading
- **Error Handling**: Graceful handling of network and server errors

## User Stories & Implementation Plan

### Epic 1: News Feed

#### Story 1.1: Display News Articles List

**Story Points**: 5

**As a** user  
**I want to** see a list of the latest news articles  
**So that** I can browse current news content

**Subtasks**:

1. Set up news API integration (2 hours)
   - Configure API client with base URL and authentication
   - Create data models for article response
2. Implement article repository (2 hours)
   - Create repository interface
   - Implement remote data source
3. Build article list UI (3 hours)
   - Create article card widget
   - Implement list view with loading states
4. Add error handling (1 hour)
   - Display error messages for failed requests
   - Add retry functionality

**Dependencies**: None (foundational feature)

---

#### Story 1.2: Implement Infinite Scroll Pagination

**Story Points**: 3

**As a** user  
**I want to** automatically load more articles as I scroll  
**So that** I can browse through many articles seamlessly

**Subtasks**:

1. Implement pagination logic in repository (2 hours)
   - Add page tracking
   - Handle page parameter in API calls
2. Add scroll detection to UI (1.5 hours)
   - Detect when user reaches bottom
   - Trigger next page load
3. Implement loading indicators (1 hour)
   - Show loading spinner at bottom
   - Handle end-of-list state

**Dependencies**:

- Requires Story 1.1 (Display News Articles List) to be completed first

---

### Epic 2: Search Functionality

#### Story 2.1: Implement Article Search

**Story Points**: 5

**As a** user  
**I want to** search for articles by keywords  
**So that** I can find specific topics I'm interested in

**Subtasks**:

1. Create search API endpoint integration (1.5 hours)
   - Add search method to repository
   - Handle search query parameters
2. Implement search debouncing (2 hours)
   - Add debounce mechanism to prevent excessive API calls
   - Configure optimal delay (300-500ms)
3. Build search UI (2.5 hours)
   - Add search bar to app bar
   - Display search results in list
   - Show search state (searching, results, no results)
4. Add search result caching (1.5 hours)
   - Cache recent search queries
   - Reduce redundant API calls

**Dependencies**:

- Requires Story 1.1 (Display News Articles List) for article display components

---

### Epic 3: Article Details

#### Story 3.1: Display Full Article Content

**Story Points**: 3

**As a** user  
**I want to** view the full content of an article  
**So that** I can read the complete story

**Subtasks**:

1. Create article detail screen (2 hours)
   - Design detail page layout
   - Display article title, author, date, image, content
2. Implement navigation (1 hour)
   - Add tap handler on article cards
   - Navigate to detail screen with article data
3. Add web view for external articles (2 hours)
   - Integrate webview_flutter package
   - Handle external article URLs
   - Add loading indicator for web content

**Dependencies**:

- Requires Story 1.1 (Display News Articles List) to have articles to display

---

### Epic 4: Bookmarks

#### Story 4.1: Save Articles for Later

**Story Points**: 5

**As a** user  
**I want to** bookmark articles  
**So that** I can read them later

**Subtasks**:

1. Set up local database (2.5 hours)
   - Integrate sqflite or hive package
   - Create database schema for bookmarks
2. Implement bookmark repository (2 hours)
   - Create local data source
   - Add CRUD operations for bookmarks
3. Add bookmark button to UI (1.5 hours)
   - Add bookmark icon to article cards
   - Add bookmark icon to detail screen
   - Show visual feedback for bookmarked state
4. Implement bookmark state management (2 hours)
   - Track bookmark status across app
   - Update UI when bookmark status changes

**Dependencies**:

- Requires Story 1.1 (Display News Articles List) for article data structure
- Requires Story 3.1 (Display Full Article Content) for detail screen bookmark button

---

#### Story 4.2: View Bookmarked Articles Offline

**Story Points**: 3

**As a** user  
**I want to** access my bookmarked articles without internet  
**So that** I can read saved content anywhere

**Subtasks**:

1. Create bookmarks screen (2 hours)
   - Build dedicated bookmarks tab/page
   - Display list of saved articles
2. Implement offline data retrieval (1.5 hours)
   - Load bookmarks from local database
   - Handle empty state
3. Add remove bookmark functionality (1 hour)
   - Add swipe-to-delete or delete button
   - Update local database

**Dependencies**:

- Requires Story 4.1 (Save Articles for Later) to be completed first

---

### Epic 5: Error Handling

#### Story 5.1: Handle Network Errors

**Story Points**: 3

**As a** user  
**I want to** see clear error messages when network issues occur  
**So that** I understand why content isn't loading

**Subtasks**:

1. Implement network connectivity checking (1.5 hours)
   - Integrate connectivity_plus package
   - Detect online/offline status
2. Create error state UI components (2 hours)
   - Design error message widgets
   - Add "No Internet" screen
   - Add retry buttons
3. Handle API errors gracefully (1.5 hours)
   - Catch and categorize API errors
   - Display appropriate messages for different error types
   - Log errors for debugging

**Dependencies**:

- Should be implemented after Story 1.1 (Display News Articles List)
- Can be developed in parallel with other features

---

#### Story 5.2: Handle Server Errors

**Story Points**: 2

**As a** user  
**I want to** see helpful messages when server errors occur  
**So that** I know the issue is temporary and can retry

**Subtasks**:

1. Implement server error detection (1 hour)
   - Handle 500, 503, and other server errors
   - Distinguish from client errors
2. Create server error UI (1.5 hours)
   - Display user-friendly error messages
   - Add retry mechanism
   - Show fallback content when available

**Dependencies**:

- Requires Story 5.1 (Handle Network Errors) for error handling infrastructure

---

## Summary

**Total Story Points**: 29  
**Estimated Total Time**: ~40-45 hours

### Development Sequence

1. **Phase 1 - Foundation** (Stories 1.1, 5.1): Core news feed with error handling
2. **Phase 2 - Enhanced Browsing** (Stories 1.2, 3.1): Pagination and article details
3. **Phase 3 - Search** (Story 2.1): Search functionality
4. **Phase 4 - Offline Support** (Stories 4.1, 4.2): Bookmarking and offline access
5. **Phase 5 - Polish** (Story 5.2): Complete error handling

### Critical Path Dependencies

```
Story 1.1 (News Feed)
    ├─→ Story 1.2 (Pagination)
    ├─→ Story 2.1 (Search)
    ├─→ Story 3.1 (Article Details)
    │       └─→ Story 4.1 (Bookmarks)
    │               └─→ Story 4.2 (Offline Bookmarks)
    └─→ Story 5.1 (Network Errors)
            └─→ Story 5.2 (Server Errors)
```
## Architecture && State Management
### Clean Architecture
   Core
      - constants
      - network
         + dio_client
      - theme
         + app_theme.dart
      - utils
   data <--- data layer
      - datasources
         + local_datasource
         + remote_datasource
      - models
      - repositories (implements) 
   domain <--- domain layer (business and enterprise)
      - entities
      - repositories (interfaces)
      - use cases
   presentation <--- application layer
      - blocs
      - pages
      - widgets
### Bloc
  - Using flutter_bloc library
  - Use cubit instead of bloc for simple state management
  - Use bloc for complex state management

## AI Transparency Log
### Tool & promt
 - Tools used: Claude
 - Main promt:
 1. Based on the base features, generate the necessary steps to build the application using Flutter.
    
 => Results A
 
 3. Base on Results A, build the application using the clean architecture model, specifically as follows:
 
 - Core
   - constants
   - network
     - dio_client
   - theme
     - app_theme.dart
   - utils
  - data
    - datasources
      - local_datasource
      - remote_datasource
    - models
    - repositories (implements) 
  - domain
    - entities
    - repositories (interfaces)
    - use cases
  - presentation
    - blocs
    - pages
    - widgets
  - injection_container.dart
  - main.dart

Note: use flutter_bloc for state management, ensure clean code and SOLID principles

=> Results B and then refactor to meet the requirements of the clean architecture model and UI/UX
### Lesson learned/pain point
1. **Looks correct ≠ Actually correct**

AI-generated code often looks clean and convincing, but:
  - May contain subtle logic bugs
  - Edge cases are frequently missed
  - Assumptions are hidden (e.g., null handling, concurrency)

👉 Lesson: Always treat AI code as a draft, not a solution

2. **Lack of context awareness**

AI doesn’t fully understand your:
  - Existing architecture (Clean Architecture, layered design, etc.)
  - Business rules
  - Project-specific conventions

This leads to:
  - Inconsistent patterns
  - Code that “works” but doesn’t fit your system

👉 Lesson: You must provide strong context or refactor heavily

3. **Outdated or mismatched dependencies**

AI may:
  - Use deprecated APIs
  - Suggest wrong package versions
  - Mix patterns from different framework versions

Example:
  - Old Flutter widgets
  - Incorrect NestJS decorators
  - Deprecated TypeORM methods

👉 Lesson: Verify against official docs before trusting

4. ***Over-engineering or under-engineering***

AI tends to:
  - Overcomplicate simple problems (too many abstractions)
  - Or oversimplify complex ones (missing scalability)

👉 Lesson: You still need engineering judgment

5. ***Weak error handling & edge cases***

Common gaps:
  - Missing try/catch
  - No retry logic
  - No validation for bad input
  - Poor handling of async failures

👉 Lesson: Manually harden production code

6. ***Security risks***

AI might generate code that:
  - Exposes sensitive data
  - Skips validation/sanitization
  - Uses insecure patterns

👉 Lesson: Never trust AI for security-critical logic without review

7. ***Inconsistent code style***

You may get:
  - Mixed naming conventions
  - Different patterns across files
  - Hard-to-maintain structure

👉 Lesson: Enforce linting + code review standards

8. ***Hallucinated APIs / functions***

AI sometimes invents:
  - Functions that don’t exist
  - Parameters that aren’t valid
  - Non-existent SDK features

👉 Lesson: If something feels “too perfect,” double-check it

9. ***Poor long-term maintainability***

Generated code often:
  - Lacks clear intent
  - Has minimal documentation
  - Is hard for teams to extend

👉 Lesson: Refactor AI code to match team standards

10. ***Prompt quality = output quality***

Bad prompt → bad code.

Common issues:
  - Vague requirements → wrong implementation
  - Missing constraints → wrong architecture

👉 Lesson:
You’re not just coding—you’re designing prompts

11. ***False sense of productivity***

AI can make you faster initially, but:
  - Debugging bad generated code can take longer
  - You may lose deep understanding

👉 Lesson:
Speed without control can reduce overall productivity

12. ***Testing is often missing***

AI rarely includes:
  - Unit tests
  - Integration tests
  - Edge case coverage

👉 Lesson:
Always ask for tests—or write them yourself

## Security and Offline data.
- Use Hive for local database

## Demo
- GIF: ![Alt Text](news_app_record.gif)
- Apk: ![Alt Text](app-demo.apk)
