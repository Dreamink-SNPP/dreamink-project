# Dreamink Entity Relationship Diagram

This directory contains a technology-independent UML 2.5 Entity Relationship Diagram (ERD) for the Dreamink application database, created with PlantUML.

## Overview

Dreamink is a screenwriting pre-production tool that helps screenwriters organize and structure their audiovisual works. This ERD documents the complete data model, showing all entities, their attributes, relationships, and constraints in a database-agnostic format.

The diagram is designed to be independent from any specific database technology (MySQL, MariaDB, PostgreSQL, etc.) and focuses on the logical data structure.

## Diagram Files

### Entity Relationship Diagram
**Files:**
- `erd.puml` (English version)
- `erd-es.puml` (Spanish version)

Both versions contain the same data model with annotations in their respective languages.

## Data Model Overview

### Authentication & User Management

#### users
The primary authentication entity representing registered users.
- **Primary Key:** id
- **Unique Constraints:** email_address
- **Key Attributes:**
  - email_address: User's unique email for authentication
  - password_digest: Encrypted password storage
  - created_at, updated_at: Audit timestamps

#### sessions
Tracks user authentication sessions.
- **Primary Key:** id
- **Foreign Keys:** user_id → users(id)
- **Key Attributes:**
  - ip_address: Session origination IP
  - user_agent: Browser/client information
  - created_at, updated_at: Session lifecycle timestamps

### Project Management

#### projects
Central entity representing a screenplay project.
- **Primary Key:** id
- **Foreign Keys:** user_id → users(id)
- **Key Attributes:**
  - title: Project title
  - genre: Story genre classification
  - logline: One-sentence story summary
  - idea: Initial concept
  - themes: Thematic elements
  - tone: Narrative tone description
  - world: World-building details
  - storyline: Plot outline
  - short_synopsis: Brief synopsis
  - long_synopsis: Detailed synopsis
  - characters_summary: Overview of characters

#### ideas
Creative ideas bank for project development.
- **Primary Key:** id
- **Foreign Keys:** project_id → projects(id)
- **Key Attributes:**
  - title: Idea title
  - description: Detailed description
  - tags: Comma-separated categorization tags

### Dramatic Structure

The hierarchical narrative structure follows the pattern: **Project → Acts → Sequences → Scenes**

#### acts
Top-level narrative divisions (typically 3-5 acts).
- **Primary Key:** id
- **Foreign Keys:** project_id → projects(id)
- **Unique Constraints:** (project_id, position)
- **Key Attributes:**
  - title: Act title
  - description: Act summary
  - position: Order within project (enforces unique positioning)

#### sequences
Mid-level narrative groupings within acts.
- **Primary Key:** id
- **Foreign Keys:**
  - act_id → acts(id)
  - project_id → projects(id) (denormalized for query optimization)
- **Unique Constraints:** (act_id, position)
- **Key Attributes:**
  - title: Sequence title
  - description: Sequence summary
  - position: Order within act

#### scenes
Individual story units, the smallest structural element.
- **Primary Key:** id
- **Foreign Keys:**
  - sequence_id → sequences(id)
  - act_id → acts(id) (denormalized)
  - project_id → projects(id) (denormalized)
- **Unique Constraints:** (sequence_id, position)
- **Key Attributes:**
  - title: Scene title
  - description: Scene content
  - position: Order within sequence
  - color: Visual color coding
  - time_of_day: Screenplay heading time (DAY, NIGHT, MORNING, etc.)

### Character Management

#### characters
Character profiles within a project.
- **Primary Key:** id
- **Foreign Keys:** project_id → projects(id)
- **Key Attributes:**
  - name: Character name
- **Relationships:** Each character has exactly one internal traits record and one external traits record (composition relationship)

