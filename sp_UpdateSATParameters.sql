-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-20-2022
-- Description: Update the default parameters of the payment methods, use of CFDI and the form of payment for the SAT
-- STORED PROCEDURE NAME:	sp_UpdateSATParameters
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
--	2022-05-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/20/2022
-- Description: sp_UpdateSATParameters - Update the default parameters of the payment methods, use of CFDI and the form of payment for the SAT
CREATE PROCEDURE sp_UpdateSATParameters(
    @cfdiId NVARCHAR(100),
    @payFormId NVARCHAR(100),
    @payMethodId NVARCHAR(100),
    @lastUpdateBy NVARCHAR(30)
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(30) ='updateSAT';
    BEGIN TRY
        BEGIN TRANSACTION @tranName

        UPDATE Parameters
            SET [value]=@cfdiId,
            lastUpdatedBy=@lastUpdateBy,
            lastUpdatedDate= dbo.fn_MexicoLocalTime(GETDATE())
        WHERE parameter=31
        UPDATE Parameters
            SET [value]=@payFormId,
            lastUpdatedBy=@lastUpdateBy,
            lastUpdatedDate= dbo.fn_MexicoLocalTime(GETDATE())
        WHERE parameter=33 
        UPDATE Parameters
            SET [value]=@payMethodId,
            lastUpdatedBy=@lastUpdateBy,
            lastUpdatedDate= dbo.fn_MexicoLocalTime(GETDATE())
        WHERE parameter=34

        SELECT @@ROWCOUNT AS rowAfected

        COMMIT TRANSACTION @tranName;

    END TRY

    BEGIN CATCH

    DECLARE @createdBy NVARCHAR(30)= @lastUpdateBy;
    DECLARE @infoSended NVARCHAR(MAX)= CONCAT ('Informacion que se trato de enviar en orden para el SP sp_sp_UpdateSATParameters',@cfdiId,@payFormId,@payMethodId,@lastUpdateBy);
    DECLARE @wasAnError TINYINT=1;
    DECLARE @mustBeSyncManually TINYINT=1;
    DECLARE @provider TINYINT=4;

    DECLARE @Message NVARCHAR(MAX)=ERROR_MESSAGE();
    DECLARE @Severity  INT= ERROR_SEVERITY()
    DECLARE @State   SMALLINT = ERROR_SEVERITY()


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