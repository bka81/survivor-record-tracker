CREATE DATABASE IF NOT EXISTS transfer_db;
USE transfer_db; 

CREATE TABLE Users(
	userID INT PRIMARY KEY,
	firstName VARCHAR(100) NOT NULL,
	lastName VARCHAR(100) NOT NULL,
	userEmail VARCHAR(100) NOT NULL,
	userPhoneNo VARCHAR(20)
);

CREATE TABLE Responder(
	userID INT PRIMARY KEY,
	orgID INT NOT NULL,
	CONSTRAINT responder_user_fk FOREIGN KEY (userID) REFERENCES Users(userID),
	CONSTRAINT responder_org_fk FOREIGN KEY (orgID) REFERENCES Organization(orgID)
);

CREATE TABLE FacilityStaff(
	userID INT PRIMARY KEY,
	facilityID INT NOT NULL,
	CONSTRAINT facilityStaff_user_fk FOREIGN KEY (userID) REFERENCES Users(userID),
	CONSTRAINT facilityStaff_facility_fk FOREIGN KEY (facilityID) REFERENCES Facility(facilityID)
);

CREATE TABLE Reviewer(
	userID INT PRIMARY KEY,
	CONSTRAINT reviewer_user_fk FOREIGN KEY (userID) REFERENCES Users(userID)
);

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
    SurvivorID INT NOT NULL, 
    toFacilityID INT NOT NULL,
    userID INT NOT NULL,
    fromFacilityID INT,
    transferTime TIME NOT NULL,

    FOREIGN KEY(SurvivorID) references SurvivorRecord(SurvivorID),
    FOREIGN KEY(toFacilityID) references Facility(toFacilityID),
    FOREIGN KEY(userID) references User(userID)

);

CREATE TABLE TransferNote (
    noteNo INT PRIMARY KEY NOT NULL,
    transferID INT NOT NULL,
    witnessName VARCHAR(150),
    noteText TEXT,
    tagSeen VARCHAR(100),

    FOREIGN KEY(transferID) references TransferEvent(transferID)
);

CREATE TABLE SurvivorRecord (
	survivorID INT PRIMARY KEY,
	aliasTag VARCHAR(100), 
	isMinor BOOLEAN NOT NULL, 
	currentFacilityLocation INT, 
	status VARCHAR(50) NOT NULL,
	
	FOREIGN KEY(currentFacilityLocation) REFERENCES Facility(facilityID), 
	CONSTRAINT check_status CHECK(status IN ('Active', 'Reunited', 'Deceased', )
	);
	
CREATE TABLE Flag (
	flagID INT PRIMARY KEY, 
	userID INT NOT NULL, 
	survivorID INT NOT NULL, 
	status VARCHAR(50) NOT NULL, 
	description VARCHAR(255), 
	category VARCHAR(100) NOT NULL,
	
	CONSTRAINT responder_user_fk FOREIGN KEY (userID) REFERENCES Users(userID)
	CONSTRAINT facilityStaff_facility_fk FOREIGN KEY (facilityID) REFERENCES Facility(facilityID)
	);



