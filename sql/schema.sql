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
    CONSTRAINT transferNote_transfer_fk 
        FOREIGN KEY (transferID) REFERENCES TransferEvent(transferID) ON DELETE CASCADE
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

ALTER TABLE TransferNote
DROP FOREIGN KEY transferNote_transfer_fk;

ALTER TABLE TransferNote
ADD CONSTRAINT transferNote_transfer_fk
FOREIGN KEY (transferID)
REFERENCES TransferEvent(transferID)
ON DELETE CASCADE;

