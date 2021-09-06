Esta documentacion esta hecha para reforzar los topes encontrados y recurrir aqui.

* [Formato para documentar SP](#doc_format)
* Tutoriales
    * [Importar csv a tabla de sql server](#csv_to_sql_table)

<span href="#doc_format"></span>
## Formato de la documentacion para los SP

```sql
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- STORED PROCEDURE NAME:	sp_AddFilterUsersToRol 
-- STORED PROCEDURE OLD NAME: sp_AssignFilterUsersToRol
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @rolID - ID of the rol that was added 
-- @userID - ID of the executive(s) that can filter by
-- @createdBy - Name, middlename and 1st last name who performed this action
-- ===================================================================================================================================
-- Returns:    Value of discount expressed as % (0-100)
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-06-09		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-21      Jose Luis                   1.0.0.1         Documentation and update name of sp		
-- *****************************************************************************************************************************
```

---

<span href="#csv_to_sql_table"></span>
## Importar csv a tabla de sql server
```sql
BULK INSERT
    [Table_name_will_be_inserted_the_data]

FROM
    [Your_path_csv_is_located]

WITH(
    FIELDTERMINATOR= ',',
    ROWTERMINATOR = '\n'
)
```

**Ejemplo**
```sql
BULK INSERT
    Cabecera

FROM
    'C:\....\archivo.csv'

WITH(
    FIELDTERMINATOR= ',',
    ROWTERMINATOR = '\n'
)
```

**[Fuente](https://www.programandoamedianoche.com/2009/09/importacion-de-archivos-csv-con-el-comando-bulk-insert/)**

---