#### character_internal_traits
Psychological and internal characteristics.
- **Primary Key:** id
- **Foreign Keys:** character_id → characters(id)
- **Key Attributes:**
  - skills: Character abilities
  - religion, spirituality: Belief system
  - identity: Self-concept
  - mental_programs: Thought patterns
  - ethics: Moral framework
  - sexuality: Sexual orientation
  - main_motivation: Primary driving force
  - conversation_focus: Communication style
  - self_awareness_level: Introspection capacity
  - time_management: Temporal organization
  - artistic_inclinations: Creative interests
  - heroes_models: Role models
  - political_ideas: Political beliefs
  - authority_relationship: Attitude toward authority
  - vices: Character flaws
  - temporal_location: Time orientation
  - food_preferences: Dietary habits
  - habits: Behavioral patterns
  - peculiarities: Unique traits
  - hobbies: Leisure activities
  - charitable_activities: Altruistic engagement
  - beliefs: Core beliefs
  - friendship_relations: Social connections
  - values_priorities: Value hierarchy

#### character_external_traits
Observable and external characteristics.
- **Primary Key:** id
- **Foreign Keys:** character_id → characters(id)
- **Key Attributes:**
  - general_appearance: Overall look
  - detailed_appearance: Specific physical details
  - medical_history: Health background
  - education: Academic background
  - profession: Occupation
  - legal_situation: Legal status
  - economic_situation: Financial status
  - important_possessions: Significant belongings
  - residence_type: Living situation
  - usual_location: Typical whereabouts
  - pets: Animal companions
  - family_structure: Family composition

### Location Management

#### locations
Story world locations where scenes take place.
- **Primary Key:** id
- **Foreign Keys:** project_id → projects(id)
- **Key Attributes:**
  - name: Location name
  - description: Location details
  - location_type: Interior/Exterior classification

#### scene_locations
Join table for many-to-many relationship between scenes and locations.
- **Primary Key:** id
- **Foreign Keys:**
  - scene_id → scenes(id)
  - location_id → locations(id)
- **Purpose:** A scene can use multiple locations, and a location can appear in multiple scenes

## Relationship Types

### One-to-Many Relationships (||--o{)
- User has many Sessions
- User owns many Projects
- Project contains many Acts, Characters, Locations, Ideas
- Project references many Sequences, Scenes (denormalized)
- Act contains many Sequences
- Act references many Scenes (denormalized)
- Sequence contains many Scenes

### One-to-One Relationships (||--||)
- Character has one CharacterInternalTrait
- Character has one CharacterExternalTrait

### Many-to-Many Relationships (||--o{...o{||)
- Scene uses many Locations
- Location used in many Scenes
- **Implemented via:** scene_locations join table

## Key Design Principles

### 1. Data Denormalization
Sequences and Scenes maintain redundant foreign keys to parent entities (project_id, act_id) to optimize query performance. This allows direct querying without complex joins.

**Example:** Finding all scenes in a project doesn't require joining through sequences and acts.

### 2. Position Integrity
Unique constraints on (parent_id, position) pairs ensure:
- No duplicate positions within a container
- Ordered elements maintain consistent sequencing
- Prevents data anomalies during reordering operations

**Applied to:**
- Acts within Projects
- Sequences within Acts
- Scenes within Sequences

### 3. Composition Relationships
Characters and their traits use composition (strong ownership):
- Creating a Character automatically creates Internal and External trait records
- Deleting a Character cascades to delete both trait records
- One-to-one cardinality ensures data consistency

### 4. Cascade Deletions
Foreign key constraints with cascade delete ensure referential integrity:
- Deleting a User removes all their Projects and Sessions
- Deleting a Project removes all Acts, Sequences, Scenes, Characters, Locations, and Ideas
- Deleting an Act removes all Sequences and Scenes within it
- Deleting a Sequence removes all its Scenes
- Deleting a Character removes both trait records

### 5. Technology Independence
The ERD uses generic data types:
- `bigint` for IDs (auto-incrementing primary keys)
- `varchar(n)` for short strings
- `text` for long-form content
- `timestamp` for date/time values
- `integer` for numeric values

These map to appropriate types in any relational database system.

## Data Constraints

