'\" t
.\"Traducido por Claudio S. Suárez el 8 de Julio de 1999
.TH RPNCALC 1 "$Date: 1999/07/10 16:30:23 $" "Debian" "Manual de referencia de usuarios" \" -*- nroff -*-
.SH NOMBRE
rpncalc \- una calculadora de notación polaca inversa (RPN).
.SH SINOPSIS
.B rpncalc
[-h]|[-v]|["\fIexpresión\fP"]
.PP
.SH DESCRIPCIÓN
.I rpncalc
emula parcialmente una HP 28S y está pensada para cálculos del
día a día
(por ejemplo
.IR "1 1 +" "),"
no para tareas complejas (en ese caso, use
.BR gnuplot "(1)"
u
.BR octave "(1)"
).
.IR "rpncalc " "evalúa la"
.I expresión
dada o la lee de la entrada estándar si no hay tal expresión.
No está implementado nada concerniente a:
.br
 \(bu números complejos,
.br
 \(bu vectores, matrices, listas y tablas,
.br
 \(bu datos algebraicos, evaluación simbólica,
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
.IR " cambio de línea" .

Hay un par de añadidos respecto a la HP28: el
uso de prefijos 0x y 0 para representar los números hexadecimales
y octales respectivamente, como en C. Las nuevas Funciones de Bessel
y funciones de error son para hacer un mejor uso de la biblioteca de
rutinas matemáticas.
.SH OPCIONES
.TP
.I \-h, \-\-help
para obtener la ayuda
.TP
.I \-v, \-\-version
escribe la versión de rpncalc y finaliza.
.SH VÉASE TAMBIÉN
.BR dc "(1),"
.BR bc "(1),"
.BR gnuplot "(1),"
.BR octave "(1),"
.BR units "(1)."
.SH FALLOS
La forma de tratarse las excepciones de las operaciones en
coma flotante depende de la máquina y arquitectura en que se
encuentre.
.PP
La precisión y el rango de los cálculos depende de la
biblioteca de funciones matemáticas (y en general será mucho peor
que los datos originales).
.SH AUTOR
David Frey
.SH NOTA
HP 28S es una marca registrada Hewlett Packard Instruments.
