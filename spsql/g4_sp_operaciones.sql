IF OBJECT_ID ('dbo.g4_sp_operaciones') IS NOT NULL
	DROP PROCEDURE dbo.g4_sp_operaciones
GO

CREATE PROC g4_sp_operaciones 

   
	@s_srv                      varchar(30) = NULL,
   	@s_ssn                      int         = NULL,
   	@s_ssn_branch               int         = 0,
   	@s_date                     datetime    = NULL,
   	@s_ofi                      smallint    = NULL,
   	@s_user                     varchar(30) = NULL,
   	@s_lsrv                     varchar(30) = NULL,
   	@s_rol                      smallint    = 1,
   	@s_term                     varchar(10) = NULL,
   	@s_org                      char(1)     = NULL,
   	@s_culture                  varchar(10) = 'NEUTRAL',
   	@t_file                     varchar(14) = NULL,
   	@i_operacion                char(1),
   	@t_trn                      INT 	    = 99,
   	@i_numero_cuenta            INT,          
   	@i_numero_cuenta_destino	INT         =  NULL,
   	@i_cliente                  VARCHAR(30) = NULL,
   	@i_valor                    FLOAT		= 0	,
   	@i_saldo                    FLOAT		= 0	,
   	@i_tipo_cuenta              VARCHAR(10)	= NULL,
   	@i_tipo_cuenta_destino	    VARCHAR(10)	= NULL
   
AS

	DECLARE 
	        @w_saldoActual FLOAT,
	        @w_saldoDestino FLOAT,
	        @w_error       INT,
	        @w_ced_cliente VARCHAR(30),
	        @w_nom_cliente VARCHAR(30),
	        @w_ape_cliente VARCHAR(30),
	        @w_tipo_cuenta varCHAR(10),
	        @w_num_cuenta  INT
	        
	        
	        
	        
	        
--opcion: Q - consultar datos de cuenta

if @i_operacion = 'Q'
	BEGIN

	
		IF (SELECT COUNT(*) from g4_cuenta_ahorros WHERE ca_banco = @i_numero_cuenta )<>0
		
		BEGIN
		
			SET	@i_cliente = (SELECT [ca_cliente] FROM g4_cuenta_ahorros WHERE ca_banco = @i_numero_cuenta)
			
			SELECT ca_banco,
					ca_cliente,
			       CAST(ca_saldo AS VARCHAR),
			       cl_cedula,
			       cl_nombre,
			       cl_apellido,
			      'tipo_cuenta '='Ahorros'
			       
		 	FROM g4_cuenta_ahorros INNER JOIN cliente_taller ON cl_id=@i_cliente
		 	WHERE ca_banco=@i_numero_cuenta
		 	
		END

		ELSE IF (SELECT COUNT(*) from g4_cuenta_corriente WHERE ca_banco = @i_numero_cuenta)<>0
		
		BEGIN
		 	
		 	SET	@i_cliente = (SELECT [ca_cliente] FROM g4_cuenta_corriente WHERE ca_banco = @i_numero_cuenta)
		 	
			SELECT ca_banco,
			      ca_cliente,
			       CAST(ca_saldo AS VARCHAR),
			       cl_cedula,
			       cl_nombre,
			       cl_apellido,
			      'tipo_cuenta '='Corriente'
			       
		 	FROM g4_cuenta_corriente INNER JOIN cliente_taller ON cl_id=@i_cliente	 	
		 	WHERE ca_banco=@i_numero_cuenta	
			
			
		END
		
		
	
	END



 


       
			
  
--opcion: C - depositar

