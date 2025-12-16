# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dreamink is a web application for screenwriters to organize and structure audiovisual works before writing the literary script. It manages dramatic structure using a three-tier hierarchy (Acts → Sequences → Scenes) with a Kanban-style interface, along with characters, locations, and ideas.

**Stack**: Ruby on Rails 8.1.1, Ruby 3.4+, PostgreSQL 16, Node.js 22+, Tailwind CSS, Hotwire (Turbo + Stimulus), ESbuild

**Key Dependencies**:
- `acts_as_list` - Position-based ordering for Acts, Sequences, Scenes
- `bcrypt` - Password hashing for authentication
- `prawn` & `prawn-table` - PDF generation
- `solid_cache`, `solid_queue`, `solid_cable` - Rails 8 database-backed adapters
- `kamal` & `thruster` - Deployment and HTTP optimization
- `sortablejs` - Drag-and-drop functionality (frontend)
- `dotenv-rails` - Environment variable management

## Prerequisites

- **Ruby**: 3.4+ (project uses 3.4.6)
  - Recommended: Use `rbenv` for Ruby version management (Linux/macOS)
- **Rails**: 8.1.1
- **Node.js**: 22+ (project uses 22.19.0)
- **PostgreSQL**: 16
- **Podman or Docker**: For running PostgreSQL container
- **Bundler**: `gem install bundler` (or installed via `bundle install`)
- **Foreman**: Installed automatically by `bin/dev`

### Windows Users

> [!CAUTION]
> The Windows setup instructions and scripts (`bin/dev.bat`, `bin/dev.ps1`) have not been tested on actual Windows systems yet. We welcome feedback and bug reports from Windows users to help improve this documentation.

This project uses Unix-style tools and scripts. Windows users have two options:

#### Option 1: WSL2 (Recommended)

Use Windows Subsystem for Linux for the best compatibility:

```powershell
# In PowerShell (Administrator)
wsl --install
```

After installation:
1. Restart your computer
2. Open Ubuntu (installed with WSL2)
3. Install Docker Desktop for Windows with WSL2 backend enabled
4. Follow all setup instructions in your WSL2 Ubuntu environment
5. The `bin/dev` script and all Unix commands will work natively

**Benefits**: Full compatibility, native Linux environment, all documentation applies directly.

#### Option 2: Native Windows

If you prefer native Windows without WSL2:

