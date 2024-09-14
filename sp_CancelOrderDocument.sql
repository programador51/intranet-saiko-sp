-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-25-2022
-- Description: Process that cancels the order and reverses the related documents if necessary
-- STORED PROCEDURE NAME:	sp_CancelOrderDocument
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: Document id
-- @lastUpdateBy: User who try to cancel the document.
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @originId: Especifys the origin contract id
-- @odcId: Especifys the ODC id
-- @quoteId: Especifys the quote id
-- @contractId: Especifys the contract id
-- @isCancelable: Identify if the ODC is cancelable or not
-- @isSpecial: Identify if the ODC is special
-- @Message: Message to return
-- @tranName: Transaction name
-- @Severity: Severity error
-- @State: State of error
-- @createdBy: user who try to update the record
-- @infoSended: Info that was dended to update the document
-- @wasAnError: Indicates if was an error or not
-- @mustBeSyncManually: Indicates if must sync manually
-- @provider: Identifys the error provider.
-- ===================================================================================================================================
-- Returns: 
-- @Message: The reply message

-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-05-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/25/2022
-- Description: sp_CancelOrderDocument - Process that cancels the order and reverses the related documents if necessary
CREATE PROCEDURE sp_CancelOrderDocument(
    @documentId INT,
    @lastUpdateBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @isSpecial BIT;
    DECLARE @isCancelable BIT;

    DECLARE @odcId INT;
    DECLARE @quoteId INT;
    DECLARE @originId INT;
    DECLARE @contractId INT;


    DECLARE @Message NVARCHAR(MAX);
    DECLARE @tranName NVARCHAR(30) = 'cancelOrder';

    BEGIN TRY
        SELECT 
                @isSpecial= CASE
                                WHEN odcDocument.idQuotation IS NULL THEN 1
                                ELSE 0
                            END,
                @isCancelable= CASE
                                    WHEN (odcDocument.wasSend=0 AND orderDocument.idStatus=9) THEN 1
                                    ELSE 0
                                END,
                @Message= CASE
                                    WHEN (odcDocument.wasSend=1 AND orderDocument.idStatus=9) THEN 'El pedido no puede ser cancelado debido a que la ODC ya fue enviada'
                                    WHEN (odcDocument.wasSend=0 AND orderDocument.idStatus!=9) THEN 'El pediodo no puede ser cancelado porque ya fue facturado'
                                    WHEN (odcDocument.wasSend=1 AND orderDocument.idStatus!=9) THEN 'El pedido no puede ser cancelado porque ya fue facturado y la ODC ya fue enviada'
                                    ELSE 'La ODC fue cancelada con exito'
                                END,
                @odcId= orderDocument.idOC,
                @quoteId=orderDocument.idQuotation,
                @originId=orderDocument.idContractParent,
                @contractId=orderDocument.idContract

                
        FROM Documents AS orderDocument
        LEFT JOIN Documents AS odcDocument ON odcDocument.idDocument= orderDocument.idOC
        WHERE orderDocument.idDocument= @documentId;

        IF @isCancelable=1
            BEGIN
                IF @isSpecial = 1
                    BEGIN 
                        UPDATE Documents SET 
                            idStatus= 12
                        WHERE idDocument= @documentId;
                        SELECT @Message AS [Message]
                        COMMIT TRANSACTION @tranName
                    END
                ELSE
                    BEGIN
                        -- Updates the status of the Order to canceled
                            UPDATE Documents SET 
                                idStatus= 12
                            WHERE idDocument= @documentId;
                            
                            -- Updates the status of the ODC to canceled
                            UPDATE Documents SET 
                                idStatus= 8
                            WHERE idDocument= @odcId;

                            -- Updates the status of the Cotizacion to canceled and the Contrato, ODC, Pedido id's to null
                            UPDATE Documents SET 
                                idStatus= 1,
                                idOC= NULL,
                                idInvoice= NULL,
                                idContract= NULL
                            WHERE idDocument= @quoteId;

                            -- Updates the status of the Contract to 'Terminado' se deberia de inactivar
                            IF @contractId IS NOT NULL
                                BEGIN
                                    UPDATE Documents SET 
                                        idStatus= 15
                                    WHERE idDocument= @contractId;
                                END
                            -- Updates the status of the Contract  parent to 'En  proceso' se deberia de inactivar
                            IF @originId IS NOT NULL
                                BEGIN
                                    UPDATE Documents SET 
                                        idStatus= 14
                                    WHERE idDocument= @originId;
                                END
                            SELECT @Message AS [Message]
                            COMMIT TRANSACTION @tranName
                    END
            END
        ELSE
            BEGIN
                RAISERROR(@Message, 1,0);
                COMMIT TRANSACTION @tranName
            END
    END TRY


    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()

        DECLARE @createdBy NVARCHAR(30)= @lastUpdateBy;
        DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_CancelOrderDocument',@documentId,@lastUpdateBy);
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
        IF (XACT_STATE()= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (XACT_STATE()=1)
            BEGIN
                COMMIT TRANSACTION @tranName
            END

        IF @@TRANCOUNT > 0  
            BEGIN
                ROLLBACK TRANSACTION @tranName;   
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog @createdBy,@infoSended,@Message,@Message,@wasAnError,@mustBeSyncManually,@provider;
    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------