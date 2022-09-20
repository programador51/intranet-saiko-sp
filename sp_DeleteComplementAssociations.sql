-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-08-2022
-- Description: Delete the associations.
-- STORED PROCEDURE NAME:	sp_DeleteComplementAssociations
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- 
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
-- Description: sp_DeleteComplementAssociations - Delete the associations.
CREATE PROCEDURE sp_DeleteComplementAssociations(
    @uuid NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50) = 'DeleteAssociations';
    BEGIN TRY
        BEGIN TRANSACTION @tranName;
        DELETE FROM AssociationsComplements WHERE uuidComplement=@uuid AND [status]=1;
        COMMIT TRANSACTION @tranName;
    END TRY

    BEGIN CATCH
            DECLARE @Severity  INT= ERROR_SEVERITY()
            DECLARE @State   SMALLINT = ERROR_SEVERITY()
            DECLARE @Message   NVARCHAR(MAX)

            DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de actualizar el complemento
            SP sp_DeleteComplementAssociations
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