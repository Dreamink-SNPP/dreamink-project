# Dreamink Use Case Diagrams

This directory contains UML 2.5 use case diagrams for the Dreamink application, created with PlantUML.

## Overview

Dreamink is a screenwriting pre-production tool that helps screenwriters organize and structure their audiovisual works before writing the literary screenplay. These diagrams document the system's functional requirements and user interactions.

## Diagrams

### 1. General Overview
**File:** `use-case-overview.puml`

High-level view of all major functional areas of the Dreamink system:
- Account Management
- Project Management
- Dramatic Structure
- Character Management
- Location Management
- Ideas Management

This diagram provides a bird's-eye view of the complete system and shows all primary use cases organized by functional domain.

### 2. Authentication and Account Management
**File:** `use-case-authentication.puml`

Covers user authentication and account-related operations:
- User registration
- Login/logout
- Password reset
- Session management
- Credential validation

Includes interactions with external email system for password recovery.

### 3. Project Management
**File:** `use-case-projects.puml`

Documents project-level operations:
- Creating and managing screenplay projects
- Editing treatment metadata (title, genre, logline, synopsis, themes, etc.)
- Viewing project details
- Deleting projects
- Exporting to PDF reports
- Exporting to Fountain screenplay format

All operations include authorization checks to ensure users can only access their own projects.

### 4. Dramatic Structure Management
**File:** `use-case-structure.puml`

The most complex subsystem, managing the hierarchical narrative structure:
- **Acts:** Top-level narrative divisions
- **Sequences:** Mid-level groupings within acts
- **Scenes:** Individual story units within sequences

Features include:
- Creating, editing, deleting elements at all levels
- Reordering elements via drag-and-drop
- Moving sequences between acts (with automatic child scene updates)
- Moving scenes between sequences
- Assigning locations to scenes
- Setting time of day and color coding for scenes
- Filtering scenes by location
- Automatic statistics calculation

### 5. Character Management
**File:** `use-case-characters.puml`

Character development and documentation:
- Creating character profiles
- Managing Internal Traits (psychology, beliefs, motivations, relationships, habits)
- Managing External Traits (appearance, family, education, profession, economic status)
- Viewing character lists
- Deleting characters
- Generating individual character PDF reports
- Generating collective character reports

Characters have unique names within each project and automatically get initialized internal/external trait records.

### 6. Location Management
**File:** `use-case-locations.puml`

Managing story world locations:
- Creating locations (Interior/Exterior)
- Editing location details
- Viewing locations list with type filtering
- Deleting locations
- Viewing all scenes associated with a location
- Generating individual location PDF reports
- Generating collective location reports

Locations are linked to scenes through the Scene Management subsystem.

### 7. Ideas Management
**File:** `use-case-ideas.puml`

Creative ideas bank for project development:
- Creating ideas with title, description, and tags
- Editing ideas
- Viewing ideas list (sorted by date)
- Deleting ideas
- Searching ideas by keyword
- Filtering ideas by tags
- Generating individual idea PDF reports
- Generating collective idea reports

Tags are comma-separated and provide flexible categorization.

## UML 2.5 Notation

These diagrams follow UML 2.5 standards:

### Elements
- **Actors:** Stick figures representing external entities (primarily "Screenwriter")
- **Use Cases:** Ovals representing system functionalities
- **System Boundary:** Rectangle containing all use cases
- **Packages:** Grouped related use cases for better organization

### Relationships
- **Association:** Solid line connecting actor to use case (primary interaction)
- **Include:** Dashed arrow with `<<include>>` stereotype (mandatory behavior that's always part of the base use case)
- **Extend:** Dashed arrow with `<<extend>>` stereotype (optional behavior that may occur)
- **Generalization:** Solid line with hollow arrowhead (inheritance/specialization)

### Example Interpretations
- `UC1 .> UC2 : <<include>>` means UC1 always includes the behavior of UC2
- `UC1 <. UC2 : <<extend>>` means UC2 optionally extends UC1 under certain conditions
- `Actor --> UseCase` means the actor initiates or participates in the use case

## Viewing the Diagrams

### Online Viewers
1. **PlantUML Server:** http://www.plantuml.com/plantuml/uml/
   - Copy and paste the diagram code
   - View rendered diagram instantly

2. **VS Code:** Install "PlantUML" extension
   - Open `.puml` files
   - Use `Alt+D` to preview

3. **IntelliJ IDEA:** Built-in PlantUML support
   - Open `.puml` files for inline preview

### Generating Images

Using PlantUML command-line:
```bash
# Install PlantUML
# On macOS: brew install plantuml
# On Ubuntu: apt-get install plantuml

# Generate PNG
plantuml use-case-overview.puml

# Generate SVG (recommended for scalability)
plantuml -tsvg use-case-overview.puml

# Generate all diagrams
plantuml *.puml
```

## System Architecture Notes

### Primary Actor
**Screenwriter** - The sole user type who owns and manages projects. All data is scoped to the authenticated user.

### Key Design Principles
1. **Authorization:** Every project operation validates user ownership
2. **Hierarchical Structure:** Acts → Sequences → Scenes maintain parent-child relationships
3. **Data Integrity:**
   - Unique constraints on character and location names within projects
   - Cascade deletions (deleting an act removes all sequences and scenes)
   - Reference updates (moving a sequence updates all child scenes)
4. **Statistics:** Automatic calculation of element counts at all hierarchy levels

### Data Flow Example
When a screenwriter moves a sequence to a different act:
1. System validates the move
2. Updates the sequence's act reference
3. Updates all child scenes' act references
4. Recalculates positions for both source and target acts
5. Updates statistics for affected acts
6. Refreshes the UI

## Contributing

When adding new features to Dreamink:
1. Update the relevant use case diagram(s)
2. Follow UML 2.5 notation standards
3. Add notes to clarify complex behaviors
4. Update this README with new diagram descriptions

## References

- **UML 2.5 Specification:** https://www.omg.org/spec/UML/2.5/
- **PlantUML Documentation:** https://plantuml.com/use-case-diagram
- **Fountain Format:** https://fountain.io/

---

**Last Updated:** 2025-11-07
**UML Version:** UML 2.5
**PlantUML Version:** Latest
