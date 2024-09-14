-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-18-2023
-- Description: Update the contacts by UEN
-- STORED PROCEDURE NAME:	sp_UpdateContactByUen
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
--	2023-07-18		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/18/2023
-- Description: sp_UpdateContactByUen - Some Notes
CREATE PROCEDURE sp_UpdateContactByUen(
    @activeContacByUen ContactByUen READONLY,
    @disbaleContacByUen ContactByUen READONLY,
    @updatedBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(50)='addContactsByUen';
    DECLARE @trancount INT;
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
        DECLARE @status TINYINT= 0;
        DECLARE @updateDate DATETIME;
        SELECT @updateDate= GETUTCDATE();

        UPDATE contactsByUen SET
            contactsByUen.idContact=disableUen.idContact,
            contactsByUen.idUen=disableUen.idUen,
            contactsByUen.[status]=@status,
            contactsByUen.updatedBy=@updatedBy,
            contactsByUen.updatedDate=@updateDate
        FROM ContactsByUens AS contactsByUen
        INNER JOIN @disbaleContacByUen AS disableUen  ON contactsByUen.idContact= disableUen.idContact 
        WHERE 
            contactsByUen.idContact=disableUen.idContact AND 
            contactsByUen.idUen=disableUen.idUen;


        INSERT INTO ContactsByUens (
            idContact,
            idUen,
            createdBy,
            [status],
            updatedBy,
            updatedDate
            
        )
        SELECT 
            temContactByUen.idContact,
            temContactByUen.idUen,
            @updatedBy,
            @status,
            @updatedBy,
            @updateDate
        FROM @activeContacByUen AS temContactByUen
        LEFT JOIN ContactsByUens AS contacByUen ON contacByUen.idContact = temContactByUen.idContact
        WHERE contacByUen.idUen !=temContactByUen.idUen

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

        DECLARE @infoSended NVARCHAR(MAX)= 'Sin informacion por el momento';
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

        IF (@xstate=1 AND @trancount > 0)
            BEGIN
                ROLLBACK TRANSACTION @tranName;
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;

    END CATCH
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------