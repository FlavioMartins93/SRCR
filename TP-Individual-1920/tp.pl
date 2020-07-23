:- consult(data).

:- use_module(library(lists)).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: definicoes iniciais

:- op( 900,xfy,'::' ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% ----- Nodos: 
% ---------- paragem ( gid, Latitude, Longitude, TipoDeAbrigo, AbrigoComPublicidade, Operadora, [Carreira] )
% ----- Arestas: 
% ---------- ligacao ( Carreira, OrigemGid, DestinoGid, Distancia ) ----- Existe um caminho direto entre 2 pontos
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% --------------------------
% |     Dados de teste     |
% --------------------------

%    paragem(1,  0, 0, fechadodosLados, yes, vimeca, [1,2,3,5,6,7] ).            % 6
%    paragem(2,  0, 1, semAbrigo, no, vimeca, [1]).                              % 1
%    paragem(3,  0, 2, fechadodosLados, yes, vimeca, [1]).                       % 1
%    paragem(4,  1, 0, fechadodosLados, no, vimeca, [2]).                        % 1
%    paragem(5,  1, 1, semAbrigo, yes, carris, [3,4,6]).                         % 3
%    paragem(6,  1, 2, semAbrigo, no, vimeca, [1,6]).                            % 2
%    paragem(7,  2, 0, fechadodosLados, yes, vimeca, [5]).                       % 1
%    paragem(8,  2, 1, fechadodosLados, yes, vimeca, [2,3,7]).                   % 3
%    paragem(9,  2, 2, fechadodosLados, yes, vimeca, [1,4]).                     % 2
%    paragem(10, 3, 0, fechadodosLados, yes, vimeca, [5]).                       % 1
%    paragem(11, 3, 1, semAbrigo, yes, vimeca, [2]).                             % 1
%    paragem(12, 3, 2, semAbrigo, yes, vimeca, [1]).                             % 1

%    ligacao(1,1,2,3).
%    ligacao(1,2,3,3).
%    ligacao(1,3,6,3).
%    ligacao(1,6,9,3).
%    ligacao(1,9,12,3).
%    ligacao(2,1,4,5).
%    ligacao(2,4,8,5).
%    ligacao(2,8,11,5).
%    ligacao(3,1,5,5).
%    ligacao(3,5,8,7).
%    ligacao(4,9,5,10).
%    ligacao(5,1,5,5).
%    ligacao(5,5,10,5).
%    ligacao(5,10,7,5).
%    ligacao(6,1,5,5).
%    ligacao(6,5,6,5).
%    ligacao(7,1,8,29).


% ---------------------------------------------------------------------------
% |     Caminhos entre 2 pontos (apresentando as ligacoes como resultado)   |
% ---------------------------------------------------------------------------

% ---------------
% |     DFS     |
% ---------------

trajeto( Origem, Destino, Caminho ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,Distancia)]\n'),
    percurso( Origem , Destino, [Origem], [], Caminho ).

% Se houver ligacao entre o destino e o gid actual temos um caminho
percurso( GidAtual, GidDestino, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, GidDestino, Dist ),
    reverse([( Car,GidAtual,ProxGid, Dist )|Ligacoes], Caminho).
% --- reverse([GidDestino|Visitados],Caminho).   -- Apresenta resultado os gids onde passou

percurso( GidAtual, GidDestino, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, ProxGid, Dist ),
    ProxGid \== GidDestino,
    \+memberchk( ProxGid, Visitados ),
    percurso( ProxGid, GidDestino, [ProxGid|Visitados], [(Car,GidAtual,ProxGid,Dist)|Ligacoes], Caminho).


% --------------------------------------------
% |     Pesquisa em profundidade limitada    |
% --------------------------------------------

trajetoLimProf( Origem, Destino, Limite, Caminho ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,Distancia)]\n'),
    percursoLimProf( Origem , Destino, Limite, [Origem], [], Caminho ).

% Se houver ligacao entre o destino e o gid actual temos um caminho
percursoLimProf( GidAtual, GidDestino, _, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, GidDestino, Dist ),
    reverse([( Car,GidAtual,ProxGid, Dist )|Ligacoes], Caminho).
% --- reverse([GidDestino|Visitados],Caminho).   -- Apresenta resultado os gids onde passou