**Ruby Installation**:
- Use [RubyInstaller for Windows](https://rubyinstaller.org/) instead of `rbenv`
- Download Ruby 3.4.6 installer (with DevKit)
- Verify: `ruby --version` should show `ruby 3.4.6`

**Node.js Installation**:
- Download from [nodejs.org](https://nodejs.org/)
- Verify: `node --version` should show `v22.x`

**PostgreSQL**:
- Use Docker Desktop for Windows (recommended)
- Or install PostgreSQL 16 natively from [postgresql.org](https://www.postgresql.org/download/windows/)

**Running the Development Server**:
The `bin/dev` script is a Unix shell script. Use one of these alternatives:

```powershell
# Option A: Use the provided Windows batch script (CMD)
bin\dev.bat

# Option B: Use the provided PowerShell script
bin\dev.ps1

# Option C: Run foreman directly
gem install foreman
foreman start -f Procfile.dev
```

**Important Notes for Native Windows**:
- Use backslashes `\` for paths: `bin\dev.bat` instead of `bin/dev`
- Replace `export VAR=value` with `set VAR=value` (CMD) or `$env:VAR="value"` (PowerShell)
- Multi-line commands with `\` won't work; combine into single lines or use `^` (CMD) or `` ` `` (PowerShell)
- `rbenv rehash` is not needed (RubyInstaller doesn't use it)

## Initial Setup

```bash
# 1. Clone the repository
git clone https://github.com/Dreamink-SNPP/dreamink-project.git
cd dreamink-project

# 2. Install Ruby (if using rbenv)
# The project uses Ruby 3.4.6 (specified in .ruby-version)
# If you don't have it installed:
rbenv install 3.4.6
rbenv rehash

# Verify Ruby version
ruby --version  # Should show: ruby 3.4.6

# 3. Install dependencies
bundle install
npm install

# Important: If using rbenv, rehash after installing gems with executables
rbenv rehash

# 4. Set up database (see Database Setup section below)

# 5. Create .env file with database credentials
# Copy .env.example if available, or create .env with:
# DATABASE_USERNAME=your_username
# DATABASE_PASSWORD=your_password
# DATABASE_HOST=localhost
# DATABASE_PORT=5432

# 6. Create and migrate database
rails db:create
rails db:migrate

# 7. Start the development server
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

#### Option 1: Using Docker Compose (Recommended)

The easiest way to manage PostgreSQL is with Docker Compose:

```bash
# Start PostgreSQL in the background
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs postgres

# Stop the database
docker compose down

# Stop and remove data (clean slate)
docker compose down -v
```

After starting with Docker Compose, create and migrate the databases:
```bash
rails db:create
rails db:migrate
```

The `docker-compose.yml` file uses your `.env` variables automatically.

#### Option 2: Using Podman
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

#### Option 3: Using Docker (Manual)
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

**With Docker Compose:**
```bash
# Start services
docker compose up -d

# Stop services (keeps data)
docker compose down

# Restart services
docker compose restart

# View logs
docker compose logs -f postgres

# Remove everything including volumes (⚠️ deletes data)
docker compose down -v
```

**With Podman or Docker (manual):**
```bash
# Stop container
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
# Run all tests (runs in parallel by default)
rails test

# Run specific test file
rails test test/controllers/scenes_controller_test.rb

# Run system tests (uses Capybara + Selenium + Chrome)
rails test:system

# Run all tests including system tests (like CI does)
bin/rails db:test:prepare test test:system

# Run a single test by line number
rails test test/controllers/scenes_controller_test.rb:42
```

**Important**: Tests use parallel execution by default. Fixtures return Hashes in parallel mode, so use `fixture_to_model(fixture, ModelClass)` helper to convert them to model instances. For authentication in controller tests, use `sign_in_as(user)` helper (sets `session[:session_id]`).

### Code Quality
```bash
# Run RuboCop linter (uses rubocop-rails-omakase)
rubocop
# Or via bin wrapper:
bin/rubocop

# Run Brakeman security scanner
brakeman
# Or via bin wrapper:
bin/brakeman

# Build JavaScript assets (production build)
npm run build

# Watch mode for JavaScript (already included in bin/dev)
npm run build -- --watch
```

### CI Pipeline

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on PRs and pushes to main:
- **scan_ruby**: Runs Brakeman security scan
- **lint**: Runs RuboCop style checks
- **test**: Runs full test suite with PostgreSQL service container

CI uses `bin/rails db:test:prepare test test:system` to run both unit and system tests.

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

**Assets and Branding**:
- **Logo**: `app/assets/images/dreamink-logo.svg` - Main Dreamink logo used throughout the application
- **Favicon**: `public/icon.svg` and `public/icon.png` - Browser tab icons
- Logo appears in:
  - Navbar (`app/views/shared/_navbar.html.erb`) - 32px height
  - Authentication pages (login, registration, forgot password) - 64px height
- Use `<%= image_tag "dreamink-logo.svg", alt: "Dreamink", class: "h-8 w-auto" %>` pattern for displaying the logo

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
  get :report                               # PDF report
end
```

**Key routing conventions**:
- All resources nested under `/projects/:project_id`
- Modal endpoints use `_modal` suffix (e.g., `edit_modal`, `new_modal`) to return Turbo Frame responses
- Reordering actions: `move_left`, `move_right`, `move_to_act`, `move_to_sequence`
- Report actions: `report` (single resource), `collection_report` (all resources)
- Scenes support filtering: `by_location` action

**Authentication routes**:
- `GET /login`, `POST /login`, `DELETE /logout`
- `GET /register`, `POST /register`
- `GET /forgot-password`, `POST /forgot-password`, `GET /reset-password/:token`, `PATCH /reset-password/:token`

### Internationalization

The app supports Spanish (default) and English:
- Locale files: `config/locales/es.yml`, `config/locales/en.yml`
- Use `I18n.t()` for all user-facing strings
- Scene times of day defined in `Scene::TIMES_OF_DAY` constant

## Development Guidelines

### Testing Patterns

Tests use fixtures in `test/fixtures/` with helper methods in `test/test_helper.rb`:
- **Parallel execution**: Tests run in parallel by default. Use `fixture_to_model(fixture, ModelClass)` to handle Hash fixtures
- **Controller tests**: Verify authentication and authorization. Use `sign_in_as(user)` to authenticate
- **System tests**: Use Capybara + Selenium WebDriver with Chrome
- **Authentication**: Set `session[:session_id]` directly in integration tests (see `Authentication` concern)

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
5. Add tests for new attribute

**Adding a new Stimulus controller**:
1. Create in `app/javascript/controllers/name_controller.js`
2. Export in `app/javascript/controllers/index.js`
3. Use in view: `data-controller="name"`
4. Available targets: connect(), disconnect(), targets, values, classes

**Working with Turbo Frames**:
- Modal forms use `turbo_frame_tag` with matching IDs
- Controllers respond with `turbo_stream` format for dynamic updates
- Lazy-loaded frames use `src` attribute
- Modal endpoints use `_modal` suffix (e.g., `edit_modal_project_scene_path`)

**Debugging**:
- `bin/dev` enables Ruby debug mode via `RUBY_DEBUG_OPEN=true`
- Insert `debugger` in code to trigger breakpoint
- System test screenshots saved to `tmp/screenshots/` on failure

**Troubleshooting**:
- **"command not found" for gem executables** (foreman, rubocop, etc.): Run `rbenv rehash` after installing new gems
- **Ruby version mismatch**: Ensure `ruby --version` matches `.ruby-version` file (3.4.6)
- **Database connection errors**: Verify PostgreSQL is running with `docker compose ps` and credentials in `.env` are correct

### Deployment

Uses Kamal for deployment (config in `config/deploy.yml`). Dockerfile provided for containerization.
