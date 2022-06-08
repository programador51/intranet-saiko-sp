-- Obtener los datos de Cotizacion,Contrato, Pedido,Orden de compra y Origen

CREATE VIEW documents_view AS 
    SELECT  
    -- ? Infomracion de los documentos relacionados
        document.idDocument AS documentId,
        docType.documentTypeID AS typeId,
        docType.[description] AS documentType,
        document.idStatus AS statusId,
        docStatus.[description] AS documentStatus,
        CASE
            WHEN document.idTypeDocument=1 THEN document.idDocument
            WHEN document.idTypeDocument !=1 AND quoteDocument.idDocument IS NOT NULL THEN quoteDocument.idDocument
            ELSE -1
        END AS quoteId,
        CASE
            WHEN document.idTypeDocument= 1 AND  quoteDocument.documentNumber IS NULL THEN FORMAT(document.documentNumber,'0000000') 
            WHEN quoteDocument.documentNumber IS NOT NULL THEN FORMAT(quoteDocument.documentNumber,'0000000') 
            ELSE 'ND'
        END AS quoteNumber,
        ------------------------
        CASE
            WHEN document.idTypeDocument=2 THEN document.idDocument
            WHEN document.idTypeDocument !=2 AND orderDocument.idDocument IS NOT NULL THEN orderDocument.idDocument
            ELSE -1
        END AS orderId,
        CASE
            WHEN document.idTypeDocument= 2 AND orderDocument.documentNumber IS NULL THEN FORMAT(document.documentNumber,'0000000')
            WHEN orderDocument.documentNumber IS NOT NULL THEN FORMAT(orderDocument.documentNumber,'0000000')
            ELSE 'ND'
        END AS orderNumber,
        ---------------------------
        CASE
            WHEN document.idTypeDocument=6 THEN document.idDocument
            WHEN document.idTypeDocument !=6 AND contractDocument.idDocument IS NOT NULL THEN contractDocument.idDocument
            ELSE -1
        END AS contractId,
        CASE
            WHEN document.idTypeDocument= 6 AND contractDocument.documentNumber IS NULL THEN FORMAT(document.documentNumber,'0000000')
            WHEN contractDocument.documentNumber IS NOT NULL THEN FORMAT(contractDocument.documentNumber,'0000000')
            ELSE 'ND'
        END AS contractNumber,
        ---------------------------
        CASE
            WHEN document.idTypeDocument=3 THEN document.idDocument
            WHEN document.idTypeDocument !=3 AND odcDocument.idDocument IS NOT NULL THEN odcDocument.idDocument
            ELSE -1
        END AS odcId,
        CASE
            WHEN document.idTypeDocument= 3 AND odcDocument.documentNumber IS NULL THEN FORMAT(document.documentNumber,'0000000')
            WHEN odcDocument.documentNumber IS NOT NULL THEN FORMAT(odcDocument.documentNumber,'0000000')
            ELSE 'ND'
        END AS odcNumber,

        document.subTotalAmount AS import,
        document.ivaAmount AS iva,
        document.totalAmount AS total,
        document.idCurrency AS currencyId,
        currency.code AS currencyCode,
        document.creditDays AS creditDays,

    -- ? Infomracion de la razon social

        document.idCustomer AS customerId,
        customer.customerType AS customerTypeId,
        customerType.[description] AS customerType, 
        customer.socialReason AS socialReson,
        customer.street AS street,
        customer.interiorNumber AS interiorNumber,
        customer.exteriorNumber AS exteriorNumber,
        customer.city AS city,
        customer.suburb AS [state],
        customer.country AS country,
        customer.cp AS cp,

    -- ? Infomracion del contacto (si no tiene se utiliza la información del customer)

        CASE
            WHEN document.idContact IS NOT NULL THEN contact.email
            ELSE customer.email
        END AS contactEmail,
        CASE
            WHEN document.idContact IS NOT NULL THEN (
                CASE 
                    WHEN (
                        contact.phoneNumberAreaCode IS NULL OR 
                        contact.phoneNumberAreaCode = '' OR 
                        contact.phoneNumber IS NULL OR
                        contact.phoneNumber = ''  
                        ) THEN 'ND'
                    ELSE CONCAT('+ ',contact.phoneNumberAreaCode, ' ',contact.phoneNumber)
                END
            )
            ELSE (
                CASE
                    WHEN (
                        customer.ladaPhone IS NULL OR 
                        customer.ladaPhone = '' OR 
                        customer.phone IS NULL OR
                        customer.phone = ''
                        ) THEN 'ND'
                    ELSE CONCAT('+ ',customer.ladaPhone,' ',customer.phone)
                END
            )
        END AS phone,
        CASE
            WHEN document.idContact IS NOT NULL THEN (
                CASE 
                    WHEN (
                        contact.cellNumberAreaCode IS NULL OR 
                        contact.cellNumberAreaCode ='' OR 
                        contact.cellNumber IS NULL OR
                        contact.cellNumber = ''
                        ) THEN 'ND'
                    ELSE CONCAT('+ ',contact.cellNumberAreaCode, ' ',contact.cellNumber) 
                END
            )
            ELSE (
                CASE
                    WHEN (
                        customer.ladaMovil IS NULL OR 
                        customer.ladaMovil = '' OR 
                        customer.movil IS NULL OR
                        customer.movil =''
                        ) THEN 'ND'
                    ELSE CONCAT('+ ',customer.ladaMovil,' ',customer.movil)
                END
            )
        END AS cel,

    -- ? Infomracion de las fechas importantes
        dbo.FormatDate(document.createdDate) AS createdDate,
        dbo.FormatDate(document.expirationDate) AS expirationDate,
        ISNULL(dbo.FormatDate(document.reminderDate),'ND') AS reminderDate,

    -- ? Infomracion del ejecutivo

        executive.userID,
        executive.initials AS executiveInitials,
        CONCAT(executive.firstName, ' ',executive.middleName,' ',executive.lastName1, ' ',executive.lastName2) AS executiveName

    FROM Documents AS document
        LEFT JOIN Customers AS customer ON customer.customerID=document.idCustomer
        LEFT JOIN CustomerTypes AS customerType ON customerType.customerTypeID=customer.customerType
        LEFT JOIN Currencies AS currency ON currency.currencyID=document.idCurrency
        LEFT JOIN Contacts AS contact ON contact.contactID=document.idContact
        LEFT JOIN DocumentStatus AS docStatus ON docStatus.documentStatusID= document.idStatus
        LEFT JOIN Users AS executive ON executive.userID= document.idExecutive
        LEFT JOIN DocumentTypes AS docType ON docType.documentTypeID= document.idTypeDocument
        LEFT JOIN Documents AS quoteDocument ON quoteDocument.idDocument=document.idQuotation
        LEFT JOIN Documents AS orderDocument ON orderDocument.idDocument=document.idInvoice
        LEFT JOIN Documents AS contractDocument ON contractDocument.idDocument=document.idContract
        LEFT JOIN Documents AS odcDocument ON odcDocument.idDocument=document.idOC

    WHERE 
        document.idTypeDocument != 4 OR 
        document.idTypeDocument != 5 OR 
        document.idTypeDocument != 7 OR 
        document.idTypeDocument != 8





-- SELECT * FROM documents_view 