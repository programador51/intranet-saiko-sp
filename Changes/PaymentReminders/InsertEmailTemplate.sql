-- Eliminar la restricción
ALTER TABLE [dbo].[EmailTemplates]
DROP CONSTRAINT [availableModules];

-- Crear una nueva restricción
ALTER TABLE [dbo].[EmailTemplates]  WITH CHECK ADD  CONSTRAINT [availableModules] CHECK  (
    (
        [module]='recordatorioContratos' 
        OR [module]='complemento' 
        OR [module]='recordatorioPagos4' 
        OR [module]='recordatorioPagos3' 
        OR [module]='recordatorioPagos2' 
        OR [module]='recordatorioPagos1' 
        OR [module]='contrato' 
        OR [module]='cotizacion' 
        OR [module]='facturaEmitida' 
        OR [module]='notaDeCredito' 
        OR [module]='oc' 
        OR [module]='pedido'
        OR [module]='banckAccountCxcReminder'
        OR [module]='emailSupport'
        OR [module]='phoneSupport'
        OR [module]='coprobanteEmail'        
    )
)
GO
ALTER TABLE [dbo].[EmailTemplates] CHECK CONSTRAINT [availableModules]


DECLARE @createdBy NVARCHAR(50)= 'Adrian Alardin Iracheta';

INSERT INTO EmailTemplates (
    body,
    createdBy,
    createdDate,
    [module],
    [subject],
    updatedBy,
    updatedDate
)
VALUES (
 '',
 @createdBy,
 GETUTCDATE(),
 'banckAccountCxcReminder',
 'Test',
 @createdBy,
 GETUTCDATE()
),
-- VALUES (
--  '<p>Pagos en pesos</p><p>Beneficiario: Grupo Saiko S de RL de CV</p><p>Moneda: M.N.</p><p>Banco: BBVA Bancomer</p><p>Cuenta:  0453675084        </p><p>CLABE: 012580004536750846</p><p>Sucursal: 0840</p><p>Plaza: Garza Garcia NL</p><p>Pagos en dólares</p><p>Beneficiario: Grupo Saiko S de RL de CV</p><p>Moneda: U.S.D.</p><p>Banco: BBVA Bancomer</p><p>Cuenta:  0136385893        </p><p>CLABE: 012580001363858930</p><p>Sucursal: 0840</p><p>Plaza: Garza Garcia NL</p><p>Pagos en dólares desde bancos internacionales</p><p>Beneficiario: Grupo Saiko S de RL de CV</p><p>Moneda: U.S.D.</p><p>Banco: MONEX SA. INSTITUCION DE BANCA MULTIPLE </p><p>Cuenta: 02712578</p><p>CLABE SPID:112962000027125787</p><p>ABA o Routing: 112180</p><p>SWIFT CODE: MONXMXMM</p><p>Observación: DO NOT CONVERT</p>',
--  @createdBy,
--  GETUTCDATE(),
--  'banckAccountCxcReminder',
--  'Test',
--  @createdBy,
--  GETUTCDATE()
-- ),
(
    'mail@gmai.com',
     @createdBy,
    GETUTCDATE(),
    'emailSupport',
     'Test',
    @createdBy,
    GETUTCDATE()
),
(
    '(818) 215-5100',
     @createdBy,
    GETUTCDATE(),
    'phoneSupport',
     'Test',
    @createdBy,
    GETUTCDATE()
),
(
    'comprobantefiscal@saiko.mx',
     @createdBy,
    GETUTCDATE(),
    'coprobanteEmail',
     'Test',
    @createdBy,
    GETUTCDATE()
)
