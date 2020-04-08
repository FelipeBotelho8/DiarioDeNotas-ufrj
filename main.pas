Program Diario_de_Notas;
(*Programa de um diário de notas que armazenam dados de alunos, por turma, que são o DRE, nota de duas provas, média e número de faltas; Responsável: Felipe Botelho Nunes da Silva; Data:28/02/2016 *)

Uses crt,digDados,sysutils;

Type
	regAluno = record
		nome:string;
		dre:integer;
		notas:array[1..2] of real;
		media:real;
		faltas:integer;
	end;
	arqTurma = file of regAluno;
	ptrTurma = ^regTurma;
	regTurma = record
		desc:string;
		prox,ant:ptrTurma;
	end;

Function buscaPtrNomeTm(primeiro:ptrTurma;alvo:string):ptrTurma;
(*Procedimento para achar o ponteiro de uma turma pelo nome*)
Var
	achou:boolean;
	atual:ptrTurma;
begin
	new(atual);
	atual:=primeiro;
	achou:=false;
	if (atual<>nil) then {Se o primeiro ponteiro for diferente de nil, existe no mínimo um ponteiro na lista, então a busca pode ser feita}
	begin
		repeat
			if (atual^.desc=alvo) then
			begin
				achou:=true;
				writeln('A turma ',alvo,' foi achada.');
			end
			else
			begin
				atual:=atual^.prox;
			end;
		until ((atual=nil) or (achou));
		if not(achou) then
		begin
			clrscr;
			buscaPtrNomeTm:=nil; {Se não achar o ponteiro, igualar a busca como nil}
		end
		else
		begin
			buscaPtrNomeTm:=atual;
		end;
	end
	else
	begin
		buscaPtrNomeTm:=nil; {Busca não pode ser realizada, e assume o valor nil}
	end
end;


Procedure abrirTurma(var primeiro,ultimo:ptrTurma);
(*Procedimento para abrir uma turma, inserindo-a ordenadamente na lista de turmas ativas.*)
Var
	turma:arqTurma;
	novo,atual,busca:ptrTurma;
	opcao:char;
	nomeTm:string;
	parar:boolean;
begin
	clrscr;
	new(busca);
	writeln('Informe o nome da turma.');
	readln(nomeTm);
	assign(turma,nomeTm);
	{$i-}
	reset(turma);
	{$i+}
	if ioresult =2 then
	begin
		clrscr;
		opcao:=funConfirmar('Não existe arquivo dessa turma. Deseja criar um?<s/n>  ');
		if opcao='S' then
		begin
			rewrite(turma);
		end;
	end;
	busca:=buscaPtrNomeTm(primeiro,nomeTm); {Buscar se existe o ponteiro com o nome informado}
	if (busca=nil) then 
	begin
		new(novo);
		new(atual);
		novo^.desc:=nomeTm;
		if (((primeiro=nil)and(ioresult=0))or((opcao='S')and(primeiro=nil))) then {Caso em que não há nenhuma turma ativa}
		begin
			primeiro:=novo;
			ultimo:=novo;
			novo^.ant:=nil;
			novo^.prox:=nil;
		end
		else if (((primeiro<>nil)and(ioresult=0)) or ((opcao='S')and(primeiro<>nil))) then {Caso em que já existe alguma turam ativa}
		begin
			parar:=false;
			atual:=primeiro;
			repeat {Iteração para descobrir onde o ponteiro será inserido ordenadamente}
				if (novo^.desc<atual^.desc) then
				begin
					parar:=true;
				end
				else
				begin
					atual:=atual^.prox;
				end;
			until ((parar)or(atual=nil));
			if (parar) then
			begin
				if (atual=primeiro) then {Se o atual for o primeiro, o novo ponteiro passa a ser o primeiro}
				begin
					novo^.prox:=atual;
					novo^.ant:=nil;
					atual^.ant:=novo;
					primeiro:=novo;
				end
				else
				begin
					novo^.prox:=atual;
					novo^.ant:=atual^.ant;
					atual^.ant^.prox:=novo;
					atual^.ant:=novo;
				end;
			end
			else {O novo ponteiro será inserido como último}
			begin
				novo^.prox:=nil;
				novo^.ant:=ultimo;
				ultimo^.prox:=novo;
				ultimo:=novo;
			end;
		end;
	end;
	clrscr;
