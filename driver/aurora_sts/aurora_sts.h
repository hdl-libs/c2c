// ---------------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ---------------------------------------------------------------------------------------

/**
 * @file aurora_sts.h
 * @brief
 * @author
 */

/******************************************************************************/
/************************ Copyright *******************************************/
/******************************************************************************/

#ifndef _AURORA_STS_H_
#define _AURORA_STS_H_

/******************************************************************************/
/************************ Include Files ***************************************/
/******************************************************************************/

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C"
{
#endif
    /******************************************************************************/
    /************************ Marco Definitions ***********************************/
    /******************************************************************************/

#define FPGA_ADDR_AURORA_STS_ID (0x0000U)
#define FPGA_ADDR_AURORA_STS_RESET (0x0004U)
#define FPGA_ADDR_AURORA_STS_STATE (0x0008U)

    /******************************************************************************/
    /************************ Types Definitions ***********************************/
    /******************************************************************************/
    typedef union
    {
        struct
        {
            uint32_t reset_pb : 1;
            uint32_t pma_reset : 1;
            uint32_t global_reset : 1;
            uint32_t : 29;
        };
        uint32_t all;
    } aurora_sts_reset_t;

    typedef union
    {
        struct
        {
            uint32_t lane_up : 4;       // 1111
            uint32_t channel_up : 1;    // 1
            uint32_t soft_err : 1;      // 0
            uint32_t hard_err : 1;      // 0
            uint32_t gt_pll_lock : 1;   // 1
            uint32_t mmcm_not_lock : 1; // 0
            uint32_t : 23;
        };
        uint32_t all;
    } aurora_sts_state_t;

    typedef struct
    {
        uint32_t id;              // 0x0000
        aurora_sts_state_t state; // 0x0004
        aurora_sts_reset_t reset; // 0x0008
    } aurora_sts_t;

    /******************************************************************************/
    /************************ Functions Declarations ******************************/
    /******************************************************************************/
    extern int32_t aurora_sts_init(aurora_sts_t **handler, uint32_t addr);

#ifdef __cplusplus
}
#endif

#endif // __AURORA_STS_H__
