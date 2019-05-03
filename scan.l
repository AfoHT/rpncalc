%{
/***************************************************************************
 * scan.l -- Scanner for the Reverse Polish Calculator			   *
 *									   *
 * A little RPN (Reverse Polish Notation) calculator, rudimentary          *
 * emulating a HP 28S. 					                   *
 * 								           *
 * rpncalc is (c) David Frey, 1993, 1994, 1995, 1996, 1997, 1998	   *
 *								           * 
 * This program is free software; you can redistribute it and/or modify it *
 * under the terms of the GNU General Public License as published by the   *
 * Free Software Foundation; either version 2 of the License, or (at your  *
 * option) any later version.                                              *
 *									   * 
 * This program is distributed in the hope that it will be useful, but     *
 * WITHOUT ANY WARRANTY; without even the implied warranty of              *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       *
 * General Public License for more details.                                *
 *									   * 
 * You should have received a copy of the GNU General Public License       *
 * along with this program; if not, write to the Free Software Foundation, *
 * Inc., 59 Temple Place Suite 330, Boston, MA 02111-1307 USA.             *
 ***************************************************************************/

/* $Id: scan.l,v 1.3 1999/09/12 20:57:44 david Exp $
 * $Log: scan.l,v $
 * Revision 1.3  1999/09/12 20:57:44  david
 * Added variable and constant names support.
 * Improved error messages for hexadecimal and octal numbers ('invalid constant' instead of
 * 'parse error').
 *
 * Revision 1.2  1999/03/07 16:35:46  david
 * Moved most of readline-specific stuff into rpncalc.c
 *
 * Revision 1.1  1999/03/06 14:44:19  david
 * Initial revision
 *
 */

#include <unistd.h>
#include <strings.h>
#include <malloc.h>
#include <math.h>
#include <errno.h>

#include <readline/readline.h>
#include <readline/history.h>

char *command_generator (char *text, int state);

#include "cmds.h"
#include "stack.h"
#include "utils.h"
#include "gram.h"

#include <libintl.h>

#define _(String) gettext(String)

#define textdomain(Domain)
#define bindtextdomain(Package, Directory)

extern char *filename, *progname;
extern struct var vartab[];

void yyerror(const char *s);
int yylex(void);

/* This structure must be held in cmdcmp()-order, 
   since it will be bsearch()ed! */
const struct cmd cmdtab[] =
{
  { "!"       , 1, 1, fact     , "factorial"                               },
  { "%"       , 2, 1, percent  , "xy/100"                                  },
  { "%ch"     , 2, 1, deltapercent, "100(y-x)/x"                           },
  { "%t"      , 2, 1, percenttotal, "100y/x"                               },
  { "&"       , 2, 1, and      , "logical and"                             },
  { "*"       , 2, 1, multiply , "multiplication"                          },
  { "+"       , 2, 1, plus     , "addition"                                },
  { "-"       , 2, 1, minus    , "subtraction"                             },
  { "/"       , 2, 1, divide   , "division"                                },
  { "?"       , 0, 0, help     , "show all known functions and commands"   },
  { "^"       , 2, 1, pow      , "exponentiation"                          },
  { "abs"     , 1, 1, fabs     , "absolute value: |x|"                     },
  { "acos"    , 1, 1, acos     , "arc cosine"                              },
  { "acosh"   , 1, 1, acosh    , "inverse hyperbolic cosine"               },
  { "alog"    , 1, 1, exp10    , "exponentiation to the base 10: 10^x"     },
  { "and"     , 2, 1, and      , "logical and"                             },
  { "arg"     , 2, 1, atan2    , "arc tangent of 2 variables"              },
  { "asin"    , 1, 1, asin     , "arc sine"                                },
  { "asinh"   , 1, 1, asinh    , "inverse hyperbolic sine"                 },
  { "atan"    , 1, 1, atan     , "arc tangent"                             },
  { "atan2"   , 2, 1, atan2    , "arc tangent of 2 variables"              },
  { "atanh"   , 1, 1, atanh    , "inverse hyperbolic tangent"              },
  { "bin"     , 0, 0, setbin   , "set binary"                              },
  { "cbrt"    , 1, 1, cbrt     , "cube root: x^1/3"                        },
  { "ceil"    , 1, 1, ceil     , "smallest integral value not less than x" },
  { "char"    , 0, 0, setchar  , "display ASCII values"                    },
  { "chs"     , 1, 1, chs      , "change sign"                             },
  { "clear"   , 0, 0, clear    , "clear stack"                             },
  { "cos"     , 1, 1, cos      , "cosine"                                  },
  { "cosh"    , 1, 1, cosh     , "arcus cosine"                            },
  { "dec"     , 0, 0, setdec   , "switch to decimal base"                  },
  { "depth"   , 0, 1, depth    , "show depth of stack"                     },
  { "div"     , 2, 1, idiv     , "divide"                                  },
  { "drop"    , 0, 0, drop     , "drop last stack element"                 },
  { "drop2"   , 0, 0, drop2    , "drop last 2 stack elements"              },
  { "dropn"   , 1, 0, dropn    , "drop last n stack elements"              },
  { "dup"     , 1, 0, dupel    , "duplicate last stack element"            },
  { "dup2"    , 1, 0, dupel2   , "duplicate last 2 stack elements"         },
  { "dupn"    , 2, 0, dupn     , "duplicate last n stack elements"         },
  { "erf"     , 1, 1, erf      , "error function"                          },
  { "erfc"    , 1, 1, erfc     , "complementary error function: 1-erf(x)"  },
  { "exit"    , 0, 0, quit     , "exit rpncalc"                            },
  { "exp"     , 1, 1, exp      , "exponential function: e^x"               },
  { "expm"    , 1, 1, expm1    , "e^x-1"                                   },
  { "fact"    , 1, 1, fact     , "factorial"                               },
  { "floor"   , 1, 1, floor    , "largest integral value not greater than x" },
  { "fp"      , 1, 1, fp       , "floating point part of x"                },
  { "gcd"     , 2, 1, gcd      , "greatest common divisor"                 },
  { "help"    , 0, 0, help     , "show all known functions and commands"   },
  { "hex"     , 0, 0, sethex   , "switch to hexadecimal base"              },
  { "hypot"   , 2, 1, hypot    , "Euclidean distance function: sqrt(x^2+y^2)" },
  { "inv"     , 1, 1, inv      , "inverse: 1/x"                            },
  { "ip"      , 1, 1, ip       , "largest integral value not greater than x" },
  { "j0"      , 1, 1, j0       , "Bessel function of zeroth order"         },
  { "j1"      , 1, 1, j1       , "Bessel function of first  order"         },
  { "jn"      , 2, 1, jn       , "Bessel function of n-th order"           },
  { "ld"      , 1, 1, log2     , "base-2 logarithm"                        },
  { "ldb"     , 1, 1, logb     , "integer part of the base-2 logarithm"    },
  { "lg"      , 1, 1, log10    , "logarithm to the base 10"                },
  { "lgamma"  , 1, 1, lgamma   , "ln|gamma(x)|"                            },
  { "ln"      , 1, 1, log      , "natural log"                             },
  { "lnp1"    , 1, 1, log1p    , "ln(1+x)"                                 },
  { "log"     , 1, 1, log10    , "logarithm to the base 10"                },
  { "max"     , 2, 1, max      , "max(x,y)"                                },
  { "min"     , 2, 1, min      , "min(x,y)"                                },
  { "mod"     , 2, 1, mod      , "modulo function"                         },
  { "neg"     , 1, 1, chs      , "change sign"                             },
  { "not"     , 1, 1, not      , "logical not"                             },
  { "oct"     , 0, 0, setoct   , "switch to octal base"                    },
  { "or"      , 2, 1, or       , "logical or"                              },
  { "over"    , 0, 0, over     , "push second last element on stack"       },
  { "pick"    , 1, 1, pick     , "duplicate a element from the stack"      },
  { "pop"     , 0, 0, pop      , "drop last element from stack"            },
  { "prec"    , 1, 0, prec     , "set precision"                           },
  { "prod"    , 0, 1, prod     , "product of all elements on stack"        },
  { "push"    , 1, 0, push     , "push a new element on the stack"         },
  { "quit"    , 0, 0, quit     , "exit rpncalc"                            },
  { "rand"    , 0, 1, rnd      , "random value [0, 1["                     },
  { "rdz"     , 1, 0, rdz      , "set seed for random value generator"     },
  { "rint"    , 1, 1, rint     , "round to closest integer"                },
  { "rnd"     , 1, 1, rint     , "round to closest integer"                },
#if 0
  { "roll"    , 1, 0, roll     , "roll the stack"                          },
  { "rolld"   , 0, 0, rolld    , "roll the stack down"                     },
#endif
  { "rot"     , 0, 0, rot      , "rotate the stack"                        },
  { "shl"     , 1, 1, sl       , "shift left"                              },
  { "show"    , 0, 0, showstack, "redisplay stack"                         },
  { "shr"     , 1, 1, sr       , "shift right"                             },
  { "sign"    , 1, 1, sign     , "sign of x"                               },
  { "sin"     , 1, 1, sin      , "sine"                                    },
  { "sinh"    , 1, 1, sinh     , "hyperbolic sine"                         },
  { "sl"      , 1, 1, sl       , "shift left"                              },
  { "slb"     , 1, 1, slb      , "shift left 1 byte"                       },
  { "sq"      , 1, 1, sqr      , "square: x^2"                             },
  { "sqr"     , 1, 1, sqr      , "square: x^2"                             },
  { "sqrt"    , 1, 1, sqrt     , "square root"                             }, 
  { "sr"      , 1, 1, sr       , "shift right"                             },
  { "srb"     , 1, 1, srb      , "shift right 1 byte"                      },
  { "sum"     , 0, 1, sum      , "sum of all elements on stack"            },
  { "swap"    , 0, 0, swap     , "swap last two elements"                  },
  { "tan"     , 1, 1, tan      , "tangent"                                 },
  { "tanh"    , 1, 1, tanh     , "hyperbolic tangent"                      },
  { "warranty", 0, 0, warranty , "show absence of warranty"                },
  { "xor"     , 2, 1, xor      , "logical xor"                             },
  { "y0"      , 1, 1, y0       , "Bessel function of the second kind of zeroth order" },
  { "y1"      , 1, 1, y1       , "Bessel function of the second kind of first order"  },
  { "yn"      , 2, 1, yn       , "Bessel function of the second kind of n-th order"   },
  { "|"       , 2, 1, or       , "logical or"                              },
  { "~"       , 1, 1, not      , "logical not"                             }
};

const int noofcmds=sizeof(cmdtab) / sizeof(cmdtab[0]);

int lineno=1;
%}

