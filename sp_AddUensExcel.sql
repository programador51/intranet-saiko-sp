-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-11-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddUensExcel
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
--	2022-11-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 11/11/2022
-- Description: sp_AddUensExcel - Some Notes
CREATE PROCEDURE sp_AddUensExcel(
    @tableAdd UensType READONLY,
    @tableUpdate UensType READONLY,
    @createdBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(30)='addUenExcel';
    DECLARE @itemsToUpdate INT;
    DECLARE @itemsToAdd INT;
    DECLARE @trancount int;
    SET @trancount = @@trancount;
    BEGIN TRY
        IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN 
                SAVE TRANSACTION @tranName
            END

        SELECT @itemsToUpdate= COUNT(*) FROM @tableUpdate
        SELECT @itemsToAdd= COUNT(*) FROM @tableAdd

        IF(@itemsToAdd>0)
            BEGIN
                INSERT INTO UEN (
                    [description],
                    family,
                    subFamily,
                    SATcode,
                    SATUM,
                    [status],
                    iva,
                    createdBy,
                    createdDate,
                    lastUpdatedBy,
                    lastUpdatedDate,
                    marginRate,
                    satCodeDescription,
                    satUmDescription,
                    excent
                )
                SELECT 
                    [description],
                    family,
                    subFamily,
                    satCode,
                    satUM,
                    1,
                    iva,
                    @createdBy,
                    GETUTCDATE(),
                    @createdBy,
                    GETUTCDATE(),
                    marginrate,
                    satCodeDescription,
                    satUmDescription,
                    excent
                FROM @tableAdd
            END
        IF(@itemsToUpdate>0)
            BEGIN
                UPDATE uen SET
                    uen.[description]=updatedUEN.[description],
                    family=updatedUEN.family,
                    subFamily=updatedUEN.subFamily,
                    SATcode=updatedUEN.satCode,
                    SATUM=updatedUEN.satUM,
                    [status]=1,
                    iva=updatedUEN.iva,
                    createdBy=@createdBy,
                    createdDate=GETUTCDATE(),
                    lastUpdatedBy=@createdBy,
                    lastUpdatedDate=GETUTCDATE(),
                    marginRate=updatedUEN.marginrate,
                    satCodeDescription=updatedUEN.satCodeDescription,
                    satUmDescription=updatedUEN.satUmDescription,
                    excent=updatedUEN.excent
                FROM UEN AS uen
                INNER JOIN @tableUpdate AS updatedUEN ON updatedUEN.idUen=uen.UENID
            END
    
        IF (@trancount=0)
            BEGIN
                COMMIT TRANSACTION @tranName
            END 
    END TRY

    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)
        DECLARE @xstate INT= XACT_STATE();

        DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_UpdateDisassociationConceptsExpenses,
            @tableAdd,
            @tableUpdate,
            @createdBy
            ';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
        IF (@xstate= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (@xstate=1 AND @trancount=0)
            BEGIN
                -- COMMIT TRANSACTION @tranName
                ROLLBACK TRANSACTION @tranName
            END

        IF (@xstate=1   AND @trancount > 0)
            BEGIN
                ROLLBACK TRANSACTION @tranName;   
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;

    END CATCH
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------