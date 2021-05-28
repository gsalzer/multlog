%% ml_interactive.pl -- Run MUltlog interactively
multlog.

user:file_search_path(multlog, Dir) :-
    source_file(multlog, File),
    file_directory_name(File, Dir).

:- set_prolog_flag(double_quotes, codes).

% Load required files
:- [multlog(ml_conf)].
:- [multlog(ml_util)].
:- [multlog(ml_error)].
:- [multlog(ml_lgc)].
:- [multlog(ml_check)].
:- [multlog(ml_kernl)].
:- [multlog(ml_tex)].
:- [multlog(propres_compact)].
:- [multlog(ml_minimize)].
:- [multlog(ml_compactrepr)].

:- (dynamic logName/2, logTVs/2, logDTVs/2, logNDTVs/2, logOp/3, logColors/2, foundTaut/2).

% Defining logics
% ===============

% loadLogic(Filename, Lg) -- load definition of logic Lg from file FileName
% from FileName

loadLogic(FN, Lg) :-
    lgc_in(FN),
    check,
    deleteLogic(Lg),
    lgcLN(LN),
    assertz(logName(Lg, LN)),
    lgcTVs(TVs),
    assertz(logTVs(Lg, TVs)),
    lgcDTVs(DTVs),
    assertz(logDTVs(Lg, DTVs)),
    subtract(TVs, DTVs, NDTVs),
    assertz(logNDTVs(Lg, NDTVs)),
    (   lgcOp(N, _),
        chkOp(N, S),
        assertz(logOp(Lg, N, S)),
        fail
    ;   true
    ),
    setColors(Lg,all),
    format("Logic ~s loaded as '~a'.", [LN, Lg]), nl, !.

deleteLogic(Lg) :-
    retractall(logName(Lg, _)),
    retractall(logTVs(Lg, _)),
    retractall(logDTVs(Lg, _)),
    retractall(logNDTVs(Lg, _)),
    retractall(logOp(Lg, _, _)).

% addOp(Lg, Op/Ar, Map) -- add Op/Ar to logic L with mapping Map.
% if Ar/Op already defined, it is replaced.

addOp(Lg, Op/Ar, Map) :-
    retract(logOp(Lg, Op/Ar, _)),
    assertz(logOp(Lg, Op/Ar, Map)).

% delOp(Lg, Op/Ar) -- delete Op/Ar from logic Lg

delOp(Lg, Op/Ar) :- 
    retract(logOp(Lg,Op/Ar,_)).

% logOps(Lg, Ops) -- Ops is the list of operators of Lg

logOps(Lg, Ops) :-
    setof(Op, A^logOp(Lg, Op, A), Ops).

% logOps(Lg, Maps) -- Maps is the list of operator/map pairs of Lg

logMaps(Lg, Maps) :-
    setof(Op:Map, logOp(Lg, Op, Map), Maps).

% Semantics of logics
% ===================

% valueOp(Maps, Op, Arg, Val) -- in logic Lg, the value of Op applied to
% Arg is V.

valueOp(Lg, Op/Ar, Arg, V) :-
    logOp(Lg, Op/Ar, Map), !,
    member(Arg:V, Map).
valueOp(Lg, Op, Arg, V) :-
    logOp(Lg, Op/_, Map), !,
    member(Arg:V, Map).

% hasValue(Lg, F, V) -- in logic Lg, formula F has value V.

hasValue(Lg, F, F) :- % F can be a truth value of Lg
    logTVs(Lg,TVs),
    member(F,TVs).
hasValue(_, F, _) :-
    var(F), !, fail.
hasValue(Lg, F, V) :-  % F can be a constant mapped to V
    logOp(Lg,F/0, [[]:V]).
hasValue(Lg, F, V) :-
    F =.. [Op|Args],
    atom(Op),
    logOp(Lg, Op/A, Map),
    length(Args, A),
    maplist(hasValue(Lg), Args, Vals),
    member(Vals:V, Map).

% hasValueIn(Lg, Vs, F) :- For any values in truth values of logic Lg,
% F takes a value in Vs.

