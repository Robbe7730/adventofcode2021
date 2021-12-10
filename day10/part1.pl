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
value(round, 3).
value(square, 57).
value(curly, 1197).
value(triangle, 25137).

open_br(40, round).
open_br(91, square).
open_br(123, curly).
open_br(60, triangle).

close_br(41, round).
close_br(93, square).
close_br(125, curly).
close_br(62, triangle).

% ---- SCORE ----
score([], _, 0).
score([H|Q], S, P):-
    open_br(H, T),
    score(Q, [T|S], P).
score([C|Q], [T|S], P):-
    close_br(C, T),
    score(Q, S, P).
score([C|_], _, S):-
    close_br(C, U),
    value(U, S).

score_all([], 0).
score_all([Head|Rest], N) :-
    score(Head, [], HeadScore),
    score_all(Rest, RestScore),
    N is HeadScore + RestScore.

% ---- MAIN ----
main(_) :-
    phrase_from_file(lines(Ls), 'input'),
    score_all(Ls, N),
    write(N), nl,
    halt.