if @i_operacion = 'C' 
BEGIN
   IF @i_tipo_cuenta = 'Ahorros'
   BEGIN 
   
      IF EXISTS (SELECT 1 FROM g4_cuenta_ahorros WHERE ca_banco = @i_numero_cuenta AND ca_cliente= @i_cliente)
      BEGIN
        SELECT @w_saldoActual = ca_saldo
        FROM g4_cuenta_ahorros 
        WHERE ca_banco = @i_numero_cuenta 
        AND ca_cliente= @i_cliente
       
        UPDATE g4_cuenta_ahorros
        SET ca_saldo = @w_saldoActual+  @i_saldo,
            ca_fecha_modificacion = getdate()
        WHERE ca_banco = @i_numero_cuenta 
        AND ca_cliente= @i_cliente
        
        INSERT INTO g4_transaccion
               	(
               	tr_fecha,            	tr_cuenta,            	tr_tipo_tr,            	tr_tipo_cuenta
               	)
                   VALUES 
               	(
               	GETDATE(),            	@i_numero_cuenta,            	'D',            	@i_tipo_cuenta
               	)
    
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
   
   IF @i_tipo_cuenta = 'Corriente'
   BEGIN
      IF EXISTS (SELECT 1 FROM g4_cuenta_corriente WHERE ca_banco = @i_numero_cuenta AND ca_cliente= @i_cliente)
       BEGIN
             SELECT @w_saldoActual = ca_saldo
    		 FROM g4_cuenta_corriente 
    		 WHERE ca_banco = @i_numero_cuenta 
    		 AND ca_cliente= @i_cliente
    		 
    		 UPDATE g4_cuenta_corriente
    		 SET ca_saldo = @w_saldoActual+  @i_saldo,
    		     ca_fecha_modificacion = getdate()
    		 WHERE ca_banco = @i_numero_cuenta 
    		 AND ca_cliente= @i_cliente
    		 
    		 INSERT INTO g4_transaccion
               	(
               	tr_fecha,            	tr_cuenta,            	tr_tipo_tr,            	tr_tipo_cuenta
               	)
                   VALUES 
               	(
               	GETDATE(),            	@i_numero_cuenta,            	'D',            	@i_tipo_cuenta
               	)
       
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
   
	

end







--opcion: R - retirar

if @i_operacion = 'R' 
BEGIN
 IF @i_tipo_cuenta = 'Ahorros'
   BEGIN 
      PRINT 'Ingreso a la opcion ahorros'
      IF EXISTS (SELECT 1 FROM g4_cuenta_ahorros WHERE ca_banco = @i_numero_cuenta AND ca_cliente= @i_cliente)
      BEGIN
        
        SELECT @w_saldoActual = ca_saldo
        FROM g4_cuenta_ahorros 
        WHERE ca_banco = @i_numero_cuenta 
        AND ca_cliente= @i_cliente
        
        PRINT @w_saldoActual
        PRINT @i_saldo
       
       IF @w_saldoActual > @i_saldo
     	 BEGIN
     	    
     	    PRINT 'Si hay dinero'
     	    
     	    UPDATE g4_cuenta_ahorros
     	    SET ca_saldo = @w_saldoActual- @i_saldo,
     	        ca_fecha_modificacion = getdate()
     	    WHERE ca_banco = @i_numero_cuenta 
     	    AND ca_cliente= @i_cliente
     	    
     	    
     	    INSERT INTO g4_transaccion
               	(
               	tr_fecha,            	tr_cuenta,            	tr_tipo_tr,            	tr_tipo_cuenta
               	)
                   VALUES 
               	(
               	GETDATE(),            	@i_numero_cuenta,            	'R',            	'Ahorros'
               	)
               	
               	
               	
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
   
   IF @i_tipo_cuenta = 'Corriente'
   BEGIN
      PRINT 'Ingreso a la opcion Corriente'
      
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
    		        ca_fecha_modificacion = getdate()
    		    WHERE ca_banco = @i_numero_cuenta 
    		    AND ca_cliente= @i_cliente
    		    
                
                
                INSERT INTO dbo.g4_transaccion
            	(
            	tr_fecha,            	tr_cuenta,            	tr_tipo_tr,            	tr_tipo_cuenta
            	)
                VALUES 
            	(
            	GETDATE(),            	@i_numero_cuenta,            	'R',            	'Corriente'
            	)
            
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
	

