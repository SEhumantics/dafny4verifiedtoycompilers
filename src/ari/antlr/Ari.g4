grammar Ari;

options {
	language = Python3;
}

prog: (s += stmt ';')*;

stmt:
	'print' '(' e = expr ')'		# Print
	| 'set' v = VAR ':=' e = expr	# Assign;

expr:
	n = INT						# Const
	| v = VAR					# Var
	| e1 = expr '+' e2 = expr	# Add
	| e1 = expr '-' e2 = expr	# Sub;

VAR: [a-z]+;
INT: [0-9]+;
WS: [ \t\n\r]+ -> skip;