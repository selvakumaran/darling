#define __SYSCALL_32BIT_ARG_BYTES 12
#include "SYS.h"

#ifndef SYS_mkdirat
#error "SYS_mkdirat not defined. The header files libsyscall is building against do not match syscalls.master."
#endif

#if defined(__x86_64__)
__SYSCALL2(mkdirat, mkdirat, 3, cerror_nocancel)
#endif

