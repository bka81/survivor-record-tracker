DROP DATABASE IF EXISTS survivor_record_tracking;
CREATE DATABASE survivor_record_tracking;
USE survivor_record_tracking;


CREATE TABLE Users (
    userID INT PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    userEmail VARCHAR(100) NOT NULL UNIQUE,
    userPhoneNo VARCHAR(20) NOT NULL,
    userPassword VARCHAR(255) NOT NULL
);

CREATE TABLE Organization (
    orgID INT PRIMARY KEY,
    orgType VARCHAR(50) NOT NULL,
    orgName VARCHAR(100) NOT NULL
);

CREATE TABLE Facility (
    facilityID INT PRIMARY KEY,
    facilityName VARCHAR(100) NOT NULL,
    address VARCHAR(150) NOT NULL,
    orgID INT NOT NULL,
    CONSTRAINT facility_org_fk FOREIGN KEY (orgID) REFERENCES Organization(orgID)
);

CREATE TABLE Responder (
    userID INT PRIMARY KEY,
    orgID INT NOT NULL,
    CONSTRAINT responder_user_fk FOREIGN KEY (userID) REFERENCES Users(userID),
    CONSTRAINT responder_org_fk FOREIGN KEY (orgID) REFERENCES Organization(orgID)
);

CREATE TABLE FacilityStaff (
    userID INT PRIMARY KEY,
    facilityID INT NOT NULL,
    CONSTRAINT facilityStaff_user_fk FOREIGN KEY (userID) REFERENCES Users(userID),
    CONSTRAINT facilityStaff_facility_fk FOREIGN KEY (facilityID) REFERENCES Facility(facilityID)
);

CREATE TABLE Reviewer (
    userID INT PRIMARY KEY,
    CONSTRAINT reviewer_user_fk FOREIGN KEY (userID) REFERENCES Users(userID)
);

CREATE TABLE DisasterEvent (
    disasterID INT PRIMARY KEY,
    disasterType VARCHAR(50) NOT NULL,
    location VARCHAR(150) NOT NULL,
    disasterDateTime DATETIME NOT NULL,
    CONSTRAINT check_disaster_type CHECK (disasterType IN ('Earthquake', 'Flood', 'Wildfire', 'Hurricane', 'Tornado', 'Tsunami', 'Landslide', 'Other'))
);

CREATE TABLE SurvivorRecord (
    survivorID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    aliasTag VARCHAR(100),
    isMinor BOOLEAN NOT NULL,
    status VARCHAR(50) NOT NULL,
    disasterID INT NOT NULL,
    CONSTRAINT survivor_disaster_fk FOREIGN KEY (disasterID) REFERENCES DisasterEvent(disasterID),
    CONSTRAINT check_status CHECK (status IN ('Active', 'Reunited', 'Deceased', 'Unknown', 'Closed'))
);

CREATE TABLE TransferEvent (
    transferID INT AUTO_INCREMENT PRIMARY KEY,
    survivorID INT NOT NULL,
    fromFacilityID INT,
    toFacilityID INT NOT NULL,
    userID INT NOT NULL,
    transferTime DATETIME NOT NULL,
    CONSTRAINT transfer_survivor_fk FOREIGN KEY (survivorID) REFERENCES SurvivorRecord(survivorID),
    CONSTRAINT transfer_from_facility_fk FOREIGN KEY (fromFacilityID) REFERENCES Facility(facilityID),
    CONSTRAINT transfer_to_facility_fk FOREIGN KEY (toFacilityID) REFERENCES Facility(facilityID),
    CONSTRAINT transfer_user_fk FOREIGN KEY (userID) REFERENCES Users(userID)
);

CREATE TABLE TransferNote (
    transferID INT NOT NULL,
    noteNo INT NOT NULL,
    noteText TEXT,
    PRIMARY KEY (transferID, noteNo),
    CONSTRAINT transferNote_transfer_fk FOREIGN KEY (transferID) REFERENCES TransferEvent(transferID)
);