hasValueIn(Lg, F, Vs) :-
    hasValue(Lg, F, V),
    member(V, Vs).

haveValuesIn(_Lg, [], _Vs).
haveValuesIn(Lg, [F|Fs], Vs) :-
    hasValueIn(Lg, F, Vs),
    haveValuesIn(Lg, Fs, Vs).

% isDesignated(Lg, F) -- in logic Lg, F takes a
% designated value

isDesignated(Lg, F) :-
    logDTVs(Lg, DTVs),
    hasValueIn(Lg, F, DTVs).

areDesignated(_Lg, []).
areDesignated(Lg, [F|Fs]) :-
    isDesignated(Lg, F),
    areDesignated(Lg,Fs).

% isUnDesignated(Lg, F) -- same, except will find all solutions
% where F has a non-designated value.

isUnDesignated(Lg, F) :-
    logNDTVs(Lg, NDTVs),
    hasValueIn(Lg, F, NDTVs).

% isTaut(Lg, F) -- F is a tautology of Lg.

isTaut(Lg, F) :-
    logTVs(Lg, TVs),
    logDTVs(Lg, DTVs),
    term_variables(F, Vars), !,
    forall(listOfTVs(Vars, TVs),
           ( hasValue(Lg, F, V),
             member(V, DTVs)
           )).

findTaut(Lg, F) :-
    findFmla(Lg, F),
    \+ foundTaut(Lg, F),
    isTaut(Lg, F),
    assertz(foundTaut(Lg, F)).

findTaut(Lg) :-
    logName(Lg, N),
    format('Tautologies of ~s logic:~n', [N]),
    findTaut(Lg, F),
    numbervars(F, 0, _), 
    write_term(F, [numbervars(true), ignore_ops(true), spacing(next_argument)]), 
    nl, fail.


% isConseq(Lg, Fs, F) -- in logic Lg, F is a consequence of the Fs

isConseq(Lg, Fs, F) :-
    logTVs(Lg, TVs),
    logDTVs(Lg, DTVs),
    term_variables(Fs, Vars),
    forall(listOfTVs(Vars, TVs),
        ( haveValuesIn(Lg, Fs, DTVs) ->
          hasValueIn(Lg, F, DTVs) ; true
        )).

% areEquiv(Lg1, F1, Lg2, F2) -- F1 and F2 agree on all assignments of
% values from Lg1 to the variables of F1 and F2. Assumes that truth
% values of Lg1 are also truth values of Lg2.

areEquiv(Lg1, F1, Lg2, F2) :-
    forall(hasValue(Lg1, F1, V),
        hasValue(Lg2, F2, V)
           ).

% findEquiv(Lg1, F1, Lg2, -F2) -- find a formula F2 equivalent to F1.

findEquiv(Lg1, F1, Lg2, F2) :-
    term_variables(F1, VarsF1),
    findFmla(Lg2, F2, _, V), 
    maplist(revmember(VarsF1), V),
    areEquiv(Lg1, F1, Lg2, F2).

% listOfTVs(L, TVs) -- L is a subset of TVs (works as generator of
% lists of truth values).

listOfTVs([], _) :- !.
listOfTVs([L|Ls], TVs) :-
    member(L, TVs),
    listOfTVs(Ls, TVs).

% Finding formulas
% ================

% findFmla(Lg, -F) --- F is a formula of logic L. This will backtrack
% to find all formulas of Lg. It works by finding all most general
% formulas, then partitioning the set of variables, and identifying
% all variables in a set in the partition.

findFmla(Lg, F) :-
    findFmla(Lg, F, _, V),
    partition(V, Vs),
    unifyPart(Vs).

% findFmla(Lg, F, N, Vs) -- F is a most general formula of length N in
% logic Lg, with variables Vs.

findFmla(Lg, F, N, Vs) :-
    setof(Op, Map^logOp(Lg, Op, Map), Ops), !,
    length(S, N),
    findFmla(F, Ops, S, [], Vs, []).

