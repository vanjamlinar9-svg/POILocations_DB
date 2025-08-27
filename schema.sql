-- db, schema
CREATE DATABASE POI_Locations;
GO

ALTER DATABASE POI_Locations SET COMPATIBILITY_LEVEL = 150;  
GO

USE POI_Locations;
GO

CREATE SCHEMA poi;
GO

/*
DROP TABLE IF EXISTS poi.SourceData;
DROP TABLE IF EXISTS poi.POILocations;
DROP TABLE IF EXISTS poi.OperationHour;
DROP TABLE IF EXISTS poi.LocationTag;
DROP TABLE IF EXISTS poi.Locations;
DROP TABLE IF EXISTS poi.Tag;
DROP TABLE IF EXISTS poi.Subcategory;
DROP TABLE IF EXISTS poi.Category;
DROP TABLE IF EXISTS poi.PostalCode;
DROP TABLE IF EXISTS poi.City;
DROP TABLE IF EXISTS poi.Region;
DROP TABLE IF EXISTS poi.Country;
*/
    
-- tables
CREATE TABLE poi.Country (
    CountryID INT IDENTITY(1,1) PRIMARY KEY,
    CountryCode VARCHAR(10) NOT NULL UNIQUE,
    CountryName VARCHAR(255) NOT NULL UNIQUE,
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);

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