end




--opcion: T - transferir
IF	@i_operacion = 'T'
	
	BEGIN
	
		IF @i_tipo_cuenta = 'Ahorros'
		
		BEGIN
		
			SET @w_saldoActual = (SELECT [ca_saldo] FROM g4_cuenta_ahorros WHERE ca_banco=@i_numero_cuenta)
			
			IF @i_tipo_cuenta_destino = 'Ahorros'
			
			BEGIN
			
				SET @w_saldoDestino = (SELECT [ca_saldo] FROM g4_cuenta_ahorros WHERE ca_banco=@i_numero_cuenta_destino)
				
				UPDATE g4_cuenta_ahorros SET
				ca_fecha_modificacion = getdate(),
				ca_saldo			  = (@w_saldoDestino+@i_valor)
				WHERE ca_banco=@i_numero_cuenta_destino
			
			END
			
			ELSE IF @i_tipo_cuenta_destino = 'Corriente'
			
			BEGIN
			
				SET @w_saldoDestino = (SELECT [ca_saldo] FROM g4_cuenta_corriente WHERE ca_banco=@i_numero_cuenta_destino)
				
				UPDATE g4_cuenta_corriente SET
				ca_fecha_modificacion = getdate(),
				ca_saldo			  = (@w_saldoDestino+@i_valor)
				WHERE ca_banco=@i_numero_cuenta_destino
				
			
			END
			
			UPDATE g4_cuenta_ahorros SET
				ca_fecha_modificacion = getdate(),
				ca_saldo			  = (@w_saldoActual-@i_valor)
				WHERE ca_banco=@i_numero_cuenta
		
		END
		
		
		
		ELSE IF	@i_tipo_cuenta = 'Corriente'
		
		BEGIN
		
			SET @w_saldoActual = (SELECT [ca_saldo] FROM g4_cuenta_corriente WHERE ca_banco=@i_numero_cuenta)
			
			IF @i_tipo_cuenta_destino = 'Ahorros'
			
			BEGIN
			
				SET @w_saldoDestino = (SELECT [ca_saldo] FROM g4_cuenta_ahorros WHERE ca_banco=@i_numero_cuenta_destino)
				
				UPDATE g4_cuenta_ahorros SET
				ca_fecha_modificacion = getdate(),
				ca_saldo			  = (@w_saldoDestino+@i_valor)
				WHERE ca_banco=@i_numero_cuenta_destino
			
			END
			
			ELSE IF @i_tipo_cuenta_destino = 'Corriente'
			
			BEGIN
			
				SET @w_saldoDestino = (SELECT [ca_saldo] FROM g4_cuenta_corriente WHERE ca_banco=@i_numero_cuenta_destino)
				
				UPDATE g4_cuenta_corriente SET
				ca_fecha_modificacion = getdate(),
				ca_saldo			  = (@w_saldoDestino+@i_valor)
				WHERE ca_banco=@i_numero_cuenta_destino
				
			
			END
			
			UPDATE g4_cuenta_corriente SET
				ca_fecha_modificacion = getdate(),
				ca_saldo			  = (@w_saldoActual-@i_valor)
				WHERE ca_banco=@i_numero_cuenta
		
		END		
	
end
RETURN 0


--opcion: S - Permite consultar transsacciones

   if @i_operacion = 'S'
	BEGIN
	   IF EXISTS(SELECT 1 FROM g4_transaccion WHERE tr_cuenta = @i_numero_cuenta)
	   BEGIN
	      SELECT 'id'       = tr_id,
	             'fecha'    = tr_fecha,
	             'cuenta'   = tr_cuenta,
	             'tipo_tr'  = tr_tipo_tr,
	             'tipo_c'   = tr_tipo_cuenta      
	      FROM g4_transaccion
	      WHERE tr_cuenta = @i_numero_cuenta
	
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

 








GO

