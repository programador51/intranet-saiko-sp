-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-10-2023
-- Description: Add and update posted records
-- STORED PROCEDURE NAME:	sp_AddAccounted
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
    -- @accounted List of records to accounted
    -- @deaccounted List of records to deaccounted
    -- @idFrom id from type [1,2,3,4,5]
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-10-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 10/10/2023
-- Description: sp_AddAccounted - Add and update posted records
CREATE PROCEDURE sp_AddAccounted(
    @accounted NVARCHAR(MAX),
    @deaccounted NVARCHAR(MAX),
    @idFrom INT,
    @createdBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='addAccounted';
    DECLARE @trancount INT;
    DECLARE @markAsAccounted BIT =1;
    DECLARE @markAsDeaccounted BIT =0;
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

        IF (@accounted IS NOT NULL)
            BEGIN
                DECLARE @ToAdd TABLE (
                    id INT NOT NULL IDENTITY(1,1),
                    idRecord INT NOT NULL
                )
               
                INSERT INTO @ToAdd (idRecord)
                SELECT
                    CAST(value AS INT)
                FROM STRING_SPLIT(@accounted, ',')
                WHERE RTRIM(value)<>'' ;

                

                -- Inserta en la tabla accounted los registros que se marcan como 'Accounted'
                INSERT INTO Accounted (
                    idFrom,
                    idRecord,
                    accounted,
                    createdBy
                )
                SELECT
                    @idFrom,
                    toAdd.idRecord,
                    @markAsAccounted,
                    @createdBy
                FROM @ToAdd AS toAdd
                WHERE NOT EXISTS (SELECT accounted.idRecord FROM Accounted AS accounted WHERE accounted.idRecord = toAdd.idRecord AND accounted.idFrom=@idFrom);


                -- Lo que estaba en la tabla las marca como 'Accounted'
                UPDATE accounted SET
                    accounted=@markAsAccounted
                FROM Accounted AS accounted
                INNER JOIN @ToAdd AS toUpdate ON toUpdate.idRecord= accounted.idRecord
                WHERE 
                    accounted.idFrom=@idFrom;

            END
            IF (@deaccounted IS NOT NULL)
                BEGIN
                    DECLARE @ToUpdate TABLE (
                        id INT NOT NULL IDENTITY(1,1),
                        idRecord INT NOT NULL
                    )
                    INSERT INTO @ToUpdate (idRecord)
                            SELECT
                                CAST(value AS INT)
                            FROM STRING_SPLIT(@deaccounted, ',')
                            WHERE RTRIM(value)<>'' ;
                    -- Lo que estaba en la tabla las desmarca y quedan como 'Deaccounted'
                    UPDATE accounted SET
                        accounted=@markAsDeaccounted
                    FROM Accounted AS accounted
                    INNER JOIN @ToUpdate AS toUpdate ON toUpdate.idRecord= accounted.idRecord
                    WHERE 
                        accounted.idFrom=@idFrom;
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