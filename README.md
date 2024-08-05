
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
  - Rename File
  - Remove File
  - View File

## Technology Stack
- **Rails 7**: Web application framework
- **Postgresql**: Database
- **Minio**: Object storage for files
- **Actionable**: For asynchronous jobs
- **Redis**: For synchronous updates
- **Rswag**: Swagger documentation for API endpoints
- **Docker**: Containerization of dependencies

## Preview
![Screenshot from 2024-08-05 17-49-49](https://github.com/user-attachments/assets/526ace27-cc08-4037-b754-dc5dfb15a803)
![Screenshot from 2024-08-05 17-50-25](https://github.com/user-attachments/assets/327fe08a-13ce-4d5c-9bf5-076900658301)
![Screenshot from 2024-08-05 17-50-28](https://github.com/user-attachments/assets/4ebdb208-39af-402c-9f79-4add5a83d14f)

## API Documentation
- The API documentation is available via Swagger at [http://localhost:3000/api-docs](http://localhost:3000/api-docs).
![Screenshot from 2024-08-05 17-48-37](https://github.com/user-attachments/assets/0cf0fd63-f738-4b64-a5ea-d890b878b707)

## Setup

### Prerequisites
Dependencies installed on your machine
- Docker and Docker Compose
- Ruby and Rails
### Installation Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/voidzenn/file_manager.git
   cd <repository-name>
   ```

2. **Rename .env.example to .env:**
   ```bash
   mv .env.example .env
   ```
3. **Install gem dependencies:**
   ```bash
   bundle install
   ```

4. **Build and run the Docker containers:**
   ```bash
   docker-compose up --build
   ```

5. **Access the web application:**

   Open your browser and navigate to [http://localhost:3000](http://localhost:3000) or [http://localhost:3000/api-docs](http://localhost:3000/api-docs).
