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
--	2021-09-24		Adrian Alardin   			1.0.0.4			We add more info to return QuoteID, ContractID, PrefacturaID, MizarID, OcID, OrigenID
--	2021-10-11		Adrian Alardin   			1.0.0.5			It change the currency format.
-- *****************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetPdfHeader(
    @idDocument INT
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    SET LANGUAGE Spanish;

    -- Insert statements for procedure here
    SET LANGUAGE Spanish;
                SET LANGUAGE Spanish;
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
				ISNULL(CAST(Documents.idQuotation AS VARCHAR(100)),'ND')AS QuoteID,
				ISNULL(CAST(Documents.idContract AS VARCHAR(100)),'ND')AS ContractID,
				ISNULL(CAST(Documents.idInvoice AS VARCHAR(100)),'ND') AS PrefacturaID,
				ISNULL(CAST(Documents.invoiceMizarNumber AS VARCHAR(100)), 'ND')AS MizarID,
				ISNULL(CAST(Documents.idOC AS VARCHAR(100)),'ND') AS OcID,
				ISNULL(CAST (Documents.idContractParent AS VARCHAR(100)),'ND') AS OrigenID,
                Customers.rfc,
				CASE 
					WHEN Contacts.email IS NOT NULL THEN Contacts.email
					WHEN (Contacts.email IS NULL) AND (Customers.email IS NOT NULL) THEN Customers.email
					ELSE '-1'
					END AS customerEmail,
				CASE 
					WHEN Contacts.email IS NOT NULL THEN CONCAT (Contacts.firstName, ' ',Contacts.middleName,' ',Contacts.lastName1,' ',Contacts.lastName2)
					ELSE '-1'
				END AS contactName,
                DocumentStatus.description AS status,
                Documents.creditDays,
                REPLACE(CONVERT(VARCHAR(10),Documents.expirationDate,6),' ','/') AS expirationDate,
                Currencies.code,
                FORMAT(Documents.subTotalAmount,'C','mx-MX') AS subTotal,
                FORMAT(Documents.ivaAmount,'C','mx-MX') AS IVA,
                FORMAT(Documents.totalAmount,'C','mx-MX') AS Total,
                Users.initials AS createdBy,
                Users.email AS userEmail,
				CONCAT (Users.firstName,' ',Users.middleName, ' ',Users.lastName1, ' ',Users.lastName2) AS name
            FROM Documents
                LEFT JOIN Customers ON Documents.idCustomer=Customers.customerID
                LEFT JOIN CustomerTypes ON CustomerTypes.customerTypeID=Customers.customerType
                LEFT JOIN DocumentStatus ON Documents.idStatus=DocumentStatus.documentStatusID
                LEFT JOIN Currencies ON Documents.idCurrency= Currencies.currencyID
                LEFT JOIN DocumentTypes ON Documents.idTypeDocument= DocumentTypes.documentTypeID
                LEFT JOIN Users ON Documents.idExecutive = Users.userID
				LEFT JOIN Contacts ON Documents.idContact= Contacts.contactID
            WHERE Documents.idDocument=@idDocument

END
GO