VAR	[A-Za-z][A-Za-z0-9]*
INT	[+-]?[1-9][0-9]*
OCTINT	[+-]?0[0-9]+
HEXINT	[+-]?0[xX][0-9A-Za-z]+
BININT	[+-]?0[bB][01]+
REAL	[+-]?([0-9]*\.[0-9]+|[0-9]+)([eE][-+]?[0-9]+)?

DELIM   [ \t\v\f\r;,]
%%

^"#".*\n	  ;

{HEXINT}	  { /* Wrong hexadecimal constants are allowed in the 
                       parser and will be catched by strtol(3). This gives
		       a better (more meaningful) error message. */
		    char *e, **ep=&e;
		    errno=0;
		    yylval.inum=strtol(yytext,ep,0); 
		    if (errno != 0) yyerror(strerror(errno));
		    if (*e != '\0') yyerror(_("invalid hexadecimal constant"));
		    return INT;  }

{BININT}	  { /* Wrong binary constants are allowed in the 
                       parser and will be catched by strtol(3). This gives
		       a better (more meaningful) error message. */
		    char *e, **ep=&e;
		    errno=0;
		    yylval.inum=strtol(&yytext[2],ep,2); 
		    if (errno != 0) yyerror(strerror(errno));
		    if (*e != '\0') yyerror(_("invalid binary constant"));
		    return INT;  }

