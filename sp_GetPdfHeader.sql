-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-07-2021
-- Description: We obtain the Header for every document
-- STORED PROCEDURE NAME:	sp_GetPdfHeader
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: The id of the signed user
-- ===================================================================================================================================
-- Returns:
-- The document date, number, the customer info, the document status, credit days, expiration date, currency, import, iva, total and the user how creates the document
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-09-07		Adrian Alardin   			1.0.0.0			Initial Revision
--	2021-09-09		Adrian Alardin   			1.0.0.1			More Features
-- *****************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetPdfHeader(
    @documentId INT
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    SELECT
            FORMAT(Documents.documentNumber,'0000000') AS documentNumber,
            DocumentTypes.description AS documentType,
            CASE
                WHEN Documents.lastUpdatedDate IS NULL THEN FORMAT (Documents.createdDate,'dd-MM-yy')
                    ELSE FORMAT(Documents.lastUpdatedDate, 'dd-MM-yyyy')
            END AS fechaCreacion,
            CustomerTypes.description AS CustomerType,
            Customers.socialReason,

            CASE
				WHEN Customers.exteriorNumber IS NULL THEN CONCAT (Customers.street , ', ', 'Numero exterior: ###' , ' ', 'Numero interior: ' ,
                    Customers.interiorNumber , ', ' , Customers.suburb)
				WHEN Customers.interiorNumber IS NULL THEN CONCAT (Customers.street , ', ', 'Numero exterior: ' , Customers.exteriorNumber , ', ', 'Numero interior: ###' , ', ' , Customers.suburb)
				ELSE CONCAT (Customers.street , ', ', 'Numero exterior: ' ,Customers.exteriorNumber, ', ', 'Numero interior: ' ,Customers.interiorNumber , ', ' , Customers.suburb)
				END AS Calle,
            CONCAT (Customers.city , ', ' , Customers.polity , ', ' , Customers.country) AS Pais,
            Customers.rfc,
            CASE
                WHEN Customers.ladaPhone IS NULL OR Customers.phone IS NULL THEN 'Telefono: -- --- --- ----'
                    ELSE CONCAT ('Telefono: +',Customers.ladaPhone,' ', Customers.phone)
            END AS phoneNumber,
            CASE
                WHEN Customers.ladaMovil IS NULL OR Customers.movil IS NULL THEN 'Celular: -- --- --- ----'
                    ELSE CONCAT (' Celular: +',Customers.ladaMovil,' ', Customers.movil)
            END AS cellNumber,
            DocumentStatus.description AS status,
            Documents.creditDays,
            FORMAT(Documents.expirationDate, 'dd-MM-yyyy') AS expirationDate,
            Currencies.code,
            CONCAT ('$ ',FORMAT(Documents.subTotalAmount,'N2')) AS subTotal,
            CONCAT ('$ ',FORMAT(Documents.ivaAmount,'N2')) AS IVA,
            CONCAT ('$ ',FORMAT(Documents.totalAmount,'N2')) AS Total,
            Users.initials AS createdBy
        FROM Documents
            INNER JOIN Customers ON Documents.idCustomer=Customers.customerID
            INNER JOIN CustomerTypes ON CustomerTypes.customerTypeID=Customers.customerType
            INNER JOIN DocumentStatus ON Documents.idStatus=DocumentStatus.documentStatusID
            INNER JOIN Currencies ON Documents.idCurrency= Currencies.currencyID
            INNER JOIN DocumentTypes ON Documents.idTypeDocument= DocumentTypes.documentTypeID
            INNER JOIN Users ON Documents.idExecutive = Users.userID
        WHERE Documents.idDocument=@idDocument

END
GO