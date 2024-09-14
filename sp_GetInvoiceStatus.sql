-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-18-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetInvoiceStatus
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
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
--	2022-07-18		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/18/2022
-- Description: sp_GetInvoiceStatus - Some Notes
CREATE PROCEDURE sp_GetInvoiceStatus AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @orderType INT =2
    DECLARE @invoiceType INT =10

    SELECT documentStatusID AS [state],
        documentTypeID AS document,
        [description] AS [description],
        [order] AS [order],
        [status] AS logicalErase

    FROM DocumentStatus
    WHERE [status]=1 AND documentTypeID IN (@orderType,@invoiceType)
    ORDER BY [order] ASC

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------