{OCTINT}	  { /* Wrong hexadecimal constants are allowed in the 
                       parser and will be catched by strtol(3). This gives
		       a better (more meaningful) error message. */
		    char *e, **ep=&e;
		    errno=0;
		    yylval.inum=strtol(yytext,ep,0); 
		    if (errno != 0) yyerror(strerror(errno));
		    if (*e != '\0') yyerror(_("invalid octal constant"));
		    return INT;  }

{INT}		  { char *e, **ep=&e;
		    errno=0;
		    yylval.inum=strtol(yytext,ep,0); 
		    if (errno != 0) yyerror(strerror(errno));
		    if (*e != '\0') yyerror(_("invalid integer constant"));
		    return INT;  }

{REAL}		  { yylval.dnum=atof(yytext); return REAL; }

[!%&*+/?^|~-][a-z]?[a-z0-9]* {
                    struct cmd *f, k;

		    k.fname=yytext;
		    f=(struct cmd *)bsearch(&k, cmdtab, 
					    noofcmds, sizeof(cmdtab[0]),
					    cmdcmp);
		    
		    if (f != NULL) {
                      yylval.func=f;

		      if (f->fnct == help) {
			return HELP ;
		      } else if (f->pushrestostack) {
			return FUNC;
		      } else {
		        return CMD;
		      }
		    } else {
		      yyerror(_("undefined function or command"));
		    }
		  }

