/* gpibwrite.c                                                                      														*/
/*                                                                                  														*/
/* 21-Feb-2003	          																													*/

#define WIN32

#include "mex.h"
#include <sicl.h>

INST instrument;

void mexFunction (int n_lhs, mxArray *p_lhs[], int n_rhs, const mxArray *p_rhs[])
{   
	char dev_id[80];																														/* gpib device name */
 	char buff[1024];																														/* buffer where the string to be written is stored */
	char err_buff[160];
  	double term_chr;
	
 	/* the following lines are needed to the Borland compiler : do not remove !!!															*/
	#if defined(__BORLANDC__) && !defined(__WIN32__)
	_InitEasyWin ();
	#endif

	if (n_rhs!=2 && n_rhs!=3) mexErrMsgTxt ("wrong number of arguments - check documentation");												/* parsing of the parameters */
	if (!mxIsChar(p_rhs[0])) mexErrMsgTxt ("the first argument must be a string - check documentation");
	if (!mxIsChar(p_rhs[1])) mexErrMsgTxt ("the second argument must be a string - check documentation");
	mxGetString (p_rhs[0], dev_id, 80);
 	instrument = iopen (dev_id);																											/* open the channel */
	if (instrument==0) {
 		sprintf (err_buff, "error while opening the device <%s>", dev_id);
   		mexErrMsgTxt (err_buff);
	}
	if (n_rhs==3) {
 		if (!mxIsDouble(p_rhs[2])) mexErrMsgTxt ("the third argument must be a double - check documentation");
 		else {
 			term_chr = mxGetScalar (p_rhs[2]);
 			itermchr (instrument, term_chr);
 		}
	}	
	mxGetString (p_rhs[1], buff, 1024);
	iprintf (instrument, buff);
	iclose (instrument);
}
