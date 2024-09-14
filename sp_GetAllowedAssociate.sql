-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 12-10-2021
-- Description: We obtain allowed clients to associate a conciliation 
-- STORED PROCEDURE NAME:	sp_GetAllowedAssociate
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerType: The customer type [1 | 5]
-- @rangeBegin: The offset. Where dose it start
-- @noRegisters: The limit. Where it ends
-- ===================================================================================================================================
-- Returns:
-- All the clients and clients/providers 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-12-10		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetAllowedAssociate(
    @customerType INT,
    @rangeBegin INT,
    @noRegisters INT
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    -- Insert statements for procedure here
    SET LANGUAGE Spanish;
        SELECT    
            Customers.customerID AS ID,
            Customers.socialReason AS Razon_social,
            Customers.commercialName AS Nombre_comercial,
            Customers.shortName AS Nombre_corto,
            Customers.ladaPhone,
            Customers.phone,
            Customers.ladaMovil,
            Customers.movil,

            CASE WHEN
                Customers.ladaPhone IS NULL THEN ''
            ELSE
            CONCAT('+',ladaPhone,phone) END AS Telefono,

            CASE WHEN
                Customers.ladaMovil IS NULL THEN ''
            ELSE
            CONCAT('+',ladaMovil,movil) END AS Movil

            FROM Customers

            WHERE
                (customerType = @customerType OR
                customerType = 5) AND 
                (customerID IN (SELECT idCustomer FROM Documents WHERE idTypeDocument=5))
                AND [status]=1
            
            ORDER BY customerID DESC

            OFFSET @rangeBegin ROWS
            FETCH NEXT @noRegisters ROWS ONLY

END
GO