percursoLimProf( GidAtual, GidDestino, Limite, Visitados, Ligacoes, Caminho) :-
    Limite > 0,
    ligacao( Car, GidAtual, ProxGid, Dist ),
    ProxGid \== GidDestino,
    \+memberchk( ProxGid, Visitados ),
    Lim = Limite-1,
    percursoLimProf( ProxGid, GidDestino, Lim, [ProxGid|Visitados], [(Car,GidAtual,ProxGid,Dist)|Ligacoes], Caminho).


% ---------------------------------------------
% |     Pesquisa em profundidade iterativa    |
% ---------------------------------------------

trajetoIter( Origem, Destino, Caminho ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,Distancia)]\n'),
    percursoIt( Origem , Destino, 0, Caminho ).

percursoIt( Origem, Destino, Lim, Caminho) :-
    percursoLimProf( Origem , Destino, Lim, [Origem], [], Caminho ),
    !;
    LimN = Lim+1,
    percursoIt( Origem, Destino, LimN, Caminho).


% ----------------------------------------------------------------------
% |     Caminhos entre 2 pontos, utilizando apenas algumas operadoras  |
% ----------------------------------------------------------------------

trajetoSelOps( Origem, Destino, Operadoras, Percurso ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,OperadoraDestino)]\n'),
    paragem( Origem,_,_,_,_,Op,_),
    memberchk( Op, Operadoras ),
    paragem( Destino,_,_,_,_,Op2,_ ),
    memberchk( Op2, Operadoras ),
    percursoSelOps( Origem , Destino, Operadoras, [Origem], [], Caminho ),
    Percurso = Caminho.

% Se houver ligacao entre o destino e o gid actual temos um caminho
percursoSelOps( GidAtual, GidDestino, Operadoras, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, GidDestino, Distancia ),
    paragem( GidDestino,_,_,_,_,Op,_ ),
    reverse([(Car,GidAtual,ProxGid,Op)|Ligacoes],Caminho).

percursoSelOps( GidAtual, GidDestino, Operadoras, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, ProxGid, _),
    paragem( ProxGid,_,_,_,_,Op,_ ),
    memberchk(Op,Operadoras),
    ProxGid \== GidDestino,
    \+memberchk(ProxGid,Visitados),
    percursoSelOps( ProxGid, GidDestino, Operadoras, [ProxGid|Visitados], [(Car,GidAtual,ProxGid,Op)|Ligacoes], Caminho).


% ------------------------------------------------------------------
% |     Caminhos entre 2 pontos, excluindo algumas operadoras      |
% ------------------------------------------------------------------ 

trajetoExOps( Origem, Destino, Operadoras, Percurso ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,OperadoraDestino)]\n'),
    paragem( Origem,_,_,_,_,Op,_ ),
    \+memberchk( Op, Operadoras ),
    paragem( Destino,_,_,_,_,Op2,_ ),
    \+memberchk( Op2, Operadoras ),
    percursoExOps( Origem , Destino, Operadoras, [Origem], [], Caminho ),
    Percurso = Caminho.

% Se houver ligacao entre o destino e o gid actual temos um caminho
percursoExOps( GidAtual, GidDestino, Operadoras, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, GidDestino, Distancia ),
    paragem( GidDestino,_,_,_,_,Op,_ ),
    reverse([(Car,GidAtual,GidDestino,Op)|Ligacoes],Caminho).

percursoExOps( GidAtual, GidDestino, Operadoras, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, ProxGid, _),
    paragem( ProxGid,_,_,_,_,Op,_ ),
    \+memberchk(Op,Operadoras),
    ProxGid \== GidDestino,
    \+memberchk(ProxGid,Visitados),
    percursoExOps( ProxGid, GidDestino, Operadoras, [ProxGid|Visitados], [(Car,GidAtual,ProxGid,Op)|Ligacoes], Caminho).


% --------------------------------------------------------------
% |     Paragens com mais carreiras num determinado percurso   |
% --------------------------------------------------------------

%%      ([pto1,pto2,...,pton], RES).
paragemMaisCar([P|T],R) :- 
    paragem( P,_,_,_,_,_,LP),
    length(LP,Len),
    paragemMaisCarAux(T,Len,P,R).

