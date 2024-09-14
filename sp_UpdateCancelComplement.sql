-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-08-2022
-- Description: Cancel the complement
-- STORED PROCEDURE NAME:	sp_UpdateCancelComplement
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
--	2022-09-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/08/2022
-- Description: sp_UpdateCancelComplement - Some Notes
CREATE PROCEDURE sp_UpdateCancelComplement(
    @uuid NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50) = 'CancelComplement';
    BEGIN TRY
        BEGIN TRANSACTION @tranName
        UPDATE Complements SET 
            [status]=0
        WHERE uuid=@uuid AND [status]=1

        COMMIT TRANSACTION @tranName;
    END TRY
    BEGIN CATCH
            DECLARE @Severity  INT= ERROR_SEVERITY()
            DECLARE @State   SMALLINT = ERROR_SEVERITY()
            DECLARE @Message   NVARCHAR(MAX)

            DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de actualizar el complemento
            SP sp_UpdateCancelComplement
                    @uuid,
                    ';
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
            EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;

    END CATCH
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------