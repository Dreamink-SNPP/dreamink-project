# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dreamink is a web application for screenwriters to organize and structure audiovisual works before writing the literary script. It manages dramatic structure using a three-tier hierarchy (Acts → Sequences → Scenes) with a Kanban-style interface, along with characters, locations, and ideas.

**Stack**: Ruby on Rails 8.1.1, Ruby 3.4+, PostgreSQL 16, Node.js 22+, Tailwind CSS, Hotwire (Turbo + Stimulus), ESbuild

## Prerequisites

- **Ruby**: 3.4+ (project uses 3.4.6)
- **Rails**: 8.1.1
- **Node.js**: 22+ (project uses 22.19.0)
- **PostgreSQL**: 16
- **Podman or Docker**: For running PostgreSQL container
- **Bundler**: `gem install bundler`
- **Foreman**: Installed automatically by `bin/dev`

## Initial Setup

```bash
# 1. Clone the repository
git clone https://github.com/Dreamink-SNPP/dreamink-project.git
cd dreamink-project

# 2. Install dependencies
bundle install
npm install

# 3. Set up database (see Database Setup section below)

# 4. Create .env file with database credentials
# Copy .env.example if available, or create .env with:
# DATABASE_USERNAME=your_username
# DATABASE_PASSWORD=your_password
# DATABASE_HOST=localhost
# DATABASE_PORT=5432

# 5. Create and migrate database
rails db:create
rails db:migrate

# 6. Start the development server
bin/dev
```

Visit `http://localhost:3000` to access the application.

## Development Commands

### Starting Development Server
```bash
bin/dev
```
This uses Foreman to run three processes simultaneously (defined in `Procfile.dev`):
- Rails server with debugging enabled on port 3000
- JavaScript bundler in watch mode (ESbuild)
- Tailwind CSS watcher

### Database Setup

**Important**: The application uses environment variables for database configuration (see `.env` file):
- `DATABASE_USERNAME` - PostgreSQL username
- `DATABASE_PASSWORD` - PostgreSQL password
- `DATABASE_HOST` - Database host (default: localhost)
- `DATABASE_PORT` - Database port (default: 5432)

#### Option 1: Using Podman
```bash
# Start PostgreSQL 16 container
podman run -d \
  --name dreamink_postgres \
  -e POSTGRES_USER=your_username \
  -e POSTGRES_PASSWORD=your_password \
  -e POSTGRES_DB=dreamink_development \
  -p 5432:5432 \
  -v dreamink_postgres_data:/var/lib/postgresql/data \
  docker.io/postgres:16

# Update .env file with your credentials
# DATABASE_USERNAME=your_username
# DATABASE_PASSWORD=your_password
# DATABASE_HOST=localhost
# DATABASE_PORT=5432

# Create and migrate databases
rails db:create
rails db:migrate
```

#### Option 2: Using Docker
```bash
# Start PostgreSQL 16 container
docker run -d \
  --name dreamink_postgres \
  -e POSTGRES_USER=your_username \
  -e POSTGRES_PASSWORD=your_password \
  -e POSTGRES_DB=dreamink_development \
  -p 5432:5432 \
  -v dreamink_postgres_data:/var/lib/postgresql/data \
  postgres:16

# Update .env file with your credentials
# DATABASE_USERNAME=your_username
# DATABASE_PASSWORD=your_password
# DATABASE_HOST=localhost
# DATABASE_PORT=5432

# Create and migrate databases
rails db:create
rails db:migrate
```

#### Managing the Database Container

```bash
# Stop container (Podman or Docker)
podman stop dreamink_postgres  # or: docker stop dreamink_postgres

# Start existing container
podman start dreamink_postgres  # or: docker start dreamink_postgres

# Remove container
podman rm dreamink_postgres  # or: docker rm dreamink_postgres

# View logs
podman logs dreamink_postgres  # or: docker logs dreamink_postgres
```

### Testing
```bash
# Run all tests
rails test

# Run specific test file
rails test test/controllers/scenes_controller_test.rb

# Run system tests
rails test:system
```

### Code Quality
```bash
# Run RuboCop linter (uses rubocop-rails-omakase)
rubocop

# Run Brakeman security scanner
brakeman

# Build JavaScript assets
npm run build
```

## Architecture

### Data Model Hierarchy

The core dramatic structure uses a strict three-level hierarchy with position-based ordering:

**Project** (belongs to User)
└── **Acts** (ordered by position, unique per project)
    └── **Sequences** (ordered by position within act)
        └── **Scenes** (ordered by position within sequence)

