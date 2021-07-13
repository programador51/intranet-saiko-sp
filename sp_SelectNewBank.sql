CREATE PROCEDURE sp_SelectNewBank (

    @nameBank VARCHAR
    
)

AS BEGIN

INSERT INTO Banks 
        
        (
            socialReason, commercialName,shortName,
            status,createdBy,createdDate,
            lastUpdatedBy,lastUpdatedDate,clave
        )

        VALUES

        (
            @nameBank,@nameBank,@nameBank,
            1,'Jose Luis', getDate(),
            'Jose Luis', getDate(),999
        );

        SELECT SCOPE_IDENTITY()

END