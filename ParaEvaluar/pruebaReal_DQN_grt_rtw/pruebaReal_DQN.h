/*
 * pruebaReal_DQN.h
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

#ifndef pruebaReal_DQN_h_
#define pruebaReal_DQN_h_
#ifndef pruebaReal_DQN_COMMON_INCLUDES_
#define pruebaReal_DQN_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "rt_logging.h"
#include "rt_nonfinite.h"
#include "math.h"
#include "hil.h"
#include "quanser_messages.h"
#include "quanser_extern.h"
#endif                                 /* pruebaReal_DQN_COMMON_INCLUDES_ */

#include "pruebaReal_DQN_types.h"
#include "rtGetNaN.h"
#include <float.h>
#include <string.h>
#include <stddef.h>

/* Macros for accessing real-time model data structure */
#ifndef rtmGetFinalTime
#define rtmGetFinalTime(rtm)           ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetRTWLogInfo
#define rtmGetRTWLogInfo(rtm)          ((rtm)->rtwLogInfo)
#endif

#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetStopRequested
#define rtmGetStopRequested(rtm)       ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
#define rtmSetStopRequested(rtm, val)  ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
#define rtmGetStopRequestedPtr(rtm)    (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
#define rtmGetT(rtm)                   ((rtm)->Timing.taskTime0)
#endif

#ifndef rtmGetTFinal
#define rtmGetTFinal(rtm)              ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetTPtr
#define rtmGetTPtr(rtm)                (&(rtm)->Timing.taskTime0)
#endif

/* Block states (default storage) for system '<Root>' */
typedef struct {
  sIlSV3yMHnSEtj8UJwPQCPE_prueb_T P;   /* '<Root>/ControlDQN' */
  real_T HILReadTimebase_AnalogBuffer; /* '<S3>/HIL Read Timebase' */
  real_T HILReadTimebase_OtherBuffer[2];/* '<S3>/HIL Read Timebase' */
  real_T posPrev[2];                   /* '<Root>/ControlDQN' */
  real_T velPrev[2];                   /* '<Root>/ControlDQN' */
  real_T uHold;                        /* '<Root>/ControlDQN' */
  t_card HILInitialize_Card;           /* '<S3>/HIL Initialize' */
  t_task HILReadTimebase_Task;         /* '<S3>/HIL Read Timebase' */
  void *HILWrite_PWORK;                /* '<S3>/HIL Write' */
  int32_T HILReadTimebase_EncoderBuffer[2];/* '<S3>/HIL Read Timebase' */
  uint16_T muestras;                   /* '<Root>/ControlDQN' */
  uint8_T contador;                    /* '<Root>/ControlDQN' */
  boolean_T inicializado;              /* '<Root>/ControlDQN' */
  boolean_T ejecutando;                /* '<Root>/ControlDQN' */
  boolean_T disparado;                 /* '<Root>/ControlDQN' */
  boolean_T vioDesarmado;              /* '<Root>/ControlDQN' */
  boolean_T armarPrev;                 /* '<Root>/ControlDQN' */
  t_boolean HILReadTimebase_DigitalBuffer;/* '<S3>/HIL Read Timebase' */
} DW_pruebaReal_DQN_T;

