:- use_module(library(lists)).

%!  valid_template(-Solution) is nondet.
%
%   Generates a candidate solution template for the 4 friends in the exact order:
%   'Alex', 'Ben', 'Carla', and 'Dana'.
%
%   Each person is represented by the term:
%       p(Name, Department, Language, Project)
%
%   Domains:
%   - Departments: [research, development, design, testing]
%   - Languages:   [python, java, 'c++', javascript]
%   - Projects:    ['AI', web, embedded, data]
%
%   Uses permutation/2 across the 4 positions so that every attribute is assigned
%   uniquely across the friends without repetition.
valid_template([
    p('Alex', D1, L1, P1),
    p('Ben', D2, L2, P2),
    p('Carla', D3, L3, P3),
    p('Dana', D4, L4, P4)
]) :-
    permutation([research, development, design, testing], [D1, D2, D3, D4]),
    permutation([python, java, 'c++', javascript], [L1, L2, L3, L4]),
    permutation(['AI', web, embedded, data], [P1, P2, P3, P4]).

%!  clue(+Index, +Solution) is semidet.
%
%   Verifies individual clues against a fully instantiated Solution list.
%
%   Clue 1: The friend who prefers the AI project does not work in research
%           and is not Dana.
clue(1, Solution) :-
    member(p(Name, Dept, _, 'AI'), Solution),
    Dept \= research,
    Name \= 'Dana'.

%   Clue 2: Alex does not work in development and does not prefer C++.
clue(2, Solution) :-
    member(p('Alex', Dept, Lang, _), Solution),
    Dept \= development,
    Lang \= 'c++'.

%   Clue 3: The friend working in the testing department likes Python.
clue(3, Solution) :-
    member(p(_, testing, python, _), Solution).

%   Clue 4: Ben prefers web projects and does not work in testing.
clue(4, Solution) :-
    member(p('Ben', Dept, _, web), Solution),
    Dept \= testing.

