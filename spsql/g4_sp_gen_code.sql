/************************************************************************/
/*      Archivo:                g4_sp_gen_code                          */
/*      Stored procedure:       g4_sp_gen_code                          */
/*      Base de datos:          cobis                                   */
/*      Producto:               Ahorro                                  */
/*      Disenado por:           Diana Zambrano                          */
/*      Fecha de escritura:     28/Dic/2020                             */
/************************************************************************/
/*                              IMPORTANTE                              */
/*      Este programa es parte de los paquetes bancarios propiedad de   */
/*      'COBISCORP'.                                                    */
/*      Su uso no autorizado queda expresamente prohibido asi como      */
/*      cualquier alteracion o agregado hecho por alguno de sus         */
/*      usuarios sin el debido consentimiento por escrito de la         */
/*      Presidencia Ejecutiva de COBISCORP o su representante.          */
/************************************************************************/
/*                              PROPOSITO                               */
/*      Generar un código de cuenta de 10 digitos                       */
/************************************************************************/
/*                             MODIFICACION                             */
/*    FECHA                 AUTOR                 RAZON                 */
/*    28/Dic/2020           Diana Zambrano        Version Inicial       */
/************************************************************************/

use cobis
go

if exists (select 1 from sysobjects where name = 'g4_sp_gen_code')
    drop proc g4_sp_gen_code
go

create proc g4_sp_gen_code(
--@i_fecha_valida  datetime,
@o_cod_id_reg   varchar(10)  OUTPUT,
@i_operacion    CHAR(1)
)
as

declare
@w_sp_name              varchar(25),
@w_numero_digitos       int,
@w_upper                int,
@w_lower                int,
@w_random               int,
@w_str_result           varchar(10),
@w_str_number           varchar(1),
@w_bandera_generacion   int,
@w_bandera_prueba       int,
@w_cod_registro         int,
@w_fecha_proceso        datetime

-- Variables
select @w_sp_name = 'g4_sp_gen_code'
select @w_str_result = '1'
select @w_numero_digitos = 9
select @w_bandera_generacion = 0 
-- Variables para generar aleatorio entre 0 y 9 
select @w_lower = 0  -- numero menor 
select @w_upper = 9  -- numero mayor


IF @i_operacion ='A'
BEGIN  
   
   while 1 = 1
   begin
      while @w_bandera_generacion<@w_numero_digitos
      begin
         select @w_random = ROUND(((@w_upper - @w_lower -1) * RAND() + @w_lower), 0)
         select @w_str_number = convert(varchar(1),@w_random) 
         select @w_str_result = @w_str_result + @w_str_number 
         select @w_bandera_generacion = @w_bandera_generacion + 1   
      end
      
      select @w_cod_registro = count(1)
      from cobis..g4_cuenta_ahorros
      where ca_banco = @w_str_result
      
      
      if @w_cod_registro = 0
      begin  
        print 'Ingreso a enviar el codigo'
        break
      end
      else
      begin
      print 'Codigo repetido'
         select @w_bandera_generacion = 0 
         select @w_str_result = '1'
         
      end
   
   END
END

IF @i_operacion ='C'
BEGIN  
   
   while 1 = 1
   begin
      while @w_bandera_generacion<@w_numero_digitos
      begin
      select @w_random = ROUND(((@w_upper - @w_lower -1) * RAND() + @w_lower), 0)
      select @w_str_number = convert(varchar(10),@w_random) 
      select @w_str_result = @w_str_result + @w_str_number   
      select @w_bandera_generacion = @w_bandera_generacion + 1   
      end
      
      select @w_cod_registro = count(1)
      from cobis..g4_cuenta_corriente
      where ca_banco = @w_str_result
      
      
      if @w_cod_registro = 0
      begin  
        print 'Ingreso a enviar el codigo'
        break
      end
      else
      begin
      print 'Codigo repetido'
         select @w_bandera_generacion = 0 
         select @w_str_result = '1'
         
      end
   
   END
END

PRINT @w_str_result
select @o_cod_id_reg = convert(VARCHAR(10),@w_str_result)
return 0

go