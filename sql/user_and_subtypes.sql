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

