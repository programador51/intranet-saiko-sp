-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-18-2023
-- Description: Cancel the order document
-- STORED PROCEDURE NAME:	sp_UpdateCancelPreInvoice
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
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
--	2023-04-18		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/18/2023
-- Description: sp_UpdateCancelPreInvoice - Cancel the order document
CREATE PROCEDURE sp_UpdateCancelPreInvoice(
    @idPreinvoice INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idQuote INT=NULL;
    DECLARE @idOdc INT=NULL;
    DECLARE @idContract INT=NULL;
    DECLARE @idStatus INT;
    DECLARE @idOdcStatus INT=10;

    SELECT 
        @idQuote = idQuotation,
        @idOdc= idOC,
        @idContract=idContact,
        @idStatus=@idStatus --Order status
    FROM Documents WHERE idDocument=@idPreinvoice

    IF(@idOdc!=NULL)
        BEGIN
            SELECT 
                @idOdcStatus=idStatus
            FROM Documents  WHERE idDocument=@idOdc
        END

    IF(@idStatus=4)
        BEGIN
            --It can be cancelable.
            IF (@idOdcStatus=10 OR @idOdcStatus=11)
                BEGIN
                    
                    UPDATE Documents SET idStatus=6 WHERE idDocument=@idPreinvoice
                    IF (@idQuote!=NULL)
                        BEGIN
                            UPDATE Documents SET idStatus=1 WHERE idDocument=@idQuote

                        END
                    IF (@idOdc!=NULL)
                        BEGIN
                            UPDATE Documents SET idStatus=12 WHERE idDocument=@idOdc

                        END
                    IF (@idContract!=NULL)
                        BEGIN
                            UPDATE Documents SET idStatus=8 WHERE idDocument=@idContract

                        END
                END
            ELSE 
                BEGIN
                    ;THROW 51000, 'El pedido no puede ser cancelado, la odc ya tiene una factura recibida',1;
                END


        END
    ELSE
        BEGIN
            ;THROW 51000, 'El pedido no puede ser cancelado, no tiene que esta facturado',1;
        END



END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------