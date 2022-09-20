-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-25-2022
-- Description: Obtains the status of the movement, if it has a payment complement and identifies if there is an invoice as ppd
-- STORED PROCEDURE NAME:	sp_GetPreviusAssociationStatus
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @arrayIdInvoice: invoice id array
-- @idMovement: movement id
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
--	2022-08-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/25/2022
-- Description: sp_GetPreviusAssociationStatus - Obtains the status of the movement, if it has a payment complement and identifies if there is an invoice as ppd
CREATE PROCEDURE sp_GetPreviusAssociationStatus(
    @arrayIdInvoice NVARCHAR(MAX),
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @hasPpd BIT;
    DECLARE @hasComplement BIT;
    DECLARE @previusStatus INT;
        SELECT 
        @hasComplement=
            CASE 
                WHEN idPaymentPluginStatus=1 THEN 1
                ELSE 0
            END,
        @previusStatus= [status]

    FROM Movements WHERE MovementID= @idMovement

    IF EXISTS (

        SELECT 
            *
        FROM Documents 
        WHERE idDocument IN (
            SELECT  
                [value]
            FROM STRING_SPLIT(@arrayIdInvoice,',')
            WHERE RTRIM([value])<>''
        ) AND idPaymentForm=1
    )
        BEGIN
            PRINT 'SI EXISTE ALMENOS UNA FACTURA PPD'
            SET @hasPpd=1
        END
    ELSE    
        BEGIN
            PRINT 'NO EXISTE NINGUNA FACTURA CON PPD'
            SET @hasPpd=0
        END

    SELECT 
        @hasPpd AS hasPPD,
        @hasComplement AS hasComplement,
        @previusStatus AS idMovementStatus


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------