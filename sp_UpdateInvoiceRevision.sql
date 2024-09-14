- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * --  STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 08-11-2021
-- Description: Update the authorization flag of the preinvoice in order to stamp it
-- STORED PROCEDURE NAME:   sp_UpdatePreinvoiceAuth
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: ID of the preinvoice to update
-- @partialitiesRequested: Partialities to use
-- @tcRequested: TC to use
-- @authorizationFlag: Authorization flag
-- @requiresExchangeCurrency: True if the document will do a currenc exchange (Cambio moneda)
-- *******************************************************************************************************************************
--  REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--  Date            Programmer                  Revision        Revision Notes
-- =================================================================================================
--  08-10-2021      Jose Luis Perez Olguin              1.0.0.0         Initial Revision
-- *******************************************************************************************************************************
CREATE PROCEDURE sp_UpdateInvoiceRevision(
    @idDocument INT,
    @partialitiesRequested INT,
    @tcRequested DECIMAL(14, 2),
    @authorizationFlag INT,
    @requiresExchangeCurrency TINYINT,
    @limitBillingTime DATETIME
) AS BEGIN
UPDATE
    Documents
SET
    partialitiesRequested = @partialitiesRequested,
    tcRequested = @tcRequested,
    authorizationFlag = @authorizationFlag,
    requiereExchange = @requiresExchangeCurrency,
    limitBillingTime=@limitBillingTime
WHERE
    idDocument = @idDocument;

END