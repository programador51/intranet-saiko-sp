SELECT
    currentDoc.idDocument,
    currentDoc.idQuotation,
    currentDoc.idInvoice,
    currentDoc.idContract,
    currentDoc.idOC,
    currentDoc.idTypeDocument,
    contractDoc.idDocument AS contractId
FROM Documents AS currentDoc
LEFT JOIN Documents AS contractDoc ON contractDoc.idDocument=currentDoc.idContract
WHERE currentDoc.idDocument=3683


IF OBJECT_ID(N'tempdb..#QuoteDocument') IS NOT NULL 
        BEGIN
        DROP TABLE #QuoteDocument
    END
IF OBJECT_ID(N'tempdb..#OrderDocument') IS NOT NULL 
        BEGIN
        DROP TABLE #OrderDocument
    END
IF OBJECT_ID(N'tempdb..#ContractDocument') IS NOT NULL 
        BEGIN
        DROP TABLE #ContractDocument
    END
IF OBJECT_ID(N'tempdb..#OdcDocument') IS NOT NULL 
        BEGIN
        DROP TABLE #OdcDocument
    END

IF OBJECT_ID(N'tempdb..#Customer') IS NOT NULL 
        BEGIN
        DROP TABLE #Customer
    END
    CREATE TABLE #QuoteDocument
    (
        idQuote INT,
        documentNumber NVARCHAR(30),
        currency NVARCHAR(3),
        idDocumentType INT,
        documentType NVARCHAR(256),
        importAmount DECIMAL(14,4),
        ivaAmount DECIMAL(14,4),
        totalAmount DECIMAL(14,4),
        createdDate NVARCHAR(30),
        expirationDate NVARCHAR(30),
        idContact INT,
        contactName NVARCHAR(128),
        contactPhone NVARCHAR(30),
        contactCellPhone NVARCHAR(30),
        contactEmail NVARCHAR(50),
        beginDateLable NVARCHAR(20),
        endDateLable NVARCHAR(20),

    )
    CREATE TABLE #OrderDocument
    (
        idDocument INT,
        documentNumber NVARCHAR(30),
        currency NVARCHAR(3),
        idDocumentType INT,
        documentType NVARCHAR(256),
        importAmount DECIMAL(14,4),
        ivaAmount DECIMAL(14,4),
        totalAmount DECIMAL(14,4),
        createdDate NVARCHAR(30),
        expirationDate NVARCHAR(30),
        idContact INT,
        contactName NVARCHAR(128),
        contactPhone NVARCHAR(30),
        contactCellPhone NVARCHAR(30),
        contactEmail NVARCHAR(50),
        beginDateLable NVARCHAR(20),
        endDateLable NVARCHAR(20)

    )
    CREATE TABLE #ContractDocument
    (
        idQuote INT,
        documentNumber NVARCHAR(30),
        currency NVARCHAR(3),
        idDocumentType INT,
        documentType NVARCHAR(256),
        importAmount DECIMAL(14,4),
        ivaAmount DECIMAL(14,4),
        totalAmount DECIMAL(14,4),
        createdDate NVARCHAR(30),
        expirationDate NVARCHAR(30),
        idContact INT,
        contactName NVARCHAR(128),
        contactPhone NVARCHAR(30),
        contactCellPhone NVARCHAR(30),
        contactEmail NVARCHAR(50),
        beginDateLable NVARCHAR(20),
        endDateLable NVARCHAR(20),

    )
    CREATE TABLE #OdcDocument
    (
        idQuote INT,
        documentNumber NVARCHAR(30),
        currency NVARCHAR(3),
        idDocumentType INT,
        documentType NVARCHAR(256),
        importAmount DECIMAL(14,4),
        ivaAmount DECIMAL(14,4),
        totalAmount DECIMAL(14,4),
        createdDate NVARCHAR(30),
        expirationDate NVARCHAR(30),
        idContact INT,
        contactName NVARCHAR(128),
        contactPhone NVARCHAR(30),
        contactCellPhone NVARCHAR(30),
        contactEmail NVARCHAR(50),
        beginDateLable NVARCHAR(20),
        endDateLable NVARCHAR(20),

    )


    CREATE TABLE #Customer
    (
        id INT,
        idCustomerType INT,
        customerType NVARCHAR(20),
        socialReason NVARCHAR(128),
        rfc NVARCHAR(30),
        comertialName NVARCHAR(30),
        shortName NVARCHAR(30),

    )