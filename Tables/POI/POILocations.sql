CREATE TABLE poi.POILocations (
    POILocationID INT IDENTITY(1,1) PRIMARY KEY,
    POIName VARCHAR(255) NULL, 
    LocationID INT NOT NULL,
    GeometryType NVARCHAR(255) NULL,
    Polygon_WKT NVARCHAR(MAX) NULL,
    PolygonGeom geometry NULL,
    FOREIGN KEY (LocationID) REFERENCES poi.Locations(LocationID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
CREATE NONCLUSTERED INDEX IX_POILocations_LocationID ON poi.POILocations (LocationID);
