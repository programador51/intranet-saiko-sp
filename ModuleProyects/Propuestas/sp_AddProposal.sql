-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-05-2024
-- Description: Add a proposal
-- STORED PROCEDURE NAME:	sp_AddProposal
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @positions: The positions to add
-- @idExecutive: The executive id
-- @createdBy: The person who created the record
-- @attn: The attention of the proposal
-- @expirationDate: The expiration date of the proposal
-- @paymentTerms: The payment terms of the proposal
-- @termsAndConditions: The terms and conditions of the proposal
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @idProyect: The project id
-- @idCustomer: The customer id
-- @subTotal: The subtotal of the proposal
-- @iva: The iva of the proposal
-- @idProposal: The proposal id
-- @tranName: The transaction name
-- @trancount: The transaction count
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-08-05		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddProposal')
    BEGIN 

        DROP PROCEDURE sp_AddProposal;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/05/2024
-- Description: sp_AddProposal - Add a proposal
CREATE PROCEDURE sp_AddProposal(
    @positions ProposalPositionIdType READONLY,
    @idExecutive INT,
    @createdBy NVARCHAR(30),
    @attn NVARCHAR(256),
    @expirationDate DATE,
    @paymentTerms NVARCHAR(256),
    @termsAndConditions NVARCHAR(MAX)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @idProyect INT;
    DECLARE @idCustomer INT;
    DECLARE @subTotal DECIMAL(14,4);
    DECLARE @iva DECIMAL(14,4);
    DECLARE @idProposal INT;

    DECLARE @tranName NVARCHAR(50) = 'addProposal';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
    BEGIN TRY
        IF (@trancount = 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName;
            END

    
        UPDATE proposal SET
            proposal.proposalStatus ='Cancelada',
            proposal.status= 0
        FROM ProyectProposals AS proposal
        LEFT JOIN ProposalPositionIndex AS proposalIndex ON proposalIndex.idProposal = proposal.id
        WHERE proposalIndex.idPosition IN (SELECT idPosition FROM @positions);
        
        SELECT 
            @idProyect = idProject
        FROM PositionsProyects
        WHERE id IN (SELECT TOP(1) idPosition FROM @positions);

        SELECT 
            @idCustomer = idClient
        FROM Proyects
        WHERE id = @idProyect;

        SELECT 
            @subTotal = SUM(sell),
            @iva = SUM(ivaSellAmount)
        FROM PositionsProyects
        WHERE id IN (SELECT idPosition FROM @positions);


        INSERT INTO ProyectProposals(
            idCustomer,
            idExecutive,
            idProyect,
            proposalNumber,
            subTotal,
            iva,
            attn,
            expirationDate,
            paymentTerms,
            termsAndConditions,
            createdBy,
            updatedBy
        )
        VALUES (
            @idCustomer,
            @idExecutive,
            @idProyect,
            'P' + CAST(@idProyect AS NVARCHAR(256)) + '-' + CAST((SELECT COUNT(*) FROM ProyectProposals WHERE idProyect = @idProyect) AS NVARCHAR(256)),-- NombreCorto+NumeroConcencutivo.
            @subTotal,
            @iva,
            @attn,
            @expirationDate,
            @paymentTerms,
            @termsAndConditions,
            @createdBy,
            @createdBy
        )

        SELECT 
            @idProposal = SCOPE_IDENTITY();
        
        INSERT INTO ProposalPositionIndex(
            idProposal,
            idPosition,
            positionDescription,
            createdBy,
            updatedBy
        )
        SELECT 
            @idProposal,
            idPosition,
            positionDescription,
            @createdBy,
            @createdBy
        FROM @positions;

    IF (@trancount = 0)
            BEGIN
                COMMIT TRANSACTION @tranName;
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