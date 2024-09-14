-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-02-2021
-- Description: gets all the users on the sistem
-- STORED PROCEDURE NAME:	sp_GetLegalDocumentPraxiaValidation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @rfcReceptor: The RFC receptor must be our RFC from the legal document
-- @rfcEmitter: The RFC provider from the legal document
-- @uuidRequested: The UUID from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @isUs: Indicates if the RFC receptor is us
-- @existUUID: Indicates if the UUID exist in LegalDocument table
-- @existProvider: Indicates if the Provider exist
-- @errorMessage: The error message
-- @id: Indicates the Provider id
-- @creditDays: Indicates the credit days that the Provider has
-- @socialReason: Is the Provider's social reason
-- @tempTable: Is a tenmporal table that stores the providers (We use this if exist more than one Provider with the same RFC)
-- ===================================================================================================================================
-- Returns: 3 RESULTS, THE ERROR MESSAGE, IF THERE ARE SUPPLIERS OR NOT, AND THE LIST OF SUPPLIERS
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-01-28		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/02/2021
-- Description: sp_GetLegalDocumentPraxiaValidation Validates the legal documents requirements for praxia to be a valid XML file
-- =============================================
CREATE PROCEDURE sp_GetLegalDocumentPraxiaValidation (
    @rfcReceptor NVARCHAR(256),
    @rfcEmitter NVARCHAR(256),
    @uuidRequested NVARCHAR(256)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    DECLARE @isUs BIT;
    DECLARE @existUUID BIT;
    DECLARE @existProvider BIT=0;
    DECLARE @errorMessage NVARCHAR(256);

    DECLARE @id INT;
    DECLARE @creditDays INT;
    DECLARE @socialReason NVARCHAR(256);

    DECLARE @tempTable TABLE (id INT,creditDays INT,socialReason NVARCHAR (256))

-- ----------------- ↓↓↓ EVALUATE IF THE rfcReceptor IS US ↓↓↓ -----------------------
    SELECT 
        @isUs= CASE
                    WHEN value=@rfcReceptor THEN 1
                ELSE 0
                END
    FROM Parameters 
    WHERE parameter=9;
-- ----------------- ↑↑↑ EVALUATE IF THE rfcReceptor IS US ↑↑↑ -----------------------

-- ----------------- ↓↓↓ IF THE RFC IS OURS THEN ASSESS IF THE UUID EXISTS IN THE LEGAL DOCUMENTS TABLE  ↓↓↓ -----------------------
IF(@isUs=1)
	BEGIN
		SELECT 
			@existUUID= CASE 
							WHEN COUNT (*)>0 THEN 1
							ELSE 0
			END
		FROM LegalDocuments
		WHERE uuid=@uuidRequested;
		IF (@existUUID=1)
			BEGIN --The invoice has already been registered
				SET @errorMessage='La factura ya ha sido registrada, intenta una diferente'
			END
	END
ELSE 
	BEGIN-- This bill is not for us
		SET @errorMessage='Esta factura no es para nosotros'
	END
-- ----------------- ↑↑↑ IF THE RFC IS OURS THEN ASSESS IF THE UUID EXISTS IN THE LEGAL DOCUMENTS TABLE  ↑↑↑ -----------------------

/* ----------------- ↓↓↓ IF THE UUID DOES NOT EXIST IN THE LEGAL DOCUMENTS TABLE  ↓↓↓ -----------------------
                        AND THE RFC IS NOT A GENERIC RFC,THE PROVIDERS ARE REVIEWED  */

IF (@existUUID=0 AND NOT(@rfcEmitter='XAXX010101000' OR @rfcEmitter='XEXX010101000'))
	BEGIN
		SELECT @existProvider= CASE 
								WHEN COUNT(*)>0 THEN 1
								ELSE 0
								END
		FROM Customers WHERE rfc=@rfcEmitter AND status=1
		IF(@existProvider=1)
			BEGIN
				INSERT INTO @tempTable SELECT  customerID ,creditDays,socialReason  FROM Customers WHERE rfc=@rfcEmitter AND status=1
			END
		ELSE
			BEGIN
				INSERT INTO @tempTable VALUES(NULL ,NULL,NULL)
			END
	END
ELSE
	BEGIN
		INSERT INTO @tempTable VALUES(NULL ,NULL,NULL)
	END
/* ----------------- ↑↑↑ IF THE UUID DOES NOT EXIST IN THE LEGAL DOCUMENTS TABLE  ↑↑↑ -----------------------
                        AND THE RFC IS NOT A GENERIC RFC,THE PROVIDERS ARE REVIEWED  */

-- ----------------- ↓↓↓ QUERY EXECUTION ↓↓↓ -----------------------

SELECT @errorMessage AS errorMessage;
SELECT @existProvider AS existProvider;
SELECT  id , creditDays, socialReason FROM @tempTable;

-- ----------------- ↑↑↑ QUERY EXECUTION ↑↑↑ -----------------------
   
END
GO
