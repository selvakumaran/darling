#define __SYSCALL_32BIT_ARG_BYTES 8
#include "SYS.h"

#ifndef SYS_shutdown
#error "SYS_shutdown not defined. The header files libsyscall is building against do not match syscalls.master."
#endif

#if defined(__i386__)
__SYSCALL2(shutdown, shutdown, 2, cerror_nocancel)
#endif

