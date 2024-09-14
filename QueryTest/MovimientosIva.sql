SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 06-03-2022
-- Description: Obtiene la informacion de un movimiento
-- STORED PROCEDURE NAME:	sp_GetMovementV3
-- ===============================================================================================================================
ALTER PROCEDURE [dbo].[sp_GetMovementV3]
(@id INT)
AS
BEGIN


    SELECT 
        Movements.MovementID AS id,
        Movements.noMovement AS folio,
        Movements.idBeneficiary AS [beneficiary.id],
        Beneficiary.beneficiary AS [beneficiary.description],
        Movements.createdDate AS createdDate,
        Movements.amount AS import,
        Customers.customerID AS [customer.id],
        Customers.socialReason AS [customer.socialReason],
        Movements.status AS [status.id],
        MovementStatus.description AS [status.description],
        Movements.saldo AS residue,
        Movements.paymentMethod AS [payMethod.id],
        PaymentMethods.description AS [payMethod.description],
        Movements.movementDate AS [date],
        Movements.bankAccount AS [bankAccount.id],
        Movements.movementType AS [type.id],
        CASE 
            WHEN Movements.movementType = 1 THEN Movements.amount*.16
            ELSE (
                SELECT 
                    (invoice.iva/invoice.total) * SUM(association.amountApplied)
                FROM ConcilationEgresses AS association
                LEFT JOIN LegalDocuments AS invoice ON invoice.id = association.idInvoice
                WHERE 
                    association.idMovement = Movements.MovementID
                GROUP BY association.idMovement
            )
        END AS [movement.iva],
        CASE
            WHEN Movements.movementType = 1 THEN
                'Ingreso'
            ELSE
                'Egreso'
        END AS [type.description]
    FROM Movements
        LEFT JOIN MovementStatus
            ON Movements.status = MovementStatus.id
        LEFT JOIN Customers
            ON Movements.customerAssociated = Customers.customerID
        INNER JOIN PaymentMethods
            ON Movements.paymentMethod = PaymentMethods.code
        LEFT JOIN Beneficiary ON Movements.idBeneficiary = Beneficiary.id
    WHERE Movements.MovementID = @id
    ORDER BY Movements.MovementID DESC
    FOR JSON PATH, ROOT('movements'), INCLUDE_NULL_VALUES



END
GO
