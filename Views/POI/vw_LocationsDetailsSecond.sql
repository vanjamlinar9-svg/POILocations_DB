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
