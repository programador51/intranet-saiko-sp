-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-18-2023
-- Description: Cancel the odc document
-- STORED PROCEDURE NAME:	sp_UpdateCancelOdc
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
-- Description: sp_UpdateCancelOdc - Cancel the odc document
CREATE PROCEDURE sp_UpdateCancelOdc(
    @idOdc INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idQuote INT=NULL;
    DECLARE @idOrder INT=NULL;
    DECLARE @idContract INT=NULL;
    DECLARE @idStatus INT;
    DECLARE @idOrderStatus INT=4;

    SELECT 
        @idQuote = idQuotation,
        @idOrder= idInvoice,
        @idContract=idContact,
        @idStatus=idStatus --Order status
    FROM Documents WHERE idDocument=@idOdc

    IF(@idOrder!=NULL)
        BEGIN
            SELECT 
                @idOrderStatus=idStatus
            FROM Documents  WHERE idDocument=@idOrder
        END

    IF(@idStatus=10 OR @idStatus=11)
        BEGIN
            --It can be cancelable.
            IF (@idOrderStatus=4)
                BEGIN
                    
                    
                    UPDATE Documents SET idStatus=12 WHERE idDocument=@idOdc
                    IF (@idQuote!=NULL)
                        BEGIN
                            UPDATE Documents SET idStatus=1 WHERE idDocument=@idQuote

                        END
                    IF (@idOrder!=NULL)
                        BEGIN
                            UPDATE Documents SET idStatus=6 WHERE idDocument=@idOrder
                        END
                    IF (@idContract!=NULL)
                        BEGIN
                            UPDATE Documents SET idStatus=8 WHERE idDocument=@idContract

                        END
                END
            ELSE 
                BEGIN
                    ;THROW 51000, 'La orden de compra no puede ser cancelado, la odc ya tiene una factura recibida',1;
                END


        END
    ELSE
        BEGIN
            ;THROW 51000, 'La orden de compra no puede ser cancelado, la odc ya tiene una factura recibida',1;
        END



END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------