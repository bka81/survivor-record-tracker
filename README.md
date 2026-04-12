# Survivor Record Tracker

## Overview

This project is a disaster response survivor-tracking system created to help emergency teams record and monitor the movement of survivors during large-scale disasters such as earthquakes, floods, and wildfires.

In these situations, survivors may be transferred between shelters, triage centers, hospitals, and reunification services, often under urgent conditions and with incomplete information. The purpose of this system is to maintain a centralized record of each survivor’s case so that responders and facilities can track where a survivor was taken, when transfers occurred, who handled each handoff, and the current progress of the case.

By organizing this information in one place, the project helps improve coordination between teams, reduce record-keeping errors, and provide a clearer history of survivor care over time.

This project was built using **Python**, **Flask**, **Tailwind CSS**, and **MySQL**, and is currently intended for **local development and demonstration**.

---

## Tech Stack

- **Backend:** Python, Flask
- **Frontend:** HTML, Tailwind CSS
- **Database:** MySQL
- **Other Tools/Libraries:** PyMySQL, python-dotenv, Node.js, npm

---

## Project Structure

Important files and folders in this project include:

- `app.py` — main Flask application
- `db_config.py` — database connection setup
- `.env.example` — example environment variables file
- `templates/` — HTML templates
- `static/` — CSS and static assets
- `sql/sql_dump.sql` — SQL dump used to create and populate the database

---

## Requirements

Before running the project locally, make sure you have the following installed:

- Python 3
- MySQL Server
- Node.js and npm
- Git (optional, if cloning from a repository)

---

## Local Setup Instructions

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd survivor-record-tracker
```

If you already have the project files, open the project folder in your code editor.

### 2. Create and activate a virtual environment

Create a virtual environment:

```bash
python -m venv .venv
```

Activate it:

**macOS/Linux**
```bash
source .venv/bin/activate
```

**Windows**
```bash
.venv\Scripts\activate
```

### 3. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 4. Install frontend dependencies

```bash
npm install
```

### 5. Set up environment variables

Create a `.env` file in the root of the project using `.env.example` as a guide.

Example:

```env
FLASK_ENV=development
SECRET_KEY=change-me

DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=survivor_record_tracking
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
```

Replace the database username and password with your own MySQL credentials.

### 6. Create and populate the database

This project includes an SQL dump file located at:

```bash
sql/sql_dump.sql
```

Use this file to create and populate the database on your local machine.

You can import it using DBeaver, MySQL Workbench, or the MySQL command line.

Example using MySQL command line:

```bash
mysql -u your_mysql_username -p < sql/sql_dump.sql
```

After importing, make sure the database name matches the one in your `.env` file.

### 7. Start the Flask application

```bash
python app.py
```

The application should then run locally at:

```bash
http://127.0.0.1:5000
```

### 8. Run Tailwind in watch mode

In a second terminal, run:

```bash
npm run tailwind:watch
```

This will rebuild the CSS automatically while you work on the project.

---

## Notes

- Make sure MySQL is running before starting the Flask app.
- Make sure your `.env` file contains the correct database credentials.
- The database for this project is stored locally, so the application is currently meant for local development and demonstration.
- The included `sql_dump.sql` file is the easiest way to set up the database on another machine.


