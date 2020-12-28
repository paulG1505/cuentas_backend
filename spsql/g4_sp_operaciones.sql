/****************************************************************************/
/*     Archivo:     g4_sp_operaciones.sp								    */
/*     Stored procedure: g4_sp_operaciones                                  */
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
/* Realiza las operaciones de Depositar, transferir y retirar               */
/*                                                          			    */
/****************************************************************************/
/*                           MODIFICACIONES                                 */
/*       FECHA          AUTOR                  RAZON                        */
/*     28-Dic-2020      Diana Zambrano     Version inicial                  */     
/*                                                                          */
/*                                                                          */
/****************************************************************************/

USE cobis
go

IF OBJECT_ID ('dbo.g4_sp_operaciones') IS NOT NULL
	DROP PROCEDURE dbo.g4_sp_operaciones
GO

CREATE PROC g4_sp_operaciones 

   
	@s_srv           varchar(30) = NULL,
   	@s_ssn           int         = NULL,
   	@s_ssn_branch    int         = 0,
   	@s_date          datetime    = NULL,
   	@s_ofi           smallint    = NULL,
   	@s_user          varchar(30) = NULL,
   	@s_lsrv          varchar(30) = NULL,
   	@s_rol           smallint    = 1,
   	@s_term          varchar(10) = NULL,
   	@s_org           char(1)     = NULL,
   	@s_culture       varchar(10) = 'NEUTRAL',
   	@t_file          varchar(14) = NULL,
   	@i_operacion     char(1),
   	@t_trn           INT 	     =99,
   	@i_numero_cuenta VARCHAR(10),
   	@i_cliente       VARCHAR(30),
   	@i_saldo         FLOAT,
   	@i_tipo_cuenta   CHAR(1)
 
   
AS

	DECLARE 
	        @w_saldoActual FLOAT,
	        @w_error       INT
	        
			
  
--opcion: C - depositar

if @i_operacion = 'C' 
BEGIN
   IF @i_tipo_cuenta = 1
   BEGIN 
   
      IF EXISTS (SELECT 1 FROM g4_cuenta_ahorros WHERE ca_banco = @i_numero_cuenta AND ca_cliente= @i_cliente)
      BEGIN
        SELECT @w_saldoActual = ca_saldo
        FROM g4_cuenta_ahorros 
        WHERE ca_banco = @i_numero_cuenta 
        AND ca_cliente= @i_cliente
       
        UPDATE g4_cuenta_ahorros
        SET ca_saldo = @w_saldoActual+  @i_saldo,
            ca_fecha_modificacion = getdate(),
        WHERE ca_banco = @i_numero_cuenta 
        AND ca_cliente= @i_cliente
    
      END 
      ELSE
       BEGIN
            SELECT @w_error=4000
		
			exec cobis..sp_cerror
         
         	@t_debug = 'N',
         	@t_file  = null,
         	@t_from  = 'g4_sp_operaciones',
         	@i_num   = @w_error
         
         	return 1
       
       
       
       END
   
   END
   
   IF @i_tipo_cuenta = 2
   BEGIN
      IF EXISTS (SELECT 1 FROM g4_cuenta_corriente WHERE ca_banco = @i_numero_cuenta AND ca_cliente= @i_cliente)
       BEGIN
             SELECT @w_saldoActual = ca_saldo
    		 FROM g4_cuenta_corriente 
    		 WHERE ca_banco = @i_numero_cuenta 
    		 AND ca_cliente= @i_cliente
    		 
    		 UPDATE g4_cuenta_corriente
    		 SET ca_saldo = @w_saldoActual+  @i_saldo,
    		     ca_fecha_modificacion = getdate(),
    		 WHERE ca_banco = @i_numero_cuenta 
    		 AND ca_cliente= @i_cliente
       
       END
   END
   ELSE
       BEGIN
            SELECT @w_error=4000
		
			exec cobis..sp_cerror
         
         	@t_debug = 'N',
         	@t_file  = null,
         	@t_from  = 'g4_sp_operaciones',
         	@i_num   = @w_error
         
         	return 1
       
       
       
       END
	

end







--opcion: R - retirar

if @i_operacion = 'R' 
BEGIN
   IF @i_tipo_cuenta = 1
   BEGIN 
   
      IF EXISTS (SELECT 1 FROM g4_cuenta_ahorros WHERE ca_banco = @i_numero_cuenta AND ca_cliente= @i_cliente)
      BEGIN
        SELECT @w_saldoActual = ca_saldo
        FROM g4_cuenta_ahorros 
        WHERE ca_banco = @i_numero_cuenta 
        AND ca_cliente= @i_cliente
       
       IF @w_saldoActual > @i_saldo
     	 BEGIN
     	 UPDATE g4_cuenta_ahorros
     	 SET ca_saldo = @w_saldoActual- @i_saldo,
     	     ca_fecha_modificacion = getdate(),
     	 WHERE ca_banco = @i_numero_cuenta 
     	 AND ca_cliente= @i_cliente
     	 END
     	 ELSE
     	 BEGIN
     	    SELECT @w_error=4001
	 
	   		exec cobis..sp_cerror
         		
         		@t_debug = 'N',
         		@t_file  = null,
         		@t_from  = 'g4_sp_operaciones',
         		@i_num   = @w_error
         		
         		return 1
       
     	
    	 END
      END 
      ELSE
       BEGIN
            SELECT @w_error=4000
		
			exec cobis..sp_cerror
         
         	@t_debug = 'N',
         	@t_file  = null,
         	@t_from  = 'g4_sp_operaciones',
         	@i_num   = @w_error
         
         	return 1
       
       
       
       END
   
   END
   
   IF @i_tipo_cuenta = 2
   BEGIN
      IF EXISTS (SELECT 1 FROM g4_cuenta_corriente WHERE ca_banco = @i_numero_cuenta AND ca_cliente= @i_cliente)
       BEGIN
             SELECT @w_saldoActual = ca_saldo
    		 FROM g4_cuenta_corriente 
    		 WHERE ca_banco = @i_numero_cuenta 
    		 AND ca_cliente= @i_cliente
    		
    		 IF @w_saldoActual > @i_saldo
    		 BEGIN
    		 UPDATE g4_cuenta_corriente
    		 SET ca_saldo = @w_saldoActual- @i_saldo,
    		     ca_fecha_modificacion = getdate(),
    		 WHERE ca_banco = @i_numero_cuenta 
    		 AND ca_cliente= @i_cliente
    		 END
    		 ELSE
    		 BEGIN
    		    SELECT @w_error=4001
		
		  		exec cobis..sp_cerror
          		
          		@t_debug = 'N',
          		@t_file  = null,
          		@t_from  = 'g4_sp_operaciones',
          		@i_num   = @w_error
          		
          		return 1
        
    		 
    		 
    		 END
       
       END
   END
   ELSE
       BEGIN
            SELECT @w_error=4000
		
			exec cobis..sp_cerror
         
         	@t_debug = 'N',
         	@t_file  = null,
         	@t_from  = 'g4_sp_operaciones',
         	@i_num   = @w_error
         
         	return 1
       
       
       
       END
	

end










	






--opcion: T - transferir

















RETURN 0

go