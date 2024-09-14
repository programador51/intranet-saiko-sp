CREATE VIEW TicketsView AS
SELECT 
    tickets.id AS idTicket,
    tickets.createdBy AS createdBy,
    tickets.createdDate AS createdDate,
    tickets.assignedDate AS assignedDate,
    tickets.startDate AS startDate,
    tickets.finishDate AS finishDate,
    CASE 
        WHEN 
            tickets.score IS NOT NULL 
            AND tickets.scoreComment IS NOT NULL 
            AND tickets.assignedDate IS NOT NULL
            AND tickets.startDate IS NOT NULL
            AND tickets.finishDate IS NOT NULL
        THEN updatedDate
        ELSE NULL
    END AS scoreDate,
    executiveAssignedBy.initials AS executiveAssignedBy,
    executiveAssignedTo.initials AS executiveAssignedTo,
    CASE 
        WHEN 
            tickets.createdDate IS NOT NULL 
            AND tickets.assignedDate IS NULL
            AND tickets.startDate IS NULL
            AND tickets.finishDate IS NULL
        THEN 'Pendiente'
        WHEN 
            tickets.createdDate IS NOT NULL 
            AND tickets.assignedDate IS NOT NULL
            AND tickets.startDate IS NULL
            AND tickets.finishDate IS NULL
        THEN 'En proceso'
        WHEN 
            tickets.createdDate IS NOT NULL 
            AND tickets.assignedDate IS NOT NULL
            AND tickets.startDate IS NOT NULL
            AND tickets.finishDate IS NULL
        THEN 'Por Revisar'
        WHEN 
            tickets.createdDate IS NOT NULL 
            AND tickets.assignedDate IS NOT NULL
            AND tickets.startDate IS NOT NULL
            AND tickets.finishDate IS NOT NULL
        THEN 'Terminado'
        WHEN 
            tickets.createdDate IS NOT NULL 
            AND tickets.assignedDate IS NOT NULL
            AND tickets.startDate IS NOT NULL
            AND tickets.finishDate IS NOT NULL
            AND tickets.score IS NOT NULL
        THEN 'Evaluado'
        ELSE 'Sin estado'
    END AS [status]
FROM Tickets AS tickets
LEFT JOIN Users AS executiveAssignedBy ON executiveAssignedBy.userID = tickets.assignedTo
LEFT JOIN Users AS executiveAssignedTo ON executiveAssignedTo.userID = tickets.assignedBy
