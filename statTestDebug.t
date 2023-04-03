#charset "us-ascii"
//
// statTestDebug.t
//
#include <adv3.h>
#include <en_us.h>

#ifdef __DEBUG_STAT_TEST

modify StatTestObject
	_debug(msg?) { aioSay('\n<<(svc ? '<<svc>>: ' : '')>><<msg>>\n '); }
;

#endif // __DEBUG_STAT_TEST
