-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-04-2024
-- Description: Add a new proyect
-- STORED PROCEDURE NAME:	sp_AddProyect
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @buyer Buyer name
-- @buyerEmail Buyer email
-- @closeDate Close date
-- @comments Comments
-- @link Link
-- @noRFQ No RFQ
-- @solped Solped
-- @title Title
-- @buyerPhone Buyer phone
-- @user User
-- @userEmail User email
-- @userPhone User phone
-- @createdBy Created by
-- @updatedBy Updated by
-- ===================================================================================================================================
-- =============================================
-- ===================================================================================================================================
-- Returns: 
-- idProyect INT
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-06-04		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddProyect')
    BEGIN 

        DROP PROCEDURE sp_AddProyect;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/04/2024
-- Description: sp_AddProyect - Add a new proyect
CREATE PROCEDURE sp_AddProyect(
    @buyer NVARCHAR(1000),
    @buyerEmail NVARCHAR(1000),
    @closeDate DATE,
    @comments NVARCHAR(MAX),
    @link NVARCHAR(1000),
    @noRFQ NVARCHAR(256),
    @solped NVARCHAR(1000),
    @title NVARCHAR(256),
    @buyerPhone NVARCHAR(15),
    @user NVARCHAR(256),
    @userEmail NVARCHAR(256),
    @userPhone NVARCHAR(15),
    @createdBy NVARCHAR(256),
    @updatedBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='addProyect';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
    DECLARE @status NVARCHAR(50)='Solicitud';
    BEGIN TRY
        IF (@trancount= 0)
                BEGIN
                    BEGIN TRANSACTION @tranName;
                END
            ELSE
                BEGIN
                    SAVE TRANSACTION @tranName
                END


        INSERT INTO Proyects (
            buyer,
            buyerEmail,
            closeDate,
            comments,
            link,
            noRFQ,
            solped,
            title,
            buyerPhone,
            [user],
            userEmail,
            userPhone,
            createdBy,
            updatedBy,
            [status]
        )
        VALUES (
            @buyer,
            @buyerEmail,
            @closeDate,
            @comments,
            @link,
            @noRFQ,
            @solped,
            @title,
            @buyerPhone,
            @user,
            @userEmail,
            @userPhone,
            @createdBy,
            @updatedBy,
            @status
        )
        SELECT SCOPE_IDENTITY() AS idProyect;


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