end;

Procedure retirarTurma(var primeiro,ultimo:ptrTurma;alvo:ptrTurma);
(*Procedimento que retira uma turma da lista de turmas ativas*)
begin
	if (alvo=primeiro) then
	begin
		if (alvo=ultimo) then {Se o ponteiro que deseja tirar for primeiro e o último, os ponteiros primeiro e último passarão a ser nil}
		begin
			primeiro:=nil;
			ultimo:=nil;
		end
		else {Se o ponteiro a ser tirado for só o primeiro, o posterior a ele passa a ser o primeiro}
		begin
			primeiro:=alvo^.prox;
			primeiro^.ant:=nil;
		end;
	end
	else if (alvo=ultimo) then {Se o ponteiro a ser retirado for só o último, o anterior a ele passa a ser o último}
	begin
		ultimo:=alvo^.ant;
		ultimo^.prox:=nil;
	end
	else
	begin
		alvo^.ant^.prox:=alvo^.prox;
		alvo^.prox^.ant:=alvo^.ant;
	end;
end;

Procedure fecharTurma(var primeiro,ultimo:ptrTurma);
(*Procedimento que fecha uma turma, tirando-a da lista de turmas ativas, perguntando primeiramente ao usuário o nome da turma*)
Var
	busca:ptrTurma;
	nomeTm:string;
	resposta:char;
Begin
	if primeiro=nil then 
	begin
		writeln('Não existe turma aberta!');
	end
	else
	begin
		new(busca);
		digStr('Informe o nome da turma que quer fechar:',30,1,nomeTm);
		busca:=buscaPtrNomeTm(primeiro,nomeTm); {Buscar o ponteiro referente ao nome informado}
		if busca=nil then
		begin
			writeln('Não foi achada turma com esse nome na lista de turmas ativas.');
		end
		else
		begin
			resposta:=funConfirmar('Deseja mesmo fechar essa turma e retirá-la da lista de turmas ativas?<s/n> ');
			if resposta='S' then
			begin
				retirarTurma(primeiro,ultimo,busca); {Retirar a turma da lista de turmas abertas}
				clrscr;
				writeln('Turma fechada!');
				writeln();
				writeln();
			end;
		end;
	end;
End;

Function procuraDREigual(numDre:integer;primeiro:ptrTurma):boolean;
(*Função que assume valor verdadeiro se encontrar entre os arquivos das turmas ativas algum aluno com dre igual ao informado na inclusão de um aluno*)
Var
	turma:arqTurma;
	atual:ptrTurma;
	aux:regAluno;
	achou:boolean;
Begin
	achou:=false;
	atual:=primeiro;
	repeat {Iteração que percorre a lista de turmas}
		assign(turma,atual^.desc);
		reset(turma);
		if (filesize(turma)<>0) then
		begin
			repeat {Iteração que percorre o arquivo e busca se a algum aluno com dre semelhante ao informado}
				read(turma,aux);
				if (aux.dre=numDre) then
				begin
					achou:=true;
				end;
			until ((achou)or(eof(turma)));
		end;
		atual:=atual^.prox;
	until ((achou)or(atual=nil));
	procuraDREigual:=achou;
End;

Procedure incluirAluno(primeiro:ptrTurma);
(*Procedimento que inclui um aluno e todos os seus dados, ordenadamente pelo seu nome, no arquivo referente a turma do aluno*)
Var
	turma:arqTurma;
	busca:ptrTurma;
	aux,novo:regAluno;
	nomeTm:string;
	cont,posicao:integer;
	incluiu,igual:boolean;