% findFmla(F, Ops, S, S0, Vs, Vs0) F is a formula skeleton built from
% Ops of size S-S0, with variables Vs-Vs0. Ops is a list of
% Operator/Arity pairs.

findFmla(F, _Ops, [_|S], S, [F|Vs], Vs) :-
    var(F).
findFmla(F, Ops, [_|S], S0, Vs, Vs0) :-
    member(Op/Ar, Ops),
    functor(F, Op, Ar),
    F =.. [_|Fs],
    findFmla_l(Fs, Ops, S, S0, Vs, Vs0).

% isMGFmla_l(Lg, Ops, Fs, S, S0, Vs, Vs0) Fs is a list of formulas built
% from Ops with total size S-S0 and variables Vs-Vs0

findFmla_l([], _, S, S, Vs, Vs).
findFmla_l([F|Fs], Ops, S, S0, Vs, Vs0) :-
    findFmla(F, Ops, S, S1, Vs, Vs1),
    findFmla_l(Fs, Ops, S1, S0, Vs1, Vs0).

% partition(S, Ps) -- partition S into set of sets P.

partition([A], [[A]]).
partition([A|As], [[A] | Ps]) :-
    partition(As, Ps).
partition([A|As], Ps) :-
    partition(As, Qs),
    addElement(A, Qs, Ps).

addElement(A, [P | Ps], [[A|P]|Ps]).
addElement(A, [P | Ps], [P|Qs]) :-
    addElement(A, Ps, Qs).

% unifyPart(P) :- unify elements of each set in a partition.

unifyPart([]).
unifyPart([P|Ps]) :-
    unifySet(P),
    unifyPart(Ps).

% unifySet(A,S) :- unify all members of S.

unifySet([A|As]) :- 
    unifySet(A, As).

unifySet(_, []).
unifySet(A, [A|As]) :- 
    unifySet(A,As).

prettyFmla(F) :-
    term_variables(F, Vars),
    length(Vars, N),
    varList(N,Vars),
    write_term(F, [nl]), nl.

varList(N,Vars) :-
    numlist(1,N,Nums),
    maplist(varNo, Nums, Vars).

varNo(N,v-N).

revmember(X,Y) :- member(Y,X).
superset(X, Y) :- subset(Y, X).
intersects(X,Y) :- member(Z,X), member(Z,Y).

% Finding congruences of a matrix
% ===============================

% findCong(Lg) -- find a congruence of a logic and print it

findCong(Lg) :-
    logDTVs(Lg, DTVs),
    isCong(Lg, Part, DPart),
    length(Part, N1),
    length(DPart, N2),
    format("~nFound a congruence:~n~d congruence classes, ~d designated~nCongruence classes:~n~w~nDesignated classes:~n~w~n", [N1, N2, Part, DPart]),
    unionPart(Part, TVs),
    getColors(TVs, DTVs, partition(Part), Cols),
    (   logOp(Lg, Op/Ar, Map), 
        format('~nOperator ~w/~w:~n~n', [Op, Ar]),
        formatMap(Map, Ar, TVs, Cols), fail
    ;   true).

% unionPart(Part, Union) -- Union is the union of all classes in
% partition Part -- used to produce the list of truth values in an
% ordering that guarantees that equivalent truth values are adjacent

unionPart([], []) :- !.
unionPart([C|Cs], U) :-
    unionPart(Cs, U1),
    union(C, U1, U).

% isCong(Lg, Part) :- Part (a partition of truth values
% of Lg) is a congruence.

isCong(Lg, Part, DPart) :-
    logDTVs(Lg, DTVs),
    logNDTVs(Lg, NDTVs),
    partition(DTVs, DPart),
    partition(NDTVs, NDPart),
    union(NDPart, DPart, Part),
    forall(logOp(Lg, _Op/Ar, Map),
        congMap(Ar, Map, Part)).

