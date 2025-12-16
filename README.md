# Dreamink

> Open-source web application for dramatic structure management in audiovisual works

Dreamink is a web application designed to help screenwriters organize and structure their audiovisual works before writing the literary script. It provides comprehensive tools for managing dramatic structure using a three-tier hierarchy (Acts, Sequences, Scenes) with a Kanban-style interface, along with character profiles, locations, and idea management.

## Features

- Complete treatment management (title, genre, logline, synopsis, etc.)
- Dramatic structure board with Kanban interface (Acts → Sequences → Scenes)
- Detailed character profiles with internal and external traits
- Location management (interior/exterior settings)
- Ideas repository with tagging system
- Export to Fountain screenplay format
- PDF report generation
- Multi-tenant authentication system
- Drag-and-drop reordering with position-based organization

## Technology Stack

- **Backend**: Ruby on Rails 8.1.1, Ruby 3.4.6
- **Database**: PostgreSQL 16
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS, ESbuild
- **Key Libraries**: acts_as_list, Prawn (PDF), SortableJS (drag-and-drop)
- **Deployment**: Kamal, Thruster, Docker
- **Testing**: Minitest, Capybara, Selenium WebDriver

## Quick Start

### Prerequisites

- Ruby 3.4+
- Rails 8.1.1
- PostgreSQL 16
- Node.js 22+
- Docker or Podman (for PostgreSQL)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/Dreamink-SNPP/dreamink-project.git
cd dreamink-project
```

2. Install dependencies:

```bash
bundle install
npm install
```

3. Set up the database:

**Option A: Using Docker Compose (Recommended)**

```bash
# Create .env file with your database credentials
cp .env.example .env  # Or create manually

# Start PostgreSQL
docker compose up -d

# Create and migrate databases
rails db:create
rails db:migrate
```

**Option B: Using Podman/Docker manually**

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

# Update .env file with credentials
# DATABASE_USERNAME=your_username
# DATABASE_PASSWORD=your_password
# DATABASE_HOST=localhost
# DATABASE_PORT=5432

# Create and migrate databases
rails db:create
rails db:migrate
```

4. Start the development server:

```bash
bin/dev
```

5. Visit http://localhost:3000

## Development

### Running Tests

```bash
# Run all tests
rails test

# Run specific test file
rails test test/controllers/scenes_controller_test.rb

# Run system tests
rails test:system

# Run full test suite (like CI)
bin/rails db:test:prepare test test:system
```

### Code Quality

```bash
# Run RuboCop linter
bin/rubocop

# Run Brakeman security scanner
bin/brakeman

# Build JavaScript assets
npm run build
```

### Common Commands

```bash
# Start development server (Rails + JS + CSS watchers)
bin/dev

# Database migrations
rails db:migrate
rails db:rollback

# Rails console
rails console

# Database console
rails dbconsole

# Generate migration
rails g migration AddFieldToModel field:type
```

## Windows Setup

> [!CAUTION]
> The Windows setup instructions and scripts have not been tested on actual Windows systems yet. We welcome feedback and bug reports from Windows users to help improve this documentation.

This project is primarily developed on Unix-like systems (Linux/macOS). Windows users have two options for running Dreamink:

### Option 1: WSL2 (Recommended)

Windows Subsystem for Linux provides the best compatibility and experience:

**Setup WSL2:**

```powershell
# In PowerShell (run as Administrator)
wsl --install
```

**After installation:**
1. Restart your computer
2. Open Ubuntu from the Start menu
3. Install Docker Desktop for Windows with WSL2 backend enabled
4. Clone the repository inside WSL2 (in your Ubuntu home directory)
5. Follow all standard Linux installation instructions above
6. Access the app at `http://localhost:3000` from your Windows browser

**Benefits**: Full compatibility, all Unix commands work natively, access to Linux tools, Docker integration.

### Option 2: Native Windows

If you prefer to run directly on Windows without WSL2:

**Prerequisites for Windows:**

