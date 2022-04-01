/***************************************************************************
 * rpncalc.c                                                               *
 *                                                                         *
 * A little RPN (Reverse Polish Notation) calculator, rudimentary          *
 * emulating a HP 28S.                                                     *
 *                                                                         *
 * rpncalc is (c) David Frey et. al., 1993-2004, 2007                      *
 *                                                                         *
 * This program is free software; you can redistribute it and/or modify it *
 * under the terms of the GNU General Public License as published by the   *
 * Free Software Foundation; either version 2 of the License, or (at your  *
 * option) any later version.                                              *
 *                                                                         *
 * This program is distributed in the hope that it will be useful, but     *
 * WITHOUT ANY WARRANTY; without even the implied warranty of              *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       *
 * General Public License for more details.                                *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with this program; if not, write to the Free Software Foundation, *
 * Inc., 59 Temple Place Suite 330, Boston, MA 02111-1307 USA.             *
 ***************************************************************************/

/* $Id: rpncalc.c,v 1.11 2004/01/11 22:25:19 david Exp david $
 * $Log: rpncalc.c,v $
 * Revision 1.11  2004/01/11 22:25:19  david
 * Add mtrace() calls.
 * Better prototyping.
 *
 * Revision 1.10  2000/04/02 16:14:41  david
 * Adapted copyright date.
 * Changed for new libreadline prototypes (thanks to Ben Collins for the patch).
 *
 * Revision 1.9  1999/09/12 20:59:13  david
 * Included constand and variable name support.
 *
 * Revision 1.8  1999/03/07 16:36:02  david
 * Move most of readline-specific stuff from scan.l into rpncalc.c.
 * Changed reading in the lines.
 *
 * Revision 1.7  1998/01/04 16:40:53  david
 * - changed HAVE_READLINE to HAVE_LIBREADLINE, HAVE_HISTORY to
 *   HAVE_LIBHISTORY for future use with autoconf.
 * - added the meaningfull X/OPEN-math functions to rpncalc:
 *   ln1p (log1p), ldb (logb), expm1, gamma, lgamma, hypot, cbrt, floor, rint.
 *   Changed the names of the log-named functions to reflect their base
 *   (log -> ln, lobg -> ld)
 * - --warranty and --license switches are new.
 * - renamed -v to -V switch.
 * - changed version to 1.2
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <signal.h>
#include <locale.h>
#include <search.h>

#include <getopt.h>

#include <readline/readline.h>
#include <readline/history.h>

#include "cmds.h"
#include "stack.h"
#include "utils.h"

size_t noofvars;
void initialize_readline(int interactive);

extern char *command_generator (const char *text, int state);

#include <libintl.h>

#define  _(String) gettext(String)

extern int  yyparse(void);
extern void yy_scan_string(char *s);

extern struct cnst consttab[];
extern struct var vartab[];

const char *progname, *filename;
int done;

struct option const long_options[] =
{
  {"help",     no_argument, 0, 'h'},
  {"version",  no_argument, 0, 'V'},
  {"warranty", no_argument, 0, 'W'},
  {"license",  no_argument, 0, 'L'},
  {(char *)0, 0,           0, (char)0}
};

/* print a short usage statement. Indicate that the argument must be quoted. */
static void usage(int showhelp)
{
  printf(_("usage: %s [-h][-v] [\"expression\"]\n"), progname);
  if (showhelp) {
    printf("\n");
    printf("-h, --help\t%s\n"    ,_("display this help and exit"));
    printf("-v, --version\t%s\n" ,_("output version information and exit"));
    printf("-W, --warranty\t%s\n",_("show license information and exit"));
    printf("-L, --license\t%s\n" ,_("show license information and exit"));
  }
}

/* Tell the GNU Readline library how to complete.  We want to try to complete
   on command names if this is the first word in the line. */
void initialize_readline(int interactive)
{
  /* Allow conditional parsing of the ~/.inputrc file. */
  rl_readline_name = "rpncalc";

  /* Tell the completer that we want a crack first. */
  if (interactive) {
    rl_completion_entry_function=command_generator;
  } else {
    rl_bind_key('\t', rl_insert);
    /* Suppress key binding of TAB in batch mode */
  }
}

/* the initialisation code was taken from:
     fileman.c -- A tiny application which demonstrates how to use the
     GNU Readline library.  This application interactively allows users
     to manipulate files and their modes.
 */

/* Attempt to complete on the contents of TEXT.  START and END show the
   region of TEXT that contains the word to complete.  We can use the
   entire line in case we want to do some simple parsing.  Return the
   array of matches, or NULL if there aren't any. */

char **rpncalc_completion(const char *text, int start, int end)
{
  return rl_completion_matches (text, &command_generator);
}

int main(int argc, char *argv[])
{
  int c,i;

  progname=strrchr(argv[0],'/');
  if (progname==NULL) progname=argv[0];
  else progname++;

  setlocale(LC_ALL, "");
  setlocale(LC_NUMERIC, "C"); /* No "," and such BS for decimal points */
  bindtextdomain(PACKAGE,LOCALEDIR);
  textdomain(PACKAGE);

  while ((c = getopt_long(argc, argv, "hVWL",
                          long_options, (int *) 0)) != EOF) {

    switch (c) {
      case 0  : break;
      case 'h': usage(1); return 0;
      case 'V': fprintf(stderr,_("%s version %s\n"), progname, VERSION);
                return 1;
      case 'W': warranty(); return 1;
      default : break;
    }
  }

  signal(SIGFPE,SIG_IGN); /* ignore floating point exceptions. */

  for(i=0;i<noofconst;i++) {
    vartab[i].vname=consttab[i].vname;
    vartab[i].value=consttab[i].value;
    vartab[i].isconst=1;
  }
  noofvars=noofconst;

  if (argc > optind) {
    short int l;
    char *args=NULL;    /* entire line  */

    l=0; for(i=optind;i<argc;i++) l += (strlen(argv[i])+1);
    args=(char *)xmalloc(l+1);
    strcpy(args, argv[optind]);
    for (i = optind+1; i < argc; i++) {
      strcat(args, " "); strcat(args, argv[i]);
    }

    filename="arguments"; yy_scan_string(args); yyparse();
    showstack();

    free(args); args=NULL;
  } else {
    int interactive=isatty(0);
    char *line;

    initialize_readline(interactive);

    if (interactive) {
      fprintf(stderr,"%s version %s. Copyright (c) 1993-2004 David Frey et. al.\n",
              progname, VERSION);
      fprintf(stderr,_("This is free software with ABSOLUTELY NO WARRANTY.\n"));

      fprintf(stderr, _("For details, type `warranty'.\n"));
      fprintf(stderr, _("Type `quit' to quit and `?' to get a summary.\n"));

      using_history();
    }

    filename="stdin"; done=0;
    while (!done && ((line = readline(NULL)) != NULL)) {

      add_history(line);

      yy_scan_string(line); yyparse();
      showstack();

      free(line); line=NULL;
    }

    if (interactive) {
      remove_history(0);
    }
  }
  return 0;
}
