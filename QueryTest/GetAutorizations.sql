DECLARE @idInvoice INT = 1644;


DECLARE @partialitiesAllowed INT;
DECLARE @tcRate DECIMAL (14,2);
DECLARE @tcAllowed DECIMAL (14,2);

DECLARE @tcDof DECIMAL (14,4)
DECLARE @tcDofPagos DECIMAL (14,4)
DECLARE @tcCompra DECIMAL (14,4)
DECLARE @tcVenta DECIMAL (14,4)
DECLARE @tcInstitucional DECIMAL (14,4)
DECLARE @tcDocument DECIMAL (14,4)
DECLARE @tcRequested DECIMAL (14,4)

DECLARE @message NVARCHAR (MAX)='';
DECLARE @isValidTc BIT;
DECLARE @isValidPartialities BIT;
DECLARE @requireCurrencyExchange BIT;

DECLARE @invoiceNumber NVARCHAR(20);
DECLARE @invoiceCurrency NVARCHAR(3);
DECLARE @ocCurrency NVARCHAR(3);
DECLARE @invoiceChangedCurrency NVARCHAR(3);
DECLARE @invoiceTotal DECIMAL(14,4);
DECLARE @ocTotal DECIMAL(14,4);
DECLARE @partialitiesRequested INT;


DECLARE @newTotalxDocumentTc DECIMAL(14,4)
DECLARE @newTotalxInstitucionalTc DECIMAL(14,4)
DECLARE @newTotalxRequestedTc DECIMAL(14,4)
DECLARE @newTotalxOc DECIMAL(14,4)



SELECT 
  @partialitiesAllowed= CAST ([value] AS INT)

 FROM Parameters WHERE parameter= 22
SELECT 
  @tcRate= CAST ([value] AS DECIMAL(14,2))

 FROM Parameters WHERE parameter= 23


 SELECT TOP 1  
  @tcDof=  CAST(DOF AS DECIMAL(14,4)),
  @tcDofPagos= CAST(pays AS DECIMAL(14,4)),
  @tcCompra= CAST(purchase AS DECIMAL(14,4)),
  @tcVenta= CAST(sales AS DECIMAL(14,4)),
  @tcInstitucional= CAST(saiko AS DECIMAL(14,4)),
  @tcAllowed= @tcInstitucional- @tcRate
  
  FROM TCP ORDER BY id DESC

SELECT 
  @isValidTc= CASE 
    WHEN invoiceAuth.tcRequested<@tcAllowed THEN 0
    ELSE 1
  END,
  @isValidPartialities=CASE 
    WHEN invoiceAuth.partialitiesRequested>@partialitiesAllowed THEN 0
    ELSE 1
  END,
  @invoiceNumber= FORMAT(document.documentNumber,'0000000'),
  @invoiceCurrency= currency.code,
  @invoiceChangedCurrency=dbo.fn_changeCurrency(currency.code),
  @tcDocument= document.tcRequested,
  @invoiceTotal= document.totalAmount,
  @ocTotal= ocDocument.totalAmount,
  @newTotalxOc= ocDocument.totalAmount,
  @ocCurrency= ocCurrency.code,
  @tcRequested= invoiceAuth.tcRequested,
  @requireCurrencyExchange= invoiceAuth.requiresCurrencyExchange,
  @partialitiesRequested= invoiceAuth.partialitiesRequested
 FROM InvoiceAuthorizations  AS invoiceAuth
 LEFT JOIN Documents AS document ON document.idDocument=invoiceAuth.idInvoice
 LEFT JOIN Documents AS ocDocument ON ocDocument.idDocument=invoiceAuth.idOc
 LEFT JOIN Currencies AS currency ON currency.currencyID= document.idCurrency
 LEFT JOIN Currencies AS ocCurrency ON ocCurrency.currencyID= ocDocument.idCurrency
 
 WHERE invoiceAuth.idInvoice=@idInvoice AND  invoiceAuth.limitBillingTime IS NULL
 
PRINT 'Antes de valoracion----------------'
PRINT @message 
IF (@requireCurrencyExchange=1 AND @isValidTc=0)
  BEGIN
    SELECT @message= @message + '<p>
      <b>
        Solicitud de cambio de moneda
      </b>
    </p> <p>
      Solicitud de autorización para cambiar moneda del pedido
    </p>' + CONCAT('<b>',@invoiceNumber,'</b>', ' de ','<b>',@invoiceCurrency,'</b>', ' a ', '<b>',@invoiceChangedCurrency,'</b>') 
  END
IF (@isValidPartialities=0)
  BEGIN
    SELECT @message= @message + '<p><b> Se solicitan '+ CONCAT (@partialitiesRequested, ' parcialidades</b> para el timbrado</p>')

  END
SELECT @message = @message + 
  '<p>
    El tipo de cambio al 
  </p>'+ CONCAT('<b>',dbo.FormatDate(dbo.fn_MexicoLocalTime(GETUTCDATE())),'</b>', ' es:') +
  CONCAT(
    '<ul>',
      '<li> Diario oficial: <b>',dbo.fn_FormatCurrency(@tcDof),'</b> </li>',
      '<li> Diario oficial para pagos: <b>',dbo.fn_FormatCurrency(@tcDofPagos),'</b> </li>',
      '<li> BANAMEX (venta): <b>',dbo.fn_FormatCurrency(@tcVenta),'</b> </li>',
      '<li> Institucional: <b>',dbo.fn_FormatCurrency(@tcInstitucional),'</b> </li>',
    '</ul>'
  )


