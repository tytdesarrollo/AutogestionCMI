IF OBJECT_ID('CERT_LABORALES1 ') IS NOT NULL
BEGIN 
	DROP PROCEDURE CERT_LABORALES1 ;
END
GO

/***********************************OBJETIVO: GENERA LOS CERTIFICADOS LABORALES ************************************

-- PARAMETROS DE ENTRADA
   -- CODIGO_
   
   EPL          : CODIGO DEL EMPLEADO
   -- TIPO                : TIPO DE CERTIFICADO (NORMAL CON SALARIO Ó NORMAL SIN SALARIO)   
                            1 CON SALARIO
                            2 SIN SALARIO                            
   -- DESTINATARIO     : A QUIEN VA DIRIGIDO EL CERTIFICADO  
   
   _*  SEPARADOR DE VARIABLES

************************************  DECLARACION DE VARIABLE  ************************************************************ */


CREATE PROCEDURE CERT_LABORALES1 
(

	@CODIGO_EPL VARCHAR(15), 
    @TIPO VARCHAR, 
    @DESTINATARIO  VARCHAR(50),                                                                                                           
	@BLOQUEA  VARCHAR(MAX) OUTPUT, --Encabezado del Certificado
    @BLOQUET  VARCHAR(MAX) OUTPUT, --Titulo del certificado
    @BLOQUEB  NVARCHAR(MAX) OUTPUT, -- Cuerpo del mensaje
    @BLOQUEC  VARCHAR(MAX) OUTPUT -- Firma y cargo del certificado 
)

AS

DECLARE @FAX                           VARCHAR(15);
DECLARE @EMPRESA_REAL                  VARCHAR(60);
DECLARE @NIT_REAL                      VARCHAR(50);
DECLARE @NOM_CIU                       VARCHAR(10);
DECLARE @TEL_1                         VARCHAR(10);
DECLARE @SEXO                          VARCHAR(1); 
DECLARE @NOMBRE_EPL                    VARCHAR(150);
DECLARE @CEDULA                        VARCHAR(18);
DECLARE @SAL_BAS                       DECIMAL(15,2);
DECLARE @NOM_CAR                       VARCHAR(40);
DECLARE @INI_CTO                       VARCHAR(11);
DECLARE @FEC_RET                       DATETIME;
DECLARE @VTO_CTO					   DATETIME;
DECLARE @F_VENCI                       VARCHAR(100)=' ';
DECLARE @TIP_DOC                       VARCHAR(1);
DECLARE @TIP_DOC2                      VARCHAR(50);
DECLARE @NOM_CTO                       VARCHAR(30);
DECLARE @TIPO_CONTRATO                 VARCHAR(20);
DECLARE @CADENA6                       VARCHAR(150);
DECLARE @CADENA7                       VARCHAR(150);
DECLARE @CADENA8                       VARCHAR(150);
DECLARE @DIA                           INT;
DECLARE @MES                           VARCHAR(15);             
DECLARE @AÑO                           INT;    
DECLARE @NOM_MES                       VARCHAR(20);     
DECLARE @SALARIO                       VARCHAR(100);
DECLARE @XVALOR                        VARCHAR(150);
DECLARE @VOk                           VARCHAR(200);
DECLARE @ENCABEZA1                     VARCHAR(150); 
DECLARE @ENCABEZA2                     VARCHAR(150);
DECLARE @ENCABEZA3                     VARCHAR(150); 
DECLARE @ENCABEZA4                     VARCHAR(150); 
DECLARE @ENCABEZA5                     VARCHAR(150);
DECLARE @CANTIDAD2                     INT;
DECLARE @TITULO1                       VARCHAR(150);          
DECLARE @TITULO2                       VARCHAR(150);
DECLARE @FIRMA                         VARCHAR(100);  
DECLARE @CARGO                         VARCHAR(100);
BEGIN
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------- CERTIFICADO NORMAL CON SALARIO ---------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET LANGUAGE Spanish;