{VAR}		  {
	            struct cmd *f, k;

		    k.fname=yytext;
		    f=(struct cmd *)bsearch(&k, cmdtab, 
					    noofcmds, sizeof(cmdtab[0]),
					    cmdcmp);
		    
		    if (f != NULL) {
                      yylval.func=f;

		      if (f->fnct == help) {
			return HELP ;
		      } else if (f->pushrestostack) {
			return FUNC;
		      } else {
		        return CMD;
		      }
		    } else {
		      yylval.name=xstrdup(yytext); 
		      return VAR;
		    }
		  }

{DELIM}+	  ;
<<EOF>>           return 0;
\n|.		  return yytext[0];


%%

int yywrap(void)
{
  lineno=1; return 1;
}

void yyerror(const char *s)
{
  fprintf(stderr,_("%s:%s:%d: %s at '%s'\n"), 
		  progname, filename, lineno, s, yytext);
}

/* Generator function for command completion.  STATE lets us know whether
   to start from scratch; without any state (i.e. STATE == 0), then we
   start at the top of the list. */
char *command_generator (char *text, int state)
{
  static int clist_index, vlist_index;
  static size_t len;
  const char *name;

  /* If this is a new word to complete, initialize now.  This includes
     saving the length of TEXT for efficiency, and initializing the index
     variable to 0. */
  if (!state) { clist_index=vlist_index=0; len=strlen(text); }

  /* Return the next name which partially matches from the command list. */
  while (clist_index < noofcmds) {
    name = cmdtab[clist_index].fname; clist_index++;

    if (strncmp (name, text, len) == 0) return (xstrdup(name));
  }

  /* Return the next variable which partially matches from the 
     variable list. */
  while (vlist_index < noofvars) {
    name = vartab[vlist_index].vname; vlist_index++;

    if (strncmp (name, text, len) == 0) return (xstrdup(name));
  }

  /* If no names matched, then return NULL. */
  return ((char *)NULL);
}
