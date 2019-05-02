%{
/***************************************************************************
 * gram.y -- Grammar for the Reverse Polish Calculator			   *
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

/* $Id: gram.y,v 1.4 2000/04/02 16:12:17 david Rel $
 * $Log: gram.y,v $
 * Revision 1.4  2000/04/02 16:12:17  david
 * Added `#include <string.h>', added declaration of `pushtostack'.
 *
 * Revision 1.3  1999/09/12 20:51:45  david
 * Added gettext support.
 * Added variables and functions.
 * Set errno to 0 before function calls.
 *
 * Revision 1.2  1999/03/07 16:35:16  david
 * Simplified grammar, handles now EOF correctly.
 *
 * Revision 1.1  1999/03/06 14:45:27  david
 * Initial revision
 *
 */

#include <stdio.h>
#include <errno.h>
#include <malloc.h>
#include <string.h>
#include <search.h>

#include "cmds.h"
#include "stack.h"
#include "utils.h"

#ifdef HAVE_GETTEXT
#include <libintl.h>

#define _(String) gettext(String)
#else
#define _(String) (String)

#define textdomain(Domain)
#define bindtextdomain(Package, Directory)
#endif
extern int lineno;
extern int pushtostack;

extern void yyerror(const char *s);
extern int yylex(void);

#define MAXNOOFVARS 256

struct var vartab[MAXNOOFVARS];
%}

%union {
	        char    *name;
	        struct cmd *func;
                double   dnum;
		long int inum;
       }

%token <name>   VAR
%token <inum>   INT  
%token <dnum>   REAL
%token <func>   CMD FUNC
%token <name>   HELP

%%

input: /* empty */
     | input { pushtostack=1; } line
     ; 

line: '\n'		     { lineno++; showstack(); }
    | explist	             
    | help
    ;

explist: exp
       | explist exp
       ;
       
exp: CMD		     { double op1=0.0, op2=0.0;
                               errno=0;
                               switch ($1->argno) {
                                 case 0: $1->fnct(); 
                                         break;
                                 case 1: op1=pop(); 
                                         $1->fnct(op1); 
                                         break;
                                 case 2: op2=pop(); op1=pop(); 
                                         $1->fnct(op1,op2); 
                                         break;
                               }
		               if (errno != 0) yyerror(strerror(errno));
                             }
   | FUNC		     { double op1=0.0, op2=0.0, res=0.0;

                               errno=0;
                               switch ($1->argno) {
                                 case 0: res=$1->fnct(); 
                                         break;
                                 case 1: op1=pop(); 
                                         res=$1->fnct(op1); 
                                         break;
                                 case 2: op2=pop(); op1=pop(); 
                                         res=$1->fnct(op1,op2); 
                                         break;
			       }
		               if (errno != 0) yyerror(strerror(errno));
	                       push(res);
                             }
   | VAR		     { struct var s, *r;

			       s.vname=$1;
			       s.value=0.0;
                               r=lfind(&s, &vartab, &noofvars,
				       sizeof(struct var), varcmp);
			       if (r != NULL) {
				 push(r->value);
			       } else {
				 yyerror(_("undefined variable"));
			       }
                               free($1);
                             }
   | VAR '='		     { struct var v, *r;
			     
			       v.vname=xstrdup($1);
			       v.value=pop();
			       v.isconst=0;

                               r=lfind(&v, &vartab, &noofvars,
				       sizeof(struct var), varcmp);
			       if (r != NULL) {
				 if (r->isconst) {
				   yyerror(_("is a constant"));
				 } else {
				   r->value=v.value;
				 }
			       } else {
				 if (noofvars < MAXNOOFVARS) {
				   lsearch(&v, &vartab, &noofvars, 
					   sizeof(struct var), varcmp);
				 } else {
				   yyerror(_("variable table is full"));
				 }
			       }
                               free($1);
                             }
   | INT                     { push($1); }
   | REAL                    { push($1); }
   ;

help: HELP CMD               { help($2); }     
    | HELP FUNC              { help($2); }
    | HELP HELP              { help(NULL); }
    | HELP                   { help(NULL); }
    ;
%%
