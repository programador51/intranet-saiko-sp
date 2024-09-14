-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 01-04-2022
-- Description: Get rol information
-- STORED PROCEDURE NAME:	sp_GetRol
-- ===============================================================================================================================
-- PARAMETERS
-- @idRol: Id of the rol to get his information
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	01-04-2022		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************
-- ===============================================================================================================================

CREATE PROCEDURE sp_GetRol(
    @idRol INT
)

AS
BEGIN

    SELECT

        Roles.description AS description,
        CONVERT(BIT,Roles.[status]) AS isActive


    FROM Roles
    WHERE rolID = @idRol;

    SELECT
        RolePermissions.uuid
    FROM RolePermissions
    WHERE rolId = @idRol;

    SELECT
        ParentRoles.idParentRole AS id,
        Roles.[description] AS description

    FROM ParentRoles

        INNER JOIN Roles ON ParentRoles.idChildRole = Roles.rolID

    WHERE idParentRole = @idRol;

END