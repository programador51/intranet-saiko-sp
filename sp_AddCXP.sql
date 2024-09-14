-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-08-2022
-- Description: Add the CXP
-- STORED PROCEDURE NAME:	sp_AddCXP
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- idExecutive: The executive.
-- idCustomer: Customer id.
-- idCurrency: Currency Id.
-- expirationDate: Expiration date.
-- reminderDate: Reminder Date.
-- currentFaction: Currenct Faction.
-- creditDays: Credit days.
-- amountToPay: Amount to pay.
-- totalAmount: Total amount to pay.
-- createdBy:User who create the record .
-- lastUpdatedBy: The last user who modify the record.
-- uuid: The UUID.
-- partialitiesRequested: Partialities requested.
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @idProgress:Document progress (12)
-- @idStatus:The document status (20)
-- ===================================================================================================================================
-- Returns:
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/08/2022
-- Description: sp_AddCXP -Add the CXP
-- =============================================
CREATE PROCEDURE sp_AddCXP
    (
    @idExecutive INT,
    @idCustomer INT,
    @idCurrency INT,
    @expirationDate DATETIME,
    @reminderDate DATETIME,
    @currentFaction INT,
    @creditDays DECIMAL (14,4),
    @amountToPay DECIMAL (14,4),
    @totalAmount DECIMAL (14,4),
    @createdBy NVARCHAR(30),
    @lastUpdatedBy NVARCHAR(30),
    @uuid NVARCHAR(256),
    @partialitiesRequested INT
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    -- UPDATE Documents
    
-- ----------------- ↓↓↓ VARIABLES DECLARATION ↓↓↓ -----------------------
    DECLARE @idProgress INT=12;
    DECLARE @idStatus INT=20;
    DECLARE @idTypeDocument INT=4;
-- ----------------- ↑↑↑ VARIABLES DECLARATION↑↑↑ -----------------------


-- ----------------- ↓↓↓ INSERT STATEMENT ↓↓↓ -----------------------

    INSERT INTO Documents
( -- columns to insert data into
    idExecutive,
    idCustomer,
    idCurrency,
    idTypeDocument,
    createdDate,
    lastUpdatedDate,
    expirationDate,
    reminderDate,
    idProgress,
    currectFaction,
    creditDays,
    amountToPay,
    idStatus,
    subTotalAmount,
    totalAmount,
    createdBy,
    lastUpdatedBy,
    uuid,
    partialitiesRequested
)
VALUES
( 
    @idExecutive,
    @idCustomer,
    @idCurrency,
    @idTypeDocument,
    dbo.fn_MexicoLocalTime(GETDATE()),
    dbo.fn_MexicoLocalTime(GETDATE()),
    @expirationDate,
    @reminderDate,
    @idProgress, 
    @currentFaction,
    @creditDays,
    @amountToPay,
    @idStatus,
    @totalAmount,
    @totalAmount,
    @createdBy,
    @lastUpdatedBy,
    @uuid,
    @partialitiesRequested
)

-- ----------------- ↑↑↑ INSERT STATEMENT ↑↑↑ -----------------------
SELECT SCOPE_IDENTITY() AS ID
END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------