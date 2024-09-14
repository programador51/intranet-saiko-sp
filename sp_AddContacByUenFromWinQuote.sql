-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-20-2023
-- Description: Add the contacts by UEN from wining a quote
-- STORED PROCEDURE NAME:	sp_AddContacByUenFromWinQuote
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
--	2023-07-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/20/2023
-- Description: sp_AddContacByUenFromWinQuote - Add the contacts by UEN from wining a quote
CREATE PROCEDURE sp_AddContacByUenFromWinQuote(
    @idDocument INT,
    @createdBy NVARCHAR(256)
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
        DECLARE @status TINYINT= 1;
        DECLARE @updateDate DATETIME;
        SELECT @updateDate= GETUTCDATE();

        DECLARE @idContact INT;
        SELECT 
            @idContact= idContact
        FROM Documents
        WHERE idDocument=@idDocument

        
        IF(@idContact IS NOT NULL)
            BEGIN
                IF OBJECT_ID(N'tempdb..#TempUens') IS NOT NULL 
                    BEGIN
                        DROP TABLE #TempUens
                    END

                CREATE TABLE #TempUens (
                    id INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
                    idUen INT NOT NULL
                )



                INSERT INTO #TempUens (
                    idUen
                )
                SELECT DISTINCT
                    catalogue.uen
                FROM DocumentItems AS items
                LEFT JOIN Catalogue AS catalogue ON catalogue.id_code=items.idCatalogue
                WHERE items.document=@idDocument

                -- SELECT * FROM #TempUens

                INSERT INTO ContactsByUens (
                    idContact,
                    idUen,
                    idDocument,
                    createdBy,
                    [status],
                    updatedDate,
                    updatedBy

                )
                SELECT 
                    @idContact,
                    tempUens.idUen,
                    @idDocument,
                    @createdBy,
                    @status,
                    @updateDate,
                    @createdBy
                FROM #TempUens AS tempUens
                LEFT JOIN ContactsByUens AS contactByUen ON contactByUen.idContact=@idContact
                WHERE contactByUen.idUen!=tempUens.idUen

                IF OBJECT_ID(N'tempdb..#TempUens') IS NOT NULL 

                        BEGIN
                        DROP TABLE #TempUens
                    END
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