CREATE TABLE Flag (
    flagID INT AUTO_INCREMENT PRIMARY KEY,
    userID INT NOT NULL,
    survivorID INT NOT NULL,
    flagStatus VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    createdAt DATETIME NOT NULL,
    category VARCHAR(100) NOT NULL,
    CONSTRAINT flag_user_fk FOREIGN KEY (userID) REFERENCES Reviewer(userID),
    CONSTRAINT flag_survivor_fk FOREIGN KEY (survivorID) REFERENCES SurvivorRecord(survivorID),
    CONSTRAINT check_flag_status CHECK (flagStatus IN ('Open', 'Resolved'))
);
INSERT INTO Organization (orgID, orgType, orgName)
VALUES
(1, 'Government', 'Provincial Emergency Services'),
(2, 'NGO', 'Red Cross Relief Team'),
(3, 'Hospital', 'City General Hospital'),
(4, 'Shelter', 'Community Shelter Network'),
(5, 'Government', 'Municipal Fire Rescue');

INSERT INTO Facility (facilityID, facilityName, address, orgID)
VALUES
(201, 'North Emergency Shelter', '101 Main St', 4),
(202, 'East Community Shelter', '202 Oak Ave', 4),
(203, 'City General Hospital', '303 Health Rd', 3),
(204, 'West Relief Shelter', '404 Pine St', 2),
(205, 'South Medical Triage Center', '505 River Dr', 1),
(206, 'Central Family Reunification Center', '606 Hope Blvd', 1),
(401, 'Rescue Staging Area A', '701 Front St', 5),
(402, 'Temporary Shelter B', '702 Lake Ave', 2),
(403, 'Field Medical Camp C', '703 Valley Rd', 1),
(404, 'Transit Point D', '704 Cedar St', 5),
(405, 'Mobile Aid Unit E', '705 Hill Dr', 2),
(406, 'Local Intake Center F', '706 Bridge Ave', 4);

INSERT INTO Users (userID, firstName, lastName, userEmail, userPhoneNo, userPassword)
VALUES
(301, 'Amina', 'Khan', 'amina.khan@example.com', '604-111-1001', 'amina123'),
(302, 'Daniel', 'Lee', 'daniel.lee@example.com', '604-111-1002', 'daniel123'),
(303, 'Sara', 'Patel', 'sara.patel@example.com', '604-111-1003', 'sara123'),
(304, 'Omar', 'Chen', 'omar.chen@example.com', '604-111-1004', 'omar123'),
(305, 'Lila', 'Brown', 'lila.brown@example.com', '604-111-1005', 'lila123'),
(306, 'Maya', 'Singh', 'maya.singh@example.com', '604-111-1006', 'maya123'),
(307, 'Noah', 'Wilson', 'noah.wilson@example.com', '604-111-1007', 'noah123'),
(308, 'Eva', 'Garcia', 'eva.garcia@example.com', '604-111-1008', 'eva123'),
(309, 'Ibrahim', 'Ali', 'ibrahim.ali@example.com', '604-111-1009', 'ibrahim123'),
(310, 'Chloe', 'Martin', 'chloe.martin@example.com', '604-111-1010', 'chloe123'),
(311, 'Zara', 'Ahmed', 'zara.ahmed@example.com', '604-111-1011', 'zara123'),
(312, 'Ethan', 'Clark', 'ethan.clark@example.com', '604-111-1012', 'ethan123'),
(313, 'Hana', 'Yusuf', 'hana.yusuf@example.com', '604-111-1013', 'hana123'),
(314, 'Leo', 'Turner', 'leo.turner@example.com', '604-111-1014', 'leo123'),
(315, 'Nina', 'Scott', 'nina.scott@example.com', '604-111-1015', 'nina123');

INSERT INTO Responder (userID, orgID)
VALUES
(301, 1),
(302, 2),
(303, 5),
(304, 1),
(305, 2);

INSERT INTO FacilityStaff (userID, facilityID)
VALUES
(306, 201),
(307, 202),
(308, 203),
(309, 204),
(310, 205);

INSERT INTO Reviewer (userID)
VALUES
(311),
(312),
(313),
(314),
(315);

INSERT INTO DisasterEvent (disasterID, disasterType, location, disasterDateTime)
VALUES
(1, 'Wildfire', 'North Region, Cascade Mountains', '2026-03-14 14:30:00'),
(2, 'Earthquake', 'Westside Urban District', '2026-03-14 08:15:00'),
(3, 'Flood', 'River Valley, South County', '2026-03-13 22:00:00'),
(4, 'Wildfire', 'East Hills, Pine Forest', '2026-03-15 01:45:00'),
(5, 'Tornado', 'Central Plains, Springfield', '2026-03-12 16:20:00');

