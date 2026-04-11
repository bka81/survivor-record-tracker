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


-- Update survivor status
UPDATE SurvivorRecord
SET status = 'Reunited'
WHERE survivorID = 101;

-- Update flag status
UPDATE Flag
SET flagStatus = 'Resolved'
WHERE flagID = 1;

-- Delete with cascade demo
SELECT * 
FROM TransferEvent
WHERE transferID = 1;

SELECT * 
FROM TransferNote
WHERE transferID = 1;

DELETE FROM TransferEvent
WHERE transferID = 1;

SELECT * 
FROM TransferNote
WHERE transferID = 1;

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