### Unique Constraints
1. **users.email_address** - One account per email
2. **(acts.project_id, acts.position)** - Unique act ordering per project
3. **(sequences.act_id, sequences.position)** - Unique sequence ordering per act
4. **(scenes.sequence_id, scenes.position)** - Unique scene ordering per sequence

### Not Null Constraints
All entities require:
- Primary key (id)
- Foreign keys to parent entities
- Audit timestamps (created_at, updated_at)

### Foreign Key Constraints
All foreign keys enforce referential integrity with appropriate cascade behavior.

## UML 2.5 Notation

### Entity Representation
```
entity "table_name" as alias {
  * required_field : data_type <<constraint>>
  optional_field : data_type
  --
  note or constraint
}
```

### Symbols
- `*` - Required field (NOT NULL)
- `<<PK>>` - Primary Key
- `<<FK>>` - Foreign Key
- `<<UNIQUE>>` - Unique constraint

### Relationship Notation
- `||--o{` - One to Many (one required, many optional)
- `||--||` - One to One (both required)
- `}o--o{` - Many to Many (via join table)

### Cardinality
- `||` - Exactly one (required)
- `o|` - Zero or one (optional)
- `o{` - Zero or many
- `|{` - One or many

## Viewing the Diagram

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
plantuml erd.puml

# Generate SVG (recommended for scalability)
plantuml -tsvg erd.puml

# Generate both English and Spanish versions
plantuml erd*.puml
```

## Implementation Notes

### Current Implementation
Dreamink is built with:
- **Framework:** Ruby on Rails 8.1
- **Database:** PostgreSQL (with pg_catalog.plpgsql extension)
- **ORM:** ActiveRecord

### Database-Specific Features
While the ERD is technology-independent, the actual implementation uses:
- PostgreSQL's `bigserial` for auto-incrementing bigint primary keys
- `text` type for unlimited-length strings
- `timestamp without time zone` for temporal data
- Indexes on foreign keys and unique constraints for performance

### Migration Strategy
The schema evolves through Rails migrations in `/db/migrate/`, ensuring version-controlled, reproducible database changes across environments.

## Data Flow Examples

### Creating a New Scene
1. User selects a sequence within an act
2. System determines next position in sequence
3. Creates scene record with:
   - sequence_id (parent)
   - act_id (denormalized from sequence)
   - project_id (denormalized from sequence)
   - position (calculated)
4. Enforces unique constraint on (sequence_id, position)

### Moving a Sequence to Another Act
1. Validates target act exists in same project
2. Updates sequence.act_id
3. Recalculates sequence.position in target act
4. **Cascade update:** Updates all child scenes' act_id
5. Maintains scene.sequence_id (unchanged)
6. Reorders positions in both source and target acts

### Deleting a Character
1. Validates user owns the project
2. **Cascade delete:** Removes character_internal_traits record
3. **Cascade delete:** Removes character_external_traits record
4. Removes character record
5. Transaction ensures atomicity (all or nothing)

## Contributing

When modifying the data model:
1. Update the ERD diagram(s) to reflect changes
2. Follow UML 2.5 notation standards
3. Maintain technology independence
4. Update both English and Spanish versions
5. Document new constraints or relationships
6. Update this README with structural changes

## References

- **UML 2.5 Specification:** https://www.omg.org/spec/UML/2.5/
- **PlantUML Documentation:** https://plantuml.com/ie-diagram
- **Database Design Patterns:** https://www.postgresql.org/docs/current/ddl.html
- **Rails Schema Documentation:** https://guides.rubyonrails.org/active_record_migrations.html

## Related Documentation

- **Class Diagram:** `class-diagram.puml` - Object-oriented view of the domain model
- **Use Case Diagrams:** `use-case-*.puml` - Functional requirements and user interactions
- **Database Schema:** `/db/schema.rb` - Actual Rails implementation

---

**Last Updated:** 2025-11-07
**UML Version:** UML 2.5
**PlantUML Version:** Latest
**Database-Agnostic:** Yes (MySQL, MariaDB, PostgreSQL compatible)
