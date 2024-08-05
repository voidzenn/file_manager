
# File Manager

## Overview
A File manager with [React Frontend](https://github.com/voidzenn/file_manager_fe) and Rails 7 Backend. Allows users to manage their files and folders seamlessly. The app uses Minio for object storage, ensuring that the structure in the File Manager UI mirrors the structure in Minio, providing a reliable and intuitive user experience. Additionally, the app features real-time updates with ActionCable, allowing users to see changes immediately as they happen.

## Features
- **Folder Management:**
  - Create Folder
  - Create Nested Folder
  - Rename Folder
  - Remove Folder
  - Get Folder List

- **File Management:**
  - Create File
  - Create File inside a Folder
  - Rename Filename
  - View File
  - Remove File

## Technology Stack
- **Rails 7**: Web application framework
- **Postgresql**: Database
- **Minio**: Object storage for files
- **Actionable**: For asynchronous jobs
- **Redis**: For synchronous updates
- **Rswag**: Swagger documentation for API endpoints
- **Docker**: Containerization of dependencies

## Preview


## Setup

### Prerequisites
- Docker and Docker Compose installed on your machine

### Installation Steps
1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Build and run the Docker containers:**
   ```bash
   docker-compose up --build
   ```

3. **Run database migrations:**
   ```bash
   docker-compose run web rake db:create db:migrate
   ```

4. **Access the web application:**
   Open your browser and navigate to `http://localhost:3000`.

## API Documentation
- The API documentation is available via Swagger at [http://localhost:3000/api-docs](http://localhost:3000/api-docs).
