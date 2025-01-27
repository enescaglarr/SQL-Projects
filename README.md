# SQL Projects Repository

## Overview
This repository contains SQL-based projects showcasing database design, query optimization, and advanced SQL techniques like stored procedures and triggers. These projects highlight real-world applications of database management and SQL for various scenarios.

---

## Projects

### 1. NBA Team Management Database System
**Description**:  
A comprehensive database system for managing NBA data, including teams, players, staff, stadiums, and games. This project integrates advanced SQL features like triggers and stored procedures to ensure efficient and secure database management.

**Key Features**:
- **Triggers**:
  - `AfterPlayerInsert`: Logs player additions to the `log_table`.
  - `AfterTeamInsert`: Logs team additions with stadium information.
- **Stored Procedures**:
  - `GetAllPlayers`: Retrieves detailed player data.
  - `AddStaffMember`: Simplifies adding new staff members.
  - `GetAllTeams`: Fetches all team details.
  - `GetAllStadiums`: Displays all stadium data.
- **Web Application**:
  - Includes a web-based interface for managing and interacting with database data.
  - Real-time updates using Firebase Realtime Database.
  - Role-based access for users, guests, and admins.

**How to Use**:
1. Import the SQL script (`cs306ProjectPhase2SQLScript.sql`) to set up the database.
2. Ensure the database triggers and procedures are installed and working.
3. Connect the database to the web application using the provided frontend files (`index.html`).
4. Use the web application or SQL scripts to manage and interact with the data.

**Resources**:
- [Phase 2 Report](https://your-link.com)  
- [Phase 3 Report](https://your-link.com)

---

## Future Projects
More projects will be added to this repository soon, focusing on:
- Complex SQL queries for data analysis.
- Schema design and normalization.
- Performance optimization techniques.
- Triggers and constraints for advanced database management.

---

## Requirements
- A relational database management system (e.g., MySQL).
- Basic knowledge of SQL and database design.

## Contact
For any questions or suggestions, feel free to reach out at **enes.caglar@sabanciuniv.edu**.

---

Thank you for visiting the SQL Projects repository! 🚀