IF (@TIPO='1')                             
	BEGIN 
       
		SELECT @EMPRESA_REAL=P.NOM_EMP,@NIT_REAL =(P.NIT_EMP +'-'+ CAST(P.DIGITO_VER AS VARCHAR))                                             
		FROM EMPLEADOS_BASIC E,EMPRESAS P
		WHERE E.COD_EMP=P.COD_EMP 
		AND E.COD_EPL=@CODIGO_EPL;					
		
		SET  @CANTIDAD2=(
			SELECT COUNT(*)+1 
			FROM LOG_CERTIFICADOS);
        
		      
		SET  @ENCABEZA1 = 'Transv. 60 (Av. Suba) No. 114 A-55';
		SET  @ENCABEZA2 = 'Bogotá D.C. - Colombia';
		SET  @ENCABEZA3 = 'LÍnea Única Nacional 018000361645';
		SET  @ENCABEZA4 = 'www.telefonica.co';
		SET  @ENCABEZA5 = 'Consecutivo: 000'+''+CAST(@CANTIDAD2 AS VARCHAR);
		SET  @TITULO1 = '<B>DIRECCIÓN GESTIÓN DE RECURSOS HUMANOS</B>';
		SET  @TITULO2 = '<B>CERTIFICACIÓN</B>';
        
		SET @BLOQUEA = (@EMPRESA_REAL+'<BR>'+@NIT_REAL+'<BR>'+@ENCABEZA1+'<BR>'+@ENCABEZA2+'<BR>'+@ENCABEZA3+'<BR>'+@ENCABEZA4+'<BR>'+@ENCABEZA5);      
                                            
		SET @BLOQUET = '<BR>'+@TITULO1+'<BR><BR>'+@TITULO2;

	   
	   --DATOS DEL EMPLEADO

        SELECT @SEXO=C.SEXO,@NOMBRE_EPL =(NOM_EPL+' '+APE_EPL),@CEDULA=CEDULA,@SAL_BAS=SAL_BAS,@NOM_CAR=NOM_CAR,
		@INI_CTO=INI_CTO,@FEC_RET=FEC_RET, 
		@VTO_CTO=VTO_CTO,@TIP_DOC=A.TIPO_DOC, @NOM_CTO=CON.NOM_CTO 
		FROM EMPLEADOS_BASIC A, CARGOS B, EMPLEADOS_GRAL C, CONTRATOS CON 
		WHERE A.COD_CAR=B.COD_CAR 
		AND A.COD_EPL=C.COD_EPL 
		AND A.ESTADO='A' 
		AND A.COD_EPL=@CODIGO_EPL 
		AND A.COD_CTO=CON.COD_CTO;


			 
		SET @VOk =dbo.ImportEnLetras(@SAL_BAS); -- LLAMO LA FUNCION PARA CONVERTIR NUMEROS EN LETRAS
				 
		--SET	@VOk = (UPPER(@VOk));                
		SET @SALARIO = (CONVERT(VARCHAR,@SAL_BAS));
		SET	@SALARIO = RTRIM(LTRIM(@SALARIO));
		SET	@XVALOR = CAST(@SAL_BAS AS INT);
			
			
		IF (@XVALOR < 1) 
			BEGIN
				SET	@XVALOR = ' CERO PESOS ';
			END
		ELSE 
			BEGIN
				IF (@XVALOR >= 1 ) AND (@XVALOR <= 2)
					BEGIN
						SET	@XVALOR = ' UN PESO ';
					END
				ELSE
					IF (@XVALOR >=2)
						BEGIN
							SET	@XVALOR = ' PESOS M/CTE ';
						END
	
			END;
												
													
		IF (@TIP_DOC='C')
			BEGIN
				SET @TIP_DOC2 = 'cedula de ciudadania ';
			END
		ELSE
			BEGIN
				IF (@TIP_DOC='E')
					BEGIN
						SET   @TIP_DOC2 = 'cedula de extranjeria';
					END
				ELSE
					BEGIN
						IF (@TIP_DOC='T')
							BEGIN
								SET   @TIP_DOC2 = 'tarjeta de identidad';
							END
					END
			END;
					 
		IF (@VTO_CTO IS NOT NULL)
			BEGIN
				SET @F_VENCI = ' hasta el '+''+CAST(@VTO_CTO AS VARCHAR);
			END
	

	


		BEGIN	
				SELECT @TIPO_CONTRATO=(CASE WHEN COD_GRU='2' THEN 'INTEGRAL' WHEN COD_GRU='1' THEN 'BÁSICO' WHEN COD_GRU IN ('3','5') THEN 'APRENDICES' END)        
				FROM EPL_GRUPOS
				WHERE COD_EPL=@CODIGO_EPL AND COD_GRU IN (1,2,3);

				IF (@TIPO_CONTRATO='INTEGRAL') 
					BEGIN
						SET @CADENA6 = ' bajo la modalidad de <B>SALARIO INTEGRAL.</B>';
						SET @CADENA7 = ' una asignacion salarial mensual';
						SET @CADENA8 = ' trabajo a termino <B>'+@NOM_CTO+'/B';
					END;
                ELSE
					IF (@TIPO_CONTRATO='APRENDICES')
						BEGIN
							SET @CADENA6 = ' bajo la modalidad de <B>APOYO DE SOSTENIMIENTO.</B>';
							SET @CADENA7 = ' asignacion mensual ';
							SET @CADENA8 = 'B'+@NOM_CTO+'/B';   
						END;   
                    ELSE
						IF (@TIPO_CONTRATO='BÁSICO') 
							BEGIN
								SET @CADENA6 = ' bajo la modalidad de <B>SALARIO BASICO.</B>';
								SET @CADENA7 = ' una asignacion salarial mensual ';
								SET @CADENA8 = ' trabajo a termino <B>'+@NOM_CTO+'</B>';
							 END;  
			END;

			BEGIN	
				  SET  @DIA = DATENAME (DAY,CONVERT(VARCHAR,GETDATE()));
				  SET  @MES = DATENAME (MONTH,CONVERT(VARCHAR,GETDATE()));                        
				  SET  @AÑO =  DATENAME (YEAR,CONVERT(VARCHAR,GETDATE()));
			END;

		
			SET @BLOQUEB =(N'LA DIRECCIÓN GESTIÓN DE RECURSOS HUMANOS certifica que <B>'+' '+@NOMBRE_EPL+' '+'</B> con <B>'+' '+@TIP_DOC2+' '+
			' No. '+' '+@CEDULA+' '+'</B>, se encuentra vinculado(a) para la compañía desde el '+' '+@INI_CTO+' '+@F_VENCI+' '+', con un contrato de '
			+' '+@CADENA8+' '+', en el cargo de <B>'+' '+@NOM_CAR+' '+'</B> con '+' '+@CADENA7+' '+' de <B>'+' '+@VOk+' '+@XVALOR+' '+'($'+' '+@SALARIO+' '+') </B>'
			+''+ @CADENA6+''+'</BR>'+''+'<BR><BR><BR>'+''+'La presente certificación se expide a solicitud del interesado a los '+''+CAST(@DIA AS VARCHAR)
			+' '+' dias del mes de '+' '+CAST(@MES AS VARCHAR)+''+' de '+''+CAST(@AÑO AS VARCHAR)+''+' para ser presentado a '+''+@DESTINATARIO+''+'.'+' '+'<BR><BR><BR>'
			+' '+'Para confirmar este certificado, comuniquese con la linea unica nacional 018000361645.'+' '+'<BR><BR><BR><BR><BR>'+' '+'Cordialmente,');
	
		

			BEGIN
				SELECT @FIRMA=var_carac, @CARGO=descripcion
				FROM parametros_nue 
				WHERE nom_var = 't_epl_fir_cer_lab';	
			END;
			SET @BLOQUEC = ('<B>'+''+@FIRMA+''+'</B>'+''+'<BR>'+''+@CARGO); 
						
	END
	
