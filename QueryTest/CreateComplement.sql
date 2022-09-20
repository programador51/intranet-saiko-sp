

DECLARE @idMovement INT = 218;
DECLARE @postalCode NVARCHAR(30);
SELECT @postalCode=[value] FROM Parameters WHERE parameter=18
DECLARE @exchangePayment DECIMAL(5,2);
SELECT TOP(1) @exchangePayment= CAST(pays AS DECIMAL(5,2)) FROM TCP ORDER BY id DESC

DECLARE @jsonResult NVARCHAR(MAX);


-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------


IF OBJECT_ID(N'tempdb..#TempAssocaition') IS NOT NULL
        BEGIN
            DROP TABLE #TempAssocaition
        END

--* ----------------- ↓↓↓ CREACION DE LA TABLA TEMPORAL ↓↓↓ -----------------------
CREATE TABLE #TempAssocaition (
    id INT NOT NULL IDENTITY(1,1),
    idInvoice INT NOT NULL,
    idMovement INT NOT NULL,
    uuid NVARCHAR(256) NOT NULL,
    paymentMethod NVARCHAR(3) NOT NULL,
    amountUsedFromMovement DECIMAL(14,4) NOT NULL,
    amountToInvoice DECIMAL(14,4) NOT NULL,
    documentNumber NVARCHAR(128) NOT NULL,
    currency NVARCHAR(3) NOT NULL,
    totalInvoice DECIMAL (14,2) NOT NULL,
)
--* ----------------- ↑↑↑ CREACION DE LA TABLA TEMPORA ↑↑↑ -----------------------

--¡?<----------------------------------------------------------------------------------------->

--? ----------------- ↓↓↓ LLENADO DE LA TABLA TEMPORAL ↓↓↓ -----------------------
INSERT INTO #TempAssocaition (
    idInvoice,
    idMovement,
    uuid,
    paymentMethod,
    amountUsedFromMovement,
    amountToInvoice,
    documentNumber,
    currency,
    totalInvoice
)

SELECT 
        document.idInvoice,
        concilationCxC.idMovement,
        invoice.uuid,
        paymetForms.code,
        SUM(concilationCxC.amountPaid),
        SUM(concilationCxC.amountApplied),
        legalDocument.noDocument,
        legalDocument.currencyCode,
        legalDocument.total
        
    FROM ConcilationCxC AS concilationCxC
    LEFT JOIN Documents AS document ON document.idDocument= concilationCxC.idCxC
    LEFT JOIN Documents AS invoice ON invoice.idDocument=document.idInvoice
    LEFT JOIN LegalDocuments AS legalDocument ON legalDocument.uuid= invoice.uuid
    LEFT JOIN PaymentForms AS paymetForms ON paymetForms.idPayForm= invoice.idPaymentForm
    LEFT JOIN Movements AS movement ON movement.MovementID=@idMovement
    WHERE 
        concilationCxC.idMovement= @idMovement AND 
        movement.[status]=3 AND 
        movementType=1
    GROUP BY 
    concilationCxC.uuid,
    document.idInvoice,
    concilationCxC.idMovement,
    document.uuid,
    invoice.uuid,
    paymetForms.code,
    legalDocument.noDocument,
    legalDocument.currencyCode,
    legalDocument.total
--? ----------------- ↑↑↑ LLENADO DE LA TABLA TEMPORAL ↑↑↑ -----------------------

--¡?<----------------------------------------------------------------------------------------->

