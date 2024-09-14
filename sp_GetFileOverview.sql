-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 05-10-2021
-- Description: gets the information of the signed user
-- STORED PROCEDURE NAME:	sp_GetFileOverview
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idCustomer: Id of the customer to fetch the overview customer info
-- @idDocument: Id of the document to fetch the overview info of the label

-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	05-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_GetFileOverview(
    @idCustomer INT,
    @idDocument INT
)

AS BEGIN

    SELECT
            Customers.customerID AS id,
            Customers.commercialName AS socialReason

        FROM Customers

        WHERE 
            Customers.customerID = @idCustomer;

    SELECT 
            Documents.idDocument AS [document.id],
            Documents.documentNumber AS [document.number],
            DocumentTypes.description AS [document.type.description],
            DocumentTypes.documentTypeId AS [document.type.id]

        FROM Documents

        INNER JOIN DocumentTypes ON Documents.idTypeDocument = DocumentTypes.documentTypeId
        
        WHERE Documents.idDocument = @idDocument

        FOR JSON PATH, ROOT('documentInfo'), INCLUDE_NULL_VALUES;

END

-- *******************************************************************************************************************************
-- EXPECTED RESULT TO RETURN ON API IF THE INFORMATION WAS FOUNDED
-- {
--     "status": 200,
--     "overviewInfo": {
--         "customer": {
--             "id": 217,
--             "socialReason": "JLPOTest2"
--         },
--         "document": {
--             "id": 483,
--             "number": 12,
--             "type": {
--                 "description": "Cotizacion",
--                 "id": 1
--             }
--         }
--     }
-- }