INSERT INTO SurvivorRecord (survivorID, firstName, lastName, aliasTag, isMinor, status, disasterID)
VALUES
(101, 'Adam', 'Smith', NULL, FALSE, 'Active', 1),
(102, 'Bella', 'Jones', NULL, TRUE, 'Active', 4),
(103, NULL, NULL, 'Unknown1', TRUE, 'Unknown', 3),
(104, 'Chris', 'Taylor', NULL, FALSE, 'Active', 5),
(105, 'Mina', 'Ali', NULL, FALSE, 'Reunited', 2),
(106, NULL, NULL, 'Unknown2', TRUE, 'Unknown', 2),

(107, 'Nora', 'Evans', NULL, FALSE, 'Active', 1),
(108, 'Isaac', 'Moore', NULL, TRUE, 'Active', 1),
(109, NULL, NULL, 'Unknown3', FALSE, 'Unknown', 1),
(110, 'Jamal', 'Reed', NULL, FALSE, 'Active', 1),

(111, 'Layla', 'Hassan', NULL, TRUE, 'Active', 2),
(112, 'Owen', 'Brooks', NULL, FALSE, 'Active', 2),
(113, NULL, NULL, 'Unknown4', TRUE, 'Unknown', 2),

(114, 'Emily', 'Ward', NULL, FALSE, 'Active', 3),
(115, 'Rayan', 'Nasir', NULL, TRUE, 'Active', 3),
(116, NULL, NULL, 'Unknown5', FALSE, 'Unknown', 3),
(117, 'Sophia', 'Cole', NULL, FALSE, 'Reunited', 3),

(118, 'Lucas', 'Price', NULL, FALSE, 'Active', 4),
(119, 'Ava', 'Mitchell', NULL, TRUE, 'Active', 4),
(120, NULL, NULL, 'Unknown6', FALSE, 'Unknown', 4),
(121, 'Yusuf', 'Rahman', NULL, FALSE, 'Active', 4),

(122, 'Mason', 'Perry', NULL, FALSE, 'Active', 5),
(123, 'Ella', 'Long', NULL, TRUE, 'Active', 5),
(124, NULL, NULL, 'Unknown7', FALSE, 'Unknown', 5),
(125, 'Hiba', 'Karim', NULL, FALSE, 'Active', 5);

INSERT INTO TransferEvent (transferID, survivorID, toFacilityID, userID, fromFacilityID, transferTime)
VALUES
(1, 101, 201, 301, 401, '2026-03-15 10:00:00'),
(2, 102, 202, 302, 402, '2026-03-15 11:30:00'),
(3, 103, 203, 303, 403, '2026-03-15 11:40:00'),
(4, 104, 204, 306, 404, '2026-03-15 11:45:00'),
(5, 105, 205, 307, 405, '2026-03-15 12:00:00'),
(6, 106, 206, 308, 406, '2026-03-15 12:02:00'),
(7, 102, 203, 303, 201, '2026-03-15 14:00:00'),
(8, 106, 204, 303, 206, '2026-03-15 14:30:00'),
(9, 106, 203, 303, 204, '2026-03-15 15:00:00'),

(10, 101, 206, 306, 201, '2026-03-15 13:20:00'),
(11, 105, 206, 307, 205, '2026-03-15 13:35:00'),

(12, 107, 201, 301, 401, '2026-03-15 10:20:00'),
(13, 107, 206, 306, 201, '2026-03-15 16:10:00'),
(14, 108, 204, 302, 405, '2026-03-15 10:40:00'),
(15, 109, 205, 304, 403, '2026-03-15 11:05:00'),
(16, 110, 202, 305, 402, '2026-03-15 11:25:00'),

(17, 111, 202, 302, 402, '2026-03-15 10:50:00'),
(18, 111, 203, 308, 202, '2026-03-15 15:20:00'),
(19, 112, 205, 304, 406, '2026-03-15 11:10:00'),
(20, 113, 201, 301, 401, '2026-03-15 11:50:00'),

(21, 114, 204, 305, 405, '2026-03-15 10:35:00'),
(22, 114, 206, 307, 204, '2026-03-15 16:00:00'),
(23, 115, 203, 303, 403, '2026-03-15 11:15:00'),
(24, 116, 201, 301, 406, '2026-03-15 11:55:00'),
(25, 117, 206, 307, 202, '2026-03-15 12:15:00'),

