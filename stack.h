/************************************************************************
 * stack.h -- part of rpncalc.c						*
 *									*
 * Refer to rpncalc.c for copyrights and license permissions.           *
 ************************************************************************/

/* $Id: stack.h,v 1.4 2000/04/02 16:13:01 david Rel david $
 * $Log: stack.h,v $
 * Revision 1.4  2000/04/02 16:13:01  david
 * Removed declaration of pushtostack.
 *
 * Revision 1.3  1999/03/06 14:41:44  david
 * Added new commands.
 *
 * Revision 1.2  1997/01/19 18:56:40  david
 * Declaration of all stack related functions.
 *
 * Revision 1.1  1997/01/19 18:19:23  david
 * Initial revision
 *
 */

struct elm
{
  double value;
  struct elm *prev, *next;
};

enum BASE { DEC, HEX, OCT, CHAR, BIN }; /* current base (dec,oct..) */

double push(double elem);
double pop(void);
double pick(double op1);
double drop(void);
double drop2(void);
double dropn(double n);
double dupel(double d);
double dupel2(double d);
double dupn(double n, double d);
double clear(void);
double over(void);
double depth(void);
double swap(void);
double rot(void);
double showstack(void);
double sethex(void);
double setdec(void);
double setoct(void);
double setchar(void);
double setbin(void);

double prec(double p);
