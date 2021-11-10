-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_GetSectionsRol
--
--	DESCRIPTION:			This SP retrieves the permissions and sections information for a given rol.
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ==================================================================================================================================================
--	2021-11-10		Iván Díaz   				1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************

/****** Object:  StoredProcedure [dbo].[sp_GetSectionsRol]    Script Date: 09/07/2021 03:06:40 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_GetSectionsRol(

	@rolUser INT

)

AS BEGIN

(SELECT 

            permissions.permissionID AS permission,
            permissions.status AS permissionStatus,
            permissions.createdBy AS permissionCreatedBy,
            permissions.lastUpdatedBy AS permissionLastUpdatedBy,
            permissions.lastUpadatedDate AS permissionLastUpdatedDate,
            
            sections.description AS description,
            sections.level AS level,
            sections.sectionID AS sectionID,
            sections.parentSectionID as parentSectionID,
            sections.Comentarios AS comment,
            sections.status AS sectionStatus,
            sections.createdBy AS sectionCreatedBy,
            sections.lastUpdatedBy AS sectionLastUpdatedBy,
            sections.lastUpadatedDate AS sectionLastUpdatedDate,
            sections.orderElement AS orderElement

            FROM Permissions       
            JOIN Sections on Permissions.sectionID = Sections.sectionID
            WHERE rolID = @rolUser    
                  
        )ORDER BY orderElement

END	
