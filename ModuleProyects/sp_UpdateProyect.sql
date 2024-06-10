-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-10-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateProyect
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @id INT - Id
-- @buyerEmail NVARCHAR(1000) - Buyer email
-- @buyerPhone NVARCHAR(15) - Buyer phone
-- @user NVARCHAR(256) - User
-- @userEmail NVARCHAR(256) - User email
-- @userPhone NVARCHAR(15) - User phone
-- @comments NVARCHAR(MAX) - Comments
-- @status NVARCHAR(255) - Status
-- @updatedBy NVARCHAR(256) - Updated by
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @updateDate DATETIME - Update date
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-06-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_UpdateProyect')
    BEGIN 

        DROP PROCEDURE sp_UpdateProyect;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/10/2024
-- Description: sp_UpdateProyect - Update a proyect
CREATE PROCEDURE sp_UpdateProyect(
    @id INT,
    @buyerEmail NVARCHAR(1000),
    @buyerPhone NVARCHAR(15),
    @user NVARCHAR(256),
    @userEmail NVARCHAR(256),
    @userPhone NVARCHAR(15),
    @comments NVARCHAR(MAX),
    @status NVARCHAR(255),
    @updatedBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @updateDate DATETIME = GETUTCDATE();
    DECLARE @tranName NVARCHAR(50)='updateProyect';
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

        UPDATE Proyects SET 
            buyerEmail = @buyerEmail,
            buyerPhone = @buyerPhone,
            [user] = @user,
            userEmail = @userEmail,
            userPhone = @userPhone,
            comments = @comments,
            [status] = @status,
            updatedBy = @updatedBy,
            updatedDate = @updateDate
        WHERE id = @id;


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