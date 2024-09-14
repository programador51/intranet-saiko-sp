-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-05-2022
-- Description: Acept or reject the authorization, terminates the ToDo an create a new one
-- STORED PROCEDURE NAME:	sp_UpdateResponseAuthorization
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @isAuthorized
-- @repply
-- @limitTime
-- @tc
-- @partialities
-- @idTodo
-- @idExecutive
-- @updatedBy
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
--	2022-07-05		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/05/2022
-- Description: sp_UpdateResponseAuthorization - Acept or reject the authorization, terminates the ToDo an create a new one
CREATE PROCEDURE sp_UpdateResponseAuthorization(
    @isAuthorized BIT,
    @repply NVARCHAR(256),
    @limitTime DATETIME,
    @tc DECIMAL(14,2),
    @partialities INT,
    @idTodo INT,
    @idExecutive INT,
    @updatedBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idFrom INT;
    DECLARE @idCustomer INT;
    DECLARE @todayUTC DATETIME;
    DECLARE @parent NVARCHAR(256);

    SELECT @todayUTC = GETUTCDATE();

    DECLARE @idExecutiveRequested INT;
    SELECT 
        @idExecutiveRequested =executiveWhoCreatedId,
        @idFrom=fromId,
        @idCustomer= customerId,
        @parent= parent
    FROM ToDo WHERE id=@idTodo;

    EXEC sp_UpdateTerminateToDo @idTodo,@idExecutive,@updatedBy;

    EXEC sp_AddToDo 
        NULL,
        @todayUTC,
        @updatedBy,
        @idExecutive,
        @idFrom,
        5,
        -200,
        @todayUTC,
        'Autorizaciones',
        'Respuesta de la solisitud de autorización',
        @repply,
        @idCustomer,
        @parent;
    EXEC sp_UpdateAuthorizationRequest 
    1,
    @updatedBy,
    @todayUTC,
    @limitTime,
    @partialities,
    @tc,
    @isAuthorized,
    @idFrom;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------