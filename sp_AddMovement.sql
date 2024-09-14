-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-27-2021

-- Description: Add a new movement (egress or incoming) associated with a bank account

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @bank: Bank associated with the bank account
-- @movementType (FK): Type of movement (egress of incoming)
-- @movementTypeNumber (FK): Type of movement (egress of incoming)
-- @reference: Reference of the movement
-- @concept: Concept of the movement created
-- @amount: Cost of the movement
-- @status: 1 acitve and 0 inactive
-- @createdBy: First name, middlename and lastName1
-- @bankAccount (FK): Bank account it correspond that movement
-- @customerAssociated (FK): Which customer correspond that movement
-- @movementDate: Date it corresponds the movement, format YYYY-MM-DD

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  2021-07-27      Jose Luis Perez             1.0.0.0         Creation of query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddMovement(
    @bank INT
    @movementType TINYINT,
    @movementTypeNumber INT,
    @reference NVARCHAR(30),
    @concept NVARCHAR(256),
    @amount DECIMAL(14,4),
    @status TINYINT,
    @createdBy NVARCHAR(30),
    @bankAccount INT,
    @customerAssociated INT,
    @movementDate NVARCHAR(15)

)

AS BEGIN

INSERT INTO Movements
(
    bankID,movementType,movementTypeNumber,
    reference,concept,amount,
    status,createdBy,createdDate,
    movementDate,
    bankAccount,customerAssociated
)

VALUES

(
    @bank,@movementType,@movementTypeNumber,
    @reference,@concept,@amount,
    @status,@createdBy,GETDATE(),
    CONVERT(DATETIME,@movementDate,102),
    @bankAccount,@customerAssociated
)

END