CREATE TABLE poi.LocationTag (
    LocationTagID INT IDENTITY(1,1) PRIMARY KEY,
    TagID INT NOT NULL,
    LocationID INT NOT NULL,
    CONSTRAINT UQ_LocationTag UNIQUE (TagID, LocationID),
    FOREIGN KEY (TagID) REFERENCES poi.Tag(TagID),
    FOREIGN KEY (LocationID) REFERENCES poi.Locations(LocationID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
CREATE NONCLUSTERED INDEX IX_LocationTag_LocationID ON poi.LocationTag (LocationID);
CREATE NONCLUSTERED INDEX IX_LocationTag_TagID      ON poi.LocationTag (TagID);