ELSE

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------- CERTIFICADO NORMAL SIN SALARIO ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	BEGIN
BEGIN
		IF (@TIPO='2')   
		
				SELECT @EMPRESA_REAL=P.NOM_EMP,@NIT_REAL =(P.NIT_EMP +'-'+ CAST(P.DIGITO_VER AS VARCHAR))                                             
				FROM EMPLEADOS_BASIC E,EMPRESAS P
				WHERE E.COD_EMP=P.COD_EMP 
				AND E.COD_EPL=@CODIGO_EPL;
		
				SET  @CANTIDAD2=(
				SELECT COUNT(*)+1 
				FROM LOG_CERTIFICADOS);
		

		SET  @ENCABEZA1 = 'Transv. 60 (Av. Suba) No. 114 A-55';
		SET  @ENCABEZA2 = 'Bogotá D.C. - Colombia';
		SET  @ENCABEZA3 = 'LÍnea Única Nacional 018000361645';
		SET  @ENCABEZA4 = 'www.telefonica.co';
		SET  @ENCABEZA5 = 'Consecutivo: 000'+''+CAST(@CANTIDAD2 AS VARCHAR);
		SET  @TITULO1 = '<B>DIRECCIÓN GESTIÓN DE RECURSOS HUMANOS</B>';
		SET  @TITULO2 = '<B>CERTIFICACIÓN</B>';
        
		SET @BLOQUEA = (@EMPRESA_REAL+'<BR>'+@NIT_REAL+'<BR>'+@ENCABEZA1+'<BR>'+@ENCABEZA2+'<BR>'+@ENCABEZA3+'<BR>'+@ENCABEZA4+'<BR>'+@ENCABEZA5);      
        SET @BLOQUET = '<BR>'+@TITULO1+'<BR><BR>'+@TITULO2;

		

			   --DATOS DEL EMPLEADO

			SELECT @SEXO=C.SEXO,@NOMBRE_EPL =(NOM_EPL+' '+APE_EPL),@CEDULA=CEDULA,@SAL_BAS=SAL_BAS,@NOM_CAR=NOM_CAR,
			@INI_CTO=INI_CTO,@FEC_RET=FEC_RET, 
			@VTO_CTO=VTO_CTO,@TIP_DOC=A.TIPO_DOC, @NOM_CTO=CON.NOM_CTO 
			FROM EMPLEADOS_BASIC A, CARGOS B, EMPLEADOS_GRAL C, CONTRATOS CON 
			WHERE A.COD_CAR=B.COD_CAR 
			AND A.COD_EPL=C.COD_EPL 
			AND A.ESTADO='A' 
			AND A.COD_EPL=@CODIGO_EPL 
			AND A.COD_CTO=CON.COD_CTO;


			SET @VOk ='un millon quinientos mil pesos'; ---ImportEnLetras(@SAL_BAS); -- LLAMO LA FUNCION PARA CONVERTIR NUMEROS EN LETRAS
				 
			SET	@VOk = (UPPER(@VOk));                
			SET @SALARIO = (CONVERT(VARCHAR,@SAL_BAS));
			SET	@SALARIO = RTRIM(LTRIM(@SALARIO));
			SET	@XVALOR = CAST(@SAL_BAS AS INT);
			
			
						
													
		IF (@TIP_DOC='C')
			BEGIN
				SET @TIP_DOC2 = 'cedula de ciudadania ';
			END
		ELSE
			BEGIN
				IF (@TIP_DOC='E')
					BEGIN
						SET   @TIP_DOC2 = 'cedula de extranjeria';
					END
				ELSE
					BEGIN
						IF (@TIP_DOC='T')
							BEGIN
								SET   @TIP_DOC2 = 'tarjeta de identidad';
							END
					END
			 END;
					 
		IF (@VTO_CTO IS NOT NULL)
			BEGIN
				SET @F_VENCI = ' hasta el '+''+CAST(@VTO_CTO AS VARCHAR);
			END
	
			BEGIN	
				SELECT @TIPO_CONTRATO=(CASE WHEN COD_GRU='2' THEN 'INTEGRAL' WHEN COD_GRU='1' THEN 'BÁSICO' WHEN COD_GRU IN ('3','5') THEN 'APRENDICES' END)        
				FROM EPL_GRUPOS
				WHERE COD_EPL=@CODIGO_EPL AND COD_GRU IN (1,2,3);

				IF (@TIPO_CONTRATO='INTEGRAL') 

					BEGIN
						SET @CADENA6 = ' bajo la modalidad de <B>SALARIO INTEGRAL.</B>';
						SET @CADENA7 = ' una asignacion salarial mensual';
						SET @CADENA8 = ' trabajo a termino <B>'+@NOM_CTO+'/B';
					END;
                ELSE
						IF (@TIPO_CONTRATO='APRENDICES')
							BEGIN
								SET @CADENA7 = ' asignacion mensual ';
								SET @CADENA6 = ' bajo la modalidad de <B>APOYO DE SOSTENIMIENTO.</B>';
								SET @CADENA8 = 'B'+@NOM_CTO+'/B';   
							END;   
								ELSE
									IF (@TIPO_CONTRATO='BÁSICO') 
										BEGIN
											SET @CADENA6 = ' bajo la modalidad de <B>SALARIO BASICO.</B>';
											SET @CADENA7 = ' una asignacion salarial mensual ';
											SET @CADENA8 = ' trabajo a termino <B>'+@NOM_CTO+'</B>';
										END;  
							END;

			BEGIN
				  SET  @DIA = DATENAME (DAY,CONVERT(VARCHAR,GETDATE()));
				  SET  @MES = DATENAME (MONTH,CONVERT(VARCHAR,GETDATE()));                        
				  SET  @AÑO =  DATENAME (YEAR,CONVERT(VARCHAR,GETDATE()));
			END;

			SET @BLOQUEB = (N'LA DIRECCIÓN GESTIÓN DE RECURSOS HUMANOS certifica que <B>'+''+@NOMBRE_EPL+''+'</B> con <B>'+''+@TIP_DOC2+''+' No. '+''+@CEDULA
			 +''+'</B>, se encuentra vinculado(a) para la compañía desde el '+''+@INI_CTO+''+@F_VENCI+''+', con un contrato de '+''+@CADENA8+''+', en el cargo de <B>'
			 +''+@NOM_CAR+''+'</B>.'+''+'<BR><BR><BR>'+''+'La presente certificación se expide a solicitud del interesado a los '+''+CAST(@DIA AS VARCHAR)+''+' dias del mes de '
			 +''+@MES+''+' de '+''+CAST(@AÑO AS VARCHAR)+''+' para ser presentado a '+''+@DESTINATARIO+''+'.'+''+'<BR><BR><BR><BR>'+''+'Para confirmar este certificado, 
			 comuniquese con la linea unica nacional 018000361645.'+''+'<BR><BR><BR><BR><BR>'+''+'Cordialmente,');

		 
			BEGIN
				SELECT @FIRMA=var_carac, @CARGO=descripcion
				FROM parametros_nue 
				WHERE nom_var = 't_epl_fir_cer_lab';	
			END;

			SET @BLOQUEC = ('<B>'+''+@FIRMA+''+'</B>'+''+'<BR>'+''+@CARGO); 
		
					

		END
			
	END;
GO
/**	
DECLARE @BLOQUEA VARCHAR(300);
DECLARE @BLOQUET VARCHAR(MAX);
DECLARE @BLOQUEB VARCHAR(MAX);
DECLARE @BLOQUEC VARCHAR(300);

EXEC dbo.CERT_LABORALES1 '1010056853' ,'2','CONFAMA',@BLOQUEA OUTPUT,@BLOQUET OUTPUT,@BLOQUEB OUTPUT,@BLOQUEC OUTPUT;

SELECT @BLOQUEA;

SELECT @BLOQUET;

SELECT @BLOQUEB;

SELECT @BLOQUEC;**/



