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
