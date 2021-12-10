#!/usr/bin/env swipl
:- initialization main.

:- use_module(library(pio)).

% ---- INPUT ----
lines([])           --> call(eos), !.
lines([Line|Lines]) --> line(Line), lines(Lines).

eos([], []).

line([])     --> ( "\n" ; call(eos) ), !.
line([L|Ls]) --> [L], line(Ls).

% ---- VALUES ----
value(round, 1).
value(square, 2).
value(curly, 3).
value(triangle, 4).

open_br(40, round).
open_br(91, square).
open_br(123, curly).
open_br(60, triangle).

close_br(41, round).
close_br(93, square).
close_br(125, curly).
close_br(62, triangle).

% ---- REMAINING ----
remaining_score([], A, A).
remaining_score([H|T], A, P):-
    value(H, V),
    B is (A * 5) + V,
    remaining_score(T, B, P).

% ---- MEDIAN (credit: https://stackoverflow.com/questions/23707541/median-in-prolog) ----
partition([], _, [], []).
partition([X | L], V, [X | A], B) :- (V > X), !, partition(L, V, A, B).
partition([X | L], V, A, [X | B]) :- (V < X), !, partition(L, V, A, B).
partition([X | L], V, A, B) :- (V =:= X), partition(L, V, A, B).

median(L, M) :-
    member(M, L),
    partition(L, M, A, B), length(A, X), length(B, X).

% ---- SCORE ----
score([], S, P):-
    remaining_score(S, 0, P).
score([H|Q], S, P):-
    open_br(H, T),
    score(Q, [T|S], P).
score([C|Q], [T|S], P):-
    close_br(C, T),
    score(Q, S, P).
score([C|_], [T|_], 0):-
    close_br(C, U),
    \+ T = U.

score_all([], S, S).
score_all([Head|Rest], A, S) :-
    score(Head, [], 0),
    score_all(Rest, A, S).
score_all([Head|Rest], A, S) :-
    score(Head, [], HeadScore),
    score_all(Rest, [HeadScore|A], S).

% ---- MAIN ----
main(_) :-
    phrase_from_file(lines(Ls), 'input'),
    score_all(Ls, [], S),
    median(S, M),
    write(M), nl,
    halt.
