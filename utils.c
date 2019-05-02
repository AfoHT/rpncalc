/************************************************************************
 * utils.c -- various utilities for rpncalc				*
 *									*
 * Refer to rpncalc.c for copyrights and license permissions.           *
 ************************************************************************/

/* $Id: utils.c,v 1.6 1999/03/06 14:35:17 david Rel david $
 * $Log: utils.c,v $
 * Revision 1.6  1999/03/06 14:35:17  david
 * Internationalized.
 * Removed lint comments.
 *
 * Revision 1.5  1998/01/03 22:57:39  david
 * replaced HAVE_READLINE with HAVE_LIBREADLINE (for autoconf)
 *
 * Revision 1.4  1997/01/19 18:58:58  david
 * Changed dupstr(char *) to dupstr(const char *)
 *
 * Revision 1.4  1997/01/19 18:19:23  david
 * Changed dupstr(char *) to dupstr(const char *)
 *
 * Revision 1.2  1996/09/13 20:21:29  david
 * lclint additions
 *
 * Revision 1.1  1996/07/13 20:58:36  david
 * Added dupstr()
 * Moved getline() from rpncalc.c into utils.c
 *
 * Revision 1.0  1995/12/31 18:19:34  david
 * Initial revision
 *
 * Revision 1.0  1995/11/25 20:02:25  david
 * Initial revision
 * */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "utils.h"

#include <readline/readline.h>
#include <readline/history.h>

#include <libintl.h>

#define _(String) gettext(String)

#define LINEFRAGMENT 32

void *xmalloc(size_t size)	/* safe malloc */
{
  void *ptr;

  ptr=malloc(size);
  if (ptr == NULL) {
    perror(_("Out of memory!"));
    exit(1);
  }

  return ptr;
}

void *xrealloc(void *ptr, size_t size)	/* save realloc */
{
  ptr=realloc(ptr, size);
  if (ptr == NULL) {
    perror(_("Out of memory!"));
    exit(1);
  }

  return ptr;
}

char *xstrdup(const char *s)
{
  char *r;

  r = (char *)xmalloc (strlen (s) + 1);
  strcpy (r, s);
  return (r);
}
