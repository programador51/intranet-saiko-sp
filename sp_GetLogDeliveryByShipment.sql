USE [TripEvent_PRD]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetLogDeliveryByShipment]    Script Date: 1/4/2022 3:47:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- **************************************************************************************************************************************************        
-- STORED PROCEDURE OVERVIEW INFORMATION        
-- **************************************************************************************************************************************************        
--        
-- STORED PROCEDURE NAME: sp_GetLogDeliveryByShipment      
--        
-- DESCRIPTION:   This SP selects the travels displayed on Logistic Dashboard / Delivery by Shipment Document  
--        
-- **************************************************************************************************************************************************        
-- REVISION HISTORY/LOG
-- **************************************************************************************************************************************************        
-- Date			Programmer					Revision    Revision Notes           
-- ==================================================================================================================================================        

-- **************************************************************************************************************************************************
ALTER PROCEDURE [dbo].[sp_GetLogDeliveryByShipment]
	@LocationList				LogLocationList			READONLY,
	@SubBUList					LogSubBuList			READONLY,
	@DateFrom					VARCHAR(10),
	@DateTo						VARCHAR(10),
	@TravelID					NVARCHAR(15),
	@CustomerList				LogCustomerList			READONLY,
	@ShipmentCategoryList		LogShipmentCategoryList	READONLY,
	@CarrierList				LogCarrierList			READONLY,
	@ArrivalStatusList			LogArrivalStatusList	READONLY,
	@CommercialDocument			VARCHAR(80),
	@ViewType					VARCHAR(1),  -- 'T' for Yard, 'P' for Pick Up & 'D' Drop Off  --3.0.0.0
	@ActiveTrackingCarriers		BIT = 0,

	@CountryIdList				CountryIdList			READONLY
AS
BEGIN

-- **************************************************************************************************************************************************                    
-- STORED PROCEDURE VARIABLE DECLARATIONS                    
-- **************************************************************************************************************************************************    
	SET NOCOUNT ON;

    
    DECLARE @dtPickUpDateFrom	DATETIME = '1753-01-01'
	DECLARE @dtPickUpDateTo		DATETIME = '9999-12-31'
    DECLARE @dtDeliveryDateFrom	DATETIME
	DECLARE @dtDeliveryDateTo	DATETIME
	
	DECLARE @vSubBU				LogSubBuList
	DECLARE @ALLSUBBU			NUMERIC;


	-- Filter by CountryID
	DECLARE @CountriesParamsLength int = 0;
	DECLARE @pCountryIds  table (countryId int) ;

	SELECT @CountriesParamsLength=COUNT(countryId) from @CountryIdList;
		IF @CountriesParamsLength <1 
			INSERT @pCountryIds(countryId) VALUES (1);
		ELSE
			INSERT @pCountryIds(countryId)
			SELECT countryId from @CountryIdList;

				
		

	-- Separate Business Number and Position
	--DECLARE @PCommercialDocument	VARCHAR(80) = '%'+ REPLACE(SUBSTRING(@CommercialDocument,PATINDEX('%[^0]%', @CommercialDocument + '.'),LEN(@CommercialDocument)), ' ', '') + '%'
	DECLARE @PCommercialDocument	VARCHAR(80);
	; WITH Separated AS
	(
		SELECT 
			V.value AS BusinessValue
			, ROW_NUMBER() OVER(ORDER BY LEN(V.VALUE) DESC) AS Position
		FROM string_split(@CommercialDocument, '-') V
	)
	SELECT 
		@CommercialDocument = CASE WHEN Separated.Position = 1 THEN Separated.BusinessValue ELSE @CommercialDocument END
		, @PCommercialDocument = CASE WHEN Separated.Position = 2 THEN Separated.BusinessValue ELSE @PCommercialDocument END
	FROM Separated
	;
	
	DECLARE @PTravelID			NVARCHAR(15) = '%'+ REPLACE(SUBSTRING(@TravelID,PATINDEX('%[^0]%', @TravelID + '.'),LEN(@TravelID)), ' ', '') + '%'
	DECLARE @SQL NVARCHAR(MAX)

	DECLARE @LocationValues				VARCHAR(MAX) = '';
	DECLARE @SubBUValues				VARCHAR(MAX) = '';
	DECLARE	@CustomerValues				VARCHAR(MAX) = ''; --
	DECLARE @ShipmentCategoryValues		VARCHAR(MAX) = '';
	DECLARE @CarrierValues				VARCHAR(MAX) = ''; --
	DECLARE @ArrivalStatusValues		VARCHAR(MAX) = '';
	DECLARE @CountryIdValues			VARCHAR(MAX) = '';
	

