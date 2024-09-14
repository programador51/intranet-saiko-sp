-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 14-10-2021
-- Description: We obtain the reminders created by an executive
-- STORED PROCEDURE NAME:	sp_GetRemindersToAttent
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @executiveID - The executive id
-- ===================================================================================================================================
-- Returns:
-- commentId, registerById, mustAttendById, customerID, contactID, documentId, reminderDate, attentionDate,reminderFrom
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-10-14		Adrian Alardin   			1.0.0.0			Initial Revision
--	2021-10-15		Adrian Alardin   			1.0.0.1			We add the next validation commentType=1, get the reminderFrom 
--                                                              and the reminderFromType
--			                                                    
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_GetRemindersToAttent(@executiveID INT) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON -- Insert statements for procedure here
SET
    LANGUAGE Spanish;

SELECT
    commentId,
    registerById,
    mustAttendById,
    customerID,
    contactID,
    documentId,
	REPLACE(
        CONVERT(VARCHAR(10), reminderDate, 6),
        ' ',
        '/'
    ) AS reminderDate,
	REPLACE(
        CONVERT(VARCHAR(10), attentionDate, 6),
        ' ',
        '/'
    ) AS attentionDate,
    ISNULL(CONVERT(VARCHAR(10), realAttentionDate, 6), '---') AS realAttentionDate,
	REPLACE(
        CONVERT(VARCHAR(10), createdDate, 6),
        ' ',
        '/'
    ) AS createdDate,
    commentTypeDescription,
	reminderFrom,
	CASE 
		WHEN reminderFrom=1 THEN 'Directorio'
		WHEN reminderFrom=2 THEN 'Contacto'
		WHEN reminderFrom=3 THEN 'Documento'
		ELSE 'No definido'
	END AS reminderFromType
FROM
    Commentation
WHERE
    (mustAttendById = @executiveId)
    AND (
        reminderDate <= GETDATE()
        OR reminderDate <= DATEADD(DAY, 5, GETDATE())
    )
    AND status = 1
	AND commentType=1
    AND realAttentionDate IS NULL
ORDER BY
    reminderDate DESC
END
GO