--TransferEvent dummy data
INSERT INTO TransferEvent(transferID, SurvivorID, toFacilityID, userID, fromFacilityID, transferTime)
VALUES
(1, 101, 201, 301, 401, '10:00:00'),
(2, 102, 202, 302, 402, '11:30:00'),
(3, 103, 203, 303, 403, '11:40:00'),
(4, 104, 204, 304, 404, '11:45:00'),
(5, 105, 205, 305, 405, '12:00:00'),
(6, 106, 206, 306, 406, '12:02:00');


-- TransferNote dummy data
INSERT INTO TransferNote (noteNo, transferID, witnessName, noteText, tagSeen)
VALUES
(1, 1, 'Alice', 'Survivor moved safely', 'Tiger'),
(2, 2, 'Bob', 'No issues', 'Eagle');
(3, 3, 'Charlie', 'Missing parents', 'Horse'),
(4, 4, 'Derby', 'Hurt leg', 'Mouse'),
(5, 5, 'Mel', 'No issues', 'Bat'),
(6, ,6 'Lila', 'Lost', 'Rat');