Begin
	if primeiro=nil then
	begin
		clrscr;
		writeln('Não existe turma aberta!');
		writeln();
		writeln();
	end
	else
	begin
		clrscr;
		digStr('Informe o nome da turma do aluno que será incluido.',30,1,nomeTm);
		new(busca);
		busca:=buscaPtrNomeTm(primeiro,nomeTm); {Busca o ponteiro referente ao nome da turma}
		if busca=nil then
		begin
			clrscr;
			writeln('Não existe turma com esse nome na lista de turmas abertas.');
			writeln();
			writeln();
		end
		else
		begin
			clrscr;
			incluiu:=false;
			assign(turma,nomeTm);
			reset(turma);
			digStr('Informe o nome do aluno',30,1,novo.nome);
			repeat
				digInt('Informe o DRE do aluno',1000,1,novo.dre);
				igual:=procuraDREigual(novo.dre,primeiro);
				if (igual) then
				begin
					writeln('Já existe aluno com esse mesmo DRE nessa turma ou em outra turma aberta. Informe outro valor.');
					writeln();
				end;
			until (not(igual));
			digReal('Informe a nota 1 do aluno.',10,0,novo.notas[1]);
			digReal('Informe a nota 2 do aluno.',10,0,novo.notas[2]);
			digInt('Informe o número de faltas do aluno.',30,0,novo.faltas);
			novo.media:=(novo.notas[1]+novo.notas[2])/2;
			if filesize(turma)=0 then {Caso em que não há nada no arquivo}
			begin
				seek(turma,filesize(turma));
				write(turma,novo);
				incluiu:=true;
			end
			else
			begin
				seek(turma,0);
				repeat {Iteração para incluir os dados ordenados pelo nome}
					posicao:=filepos(turma);
					read(turma,aux);
					if (novo.nome<aux.nome) then {Foi achada a posição em que será incluido}
					begin
						for cont:=filesize(turma)-1 downto posicao do {Iteração para "empurrar para baixo" todos os dados após a posição achada}
						begin
							seek(turma,cont);
							read(turma,aux);
							write(turma,aux);
						end;
						seek(turma,posicao);
						write(turma,novo); {Inclusão}
						incluiu:=true
					end;
				until (incluiu) or (eof(turma));
			end;
			if (not(incluiu)) then {Se não foi incluido ainda, será incluido no final do arquivo}
			begin
				seek(turma,filesize(turma));
				write(turma,novo);
			end; 
			clrscr;
			writeln('Dados incluidos!');
			writeln();
			writeln();
		end;
	end;
end;

Procedure removerAluno(primeiro:ptrTurma);
(*Procedimento para remover todos os dados de um aluno de uma turma*)
Var
	turma:arqTurma;
	busca:ptrTurma;
	aux:regAluno;
	nomeTm,alvo:string;
	posicao:integer;
	achou:boolean;
Begin
	if primeiro=nil then
	begin
		clrscr;
		writeln('Não existe turma aberta!');
		writeln();
		writeln();
	end
	else
	begin
		clrscr;
		digStr('Informe o nome da turma da qual o aluno pertence.',30,1,nomeTm);
		new(busca);
		busca:=buscaPtrNomeTm(primeiro,nomeTm); {Buscar o ponteiro referente ao nome da turma informado}
		if busca=nil then
		begin
			clrscr;
			writeln('Não existe turma com esse nome na lista de turmas abertas.');
			writeln();
			writeln();
		end
		else
		begin
			assign(turma,busca^.desc);
			reset(turma);
			if filesize(turma)=0 then
			begin
				clrscr;
				writeln('Não há dados cadastrados nessa turma.');
				writeln();
				writeln();
			end
			else
			begin
				achou:=false;
				clrscr;
				digStr('Informe o nome do aluno que deseja remover. Serão removidos todos os dados.',50,1,alvo);
				seek(turma,0);
				repeat {Iteração para achar a posição no arquivo do aluno que deseja remover}
					posicao:=filepos(turma);
					read(turma,aux);
					if (aux.nome=alvo) then
					begin
						achou:=true;
					end;
				until ((achou) or (eof(turma)));
				if achou then {Caso em que foi achado o aluno no arquivo}
				begin
					aux.nome:=' '; {Atribuir espaço vazio (' ') nome, que é um nome não válido}
					aux.dre:=0;    {Atribuir 0 ao DRE, que é um valor não válido}
					seek(turma,posicao);
					write(turma,aux);
					clrscr;
					writeln('Dados removidos!');
					writeln();
					writeln();
				end
				else
				begin
					clrscr;
					writeln('Não existe aluno com esse nome na turma informada.');
					writeln();
					writeln();
				end;
			end;
		end;
	end;
