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