CREATE DATABASE IF NOT EXISTS transfer_db;
USE transfer_db;

CREATE TABLE Users (
    userID INT PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    userEmail VARCHAR(100) NOT NULL UNIQUE,
    userPhoneNo VARCHAR(20) NOT NULL
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

CREATE TABLE SurvivorRecord (
    survivorID INT PRIMARY KEY,
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    aliasTag VARCHAR(100),
    isMinor BOOLEAN NOT NULL,
    status VARCHAR(50) NOT NULL,
    CONSTRAINT check_status CHECK (status IN ('Active', 'Reunited', 'Deceased', 'Unknown', 'Closed'))
);

CREATE TABLE TransferEvent (
    transferID INT PRIMARY KEY,
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
    flagID INT PRIMARY KEY,
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