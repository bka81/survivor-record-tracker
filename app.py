from flask import Flask, render_template, request, redirect, url_for
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
    SELECT s.survivorID, s.firstName, s.lastName, s.aliasTag, s.status, s.isMinor, d.disasterType, d.location, d.disasterDateTime
    FROM SurvivorRecord s
    JOIN DisasterEvent d ON s.disasterID = d.disasterID
    WHERE 1=1
    """
    params = []
    if disaster_type:
        query += " AND d.disasterType = %s"
        params.append(disaster_type)
    if disaster_location:
        query += " AND d.location LIKE %s"
        params.append(f"%{disaster_location}%")
    if status:
        query += " AND s.status = %s"
        params.append(status)
    if isMinor:
        query += " AND s.isMinor = %s"
        params.append(1)

    print("QUERY:", query)
    print("PARAMS:", params)

    conn = get_db()
    with conn.cursor() as cursor: 
        cursor.execute(query, params)
        results = cursor.fetchall()

        cursor.execute("SELECT COUNT(*) AS total FROM SurvivorRecord")
        total_survivors = cursor.fetchone()['total']
        
        cursor.execute("SELECT COUNT(*) AS total FROM Facility")
        total_facilities = cursor.fetchone()['total']
        
        cursor.execute("SELECT COUNT(*) AS total FROM Flag WHERE flagStatus='Open'")
        total_flags = cursor.fetchone()['total']

        cursor.execute("SELECT COUNT(*) AS total FROM DisasterEvent")
        total_disasters = cursor.fetchone()['total']


    conn.close()

    return render_template("reviewer_dashboard.html",
    survivors=results, 
    total_disasters=total_disasters,
    total_facilities=total_facilities,
    total_flags=total_flags,
    total_survivors=total_survivors)

@app.route("/staff/dashboard")
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
            search_query += " AND (s.firstName LIKE %s OR s.lastName LIKE %s)"
            params.extend([f"%{survivor_name}%", f"%{survivor_name}%"])

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
        is_minor = request.form.get("isMinor")
        status = request.form.get("status")
        disaster_id = request.form.get("disasterID")

        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO SurvivorRecord (
                    firstName, lastName, aliasTag, isMinor, status, disasterID
                )
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (
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

        user_id = 301

        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO TransferEvent (
                    survivorID, fromFacilityID, toFacilityID, userID, transferTime
                )
                VALUES (%s, %s, %s, %s, NOW())
            """, (
                survivor_id,
                from_facility_id if from_facility_id else None,
                to_facility_id,
                user_id
            ))

            transfer_id = cursor.lastrowid

            if note_text and note_text.strip():
                cursor.execute("""
                    INSERT INTO TransferNote (transferID, noteNo, noteText)
                    VALUES (%s, 1, %s)
                """, (transfer_id, note_text.strip()))

            conn.commit()

        conn.close()
        return redirect(url_for("survivor_detail", survivor_id=survivor_id))

    conn.close()
    return render_template(
        "add_transfer.html",
        survivors=survivors,
        facilities=facilities
    )

@app.route("/survivors/<int:survivor_id>")
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
                           transfers = transfers, 
                           all_flags = all_flags,
                           current_location = current_location)

@app.route("/survivors/<int:survivor_id>/flags/create", methods=["POST"])
def create_flag(survivor_id):
    conn=get_db()

    #temporary until login page is implemented
    reviewer_user_id = 311
    flag_status = "Open"
    category = request.form.get("category")
    description =  request.form.get("description")

    with conn.cursor() as cursor:
        cursor.execute("""
            INSERT INTO Flag(userID, survivorID, flagStatus, category, description, createdAt)
            VALUES (%s, %s, %s, %s, %s, NOW())
        """, (reviewer_user_id, survivor_id, flag_status, category, description))
        conn.commit()
    conn.close()

    return redirect(url_for("survivor_detail", survivor_id = survivor_id))

##update flag status:

@app.route("/flags/<int:flag_id>/status", methods=["POST"])
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
    return redirect(url_for("survivor_detail", survivor_id=survivor_id))

@app.route("/disasters/<int:disaster_id>")
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

    conn.close()
    return render_template("disaster_detail.html", 
                           disaster=disaster, 
                           survivors=survivors,
                           stats=stats)
    return render_template(
        "disaster_detail.html",
        disaster=disaster,
        survivors=survivors,
        stats=stats
    )
##for testing dp connection
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