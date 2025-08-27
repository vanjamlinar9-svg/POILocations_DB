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