paragemMaisCarAux([],_,LS,R) :-
    R = LS.

paragemMaisCarAux([P|T],S,X,R) :-
    paragem( P,_,_,_,_,_,LP),
    length(LP,LPS),
    LPS > S,
    paragemMaisCarAux(T,LPS,[P],R).
paragemMaisCarAux([P|T],S,X,R) :-
    paragem( P,_,_,_,_,_,LP),
    length(LP,LPS),
    LPS == S,
    paragemMaisCarAux(T,S,[P|X],R).
paragemMaisCarAux([P|T],S,X,R) :-
    paragem( P,_,_,_,_,_,LP),
    length(LP,LPS),
    LPS < S,
    paragemMaisCarAux(T,S,X,R).


% ----------------------------------------------------------
% |     Menor percurso(criterio menor numero de paragens)  |
% ----------------------------------------------------------

trajetoMenosPar(Inicio,Destino,R) :-
    findall(X, trajeto(Inicio,Destino,X), L),
    menosPar(L,R).

menosPar([L|Ls], Min) :-
    menosPar(Ls, L, Min).

menosPar([], Min, Min).
menosPar([L|Ls], Min0, Min) :-
    min(L, Min0, Min1),
    menosPar(Ls, Min1, Min).
min(L,Min0,R) :-
    length(L,LL),
    length(Min0,LM),
    LL>LM,
    R=Min0.
min(L,Min0,R) :-
    length(L,LL),
    length(Min0,LM),
    LL=<LM,                         %>
    R=L.

trajetoMenosParIter(Inicio,Destino,R) :-
    trajetoIter( Inicio, Destino, R ).


% -----------------------------------------------------
% |     percurso mais rapido(criterio menor distancia) |
% ------------------------------------------------------

trajetoMaisRap(Inicio,Destino,R,Dist) :-
    findall(X, trajeto(Inicio,Destino,X), L),
    maisRap(L,R),
    distCam(R,Dist).

maisRap([L|Ls], Min) :-
    maisRap(Ls, L, Min).

maisRap([], Min, Min).
maisRap([L|Ls], Min0, Min) :-
    menorDist(L, Min0, Min1),
    maisRap(Ls, Min1, Min).
menorDist(L,Min0,R) :-
    distCam(L,LL),
    distCam(Min0,LM),
    LL>LM,
    R=Min0.
menorDist(L,Min0,R) :-
    distCam(L,LL),
    distCam(Min0,LM),
    LL=<LM,                 %>
    R=L.

distCam([], R) :- 
    R is 0.
distCam([(Car,Or,Dest,Dist)|L], R) :-
    distCam(L,R2),
    R is Dist+R2.


% --------------------------------------------------------------
% |     percurso a passar apenas em paragens com publicidade   |
% --------------------------------------------------------------

trajetoPub( Origem, Destino, Percurso ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,OperadoraDestino)]\n'),
    paragem( Origem,_,_,_,yes,_,_ ),
    paragem( Destino,_,_,_,yes,_,_ ),
    percursoPub( Origem , Destino, Operadoras, [Origem], [], Caminho ),
    Percurso = Caminho.

% Se houver ligacao entre o destino e o gid actual temos um caminho
percursoPub( GidAtual, GidDestino, Operadoras, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, GidDestino, Distancia ),
    paragem( GidDestino,_,_,_,yes,_,_ ),
    reverse([(Car,GidAtual,GidDestino)|Ligacoes],Caminho).

percursoPub( GidAtual, GidDestino, Operadoras, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, ProxGid, Distancia ),
    paragem( ProxGid,_,_,_,yes,_,_ ),
    ProxGid \== GidDestino,
    \+memberchk(ProxGid,Visitados),
    percursoPub( ProxGid, GidDestino, Operadoras, [ProxGid|Visitados], [(Car,GidAtual,ProxGid)|Ligacoes], Caminho).


% ----------------------------------------------------------
% |     percurso a passar apenas em paragens abrigadas     |
% ----------------------------------------------------------

