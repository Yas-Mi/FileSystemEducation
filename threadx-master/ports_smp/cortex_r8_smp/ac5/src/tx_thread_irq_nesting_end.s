/***************************************************************************
 * Copyright (c) 2024 Microsoft Corporation 
 * 
 * This program and the accompanying materials are made available under the
 * terms of the MIT License which is available at
 * https://opensource.org/licenses/MIT.
 * 
 * SPDX-License-Identifier: MIT
 **************************************************************************/


/**************************************************************************/
/**************************************************************************/
/**                                                                       */
/** ThreadX Component                                                     */
/**                                                                       */
/**   Thread                                                              */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/
    IF  :DEF:TX_ENABLE_FIQ_SUPPORT
DISABLE_INTS    EQU     0xC0                    // Disable IRQ & FIQ interrupts
    ELSE
DISABLE_INTS    EQU     0x80                    // Disable IRQ interrupts
    ENDIF
MODE_MASK       EQU     0x1F                    // Mode mask
IRQ_MODE_BITS   EQU     0x12                    // IRQ mode bits

    AREA ||.text||, CODE, READONLY
/**************************************************************************/
/*                                                                        */
/*  FUNCTION                                               RELEASE        */
/*                                                                        */
/*    _tx_thread_irq_nesting_end                      SMP/Cortex-R8/ARM   */
/*                                                           6.2.0        */
/*  AUTHOR                                                                */
/*                                                                        */
/*    Scott Larson, Microsoft Corporation                                 */
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    This function is called by the application from IRQ mode after      */
/*    _tx_thread_irq_nesting_start has been called and switches the IRQ   */
/*    processing from system mode back to IRQ mode prior to the ISR       */
/*    calling _tx_thread_context_restore.  Note that this function        */
/*    assumes the system stack pointer is in the same position after      */
/*    nesting start function was called.                                  */
/*                                                                        */
/*    This function assumes that the system mode stack pointer was setup  */
/*    during low-level initialization (tx_initialize_low_level.s).        */
/*                                                                        */
/*    This function returns with IRQ interrupts disabled.                 */
/*                                                                        */
/*  INPUT                                                                 */
/*                                                                        */
/*    None                                                                */
/*                                                                        */
/*  OUTPUT                                                                */
/*                                                                        */
/*    None                                                                */
/*                                                                        */
/*  CALLS                                                                 */
/*                                                                        */
/*    None                                                                */
/*                                                                        */
/*  CALLED BY                                                             */
/*                                                                        */
/*    ISRs                                                                */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  10-31-2022      Scott Larson            Initial Version 6.2.0         */
/*                                                                        */
/**************************************************************************/
// VOID   _tx_thread_irq_nesting_end(VOID)
// {
    EXPORT  _tx_thread_irq_nesting_end
_tx_thread_irq_nesting_end
    MOV     r3,lr                               // Save ISR return address
    MRS     r0, CPSR                            // Pickup the CPSR
    ORR     r0, r0, #DISABLE_INTS               // Build disable interrupt value
    MSR     CPSR_c, r0                          // Disable interrupts
    LDMIA   sp!, {lr, r1}                       // Pickup saved lr (and r1 throw-away for
                                                //   8-byte alignment logic)
    BIC     r0, r0, #MODE_MASK                  // Clear mode bits
    ORR     r0, r0, #IRQ_MODE_BITS              // Build IRQ mode CPSR
    MSR     CPSR_c, r0                          // Re-enter IRQ mode
    IF  {INTER} = {TRUE}
    BX      r3                                  // Return to caller
    ELSE
    MOV     pc, r3                              // Return to caller
    ENDIF
// }
    END

