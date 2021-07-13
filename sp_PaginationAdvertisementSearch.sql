CREATE PROCEDURE sp_PaginationAdvertisementSearch(

	@textSearch NVARCHAR(255)

)

AS BEGIN

	SELECT Count(*) FROM Advertisements AS a
        JOIN AdvertisementTypes on
            a.messageTypeID = AdvertisementTypes.advertisementTypeID
        WHERE (a.startDate LIKE @textSearch) OR (a.endDate LIKE @textSearch) OR
              (AdvertisementTypes.description LIKE @textSearch) OR 
              (a.createdDate LIKE @textSearch) OR
              (a.lastUpdatedBy LIKE @textSearch)OR
              (a.message LIKE @textSearch) OR
              (a.status LIKE @textSearch)

END