End;

Procedure apagarTurma(var primeiro,ultimo:ptrTurma);
(*Procedimento para apagar o arquivo de uma turma, e posteriormente removendo-a da lista de turmas ativas*)
Var
	turma:arqTurma;
	busca:ptrTurma;
	opcao:char;
	nomeTm:string;
Begin
	if primeiro=nil then
	begin
		clrscr;
		writeln('Não existe turma aberta!');
		writeln();
		writeln();
	end
	else
	begin
		clrscr;
		digStr('Informe o nome da turma que deseja apagar os dados.',30,1,nomeTm);
		new(busca);
		busca:=buscaPtrNomeTm(primeiro,nomeTm); {Buscar o ponteiro referente ao nome da turma informado}
		if (busca=nil) then
		begin
			clrscr;
			writeln('Não existe turma com esse nome na lista de turmas abertas.');
			writeln();
			writeln();
		end
		else
		begin
			clrscr;
			opcao:=funConfirmar('Deseja mesmo apagar o arquivo que contém todos os dados dessa turma?<s/n>');
			if (opcao='S') then
			begin
				assign(turma,busca^.desc);
				erase(turma); {Apagar o arquivo}
				retirarTurma(primeiro,ultimo,busca); {Retirar a turma da lista de turmas ativas}
				clrscr;
				writeln('Arquivo da turma apagado!');
				writeln();
				writeln();
			end;
		end;
	end;
End;

Procedure buscarPosAluno(nomeTm:string;var achou:boolean;var posicao:integer);
(*Procedimento para achar a posição de um aluno no arquivo da turma, através da solicitação do nome do aluno ou DRE, e indicar se achou ou não*)
Var
	turma:arqTurma;
	alvoStr:string;
	alvoInt,cont:integer;
	soNumero:boolean;
	aux:regAluno;
Begin
	cont:=1;
	soNumero:=true;
	clrscr;
	digStr('Informe o nome ou dre do aluno que deseja alterar o dado.',30,1,alvoStr);
	
	// Verificar se o dado informado é o nome ou dre
	repeat {Iteração para verificar se o dado informado é formado apenas por número ou não}
		if not(alvoStr[cont] in ['0'..'9']) then
		begin
			soNumero:=false; {O dado não é formado apenas por números}
		end;
		cont:=cont+1;
	until ((cont=length(alvoStr))or(not(soNumero)));
	if (soNumero) then {Se o dado informado for formado apenas por números, o usuário informou o dre, que é inteiro}
	begin
		alvoInt:=StrToInt(alvoStr); {O dado(dre) que estava como string é convertido para integer}
	end;

	//Achar a posição correspondente no arquivo
	assign(turma,nomeTm);
	reset(turma);
	if (filesize(turma)=0) then
	begin
		clrscr;
		writeln('Não há dados cadastrados nessa turma.');
		achou:=false;
		writeln();
		writeln(); 
	end
	else
	begin
		achou:=false;
		seek(turma,0);
		repeat {Verificar se o nome ou dre informado está no arquivo da turma}
			posicao:=filepos(turma);
			read(turma,aux);
			if ((alvoStr=aux.nome)or(alvoInt=aux.dre)) then
			begin
				achou:=true; {Foi achado o aluno e a posição dele no arquivO}
			end
		until ((achou)or(eof(turma))); {Repetir até achar ou até teminar o arquivo}
		if not(achou) then
		begin
			clrscr;
			writeln('Não foi achado esse aluno nessa turma.');
			writeln();
			writeln();
		end;
	end; 
End;

Procedure editarNota(primeiro:ptrTurma);
(*Procedimento para editar as notas de um aluno de uma turma*)
Var
	turma:arqTurma;
	nomeTm:string;
	busca:ptrTurma;
	posicao:integer;
	achou:boolean;
	aux:regAluno;
	novaNota1,novaNota2,novaMedia:real;