(26, 118, 202, 302, 402, '2026-03-15 10:45:00'),
(27, 118, 203, 308, 202, '2026-03-15 15:45:00'),
(28, 119, 201, 301, 401, '2026-03-15 11:35:00'),
(29, 120, 204, 305, 404, '2026-03-15 12:05:00'),
(30, 121, 205, 304, 405, '2026-03-15 12:25:00'),

(31, 122, 204, 305, 404, '2026-03-15 10:55:00'),
(32, 122, 203, 308, 204, '2026-03-15 16:20:00'),
(33, 123, 202, 302, 402, '2026-03-15 11:45:00'),
(34, 124, 205, 304, 405, '2026-03-15 12:10:00'),
(35, 125, 206, 307, 406, '2026-03-15 12:35:00');

INSERT INTO TransferNote (transferID, noteNo, noteText)
VALUES
(1, 1, 'Survivor moved safely'),
(2, 1, 'No issues during transfer'),
(3, 1, 'Minor survivor; family not yet located'),
(4, 1, 'Survivor reported leg injury'),
(5, 1, 'Transfer completed without incident'),
(6, 1, 'Survivor arrived with temporary identification tag'),
(7, 1, 'Survivor reassigned to hospital for further assessment'),
(8, 1, 'Survivor moved from reunification center to shelter for temporary placement'),
(9, 1, 'Survivor transferred again for medical follow-up and identification support'),

(10, 1, 'Survivor moved from shelter to reunification center for family contact'),
(11, 1, 'Reunited survivor transferred to family reunification center for discharge coordination'),

(12, 1, 'Survivor admitted to North Emergency Shelter'),
(13, 1, 'Survivor later moved to reunification center for family contact'),
(14, 1, 'Minor survivor placed in relief shelter with supervision'),
(15, 1, 'Unidentified survivor taken to medical triage center'),
(16, 1, 'Survivor checked into East Community Shelter'),

(17, 1, 'Minor survivor received intake support at shelter'),
(18, 1, 'Survivor later sent to hospital for follow-up examination'),
(19, 1, 'Survivor routed to triage center after initial field assessment'),
(20, 1, 'Unknown minor survivor transferred to emergency shelter'),

(21, 1, 'Flood survivor placed in relief shelter'),
(22, 1, 'Survivor later transferred to reunification center'),
(23, 1, 'Minor survivor taken to hospital for observation'),
(24, 1, 'Unidentified survivor admitted to emergency shelter'),
(25, 1, 'Reunited survivor processed through reunification center'),

(26, 1, 'Wildfire survivor admitted to East Community Shelter'),
(27, 1, 'Survivor later moved to hospital for respiratory concerns'),
(28, 1, 'Minor survivor transferred to North Emergency Shelter'),
(29, 1, 'Unidentified survivor placed in West Relief Shelter'),
(30, 1, 'Survivor admitted to South Medical Triage Center'),

(31, 1, 'Tornado survivor placed in West Relief Shelter'),
(32, 1, 'Survivor later transferred to hospital for additional treatment'),
(33, 1, 'Minor survivor admitted to East Community Shelter'),
(34, 1, 'Unidentified survivor transferred to triage center'),
(35, 1, 'Survivor routed to reunification center for case follow-up');

INSERT INTO Flag (flagID, userID, survivorID, flagStatus, description, createdAt, category)
VALUES
(1, 311, 101, 'Open', 'Possible duplicate survivor record', '2026-03-15 13:00:00', 'Duplicate Record'),
(2, 312, 102, 'Open', 'Missing identification details', '2026-03-15 13:10:00', 'Missing Information'),
(3, 313, 103, 'Resolved', 'Alias tag confirmed by staff', '2026-03-15 13:20:00', 'Verification'),
(4, 314, 104, 'Open', 'Conflicting transfer note found', '2026-03-15 13:30:00', 'Data Conflict'),
(5, 315, 105, 'Resolved', 'Reunification status confirmed', '2026-03-15 13:40:00', 'Status Review'),
(6, 311, 106, 'Open', 'Unknown minor survivor requires identity follow-up', '2026-03-15 13:50:00', 'Missing Information'),
(7, 312, 109, 'Open', 'Unidentified survivor may match another intake record', '2026-03-15 14:00:00', 'Duplicate Record'),
(8, 313, 116, 'Resolved', 'Temporary alias reviewed and record verified', '2026-03-15 14:10:00', 'Verification');

-- selecting survivors who have been flagged more than once
SELECT survivorID, firstName, lastName
FROM SurvivorRecord
WHERE survivorID IN (
	SELECT survivorID
	FROM Flag
	GROUP BY survivorID, category
HAVING COUNT(*) > 1);

