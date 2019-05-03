/************************************************************************
 * cmds.h -- part of rpncalc.c						*
 *									*
 * Refer to rpncalc.c for copyrights and license permissions.           *
 ************************************************************************/

/* $Id: cmds.h,v 1.8 2000/04/02 16:11:21 david Rel david $
 * $Log: cmds.h,v $
 * Revision 1.8  2000/04/02 16:11:21  david
 * Removed function prototype typedef and moved function prototype direct
 * into struct cmd.
 *
 * Revision 1.7  1999/09/12 20:50:49  david
 * Added constant and variable tables instead of functions.
 * Added ip and fp.
 *
 * Revision 1.6  1999/03/06 14:41:20  david
 * Added new commands.
 *
 * Revision 1.5  1997/09/11 21:21:01  david
 * libc6: pow10 and pow2 are gone; use our own definitions.
 *
 * Revision 1.4  1997/01/19 18:50:45  david
 * Declarations for cmds.c
 *
 * Revision 1.4  1997/01/19 18:19:23  david
 * Provided all declarations.
 *
 * Revision 1.2  1996/09/13 20:21:29  david
 * lclint additions
 *
 * Revision 1.1  1996/07/13 20:49:35  david
 * Cleanup and renaming due to linting of the source.
 *
 * Revision 1.0  1995/12/31 18:16:22  david
 * Initial revision
 *
 */

#include <math.h>

double rnd(void);

double exp10(double y);
double chs(double f);
double sign(double f);
double sqr(double f);
double inv(double f);
double ip(double f);
double log2(double f);
double fact(double d);
double fp(double f);
double prec(double p);
double not(double l);
double sr(double l);
double sl(double l);
double srb(double l);
double slb(double l);

double rdz(double s);

double plus(double s1, double s2);
double minus(double s, double m);
double multiply(double f1, double f2);
double divide(double n, double d);

double idiv(double dn, double dd);

double mod(double dn, double dd);
long int stein(double d1, double d2);
double gcd(double dn, double dd);
double and(double l1, double l2);
double or(double l1, double l2);
double xor(double l1, double l2);

double percent(double x, double y);
double deltapercent(double x, double y);
double percenttotal(double x, double y);

double min(double x, double y);
double max(double x, double y);

double sum(void);
double prod(void);

struct cmd {
  const char *fname;
  const short argno;     /* 0..2: no of arguments */
  short pushrestostack;
  double (*fnct)();
  const char  *helptext;
};

struct cnst {
  const char   *vname;
  const double  value;
  const char   *helptext;
};

struct var {
  const char   *vname;
  double  value;
  int   isconst;
};

const size_t noofconst;

size_t noofvars;
const size_t maxnoofvars;

double help(struct cmd *f);
double warranty(void);
double quit(void);

int cmdcmp(const void *f1, const void *f2);
int varcmp(const void *f1, const void *f2);
