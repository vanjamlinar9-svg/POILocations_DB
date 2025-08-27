CREATE TABLE poi.Region (
    RegionID INT IDENTITY(1,1) PRIMARY KEY,
    RegionCode VARCHAR(50) NOT NULL,
    RegionName VARCHAR(255) NOT NULL,
    CountryID INT NOT NULL,
    CONSTRAINT UQ_Region UNIQUE (RegionCode, CountryID),
    FOREIGN KEY (CountryID) REFERENCES poi.Country(CountryID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
CREATE NONCLUSTERED INDEX IX_Region_CountryID ON poi.Region (CountryID);