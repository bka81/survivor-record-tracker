CREATE DATABASE IF NOT EXISTS transfer_db;
USE transfer_db; 

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


