:- use_module(library(lists)).

% Load 11_q2.pl relative to this test file if not already loaded
:- (   current_predicate(generate_equation/2)
   ->  true
   ;   ensure_loaded('../code/11_q2.pl')
   ).

%% =============================================================================
%% Test Cases for P2 (Valid Arithmetic Equation)
%% =============================================================================

% 1. Standard assignment example: [4, 2, 5, 3]
test_case('example_4_2_5_3_generate', (
    generate_equation([4,2,5,3], E),
    member(E, [
        "4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
        "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"
    ])
)).

test_case('example_4_2_5_3_all', (
    all_equations([4,2,5,3], Es),
    Es == [
        "4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
        "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"
    ]
)).

test_case('example_4_2_5_3_count', (
    count_equations([4,2,5,3], 7)
)).

% 2. Standard assignment example: [2, 3, 4] (no valid equation exists)
test_case('example_2_3_4_fails', (
    \+ generate_equation([2,3,4], _)
)).

test_case('example_2_3_4_all_empty', (
    all_equations([2,3,4], [])
)).

test_case('example_2_3_4_count_zero', (
    count_equations([2,3,4], 0)
)).

% 3. Standard assignment example: [2, 4, 8]
test_case('example_2_4_8_generate', (
    generate_equation([2,4,8], "2*4=8")
)).

test_case('example_2_4_8_all', (
    all_equations([2,4,8], ["2*4=8"])
)).

test_case('example_2_4_8_count', (
    count_equations([2,4,8], 1)
)).

% 4. Edge case: Empty list
test_case('edge_empty_list_fails', (
    \+ generate_equation([], _)
)).

test_case('edge_empty_list_all', (
    all_equations([], [])
)).

test_case('edge_empty_list_count', (
    count_equations([], 0)
)).

% 5. Edge case: Single element list
test_case('edge_single_element_fails', (
    \+ generate_equation([5], _),
    \+ generate_equation([0], _)
)).

test_case('edge_single_element_all', (
    all_equations([5], []),
    all_equations([0], [])
)).

test_case('edge_single_element_count', (
    count_equations([5], 0),
    count_equations([0], 0)
)).

% 6. Edge case: Division by zero rejected without throwing unhandled exceptions
test_case('edge_division_by_zero_rejected', (
    \+ generate_equation([1, 0], _),
    all_equations([1, 0], []),
    count_equations([1, 0], 0)
)).

test_case('edge_division_by_zero_safe_handling', (
    all_equations([4, 0, 4], Es),
    Es == ["4+0=4", "4-0=4", "4=0+4"],
    \+ member("4/0=4", Es)
)).

% 7. Edge case: Non-exact division rejected (8/3 cannot be evaluated)
test_case('edge_non_exact_division_rejected', (
    all_equations([8, 3, 24], ["8*3=24"])
)).

% 8. Edge case: Sub-expressions evaluating to negative values (e.g. 3-5 = -2)
test_case('edge_negative_subexpression', (
    all_equations([3, 5, 0, 2], Es),
    member("3-5=0-2", Es)
)).

% 9. Edge case: Tree associativity producing distinct strings: 1+(2+3)=6 vs 1+2+3=6
test_case('edge_distinct_tree_parenthesization', (
    all_equations([1, 2, 3, 6], Es),
    member("1+(2+3)=6", Es),
    member("1+2+3=6", Es)
)).

%% =============================================================================
%% Test Runner
%% =============================================================================

run_tests :-
    format('~nRunning test suite for P2 (Valid Arithmetic Equation)...~n~n', []),
    findall(Name, test_case(Name, _), Names),
    run_all(Names, 0, 0, Passed, Failed),
    format('~nResults: ~w passed, ~w failed.~n', [Passed, Failed]),
    Failed =:= 0.

run_all([], P, F, P, F).
run_all([Name|Rest], P0, F0, P, F) :-
    test_case(Name, Goal),
    (   catch(call(Goal), Err, (format('  [ERROR] ~w: ~w~n', [Name, Err]), fail))
    ->  format('  [PASS] ~w~n', [Name]),
        P1 is P0 + 1,
        run_all(Rest, P1, F0, P, F)
    ;   format('  [FAIL] ~w~n', [Name]),
        F1 is F0 + 1,
        run_all(Rest, P0, F1, P, F)
    ).
