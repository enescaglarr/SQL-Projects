# NBA Team Management Database System

## Overview
This project is a comprehensive **NBA Team Management System** designed to manage and interact with various aspects of NBA data, including teams, players, coaches, staff, stadiums, and games. It integrates database design principles with web-based user interfaces and utilizes advanced SQL concepts like triggers and stored procedures.

### Description of Files and Folders
1. **static/**:
   - Contains static assets like images (`background-image.jpg`, `nba-logo.png`) used in the web application.

2. **templates/**:
   - Contains the main HTML file (`index.html`) for the web interface.

3. **app.py**:
   - Python backend script for handling interactions between the web application and the database.

4. **cs306ProjectPhase2SQLScript.sql**:
   - SQL script to set up the database schema, including tables, stored procedures, and triggers.

5. **README.md**:
   - Documentation for the project.

## Features
### Database Features
- **Triggers**:
  - Logs player additions with the player's name and team ID.
  - Logs team additions with team name, ID, and associated stadium ID.
- **Stored Procedures**:
  - `GetAllPlayers`: Displays all players with detailed information.
  - `AddStaffMember`: Simplifies adding new staff members with parameters like age, salary, and job title.
  - `GetAllTeams`: Retrieves team data with team and stadium information.
  - Additional procedures for managing staff, coaches, games, and stadiums.

### Web Application Features
- **Support Page**:
  - Allows users and guests to send messages with specific subjects.
  - Messages are stored in the database and displayed with timestamps.
  - Admins can view and respond to all messages.
- **Admin Panel**:
  - View all messages from users and guests in one place.
  - Send real-time replies to users.
- **Privacy**:
  - Users and guests see only their own messages.
  - Admins can access all messages and respond securely.

### Real-Time Integration
- Built with **Firebase Realtime Database** to provide real-time updates for messages and admin responses.

## How to Use
### Prerequisites
- A database management system (MySQL recommended).
- Firebase setup with Realtime Database for message handling.
- A web server for hosting the frontend.

### Steps
1. **Database Setup**:
   - Run `cs306ProjectPhase2SQLScript.sql` to create the database schema.
   - Verify triggers and stored procedures are installed correctly.
2. **Web Application Setup**:
   - Place the `app.py`, `static/`, and `templates/` files in your project folder.
   - Update Firebase configuration in `app.py` and `index.html`.
3. **Run the Application**:
   - Start the Flask server by running `app.py`.
   - Open the web interface via the localhost URL.
4. **Interacting with the System**:
   - Use the web application to manage NBA data and messages.

## Technical Details
### SQL Concepts
- **Triggers**:
  - `AfterPlayerInsert`: Logs player additions.
  - `AfterTeamInsert`: Logs team additions.
- **Stored Procedures**:
  - Manage and retrieve data for teams, players, staff, and stadiums.
- **Real-Time Updates**:
  - Messages and responses sync instantly using Firebase.

### Web Technologies
- **Frontend**:
  - Bootstrap for responsive design.
  - Firebase SDK for database interactions.
- **Backend**:
  - Firebase Realtime Database for dynamic message handling.
  - PHP/Python for server-side logic (if applicable).

## Example Usage
### User Flow
1. **As a Guest**:
   - Send a support message.
   - View your messages with timestamps.
2. **As a User**:
   - Log in to access personalized features.
   - Send messages and view responses in real time.
3. **As an Admin**:
   - Log in to view and respond to all user messages.
   - Manage NBA data through the database interface.

### Database Management
1. View all teams using `GetAllTeams` stored procedure.
2. Add a new player and trigger the `AfterPlayerInsert` trigger to log the addition.
3. Retrieve stadium information using the `GetAllStadiums` procedure.

## Credits
- **Çağla Güzel** 
- **Enes Çağlar** 

---

Feel free to let me know if you'd like further customization or additional sections for this project!