Begin
	if (primeiro=nil) then
	begin
		clrscr;
		writeln('Não existe turma aberta!');
		writeln();
		writeln();
	end
	else
	begin
		new(busca);
		clrscr;
		digStr('Informe o nome da turma do aluno que deseja alterar a nota:',30,1,nomeTm);
		busca:=buscaPtrNomeTm(primeiro,nomeTm); {Buscar o ponteiro referente ao nome da turma informada}
		if (busca=nil) then
		begin
			clrscr;
			writeln('Não existe turma com esse nome na lista de turmas abertas.');
			writeln();
			writeln();
		end
		else
		begin
			buscarPosAluno(nomeTm,achou,posicao); {Verificar se o aluno existe no arquivo, e se sim buscar a posição no arquivo}
			if achou then 
			begin
				clrscr;
				digReal('Informe a nova nota 1.',10,0,novaNota1);
				digReal ('Informe a nova nota 2.',10,0,novaNota2);
				novaMedia:=(novaNota1+novaNota2)/2;
				assign(turma,nomeTm);
				reset(turma);
				seek(turma,posicao);
				read(turma,aux);
				aux.notas[1]:=novaNota1;
				aux.notas[2]:=novaNota2;
				aux.media:=novaMedia;
				seek(turma,posicao);
				write(turma,aux);
				clrscr;
				writeln('Notas alteradas!');
				writeln();
				writeln();
			end;				
		end;
	end;
End;


Procedure editarFaltas(primeiro:ptrTurma);
(*Procedimento para editar as faltas de um aluno de uma turma*)
Var
	turma:arqTurma;
	nomeTm:string;
	busca:ptrTurma;
	posicao:integer;
	achou:boolean;
	aux:regAluno;
	novaFalta:integer;

Begin
	if (primeiro=nil) then
	begin
		clrscr;
		writeln('Não existe turma aberta!');
		writeln();
		writeln();
	end
	else
	begin
		new(busca);
		clrscr;
		digStr('Informe o nome da turma do aluno que deseja alterar o número de faltas:',30,1,nomeTm);
		busca:=buscaPtrNomeTm(primeiro,nomeTm); {Buscar o ponteiro referente ao nome da turma informado}
		if (busca=nil) then
		begin
			clrscr;
			writeln('Não existe turma com esse nome na lista de turmas abertas.');
			writeln();
			writeln();
		end
		else
		begin
			buscarPosAluno(nomeTm,achou,posicao); {Verificar se o aluno existe no arquivo, e se sim achar a posição}
			if achou then
			begin
				clrscr;
				digInt('Informe o novo número de faltas.',30,0,novaFalta);
				assign(turma,nomeTm);
				reset(turma);
				seek(turma,posicao);
				read(turma,aux);
				aux.faltas:=novaFalta;
				seek(turma,posicao);
				write(turma,aux);
				clrscr;
				writeln('Faltas alteradas!');
				writeln();
				writeln();
			end;				
		end;
	end;
End;

Procedure consultarDados(primeiro:ptrTurma;opcao:integer);
(*Procedimento que, dependendo da opção que é informada no menu principal, consulta dados de um aluno específico de uma turma, dados dos alunos aprovados em uma turma, dados dos alunos reprovados por nota de uma turma, dados dos alunos reprovados por falta de uma turma, ou lista todos os alunos de uma turma e seus dados.*)
Var
	turma:arqTurma;
	nomeTm,nomeAl:string;
	busca:ptrTurma;
	aux:regAluno;
	achou,vazio:boolean;
	cont:integer;

