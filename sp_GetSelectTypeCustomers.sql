-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: It's used to show the type of customers that are on the system
-- Cliente, proveedor and cliente-proveedor

-- STORED PROCEDURE NAME:	sp_GetSelectTypeCustomers
-- STORED PROCEDURE OLD NAME: sp_SelectTypeCustomers

-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--  Date            Programmer		        Revision        Revision Notes			
-- =================================================================================================
--  2021-07-22	    Iván Díaz   		1.0.0.0		Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetSelectTypeCustomers

AS BEGIN

	SELECT
        customerTypeID AS value,
        description AS text,
        status
        FROM CustomerTypes

END