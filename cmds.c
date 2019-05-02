/************************************************************************
 * cmds.c -- part of rpncalc.c                                          *
 *                                                                      *
 * Refer to rpncalc.c for copyrights and license permissions.           *
 ************************************************************************/

/* $Id: cmds.c,v 1.10 2000/04/02 16:11:05 david Rel $
 * $Log: cmds.c,v $
 * Revision 1.10  2000/04/02 16:11:05  david
 * Declared `pushtostack' extern.
 *
 * Revision 1.9  1999/09/12 20:50:18  david
 * Added constant and variable support.
 * Added ip and fp functions.
 *
 * Revision 1.8  1999/03/06 14:40:17  david
 * Internationalized.
 * Autoconf'ed.
 * New commands: minr, maxr, sign, sr, sr, srb, slb, rdz, rnd,
 *               percent, deltapercent, percenttotal, min, max.
 * Reworked help.
 *
 * Revision 1.7  1998/01/04 16:33:16  david
 * Replaced platform specific ifdefs with  HAVE_xxx. Includedd <errno.h>
 * instead of giving 'extern int errno;' directly.
 *
 * Revision 1.7  1998/01/03 23:16:56  david
 * Changed the system-based #ifdefs to HAVE_xxx ifdefs.
 *
 * Revision 1.6  1997/09/11 21:21:01  david
 * libc6: pow10 and pow2 are gone; use our own definitions.
 *
 * Revision 1.5  1997/01/19 20:01:18  david
 * FreeBSD `port': Added #define EOVERFLOW ERANGE.
 *
 * Revision 1.4  1997/01/19 18:49:47  david
 * Removed some casts to make gcc -Wall -W... happy.
 *
 * Revision 1.4  1997/01/19 18:19:23  david
 * Removed some casts to make gcc -Wall -W... happy.
 *
 * Revision 1.2  1996/09/13 20:21:29  david
 * lclint additions
 *
 * Revision 1.1  1996/07/13 20:49:35  david
 * Cleanup and renaming due to linting of the source.
 *
 * Revision 1.0  1995/12/31 18:21:07  david
 * Initial revision
 * */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include <float.h>
#include <errno.h>

#include "stack.h"
#include "cmds.h"

#include <libintl.h>

#define  _(String) gettext(String)

extern struct cmd cmdtab[];

extern int noofcmds;
extern int done;
extern int pushtostack;

struct cnst consttab[] =
{
  { "e"   , M_E    , "Euler's constant"     },
  { "minr", FLT_MIN, "smallest real number" },
  { "maxr", FLT_MAX, "largest real number"  },
  { "pi"  , M_PI   , "the constant pi"      }
};

const size_t noofconst=sizeof(consttab) / sizeof(consttab[0]);

static double res;

/* -------------------------------------------- compare function for cmdtab */

int cmdcmp(const void *f1, const void *f2)
/* (String-)Compare the two function names, cf. iX 11/95 p 212 */
{
  return strcmp(((const struct cmd *)f1)->fname,
                ((const struct cmd *)f2)->fname);
}

int varcmp(const void *f1, const void *f2)
/* (String-)Compare the two variable names, cf. iX 11/95 p 212 */
{
  if ((f1 == NULL) && (f2 == NULL)) return 0;
  else if ((f1 == NULL) && (f2 != NULL)) return  1;
  else if ((f1 != NULL) && (f2 == NULL)) return -1;
  else
    return strcmp(((const struct var *)f1)->vname,
                  ((const struct var *)f2)->vname);
}

/* -------------------------------------------------------- unary operators */
#ifndef EOVERFLOW
#define EOVERFLOW ERANGE
#endif

double chs(double f)   { return -f; }

double sqr(double f)   { return f * f; }

double sign(double f)   {
  double s;
  if      (f <  0.0) s=-1.0;
  else if (f == 0.0) s= 0.0;
  else               s=+1.0;

  return s;
}

double inv(double f)
{
  if (f != 0)   res = 1 / f;
  else          { res = HUGE_VAL; errno = ERANGE; }
  return res;
}

double ip(double f)    { return sign(f)*floor(abs(f)); }

double fp(double f)    { return f-ip(f); }

double fact(double d)
{
  long int i, n;

  n=(long int)d;
  if (n < 0) {
    fprintf(stderr, _("defined only for arguments >= 0.\n"));
    pushtostack=0;
  } else if (n == d) {
    if ((n == 0) || (n == 1)) {
      res = 1;
    } else {
      res = 1;
      for (i = n; i > 1; i--) res *= i;
    }
  } else {
    res=exp(gamma(d+1.0));
  }
  return res;
}

double not(double l) { return (double)(~(long int)l); }

double sr(double l)  { return (double)((long int)l >> 1); }
double sl(double l)  { return (double)((long int)l << 1); }

double srb(double l) { return (double)((long int)l >> 8); }
double slb(double l) { return (double)((long int)l << 8); }

double rdz(double s) { srand(s); return 0.0; /* dummy value */ }

/* ------------------------------------------------------- binary operators */

double plus(double s1, double s2) { return s1 + s2; }

double minus(double s, double m)  { return  s-m; }

double multiply(double f1, double f2) { return f1 * f2; }

double divide(double n, double d)
{
  if (d != 0) res = n / d;
  else      { res = HUGE_VAL; errno = ERANGE; }
  return res;
}

