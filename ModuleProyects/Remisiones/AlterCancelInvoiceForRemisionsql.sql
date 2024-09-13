SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/25/2022
-- Description: sp_CancelInvoiceDocummment - Cancel the invoice and reverse the related documents
ALTER PROCEDURE [dbo].[sp_CancelInvoiceDocummment](
   @documentId INT,
   @lastUpdateBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @isCancelable BIT;
    DECLARE @orderId INT;
    DECLARE @quoteId INT;
    DECLARE @tranName NVARCHAR(30) = 'cancelInvoice';
    DECLARE @Message NVARCHAR(MAX);
    DECLARE @idPosition INT;
    DECLARE @idProyect INT;

    BEGIN TRY
        BEGIN TRANSACTION @tranName

        SELECT 
        @orderId= document.idDocument,
        @quoteId= document.idQuotation


        FROM LegalDocuments AS legalDocument
        LEFT JOIN Documents AS document ON document.uuid= legalDocument.uuid

        SELECT 

            @isCancelable= CASE 
                                WHEN COUNT(*) = 0 OR COUNT(*) IS NULL THEN 1
                                ELSE 0
                            END

        FROM Documents WHERE idTypeDocument= 5 AND idInvoice=@orderId AND (idStatus = 17 OR idStatus=18)

        IF (@isCancelable= 1)
            BEGIN

                -- Cambia los Estatus de las CxC a canceladas.
                UPDATE Documents SET
                    idStatus= 19,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE idTypeDocument= 5 AND idInvoice=@orderId

                -- Cambia el estatus de la Facutra a cancelado
                UPDATE LegalDocuments SET   
                    idLegalDocumentStatus= 8,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpadatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE id= @documentId

                -- Cambia el estatus del pedido a No-Facturado
                UPDATE Documents SET 
                    idStatus= 9,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE idDocument= @orderId;

                -- Cambia el estatus de la cotizacion a Ganada
                UPDATE Documents SET 
                    idStatus= 2,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE idDocument= @quoteId;

                SELECT 
                    @idPosition= idPosition
                FROM Documents WHERE idDocument= @orderId;
                
                IF(@idPosition IS NOT NULL)
                    BEGIN
                        DECLARE @totalPositions INT;
                        DECLARE @totalPositionsActive INT;
                        DECLARE @idProposal INT;
                        DECLARE @hasProposal BIT=0;

                        SELECT 
                            @idProyect= idProject
                        FROM PositionsProyects WHERE id= @idPosition;

                        SELECT 
                            TOP(1) @idProposal= idProposal
                        FROM ProposalPositionIndex
                        WHERE idPosition= @idPosition
                        ORDER BY idProposal DESC;

                        SELECT 
                            @hasProposal= CASE 
                                            WHEN [status] = 1 THEN 1
                                            ELSE 0
                                        END
                        FROM ProyectProposals
                        WHERE 
                            id= @idProposal
                            AND [status]= 1

                            IF(@hasProposal=1)
                                BEGIN
                                    UPDATE PositionsProyects SET 
                                        [statusPosition]='Propuesta'
                                    WHERE id= @idPosition;
                                END
                            ELSE
                                BEGIN
                                    UPDATE PositionsProyects SET 
                                        [statusPosition]='Activo'
                                    WHERE id= @idPosition;
                                END
                        

                        SELECT 
                            @totalPositions= COUNT(*) 
                        FROM PositionsProyects WHERE idProject= @idProyect AND [statusPosition] !='Cancelar';

                        SELECT 
                            @totalPositionsActive= COUNT(*)
                        FROM PositionsProyects WHERE idProject= @idProyect AND [statusPosition] ='Activo';

                        IF(@totalPositions = @totalPositionsActive)
                            BEGIN
                                UPDATE Proyects SET 
                                    [statusProyect]='ActivoOperando'
                                WHERE id= @idProyect;
                            END
                        ELSE 
                            BEGIN
                                UPDATE Proyects SET 
                                    [statusProyect]='ActivoPropuestaPendiente'
                                WHERE id= @idProyect;
                            END
                    END

                SET @Message= 'La factura fue cancelada con exito';
                SELECT @Message AS [Message]
                COMMIT TRANSACTION @tranName
            END
        ELSE
            BEGIN
                SET @Message= 'La factura no puede ser cancelada debido a que ya tiene CXC asociadas a un ingreso';
                RAISERROR(@Message, 14,0);
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
GO
