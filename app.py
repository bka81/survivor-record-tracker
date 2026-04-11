from flask import Flask, render_template, request, redirect, url_for, session, flash
from db_config import get_db
from functools import wraps

app = Flask(__name__)
app.secret_key = 'your-secret-key-here-change-this-in-production'

# login with email of responder eg daniel.lee@example.com(directs to staff dashboard), facility staff eg noah.wilson@example.com (directs to staff dashboard) or
# reviewer eg zara.ahmed@example.com (directs to staff dashboard))

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please login first')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def role_required(*allowed_roles):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if session.get('role') not in allowed_roles:
                flash('Access denied')
                return redirect(url_for('login'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route("/")
def root():
    return redirect(url_for('login'))

@app.route("/login", methods=["GET", "POST"])
def login():
    conn = get_db()

    with conn.cursor() as cursor:
        cursor.execute("SELECT orgID, orgName FROM Organization ORDER BY orgName")
        organizations = cursor.fetchall()

        cursor.execute("SELECT facilityID, facilityName FROM Facility ORDER BY facilityName")
        facilities = cursor.fetchall()

    if request.method == "POST":
        email = request.form.get("username", "").strip()
        password = request.form.get("password", "").strip()

        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT u.userID, u.firstName, u.lastName,
                       CASE
                           WHEN r.userID IS NOT NULL THEN 'reviewer'
                           WHEN fs.userID IS NOT NULL THEN 'facility_staff'
                           WHEN res.userID IS NOT NULL THEN 'responder'
                           ELSE 'unknown'
                       END AS role
                FROM Users u
                LEFT JOIN Reviewer r ON u.userID = r.userID
                LEFT JOIN FacilityStaff fs ON u.userID = fs.userID
                LEFT JOIN Responder res ON u.userID = res.userID
                WHERE u.userEmail = %s AND u.userPassword = %s
            """, (email, password))
            user = cursor.fetchone()

        conn.close()

        if user:
            session['user_id'] = user['userID']
            session['username'] = user['firstName']
            session['userFullName'] = f"{user['firstName']} {user['lastName']}"
            session['role'] = user['role']

            if user['role'] == 'reviewer':
                return redirect(url_for('reviewer_dashboard'))
            elif user['role'] in ['responder', 'facility_staff']:
                return redirect(url_for('staff_dashboard'))

        return render_template(
            "login.html",
            error="Invalid email or password",
            organizations=organizations,
            facilities=facilities
        )

    conn.close()
    return render_template(
        "login.html",
        organizations=organizations,
        facilities=facilities
    )

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route("/register", methods=["POST"])
def register():
    first_name = request.form.get("firstName", "").strip()
    last_name = request.form.get("lastName", "").strip()
    email = request.form.get("userEmail", "").strip()
    phone = request.form.get("userPhoneNo", "").strip()
    password = request.form.get("userPassword", "").strip()
    role = request.form.get("role", "").strip()
    org_id = request.form.get("orgID", "").strip()
    facility_id = request.form.get("facilityID", "").strip()

    conn= get_db()
    with conn.cursor() as cursor:
        cursor.execute("SELECT orgID, orgName FROM Organization ORDER BY orgName")
        organizations =cursor.fetchall()

        cursor.execute("SELECT facilityID,facilityName FROM Facility ORDER BY facilityName")
        facilities = cursor.fetchall()

        cursor.execute("SELECT userID FROM Users WHERE userEmail = %s", (email,))
        existing_user = cursor.fetchone()

        if existing_user:
            conn.close()
            return render_template("login.html", 
                error="An account with that email already exists",
                organizations=organizations,
                facilities=facilities)
        
        if role == "responder" and not org_id:
            conn.close()
            return render_template("login.html", 
                error="Please select an organization",
                organizations=organizations,
                facilities=facilities)
        
        if role == "facility_staff" and not facility_id:
            conn.close()
            return render_template("login.html", 
                error="Please select a facility",
                organizations=organizations,
                facilities=facilities)
        
        if role not in["reviewer", "responder", "facility_staff"]:
            conn.close()
            return render_template("login.html", 
                error="Please choose a valid role",
                organizations=organizations,
                facilities=facilities)
        
        cursor.execute("SELECT COALESCE(MAX(userID),0) + 1 AS next_id FROM Users")
        next_id = cursor.fetchone()["next_id"]

        cursor.execute("""
            INSERT INTO Users (userID, firstName, lastName, userEmail, userPhoneNo, userPassword)
            VALUES (%s, %s, %s, %s, %s, %s)
        """,(next_id, first_name, last_name, email, phone, password))

        if role == "reviewer":
            cursor.execute("""
                INSERT INTO Reviewer (userID)
                VALUES (%s)
        """, (next_id, ))
        elif role == "responder":
            cursor.execute("""
                INSERT INTO Responder (userID, orgID)
                VALUES (%s, %s)
        """, (next_id, org_id))
        elif role == "facility_staff":
            cursor.execute("""
                INSERT INTO FacilityStaff (userID, facilityID)
                VALUES (%s, %s)
        """, (next_id, facility_id))
    conn.commit()
    conn.close()

    return redirect(url_for("login"))

@app.route("/reviewer/dashboard")
@login_required
@role_required('reviewer')
def reviewer_dashboard():
    # Survivor search params
    searched = request.args.get("searched")
    status = request.args.get("status", "").strip()
    is_minor = request.args.get("isMinor")
    open_flags_only = request.args.get("openFlagsOnly")

    # Disaster search params
    disaster_searched = request.args.get("disasterSearched")
    disaster_type = request.args.get("disasterType", "").strip()
    disaster_location = request.args.get("location", "").strip()

    survivors = []
    disasters = []

    conn = get_db()
    with conn.cursor() as cursor:
        # Survivor search
        if searched:
            survivor_query = """
                SELECT DISTINCT
                    s.survivorID,
                    s.firstName,
                    s.lastName,
                    s.aliasTag,
                    s.status,
                    s.isMinor,
                    d.disasterID,
                    d.disasterType,
                    d.location,
                    d.disasterDateTime
                FROM SurvivorRecord s
                JOIN DisasterEvent d ON s.disasterID = d.disasterID
                LEFT JOIN Flag f
                    ON s.survivorID = f.survivorID
                   AND f.flagStatus = 'Open'
                WHERE 1=1
            """
            survivor_params = []

            if status:
                survivor_query += " AND s.status = %s"
                survivor_params.append(status)

            if is_minor:
                survivor_query += " AND s.isMinor = %s"
                survivor_params.append(1)

            if open_flags_only:
                survivor_query += " AND f.flagID IS NOT NULL"

            survivor_query += " ORDER BY s.survivorID DESC"

            cursor.execute(survivor_query, survivor_params)
            survivors = cursor.fetchall()

        # Disaster search
        if disaster_searched:
            disaster_query = """
                SELECT
                    d.disasterID,
                    d.disasterType,
                    d.location,
                    d.disasterDateTime,
                    COUNT(s.survivorID) AS survivorCount
                FROM DisasterEvent d
                LEFT JOIN SurvivorRecord s ON d.disasterID = s.disasterID
                WHERE 1=1
            """
            disaster_params = []

            if disaster_type:
                disaster_query += " AND d.disasterType = %s"
                disaster_params.append(disaster_type)

            if disaster_location:
                disaster_query += " AND d.location LIKE %s"
                disaster_params.append(f"%{disaster_location}%")

            disaster_query += """
                GROUP BY d.disasterID, d.disasterType, d.location, d.disasterDateTime
                ORDER BY d.disasterDateTime DESC
            """

            cursor.execute(disaster_query, disaster_params)
            disasters = cursor.fetchall()

        cursor.execute("SELECT COUNT(*) AS total FROM SurvivorRecord")
        total_survivors = cursor.fetchone()['total']

        cursor.execute("SELECT COUNT(*) AS total FROM Facility")
        total_facilities = cursor.fetchone()['total']

        cursor.execute("SELECT COUNT(*) AS total FROM Flag WHERE flagStatus = 'Open'")
        total_flags = cursor.fetchone()['total']

        cursor.execute("SELECT COUNT(*) AS total FROM DisasterEvent")
        total_disasters = cursor.fetchone()['total']

    conn.close()

    return render_template(
        "reviewer_dashboard.html",
        survivors=survivors,
        disasters=disasters,
        searched=searched,
        disasterSearched=disaster_searched,
        total_survivors=total_survivors,
        total_facilities=total_facilities,
        total_flags=total_flags,
        total_disasters=total_disasters
    )

@app.route("/staff/dashboard")
@login_required
@role_required('responder', 'facility_staff')
def staff_dashboard():
    survivor_name = request.args.get("name", "").strip()
    survivor_alias = request.args.get("aliasTag", "").strip()
    disaster_id = request.args.get("disasterID", "").strip()

    conn = get_db()
    with conn.cursor() as cursor:
        search_query = """
            SELECT 
                s.survivorID,
                s.firstName,
                s.lastName,
                s.aliasTag,
                s.isMinor,
                s.status,
                d.disasterID,
                d.disasterType,
                d.location,
                d.disasterDateTime
            FROM SurvivorRecord s
            JOIN DisasterEvent d ON s.disasterID = d.disasterID
            WHERE 1=1
        """
        params = []

        if survivor_name:
            search_query += """
                AND TRIM(CONCAT(COALESCE(s.firstName, ''), ' ', COALESCE(s.lastName, ''))) LIKE %s
            """
            params.append(f"%{'%'.join(survivor_name.split())}%")

        if survivor_alias:
            search_query += " AND s.aliasTag LIKE %s"
            params.append(f"%{survivor_alias}%")

        if disaster_id:
            search_query += " AND s.disasterID = %s"
            params.append(disaster_id)

        search_query += " ORDER BY s.survivorID DESC"

        cursor.execute(search_query, params)
        survivors = cursor.fetchall()

        cursor.execute("""
            SELECT 
                d.disasterID,
                d.disasterType,
                d.location,
                d.disasterDateTime,
                COUNT(s.survivorID) AS survivorCount
            FROM DisasterEvent d
            LEFT JOIN SurvivorRecord s ON d.disasterID = s.disasterID
            GROUP BY d.disasterID, d.disasterType, d.location, d.disasterDateTime
            ORDER BY d.disasterDateTime DESC
        """)
        disaster_summary = cursor.fetchall()

        cursor.execute("""
            SELECT disasterID, disasterType, location, disasterDateTime
            FROM DisasterEvent
            ORDER BY disasterDateTime DESC
        """)
        disasters = cursor.fetchall()

    conn.close()

    return render_template(
        "staff_dashboard.html",
        survivors=survivors,
        disaster_summary=disaster_summary,
        disasters=disasters
    )

@app.route("/staff/add-survivor", methods=["GET", "POST"])
@login_required
@role_required('responder','facility_staff')
def add_survivor():
    conn = get_db()

    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT disasterID, disasterType, location, disasterDateTime
            FROM DisasterEvent
            ORDER BY disasterDateTime DESC
        """)
        disasters = cursor.fetchall()

    if request.method == "POST":
        first_name = request.form.get("firstName")
        last_name = request.form.get("lastName")
        alias_tag = request.form.get("aliasTag")
        is_minor = 1 if request.form.get("isMinor") else 0 
        status = request.form.get("status")
        disaster_id = request.form.get("disasterID")
        
        with conn.cursor() as cursor: 
            cursor.execute("SELECT COALESCE(MAX(survivorID), 0) + 1 AS next_id FROM SurvivorRecord")
            result = cursor.fetchone()
            next_id = result['next_id']

            cursor.execute("""
                INSERT INTO SurvivorRecord (
                    survivorID, firstName, lastName, aliasTag, isMinor, status, disasterID
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                next_id,
                first_name,
                last_name,
                alias_tag if alias_tag else None,
                int(is_minor),
                status,
                disaster_id
            ))
            conn.commit()

        conn.close()
        return redirect(url_for("staff_dashboard"))

    conn.close()
    return render_template("add_survivor.html", disasters=disasters)

@app.route("/staff/add-transfer", methods=["GET", "POST"])
@login_required
@role_required('responder','facility_staff')
def add_transfer():
    conn = get_db()

    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT survivorID, firstName, lastName, aliasTag, status
            FROM SurvivorRecord
            ORDER BY survivorID DESC
        """)
        survivors = cursor.fetchall()

        cursor.execute("""
            SELECT facilityID, facilityName
            FROM Facility
            ORDER BY facilityName
        """)
        facilities = cursor.fetchall()

    if request.method == "POST":
        survivor_id = request.form.get("survivorID")
        from_facility_id = request.form.get("fromFacilityID")
        to_facility_id = request.form.get("toFacilityID")
        note_text = request.form.get("noteText")

        user_id = session['user_id']

        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT COALESCE(MAX(transferID), 0) + 1 AS next_id FROM TransferEvent")
                result = cursor.fetchone()
                next_id = result['next_id']

                cursor.execute("""
                    INSERT INTO TransferEvent (
                        transferID, survivorID, fromFacilityID, toFacilityID, userID, transferTime
                    )
                    VALUES (%s, %s, %s, %s, %s, NOW())
                """, (
                    next_id,
                    survivor_id,
                    from_facility_id if from_facility_id else None,
                    to_facility_id,
                    user_id
                ))

                transfer_id = next_id

                if note_text and note_text.strip():
                    cursor.execute("""
                        INSERT INTO TransferNote (transferID, noteNo, noteText)
                        VALUES (%s, 1, %s)
                    """, (transfer_id, note_text.strip()))

                conn.commit()
            conn.close()
            return redirect(url_for("staff_dashboard"))

        except Exception as e:
            conn.close()
            return render_template(
                "add_transfer.html",
                survivors=survivors,
                facilities=facilities,
                error="Cannot transfer a survivor whose case is Closed!"
            )

    conn.close()
    return render_template(
        "add_transfer.html",
        survivors=survivors,
        facilities=facilities
    )

@app.route("/survivors/<int:survivor_id>")
@login_required
@role_required('reviewer')
def survivor_detail(survivor_id):
    conn = get_db()

    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT 
                s.survivorID,
                s.firstName,
                s.lastName,
                s.aliasTag,
                s.isMinor,
                s.status,
                d.disasterType,
                d.location,
                d.disasterDateTime
            FROM SurvivorRecord s
            JOIN DisasterEvent d ON s.disasterID = d.disasterID
            WHERE s.survivorID = %s
        """, (survivor_id,))
        survivor = cursor.fetchone()

        if not survivor:
            conn.close()
            return "Survivor record not found", 404
        
        #Transfer timeline
        cursor.execute("""
            SELECT
                t.transferID,
                t.transferTime, 
                f1.facilityName AS fromFacility,
                f2.facilityName AS toFacility,
                u.firstName AS handledByFirst,
                u.lastName AS handledByLast,
                tn.noteText
            FROM TransferEvent t
            LEFT JOIN Facility f1 ON t.fromFacilityID = f1.facilityID
            JOIN Facility f2 ON t.toFacilityID = f2.facilityID
            JOIN Users u ON t.userID = u.userID
            LEFT JOIN TransferNote tn ON t.transferID = tn.transferID
            WHERE t.survivorID = %s
            ORDER BY t.transferTime DESC                       
        """, (survivor_id,))
        transfers = cursor.fetchall()

        #All flags
        cursor.execute("""
            SELECT
                flagID, 
                flagStatus,
                category, 
                description,
                createdAt
            FROM Flag
            WHERE survivorID = %s
            ORDER BY createdAt DESC
        """, (survivor_id,))
        all_flags = cursor.fetchall()

    conn.close()

    current_location = transfers[0]["toFacility"] if transfers else None

    return render_template("survivor_detail.html", 
                           survivor=survivor,
                           transfers=transfers, 
                           all_flags=all_flags,
                           current_location=current_location)
                           
@app.route("/survivors/<int:survivor_id>/flags/create", methods=["POST"])
@login_required
@role_required('reviewer')
def create_flag(survivor_id):
    conn=get_db()

    #temporary until login page is implemented
    reviewer_user_id = session['user_id']
    flag_status = "Open"
    category = request.form.get("category")
    description =  request.form.get("description")

    with conn.cursor() as cursor:
            cursor.execute("SELECT COALESCE(MAX(flagID), 0) + 1 AS next_id FROM Flag")
            result = cursor.fetchone()
            next_id = result['next_id']


            cursor.execute("""
            INSERT INTO Flag(flagID, userID, survivorID, flagStatus, category, description, createdAt)
            VALUES (%s, %s, %s, %s, %s, %s, NOW())
        """, (next_id, reviewer_user_id, survivor_id, flag_status, category, description))
            conn.commit()
    conn.close()

    return redirect(url_for("survivor_detail", survivor_id = survivor_id))

##update flag status:

@app.route("/flags/<int:flag_id>/status", methods=["POST"])
@login_required
@role_required('reviewer')
def update_flag_status(flag_id):
    conn = get_db()
    new_status = request.form.get("flagStatus")
    survivor_id = request.form.get("survivor_id")

    with conn.cursor() as cursor:
        cursor.execute("""
            UPDATE Flag
            SET flagStatus = %s
            WHERE flagID = %s
        """, (new_status, flag_id))
        conn.commit()
    conn.close()
    return redirect(url_for("survivor_detail", survivor_id=survivor_id))


@app.route("/survivors/<int:survivor_id>/status", methods=["POST"])
@login_required
def update_survivor_status(survivor_id):
    conn = get_db()
    new_status = request.form.get("status")

    with conn.cursor() as cursor:
        cursor.execute("""
            UPDATE SurvivorRecord
            SET status = %s
            WHERE survivorID = %s
        """, (new_status, survivor_id))
        conn.commit()

    conn.close()
    return redirect(url_for("survivor_detail", survivor_id=survivor_id))


##remove flag:
@app.route("/flags/<int:flag_id>/remove", methods=["POST"])
@login_required
@role_required('reviewer')
def remove_flag(flag_id):
    conn = get_db()
    survivor_id = request.form.get("survivor_id")

    with conn.cursor() as cursor:
        cursor.execute("""
            DELETE FROM Flag
            WHERE flagID = %s
        """, (flag_id,))
        conn.commit()
    conn.close()
    return redirect(url_for("survivor_detail", survivor_id=survivor_id))

@app.route("/transfers/<int:transfer_id>/delete", methods=["POST"])
@login_required
@role_required('responder', 'facility_staff')
def delete_transfer(transfer_id):
    conn = get_db()
    survivor_id = request.form.get("survivor_id")

    with conn.cursor() as cursor:
        cursor.execute("""
            DELETE FROM TransferEvent
            WHERE transferID = %s
        """, (transfer_id,))
        conn.commit()

    conn.close()
    return redirect(url_for("staff_dashboard"))

@app.route("/disasters/<int:disaster_id>")
@login_required
@role_required('reviewer')
def disaster_detail(disaster_id):
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT disasterID, disasterType, location, disasterDateTime
            FROM DisasterEvent
            WHERE disasterID = %s
        """, (disaster_id,))
        disaster = cursor.fetchone()

        if not disaster:
            conn.close()
            return "Disaster not found", 404

        cursor.execute("""
            SELECT survivorID, firstName, lastName, aliasTag, isMinor, status
            FROM SurvivorRecord
            WHERE disasterID = %s
        """, (disaster_id,))
        survivors = cursor.fetchall()

        cursor.execute("""
            SELECT 
                COUNT(*) AS total,
                SUM(CASE WHEN isMinor = TRUE THEN 1 ELSE 0 END) AS minors,
                SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active,
                SUM(CASE WHEN status = 'Unknown' THEN 1 ELSE 0 END) AS unknown
            FROM SurvivorRecord
            WHERE disasterID = %s
        """, (disaster_id,))
        stats = cursor.fetchone()

        cursor.execute("""
            SELECT
                u.userID, u.firstName, u.lastName,
                CASE
                    WHEN r.userID IS NOT NULL THEN 'Responder'
                    WHEN fs.userID IS NOT NULL THEN 'Facility Staff'
                END AS role
            FROM Users u 
            LEFT JOIN Responder r ON u.userID = r.userID
            LEFT JOIN FacilityStaff fs ON u.userID = fs.userID
            WHERE (r.userID is NOT NULL OR fs.userID is NOT NULL)
                AND NOT EXISTS(
                    SELECT s.survivorID
                    FROM SurvivorRecord s
                    WHERE s.disasterID = %s
                        AND EXISTS(
                            SELECT 1 
                            FROM Flag f
                            WHERE f.survivorID = s.survivorID
                       )
                        AND NOT EXISTS(
                            SELECT 1
                            FROM TransferEvent t
                            WHERE t.userID = u.userID
                            AND t.survivorID = s.survivorID
                       )
                )
        """, (disaster_id,))
        division_staff = cursor.fetchall()
    conn.close()
    return render_template("disaster_detail.html", 
                           disaster=disaster, 
                           survivors=survivors,
                           stats=stats,
                           division_staff = division_staff)  

@app.route("/db-test")
def db_test():
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute("SELECT COUNT(*) AS total FROM SurvivorRecord")
        result = cursor.fetchone()
    conn.close()
    return f"DB works. Survivor count: {result['total']}"

if __name__ == "__main__":
    app.run(debug=True)