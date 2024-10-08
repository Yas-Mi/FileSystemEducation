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


#define TX_SOURCE_CODE
#define TX_THREAD_SMP_SOURCE_CODE


/* Include necessary system files.  */

#include "tx_api.h"
#include "tx_thread.h"
#include "tx_timer.h"


/**************************************************************************/
/*                                                                        */
/*  FUNCTION                                               RELEASE        */
/*                                                                        */
/*    _tx_thread_smp_current_state_get                  SMP/Linux/GCC     */
/*                                                           6.1          */
/*  AUTHOR                                                                */
/*                                                                        */
/*    William E. Lamie, Microsoft Corporation                             */
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    This function is gets the current state of the calling core.        */
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
/*    pthread_self                          Get Linux thread ID           */
/*    _tx_linux_mutex_obtain                                              */
/*    _tx_linux_mutex_release                                             */
/*                                                                        */
/*  CALLED BY                                                             */
/*                                                                        */
/*    ThreadX Components                                                  */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  09-30-2020     William E. Lamie         Initial Version 6.1           */
/*                                                                        */
/**************************************************************************/
ULONG  _tx_thread_smp_current_state_get(void)
{

UINT        core;
UINT        i;
ULONG       current_state;
pthread_t   thread_id;


    /* Lock Linux mutex.  */
    _tx_linux_mutex_obtain(&_tx_linux_mutex);

    /* Default to core 0 for ISRs and initialization.  */
    core =  0;

    /* Pickup the currently executing thread ID. */
    thread_id =  pthread_self();

    /* Loop through mapping table to find the core running this thread ID.  */
    for (i = 0; i < TX_THREAD_SMP_MAX_CORES; i++)
    {

        /* Does this core match?  */
        if (_tx_linux_virtual_cores[i].tx_thread_smp_core_mapping_linux_thread_id == thread_id)
        {

            /* Yes, we have a match.  */
            core =  i;

            /* Get out of loop.  */
            break;
        }
    }

    /* Pickup the current state.  */
    current_state =  _tx_thread_system_state[core];

    /* Unlock linux mutex. */
    _tx_linux_mutex_release(&_tx_linux_mutex);

    /* Now return the state for the core.  */
    return(current_state);
}