Begin
	if (primeiro=nil) then
	begin
		clrscr;
		writeln('Não existe turma aberta!');
		writeln();
		writeln();
	end
	else
	begin
		new(busca);
		clrscr;
		digStr('Informe o nome da turma.',30,1,nomeTm);
		busca:=buscaPtrNomeTm(primeiro,nomeTm); {Buscar o ponteiro referente ao nome da turma informado}
		if (busca=nil) then
		begin
			clrscr;
			writeln('Não existe turma com esse nome na lista de turmas abertas.');
			writeln();
			writeln();
		end
		else
		begin
			assign(turma,nomeTm);
			reset(turma);
			seek(turma,0);
			vazio:=true; {Assume que o arquivo turma está vazio}
			if (filesize(turma))<>0 then {Se o arquivo tiver algo, verificar se é válido}
			begin
				repeat {Iteração para verificar se há algum registro válido no arquivo}
					read(turma,aux);
					if (aux.nome<>' ')then {Se a condição for feita, existe registro válido}
					begin
						vazio:=false; {Assume que o arquivo não está vazio, e há registro válido}
					end;
				until ((not(vazio))or(eof(turma)));
			end;
			if (vazio) then
			begin
				clrscr;
				writeln('Não há dados cadastrados nessa turma.');
				writeln();writeln();
			end
			else
			begin
				achou:=false;
				case opcao of {Opção informada no menu principal}
					8: begin {Consultar dados de um aluno específico}
							digStr('Informe o nome do aluno buscado.',30,1,nomeAl);
							seek(turma,0);
							repeat
								read(turma,aux);
								if (aux.nome=nomeAl) then {Se achar, informar os dados}
								begin
									achou:=true;
									clrscr;
									gotoxy(1,1);write('NOME');gotoxy(13,1);write('DRE');gotoxy(26,1);write('NOTA 1');gotoxy(39,1);write('NOTA 2');gotoxy(52,1);write('MEDIA');gotoxy(65,1);writeln('FALTAS');
									write(aux.nome);gotoxy(13,2);write(aux.dre);gotoxy(26,2);write(aux.notas[1]:5:2);gotoxy(39,2);write(aux.notas[2]:5:2);gotoxy(52,2);write(aux.media:5:2);gotoxy(65,2);writeln(aux.faltas);
									writeln();writeln();
								end;
							until ((achou)or(eof(turma))); {Repetir até achar ou até terminar o arquivo}
							if not(achou) then
							begin
								clrscr;
								writeln('Não foi achado aluno com esse nome nessa turma.');
								writeln();writeln();
							end;
						end;

					9:	begin {Consultar dados dos alunos aprovados de uma turma}
							seek(turma,0);
							cont:=4;
							clrscr;
							writeln('                         ALUNOS APROVADOS');
							writeln();
							write('NOME');gotoxy(13,3);write('DRE');gotoxy(26,3);writeln('MEDIA');
							repeat
								read(turma,aux);
								if ((aux.media>=7)and(aux.faltas<=4)) then {Listar alunos aprovados, que devem ter media maior ou igual a 7 e nº de faltas menor ou igual 4}
								begin
									achou:=true;
									gotoxy(1,cont);write(aux.nome);gotoxy(13,cont);write(aux.dre);gotoxy(26,cont);writeln(aux.media:5:2);
									cont:=cont+1;
								end;
							until (eof(turma));
							writeln();writeln();
							if (not(achou)) then
							begin
								clrscr;
								writeln('Não há alunos aprovados nessa turma.');
								writeln();writeln();
							end;
						end;

					10: begin {Consultar dados dos alunos reprovados por nota de uma turma}
							seek(turma,0);
							cont:=4;
							clrscr;
							writeln('                         ALUNOS REPROVADOS POR NOTA');
							writeln();
							write('NOME');gotoxy(13,3);write('DRE');gotoxy(26,3);writeln('MEDIA');
							repeat
								read(turma,aux);
								if (aux.media<7) then {Listar alunos reprovados por nota, com media menor que 7 }
								begin
									achou:=true;
									gotoxy(1,cont);write(aux.nome);gotoxy(13,cont);write(aux.dre);gotoxy(26,cont);writeln(aux.media:5:2);
									cont:=cont+1;
								end;
							until (eof(turma));
							writeln();writeln();
							if (not(achou)) then
							begin
								clrscr;
								writeln('Não há alunos reprovados por nota nessa turma.');
								writeln();writeln();
							end;
						end;

					11: begin {Consultar dados dos alunos reprovados por falta de uma turma}
							seek(turma,0);
							cont:=4;
							clrscr;
							writeln('                       ALUNOS REPROVADOS POR FALTA');
							writeln();
							write('NOME');gotoxy(13,3);write('DRE');gotoxy(26,3);writeln('FALTAS');
							repeat
								read(turma,aux);
								if (aux.faltas>4) then {Listar alunos com número de faltas maior que 4}
								begin
									achou:=true;
									gotoxy(1,cont);write(aux.nome);gotoxy(13,cont);write(aux.dre);gotoxy(26,cont);writeln(aux.faltas);
									cont:=cont+1;
								end;
							until (eof(turma));
							writeln();writeln();
							if (not(achou)) then
							begin
								clrscr;
								writeln('Não há alunos reprovados por falta.');
								writeln();writeln();
							end;
						end;
					12: begin {Listar todos os alunos}
							seek(turma,0);
							cont:=4;
							clrscr;
							writeln('                      TURMA ',nomeTm);
							writeln();
							write('NOME');gotoxy(13,3);write('DRE');gotoxy(26,3);write('NOTA 1');gotoxy(39,3);write('NOTA 2');gotoxy(52,3);write('MÉDIA');gotoxy(65,3);writeln('FALTAS');
							repeat
								read(turma,aux);
								if (aux.nome<>' ') then
								begin
									gotoxy(1,cont);write(aux.nome);gotoxy(13,cont);write(aux.dre);gotoxy(26,cont);write(aux.notas[1]:5:2);gotoxy(39,cont);write(aux.notas[2]:5:2);gotoxy(52,cont);write(aux.media:5:2);gotoxy(65,cont);writeln(aux.faltas);
									cont:=cont+1;
								end;
							until (eof(turma));
							writeln();writeln();
						end;
				end;
			end;
		end;
	end;
