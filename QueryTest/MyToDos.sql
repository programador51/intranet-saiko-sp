
DECLARE @aditionalDays INT;
DECLARE @actualDate DATETIME

SELECT @aditionalDays=CAST ([value] AS INT), @actualDate= dbo.fn_MexicoLocalTime(GETDATE()) FROM Parameters WHERE parameter=30

SELECT 
    ToDo.id,
    dbo.FormatDate(ToDo.atentionDate)  AS atentionDate,
    ToDo.fromId,
    ToDo.idSection AS sectionId,
    dbo.FormatDate(ToDo.reminderDate) AS reminderDate,
    ToDo.idTag AS [tag.id],
    ToDo.tagDescription AS [tag.description],
    ToDo.title AS title,
    ToDo.toDoNote,
    Customers.socialReason,
    parent,
    CAST (
        CASE 
            WHEN ToDo.atentionDate < @actualDate THEN 1
            ELSE 0 END
        AS bit
    ) AS isExpired
 FROM ToDo
 LEFT JOIN Customers ON Customers.customerID= ToDo.customerId
 WHERE ToDo.executiveWhoCreatedId= 14 AND ToDo.reminderDate <= DATEADD(DAY,@aditionalDays,@actualDate) AND ToDo.isTaskFinished=0 AND ToDo.idSection=1
 ORDER BY atentionDate ASC

 FOR JSON PATH, ROOT('ToDo'), INCLUDE_NULL_VALUES