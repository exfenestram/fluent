/*
MIT License

Copyright (c) 2016 Ray Richardson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

:- module(fluent, [fluent/5]).

% fluent_call/5 calls a single callable goal with parameter substitution

fluent_call(Callable, TemplIn, TemplOut, In, Out) :-
	subst_templ(Callable, TemplIn, In, NextCall),
	subst_templ(NextCall, TemplOut, Out, Actual),
	call(Actual).

% subst_templ/4 substitutes instances of Template with Actual. Most useful for variable
% substitution
subst_templ(Callable, Template, Actual, Result) :-
	Callable =.. CallList,
	maplist(subst_var(Template, Actual), CallList, ResList),
	Result =.. ResList.

% subst_var/4 actually substitutes a variable if it matches the Template
subst_var(Template, Actual, In, Out) :-
	(Template == In ->
	 Out = Actual
	;
	 Out = In).


% fluent/5 executes the fluent. Non-determinism is respected
% fluent(FluentList, InTemplate, OutTemplate, In, Out)
% an empty fluent simply unifies In and Out
fluent([], _TemplIn, _TemplOut, In, In).

% Note that fluent/5 is does not last call optimize
fluent([H | T], TemplIn, TemplOut, In, Out) :-
	fluent_call(H, TemplIn, TemplOut, In, Tmp),
	fluent(T, TemplIn, TemplOut, Tmp, Out).