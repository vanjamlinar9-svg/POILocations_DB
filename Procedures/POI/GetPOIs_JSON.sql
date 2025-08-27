CREATE PROCEDURE poi.GetPOIs_JSON
    @SearchCriteria NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    
        DECLARE @CountryCode NVARCHAR(10),
                @RegionCode NVARCHAR(10),
                @CityName NVARCHAR(100),
                @CenterLat FLOAT,
                @CenterLon FLOAT,
                @RadiusMeters FLOAT,
                @PolygonWKT NVARCHAR(MAX),
                @POICategory NVARCHAR(100),
                @POIName NVARCHAR(255);

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
        WHERE (@CountryCode IS NULL OR  UPPER(vd.CountryCode) = UPPER(@CountryCode))
          AND (@RegionCode IS NULL OR  UPPER(vd.RegionCode) = UPPER(@RegionCode))
          AND (@CityName IS NULL OR  UPPER(vd.CityName) LIKE '%' + UPPER(@CityName) + '%')
          AND (@POICategory IS NULL OR  UPPER(vd.CategoryName) LIKE '%' + UPPER(@POICategory) + '%')
          AND (@POIName IS NULL OR  UPPER(p.POIName) LIKE '%' + UPPER(@POIName) + '%')
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
