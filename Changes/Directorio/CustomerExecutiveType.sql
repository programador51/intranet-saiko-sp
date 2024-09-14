-- Este tipo de tabla se utiliza para cambiar el ejecutivo que atiende al cliente
CREATE TYPE CustomerExecutiveType AS TABLE 
(
    idCustomer INT,
    idExecutive INT
);