-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-11-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_Name
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-04-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCouldChangeCurrency')
    BEGIN 

        DROP PROCEDURE sp_GetCouldChangeCurrency;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/11/2024
-- Description: sp_GetCouldChangeCurrency - Some Notes
CREATE PROCEDURE sp_GetCouldChangeCurrency(
    @idDocument INT 
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @documetnCurrency NVARCHAR(3);
    DECLARE @couldChange BIT=0;

    DECLARE @countMxn INT=0;
    DECLARE @countUsd INT=0;

    SELECT 
        @documetnCurrency = currency.code
    FROM Documents AS document
    LEFT JOIN Currencies AS currency ON currency.currencyID = document.idCurrency
    WHERE 
        document.idDocument = @idDocument;

    SELECT 
        @countMxn = COUNT(CASE WHEN currency.code = 'MXN' THEN 1 END),
        @countUsd = COUNT(CASE WHEN currency.code = 'USD' THEN 1 END)
    FROM DocumentItems AS items
    LEFT JOIN Catalogue AS catalogue ON catalogue.id_code = items.idCatalogue
    LEFT JOIN Currencies AS currency ON currency.currencyID = catalogue.currency
    WHERE 
        items.document = @idDocument
        AND currency.code IN ('MXN', 'USD');

    IF ((@countMxn!=0 AND @countUsd!=0) OR 
        (@countMxn>0 AND @documetnCurrency!='MXN') OR 
        (@countUsd>0 AND @documetnCurrency!='USD'))
        BEGIN
            SET @couldChange = 1
        END

    SELECT @couldChange AS couldChange;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------