CREATE TABLE poi.City (
    CityID INT IDENTITY(1,1) PRIMARY KEY,
    CityName VARCHAR(255) NOT NULL,
    RegionID INT NOT NULL,
    CONSTRAINT UQ_City UNIQUE (CityName, RegionID),
    FOREIGN KEY (RegionID) REFERENCES poi.Region(RegionID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
CREATE NONCLUSTERED INDEX IX_City_RegionID   ON poi.City (RegionID);

CREATE TABLE poi.PostalCode (
    PostalCodeID INT IDENTITY(1,1) PRIMARY KEY,
    PostalCode VARCHAR(20) NOT NULL,
    CityID INT NOT NULL,
    CONSTRAINT UQ_PostalCode UNIQUE (PostalCode, CityID),
    FOREIGN KEY (CityID) REFERENCES poi.City(CityID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
CREATE NONCLUSTERED INDEX IX_PostalCode_CityID ON poi.PostalCode (CityID);

CREATE TABLE poi.Category (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(255) NOT NULL UNIQUE,
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);

CREATE TABLE poi.Subcategory (
    SubcategoryID INT IDENTITY(1,1) PRIMARY KEY,
    SubcategoryName VARCHAR(255) NOT NULL,
    CategoryID INT NOT NULL,
    CONSTRAINT UQ_Subcategory UNIQUE (SubcategoryName, CategoryID),
    FOREIGN KEY (CategoryID) REFERENCES poi.Category(CategoryID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);

CREATE TABLE poi.Tag (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    TagName VARCHAR(255) NOT NULL UNIQUE,
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);

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

CREATE TABLE poi.POILocations (
    POILocationID INT IDENTITY(1,1) PRIMARY KEY,
    POIName VARCHAR(255) NULL, 
    LocationID INT NOT NULL,
    --SubCategoryID INT NULL,
    GeometryType NVARCHAR(255) NULL,
    Polygon_WKT NVARCHAR(MAX) NULL,
    PolygonGeom geometry NULL,
    FOREIGN KEY (LocationID) REFERENCES poi.Locations(LocationID),
    --FOREIGN KEY (SubCategoryID) REFERENCES poi.SubCategory(SubCategoryID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
CREATE NONCLUSTERED INDEX IX_POILocations_LocationID ON poi.POILocations (LocationID);

-- views
CREATE OR ALTER VIEW poi.vw_LocationsDetails AS
SELECT 
    loc.locationId,
    loc.locationName,
    parentloc.locationName as ParentName,
    loc.Latitude,
    loc.Longitude,
    pc.PostalCode,
    c.CityName,
    r.regionCode,
    cc.countryCode,
    STRING_AGG(t.tagName, ', ') WITHIN GROUP (ORDER BY t.tagName) AS CategoryTags
FROM poi.LOCATIONS loc
LEFT JOIN poi.Locations parentloc ON loc.ParentLocationID = parentloc.LocationID
JOIN poi.PostalCode pc ON pc.postalCodeId = loc.PostalCodeId
JOIN poi.City c ON c.CityId = pc.CityId
JOIN poi.Region r ON r.RegionId = c.RegionId
JOIN poi.Country cc ON cc.CountryId = r.CountryId
LEFT JOIN poi.LocationTag lt ON lt.locationId = loc.LocationID
LEFT JOIN poi.Tag t ON t.tagId = lt.tagId
GROUP BY 
    loc.locationId,
    loc.locationName,
    parentloc.locationName,
    loc.Latitude,
    loc.Longitude,
    pc.PostalCode,
    c.CityName,
    r.regionCode,
    cc.countryCode;
GO

--
CREATE OR ALTER VIEW poi.vw_LocationsDetailsSecond AS
WITH Tags AS (
    SELECT 
        l.LocationID,
        STRING_AGG(t.TagName, ', ') AS CategoryTags
    FROM poi.Locations l
    LEFT JOIN poi.LocationTag lt
        ON lt.LocationID = l.LocationID
    LEFT JOIN poi.Tag t
        ON t.TagID = lt.TagID
    GROUP BY l.LocationID
),
OpeningHoursAgg AS (
    SELECT
        l.LocationID,
        STRING_AGG(
            CASE 
                WHEN oh.DayInWeek IS NOT NULL 
                  OR oh.OpeningHours IS NOT NULL 
                  OR oh.ClosingHours IS NOT NULL
                THEN CONCAT(oh.DayInWeek, ':', oh.OpeningHours,'-',oh.ClosingHours)
                ELSE NULL
            END, '; ')
            WITHIN GROUP (ORDER BY oh.DayInWeek, oh.OpeningHours) AS OpeningHours
    FROM poi.Locations l
    LEFT JOIN poi.OperationHour oh
        ON oh.LocationID = l.LocationID
    GROUP BY l.LocationID
)
SELECT
    l.LocationID,
    l.LocationName,
    parentloc.LocationName AS ParentName,
    l.Latitude,
    l.Longitude,
    pc.PostalCode,
    c.CityName,
    r.RegionCode,
    cc.CountryCode,
    cat.CategoryName,
    sc.SubCategoryName,
    t.CategoryTags,
    ohs.OpeningHours
FROM poi.Locations l
LEFT JOIN poi.Locations parentloc
    ON l.ParentLocationID = parentloc.LocationID
JOIN poi.PostalCode pc
    ON pc.PostalCodeID = l.PostalCodeID
JOIN poi.City c
    ON c.CityID = pc.CityID
JOIN poi.Region r
    ON r.RegionID = c.RegionID
JOIN poi.Country cc
    ON cc.CountryID = r.CountryID
LEFT JOIN Tags t
    ON t.LocationID = l.LocationID
LEFT JOIN OpeningHoursAgg ohs
    ON ohs.LocationID = l.LocationID
LEFT JOIN poi.SubCategory sc
    ON sc.SubCategoryID = l.SubCategoryID
LEFT JOIN poi.Category cat
    ON cat.CategoryID = l.CategoryID;
GO

-- Procedures
CREATE OR ALTER   PROCEDURE poi.GetPOIs_GeoJSON
    @SearchCriteria NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @CountryCode VARCHAR(10),
                @RegionCode VARCHAR(10),
                @CityName VARCHAR(100),
                @CenterLat FLOAT,
                @CenterLon FLOAT,
                @RadiusMeters FLOAT,
                @PolygonWKT NVARCHAR(MAX),
                @POICategory VARCHAR(100),
                @POIName VARCHAR(255);

        SELECT 
            @CountryCode = JSON_VALUE(@SearchCriteria, '$.CountryCode'),
            @RegionCode = JSON_VALUE(@SearchCriteria, '$.RegionCode'),
            @CityName = JSON_VALUE(@SearchCriteria, '$.CityName'),
            @CenterLat = TRY_CAST(JSON_VALUE(@SearchCriteria, '$.CenterLat') AS FLOAT),
            @CenterLon = TRY_CAST(JSON_VALUE(@SearchCriteria, '$.CenterLon') AS FLOAT),
            @RadiusMeters = TRY_CAST(JSON_VALUE(@SearchCriteria, '$.RadiusMeters') AS FLOAT),
            @PolygonWKT = JSON_VALUE(@SearchCriteria, '$.PolygonWKT'),
            @POICategory = JSON_VALUE(@SearchCriteria, '$.POICategory'),
            @POIName = JSON_VALUE(@SearchCriteria, '$.POIName');

        SELECT
            (
                SELECT 
                    'FeatureCollection' AS [type],
                    (
                        SELECT 
                            'Feature' AS [type],
                            JSON_QUERY(
                                REPLACE(REPLACE(REPLACE(p.PolygonGeom.ToString(), 'POLYGON (', '{"type":"Polygon","coordinates":['), ')', ']}'), ',', '],[')
                            ) AS geometry,
                            (
                                SELECT
                                    p.POILocationID AS Id,
                                    vd.LocationName,
                                    vd.ParentName,
                                    vd.CountryCode,
                                    vd.RegionCode,
                                    vd.CityName,
                                    vd.CategoryName AS Category,
                                    vd.SubCategoryName AS SubCategory,
                                    vd.PostalCode,
                                    vd.OpeningHours
                                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                            ) AS properties
                        FROM 
                            poi.POILocations p
                        JOIN 
                            poi.vw_LocationsDetailsSecond vd ON vd.LocationID = p.LocationID
                        WHERE 
                            (@CountryCode IS NULL OR vd.CountryCode = @CountryCode)
                            AND (@RegionCode IS NULL OR vd.RegionCode = @RegionCode)
                            AND (@CityName IS NULL OR vd.CityName LIKE '%' + @CityName + '%')
                            AND (@POICategory IS NULL OR vd.CategoryName LIKE '%' + @POICategory + '%')
                            AND (@POIName IS NULL OR p.POIName LIKE '%' + @POIName + '%')
                            AND (
                                @PolygonWKT IS NULL OR p.PolygonGeom.STIntersects(geometry::STGeomFromText(@PolygonWKT, 4326)) = 1
                            )
                            AND (
                                (@CenterLat IS NULL OR @CenterLon IS NULL)
                                OR (p.PolygonGeom.STDistance(geometry::Point(@CenterLat, @CenterLon, 4326)) <= ISNULL(@RadiusMeters, 200))
                            )
                        FOR JSON PATH
                    ) AS features
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            ) AS GeoJson;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Error in GetPOIs_GeoJSON: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
GO;
--

CREATE   PROCEDURE poi.GetPOIs_JSON
    @SearchCriteria NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    
        DECLARE @CountryCode VARCHAR(10),
                @RegionCode VARCHAR(10),
                @CityName VARCHAR(100),
                @CenterLat FLOAT,
                @CenterLon FLOAT,
                @RadiusMeters FLOAT,
                @PolygonWKT NVARCHAR(MAX),
                @POICategory VARCHAR(100),
                @POIName VARCHAR(255);

        SELECT 
            @CountryCode = JSON_VALUE(@SearchCriteria, '$.CountryCode'),
            @RegionCode  = JSON_VALUE(@SearchCriteria, '$.RegionCode'),
            @CityName    = JSON_VALUE(@SearchCriteria, '$.CityName'),
            @CenterLat   = TRY_CAST(JSON_VALUE(@SearchCriteria, '$.CenterLat') AS FLOAT),
            @CenterLon   = TRY_CAST(JSON_VALUE(@SearchCriteria, '$.CenterLon') AS FLOAT),
            @RadiusMeters= TRY_CAST(JSON_VALUE(@SearchCriteria, '$.RadiusMeters') AS FLOAT),
            @PolygonWKT  = JSON_VALUE(@SearchCriteria, '$.PolygonWKT'),
            @POICategory = JSON_VALUE(@SearchCriteria, '$.POICategory'),
            @POIName     = JSON_VALUE(@SearchCriteria, '$.POIName');

        SELECT
            p.POILocationID AS Id,
            vd.LocationName,
            vd.ParentName,
            vd.CountryCode,
            vd.RegionCode,
            vd.CityName,
            vd.Latitude,
            vd.Longitude,
            vd.CategoryName AS Category,
            vd.SubCategoryName AS SubCategory,
            p.Polygon_WKT,
            vd.PostalCode,
            vd.OpeningHours
        FROM poi.POILocations p
        JOIN poi.vw_LocationsDetailsSecond vd
            ON vd.LocationID = p.LocationID
        CROSS APPLY (
            SELECT CASE 
                WHEN @CenterLat IS NOT NULL AND @CenterLon IS NOT NULL
                THEN p.PolygonGeom.STDistance(geometry::Point(@CenterLat, @CenterLon, 4326))
                ELSE NULL
            END AS DistanceToCenter
        ) d
        WHERE (@CountryCode IS NULL OR vd.CountryCode = @CountryCode)
          AND (@RegionCode IS NULL OR vd.RegionCode = @RegionCode)
          AND (@CityName IS NULL OR vd.CityName LIKE '%' + @CityName + '%')
          AND (@POICategory IS NULL OR vd.CategoryName LIKE '%' + @POICategory + '%')
          AND (@POIName IS NULL OR p.POIName LIKE '%' + @POIName + '%')
          AND (
                @PolygonWKT IS NULL
                OR p.PolygonGeom.STIntersects(geometry::STGeomFromText(@PolygonWKT, 4326)) = 1
              )
          AND (d.DistanceToCenter IS NULL OR d.DistanceToCenter <= ISNULL(@RadiusMeters,200));

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Error in GetPOIs_JSON: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;

GO

