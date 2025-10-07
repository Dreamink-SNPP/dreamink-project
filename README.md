# 🎬 Dreamink

> Sistema web de código abierto para gestión de estructura dramática en obras audiovisuales

Dreamink es una aplicación web diseñada para ayudar a guionistas a organizar y estructurar sus obras audiovisuales antes de escribir el guión literario. Incluye gestión de tratamiento, estructura dramática (actos, secuencias, escenas), personajes, locaciones e ideas.

## ✨ Características

- 📝 Gestión completa del tratamiento (título, género, logline, sinopsis, etc.)
- 🎭 Estructura dramática con tablero Kanban (actos → secuencias → escenas)
- 👥 Fichas detalladas de personajes (características internas y externas)
- 📍 Gestión de locaciones
- 💡 Banco de ideas con etiquetas
- 📄 Exportación a formato Fountain
- 🔒 Sistema de autenticación simple y privado

## 🛠️ Tecnologías

- Ruby on Rails 8.0.3
- PostgreSQL 16
- Tailwind CSS
- ESbuild
- Hotwire (Turbo + Stimulus)

## 🚀 Instalación

### Requisitos previos

- Ruby 3.x
- Rails 8.0.3
- PostgreSQL 16 (via Docker/Podman)
- Node.js y Yarn

### Configuración

1. Clonar el repositorio:

```bash
git clone git@github.com:Dreamink-SNPP/dreamink-project.git
cd dreamink-project
```

2. Instalar dependencias:

```bash
bundle install
yarn install
```

3. Configurar la base de datos:

```bash
# Iniciar PostgreSQL con Podman
podman run -d \
  --name dreamink_postgres \
  -e POSTGRES_USER=dreamink_user \
  -e POSTGRES_PASSWORD=dreamink_pass_2024 \
  -e POSTGRES_DB=dreamink_development \
  -p 5432:5432 \
  -v dreamink_postgres_data:/var/lib/postgresql/data \
  docker.io/postgres:16

# Crear las bases de datos
rails db:create
rails db:migrate  
```

>[!WARNING]
> Debes cambiar las variables de entorno de `POSTGRES_USER` y `POSTGRES_PASSWORD` a uno más adecuado a tu proyecto y necesidades.

4. Iniciar el servidor:

```bash
bin/dev
```

5. Visitar: `http://localhost:3000`