-- **************************************************************************************************************************************************                    
-- INITIAL VALUES
-- ************************************************************************************************************************************************** 

	--SUB BU
 	set @ALLSUBBU = (select count(*) from @SubBUList where SubBuCode = -1)
 	
 	if @ALLSUBBU >0
 		insert into @vSubBU
 		select SubBuCode from dim_LogSubBu
 	else
 		insert into @vSubBU
 		select * from @SubBUList

	--From Lists to Values
	SELECT @LocationValues	 = @LocationValues + cast(LocationID  as nvarchar(50)) + ',' FROM @LocationList --Casting
	SELECT @SubBUValues	 = @SubBUValues + ''''+ SubBuCode + ''',' FROM @vSubBU
	SELECT @CustomerValues	 = @CustomerValues + cast(CustomerID  as nvarchar(50)) + ',' FROM @CustomerList
	SELECT @ShipmentCategoryValues	 = @ShipmentCategoryValues + ''''+ ShipmentCategory + ''',' FROM @ShipmentCategoryList
	SELECT @CarrierValues	 = @CarrierValues + cast(CarrierID  as nvarchar(50))   + ',' FROM @CarrierList
	SELECT @ArrivalStatusValues	 = @ArrivalStatusValues + ''''+ ArrivalStatus + ''',' FROM @ArrivalStatusList

	SELECT @CountryIdValues	 = @CountryIdValues + cast(CountryId  as nvarchar(50))   + ',' FROM @pCountryIds;


	IF @DateFrom <> 'N.D.' 
	   BEGIN
			SET @dtPickUpDateFrom = (SELECT CONVERT(DATETIME,@DateFrom))
			SET @dtDeliveryDateFrom = (SELECT CONVERT(DATETIME,@DateFrom))
	   END
	IF @DateTo <> 'N.D.' 
		BEGIN
			SET @dtPickUpDateTo =	DATEADD (S,86399,(SELECT CONVERT(DATETIME,@DateTo))) --To add 24 hours because the search is done by date/time 00:00:00 to 23:59:59
			SET @dtDeliveryDateTo =	DATEADD (S,86399,(SELECT CONVERT(DATETIME,@DateTo))) 
		END
 

     
	
 
	
-- **************************************************************************************************************************************************                    
-- STORED PROCEDURE EXECUTABLE PROGRAMING                    
-- **************************************************************************************************************************************************      

	DECLARE @SQLCOMMAND_INT NVARCHAR(MAX);  --3.0.0.0
	DECLARE @SQLCOMMAND_EXT NVARCHAR(MAX);  --3.0.0.0
	DECLARE @SQLWHERE NVARCHAR(MAX);		--3.0.0.0
	DECLARE @SQLFROM NVARCHAR(MAX);
	DECLARE @CuntryFilter NVARCHAR(MAX);

