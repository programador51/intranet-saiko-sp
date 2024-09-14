CREATE VIEW egress_view AS
SELECT 
    bankAccount,
    SUM(amount) AS total
FROM Movements 
WHERE [status]!=5 AND movementType=0
GROUP BY bankAccount