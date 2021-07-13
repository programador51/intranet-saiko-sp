SELECT
            (CASE 
                WHEN @estatus="Todos"
                THEN (SELECT contactID,firstName,middleName,lastName1,lastName2,
                    phoneNumberAreaCode,phoneNumber,cellNumberAreaCode,cellNumber,
                    email,position,status,
                    CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
                    CONCAT(phoneNumberAreaCode,' ',phoneNumber) AS phone,
                    CONCAT(cellNumberAreaCode, ' ',cellNumber)AS cellPhone
                    FROM Contacts)
                WHEN @estatus="Activo"
                THEN (SELECT contactID,firstName,middleName,lastName1,lastName2,
                    phoneNumberAreaCode,phoneNumber,cellNumberAreaCode,cellNumber,
                    email,position,status,
                    CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
                    CONCAT(phoneNumberAreaCode,' ',phoneNumber) AS phone,
                    CONCAT(cellNumberAreaCode, ' ',cellNumber)AS cellPhone
                    FROM Contacts WHERE status=1)
                WHEN @estatus="Inactivo"
                THEN (SELECT contactID,firstName,middleName,lastName1,lastName2,
                    phoneNumberAreaCode,phoneNumber,cellNumberAreaCode,cellNumber,
                    email,position,status,
                    CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
                    CONCAT(phoneNumberAreaCode,' ',phoneNumber) AS phone,
                    CONCAT(cellNumberAreaCode, ' ',cellNumber)AS cellPhone
                    FROM Contacts WHERE status=0)
            END)