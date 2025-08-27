CREATE TABLE poi.Locations (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    SourceLocationId VARCHAR(255) NOT NULL,
    LocationName NVARCHAR(2000) NOT NULL,
    Latitude DECIMAL(9,6) NOT NULL,
    Longitude DECIMAL(9,6) NOT NULL,
    ParentLocationID INT NULL,
    PostalCodeID INT NOT NULL,
    CategoryID INT NULL,
    SubCategoryID INT NULL,
    CONSTRAINT UQ_Location UNIQUE (LocationName, PostalCodeID, Latitude, Longitude),
    FOREIGN KEY (ParentLocationID) REFERENCES poi.Locations(LocationID),
    FOREIGN KEY (PostalCodeID) REFERENCES poi.PostalCode(PostalCodeID),
    FOREIGN KEY (CategoryID) REFERENCES poi.Category(CategoryID),
    FOREIGN KEY (SubCategoryID) REFERENCES poi.SubCategory(SubCategoryID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
CREATE NONCLUSTERED INDEX IX_Locations_PostalCodeID ON poi.Locations (PostalCodeID);
CREATE NONCLUSTERED INDEX IX_Locations_CategoryID   ON poi.Locations (CategoryID);
CREATE NONCLUSTERED INDEX IX_Locations_SubCategoryID ON poi.Locations (SubCategoryID);
