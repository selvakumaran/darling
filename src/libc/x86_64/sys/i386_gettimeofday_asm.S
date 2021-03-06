// Modified by Lubos Dolezel for Darling
/*
 * Copyright (c) 2003-2007 Apple Inc. All rights reserved.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 * 
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */

#include <sys/appleapiopts.h>
#include <machine/cpu_capabilities.h>
#include "platfunc.h"

#ifdef DARLING
#	define _mach_absolute_time mach_absolute_time@PLT
#endif

#define NSEC_PER_SEC	1000*1000*1000
#define NSEC_PER_USEC	1000

#ifndef DARLING
	.private_extern ___commpage_gettimeofday
#else
#	define ___commpage_gettimeofday __commpage_gettimeofday
#endif
	.align 1<<4
___commpage_gettimeofday:
// %rdi = ptr to timeval
	pushq	%rbp			// set up a frame for backtraces
	pushq	%r12			// push callee-saved registers we want to use
	pushq	%r13
	pushq	%r14
	subq	$8, %rsp
	movq	%rsp,%rbp
	movq	%rdi,%r12		// save ptr to timeval
	
#ifndef DARLING
	movq	$(_COMM_PAGE_TIME_DATA_START),%r13
0:
	movl	_GTOD_GENERATION(%r13),%r14d	// get generation (0 if disabled)
	testl	%r14d,%r14d		// disabled?
	jz	4f
#endif

	call	_mach_absolute_time	// get %rax <- nanotime()

#ifndef DARLING
	movl	_GTOD_SEC_BASE(%r13),%r8d	// get _COMM_PAGE_TIMESTAMP
	subq	_GTOD_NS_BASE(%r13),%rax	// generate nanoseconds since timestamp
	cmpl	_GTOD_GENERATION(%r13),%r14d	// has data changed out from under us?
	jne	0b
#endif
	
	movl	$ NSEC_PER_SEC,%ecx
	movq	%rax,%rdx
	shrq	$32,%rdx		// get high half of delta in %edx
	divl	%ecx			// %eax <- seconds since timestamp, %edx <- nanoseconds
	addl	%eax,%r8d		// add seconds elapsed to timestamp seconds

	movl	$ NSEC_PER_USEC,%ecx
	movl	%edx,%eax
	xorl	%edx,%edx
	divl	%ecx			// divide residual ns by 1000 to get residual us in %eax
	
	movq	%r8,(%r12)		// store 64-bit seconds into timeval
	movl	%eax,8(%r12)		// store 32-bit useconds into timeval
	xorl	%eax,%eax		// return 0 for success
3:
	addq	$8, %rsp
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rbp
	ret
4:					// fail
	movl	$1,%eax
	jmp	3b
