/*
 * pruebaReal_DQN_types.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "pruebaReal_DQN".
 *
 * Model version              : 1.11
 * Simulink Coder version : 25.2 (R2025b) 28-Jul-2025
 * C source code generated on : Fri Nov 13 14:07:57 2026
 *
 * Target selection: quarc_win64.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef pruebaReal_DQN_types_h_
#define pruebaReal_DQN_types_h_
#include "rtwtypes.h"

/* Custom Type definition for MATLAB Function: '<Root>/ControlDQN' */
#ifndef struct_tag_sIlSV3yMHnSEtj8UJwPQCPE
#define struct_tag_sIlSV3yMHnSEtj8UJwPQCPE

struct tag_sIlSV3yMHnSEtj8UJwPQCPE
{
  real_T W1[512];
  real_T b1[128];
  real_T W2[16384];
  real_T b2[128];
  real_T W3[1152];
  real_T b3[9];
  real_T A[9];
};

#endif                                 /* struct_tag_sIlSV3yMHnSEtj8UJwPQCPE */

#ifndef typedef_sIlSV3yMHnSEtj8UJwPQCPE_prueb_T
#define typedef_sIlSV3yMHnSEtj8UJwPQCPE_prueb_T

typedef struct tag_sIlSV3yMHnSEtj8UJwPQCPE sIlSV3yMHnSEtj8UJwPQCPE_prueb_T;

#endif                             /* typedef_sIlSV3yMHnSEtj8UJwPQCPE_prueb_T */

/* Parameters (default storage) */
typedef struct P_pruebaReal_DQN_T_ P_pruebaReal_DQN_T;

/* Forward declaration for rtModel */
typedef struct tag_RTM_pruebaReal_DQN_T RT_MODEL_pruebaReal_DQN_T;

#endif                                 /* pruebaReal_DQN_types_h_ */