End;


//****************************************************PROGRAMA PRINCIPAL********************************************

Var
	opcao:integer;
	primeiro,ultimo:ptrTurma;
Begin
	new(primeiro);
	new(ultimo);
	primeiro:=nil;
	clrscr;
	writeln('                                BEM VINDO AO DIÁRIO DE ALUNOS.');
	writeln();
	repeat
		writeln('MENU PRINCIPAL:');
		writeln();
		writeln('Digite 1 para abrir uma turma a partir do nome.');
		writeln('Digite 2 para fechar uma turma e retirá-la da lista de turmas ativas. ');
		writeln('Digite 3 para apagar o arquivo que contem os dados de uma turma.');
		writeln('Digite 4 para incluir dados de um aluno de uma turma.');
		writeln('Digite 5 para remover um aluno de uma turma e todos seus dados.');
		writeln('Digite 6 para editar as notas de um aluno de uma turma.');
		writeln('Digite 7 para alterar o número de faltas de um aluno de uma turma.');
		writeln('Digite 8 para consultar os dados de um aluno específico de uma turma.');
		writeln('Digite 9 para consultar dados de todos os alunos aprovados de uma turma.');
		writeln('Digite 10 para consultar dados de todos os alunos reprovados por nota de uma turma.');
		writeln('Digite 11 para consultar dados de todos os alunos reprovados por falta de uma turma.');
		writeln('Digite 12 para listar todos os dados de todos os alunos de uma turma.');
		writeln('Digite 13 para sair do programa.');
		writeln();
		digInt('Informe a opção escolhida:',13,1,opcao);
		case opcao of
			1:	abrirTurma(primeiro,ultimo);
			2:	fecharTurma(primeiro,ultimo);
			3:	apagarTurma(primeiro,ultimo);
			4:	incluirAluno(primeiro);
			5:	removerAluno(primeiro);
			6:	editarNota(primeiro);
			7:	editarFaltas(primeiro);
			8:	consultarDados(primeiro,opcao); {Consultar dados de um aluno específico}
			9:	consultarDados(primeiro,opcao); {Consultar dados de todos os alunos aprovados}
			10:consultarDados(primeiro,opcao); {Consultar dados de todos os alunos reprovados por nota}
			11:consultarDados(primeiro,opcao); {Consultar dados de todos os alunos reprovados por falta}
			12:consultarDados(primeiro,opcao); {Listar dados de todos os alunos}	
		end;
	until(opcao=13);
	dispose(primeiro);
	dispose(ultimo);

End.
