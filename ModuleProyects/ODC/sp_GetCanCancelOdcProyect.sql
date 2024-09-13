-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-18-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCanCancelOdcProyect
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idOdc:ID of the ODC
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @idStatusOdcActive: ID of the active status of the ODC
-- @idStatusOdcSendent: ID of the sent status of the ODC
-- @idTypeDocument: ID of the type of document
-- @canCancel: Identify if the ODC can be canceled
-- @TempMaterials: Temporal table to store the materials of the ODC
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-07-18		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCanCancelOdcProyect')
    BEGIN 

        DROP PROCEDURE sp_GetCanCancelOdcProyect;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/18/2024
-- Description: sp_GetCanCancelOdcProyect - Get if the ODC can be canceled
CREATE PROCEDURE sp_GetCanCancelOdcProyect(
    @idOdc INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idStatusOdcActive INT = 10;
    DECLARE @idStatusOdcSendent INT = 11;
    DECLARE @idTypeDocument INT =3
    DECLARE @canCancel BIT =0;
    DECLARE @TempMaterials TABLE (idMaterial INT,quantity INT);


    SELECT 
        @canCancel =CASE 
            WHEN idStatus = @idStatusOdcActive AND idPosition IS NOT NULL THEN 1
            WHEN idStatus = @idStatusOdcSendent AND idPosition IS NOT NULL THEN 1
            ELSE 0
        END
    FROM Documents
    WHERE 
        idDocument = @idOdc
        AND idTypeDocument = @idTypeDocument



    IF(@canCancel = 1)
    BEGIN
        INSERT INTO @TempMaterials (idMaterial,quantity)
        SELECT idMaterial,quantity FROM DocumentItems WHERE document = @idOdc
    END

    SELECT
        @canCancel AS canCancel;

    SELECT 
        idMaterial AS idMaterial,
        quantity AS quantity
    FROM @TempMaterials

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------