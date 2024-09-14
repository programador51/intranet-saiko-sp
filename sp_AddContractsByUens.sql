-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-19-2022
-- Description: Associates the contract with all the UENS it contains
-- STORED PROCEDURE NAME:	sp_AddContractsByUens
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idContract: Contract id
-- @arrayUENS: Array of Uens ids
-- @createdBy: Created by
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
--	2022-08-19		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/19/2022
-- Description: sp_AddContractsByUens - Associates the contract with all the UENS it contains
CREATE PROCEDURE sp_AddContractsByUens(
    @idContract INT,
    @arrayUENS NVARCHAR(MAX),
    @createdBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @status INT =1
    DECLARE @tranName NVARCHAR(50)='addContractByUen'

    BEGIN TRY
        BEGIN TRANSACTION @tranName
        IF EXISTS (SELECT id FROM ContractByUENS WHERE idContract=@idContract AND [status]=1 )
            BEGIN
                PRINT 'EL CONTRATO EXISTE';
                DELETE ContractByUENS WHERE idContract= @idContract;
                INSERT INTO ContractByUENS (
                    idContract,
                    idUen,
                    createdBy,
                    createdDate,
                    lasUpdateBy,
                    lastUpdatedDate,
                    [status]
                )
                SELECT 
                    @idContract,
                    [value],
                    @createdBy,
                    GETUTCDATE(),
                    @createdBy,
                    GETUTCDATE(),
                    @status
                FROM STRING_SPLIT(@arrayUENS, ',')
                WHERE RTRIM([value])<>''
                COMMIT TRANSACTION @tranName
            END
        ELSE
            BEGIN 
                PRINT 'EL CONTRATO NO EXISTE';
                INSERT INTO ContractByUENS (
                    idContract,
                    idUen,
                    createdBy,
                    createdDate,
                    lasUpdateBy,
                    lastUpdatedDate,
                    [status]
                )
                SELECT 
                    @idContract,
                    [value],
                    @createdBy,
                    GETUTCDATE(),
                    @createdBy,
                    GETUTCDATE(),
                    @status
                FROM STRING_SPLIT(@arrayUENS, ',')
                WHERE RTRIM([value])<>''

                COMMIT TRANSACTION @tranName

            END

    END TRY


    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
            DECLARE @State   SMALLINT = ERROR_SEVERITY()
            DECLARE @Message   NVARCHAR(MAX)

            DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_AddContractsByUens,@idContract,@arrayUENS,@createdBy';
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