/* Parameters (default storage) */
struct P_pruebaReal_DQN_T_ {
  uint32_T HILWrite_analog_channels; /* Mask Parameter: HILWrite_analog_channels
                                      * Referenced by: '<S3>/HIL Write'
                                      */
  uint32_T HILWrite_other_channels[3];/* Mask Parameter: HILWrite_other_channels
                                       * Referenced by: '<S3>/HIL Write'
                                       */
  real_T HILInitialize_OOTerminate;/* Expression: set_other_outputs_at_terminate
                                    * Referenced by: '<S3>/HIL Initialize'
                                    */
  real_T HILInitialize_OOExit;    /* Expression: set_other_outputs_at_switch_out
                                   * Referenced by: '<S3>/HIL Initialize'
                                   */
  real_T HILInitialize_AOFinal;        /* Expression: final_analog_outputs
                                        * Referenced by: '<S3>/HIL Initialize'
                                        */
  real_T HILInitialize_POFinal;        /* Expression: final_pwm_outputs
                                        * Referenced by: '<S3>/HIL Initialize'
                                        */
  real_T HILInitialize_OOFinal[3];     /* Expression: final_other_outputs
                                        * Referenced by: '<S3>/HIL Initialize'
                                        */
  real_T Armcountstorad_Gain;          /* Expression: -2*pi/(512*4)
                                        * Referenced by: '<S2>/Arm: counts to rad'
                                        */
  real_T alpha_raw_Gain;               /* Expression: 2*pi/(512*4)
                                        * Referenced by: '<S2>/alpha_raw'
                                        */
  real_T Gain_Gain;                    /* Expression: -1
                                        * Referenced by: '<Root>/Gain'
                                        */
  real_T Constant_Value[3];            /* Expression: [0, 0, 0]
                                        * Referenced by: '<Root>/Constant'
                                        */
  int32_T HILReadTimebase_Clock;    /* Computed Parameter: HILReadTimebase_Clock
                                     * Referenced by: '<S3>/HIL Read Timebase'
                                     */
  uint32_T HILReadTimebase_SamplesInBuffer;
                          /* Computed Parameter: HILReadTimebase_SamplesInBuffer
                           * Referenced by: '<S3>/HIL Read Timebase'
                           */
  uint32_T HILReadTimebase_AnalogChannels;
                           /* Computed Parameter: HILReadTimebase_AnalogChannels
                            * Referenced by: '<S3>/HIL Read Timebase'
                            */
  uint32_T HILReadTimebase_EncoderChannels[2];
                          /* Computed Parameter: HILReadTimebase_EncoderChannels
                           * Referenced by: '<S3>/HIL Read Timebase'
                           */
  uint32_T HILReadTimebase_DigitalChannels;
                          /* Computed Parameter: HILReadTimebase_DigitalChannels
                           * Referenced by: '<S3>/HIL Read Timebase'
                           */
  uint32_T HILReadTimebase_OtherChannels[2];
                            /* Computed Parameter: HILReadTimebase_OtherChannels
                             * Referenced by: '<S3>/HIL Read Timebase'
                             */
  boolean_T HILInitialize_Active;    /* Computed Parameter: HILInitialize_Active
                                      * Referenced by: '<S3>/HIL Initialize'
                                      */
  boolean_T HILInitialize_AOTerminate;
                                /* Computed Parameter: HILInitialize_AOTerminate
                                 * Referenced by: '<S3>/HIL Initialize'
                                 */
  boolean_T HILInitialize_AOExit;    /* Computed Parameter: HILInitialize_AOExit
                                      * Referenced by: '<S3>/HIL Initialize'
                                      */
  boolean_T HILInitialize_DOTerminate;
                                /* Computed Parameter: HILInitialize_DOTerminate
                                 * Referenced by: '<S3>/HIL Initialize'
                                 */
  boolean_T HILInitialize_DOExit;    /* Computed Parameter: HILInitialize_DOExit
                                      * Referenced by: '<S3>/HIL Initialize'
                                      */
  boolean_T HILInitialize_POTerminate;
                                /* Computed Parameter: HILInitialize_POTerminate
                                 * Referenced by: '<S3>/HIL Initialize'
                                 */
  boolean_T HILInitialize_POExit;    /* Computed Parameter: HILInitialize_POExit
                                      * Referenced by: '<S3>/HIL Initialize'
                                      */
  boolean_T HILInitialize_DOFinal;  /* Computed Parameter: HILInitialize_DOFinal
                                     * Referenced by: '<S3>/HIL Initialize'
                                     */
  boolean_T HILReadTimebase_Active;/* Computed Parameter: HILReadTimebase_Active
                                    * Referenced by: '<S3>/HIL Read Timebase'
                                    */
  boolean_T ARMAR_Value;               /* Expression: false
                                        * Referenced by: '<Root>/ARMAR'
                                        */
  boolean_T HILWrite_Active;           /* Computed Parameter: HILWrite_Active
                                        * Referenced by: '<S3>/HIL Write'
                                        */
  uint8_T HILReadTimebase_OverflowMode;
                             /* Computed Parameter: HILReadTimebase_OverflowMode
                              * Referenced by: '<S3>/HIL Read Timebase'
                              */
};

/* Real-time Model Data Structure */
struct tag_RTM_pruebaReal_DQN_T {
  const char_T *errorStatus;
  RTWLogInfo *rtwLogInfo;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    time_T taskTime0;
    uint32_T clockTick0;
    uint32_T clockTickH0;
    time_T stepSize0;
    time_T tFinal;
    boolean_T stopRequestedFlag;
  } Timing;
};

/* Block parameters (default storage) */
extern P_pruebaReal_DQN_T pruebaReal_DQN_P;

/* Block states (default storage) */
extern DW_pruebaReal_DQN_T pruebaReal_DQN_DW;

/* Model entry point functions */
extern void pruebaReal_DQN_initialize(void);
extern void pruebaReal_DQN_step(void);
extern void pruebaReal_DQN_terminate(void);

/* Real-time Model object */
extern RT_MODEL_pruebaReal_DQN_T *const pruebaReal_DQN_M;

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'pruebaReal_DQN'
 * '<S1>'   : 'pruebaReal_DQN/ControlDQN'
 * '<S2>'   : 'pruebaReal_DQN/Counts to Angles'
 * '<S3>'   : 'pruebaReal_DQN/Qube-Servo 3 - IO (QAL)'
 * '<S4>'   : 'pruebaReal_DQN/Counts to Angles/MATLAB Function'
 */
#endif                                 /* pruebaReal_DQN_h_ */
