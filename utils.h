/************************************************************************
 * utils.h -- various utilities for rpncalc				*
 *									*
 * Refer to rpncalc.c for copyrights and license permissions.           *
 ************************************************************************/

/* $Id: utils.h,v 1.6 2000/04/02 16:13:19 david Rel $
 * $Log: utils.h,v $
 * Revision 1.6  2000/04/02 16:13:19  david
 * Added conditional #ifdef HAVE_READLINE to prototype readline.
 *
 * Revision 1.5  1999/03/06 14:31:06  david
 * Deleted the lint-comments.
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
 * Added dupstr() and getline() prototypes.
 *
 * Revision 1.0  1995/12/31 18:20:14  david
 * Initial revision
 *
 * Revision 1.0  1995/11/25 18:50:11  david
 * Initial revision
 * */

void *xmalloc(size_t size);
void *xrealloc(void *ptr, size_t size);
char *xstrdup(const char *s);
