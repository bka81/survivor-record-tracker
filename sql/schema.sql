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