Additionally, projects have independent collections:
- **Characters** with internal/external trait associations
- **Locations** (can be interior/exterior)
- **Ideas** with tag support

**Important**: Scenes maintain denormalized references (`act_id`, `project_id`) for performance, automatically synced via the `sync_references` callback.

### Authentication System

Custom Rails 8-style authentication (not Devise):
- Session-based with signed cookies
- Sessions stored in database with expiration support
- `Authentication` concern in controllers provides: `current_user`, `require_authentication`, `start_new_session_for`, `terminate_session`
- `Current` model holds request-scoped session data

### Authorization Pattern

Uses `UserScoped` concern for multi-tenant data isolation:
- All resources scoped to owning user via `for_user(user)` class method
- `owned_by?(user)` instance method checks ownership
- `ProjectAuthorization` concern enforces authorization in controllers

### Reordering & Drag-and-Drop

The structure supports complex reordering using `acts_as_list` gem:
- Acts can move left/right within a project
- Sequences can move left/right within an act or move to different acts
- Scenes can move to different sequences

**Critical**: The `Scene#move_to_sequence` method uses temporary negative positions to avoid unique constraint violations during complex moves. Use `update_columns` to bypass callbacks and validations for performance.

Controller actions handle reordering via:
- `PATCH /projects/:project_id/acts/:id/move_left`
- `PATCH /projects/:project_id/sequences/:id/move_to_act`
- `PATCH /projects/:project_id/scenes/:id/move_to_sequence`

Frontend uses `sortable_controller.js` (Stimulus) with SortableJS library.

### Frontend Architecture

**JavaScript**: Stimulus controllers in `app/javascript/controllers/`
- `sortable_controller.js`: Main drag-and-drop for structure board (complex, ~450 lines)
- `structure_controller.js`: Kanban board UI interactions
- `modal_controller.js`: Modal management
- `collapsible_controller.js`: Collapsible sections
- `flash_controller.js`: Flash message auto-dismissal

**CSS**: Tailwind CSS with custom color palette (see `docs/STYLE_GUIDE.md`)
- Primary brand color: `#1B3C53` (dark teal/navy)
- Use `bg-primary`, `text-primary`, `hover:bg-secondary-dark`
- Custom shades: `primary-50` through `primary-900`

**Build Process**: ESbuild bundles JavaScript from `app/javascript/` to `app/assets/builds/`

### Service Objects

Services located in `app/services/`:
- `Fountain::StructureExporter`: Exports project structure to Fountain screenplay format
- `Pdf::*`: PDF generation services (using Prawn)

### Routing Patterns

Nested resource structure (see `config/routes.rb`):
```ruby
resources :projects do
  resources :acts
  resources :sequences
  resources :scenes
  resources :characters
  resources :locations
  resources :ideas

  get "structure", to: "structures#show"    # Kanban board
  get :fountain_export                      # Export to Fountain format
end
```

Modal endpoints use `_modal` suffix (e.g., `edit_modal`, `new_modal`) to return Turbo Frame responses.

### Internationalization

The app supports Spanish (default) and English:
- Locale files: `config/locales/es.yml`, `config/locales/en.yml`
- Use `I18n.t()` for all user-facing strings
- Scene times of day defined in `Scene::TIMES_OF_DAY` constant

## Development Guidelines

### Testing Patterns

Tests use fixtures in `test/fixtures/` with helper methods in `test/test_helper.rb`:
- Controller tests verify authentication and authorization
- System tests use Capybara + Selenium WebDriver
- Test sessions by setting `session[:session_id]` (see `Authentication` concern test mode)

### Database Migrations

- Use `db:migrate` after pulling changes
- Unique constraints on position columns prevent duplicates (e.g., `index_acts_on_project_and_position`)
- Recent migrations added session expiration and performance indexes

### Common Development Tasks

**Adding a new model attribute**:
1. Generate migration: `rails g migration AddFieldToModel field:type`
2. Run migration: `rails db:migrate`
3. Add to strong parameters in controller
4. Update form views

**Adding a new Stimulus controller**:
1. Create in `app/javascript/controllers/name_controller.js`
2. Export in `app/javascript/controllers/index.js`
3. Use in view: `data-controller="name"`

**Working with Turbo Frames**:
- Modal forms use `turbo_frame_tag` with matching IDs
- Controllers respond with `turbo_stream` format for dynamic updates
- Lazy-loaded frames use `src` attribute

### Deployment

Uses Kamal for deployment (config in `config/deploy.yml`). Dockerfile provided for containerization.
