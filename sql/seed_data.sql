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