-- Queries for part 3 : 
-- Join query : 
-- This query shows the full transfer timeline for a SPECIFIC surivior (with id = 101) including which facilites they were moved between
-- and who handeld the transfer
SELECT 
    s.survivorID,
    s.firstName,
    s.aliasTag,
    s.status,
    f1.facilityName AS fromFacility,
    f2.facilityName AS toFacility,
    u.firstName AS handledBy,
    t.transferTime
FROM TransferEvent t
JOIN SurvivorRecord s ON t.survivorID = s.survivorID
LEFT JOIN Facility f1 ON t.fromFacilityID = f1.facilityID
JOIN Facility f2 ON t.toFacilityID = f2.facilityID
JOIN Users u ON t.userID = u.userID
WHERE s.survivorID = 101
ORDER BY t.transferTime;

-- OR : 
-- This query shows the full transfer timeline for ALL survivors, ordered by survivor and then by transfer time
SELECT 
    s.survivorID,
    s.firstName,
    s.aliasTag,
    s.status,
    f1.facilityName AS fromFacility,
    f2.facilityName AS toFacility,
    u.firstName AS handledBy,
    t.transferTime
FROM TransferEvent t
JOIN SurvivorRecord s ON t.survivorID = s.survivorID
LEFT JOIN Facility f1 ON t.fromFacilityID = f1.facilityID
JOIN Facility f2 ON t.toFacilityID = f2.facilityID
JOIN Users u ON t.userID = u.userID
ORDER BY s.survivorID, t.transferTime;

-- Division query : 
-- find responders who handled all minor survivors
SELECT u.firstName, u.lastName
FROM Users u
JOIN Responder r ON u.userID = r.userID
WHERE NOT EXISTS (
    SELECT s.survivorID
    FROM SurvivorRecord s
    WHERE s.isMinor = TRUE
    AND NOT EXISTS (
        SELECT t.transferID
        FROM TransferEvent t
        WHERE t.survivorID = s.survivorID
        AND t.userID = u.userID
    )
);

-- OR : *Disaster Specific* 
-- finding responders who handeld ALL MINOR SURVIVORS of Wildfires : 
SELECT u.firstName, u.lastName
FROM Users u
JOIN Responder r ON u.userID = r.userID
WHERE NOT EXISTS (
    SELECT s.survivorID
    FROM SurvivorRecord s
    WHERE s.isMinor = TRUE
    AND s.disasterID = 1
    AND NOT EXISTS (
        SELECT t.transferID
        FROM TransferEvent t
        WHERE t.survivorID = s.survivorID
        AND t.userID = u.userID
    )
);

-- OR : *Disaster Specific* 
-- finding responders who handeld ALL MINOR SURVIVORS of earthquakes : 
SELECT u.firstName, u.lastName
FROM Users u
JOIN Responder r ON u.userID = r.userID
WHERE NOT EXISTS (
    SELECT s.survivorID
    FROM SurvivorRecord s
    WHERE s.isMinor = TRUE
    AND s.disasterID = 2
    AND NOT EXISTS (
        SELECT t.transferID
        FROM TransferEvent t
        WHERE t.survivorID = s.survivorID
        AND t.userID = u.userID
    )
);

-- OR : *Disaster Specific* 
-- finding responders who handeld ALL MINOR SURVIVORS of Floods : 
SELECT u.firstName, u.lastName
FROM Users u
JOIN Responder r ON u.userID = r.userID
WHERE NOT EXISTS (
    SELECT s.survivorID
    FROM SurvivorRecord s
    WHERE s.isMinor = TRUE
    AND s.disasterID = 3
    AND NOT EXISTS (
        SELECT t.transferID
        FROM TransferEvent t
        WHERE t.survivorID = s.survivorID
        AND t.userID = u.userID
    )
);

-- OR : *Disaster Specific* 
-- finding responders who handeld ALL MINOR SURVIVORS of Wildfires : 
-- Finds responders who handled ALL minor survivors across ALL Wildfire disasters
SELECT u.firstName, u.lastName
FROM Users u
JOIN Responder r ON u.userID = r.userID
WHERE NOT EXISTS (
    SELECT s.survivorID
    FROM SurvivorRecord s
    JOIN DisasterEvent d ON s.disasterID = d.disasterID
    WHERE s.isMinor = TRUE
    AND d.disasterType = 'Wildfire'
    AND NOT EXISTS (
        SELECT t.transferID
        FROM TransferEvent t
        WHERE t.survivorID = s.survivorID
        AND t.userID = u.userID
    )
);

