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
