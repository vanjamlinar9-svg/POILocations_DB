INSERT INTO poi.Country (CountryCode, CountryName)
VALUES 
('US', 'United States of America'),
('DE', 'Germany'),
('RS', 'Serbia');
--

INSERT INTO poi.Region (RegionCode, RegionName, CountryID)
SELECT tt.RegionCode, tt.RegionName, c.CountryID
FROM (VALUES
    ('NJ', 'New Jersey'),
    ('NY', 'New York'),
    ('MD', 'Maryland'),
    ('AZ', 'Arizona'),
    ('MI', 'Michigan'),
    ('IL', 'Illinois'),
    ('OR', 'Oregon')
) tt(RegionCode, RegionName)
JOIN poi.Country c ON c.CountryCode = 'US';
--

INSERT INTO poi.City (CityName, RegionID)
SELECT 'Phoenix', RegionID
FROM poi.Region;
--

SELECT 
    c.CityID,
    r.RegionCode
FROM poi.City c
JOIN poi.Region r ON c.RegionID = r.RegionID
ORDER BY r.RegionCode;

--

INSERT INTO poi.PostalCode (PostalCode, CityID)
SELECT DISTINCT 
    sd.PostalCode,
    c.CityID
FROM poi.sourceData sd
JOIN poi.Region r
    ON r.RegionCode = sd.Region
JOIN poi.City c
    ON c.CityName = sd.City
   AND c.RegionID = r.RegionID
WHERE sd.PostalCode IS NOT NULL;

--

--DELETE FROM poi.Category ;
INSERT INTO poi.Category (CategoryName)
SELECT DISTINCT topCategory
FROM poi.SourceData
WHERE topCategory IS NOT NULL;
--169 records

--
INSERT INTO poi.Subcategory (SubcategoryName, CategoryID)
SELECT DISTINCT subCategory, c.CategoryID
FROM poi.SourceData s
JOIN poi.Category c ON s.topCategory = c.CategoryName
WHERE subCategory IS NOT NULL;
--299

--
INSERT INTO poi.Tag (TagName)
SELECT DISTINCT LTRIM(RTRIM(value)) AS TagName
FROM poi.SourceData s
CROSS APPLY STRING_SPLIT(s.CategoryTags, ',')
WHERE s.CategoryTags IS NOT NULL;
--764

--DELETE FROM poi.Locations ;
INSERT INTO poi.Locations (SourceLocationId, LocationName, Latitude, Longitude, ParentLocationID, PostalCodeID)
SELECT DISTINCT
    s.id,
    s.LocationName,
    s.latitude,
    s.longitude,
    NULL,
    p.PostalCodeID
FROM poi.SourceData s
JOIN poi.PostalCode p ON s.postalCode = p.PostalCode
WHERE s.LocationName IS NOT NULL;

-- 
UPDATE loc
SET loc.ParentLocationID = (SELECT l_parent.LocationId FROM poi.Locations l_parent WHERE l_parent.SourceLocationId = s.parentId)
FROM poi.Locations loc
JOIN poi.SourceData s ON loc.SourceLocationId = s.id;

UPDATE loc
SET 
    loc.CategoryID = c.CategoryID,
    loc.SubCategoryID = sc.SubCategoryID
FROM poi.Locations loc
JOIN poi.SourceData s 
    ON loc.SourceLocationID = s.ID
LEFT JOIN poi.SubCategory sc
    ON sc.SubCategoryName = s.SubCategory
LEFT JOIN poi.Category c
    ON c.CategoryID = sc.CategoryID
       OR c.CategoryName = s.TopCategory;

--
--DELETE FROM poi.LocationTag ;
INSERT INTO poi.LocationTag (LocationID, TagID)
SELECT DISTINCT
    loc.LocationID,
    t.TagID
FROM poi.SourceData s
JOIN poi.Locations loc
    ON loc.SourceLocationId = s.id 
CROSS APPLY STRING_SPLIT(s.categoryTags, ',') AS splitTag
JOIN poi.Tag t
    ON t.TagName = LTRIM(RTRIM(splitTag.value));

--DELETE FROM poi.OperationHour ;
INSERT INTO poi.OperationHour (DayInWeek, OpeningHours, ClosingHours, LocationID)
SELECT
    Days.[key] AS DayInWeek,
    JSON_Value(TimeSlot.value, '$[0]') AS OpeningHours,
    JSON_Value(TimeSlot.value, '$[1]') AS ClosingHours,
    loc.LocationID
FROM poi.SourceData s
JOIN poi.Locations loc
    ON loc.SourceLocationId = s.id
CROSS APPLY OPENJSON(s.operationhours) AS Days       
CROSS APPLY OPENJSON(Days.value) AS TimeSlot          
WHERE JSON_Value(TimeSlot.value, '$[0]') IS NOT NULL; 

UPDATE poi.SourceData
SET operationhours = NULL
WHERE operationhours = 'b'; --proper data overriden

--DELETE FROM poi.POILocations;
INSERT INTO poi.POILocations (
    LocationID,
    GeometryType,
    Polygon_WKT,
    PolygonGeom
)
SELECT
    l.LocationID,
    s.GeometryType,
    s.Polygon_WKT,
    CASE 
        WHEN s.Polygon_WKT IS NOT NULL 
        THEN geometry::STGeomFromText(s.Polygon_WKT, 4326)
        ELSE NULL
    END
FROM poi.SourceData s
JOIN poi.Locations l 
    ON l.SourceLocationID = s.Id