% congMap(Ar, Map, Part) :- Part is a congruence wrt the Ar-place
% mapping Map, i.e., if [x1] -> y1 and [x2] -> y2 with x_1 ~ x_2 then
% y1 ~ y2 (where x ~ y iff [x, y] \subset X \in Part.

congMap(0, _, _) :- !.
congMap(Ar, Map, Part) :-
    length(ArgCs, Ar),
    forall(maplist(revmember(Part), ArgCs),
        checkCongPart(Map, ArgCs, Part)).

% checkCong(Map, ArgCs, ValC) :- ArgCs is a list of congruence
% classes; this checks if all values are in ValC (ie if all values are
% congruent).

% find the congruence class of the value of Map for the first sequence
% of arguments....

checkCongPart(Map, ArgCs, Part) :-
    maplist(revmember, ArgCs, Args),
    member(Args:V, Map),
    member(ClassV, Part),
    member(V, ClassV),
    !,
    checkCong(Map, ArgCs, ClassV).

% ... then test if the value of Map for all sequences of arguments
% from the sequence of classes of arguments is in Class

checkCong(Map, ArgCs, ClassV) :-
    forall(maplist(revmember, ArgCs, Args),
        (   member(Args:V, Map),
            member(V, ClassV))).

% subClass(Part, A) :- A is a subset of a set in P.

subClass([C|_], A) :-
    subset(A,C), !.
subClass([_|Cs], A) :-
    subClass(Cs, A).

equivClass([], _, _) :-
    fail.
equivClass([C|_], A, C) :-
    member(A, C), !.
equivClass([_|Cs], A, C) :-
    equivClass(Cs, A, C).

makeFactor(Lg, Cong, FL) :-
    logNDTVs(Lg, NDTVs),
    logDTVs(Lg, DTVs),
    include(intersects(NDTVs), Cong, NDCls),
    include(intersects(DTVs), Cong, DCls),
    format(atom(LN), '~w/~w', [Lg,Cong]),
    assertz(logName(FL,LN)),
    assertz(logTVs(FL, Cong)),
    assertz(logNDTVs(FL, NDCls)),
    assertz(logDTVs(FL, DCls)),
    (   logOp(Lg, Op/Ar, Map),
        factorMap(Map, Ar, Cong, FMap),
        assertz(logOp(FL, Op/Ar, FMap)),
        fail
    ;   true),
    setColors(FL, all).

factorMap(Map, Ar, Cong, FMap) :-
    length(CArgs, Ar),
    setof(CArgs:CV, 
        (   maplist(revmember(Cong), CArgs),
            factorValue(CArgs, Cong, Map, CV)), 
        FMap).

factorValue(CArgs, Cong, Map, CV) :-
    maplist(first, CArgs, Args),
    member(Args:V,Map), 
    classOf(V, Cong, CV).

first([A|_],A) :-!.
classOf(V, [C|_], C) :-
    member(V, C).
classOf(V, [_|Cs], C) :-
    classOf(V, Cs, C).

% Isomorphisms of logics
% ======================

isIso(Iso, Lg1, Lg2) :-
    logTVs(Lg1, TVs),
    logDTVs(Lg1, DTVs1),
    logDTVs(Lg2, DTVs2),
    logNDTVs(Lg1, NDTVs1),
    logNDTVs(Lg2, NDTVs2),
    permutation(DTVs2, DP2),
    permutation(NDTVs2, NP2),
    pairUp(NDTVs1,NP2, NIso),
    pairUp(DTVs1, DP2, DIso),
    union(NIso, DIso, Iso),
    forall(logOp(Lg1,Op/N, Map1),
        (   logOp(Lg2,Op/N,Map2),
            isIso(TVs, Iso, N, Map1, Map2))).

isIso(_, Iso, 0, [[]:V1], [[]:V2]) :-
    mapIso(Iso, V1, V2), !.
isIso(TVs, Iso, N, Map1, Map2) :-
    length(Args1, N),
    forall(maplist(revmember(TVs), Args1),
        (   member(Args1:V1,Map1),
            maplist(mapIso(Iso), Args1, Args2),
            member(Args2:V2,Map2),
            mapIso(Iso, V1, V2))).

mapIso(Iso, V1, V2) :-
    member((V1,V2), Iso).

sortIso(Lg, Iso) :-
    maplist(second, Iso, TVs),
    logDTVs(Lg, DTVs),
    retractall(logTVs(Lg,_)),
    retractall(logDTVs(Lg,_)),
    retractall(logNDTVs(Lg,_)),
    include(revmember(DTVs), TVs, NewDTVs),
    subtract(TVs, DTVs, NewNDTVs),
    assertz(logTVs(Lg, TVs)),
    assertz(logDTVs(Lg, NewDTVs)),
    assertz(logNDTVs(Lg, NewNDTVs)).


second((_,B), B).

% Products of logics
% ==================

makeProduct(Lg1, Lg2, Lg12) :-
    logTVs(Lg1, TVs1),
    logTVs(Lg2, TVs2),
    setProduct(TVs1, TVs2, TVs),
    assertz(logTVs(Lg12, TVs)),
    logDTVs(Lg1, DTVs1),
    logDTVs(Lg2, DTVs2),
    setProduct(DTVs1, DTVs2, DTVs),
    assertz(logDTVs(Lg12, DTVs)),
    subtract(TVs, DTVs, NDTVs),
    assertz(logNDTVs(Lg12, NDTVs)),
    forall(logOp(Lg1, Op/Ar, Map1),
    (   logOp(Lg2, Op/Ar, Map2),
        mapProduct(Map1, Map2, Map),
        assertz(logOp(Lg12, Op/Ar, Map)))),
    format(atom(LN), '~w x ~w', [Lg1,Lg2]),
    assertz(logName(Lg12, LN)),
    setColors(Lg12, all).

setProduct(A1, A2, B) :-
    setof((P1, P2), (member(P1, A1), member(P2, A2)), B).

mapProduct(M1, M2, B) :-
    setof(Args:V,
        prodMap(M1, M2, Args, V),
        B).

prodMap(M1, M2, Args, (V1, V2)) :-
    member(A1:V1, M1),
    member(A2:V2, M2),
    pairUp(A1, A2, Args).

pairUp([],[],[]).
pairUp([A|As],[B|Bs], [(A,B)|Cs]) :-
    pairUp(As,Bs,Cs).

% Formatting and output
% =====================

formatLogic(Lg) :- formatLogic(Lg, ansi).

formatLogic(Lg, Format) :-
    logName(Lg, N),
    logTVs(Lg, TVs),
    logDTVs(Lg, DTVs),
    format('Logic ~s (~w)~nTruth values: ~w~nDesignated: ~w~n', 
        [N, Lg, TVs, DTVs]),
    (   formatOp(Lg, _, Format), fail ; true).

% formatOp(Lg, Op/Ar, Format) -- format the map for Op/Ar in logic Lg

formatOp(Lg, Op/Ar) :- formatOp(Lg, Op/Ar, ansi).
formatOp(Lg, Op/Ar, Format) :-
    logColors(Lg, Cols),
    formatOp(Lg, Op/Ar, Cols, Format).

formatOp(Lg, Op/Ar, Cols, Format) :-
    logOp(Lg, Op/Ar, Map),
    logTVs(Lg, TVs),
    format('~nOperator ~w/~w:~n~n', [Op, Ar]),
    formatMap(Map, Ar, TVs, Cols, Format).

% formatMap(Map, Ar, TVs, Cols, Format) -- format Map of arity Ar for truth
% values in TVs with color mapping Cols

formatMap(Map, N, TVs, Cols) :-
    formatMap(Map, N, TVs, Cols, ansi).
formatMap([[]:TV], 0, _, Cols, ansi) :-
    format('= '),
    maxLength([TV], N),
    formatTV(Cols, N, TV, ansi),
    format('~n'), !.

formatMap(Map, 2, TVs, Cols, ansi) :-
    maxLength(TVs, N),
    length(TVs, M),
    L is (N+1)*(M+1)+1,
    format('~*+~t | ', [N]),
    formatTVs(Cols, N, TVs, ansi),
    format('~n~`-t~*+~n', [L]),
    (   member(TV, TVs),
        maplist(applyMap(Map, TV), TVs, Vs),
        formatTV(Cols, N, TV, ansi),
        format(' | '),
        formatTVs(Cols, N, Vs, ansi),
        format('~n'),
        fail
    ; true), !.

formatMap(Map, Ar, TVs, Cols, ansi) :-
    maxLength(TVs, N),
    L is (N+1)*(Ar+1)+1,
    format('~`-t~*+~n', [L]),
    (   length(Args, Ar),
        maplist(revmember(TVs), Args),
        formatTVs(Cols, N, Args, ansi),
        format(' | '),
        member(Args:V, Map),
        formatTV(Cols, N, V, ansi),
        format('~n'),
        fail
    ; true), !.

formatMap([[]:TV], 0, _, Cols, tex) :-
    format('= '),
    formatTV(Cols, _, TV, tex),
    format('~n'), !.

formatMap(Map, 2, TVs, Cols, tex) :-
    format('\\begin{array}{c|'),
    format_arrayheader(TVs),
    format('}\\\\~n & '),
    formatTVs(Cols, N, TVs, tex),
    format('\\\\ \\hline~n'),
    (   member(TV, TVs),
        maplist(applyMap(Map, TV), TVs, Vs),
        formatTV(Cols, N, TV, tex),
        format(' & '),
        formatTVs(Cols, N, Vs, tex),
        format('\\\\~n'),
        fail
    ; format('\\end{array}~n')), !.

formatMap(Map, Ar, TVs, Cols, tex) :-
    format('\\begin{array}{'),
    length(N, Ar),
    format_arrayheader(N),
    format('|c}~n\\hline~n'),
    (   length(Args, Ar),
        maplist(revmember(TVs), Args),
        formatTVs(Cols, N, Args, tex),
        format(' & '),
        member(Args:V, Map),
        formatTV(Cols, N, V, tex),
        format('\\\\~n'),
        fail
    ; format('\\end{array}~n')), !.

format_arrayheader([]) :- !.
format_arrayheader([_|T]) :-
    format('c'),
    format_arrayheader(T).

% formatTV(Cols, N, TV, Format) -- format a truth value of max length N with
% color map Cols

formatTV(Cols, N, TV, ansi) :-
    member(TV-C, Cols),
    ansi_format(C, '~|~w~*+~t', [TV,N]).
formatTV(Cols, _, TV, tex) :-
    member(TV-C, Cols),
    tex_format(C, TV).

tex_format([bg(BG),fg(FG)], A) :-
    tex_color(BG, TexBG),
    tex_color(FG, TexFG),
    format('\\colorbox~w}{\\color~w}~w}', [TexBG,TexFG,A]).
tex_format([fg(FG)], A) :-
    tex_color(FG, TexFG),
    format('{\\color~w}~w}', [TexFG,A]).
tex_format([], A) :-
    format('~w', [A]).

tex_color(white, '{black') :- !.
tex_color(black, '{white') :- !.
tex_color(C, TC) :-
    atom_codes(C, [0'#|S]),
    atom_codes(TC, [91, 72, 84, 77, 76, 93, 123 |S]), !.
tex_color(C, TC) :-
    atom_codes(C, S),
    atom_codes(TC, [123 |S]), !.


% format a list of truth values

formatTVs(Cols, N, [TV], Format) :-
    formatTV(Cols, N, TV, Format), !.
formatTVs(Cols, N, [V|Vs], ansi) :-
    formatTV(Cols, N, V, ansi),
    format(' ', []),
    formatTVs(Cols, N, Vs, ansi).

formatTVs(Cols, N, [V|Vs], tex) :-
    formatTV(Cols, N, V, tex),
    format(' & ', []),
    formatTVs(Cols, N, Vs, tex).

% apply Map to V1, V2 to find value V

applyMap(Map, V1, V2, V) :-
    member([V1,V2]:V,Map).

% maxLength(TVs, N) -- find the maximum length N of the truth values in TVs

maxLength([], 0).
maxLength([V|Vs], M) :-
    format(codes(S), '~w', [V]),
    length(S, N),
    maxLength(Vs, K),
    ( K < N -> M is N ; M is K ).

% getColors(TVs, DTVs, Scheme, VCs) -- VCs is a list of truth
% value-ANSI color pairs for the truth values in TVs, with DTVs the
% designated values.

getColors(TVs, DTVs, Scheme, VCs) :-
    colors(Colors),
    mapcolors(Scheme, TVs, DTVs, Colors, Colors, VCs), !.

% setColors(Lg, Scheme) -- set the default colors for logic Lg according 
% to Scheme

setColors(Lg, Scheme) :-
    logTVs(Lg,TVs),
    logDTVs(Lg,DTVs),
    getColors(TVs, DTVs, Scheme, VCs),
    (retract(logColors(Lg,_)), fail ; true),
    assert(logColors(Lg,VCs)), !.

% mapcolors(Scheme, TVs, DTVs, Colors, Colors, VCs) -- used for
% producing the truth value-color map

% plain -- just use white

mapcolors(plain, [], _, _, _, []) :- !.
mapcolors(plain, [V|Vs], DTVs, _, _, [V-[]|VCs]) :-
    mapcolors(plain, Vs, DTVs, [], [], VCs).

% designated -- just use white with reversed for designated

mapcolors(designated, [], _, _, _, []) :- !.
mapcolors(designated, [V|Vs], DTVs, _, _, [VC|VCs]) :-
    color_designated(DTVs, white, V, VC),
    mapcolors(designated, Vs, DTVs, [], [], VCs).

% all -- distribute all colors in Colors across the truth values

mapcolors(all, [], _, _, _, []) :- !.
mapcolors(all, Vs, DTVs, [], Colors, VCs) :- 
    mapcolors(all, Vs, DTVs, Colors, Colors, VCs), !.
mapcolors(all, [V|Vs], DTVs, [C|Cs], Colors, [VC|VCs]) :-
    color_designated(DTVs, C, V, VC),
    mapcolors(all, Vs, DTVs, Cs, Colors, VCs).

% partition(P) -- use all colors, but color all truth values in one
% equivalence class the same

mapcolors(partition(P), TVs, DTVs, Colors, Colors, VCs) :-
    partition_colors(TVs, P, P, Colors, Colors, PCs),
    mapcolors(all, TVs, DTVs, PCs, PCs, VCs).

% color_designated(DTVs, Color, V, CMap) --
% make value V have color Color, reversed if V is in DTVs

color_designated(DTVs, Color, V, V-[bg(Color),fg(black)]) :-
    member(V,DTVs), !.
color_designated(_DTVs, Color, V, V-[fg(Color)]).

% provide a list of colors

colors(['#FA602D', '#D729E3', '#3953FA', '#29E3C1', '#86FF3B',
    '#FAA341', '#E33B57', '#904DFA', '#3BABE3', '#4FFF78',
    '#FABF1F', '#E35727', '#FA37F7', '#2728E3', '#38FDFF',
    '#FAE464', '#E39B66', '#FA7EAF', '#8D66E3', '#80D6FF']).

% make a list of colors for TVs on the basis of Colors and Partition Part

partition_colors([], _, _, _, _, []) :- !.
partition_colors(Vs, Part, Ps, Colors, [], PCs) :-
    partition_colors(Vs, Part, Ps, Colors, Colors, PCs).
partition_colors([V|Vs], Part, [P|Ps], Colors, [C|Cs], [C|PCs]) :-
    member(V, P),
    partition_colors(Vs, Part, [P|Ps], Colors, [C|Cs], PCs).
partition_colors(Vs, Part, [_|Ps], Colors, [_|Cs], PCs) :-
    partition_colors(Vs, Part, Ps, Colors, Cs, PCs).
partition_colors(Vs, Part, _, Colors, _, PCs) :-
    partition_colors(Vs, Part, Part, Colors, Colors, PCs).

% Announce MUltlog loaded

:- format('~s~n~n',
    ["MUtlog @ml_version@ loaded in interactive mode"]).
