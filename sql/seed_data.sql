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

INSERT INTO Users (userID, firstName, lastName, userEmail, userPhoneNo)
VALUES
(301, 'Amina', 'Khan', 'amina.khan@example.com', '604-111-1001'),
(302, 'Daniel', 'Lee', 'daniel.lee@example.com', '604-111-1002'),
(303, 'Sara', 'Patel', 'sara.patel@example.com', '604-111-1003'),
(304, 'Omar', 'Chen', 'omar.chen@example.com', '604-111-1004'),
(305, 'Lila', 'Brown', 'lila.brown@example.com', '604-111-1005'),
(306, 'Maya', 'Singh', 'maya.singh@example.com', '604-111-1006'),
(307, 'Noah', 'Wilson', 'noah.wilson@example.com', '604-111-1007'),
(308, 'Eva', 'Garcia', 'eva.garcia@example.com', '604-111-1008'),
(309, 'Ibrahim', 'Ali', 'ibrahim.ali@example.com', '604-111-1009'),
(310, 'Chloe', 'Martin', 'chloe.martin@example.com', '604-111-1010'),
(311, 'Zara', 'Ahmed', 'zara.ahmed@example.com', '604-111-1011'),
(312, 'Ethan', 'Clark', 'ethan.clark@example.com', '604-111-1012'),
(313, 'Hana', 'Yusuf', 'hana.yusuf@example.com', '604-111-1013'),
(314, 'Leo', 'Turner', 'leo.turner@example.com', '604-111-1014'),
(315, 'Nina', 'Scott', 'nina.scott@example.com', '604-111-1015');

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
(104, 'Chris', 'Taylor', 'Mouse', FALSE, 'Active', 5),
(105, 'Mina', 'Ali', 'Bat', FALSE, 'Reunited', 2),
(106, NULL, NULL, 'Unknown2', TRUE, 'Unknown', 2);

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
(9, 106, 203, 303, 204, '2026-03-15 15:00:00');

INSERT INTO TransferNote (transferID, noteNo, noteText)
VALUES
(1, 1, 'Survivor moved safely'),
(2, 1, 'No issues during transfer'),
(3, 1, 'Minor survivor; family not yet located'),
(4, 1, 'Survivor reported leg injury'),
(5, 1, 'Transfer completed without incident'),
(6, 1, 'Survivor arrived with temporary identification tag');

INSERT INTO Flag (flagID, userID, survivorID, flagStatus, description, createdAt, category)
VALUES
(1, 311, 101, 'Open', 'Possible duplicate survivor record', '2026-03-15 13:00:00', 'Duplicate Record'),
(2, 312, 102, 'Open', 'Missing identification details', '2026-03-15 13:10:00', 'Missing Information'),
(3, 313, 103, 'Resolved', 'Alias tag confirmed by staff', '2026-03-15 13:20:00', 'Verification'),
(4, 314, 104, 'Open', 'Conflicting transfer note found', '2026-03-15 13:30:00', 'Data Conflict'),
(5, 315, 105, 'Resolved', 'Reunification status confirmed', '2026-03-15 13:40:00', 'Status Review'),
(6, 311, 106, 'Open', 'Unknown minor survivor requires identity follow-up', '2026-03-15 13:50:00', 'Missing Information'),
(7, 312, 101, 'Open', 'Another possible duplicate entry reported by shelter staff', '2026-03-15 14:00:00', 'Duplicate Record'),
(8, 313, 102, 'Resolved', 'Additional missing ID concern logged during review', '2026-03-15 14:10:00', 'Missing Information');