static ldiv_t quotrem;

double idiv(double dn, double dd)
{
  long int n, d;

  n=(long int)dn; d=(long int)dd;
  if ((n <= LONG_MAX) && (d <= LONG_MAX))
  {
    if (d != 0)
    {
      quotrem = ldiv(n,d);
      res = (double)quotrem.quot;
    }
    else
    {
      res = HUGE_VAL; errno = ERANGE;
    }
  }
  else
  {
    errno = EOVERFLOW; pushtostack=0;
  }
  return res;
}

double mod(double dn, double dd)
{
 long int n, d;

 n=(long int)dn; d=(long int)dd;
 if ((n <= LONG_MAX) && (d <= LONG_MAX))
 {
   if (d != 0)
   {
     quotrem = ldiv(n,d);
     res = (double)quotrem.rem;
   }
   else
   {
     res = HUGE_VAL; errno = ERANGE;
   }
 }
 else
 {
   errno = EOVERFLOW; pushtostack=0;
 }
 return res;
}

/* Stein's Greatest Common Divisor (GCD) algorithm */
long int stein(double d1, double d2)
{
  long int n1, n2;
  long int d;                            /* difference */
  long int c;                            /* c: shift-count (see below) */
  long int t;                            /* temporary */

  c = 0; n1=(long int)d1; n2=(long int)d2;
  /* both integers are even; shift them until one gets odd. */
  while (((n1 & 1) == 0) && ((n2 & 1) == 0))
  {
    n1 >>= 1; n2 >>= 1;  c++;
  }

  do
  {
    if ((n2 & 1) == 0) { t = n1; n1 = n2; n2 = t; }

    while ((n1 & 1) == 0)
      n1 >>= 1;

    /*
     * shift n1 until it gets odd.
     */
    d = n1 - n2;
    if (d < 0) { n2 = n1; d = -d; }
    n1 = d >> 1;
  }
  while (n1 > 0);

  return (n2 * (1 << c));
}

double gcd(double dn, double dd)
{
  long int n, d;

  n=(long int)dn; d=(long int)dd;
  if ((n <= LONG_MAX) && (d <= LONG_MAX))
  {
    if (d != 0) res = stein(dn,dd);
    else      { res = HUGE_VAL; errno = ERANGE; }
  }
  else
  {
    errno = EOVERFLOW;
    pushtostack = 0;
  }
  return res;
}

double and(double l1, double l2)
{
  return (double)((long int)l1 & (long int)l2);
}

double or(double l1, double l2)
{
  return (double)((long int)l1 | (long int)l2);
}

double xor(double l1, double l2)
{
  return (double)((long int)l1 ^ (long int)l2);
}

double percent(double x, double y)
{
  return (double)(x*y/100.0);
}

double deltapercent(double x, double y)
{
  return (double)(100.0*(y-x)/x);
}

double percenttotal(double x, double y)
{
  return (double)(100.0*y/x);
}

double min(double x, double y)
{
  if (x < y) return x;
  else       return y;
}

double max(double x, double y)
{
  if (x < y) return x;
  else       return y;
}

/* ------------------------------------------------------- n-ary operators */
double sum(void)
{
  long int i,n;

  n = depth(); res = 0;
  for(i=1;i<=n;i++) res += pick((double)i);
  return res;
}

double prod(void)
{
  long int i,n;

  n = depth(); res = 1;
  for(i=1;i<=n;i++) res *= pick((double)i);
  return res;
}

double quit(void)
{
  done=1;
  return 0.0;
}

/* ------------------------------------------------------- 0-ary operators */
double help(struct cmd *f)
{
  if (f != NULL) {
    printf("%s. ",gettext(f->helptext));

    if (f->pushrestostack) {
      printf(_("`%s' is a function"), f->fname);
    } else {
      printf(_("`%s' is a command") , f->fname);
    }

    if (f->pushrestostack) {
      if (f->argno == 1)
        printf(_(" and takes 1 argument"));
      else
        printf(_(" and takes %d arguments"),f->argno);
    }
    printf(".\n");
  } else {
    int i;

    printf(_("The following operations and constants are recognized:\n\n"));
    printf(" ");

    i=0;
    while(i < noofcmds) {
      printf("%s%*c",cmdtab[i].fname,9-(int)strlen(cmdtab[i].fname),' ');
      if ((i % 8) == 7) printf("\n ");
      i++;
    }
    printf("\n\n");
    printf(_("Delimiters are ',', ';', space, tab, and newline.\n"));
  }
  return 0.0; /* dummy value */
}

double warranty(void)
{
  const char copyright[] = "\
This program is free software; you can redistribute it and/or modify\n\
it under the terms of the GNU General Public License as published by\n\
the Free Software Foundation; either version 2 of the License, or\n\
(at your option) any later version.\n\
\n\
This program is distributed in the hope that it will be useful,\n\
but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n\
GNU General Public License for more details.\n\
\n\
You should have received a copy of the GNU General Public License\n\
along with this program; if not, write to the Free Software Foundation,\n\
Inc., 59 Temple Place Suite 330, Boston, MA 02111-1307 USA.\n";

  printf(copyright);
  return 0.0; /* dummy value */
}

double rnd(void) { return (double)(rand()/(RAND_MAX+1.0)); }
