CREATE TABLE poi.OperationHour (
    OperationHourID INT IDENTITY(1,1) PRIMARY KEY,
    DayInWeek VARCHAR(20) NOT NULL,
    OpeningHours VARCHAR(50) NOT NULL,
    ClosingHours VARCHAR(50) NOT NULL,
    LocationID INT NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES poi.Locations(LocationID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
CREATE NONCLUSTERED INDEX IX_OperationHour_LocationID ON poi.OperationHour (LocationID);
