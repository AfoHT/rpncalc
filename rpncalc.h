#ifndef RPNCALC_H
#define RPNCALC_H

/************************************************************************
 * rpncalc.h								*
 *									*
 * Refer to rpncalc.c for copyrights and license permissions.           *
 ************************************************************************/

/* $Id: rpncalc.h,v 1.3 1997/01/19 19:00:59 david Rel $
 * $Log: rpncalc.h,v $
 * Revision 1.3  1997/01/19 19:00:59  david
 * Provided all declarations of all functions and moved cmdtab[] into rpncalc.c
 *
 * Revision 1.3  1997/01/19 18:19:23  david
 * Provided all declarations; moved cmdtab into rpncalc.c
 *
 * Revision 1.1  1996/07/13 20:54:40  david
 * Added operator completion prototypes; renaming of times due to linting.
 * ,
 *
 * Revision 1.0  1995/12/31 18:18:10  david
 * Initial revision
 *
 * Revision 1.0  1995/12/31 18:17:22  david
 * Initial revision
 *
 * Revision 1.2  1995/11/25 21:59:51  david
 * Cleaned up the cmd table. The stack operations have now the right
 * value in the cmd->argno field; even at the expense of superfluous
 * push/pops, unfortunately.
 * */


char *command_generator(const char *text, int state);
char **rpncalc_completion(const char *text, int start, int end);
void initialize_readline(int interactive);

#endif