IF (@requireCurrencyExchange=1 AND @isValidTc=0)
  BEGIN 
    IF (@invoiceCurrency='MXN') --De mexicano a dolar
      BEGIN
        SELECT @newTotalxDocumentTc= @invoiceTotal/@tcDocument;
        SELECT @newTotalxInstitucionalTc= @invoiceTotal/@tcInstitucional;
        SELECT @newTotalxRequestedTc= @invoiceTotal/@tcRequested;
      END
    ELSE IF (@invoiceCurrency='USD')-- de dolar a mexicano.
      BEGIN
        SELECT @newTotalxDocumentTc= @invoiceTotal*@tcDocument;
        SELECT @newTotalxInstitucionalTc= @invoiceTotal*@tcInstitucional;
        SELECT @newTotalxRequestedTc= @invoiceTotal*@tcRequested;
      END
  END

IF (@invoiceChangedCurrency='MXN' AND @ocCurrency= 'USD' AND @ocTotal IS NOT NULL AND @isValidTc=0)-- LA ORDEN DE COMPRA PASA A MXN
  BEGIN
    SELECT @newTotalxOc= @ocTotal*@tcDofPagos
  END
  ELSE IF (@invoiceChangedCurrency='USD' AND @ocCurrency= 'MXN' AND @ocTotal IS NOT NULL AND @isValidTc=0)
    BEGIN
      SELECT @newTotalxOc= @ocTotal/@tcDofPagos
    END

IF (@requireCurrencyExchange=1 AND @isValidTc=0)
  BEGIN
    SELECT @message= @message + '
    <p>
      El iporte IVA incluido del <b> pedido '+ CONCAT(@invoiceNumber, '</b> ') + 'con el TC del documento <b>'+
      CONCAT(@tcDocument,'</b>')+ 'seria de <b>'+ CONCAT(dbo.fn_FormatCurrency(@newTotalxDocumentTc),'</b> </p>')+ 
    '<p> El importe en <b>'+ CONCAT (dbo.fn_currencyName(@invoiceChangedCurrency),'</b>')+ ' al Tc institucional <b>'+
    CONCAT(dbo.fn_FormatCurrency(@tcInstitucional),'</b> ')+'seria de <b>'+CONCAT(dbo.fn_FormatCurrency(@newTotalxInstitucionalTc),'</b>')+
    '<p> El importe en <b>'+ CONCAT (dbo.fn_currencyName(@invoiceChangedCurrency),'</b>')+ ' al Tc solicitado <b>'+
    CONCAT(dbo.fn_FormatCurrency(@tcRequested),'</b> ')+'seria de <b>'+CONCAT(dbo.fn_FormatCurrency(@newTotalxRequestedTc),'</b>')

    IF (@ocTotal IS NOT NULL)
      BEGIN 
        SELECT @message= @message + 'El costo de esta operacion al TC del diario oficial para pagos del dia de hoy <b>'+
          CONCAT(dbo.fn_FormatCurrency(@tcDofPagos),'</b> ')+ 'seria de <b>'+CONCAT(dbo.fn_FormatCurrency(@newTotalxRequestedTc-@newTotalxOc),'</b>')

      END
  END
  IF (@ocTotal IS NOT NULL)
      BEGIN 
        SELECT @message= @message + 'El costo de esta operacion seria de <b>'+CONCAT(dbo.fn_FormatCurrency(@invoiceTotal-@ocTotal),'</b>')

      END


SELECT @message AS [message], @isValidTc AS [isValid.tc],@isValidPartialities AS [isValid.partialities] FOR JSON PATH, ROOT('auth')

-- TODO: Armar el mensaje con puros IF, todas las variables necesarias ya estan listas


-- SELECT 
--   FORMAT(document.documentNumber,'0000000'),
--    currency.code,
--    CASE 
--     WHEN invoiceAuth.partialitiesRequested>2 THEN 0
--     ELSE 1
--     END AS prmitido,
--   dbo.fn_changeCurrency(currency.code),
--   document.tcRequested,
--    document.totalAmount,
--   ocDocument.totalAmount,
--    ocDocument.totalAmount,
--    ocCurrency.code,
--    invoiceAuth.tcRequested,
--    invoiceAuth.requiresCurrencyExchange,
--    invoiceAuth.partialitiesRequested
--  FROM InvoiceAuthorizations  AS invoiceAuth
--  LEFT JOIN Documents AS document ON document.idDocument=invoiceAuth.idInvoice
--  LEFT JOIN Documents AS ocDocument ON ocDocument.idDocument=invoiceAuth.idOc
--  LEFT JOIN Currencies AS currency ON currency.currencyID= document.idCurrency
--  LEFT JOIN Currencies AS ocCurrency ON ocCurrency.currencyID= ocDocument.idCurrency
 
--  WHERE invoiceAuth.idInvoice=1644 AND  invoiceAuth.limitBillingTime IS NULL