trajetoAbrigado( Origem, Destino, Percurso ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,OperadoraDestino)]\n'),
    paragem( Origem,_,_,Abrigo,_,_,_ ),
    Abrigo \== semAbrigo,
    paragem( Destino,_,_,Abrigo2,_,_,_ ),
    Abrigo2 \== semAbrigo,
    percursoAbrigado( Origem , Destino, Operadoras, [Origem], [], Caminho ),
    Percurso = Caminho.

% Se houver ligacao entre o destino e o gid actual temos um caminho
percursoAbrigado( GidAtual, GidDestino, Operadoras, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, GidDestino, Distancia ),
    paragem( GidDestino,_,_,_,yes,_,_ ),
    reverse([(Car,GidAtual,GidDestino)|Ligacoes],Caminho).

percursoAbrigado( GidAtual, GidDestino, Operadoras, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, ProxGid, Distancia ),
    paragem( ProxGid,_,_,Abrigo,_,_,_ ),
    Abrigo \== semAbrigo,
    ProxGid \== GidDestino,
    \+memberchk(ProxGid,Visitados),
    percursoAbrigado( ProxGid, GidDestino, Operadoras, [ProxGid|Visitados], [(Car,GidAtual,ProxGid)|Ligacoes], Caminho).


% ----------------------------------------------------------
% |     percurso a passar em um ou mais ptos intermedios   |
% ----------------------------------------------------------

trajetoPtosInt( Origem, Destino, Pontos ,Caminho ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,Distancia)]\n'),
    percursoPtosInt( Origem , Destino, Pontos, [Origem], [], Caminho ).

% Se houver ligacao entre o destino e o gid actual temos um caminho
percursoPtosInt( GidAtual, GidDestino, Pontos, Visitados, Ligacoes, Caminho) :-
    visitaTodos(Pontos,Visitados),
    ligacao( Car, GidAtual, GidDestino, Dist ),
    reverse([( Car,GidAtual,ProxGid, Dist )|Ligacoes], Caminho).
% --- reverse([GidDestino|Visitados],Caminho).   -- Apresenta resultado os gids onde passou

percursoPtosInt( GidAtual, GidDestino, Pontos, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, ProxGid, Dist ),
    ProxGid \== GidDestino,
    \+memberchk( ProxGid, Visitados ),
    percursoPtosInt( ProxGid, GidDestino, Pontos, [ProxGid|Visitados], [(Car,GidAtual,ProxGid,Dist)|Ligacoes], Caminho).

visitaTodos([], _).
visitaTodos([X|Xs], L) :-
    member(X, L),
    visitaTodos(Xs, L).


% -----------------
% |    Gulosa     |
% -----------------

gulosa( Origem, Destino, Caminho ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,Distancia)]\n'),
    percursoGulosa( Origem , Destino, [Origem], [], Caminho ).

percursoGulosa( GidAtual, GidDestino, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, GidDestino, Dist ),
    reverse([( Car,GidAtual,ProxGid, Dist )|Ligacoes], Caminho).

percursoGulosa( GidAtual, GidDestino, Visitados, Ligacoes, Caminho) :-
    findall(( C, GidAtual, P, D ),ligacao( C, GidAtual, P, D ),Opcoes),
    removeVisitados(Opcoes,Visitados,[],OpcoesPorVisitar),
    length(OpcoesPorVisitar,L),
    L > 0,
    escolheCaminho(OpcoesPorVisitar,GidDestino,(Car,GidAtual,ProxGid,Dist)),
    %write('Escolhido:: '),write(ProxGid),write('\n'),
    ProxGid \== GidDestino,
    \+memberchk( ProxGid, Visitados ),
    ( percursoGulosa( ProxGid, GidDestino, [ProxGid|Visitados], [(Car,GidAtual,ProxGid,Dist)|Ligacoes], Caminho);
    percursoGulosa( GidAtual, GidDestino, [ProxGid|Visitados], Ligacoes, Caminho)).

escolheCaminho([(Car,Origem,Destino,Custo)|Caminhos],GOAL,R) :-
    estima(Destino,GOAL,EOA),
    escolheCaminho(Caminhos,GOAL,(Car,Origem,Destino,Custo),EOA,R).
escolheCaminho([],G,OA,EOA,R) :-
    R = OA.
