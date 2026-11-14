/*
 * pruebaReal_DQN_dt.h
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

#include "ext_types.h"

/* data type size table */
static uint_T rtDataTypeSizes[] = {
  sizeof(real_T),
  sizeof(real32_T),
  sizeof(int8_T),
  sizeof(uint8_T),
  sizeof(int16_T),
  sizeof(uint16_T),
  sizeof(int32_T),
  sizeof(uint32_T),
  sizeof(boolean_T),
  sizeof(fcn_call_T),
  sizeof(int_T),
  sizeof(pointer_T),
  sizeof(action_T),
  2*sizeof(uint32_T),
  sizeof(int32_T),
  sizeof(sIlSV3yMHnSEtj8UJwPQCPE_prueb_T),
  sizeof(t_card),
  sizeof(t_task),
  sizeof(t_boolean),
  sizeof(uint_T),
  sizeof(char_T),
  sizeof(uchar_T),
  sizeof(time_T)
};

/* data type name table */
static const char_T * rtDataTypeNames[] = {
  "real_T",
  "real32_T",
  "int8_T",
  "uint8_T",
  "int16_T",
  "uint16_T",
  "int32_T",
  "uint32_T",
  "boolean_T",
  "fcn_call_T",
  "int_T",
  "pointer_T",
  "action_T",
  "timer_uint32_pair_T",
  "physical_connection",
  "sIlSV3yMHnSEtj8UJwPQCPE_prueb_T",
  "t_card",
  "t_task",
  "t_boolean",
  "uint_T",
  "char_T",
  "uchar_T",
  "time_T"
};

/* data type transitions for block I/O structure */
static DataTypeTransition rtBTransitions[] = {
  { (char_T *)(&pruebaReal_DQN_B.Gain), 0, 0, 5 },

  { (char_T *)(&pruebaReal_DQN_B.estado), 3, 0, 1 },

  { (char_T *)(&pruebaReal_DQN_B.nuevaAccion), 8, 0, 1 }
  ,

  { (char_T *)(&pruebaReal_DQN_DW.P), 15, 0, 1 },

  { (char_T *)(&pruebaReal_DQN_DW.HILInitialize_FilterFrequency[0]), 0, 0, 10 },

  { (char_T *)(&pruebaReal_DQN_DW.HILInitialize_Card), 16, 0, 1 },

  { (char_T *)(&pruebaReal_DQN_DW.HILReadTimebase_Task), 17, 0, 1 },

  { (char_T *)(&pruebaReal_DQN_DW.HILWrite_PWORK), 11, 0, 5 },

  { (char_T *)(&pruebaReal_DQN_DW.HILInitialize_ClockModes), 6, 0, 10 },

  { (char_T *)(&pruebaReal_DQN_DW.muestras), 5, 0, 1 },

  { (char_T *)(&pruebaReal_DQN_DW.contador), 3, 0, 1 },

  { (char_T *)(&pruebaReal_DQN_DW.doneDoubleBufferReInit), 8, 0, 18 },

  { (char_T *)(&pruebaReal_DQN_DW.HILReadTimebase_DigitalBuffer), 18, 0, 1 }
};

/* data type transition table for block I/O structure */
static DataTypeTransitionTable rtBTransTable = {
  13U,
  rtBTransitions
};

/* data type transitions for Parameters structure */
static DataTypeTransition rtPTransitions[] = {
  { (char_T *)(&pruebaReal_DQN_P.HILWrite_analog_channels), 7, 0, 4 },

  { (char_T *)(&pruebaReal_DQN_P.HILInitialize_OOTerminate), 0, 0, 31 },

  { (char_T *)(&pruebaReal_DQN_P.HILInitialize_CKChannels), 6, 0, 8 },

  { (char_T *)(&pruebaReal_DQN_P.HILInitialize_AIChannels), 7, 0, 16 },

  { (char_T *)(&pruebaReal_DQN_P.HILInitialize_Active), 8, 0, 38 },

  { (char_T *)(&pruebaReal_DQN_P.HILReadTimebase_OverflowMode), 3, 0, 1 }
};

/* data type transition table for Parameters structure */
static DataTypeTransitionTable rtPTransTable = {
  6U,
  rtPTransitions
};

/* [EOF] pruebaReal_DQN_dt.h */
