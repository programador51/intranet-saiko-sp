SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_GetPdfHeader](
    @idDocument INT
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    SET LANGUAGE Spanish;
                SELECT
                ISNULL(FORMAT(Documents.documentNumber,'0000000'),'0000001') AS documentNumber,
                DocumentTypes.description AS documentType,
                CASE
                    WHEN Documents.lastUpdatedDate IS NULL THEN  REPLACE(CONVERT(VARCHAR(10),Documents.createdDate,6),' ','/')
                        ELSE  REPLACE(CONVERT(VARCHAR(10),Documents.lastUpdatedDate,6),' ','/')
                END AS fechaCreacion,
                CASE 
                    WHEN CustomerTypes.customerTypeID=5 THEN 'Cliente'
                    ELSE CustomerTypes.description
                END AS CustomerType,
                -- CustomerTypes.description AS CustomerType,
                CONCAT ('RFC: ',Customers.rfc) AS rfc,
                Customers.socialReason AS socialReason,
                CONCAT (
                    ISNULL(Customers.street,' '),' ',
                    ISNULL(Customers.exteriorNumber,' '),', ',
                    ISNULL(Customers.interiorNumber, ' '),', ',
                    ISNULL(Customers.city,' ')
                ) AS Calle,
                CONCAT (
                    ISNULL(Customers.polity,' '),', ',
                    ISNULL(Customers.country,' '),', ',
                    ISNULL (Customers.cp,' ')
                ) AS Pais,
                CONCAT(
                    Contacts.firstName, ' ', Contacts.lastName1,' ',Contacts.lastName2
                ) AS dirigidoA,

                ISNULL(CONCAT ('Telefono: +',Customers.ladaPhone, ' ', Customers.phone),'Telefono: ') AS phoneNumber,
                ISNULL (CONCAT('Celular: +',Customers.ladaMovil,' ',Customers.movil),'Celular: ') AS cellNumber,
				ISNULL(CAST(Documents.idQuotation AS VARCHAR(100)),'ND')AS QuoteID,
				ISNULL(CAST(Documents.idContract AS VARCHAR(100)),'ND')AS ContractID,
				ISNULL(CAST(Documents.idInvoice AS VARCHAR(100)),'ND') AS PrefacturaID,
				ISNULL(CAST(Documents.invoiceMizarNumber AS VARCHAR(100)), 'ND')AS MizarID,
				ISNULL(CAST(Documents.idOC AS VARCHAR(100)),'ND') AS OcID,
				ISNULL(CAST (Documents.idContractParent AS VARCHAR(100)),'ND') AS OrigenID,
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