escolheCaminho([(Car,Origem,Destino,Custo)|Caminhos],GOAL,OA,EOA,R) :-                   % OA : Opção atual  | COA: Estimativa OA
    estima(Destino,GOAL,Estima),
    Estima < EOA,
    escolheCaminho(Caminhos,GOAL,(Car,Origem,Destino,Custo),Estima,R).
escolheCaminho([(Car,Origem,Destino,Custo)|Caminhos],GOAL,OA,EOA,R) :-                   % OA : Opção atual  | COA: Estimativa OA
    estima(Destino,GOAL,Estima),
    Estima >= EOA,
    escolheCaminho(Caminhos,GOAL,OA,EOA,R).

removeVisitados([], _, TR, TR).
removeVisitados([(C,O,D,Dist)|Caminhos],Vis,TR,R) :-
    \+memberchk(D,Vis),
    removeVisitados(Caminhos,Vis,[(C,O,D,Dist)|TR],R).
removeVisitados([(C,O,D,Dist)|Caminhos],Vis,TR,R) :-
    memberchk( D,Vis ),
    removeVisitados(Caminhos,Vis,TR,R).

estima(O,D,R) :-
    distEuc(O,D,R).
distEuc(O,D,R) :-
    paragem( O,X1,Y1,_,_,_,_ ),
    paragem( D,X2,Y2,_,_,_,_ ),
    R is sqrt((X2-X1)^2 + (Y2-Y1)^2).


% -------------
% |    A*     |
% -------------

aestrela( Origem, Destino, Caminho ) :-
    write('Percurso no formato:\n[(Carreira,Origem,Destino,Distancia)]\n'),
    percursoAestrela( Origem , Destino, [Origem], [], Caminho ).

% Se houver ligacao entre o destino e o gid actual temos um caminho
percursoAestrela( GidAtual, GidDestino, Visitados, Ligacoes, Caminho) :-
    ligacao( Car, GidAtual, GidDestino, Dist ),
    reverse([( Car,GidAtual,ProxGid, Dist )|Ligacoes], Caminho).
% --- reverse([GidDestino|Visitados],Caminho).   -- Apresenta resultado os gids onde passou

percursoAestrela( GidAtual, GidDestino, Visitados, Ligacoes, Caminho) :-
    findall(( C, GidAtual, P, D ),ligacao( C, GidAtual, P, D ),Opcoes),
    removeVisitados(Opcoes,Visitados,[],OpcoesPorVisitar),
    length(OpcoesPorVisitar,L),
    L > 0,
    escolheCaminhoAestr(OpcoesPorVisitar,GidDestino,(Car,GidAtual,ProxGid,Dist)),
    ProxGid \== GidDestino,
    \+memberchk( ProxGid, Visitados ),
    ( percursoAestrela( ProxGid, GidDestino, [ProxGid|Visitados], [(Car,GidAtual,ProxGid,Dist)|Ligacoes], Caminho);
      percursoAestrela( GidAtual, GidDestino, [ProxGid|Visitados], Ligacoes, Caminho)).

escolheCaminhoAestr([(Car,Origem,Destino,Custo)|Caminhos],GOAL,R) :-
    estimaAestr(Custo,Destino,GOAL,EOA),
    escolheCaminhoAestr(Caminhos,GOAL,(Car,Origem,Destino,Custo),EOA,R).
escolheCaminhoAestr([],G,OA,EOA,R) :-
    R = OA.
escolheCaminhoAestr([(Car,Origem,Destino,Custo)|Caminhos],GOAL,OA,EOA,R) :-                   % OA : Opção atual  | COA: Estimativa OA
    estimaAestr(Custo,Destino,GOAL,Estima),
    Estima < EOA,
    escolheCaminhoAestr(Caminhos,GOAL,(Car,Origem,Destino,Custo),Estima,R).
escolheCaminhoAestr([(Car,Origem,Destino,Custo)|Caminhos],GOAL,OA,EOA,R) :-                   % OA : Opção atual  | COA: Estimativa OA
    estimaAestr(Custo,Destino,GOAL,Estima),
    Estima >= EOA,
    escolheCaminhoAestr(Caminhos,GOAL,OA,EOA,R).

estimaAestr(Custo,O,D,R) :-
    distEuc(O,D,DE),
    R is Custo+DE.