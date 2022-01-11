-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 15-12-2021
-- Description: Insert the ingress/egress 
-- STORED PROCEDURE NAME:	sp_AddIngressEgress
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @bank : The bank id
-- @movementType : The movement type [ingress|egress]
-- @movementTypeNumber : The movement type id
-- @reference : The reference of the movement
-- @concept: The concept
-- @amount : The ingress/egress import amount
-- @status : The status
-- @createdBy : The executive
-- @bankAccount : The bank account
-- @customerAssociated :The customer associated to that movement
-- @movementDate :The date the movement was added
-- ===================================================================================================================================
-- Returns:
-- 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-12-16		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_AddIngressEgress(
        @bank INT,
        @movementType TINYINT,
        @movementTypeNumber INT,
        @reference NVARCHAR(30),
        @concept NVARCHAR(256),
        @amount DECIMAL(14,4),
        @status TINYINT,
        @createdBy NVARCHAR(30),
        @bankAccount INT,
        @customerAssociated INT,
        @movementDate NVARCHAR(30)

    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON -- Insert statements for procedure here
SET
    LANGUAGE Spanish;
INSERT INTO Movements
                (
                    bankID,movementType,movementTypeNumber,
                    reference,concept,amount,
                    status,createdBy,createdDate,
                    movementDate,
                    bankAccount,customerAssociated,saldo
                )
                
                VALUES

                (
                    @bank,@movementType,@movementTypeNumber,
                    @reference,@concept,@amount,
                    @status,SUBSTRING(@createdBy,0,30),GETDATE(),
                    CONVERT(DATETIME,@movementDate,102),
                    @bankAccount,@customerAssociated,@amount
                )
END
GO