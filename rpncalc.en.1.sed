'\" t
.TH RPNCALC 1 "$Date: 1999/07/10 16:30:14 $" "Debian" "User's Reference Manual" \" -*- nroff -*-
.SH NAME
rpncalc \- a reverse polish notation (RPN) calculator.
.SH SYNOPSIS
.B rpncalc
[-h]|[-v]|["\fIexpression\fP"]
.PP
.SH DESCRIPTION
.I rpncalc
partially emulates a HP 28S and is intended for every-day purposes
(i.e.
.IR "1 1 +" "),"
not for complex calculations (use
.BR gnuplot "(1)"
or
.BR octave "(1)"
for these).
.IR "rpncalc " evaluates
.I expression
if given or reads from standard input otherwise.
These features are not implemented:
.br
 \(bu complex numbers,
.br
 \(bu vector, matrices, lists and arrays,
.br
 \(bu algebraic input, symbolic evaluation,
.br
 \(bu units, and
.br
 \(bu variables.
.br
.PP
.I rpncalc
recognizes the following functions, operations, and constants:
.PP
.TS
center, expand, tab(@);
l l l l l l l l.
%CMDS%
.TE
.PP
Delimiters are
.IR , ,
.IR ; ,
.IR space ,
.IR "tab " and
.IR newline .

A few things have been added with respect to a HP28: the prefixes 0x resp. 0
stand for hexadecimal resp. octal constants, as in C. The Bessel Functions and
the error functions are new, in order to make better use of the math library.
.SH OPTIONS
.TP
.I \-h, \-\-help
stands for help
.TP
.I \-v, \-\-version
prints out the current version of rpncalc and exits.
.SH SEE ALSO
.BR dc "(1),"
.BR bc "(1),"
.BR gnuplot "(1),"
.BR octave "(1),"
.BR units "(1)."
.SH BUGS
The floating point exception handling relies on the math library and is
site- and architecture dependent.
.PP
Accuracy and range of the calculations is at the mercy of the math library 
(and generally much worse than the original).
.SH AUTHOR
David Frey
.SH NOTE
HP 28S is a trademark of Hewlett Packard Instruments.
