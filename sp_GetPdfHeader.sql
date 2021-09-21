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
--	2021-09-09		Adrian Alardin   			1.0.0.2			It changes the Inner joins for left joins
--	2021-09-21		Adrian Alardin   			1.0.0.3			It changes the date format (dd/MMM/yy)
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
    SET LANGUAGE Spanish;

    -- Insert statements for procedure here
    SELECT
                ISNULL(FORMAT(Documents.documentNumber,'0000000'),'0000001') AS documentNumber,
                DocumentTypes.description AS documentType,
                CASE
                    WHEN Documents.lastUpdatedDate IS NULL THEN  REPLACE(CONVERT(VARCHAR(10),Documents.createdDate,6),' ','/')
                        ELSE  REPLACE(CONVERT(VARCHAR(10),Documents.lastUpdatedDate,6),' ','/')
                END AS fechaCreacion,
                CustomerTypes.description AS CustomerType,
                Customers.socialReason,
                CONCAT (
                ISNULL(CONCAT('Calle: ',Customers.street),'Calle: '),' ',
                ISNULL(CONCAT('Numero Exterior: ',Customers.exteriorNumber),'Numero Exterior: '), ' ',
                ISNULL (CONCAT('Numero Interior: ',Customers.interiorNumber),'Numero Interior: ')
                ) AS Calle,
                CONCAT(
                ISNULL(CONCAT ('Ciudad: ',Customers.city),'Ciudad: '), ' ',
                ISNULL(CONCAT ('Estado: ',Customers.polity),'Estado: '), ' ',
                ISNULL(CONCAT('Pais: ',Customers.country),'Pais: ')
                ) AS Pais,
                ISNULL(CONCAT ('Telefono: +',Customers.ladaPhone, ' ', Customers.phone),'Telefono: ') AS phoneNumber,
                ISNULL (CONCAT('Celular: +',Customers.ladaMovil,' ',Customers.movil),'Celular: ') AS cellNumber,
                Customers.rfc,
                Customers.email AS customerEmail,
                DocumentStatus.description AS status,
                Documents.creditDays,
                REPLACE(CONVERT(VARCHAR(10),Documents.expirationDate,6),' ','/') AS expirationDate,
                Currencies.code,
                CONCAT ('$',FORMAT(Documents.subTotalAmount,'N2')) AS subTotal,
                CONCAT ('$',FORMAT(Documents.ivaAmount,'N2')) AS IVA,
                CONCAT ('$',FORMAT(Documents.totalAmount,'N2')) AS Total,
                Users.initials AS createdBy,
                Users.email AS userEmail
            FROM Documents
                LEFT JOIN Customers ON Documents.idCustomer=Customers.customerID
                LEFT JOIN CustomerTypes ON CustomerTypes.customerTypeID=Customers.customerType
                LEFT JOIN DocumentStatus ON Documents.idStatus=DocumentStatus.documentStatusID
                LEFT JOIN Currencies ON Documents.idCurrency= Currencies.currencyID
                LEFT JOIN DocumentTypes ON Documents.idTypeDocument= DocumentTypes.documentTypeID
                LEFT JOIN Users ON Documents.idExecutive = Users.userID
            WHERE Documents.idDocument=@idDocument

END
GO