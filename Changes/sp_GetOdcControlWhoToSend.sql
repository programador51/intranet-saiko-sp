-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 12-12-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetOdcControlWhoToSend
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
--	2023-12-12		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetOdcControlWhoToSend')
    BEGIN 

        DROP PROCEDURE sp_GetOdcControlWhoToSend;
    END
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 12/12/2023
-- Description: sp_GetOdcControlWhoToSend - Some Notes
CREATE PROCEDURE sp_GetOdcControlWhoToSend(
    @idOdc INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE  @idQuote INT;
    DECLARE @executieEmail NVARCHAR(50);

    SELECT @idQuote = idQuotation FROM Documents WHERE idDocument =@idOdc;

    IF(@idQuote IS NOT NULL)
        BEGIN
            SELECT 
                @executieEmail = executive.email
            FROM Documents AS document
            LEFT JOIN Users AS executive ON executive.userID= document.idExecutive
            WHERE 
                document.idQuotation= @idQuote
        END
    ELSE 
        BEGIN
            SELECT 
                @executieEmail = executive.email
            FROM Documents AS document
            LEFT JOIN Users AS executive ON executive.userID= document.idExecutive
            WHERE 
                document.idDocument= @idOdc
        END
    SELECT
        @idOdc AS idOdc,
        CASE 
            WHEN @idQuote IS NOT NULL THEN 'Email enviado al ejecutivo de la cotización'
            ELSE 'Email enviado al ejecutivo de la orden de compra'
        END AS representative,
        @executieEmail AS emailTo
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------