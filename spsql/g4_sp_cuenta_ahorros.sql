IF OBJECT_ID ('dbo.g4_sp_cuenta_ahorros') IS NOT NULL
	DROP PROCEDURE dbo.g4_sp_cuenta_ahorros
GO

CREATE PROCEDURE g4_sp_cuenta_ahorros

/****************************************************************************/
/*     Archivo:     g4_sp_cuenta_ahorros.sp								    */
/*     Stored procedure: g4_sp_cuenta_ahorros                               */
/*     Base de datos: cobis											        */
/*     Producto: Taller Banco                                               */
/*     Disenado por: Diana Zambrano                                         */
/*     Fecha de escritura: 28-Dic-2020                                      */
/****************************************************************************/
/*                            IMPORTANTE                                    */
/*    Esta aplicacion es parte de los paquetes bancarios propiedad          */
/*    de COBISCorp.                                                         */
/*    Su uso no    autorizado queda  expresamente   prohibido asi como      */
/*    cualquier    alteracion o  agregado  hecho por    alguno  de sus      */
/*    usuarios sin el debido consentimiento por   escrito de COBISCorp.     */
/*    Este programa esta protegido por la ley de   derechos de autor        */
/*    y por las    convenciones  internacionales   de  propiedad inte-      */
/*    lectual.    Su uso no  autorizado dara  derecho a    COBISCorp para   */
/*    obtener ordenes  de secuestro o  retencion y para  perseguir          */
/*    penalmente a los autores de cualquier   infraccion.                   */
/****************************************************************************/
/*                           PROPOSITO                                      */
/* Inserta cuenta de ahorros           		                    	        */
/*                                                          			    */
/****************************************************************************/
/*                           MODIFICACIONES                                 */
/*       FECHA          AUTOR                  RAZON                        */
/*     28-Dic-2020      Diana Zambrano     Version inicial                  */     
/*                                                                          */
/*                                                                          */
/****************************************************************************/

   @s_srv                   varchar(30) = NULL,
   @s_ssn                   int         = NULL,
   @s_ssn_branch            int         = 0,
   @s_date                  datetime    = NULL,
   @s_ofi                   smallint    = NULL,
   @s_user                  varchar(30) = NULL,
   @s_lsrv		            varchar(30) = NULL,
   @s_rol		            smallint    = 1,
   @s_term		            varchar(10) = NULL,
   @s_org		            char(1)     = NULL,
   @s_culture	            varchar(10) = 'NEUTRAL',
   @t_file		            varchar(14) = NULL,
   @i_operacion	   	        char(1),
   @t_trn		   	        INT =99,
   @i_banco		        	VARCHAR(30) = NULL,
   @i_fecha_creacion		VARCHAR(30) = NULL,     
   @i_fecha_modificacion	VARCHAR(30) = NULL,
   @i_cliente	         	VARCHAR(30) = NULL,
   @i_saldo	                VARCHAR(30) = NULL
   
  
  
AS
    declare @w_sp_name       varchar(14),
            @w_respuesta     VARCHAR(10)
            
   	select @w_sp_name = 'g4_sp_cuenta_ahorros'
   
            
    IF @i_operacion='I'
    BEGIN
         EXEC g4_sp_gen_code
              @o_cod_id_reg  = @w_respuesta OUTPUT,
              @i_operacion   = 'A'
              
              
              
        INSERT INTO g4_cuenta_ahorros
    		(ca_banco,  ca_fecha_creacion,  ca_fecha_modificacion,  ca_cliente,  ca_saldo)
    	VALUES 
    		(@w_respuesta,  getdate(),		    null,              @i_cliente,  @i_saldo)
    END
    
   return 0


GO