IF NULLIF(@TravelID, '') IS NULL AND NULLIF(@CommercialDocument, '') IS NULL 
	BEGIN
		IF @ViewType = 'T'
		BEGIN
			--SET @SQLWHERE = 
			--	' ((OLocationOrigenID  IN (' + substring (@LocationValues, 0, len(@LocationValues)) +') AND (OAppointmentTime BETWEEN  ''' + CONVERT(nvarchar(16),@dtPickUpDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16),@dtPickUpDateTo,20) + '''))
			--		OR
			--	( DLocationDestinyID IN (' + substring (@LocationValues, 0, len(@LocationValues)) +') AND (DAppointmentTime BETWEEN '''+ CONVERT(nvarchar(16),@dtDeliveryDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16), @dtDeliveryDateTo,20) + ''') ) )';
			IF (NOT EXISTS(SELECT 1 FROM @LocationList WHERE LocationID = '-1') AND LEN(@LocationValues) > 0)
			BEGIN
				SET @SQLWHERE = CASE WHEN @LocationValues IS NOT NULL
					THEN ' ( (OLocationOrigenID  IN (' + substring (@LocationValues, 0, len(@LocationValues)) +')) OR ( DLocationDestinyID IN (' + substring (@LocationValues, 0, len(@LocationValues)) +')) ) AND '
				END;
			END

			--SET @SQLWHERE = ISNULL(@SQLWHERE, '') + 
			--	'(
			--		(
			--			OAppointmentTime IS NOT NULL AND 
			--			(
			--				(OAppointmentTime BETWEEN  ''' + CONVERT(nvarchar(16),@dtPickUpDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16),@dtPickUpDateTo,20) + ''')
			--				OR
			--				(DAppointmentTime BETWEEN  ''' + CONVERT(nvarchar(16),@dtPickUpDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16),@dtPickUpDateTo,20) + ''')
			--			)
			--		)
			--		OR
			--		(
			--			OAppointmentTime IS NULL
			--			AND
			--			(
			--				(OArrivalTime BETWEEN  ''' + CONVERT(nvarchar(16),@dtPickUpDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16),@dtPickUpDateTo,20) + ''')
			--				OR 
			--				(DArrivalTime BETWEEN  ''' + CONVERT(nvarchar(16),@dtPickUpDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16),@dtPickUpDateTo,20) + ''')
			--			)
			--		)
			--	)';
				SET @SQLWHERE = ISNULL(@SQLWHERE, '') + 
				'(
					OFilterdate BETWEEN  ''' + CONVERT(VARCHAR(10),CONVERT(DATE, @dtPickUpDateFrom, 120), 20) + ''' AND '''+ CONVERT(VARCHAR(10),CONVERT(DATE, @dtPickUpDateTo, 120),20) + '''
					OR
					DFilterdate BETWEEN  ''' + CONVERT(VARCHAR(10),CONVERT(DATE, @dtPickUpDateFrom,120), 20) + ''' AND '''+ CONVERT(VARCHAR(10),CONVERT(DATE, @dtPickUpDateTo,120), 20) + '''
				)';

		END
		IF @ViewType = 'P'
		BEGIN
			--SET @SQLWHERE = '
			--(
			--	(
			--		OAppointmentTime IS NOT NULL AND (OAppointmentTime BETWEEN  ''' + CONVERT(nvarchar(16),@dtPickUpDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16),@dtPickUpDateTo,20) + ''') 
			--	)
			--	OR 
			--	(
			--		OAppointmentTime IS NULL AND (OArrivalTime BETWEEN  ''' + CONVERT(nvarchar(16),@dtPickUpDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16),@dtPickUpDateTo,20) + ''') 
			--	)
			--)';

			SET @SQLWHERE = '
			(
				OFilterdate BETWEEN  ''' + CONVERT(VARCHAR(10),CONVERT(DATE, @dtPickUpDateFrom, 120), 20) + ''' AND '''+ CONVERT(VARCHAR(10),CONVERT(DATE, @dtPickUpDateTo, 120),20) + '''
			)';
				
			IF (NOT EXISTS(SELECT 1 FROM @LocationList WHERE LocationID = '-1') AND LEN(@LocationValues)>0)
				SET @SQLWHERE = @SQLWHERE + ' AND (OLocationOrigenID IN (' + substring (@LocationValues, 0, len(@LocationValues)) +'))';
		END
		IF @ViewType = 'D'
		BEGIN
			--SET @SQLWHERE = '
			--( 
			--	(
			--		DAppointmentTime IS NOT NULL AND (DAppointmentTime BETWEEN '''+ CONVERT(nvarchar(16),@dtDeliveryDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16), @dtDeliveryDateTo,20) + ''')
			--	)
			--	OR
			--	(
			--		DAppointmentTime IS NULL AND (DArrivalTime BETWEEN '''+ CONVERT(nvarchar(16),@dtDeliveryDateFrom,20) + ''' AND '''+ CONVERT(nvarchar(16), @dtDeliveryDateTo,20) + ''')
			--	)
			--)';

			SET @SQLWHERE = '
			( 
				DFilterdate BETWEEN  ''' + CONVERT(VARCHAR(10),CONVERT(DATE, @dtPickUpDateFrom,120), 20) + ''' AND '''+ CONVERT(VARCHAR(10),CONVERT(DATE, @dtPickUpDateTo,120), 20) + '''
			)';
			
			IF (NOT EXISTS(SELECT 1 FROM @LocationList WHERE LocationID = '-1') AND LEN(@LocationValues)>0)
				SET @SQLWHERE = @SQLWHERE + ' AND (DLocationDestinyID IN (' + substring (@LocationValues, 0, len(@LocationValues)) +'))';
		END

		-- General Filters
		IF (NOT EXISTS(SELECT 1 FROM @ShipmentCategoryList WHERE ShipmentCategory = '-1') AND LEN(@ShipmentCategoryValues)>0)
			SET @SQLWHERE = @SQLWHERE + ' AND (ShipmentCategory IN (' + substring (@ShipmentCategoryValues, 0, len(@ShipmentCategoryValues)) +'))'

		IF (NOT EXISTS(SELECT 1 FROM @CarrierList WHERE CarrierID = '-1') AND LEN(@CarrierValues)>0)
			SET @SQLWHERE = @SQLWHERE + ' AND (CarrierID IN (' + substring (@CarrierValues, 0, len(@CarrierValues)) +'))'

		IF (NOT EXISTS(SELECT 1 FROM @CustomerList WHERE CustomerID = '-1') AND LEN(@CustomerValues)>0)
			SET @SQLWHERE = @SQLWHERE + ' AND (CustomerID IN (' + substring (@CustomerValues, 0, len(@CustomerValues)) +'))'

		IF (NOT EXISTS(SELECT 1 FROM @SubBUList WHERE SubBuCode = '-1') AND LEN(@SubBUValues)>0)
			SET @SQLWHERE = @SQLWHERE + ' AND (SubBuCode IN (' + substring (@SubBUValues, 0, len(@SubBUValues)) +'))'
		ELSE
			SET @SQLWHERE = @SQLWHERE + ' AND SubBuCode IS NOT NULL'

	


	END
ELSE
	BEGIN
		IF NULLIF(@TravelID, '') IS NOT NULL
			SET @SQLWHERE = ' ((TravelDocument LIKE ''' + @PTravelID + ''' OR TravelID  LIKE ''' + @PTravelID + ''') AND ISNULL( ''' + @TravelID + ''' ,'''')!='''')'
		IF NULLIF(@CommercialDocument, '') IS NOT NULL 
			SET @SQLWHERE = CONCAT(@SQLWHERE, ' BusinessOrderNumber LIKE ''%',  @CommercialDocument, '%''', ISNULL(' AND BusinessOrderPosition = ''' + @PCommercialDocument + '''', '') )
			--SET @SQLWHERE ='((ISNULL(BusinessOrderNumber,'''') ' + '+'   +'''-'''+ '+'   + 'ISNULL(BusinessOrderPosition,'''') like ''' + @PCommercialDocument + ''' )AND ISNULL(' + @CommercialDocument + ' ,'''')!='''') '
	END

IF (@ActiveTrackingCarriers = 1)
	SET @SQLFROM = ' INNER JOIN dim_TrackingProvidersCarriers tCarriers ON tCarriers.CarrierID = C.CarrierID ';

IF NOT EXISTS (SELECT 1 FROM @ArrivalStatusList AL WHERE AL.ArrivalStatus = '-1') AND LEN(@ArrivalStatusValues) > 0
SET @SQLWHERE = @SQLWHERE
	+ ' AND ('
	+ ' ( OArrivalStatus=''Pending'' OR OArrivalStatus IN (' + substring (@ArrivalStatusValues, 0, len(@ArrivalStatusValues)) +'))'
	+ ' OR'
	+ ' ( DArrivalStatus=''Pending'' OR DArrivalStatus IN (' + substring (@ArrivalStatusValues, 0, len(@ArrivalStatusValues)) +'))'
	+ ' )'
;


SET @CuntryFilter = ' WHERE CountryId IN (' + substring (@CountryIdValues, 0, len(@CountryIdValues)) +')';

SET @SQLCOMMAND_INT = 'SELECT * FROM [dbo].[view_LogDeliverybyShipment] WHERE ' + @SQLWHERE
SET @SQLCOMMAND_EXT = 'SELECT C.*, Pipes.PortalHeaderID, Pipes.Severity AS PipeStatus, Pipes.[MessageDescription] FROM ( ' + @SQLCOMMAND_INT + ') C '
	+ ' LEFT JOIN ('
		+ ' SELECT H.PortalHeaderID, ISNULL(H.RefDocTenarisID, H.RefDocAssigned) AS RefDocTenarisID, H.[MessageDescription], H.Severity'
		+ ', ROW_NUMBER() OVER (PARTITION BY ISNULL(H.RefDocTenarisID, H.RefDocAssigned) ORDER BY H.PortalDateTime DESC) AS LastRFIDFlag'
		+ ' FROM udt_PortalHeader H WHERE H.Active = 1'
		+ ' ) Pipes ON C.TravelDocument = Pipes.RefDocTenarisID AND Pipes.LastRFIDFlag = 1'
		+ ISNULL(@SQLFROM, '')
	+ @CuntryFilter
	+ ' ORDER BY OAppointmentTime';


--  select @SQLCOMMAND_EXT as query;
 EXEC SP_EXECUTESQL @SQLCOMMAND_EXT

END