
CREATE DATABASE IF NOT EXISTS transfer_db;
USE transfer_db; 

CREATE TABLE Organization (
    orgID INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT orgPK PRIMARY KEY (orgID)
);

CREATE TABLE Facility (
    facilityID INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(150) NOT NULL,
    orgID INT NOT NULL,
    CONSTRAINT facilityPK PRIMARY KEY (facilityID),
    CONSTRAINT facilityOrgFK FOREIGN KEY (orgID) REFERENCES Organization(orgID)
);

CREATE TABLE TransferEvent (
    transferID INT PRIMARY KEY,
    SurvivorID INT, 
    toFacilityID INT,
    userID INT,
    fromFacilityID INT,
    transferTime TIME,

    FOREIGN KEY(SurvivorID) references SurvivorRecord(SurvivorID),
    FOREIGN KEY(toFacilityID) references Facility(toFacilityID),
    FOREIGN KEY(userID) references User(userID)

);

CREATE TABLE TransferNote (
    noteNo INT PRIMARY KEY,
    transferID INT,
    witnessName VARCHAR(150),
    noteText TEXT,
    tagSeen VARCHAR(100),

    FOREIGN KEY(transferID) references TransferEvent(transferID)
)



