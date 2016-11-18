# fluent

This is an SWI-Prolog module implementing "fluents", or method
chaining.  Because Prolog does not have functions, variables are often
"threaded" through multiple calls - the problem with this is that
those variables have to be unique for each call, creating a lot of
things that look like Temp1, Temp2, Temp3, etc. The fluent/5 predicate
allows multiple calls to be made, threading a variable through them,
remaining non-deterministic (although it can contain cut).
For Example, if I have square_value(Val, Square), where Square is Val
** 2 and root_value(Val, Root) where Root is sqrt(Val), I can call
fluent like:

fluent([square_value(In, Out), root_value(In, Out)], In, Out, 2,
Result),

This will square 2 and the take its square root (not very useful)
