:- use_module(library(lists)).
:- use_module(library(aggregate)).

% Load Problem 1 implementation relative to this test file.
:- consult('../code/11_q1.pl').

%!  test_permutation_count is semidet.
%
%   Verifies that valid_template/1 generates exactly 24^3 = 13824
%   raw attribute permutations when no clues are applied.
test_permutation_count :-
    count_solutions([], 13824).

%!  test_clue_filters is semidet.
%
%   Verifies that each individual clue actively filters out invalid states.
%   1. Concrete negative tests: every clue fails on an invalid candidate.
%   2. Domain space reduction: each clue strictly reduces the state count from 13824.
test_clue_filters :-
    % Clue 1 rejects candidate where the AI project friend is Dana
    \+ clue(1, [p('Alex', research, java, web),
                p('Ben', testing, python, data),
                p('Carla', development, 'c++', embedded),
                p('Dana', design, javascript, 'AI')]),

    % Clue 2 rejects candidate where Alex is in development
    \+ clue(2, [p('Alex', development, java, web),
                p('Ben', testing, python, data),
                p('Carla', research, 'c++', 'AI'),
                p('Dana', design, javascript, embedded)]),

    % Clue 3 rejects candidate where testing friend does not like python
    \+ clue(3, [p('Alex', research, java, web),
                p('Ben', testing, java, data),
                p('Carla', development, python, 'AI'),
                p('Dana', design, javascript, embedded)]),

    % Clue 4 rejects candidate where Ben works in testing
    \+ clue(4, [p('Alex', research, java, embedded),
                p('Ben', testing, python, web),
                p('Carla', development, 'c++', 'AI'),
                p('Dana', design, javascript, data)]),

    % Clue 5 rejects candidate where Java friend works in research (not design)
    \+ clue(5, [p('Alex', research, java, web),
                p('Ben', testing, python, data),
                p('Carla', development, 'c++', 'AI'),
                p('Dana', design, javascript, embedded)]),

    % Clue 6 rejects candidate where Carla is assigned embedded project
    \+ clue(6, [p('Alex', design, java, web),
                p('Ben', testing, python, data),
                p('Carla', research, 'c++', embedded),
                p('Dana', development, javascript, 'AI')]),

    % Clue 7 rejects candidate where Dana works in design (neither research nor testing)
    \+ clue(7, [p('Alex', testing, java, web),
                p('Ben', research, python, data),
                p('Carla', development, 'c++', 'AI'),
                p('Dana', design, javascript, embedded)]),

    % Clue 8 rejects candidate where data project friend uses javascript
    \+ clue(8, [p('Alex', design, java, web),
                p('Ben', testing, 'c++', embedded),
                p('Carla', development, python, 'AI'),
                p('Dana', research, javascript, data)]),

    % Clue 9 rejects candidate where testing friend prefers embedded (not AI)
    \+ clue(9, [p('Alex', design, java, 'AI'),
                p('Ben', development, javascript, web),
                p('Carla', research, 'c++', data),
                p('Dana', testing, python, embedded)]),

    % Ensure each clue strictly prunes the search space (0 < Count < 13824)
    forall(member(C, [1, 2, 3, 4, 5, 6, 7, 8, 9]),
           (count_solutions([C], Count), Count > 0, Count < 13824)).

%!  test_eight_clues is semidet.
%
%   Verifies that clues 1 through 8 yield exactly 3 solutions.
test_eight_clues :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8], 3).

%!  test_nine_clues is semidet.
%
%   Verifies that clues 1 through 9 yield exactly 1 unique solution.
test_nine_clues :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8, 9], 1).

%!  test_order_independence is semidet.
%
%   Verifies that the order and duplication of clues in Active list does not alter count.
test_order_independence :-
    count_solutions([8, 7, 6, 5, 4, 3, 2, 1], 3),
    count_solutions([9, 8, 7, 6, 5, 4, 3, 2, 1], 1),
    count_solutions([1, 1, 2, 3, 4, 5, 6, 7, 8], 3).

%!  test_main_output is semidet.
%
%   Verifies that main/0 executes cleanly, outputs 4 lines for all 4 friends,
%   and does not throw any unhandled exceptions.
test_main_output :-
    with_output_to(string(Output), main),
    sub_string(Output, _, _, _, "Alex = "),
    sub_string(Output, _, _, _, "Ben = "),
    sub_string(Output, _, _, _, "Carla = "),
    sub_string(Output, _, _, _, "Dana = "),
    split_string(Output, "\n", "\n", Lines),
    length(Lines, 4).

%!  run_tests is det.
%
%   Runs all test suites sequentially with formatted status reporting.
run_tests :-
    format('Running Test 1: Raw permutation count (13824)...~n'),
    ( test_permutation_count ->
        format('  [PASS] valid_template produces exactly 13824 states.~n')
    ;   format('  [FAIL] valid_template count mismatch.~n'), fail
    ),
    format('Running Test 2: Individual clue filtering...~n'),
    ( test_clue_filters ->
        format('  [PASS] Every clue actively rejects invalid states and prunes domain.~n')
    ;   format('  [FAIL] Clue filtering check failed.~n'), fail
    ),
    format('Running Test 3: Clues 1 to 8 solution count (N = 3)...~n'),
    ( test_eight_clues ->
        format('  [PASS] count_solutions([1..8], 3) succeeded.~n')
    ;   format('  [FAIL] Expected 3 solutions for clues 1-8.~n'), fail
    ),
    format('Running Test 4: Clues 1 to 9 unique solution count (N = 1)...~n'),
    ( test_nine_clues ->
        format('  [PASS] count_solutions([1..9], 1) succeeded.~n')
    ;   format('  [FAIL] Expected 1 unique solution for clues 1-9.~n'), fail
    ),
    format('Running Test 5: Clue order independence and duplicates...~n'),
    ( test_order_independence ->
        format('  [PASS] count_solutions produces identical count regardless of clue order.~n')
    ;   format('  [FAIL] Order independence check failed.~n'), fail
    ),
    format('Running Test 6: main/0 output formatting and line count...~n'),
    ( test_main_output ->
        format('  [PASS] main/0 outputs exactly 4 formatted lines without error.~n')
    ;   format('  [FAIL] main/0 formatting check failed.~n'), fail
    ),
    format('~nAll 6 test suites passed successfully!~n').
