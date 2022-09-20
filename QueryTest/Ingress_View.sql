CREATE VIEW ingress_view AS
SELECT 
    bankAccount,
    SUM(amount) AS total
FROM Movements 
WHERE [status]!=5 AND movementType=1
GROUP BY bankAccount