1. **Ruby**: Install [RubyInstaller for Windows](https://rubyinstaller.org/) (version 3.4.6 with DevKit)
2. **Node.js**: Install from [nodejs.org](https://nodejs.org/) (version 22+)
3. **PostgreSQL**: Use Docker Desktop for Windows OR install [PostgreSQL 16 for Windows](https://www.postgresql.org/download/windows/)
4. **Git**: Install [Git for Windows](https://git-scm.com/download/win)

**Running the Development Server:**

The standard `bin/dev` script is a Unix shell script. Use one of these Windows alternatives:

```powershell
# Command Prompt (CMD)
bin\dev.bat

# PowerShell
.\bin\dev.ps1

# Or run foreman directly
gem install foreman
foreman start -f Procfile.dev
```

**Important Windows Notes:**
- Use backslashes `\` for paths: `bin\dev.bat` instead of `bin/dev`
- Some Unix commands in the documentation may need Windows equivalents
- The `rbenv rehash` command is not needed (RubyInstaller doesn't use rbenv)
- For detailed Windows setup instructions, see [CLAUDE.md - Windows Users](CLAUDE.md#windows-users)

**Known Limitations:**
- System tests may require additional ChromeDriver setup for Windows
- Some development tools may behave differently on Windows
- File path case sensitivity differs (Windows is case-insensitive)

**We Need Your Help**: If you're a Windows user, please test the setup and report any issues or improvements via [GitHub Issues](https://github.com/Dreamink-SNPP/dreamink-project/issues).

## Architecture Overview

### Data Model

The application uses a strict three-tier hierarchy for dramatic structure:

```
Project (belongs to User)
└── Acts (ordered by position)
    └── Sequences (ordered by position within act)
        └── Scenes (ordered by position within sequence)
```

Additional project resources:

- **Characters**: Internal and external trait associations
- **Locations**: Interior/exterior settings
- **Ideas**: Tagged idea repository

### Authentication

Custom Rails 8-style authentication:

- Session-based with signed cookies
- Database-backed sessions with expiration
- `Authentication` concern provides `current_user`, `require_authentication`
- Multi-tenant isolation via `UserScoped` concern

### Frontend

- **Hotwire (Turbo + Stimulus)**: Modern SPA-like experience without complex JavaScript
- **Tailwind CSS**: Utility-first styling with custom brand colors
- **SortableJS**: Drag-and-drop functionality via Stimulus controllers
- **Modal pattern**: Turbo Frame-based modals with `_modal` route suffix

### Key Design Patterns

- **Position-based ordering**: Uses `acts_as_list` gem for all hierarchical resources
- **Denormalized references**: Scenes maintain `act_id` and `project_id` for performance
- **UserScoped concern**: Ensures multi-tenant data isolation
- **ProjectAuthorization**: Controller-level authorization enforcement

## Contributing

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`rails test`)
5. Run linter (`bin/rubocop`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Testing Guidelines

- Write tests for all new features and bug fixes
- Ensure all tests pass before submitting PR
- Use fixtures with `fixture_to_model` helper for parallel tests
- Controller tests must verify authentication and authorization
- System tests should cover critical user workflows

### Code Style

- Follow RuboCop Rails Omakase style guide
- Use `bin/rubocop -a` for auto-corrections
- Security scanning with Brakeman must pass

## Documentation

- **CLAUDE.md**: Comprehensive guide for AI-assisted development
- **docs/STYLE_GUIDE.md**: Visual design and component guidelines
- **config/routes.rb**: Complete routing reference
- **GitHub Actions**: CI/CD pipeline configuration in `.github/workflows/`

## Deployment

The application uses Kamal for deployment. Configuration is in `config/deploy.yml`.

```bash
# Deploy to production
kamal deploy

# View deployment status
kamal app logs
```

## License

This project is open source. See LICENSE file for details.

## Support

- Issues: https://github.com/Dreamink-SNPP/dreamink-project/issues
- Discussions: https://github.com/Dreamink-SNPP/dreamink-project/discussions

## Project Status

Active development. See the [GitHub Projects](https://github.com/Dreamink-SNPP/dreamink-project/projects) for current roadmap and planned features.
