-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-17-2024
-- Description: Get the company details
-- STORED PROCEDURE NAME:	sp_GetCompanyDetails
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
--	2024-08-17		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCompanyDetails')
    BEGIN 

        DROP PROCEDURE sp_GetCompanyDetails;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/17/2024
-- Description: sp_GetCompanyDetails - Get the company details
CREATE PROCEDURE sp_GetCompanyDetails
AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idSocialReason INT = 5;
    DECLARE @idRFC INT = 9;
    DECLARE @idFiscalRegimen INT = 37;
    DECLARE @idStreet INT = 6;
    DECLARE @idCity INT = 7;
    DECLARE @idCompanyPhone INT = 8;

    DECLARE @companySocialReason VARCHAR(256);
    DECLARE @companyRFC VARCHAR(15);
    DECLARE @companyFiscalRegimen VARCHAR(256);
    DECLARE @companyStreet VARCHAR(256);
    DECLARE @companyCity VARCHAR(256);
    DECLARE @companyPhone VARCHAR(15);

    -- Obtener valores de la tabla Parameters
    SELECT 
        @companySocialReason = [value]
    FROM Parameters 
    WHERE parameter = @idSocialReason;

    SELECT 
        @companyRFC = [value]
    FROM Parameters 
    WHERE parameter = @idRFC;

    SELECT 
        @companyFiscalRegimen = [value]
    FROM Parameters
    WHERE parameter = @idFiscalRegimen;

    SELECT 
        @companyStreet = [value]
    FROM Parameters
    WHERE parameter = @idStreet;

    SELECT 
        @companyCity = [value]
    FROM Parameters
    WHERE parameter = @idCity;

    SELECT 
        @companyPhone = [value]
    FROM Parameters
    WHERE parameter = @idCompanyPhone;

    -- Devolver los valores obtenidos
    SELECT 
        @companySocialReason AS socialReason,
        @companyRFC AS rfc,
        @companyFiscalRegimen AS fiscalRegimen,
        @companyStreet AS street,
        @companyCity AS city,
        @companyPhone AS phone;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------