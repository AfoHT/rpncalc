'\" t
.\"Traducido por Claudio S. Su�rez el 8 de Julio de 1999
.TH RPNCALC 1 "$Date: 1999/07/10 16:30:23 $" "Debian" "Manual de referencia de usuarios" \" -*- nroff -*-
.SH NOMBRE
rpncalc \- una calculadora de notaci�n polaca inversa (RPN).
.SH SINOPSIS
.B rpncalc
[-h]|[-v]|["\fIexpresi�n\fP"]
.PP
.SH DESCRIPCI�N
.I rpncalc
emula parcialmente una HP 28S y est� pensada para c�lculos del
d�a a d�a
(por ejemplo
.IR "1 1 +" "),"
no para tareas complejas (en ese caso, use
.BR gnuplot "(1)"
u
.BR octave "(1)"
).
.IR "rpncalc " "eval�a la"
.I expresi�n
dada o la lee de la entrada est�ndar si no hay tal expresi�n.
No est� implementado nada concerniente a:
.br
 \(bu n�meros complejos,
.br
 \(bu vectores, matrices, listas y tablas,
.br
 \(bu datos algebraicos, evaluaci�n simb�lica,
.br
 \(bu distintas unidades,
.br
 \(bu variables.
.br
.PP
.I rpncalc
reconoce las siguientes funciones, operaciones y constantes:
.PP
.TS
center, expand, tab(@);
l l l l l l l l.
%CMDS%
.TE
.PP
Los delimitadores son
.IR , ,
.IR ; ,
.IR espacio ,
.IR "tab " "y el caracter de"
.IR " cambio de l�nea" .

Hay un par de a�adidos respecto a la HP28: el
uso de prefijos 0x y 0 para representar los n�meros hexadecimales
y octales respectivamente, como en C. Las nuevas Funciones de Bessel
y funciones de error son para hacer un mejor uso de la biblioteca de
rutinas matem�ticas.
.SH OPCIONES
.TP
.I \-h, \-\-help
para obtener la ayuda
.TP
.I \-v, \-\-version
escribe la versi�n de rpncalc y finaliza.
.SH V�ASE TAMBI�N
.BR dc "(1),"
.BR bc "(1),"
.BR gnuplot "(1),"
.BR octave "(1),"
.BR units "(1)."
.SH FALLOS
La forma de tratarse las excepciones de las operaciones en
coma flotante depende de la m�quina y arquitectura en que se
encuentre.
.PP
La precisi�n y el rango de los c�lculos depende de la
biblioteca de funciones matem�ticas (y en general ser� mucho peor
que los datos originales).
.SH AUTOR
David Frey
.SH NOTA
HP 28S es una marca registrada Hewlett Packard Instruments.
