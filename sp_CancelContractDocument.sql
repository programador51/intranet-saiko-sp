-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-25-2022
-- Description: End the contract
-- STORED PROCEDURE NAME:	sp_CancelContractDocument
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: Document id
-- @lastUpdateBy: User who try to cancel the document.
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @isCancelable: Identify if the ODC is cancelable or not
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
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
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
-- Description: sp_CancelContractDocument End the contract
CREATE PROCEDURE sp_CancelContractDocument(
    @documentId INT,
   @lastUpdateBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(30) = 'terminateContract';
    DECLARE @Message NVARCHAR(MAX);
    DECLARE @isCancelable BIT;


    BEGIN TRY
        BEGIN TRANSACTION @tranName
        SELECT @isCancelable=  CASE 
                                    WHEN idStatus= 13 THEN 1
                                    ELSE 0
                                END
        FROM  Documents
        WHERE idDocument= @documentId

        IF @isCancelable= 1
            BEGIN
                UPDATE Documents SET 
                    idStatus=  15,
                    lastUpdatedBy=   @lastUpdateBy,
                    lastUpdatedDate=  dbo.fn_MexicoLocalTime(GETDATE())
                WHERE idDocument= @documentId
                SET @Message= 'El contrato se termino con exito';
                SELECT @Message AS [Message]
                COMMIT TRANSACTION @tranName
            END
        ELSE
            BEGIN
                SET @Message= 'El contrato no peude ser terminado debido a que debe estar vigente';
                RAISERROR(@Message, 1,0);
                COMMIT TRANSACTION @tranName
            END


    END TRY

    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()

        DECLARE @createdBy NVARCHAR(30)= @lastUpdateBy;
        DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_CancelContract',@documentId,@lastUpdateBy);
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
    
    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------