-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 08-11-2021
-- Description: Update the authorization flag of the preinvoice in order to stamp it
-- STORED PROCEDURE NAME:	sp_UpdatePreinvoiceAuth
-- *******************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the preinvoice to update its auth flag value
-- @idFlag [PreinvoiceFlags]: New value of the auth preinvoice flag

/**
 * Ids of the authorizations that can be use to update the preinvoice. This values are on the table "DocumentsAuthorization"
 *
 * @typedef PreinvoiceFlags
 * @type {Object}
 * @property {1} NoRequiereAutorizacion - El documento creado tiene un TC >= al de la empresa y no contiene partidas con moneda revuelta
 * @property {2} RequiereAutorizacion - El documento tiene un TC < al de la empresa o contiene partidas con monedas revueltas
 * @property {3} EnProceso - El documento esta siendo revisado por un supervisor para ser aprobado
 * @property {4} Autorizado - Documento revisado, puede ser timbrado antes de su fecha limite
 */

-- *******************************************************************************************************************************
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	08-10-2021		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************

CREATE PROCEDURE sp_UpdatePreinvoiceAuth(
    @idDocument INT,
    @idFlag INT
)

AS BEGIN

    UPDATE Documents SET authorizationFlag = @idFlag WHERE idDocument = @idDocument

END