from flask import Flask, render_template, request
from db_config import get_db


app = Flask(__name__)

@app.route("/")
def root():
    return render_template("login.html")

@app.route("/login")
def login():
    return render_template("login.html")

@app.route("/home")
def home():
    return render_template("home.html")

@app.route("/reviewer/dashboard")
def reviewer_dashboard():
    disaster_type = request.args.get("disasterType")
    disaster_location = request.args.get("location")
    status = request.args.get("status")
    isMinor = request.args.get("isMinor")

    query = """
    SELECT s.survivorID, s.firstName, s.lastName, s.aliasTag, s.status, d.disasterType, d.location, d.disasterDateTime
    FROM SurvivorRecord s
    JOIN DisasterEvent d ON s.disasterID = d.disasterID
    WHERE 1=1
    """
    params = []
    if disaster_type:
        query += "AND d.disasterType = %s"
        params.append(disaster_type)
    if disaster_location:
        query += "AND d.location LIKE %s"
        params.append(f"%{disaster_location}%")
    if status:
        query += "AND s.status = %s"
        params.append(status)
    if isMinor:
        query += "AND s.isMinor = %s"
        params.append(1 if isMinor == "yes" else 0)

    conn = get_db()
    with conn.cursor() as cursor: 
        cursor.execute(query, params)
        results = cursor.fetchall()
    conn.close()

    return render_template("reviewer_dashboard.html",survivors=results)

@app.route("/staff/dashboard")
def staff_dashboard():
    return render_template("staff_dashboard.html")

@app.route("/staff/add-survivor")
def add_survivor():
    return render_template("add_survivor.html")

@app.route("/staff/add-transfer")
def add_transfer():
    return render_template("add_transfer.html")

@app.route("/survivors/1")
def survivor_detail():
    return render_template("survivor_detail.html")

@app.route("/disasters/1")
def disaster_detail():
    return render_template("disaster_detail.html")

if __name__ == "__main__":
    app.run(debug=True)