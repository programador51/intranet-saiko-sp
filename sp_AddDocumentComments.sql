-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-09-2021

-- Description: Save the comments made to an specific document with his ID

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  06-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
--  11-10-2021     Jose Luis Perez             2.0.0.0         Data saved in another table		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddDocumentComments(
    @description NVARCHAR(200),
    @idDocument INT,
    @createdBy NVARCHAR(30)
    @order INT
)

AS BEGIN

    INSERT INTO Commentation

    (
        documentId , createdDate , "order" ,
        status , comment , createdBy , commentTypeId
    )

    VALUES

    (
        @idDocument , GETDATE() , @order ,
        1 , @description , @createdBy , 5
    )

END