--? ----------------- ↓↓↓ SELECT CON LA INFORMACION DEL COMPLEMENTO  ↓↓↓ -----------------------
SELECT @jsonResult=( SELECT 
    
    --+ ---------- ↓↓↓ DATOS DEL EMISOR ↓↓↓ ----------
    'P' AS [CfdiType],
    '14' AS [NameId],
    dbo.fn_NextLegalDocNumberFE() AS [Folio],
    @postalCode AS [ExpeditionPlace], 
    --+ ---------- ↑↑↑  DATOS DEL EMISOR  ↑↑↑ ----------

    --¡?<----------------------------------------------------------------------------------------->

    --+ ---------- ↓↓↓ DATOS DEL RECEPTOR ↓↓↓ ----------
    customer.rfc AS [Receiver.Rfc],
    'CP01' AS [Receiver.CfdiUse],
    customer.socialReason AS [Receiver.Name],
    customer.fiscalRegime AS [Receiver.FiscalRegime],
    customer.cp AS [Receiver.TaxZipCode],
    --+ ---------- ↑↑↑  DATOS DEL RECEPTOR  ↑↑↑ ----------
    
    --¡?<----------------------------------------------------------------------------------------->

     --+ ---------- ↓↓↓ OBJETO COMPLEMENTO ↓↓↓ ----------
    JSON_QUERY(
        --+ ---------- ↓↓↓ ARREGLO PAGOS ↓↓↓ ----------
        (SELECT 
            JSON_QUERY((
                --+ ---------- ↓↓↓ OBJETO PAGOS ↓↓↓ ----------
                SELECT 

                    --+ ---------- ↓↓↓ HEADER DEL PAGO ↓↓↓ ----------
                    GETUTCDATE() AS [Date],
                    FORMAT(paymentMethod,'00') AS [PaymentForm],
                    @exchangePayment AS [ExchangeRate],
                    (
                        SELECT 
                            SUM(amountUsedFromMovement) 
                        FROM #TempAssocaition 
                        WHERE idMovement=@idMovement AND paymentMethod= 'PPD'
                    ) AS [Amount],
                    currency.code AS [Currency],
                    --+ ---------- ↑↑↑  HEADER DEL PAGO  ↑↑↑ ----------

                    --¡?<----------------------------------------------------------------------------------------->

                    --+ ---------- ↓↓↓ ARREGLO DE DOCUMENTOS RELACIONADOS ↓↓↓ ----------
                    JSON_QUERY((
                        SELECT DISTINCT
                        --+ ---------- ↓↓↓ HEADER DEL DOCUMENTO ↓↓↓ ----------
                        '02' AS [TaxObject],
                        tempAssociation.uuid AS [Uuid],
                        tempAssociation.documentNumber AS [Folio],
                        tempAssociation.currency AS [Currency],
                        --¡?<----------------------------------------------------------------------------------------->
                            /* 
                                --/+ Obtiene la base para calcular el tipo de cambio del documento
                                --/+ Es la suma del total abonado a la factura (segun su moneda) entre la suma utilizado 
                                --/+ entre la suma utilizado del movimiento
                            */

                        (
                            SELECT 
                                SUM(insideTemp.amountToInvoice) / SUM (insideTemp.amountUsedFromMovement)
                            FROM #TempAssocaition AS insideTemp
                            WHERE 
                                insideTemp.idInvoice=tempAssociation.idInvoice AND
                                insideTemp.paymentMethod='PPD'

                            GROUP BY uuid
                        ) AS [EquivalenceDocRel],
                        --¡?<----------------------------------------------------------------------------------------->
                        tempAssociation.paymentMethod AS [PaymentMethod],

                            /* 
                                --/+ El siguiente numero de parcialidad se calcula segun los complementos creados para cada factura
                            */
                        --¡?<----------------------------------------------------------------------------------------->
                        (
                            SELECT 
                                COUNT(*) + 1
                            FROM AssociationsComplements
                            WHERE uuidInvoice= tempAssociation.uuid AND [status]=1
                         ) AS [PartialityNumber],
                        --¡?<----------------------------------------------------------------------------------------->
                        
                            /* 
                                --/+ El monto pagado a la factura es la suma del monto asociado a cada CxC del movimiento
                            */
                        --¡?<----------------------------------------------------------------------------------------->

                        (
                            SELECT 
                                SUM(secondInsiedTemp.amountToInvoice) 
                            FROM #TempAssocaition AS secondInsiedTemp
                            WHERE 
                                secondInsiedTemp.idInvoice=tempAssociation.idInvoice AND 
                                secondInsiedTemp.paymentMethod='PPD'

                            GROUP BY secondInsiedTemp.uuid  
                        ) AS [AmountPaid],
                        --¡?<----------------------------------------------------------------------------------------->


                            /* 
                                --/+ El saldo anterior asociado a la Factura es igual a la suma de todos los complementos
                                --/+ que le corresponden a la factura (solo el monto aplicado a la factura no el total del
                                --/+ complemento ). En caso de que no exista se utiliza el total de la factura
                            */
                        --¡?<----------------------------------------------------------------------------------------->
                        CASE 
                            WHEN 
                                (SELECT                            
                                        SUM(amount)
                                FROM AssociationsComplements
                                WHERE uuidInvoice= tempAssociation.uuid AND [status]=1 ) IS NULL THEN tempAssociation.totalInvoice
                            ELSE 
                                (SELECT                            
                                        SUM(amount)
                                FROM AssociationsComplements
                                WHERE uuidInvoice= tempAssociation.uuid AND [status]=1 )
                        END AS [PreviousBalanceAmount],
                        --¡?<----------------------------------------------------------------------------------------->


                            /* 
                                --/+ El saldo insoluto es igual al saldo anterior menos el monto aplicado actual a la factura
                            */
                        --¡?<----------------------------------------------------------------------------------------->
                        CASE 
                            WHEN 
                                (SELECT                            
                                        SUM(amount)
                                FROM AssociationsComplements
                                WHERE uuidInvoice= tempAssociation.uuid AND [status]=1 ) IS NULL 
                                    THEN 
                                        tempAssociation.totalInvoice - 
                                         (
                                            SELECT 
                                                SUM(secondInsiedTemp.amountToInvoice) 
                                            FROM #TempAssocaition AS secondInsiedTemp
                                            WHERE 
                                                secondInsiedTemp.idInvoice=tempAssociation.idInvoice AND 
                                                secondInsiedTemp.paymentMethod='PPD'

                                            GROUP BY secondInsiedTemp.uuid  
                                        )
                            ELSE 
                                (
                                    SELECT                            
                                        SUM(amount)
                                    FROM AssociationsComplements
                                    WHERE uuidInvoice= tempAssociation.uuid AND [status]=1
                                 ) - 
                                (
                                    SELECT 
                                        SUM(secondInsiedTemp.amountToInvoice) 
                                    FROM #TempAssocaition AS secondInsiedTemp
                                    WHERE 
                                        secondInsiedTemp.idInvoice=tempAssociation.idInvoice AND 
                                        secondInsiedTemp.paymentMethod='PPD'

                                    GROUP BY secondInsiedTemp.uuid  
                                )
                        END AS [ImpSaldoInsoluto],
                        --¡?<----------------------------------------------------------------------------------------->

                        --+ ---------- ↑↑↑  HEADER DEL DOCUMENTO  ↑↑↑ ----------

                        --¡?<----------------------------------------------------------------------------------------->

                        --+ ---------- ↓↓↓  ARREGLO DE IMPUESTOS ↓↓↓ ----------
                        JSON_QUERY((
                            SELECT DISTINCT
                                'IVA' AS [Name],
                                cxcTaxas.ivaPercentage AS [Rate],
                                cxcTaxas.percentageTotal AS [PorcentajeTotal],

                                /* 
                                    --/+ La base se obtiene de la suma del monto asociado a la factura
                                    --/+ multiplicada por lo que representa su porcentaje de IVA entre el IVA + 1
                                */
                                --¡?<----------------------------------------------------------------------------------------->
                                ROUND(
                                    (
                                    SELECT 
                                        SUM(secondInsiedTemp.amountToInvoice)
                                    FROM #TempAssocaition AS secondInsiedTemp
                                    WHERE 
                                        secondInsiedTemp.idInvoice=tempAssociation.idInvoice AND 
                                        secondInsiedTemp.paymentMethod='PPD'

                                    GROUP BY secondInsiedTemp.uuid  
                                ) * cxcTaxas.percentageTotal / (cxcTaxas.ivaPercentage + 1),
                                2,
                                0
                                )
                                 AS [Base], 
                                --¡?<----------------------------------------------------------------------------------------->


                                /* 
                                    --/+ El total es la base obtenida ↑↑↑ por el porcentaje del IVA
                                */
                                --¡?<----------------------------------------------------------------------------------------->
                                ROUND(
                                    (
                                    SELECT 
                                        SUM(secondInsiedTemp.amountToInvoice)
                                    FROM #TempAssocaition AS secondInsiedTemp
                                    WHERE 
                                        secondInsiedTemp.idInvoice=tempAssociation.idInvoice AND 
                                        secondInsiedTemp.paymentMethod='PPD'

                                    GROUP BY secondInsiedTemp.uuid  
                                ) * cxcTaxas.percentageTotal / (cxcTaxas.ivaPercentage + 1) * cxcTaxas.ivaPercentage ,
                                2,
                                0
                                ) AS [Total], 
                                --¡?<----------------------------------------------------------------------------------------->


                                CAST(0 AS BIT) AS [isRetention]
                             FROM CxCTaxas AS cxcTaxas 
                             WHERE 
                                cxcTaxas.uuidInvoce = tempAssociation.uuid AND
                                cxcTaxas.[status]=1 AND 
                                cxcTaxas.baseAmount!=0
                            GROUP BY 
                                cxcTaxas.uuidInvoce,
                                cxcTaxas.ivaPercentage,
                                cxcTaxas.percentageTotal
                            FOR JSON PATH
                        )) AS [Taxes]
                        --+ ---------- ↑↑↑  HEADER DEL DOCUMENTO  ↑↑↑ ----------


                        FROM #TempAssocaition AS tempAssociation
                        WHERE tempAssociation.paymentMethod='PPD' 
                        ORDER BY tempAssociation.documentNumber
                        FOR JSON PATH
                    )) AS RelatedDocuments
                    --+ ---------- ↑↑↑  ARREGLO DE DOCUMENTOS RELACIONADOS ↑↑↑ ----------
                FROM Movements AS movement 
                WHERE 
                    movement.MovementID=@idMovement AND
                    movement.[status]=3 AND 
                    movement.movementType=1
                FOR JSON PATH
                --+ ---------- ↑↑↑  OBJETO PAGOS  ↑↑↑ ----------
            )) AS [Payments]
            --+ ---------- ↑↑↑  ARREGLO PAGOS  ↑↑↑ ----------
            
        FROM Movements AS movement 
        WHERE 
            movement.MovementID=@idMovement AND
            movement.[status]=3 AND 
            movementType=1 
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    ) AS [Complemento]
    --+ ---------- ↑↑↑  OBJECTO COMPLEMENTO  ↑↑↑ ----------


 FROM Movements AS movement 
 LEFT JOIN BankAccounts AS bankAccount ON bankAccount.bankAccountID= movement.bankAccount
 LEFT JOIN Currencies AS currency ON currency.currencyID= bankAccount.currencyID
 LEFT JOIN Customers AS customer ON customer.customerID= movement.customerAssociated
 
 WHERE movement.MovementID=@idMovement 
 FOR JSON PATH,ROOT('complement')
)

    DECLARE @itMustHaveExchangeRate BIT=0;
    DECLARE @itemsWithUSD INT;
    DECLARE @currency NVARCHAR(3);

    SELECT @currency=  currency.code
    
    FROM Movements AS movement
    LEFT JOIN BankAccounts AS bankAccount ON bankAccount.bankAccountID=movement.bankAccount
    LEFT JOIN Currencies AS currency ON currency.currencyID= bankAccount.currencyID
    WHERE MovementID=@idMovement


    SELECT @itemsWithUSD =COUNT(*) FROM #TempAssocaition WHERE currency='USD' AND paymentMethod= 'PPD';

    -- IF (@itemsWithUSD > 0)
    --     BEGIN 
    --         SET @itMustHaveExchangeRate=1
    --     END
    -- ELSE 
    IF(@currency='USD')
        BEGIN 
            SET @itMustHaveExchangeRate=1
        END
    ELSE
        BEGIN 
            SET @itMustHaveExchangeRate=0
        END




IF @itMustHaveExchangeRate=0    
    BEGIN
        SET @jsonResult= JSON_MODIFY(@jsonResult,'$.complement[0].Complemento.Payments[0].ExchangeRate',NULL)
    END

SELECT @jsonResult AS complement

 --? ----------------- ↑↑↑ SELECT CON LA INFORMACION DEL COMPLEMENTO  ↑↑↑ -----------------------


IF OBJECT_ID(N'tempdb..#TempAssocaition') IS NOT NULL
        BEGIN
            DROP TABLE #TempAssocaition
        END