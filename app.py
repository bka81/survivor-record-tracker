from flask import Flask, render_template

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
    return render_template("reviewer_dashboard.html")

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