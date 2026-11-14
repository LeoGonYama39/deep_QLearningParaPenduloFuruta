/*
 * pruebaReal_DQN_data.c
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "pruebaReal_DQN".
 *
 * Model version              : 1.10
 * Simulink Coder version : 25.2 (R2025b) 28-Jul-2025
 * C source code generated on : Fri Nov 13 14:05:34 2026
 *
 * Target selection: grt.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "pruebaReal_DQN.h"

/* Block parameters (default storage) */
P_pruebaReal_DQN_T pruebaReal_DQN_P = {
  /* Mask Parameter: HILWrite_analog_channels
   * Referenced by: '<S3>/HIL Write'
   */
  0U,

  /* Mask Parameter: HILWrite_other_channels
   * Referenced by: '<S3>/HIL Write'
   */
  { 11000U, 11001U, 11002U },

  /* Expression: set_other_outputs_at_terminate
   * Referenced by: '<S3>/HIL Initialize'
   */
  1.0,

  /* Expression: set_other_outputs_at_switch_out
   * Referenced by: '<S3>/HIL Initialize'
   */
  0.0,

  /* Expression: final_analog_outputs
   * Referenced by: '<S3>/HIL Initialize'
   */
  0.0,

  /* Expression: final_pwm_outputs
   * Referenced by: '<S3>/HIL Initialize'
   */
  0.0,

  /* Expression: final_other_outputs
   * Referenced by: '<S3>/HIL Initialize'
   */
  { 1.0, 0.0, 0.0 },

  /* Expression: -2*pi/(512*4)
   * Referenced by: '<S2>/Arm: counts to rad'
   */
  -0.0030679615757712823,

  /* Expression: 2*pi/(512*4)
   * Referenced by: '<S2>/alpha_raw'
   */
  0.0030679615757712823,

  /* Expression: -1
   * Referenced by: '<Root>/Gain'
   */
  -1.0,

  /* Expression: [0, 0, 0]
   * Referenced by: '<Root>/Constant'
   */
  { 0.0, 0.0, 0.0 },

  /* Computed Parameter: HILReadTimebase_Clock
   * Referenced by: '<S3>/HIL Read Timebase'
   */
  0,

  /* Computed Parameter: HILReadTimebase_SamplesInBuffer
   * Referenced by: '<S3>/HIL Read Timebase'
   */
  1000U,

  /* Computed Parameter: HILReadTimebase_AnalogChannels
   * Referenced by: '<S3>/HIL Read Timebase'
   */
  0U,

  /* Computed Parameter: HILReadTimebase_EncoderChannels
   * Referenced by: '<S3>/HIL Read Timebase'
   */
  { 0U, 1U },

  /* Computed Parameter: HILReadTimebase_DigitalChannels
   * Referenced by: '<S3>/HIL Read Timebase'
   */
  1U,

  /* Computed Parameter: HILReadTimebase_OtherChannels
   * Referenced by: '<S3>/HIL Read Timebase'
   */
  { 14000U, 14001U },

  /* Computed Parameter: HILInitialize_Active
   * Referenced by: '<S3>/HIL Initialize'
   */
  true,

  /* Computed Parameter: HILInitialize_AOTerminate
   * Referenced by: '<S3>/HIL Initialize'
   */
  true,

  /* Computed Parameter: HILInitialize_AOExit
   * Referenced by: '<S3>/HIL Initialize'
   */
  false,

  /* Computed Parameter: HILInitialize_DOTerminate
   * Referenced by: '<S3>/HIL Initialize'
   */
  true,

  /* Computed Parameter: HILInitialize_DOExit
   * Referenced by: '<S3>/HIL Initialize'
   */
  false,

  /* Computed Parameter: HILInitialize_POTerminate
   * Referenced by: '<S3>/HIL Initialize'
   */
  false,

  /* Computed Parameter: HILInitialize_POExit
   * Referenced by: '<S3>/HIL Initialize'
   */
  false,

  /* Computed Parameter: HILInitialize_DOFinal
   * Referenced by: '<S3>/HIL Initialize'
   */
  false,

  /* Computed Parameter: HILReadTimebase_Active
   * Referenced by: '<S3>/HIL Read Timebase'
   */
  true,

  /* Expression: false
   * Referenced by: '<Root>/ARMAR'
   */
  false,

  /* Computed Parameter: HILWrite_Active
   * Referenced by: '<S3>/HIL Write'
   */
  false,

  /* Computed Parameter: HILReadTimebase_OverflowMode
   * Referenced by: '<S3>/HIL Read Timebase'
   */
  1U
};
