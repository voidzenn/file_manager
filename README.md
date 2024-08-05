
# File Manager

## Overview
This is a File Manager web application built with Rails 7. The app allows users to manage their files and folders efficiently. It integrates Minio for object storage and uses Docker to handle Redis, Minio, PostgreSQL, and the web application itself. Actionable and Rswag are used for documentation.

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
- **Minio**: Object storage for files
- **Actionable**: For asynchronous jobs
- **Rswag**: Swagger documentation for API endpoints
- **Docker**: Containerization of Redis, Minio, PostgreSQL, and the Rails app

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

## Usage
- **Folder Management:**
  - Navigate to the folder section to create, rename, remove, or list folders.
  
- **File Management:**
  - Navigate to the file section to upload, rename, view, or remove files. You can also create files inside specific folders.

## API Documentation
- The API documentation is available via Swagger at [http://localhost:3000/api-docs](http://localhost:3000/api-docs).