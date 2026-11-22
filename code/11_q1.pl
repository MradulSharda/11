:- use_module(library(lists)).
:- use_module(library(aggregate)).

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

%   Clue 5: The friend whose favorite language is Java works in the design department.
clue(5, Solution) :-
    member(p(_, design, java, _), Solution).

%   Clue 6: Carla's project preference is not embedded, and her department is not development.
clue(6, Solution) :-
    member(p('Carla', Dept, _, Project), Solution),
    Project \= embedded,
    Dept \= development.

%   Clue 7: Dana's favorite language is not Java, and she works in research or testing.
clue(7, Solution) :-
    member(p('Dana', Dept, Lang, _), Solution),
    Lang \= java,
    ( Dept = research ; Dept = testing ).

%   Clue 8: The friend who prefers data projects works in research and does not use JavaScript.
clue(8, Solution) :-
    member(p(_, research, Lang, data), Solution),
    Lang \= javascript.

%!  satisfies_all_clues(+Active, +Solution) is semidet.
%
%   Base case: an empty list of active clues is vacuously satisfied.
satisfies_all_clues([], _).
%   Recursive case: verifies the head clue against Solution and recurses on the tail.
satisfies_all_clues([ClueIndex|Rest], Solution) :-
    clue(ClueIndex, Solution),
    satisfies_all_clues(Rest, Solution).

%!  count_solutions(+Active, -N) is det.
%
%   N is the number of solutions from valid_template/1 that satisfy all clues
%   specified in the Active list while ignoring all other clues.
count_solutions(Active, N) :-
    aggregate_all(count, (valid_template(Solution), satisfies_all_clues(Active, Solution)), N).



