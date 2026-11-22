:- use_module(library(lists)).

%% gen_expr(+Numbers, -ExprTree, -Value)
%  True when ExprTree is a valid binary arithmetic expression tree over the
%  non-empty list Numbers (in the given order) evaluating to integer Value.
%  Enforces exact integer division (no remainder and non-zero divisor)
%  at every division node. Sub-expressions may evaluate to negative integers.

%  Base case: a single number forms an atomic expression with itself as value.
gen_expr([N], N, N) :-
    integer(N).

%  Recursive case: partition Numbers into non-empty LeftNums and RightNums,
%  recursively construct sub-expression trees and their integer values,
%  and combine them using one of (+, -, *, /).
gen_expr(Numbers, ExprTree, Value) :-
    Numbers = [_, _ | _],
    append([L|Ls], [R|Rs], Numbers),
    gen_expr([L|Ls], LeftExpr, LeftVal),
    gen_expr([R|Rs], RightExpr, RightVal),
    combine_expr(LeftExpr, LeftVal, RightExpr, RightVal, ExprTree, Value).

%% combine_expr(+LeftExpr, +LeftVal, +RightExpr, +RightVal, -ExprTree, -Value)
%  Combines two sub-expressions with an operator (+, -, *, /) and computes
%  the resulting integer Value. Division is valid iff divisor is non-zero
%  and remainder is zero.
combine_expr(LeftExpr, LeftVal, RightExpr, RightVal, LeftExpr + RightExpr, Value) :-
    Value is LeftVal + RightVal.
combine_expr(LeftExpr, LeftVal, RightExpr, RightVal, LeftExpr - RightExpr, Value) :-
    Value is LeftVal - RightVal.
combine_expr(LeftExpr, LeftVal, RightExpr, RightVal, LeftExpr * RightExpr, Value) :-
    Value is LeftVal * RightVal.
combine_expr(LeftExpr, LeftVal, RightExpr, RightVal, LeftExpr / RightExpr, Value) :-
    RightVal =\= 0,
    LeftVal mod RightVal =:= 0,
    Value is LeftVal // RightVal.

%% gen_equation(+List, -LTree, -RTree)
%  True when LTree and RTree are valid arithmetic expression trees over a
%  non-empty prefix and non-empty suffix of List respectively, such that
%  both expressions evaluate to the same integer value.
%  Fails if List has fewer than 2 elements.
gen_equation(List, LTree, RTree) :-
    List = [_, _ | _],
    append([L|Ls], [R|Rs], List),
    gen_expr([L|Ls], LTree, LVal),
    gen_expr([R|Rs], RTree, RVal),
    LVal =:= RVal.

%% Operator precedence for canonical formatting.
%  * and / bind tighter (precedence 2) than + and - (precedence 1).
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).

%% expr_to_string(+Tree, -String)
%  Converts an arithmetic expression tree into an SWI-Prolog string with no
%  spaces, applying parentheses according to the canonical precedence rules.
expr_to_string(N, String) :-
    integer(N), !,
    number_string(N, String).
expr_to_string(Tree, String) :-
    Tree =.. [Op, Left, Right],
    op_prec(Op, ParentPrec),
    expr_to_string(Left, LeftRaw),
    expr_to_string(Right, RightRaw),
    format_left(Left, ParentPrec, LeftRaw, LeftStr),
    format_right(Right, ParentPrec, RightRaw, RightStr),
    atomics_to_string([LeftStr, Op, RightStr], String).

%% format_left(+SubTree, +ParentPrec, +RawStr, -FormattedStr)
%  A left operand is parenthesized iff its top operator has strictly
%  lower precedence than its parent operator. Single numbers are never parenthesized.
format_left(SubTree, ParentPrec, RawStr, FormattedStr) :-
    compound(SubTree),
    SubTree =.. [Op, _, _],
    op_prec(Op, SubPrec),
    SubPrec < ParentPrec, !,
    atomics_to_string(['(', RawStr, ')'], FormattedStr).
format_left(_, _, RawStr, RawStr).

%% format_right(+SubTree, +ParentPrec, +RawStr, -FormattedStr)
%  A right operand is parenthesized iff its top operator has the same or
%  lower precedence than its parent operator. Single numbers are never parenthesized.
format_right(SubTree, ParentPrec, RawStr, FormattedStr) :-
    compound(SubTree),
    SubTree =.. [Op, _, _],
    op_prec(Op, SubPrec),
    SubPrec =< ParentPrec, !,
    atomics_to_string(['(', RawStr, ')'], FormattedStr).
format_right(_, _, RawStr, RawStr).

%% format_equation(+LTree, +RTree, -Str)
%  Converts left and right expression trees into canonical strings and
%  joins them with '=' into an SWI-Prolog string "L=R".
format_equation(LTree, RTree, Str) :-
    expr_to_string(LTree, LStr),
    expr_to_string(RTree, RStr),
    atomics_to_string([LStr, '=', RStr], Str).

%% =============================================================================
%% Public API
%% =============================================================================

%% generate_equation(+List, -Equation)
%  Unifies Equation with one valid arithmetic equation string for List.
%  Fails if List has length 0 or 1, or if no valid equation exists.
generate_equation(List, Equation) :-
    gen_equation(List, LTree, RTree),
    format_equation(LTree, RTree, Equation).

%% all_equations(+List, -Equations)
%  Unifies Equations with the list of all valid arithmetic equations for List,
%  without duplicates, sorted by sort/2 (standard order of terms).
%  If no valid equation exists (including for length 0 or 1), Equations = [].
all_equations(List, Equations) :-
    findall(Eq, (
        gen_equation(List, LTree, RTree),
        format_equation(LTree, RTree, Eq)
    ), RawEquations),
    sort(RawEquations, Equations).

%% count_equations(+List, -N)
%  N is the total number of unique valid equations for List.
count_equations(List, N) :-
    all_equations(List, Equations),
    length(Equations, N).