-- OR : *Disaster Specific* 
-- finding responders who handeld ALL MINOR SURVIVORS of Tornado : 
SELECT u.firstName, u.lastName
FROM Users u
JOIN Responder r ON u.userID = r.userID
WHERE NOT EXISTS (
    -- is there any MINOR survivor from the earthquake...
    SELECT s.survivorID
    FROM SurvivorRecord s
    WHERE s.isMinor = TRUE
    AND s.disasterID = 5
    AND NOT EXISTS (
        -- ...that this responder did NOT handle?
        SELECT t.transferID
        FROM TransferEvent t
        WHERE t.survivorID = s.survivorID
        AND t.userID = u.userID
    )
);

-- Aggregation Query : 
-- finds number of survivor records for wildfires
SELECT 
    d.disasterID,
    d.location,
    d.disasterDateTime,
    COUNT(s.survivorID) AS totalSurvivors
FROM DisasterEvent d
LEFT JOIN SurvivorRecord s ON d.disasterID = s.disasterID
WHERE d.disasterType = 'Wildfire'
GROUP BY d.disasterID, d.location, d.disasterDateTime
ORDER BY totalSurvivors DESC;

-- finds number of survivor records for earthquakes 
SELECT 
    d.disasterID,
    d.location,
    d.disasterDateTime,
    COUNT(s.survivorID) AS totalSurvivors
FROM DisasterEvent d
LEFT JOIN SurvivorRecord s ON d.disasterID = s.disasterID
WHERE d.disasterType = 'Earthquake'
GROUP BY d.disasterID, d.location, d.disasterDateTime
ORDER BY totalSurvivors DESC;

-- finds number of survivor records for Floods
SELECT 
    d.disasterID,
    d.location,
    d.disasterDateTime,
    COUNT(s.survivorID) AS totalSurvivors
FROM DisasterEvent d
LEFT JOIN SurvivorRecord s ON d.disasterID = s.disasterID
WHERE d.disasterType = 'Flood'
GROUP BY d.disasterID, d.location, d.disasterDateTime
ORDER BY totalSurvivors DESC;

-- finds number of survivor records for Tornados 
SELECT 
    d.disasterID,
    d.location,
    d.disasterDateTime,
    COUNT(s.survivorID) AS totalSurvivors
FROM DisasterEvent d
LEFT JOIN SurvivorRecord s ON d.disasterID = s.disasterID
WHERE d.disasterType = 'Tornado'
GROUP BY d.disasterID, d.location, d.disasterDateTime
ORDER BY totalSurvivors DESC;

/*
-- example login query:
-- This query checks whether a user exists with the entered email and password.
-- It also determines the user's role by checking which subtype table
-- (Responder, FacilityStaff, or Reviewer) contains that userID.
-- For this demo, passwords are stored as plain text for simplicity.
-- In a future version, this can be improved by storing hashed passwords instead of plain text
-- and verifying them in the backend using a library such as bcrypt.

SELECT 
    u.userID,
    u.firstName,
    u.lastName,
    u.userEmail,
    CASE
        WHEN r.userID IS NOT NULL THEN 'Responder'
        WHEN fs.userID IS NOT NULL THEN 'FacilityStaff'
        WHEN rv.userID IS NOT NULL THEN 'Reviewer'
    END AS userRole
FROM Users u
LEFT JOIN Responder r ON u.userID = r.userID
LEFT JOIN FacilityStaff fs ON u.userID = fs.userID
LEFT JOIN Reviewer rv ON u.userID = rv.userID
WHERE u.userEmail = ?
  AND u.userPassword = ?;

-- same query but different implementation: 

SELECT 
    u.userID,
    u.firstName,
    u.lastName,
    u.userEmail,
    CASE
        WHEN EXISTS (SELECT 1 FROM Responder r WHERE r.userID = u.userID) THEN 'Responder'
        WHEN EXISTS (SELECT 1 FROM FacilityStaff fs WHERE fs.userID = u.userID) THEN 'FacilityStaff'
        WHEN EXISTS (SELECT 1 FROM Reviewer rv WHERE rv.userID = u.userID) THEN 'Reviewer'
    END AS userRole
FROM Users u
WHERE u.userEmail = ?
  AND u.userPassword = ?;
*/