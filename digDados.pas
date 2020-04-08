Unit digDados;
(*Unit que trata os erros da entrada de dados de variáveis do tipo inteiro, real e string, e que também realiza uma função de confirmar; Responsável: Felipe Botelho Nunes da Silva; Data: 28/02/2016*)
Interface
	uses crt;
	procedure digInt(mensInt:string;maxInte,minInt:integer; var valInt:integer);
	procedure digReal(mensReal:string;maxReal,minReal:real;var valReal:real);
	procedure digStr(mensStr:string;maxStr,minStr:integer;var valStr:string);
	function funConfirmar(mens:string):char;

Implementation

	procedure digInt(mensInt:string;maxInte,minInt:integer; var valInt:integer);
	(*Procedimento que trata o erro na entrada de uma variável inteira, também limitando um máximo e mínimo informado*)
	Var
		erro:integer;
	begin
		repeat
			writeln(mensInt);
			{$i-}
			readln(valInt);
			{$i+}
			erro:=1;
			if ioresult<>0 then
			begin
				writeln('O valor digitado nao e inteiro.');
			end
			else if (valInt>maxInte) then
			begin
				writeln('O valor digitado e maior');
			end
			else if (valInt<minInt) then
			begin
				writeln('O valor e menor');
			end
			else
			begin
				erro:=0;
			end;
		until (erro=0);
	end;


	procedure digReal(mensReal:string;maxReal,minReal:real;var valReal:real);
	(*Procedimento que trata o erro na entrada de uma variável real, também limitando um máximo e mínimo informado*)
	Var
		erro:integer;
	begin
		repeat
			writeln(mensReal);
			{$i-}
			readln(valReal);
			{$i+}
			erro:=1;
			if ioresult<>0 then
			begin
				writeln('O valor digitado nao e real.');
			end
			else if (valReal>maxReal) then
			begin
				writeln('O valor digitado e maior');
			end
			else if (valReal<minReal) then
			begin
				writeln('O valor e menor');
			end
			else
			begin
				erro:=0;
			end;
		until (erro=0);
	end;


	procedure digStr(mensStr:string;maxStr,minStr:integer;var valStr:string);
	(*Procedimento que trata o erro na entrada de uma variável string; também limitando um máximo e mínimo informado*)
	Var
		tamanho:integer;
	begin
		repeat
			writeln(mensStr);
			readln(valStr);
			tamanho:= length(valStr);
			if (tamanho>maxStr) then
			begin
				writeln('Tamanho maior');
			end
			else if (tamanho<minStr) then
			begin
				writeln('Valor menor');
			end;
		until (tamanho<=maxStr)and(tamanho>=minStr);
	end;

	function funConfirmar(mens:string):char;
	(*Função que recebe 'S' ou 'N', para confirmar opções*)
	Var
		carac:char;
	begin
		repeat
			writeln(mens,'Confirme ou nao sua opcao');
			carac:= upcase(readkey);
			if (carac<>'S')and(carac<>'N') then
			begin
				writeln('Opcao invalida');
			end;
		until (carac='S')or(carac='N');
		funConfirmar:=carac;
	end;

End.


