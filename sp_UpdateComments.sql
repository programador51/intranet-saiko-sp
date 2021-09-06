-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-09-2021

-- Description: Insert document items. This items will be related with specific documents
-- using the id of the document

-- ===================================================================================================================================
-- PARAMETERS:
-- @id: ID of the comment to update
-- @description: New content of the comment
-- @order: Order that the comment must have on the UI when it's fetched
-- @modifyBy: Fullname of the executive who edited the comment

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_UpdateComments(
    @id INT,
    @description NVARCHAR(200),
    @order INT,
    @modifyBy NVARCHAR(30)
)

AS BEGIN

UPDATE Comments 

SET

    description = @description,
    [order] = @order,
    lastUpdatedBy = @modifyBy,
    lastUpdatedDate = GETDATE()
        
WHERE idComment = @id

END