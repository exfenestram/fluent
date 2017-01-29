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
	% If there's no matching In parameter, Pass In to Out
	subst_templ(Callable, TemplIn, In, NextCall, Result),
	(call(Result) ->
	 true
	;
	 Out = In,
	 NextCall = Callable),
	% Same for out. If it doesn't occur, map it to In, for the next stage
	subst_templ(NextCall, TemplOut, Out, Actual, NextResult),
	(call(NextResult) ->
	 true
	;
	 Out = In,
	 Actual = NextCall),
	
	call(Actual).

% subst_templ/5 substitutes instances of Template with Actual. Most useful for variable
% substitution
subst_templ(Callable, Template, Actual, Result, Res) :-
	Callable =.. CallList,
	foldl(subst_var(Template, Actual), CallList, ResList, false, Res),
	Result =.. ResList.

% subst_var/6 actually substitutes a variable if it matches the Template.
% It is a fold predicate and passes out true if it matches
subst_var(Template, Actual, In, Out, InTruth, OutTruth) :-
	% If it's a compound, them substitute its components
	(compound(In) ->
	 subst_templ(In, Template, Actual, Out, Result), 
	 (call(Result) ->
	  OutTruth = true
	 ;
	  OutTruth = InTruth)
	;
	 (Template == In ->
	  Out = Actual,
	  OutTruth = true
	 ;
	  Out = In,
	  OutTruth = InTruth)).
	

% fluent/6 executes the fluent. Non-determinism is respected
% The top level choice is passed down for ancestral cuts
% fluent(FluentList, InTemplate, OutTemplate, In, Out)
% an empty fluent simply unifies In and Out
fluent([], _TemplIn, _TemplOut, In, In, _Choice).

% Handle Cut
fluent([! | T], TemplIn, TemplOut, In, Out, Choice) :-
	prolog_cut_to(Choice),
	prolog_current_choice(NextChoice), 
	fluent(T, TemplIn, TemplOut, In, Out, NextChoice).

% Note that fluent/6 is does not last call optimize
fluent([H | T], TemplIn, TemplOut, In, Out, Choice) :-
	fluent_call(H, TemplIn, TemplOut, In, Tmp),
	fluent(T, TemplIn, TemplOut, Tmp, Out, Choice).

% fluent/5 just set the choicepoint and calls fluent/6
fluent(CallableList, TemplIn, TemplOut, In, Out) :-
	prolog_current_choice(Choice),
	fluent(CallableList, TemplIn, TemplOut, In, Out, Choice).