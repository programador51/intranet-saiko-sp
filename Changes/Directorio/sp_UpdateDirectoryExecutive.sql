-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-09-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateDirectoryExecutive
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
--	2024-05-09		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_UpdateDirectoryExecutive')
    BEGIN 

        DROP PROCEDURE sp_UpdateDirectoryExecutive;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/09/2024
-- Description: sp_UpdateDirectoryExecutive - Some Notes
CREATE PROCEDURE sp_UpdateDirectoryExecutive(
    @customerExecutive CustomerExecutiveType READONLY
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='PaymentRemidnerSp';
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

        UPDATE customers SET
            customers.executiveID = customerExecutive.idExecutive
        FROM Customer_Executive AS customers
        LEFT JOIN @customerExecutive AS customerExecutive ON customers.customerID = customerExecutive.idCustomer
        WHERE customers.customerID = customerExecutive.idCustomer

        UPDATE documents SET
            documents.idExecutive = customerExecutive.idExecutive
        FROM Documents AS documents
        LEFT JOIN @customerExecutive AS customerExecutive ON documents.idCustomer = customerExecutive.idCustomer
        WHERE documents.idCustomer = customerExecutive.idCustomer

        IF (@trancount=0)
            BEGIN
                COMMIT TRANSACTION @tranName
            END
    END TRY

    BEGIN CATCH
        PRINT 'Fallo la funcion'
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