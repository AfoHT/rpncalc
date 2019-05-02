'\" t                                                         \" -*- nroff -*-
.TH RPNCALC 1 "$Date: 1999/07/10 16:30:14 $" "Debian" "Benutzerreferenzhandbuch" 
.SH NAME
rpncalc \- ein umgekehrt polnischer Taschenrechner
.SH SYNTAX
.B rpncalc
[-h]|[-v]|["\fIausdruck\fP"]
.PP
.SH BESCHREIBUNG
.I rpncalc
emuliert teilweise einen HP 28S-Taschenrechner und ist für den
täglichen Gebrauch gedacht (i.e.
.IR "1 1 +" "),"
und nicht für komplexe Berechnungen (für das sind
.BR gnuplot "(1)"
und
.BR octave "(1)"
da).
.IR "rpncalc " "berechnet den auf der Kommandozeile übergebenen"
.I ausdruck
, falls vorhanden, andernfalls die Standardeingabe.
Diese Eigenschaften eines HP28S sind nicht implementiert:
.br
 \(bu komplexe Zahlen,
.br
 \(bu Vektoren, Matrizen, Listen und Arrays,
.br
 \(bu algebraischer Input, symbolische Auswertung,
.br
 \(bu Einheitenberechnungen, und
.br
 \(bu Variablen.
.br
.PP
.I rpncalc
kennt die nachfolgenden Funktionen, Operationen und Konstanten:
.PP
.TS
center, expand, tab(@);
l l l l l l l l.
%CMDS%
.TE
.PP
Begrenzer sind
.IR , ,
.IR ; ,
.IR Leerzeichen,
.IR "Tabulatoren " und
.IR newline .

Einige Dinge sind im Vergleich zum HP28S hinzugefügt worden: Die
Prefixe 0x resp. 0, welche für hexadezimale resp. oktale Konstanten
stehen (wie in C). Die Bessel und die Fehlerfunktion sind neu, um die
Mathematikbibliothek besser auszunutzen.
.SH OPTIONEN
.TP
.I \-h, \-\-help
gibt eine Hilfestellung aus.
.TP
.I \-v, \-\-version
druckt die aktuelle Version von rpncalc und beendet rpncalc.
.SH SIEHE AUCH
.BR dc "(1),"
.BR bc "(1),"
.BR gnuplot "(1),"
.BR octave "(1),"
.BR units "(1)."
.SH FEHLER
Die Ausnahmebehandlung für Gleitkommafehler ist von der
Mathematikbibliothek abhängig, welche ihrerseits durch die
Maschinenarchitektur und C-Bibliothek bestimmt wird.
.PP
Die Genauigkeit und der Zahlenbereich der Berechnungen hängen
gnadenlos von der Mathematikbibliothek ab (und sind generell viel
schlechter als das Original).
.SH AUTOR
David Frey
.SH NOTE
HP 28S ist ein eingetragenes Wahrenzeichen von Hewlett Packard Instruments.
