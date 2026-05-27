package knt.hud.buttonprompts
{
   import flash.display.BlendMode;
   import flash.text.TextFormat;
   import glacier.basic.ButtonPromptImage;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class QTEButtonPromptWidget extends BaseControl
   {
      
      private static const QTE_TYPE_SINGLE_TAP:int = 0;
      
      private static const QTE_TYPE_PRESSANDHOLD:int = 1;
      
      private static const QTE_TYPE_RAPIDPRESSES:int = 2;
      
      private static const QTE_TYPE_COUNTDOWNTIMER:int = 3;
      
      private static const QTE_STATE_ACTIVE:int = 0;
      
      private static const QTE_STATE_SUCCESS:int = 1;
      
      private static const QTE_STATE_FAIL:int = 2;
      
      private static const QTE_LABEL_ALIGN_TOP_LEFT:int = 0;
      
      private static const QTE_LABEL_ALIGN_TOP_CENTER:int = 1;
      
      private static const QTE_LABEL_ALIGN_TOP_RIGHT:int = 2;
      
      private static const QTE_LABEL_ALIGN_CENTER_LEFT:int = 3;
      
      private static const QTE_LABEL_ALIGN_CENTER:int = 4;
      
      private static const QTE_LABEL_ALIGN_CENTER_RIGHT:int = 5;
      
      private static const QTE_LABEL_ALIGN_BOTTOM_LEFT:int = 6;
      
      private static const QTE_LABEL_ALIGN_BOTTOM_CENTER:int = 7;
      
      private static const QTE_LABEL_ALIGN_BOTTOM_RIGHT:int = 8;
      
      private static const PROMPT_ICON_SCALE:Number = 1.38;
      
      private var m_view:QTEButtonPromptWidgetView;
      
      private var m_promptImage:ButtonPromptImage;
      
      private var m_controllerType:String = "";
      
      private var m_buttonCalled:Boolean = false;
      
      private var m_buttonInstantiated:Boolean = false;
      
      private var m_buttonPressed:Boolean = false;
      
      private var m_rapidPressesPulsateCalled:Boolean = false;
      
      private var m_completedstateRunning:Boolean = false;
      
      private var m_rapidPressesButtonBlinkLoopRunning:Boolean = false;
      
      private var m_newFormat:TextFormat = new TextFormat();
      
      private var m_qteLabel:String = "";
      
      private var m_qteLabelAlignment:int = 0;
      
      private var m_rapidCount:int = 0;
      
      private var m_qteType:int = -1;
      
      private var m_flare:*;
      
      public function QTEButtonPromptWidget()
      {
         super();
         this.m_view = new QTEButtonPromptWidgetView();
         addChild(this.m_view);
         this.m_promptImage = new ButtonPromptImage();
         this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.promptHolder_mc.addChild(this.m_promptImage);
         MenuUtils.setColor(this.m_view.main_mc.flourish_mc,MenuConstantsKnt.COLOR_QTE,false);
         this.m_view.main_mc.flares_mc.blendMode = BlendMode.ADD;
         this.m_newFormat.letterSpacing = 2;
      }
      
      public function onSetData(param1:Object) : void
      {
         if(param1 == null || param1.aElements == null || !param1.aElements.length || Boolean(param1.skipEnabled))
         {
            this.killAll();
            this.resetAll();
            return;
         }
         if(this.m_controllerType != param1.controllerType && this.m_buttonCalled)
         {
            this.setPromptImage(param1);
         }
         this.m_controllerType = param1.controllerType;
         if(!this.m_buttonCalled)
         {
            this.killAll();
            this.resetAll();
            this.setPromptImage(param1);
            this.setQTEType(param1.qteType);
            this.m_buttonCalled = true;
         }
         if(this.m_buttonInstantiated)
         {
            if(this.m_completedstateRunning)
            {
               return;
            }
            if(this.m_qteType == QTE_TYPE_SINGLE_TAP)
            {
               this.runSingleTap();
            }
            else if(this.m_qteType == QTE_TYPE_PRESSANDHOLD)
            {
               if(param1.pressAndHoldCurrentTimer >= 0)
               {
                  this.runPressAndHold(MenuUtils.roundDecimal(param1.pressAndHoldCurrentTimer,2),MenuUtils.roundDecimal(param1.pressAndHoldMaxTimer,2));
               }
            }
            else if(this.m_qteType == QTE_TYPE_RAPIDPRESSES)
            {
               if(param1.pressAndHoldCurrentTimer >= 0)
               {
                  this.runRapidPresses(param1.rapidPressesCurrentCount,param1.rapidPressesMaxCount);
               }
            }
            else if(this.m_qteType == QTE_TYPE_COUNTDOWNTIMER)
            {
               if(param1.countdownCurrentTimer > 0)
               {
                  this.runCountdownTimer(MenuUtils.roundDecimal(param1.countdownCurrentTimer,2),MenuUtils.roundDecimal(param1.countdownMaxTimer,2));
               }
            }
            if(param1.aElements[0].invertColor != this.m_buttonPressed)
            {
               MenuUtils.addColorFilter(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.promptHolder_mc,param1.aElements[0].invertColor ? [MenuConstantsKnt.COLOR_MATRIX_GREY] : []);
               Animate.kill(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc);
               this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.scaleX = this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.scaleY = param1.aElements[0].invertColor ? 1.2 : 0.8;
               Animate.to(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc,0.2,0,{
                  "scaleX":1,
                  "scaleY":1
               },Animate.BackOut);
               this.m_buttonPressed = param1.aElements[0].invertColor;
               if(this.m_qteType == QTE_TYPE_PRESSANDHOLD)
               {
                  Animate.to(this.m_view.main_mc.hold_arrow_mc.inner_mc,0.6,0,{"y":(this.m_buttonPressed ? -34 : -39)},Animate.ExpoOut);
               }
            }
            if(param1.qteLabel != this.m_qteLabel || param1.qteLabelAlignment != this.m_qteLabelAlignment)
            {
               this.setPromptText(param1.qteLabel,param1.qteLabelAlignment);
               this.m_qteLabel = param1.qteLabel;
               this.m_qteLabelAlignment = param1.qteLabelAlignment;
            }
            if(param1.qteState == QTE_STATE_SUCCESS)
            {
               if(!this.m_completedstateRunning)
               {
                  this.showCompletedState(true);
               }
            }
            else if(param1.qteState == QTE_STATE_FAIL)
            {
               if(!this.m_completedstateRunning)
               {
                  this.showCompletedState(false);
               }
            }
         }
      }
      
      public function forceReset() : void
      {
         this.killAll();
         this.resetAll();
      }
      
      private function runSingleTap() : void
      {
      }
      
      private function runPressAndHold(param1:Number, param2:Number) : void
      {
         var _loc3_:int = param1 / param2 * 60;
         this.m_view.main_mc.progress_mc.dial_mc.gotoAndStop(1 + _loc3_);
      }
      
      private function runRapidPresses(param1:int, param2:int) : void
      {
         Animate.kill(this.m_view.main_mc.progress_mc.dial_mc);
         var _loc3_:int = param1 / param2 * 60;
         Animate.fromTo(this.m_view.main_mc.progress_mc.dial_mc,0.1,0,{"frames":this.m_view.main_mc.progress_mc.dial_mc.currentFrame},{"frames":1 + _loc3_},Animate.Linear);
         if(!this.m_rapidPressesButtonBlinkLoopRunning)
         {
            this.runRapidPressesButtonBlinkLoop(true);
            this.m_rapidPressesButtonBlinkLoopRunning = true;
         }
         if(param1 > this.m_rapidCount)
         {
            if(this.m_rapidPressesButtonBlinkLoopRunning)
            {
               this.runRapidPressesButtonBlinkLoop(false);
               this.m_rapidPressesButtonBlinkLoopRunning = false;
            }
         }
         this.m_rapidCount = param1;
      }
      
      private function runCountdownTimer(param1:Number, param2:Number) : void
      {
         var _loc3_:int = param1 / param2 * 60;
         this.m_view.main_mc.progress_mc.dial_mc.gotoAndStop(1 + _loc3_);
      }
      
      private function initTap() : void
      {
         this.initBaseAnim();
      }
      
      private function initPressAndHold() : void
      {
         this.initBaseAnim();
         Animate.to(this.m_view.main_mc.hold_arrow_mc,0.3,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.hold_arrow_mc,1.6,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
         Animate.to(this.m_view.main_mc.progress_mc,0.5,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.progress_mc,0.3,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
         Animate.to(this.m_view.main_mc.progress_bg_mc,0.5,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.progress_bg_mc,0.3,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
      }
      
      private function initRapidPresses() : void
      {
         this.initBaseAnim();
         Animate.to(this.m_view.main_mc.rapid_arrows_mc,0.3,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.rapid_arrows_mc,1.6,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
         this.pulsateRapidPresses(true);
         this.m_rapidPressesPulsateCalled = true;
         Animate.to(this.m_view.main_mc.progress_mc,0.5,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.progress_mc,0.3,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
         Animate.to(this.m_view.main_mc.progress_bg_mc,0.5,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.progress_bg_mc,0.3,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
      }
      
      private function initCountdownTimer() : void
      {
         this.initBaseAnim();
         Animate.to(this.m_view.main_mc.progress_mc,0.5,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.progress_mc,0.3,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
         Animate.to(this.m_view.main_mc.progress_bg_mc,0.5,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.progress_bg_mc,0.3,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
      }
      
      private function initBaseAnim() : void
      {
         Animate.to(this.m_view.main_mc.shadow_mc,0.3,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.5
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.shadow_mc,1.4,0,{
               "scaleX":1,
               "scaleY":1
            },Animate.ExpoOut);
         });
         Animate.to(this.m_view.main_mc.flourish_mc,0.5,0,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.6
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.flourish_mc,1.4,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":0.8
            },Animate.ExpoOut);
         });
         this.setFlare("BASE");
         this.runFlares(true,true);
         Animate.to(this.m_view.main_mc.prompt_mc,0.5,0.2,{
            "scaleX":0.95,
            "scaleY":0.95,
            "alpha":0.95
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.main_mc.prompt_mc,0.3,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.ExpoOut);
         });
         this.m_buttonInstantiated = true;
      }
      
      private function showCompletedState(param1:Boolean) : void
      {
         var success:Boolean = param1;
         this.killAll();
         this.runRapidPressesButtonBlinkLoop(false);
         this.pulsateRapidPresses(false);
         this.m_completedstateRunning = true;
         if(success)
         {
            Animate.kill(this.m_view.main_mc.prompt_mc);
            Animate.kill(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc);
            MenuUtils.removeFilters(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.promptHolder_mc);
            this.m_view.main_mc.prompt_mc.scaleX = this.m_view.main_mc.prompt_mc.scaleY = 1;
            this.m_view.main_mc.prompt_mc.alpha = 1;
            this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.scaleX = this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.scaleY = 1;
            MenuUtils.setColor(this.m_view.main_mc.progress_mc.dial_mc,MenuConstantsKnt.COLOR_GREEN,false);
            MenuUtils.setColor(this.m_view.main_mc.result_mc,MenuConstantsKnt.COLOR_GREEN,false);
            if(this.m_qteType == QTE_TYPE_RAPIDPRESSES)
            {
               Animate.kill(this.m_view.main_mc.progress_mc.dial_mc);
               this.m_view.main_mc.progress_mc.dial_mc.gotoAndStop(this.m_view.main_mc.progress_mc.dial_mc.totalFrames);
            }
            this.setFlare("SUCCESS");
            this.runFlares(true);
         }
         else
         {
            Animate.kill(this.m_view.main_mc.prompt_mc);
            Animate.kill(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc);
            MenuUtils.addColorFilter(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.promptHolder_mc,[MenuConstantsKnt.COLOR_MATRIX_GREY]);
            this.m_view.main_mc.prompt_mc.scaleX = this.m_view.main_mc.prompt_mc.scaleY = 1;
            this.m_view.main_mc.prompt_mc.alpha = 1;
            this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.scaleX = this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.scaleY = 0.8;
            MenuUtils.setColor(this.m_view.main_mc.progress_mc.dial_mc,MenuConstantsKnt.COLOR_RED,false);
            MenuUtils.setColor(this.m_view.main_mc.result_mc,MenuConstantsKnt.COLOR_RED,false);
            this.setFlare("FAIL");
            this.runFlares(true);
         }
         this.m_view.main_mc.result_mc.alpha = 0;
         Animate.to(this.m_view.main_mc.result_mc,0.2,0,{"alpha":1},Animate.Linear,function():void
         {
            Animate.to(m_view.main_mc.result_mc,0.3,0.2,{"alpha":0},Animate.Linear);
         });
         Animate.to(this.m_view,0.2,0.5,{
            "scaleX":0,
            "scaleY":0,
            "alpha":0
         },Animate.ExpoOut,function():void
         {
            m_completedstateRunning = false;
         });
      }
      
      private function runFlares(param1:Boolean, param2:Boolean = false) : void
      {
         var start:Boolean = param1;
         var isIntro:Boolean = param2;
         Animate.kill(this.m_view.main_mc.flares_mc);
         Animate.kill(this.m_flare.flare_01_mc);
         Animate.kill(this.m_flare.flare_02_mc);
         Animate.kill(this.m_flare.flare_03_mc);
         this.m_flare.flare_01_mc.alpha = 0;
         this.m_flare.flare_02_mc.alpha = 0;
         this.m_flare.flare_03_mc.alpha = 0;
         if(start)
         {
            if(isIntro)
            {
               this.m_view.main_mc.flares_mc.scaleX = this.m_view.main_mc.flares_mc.scaleY = 0.8;
               Animate.to(this.m_view.main_mc.flares_mc,0.4,0,{
                  "scaleX":0.6,
                  "scaleY":0.6
               },Animate.Linear);
               Animate.to(this.m_flare.flare_01_mc,0.1,0,{"alpha":0.2},Animate.ExpoOut,function():void
               {
                  Animate.to(m_flare.flare_01_mc,0.4,0,{"alpha":0},Animate.ExpoIn);
               });
               Animate.to(this.m_flare.flare_02_mc,0.1,0,{"alpha":0.2},Animate.ExpoOut,function():void
               {
                  Animate.to(m_flare.flare_02_mc,0.3,0,{"alpha":0},Animate.ExpoIn);
               });
               Animate.to(this.m_flare.flare_03_mc,0.2,0.1,{"alpha":0.2},Animate.ExpoOut,function():void
               {
                  Animate.to(m_flare.flare_03_mc,0.3,0,{"alpha":0},Animate.ExpoIn);
               });
            }
            else
            {
               this.m_view.main_mc.flares_mc.scaleX = this.m_view.main_mc.flares_mc.scaleY = 0.4;
               Animate.to(this.m_view.main_mc.flares_mc,0.4,0,{
                  "scaleX":0.8,
                  "scaleY":0.8
               },Animate.Linear);
               Animate.to(this.m_flare.flare_01_mc,0.3,0,{"alpha":0.4},Animate.Linear,function():void
               {
                  Animate.to(m_flare.flare_01_mc,0.1,0,{"alpha":0},Animate.Linear);
               });
               Animate.to(this.m_flare.flare_02_mc,0.2,0.1,{"alpha":0.4},Animate.Linear,function():void
               {
                  Animate.to(m_flare.flare_02_mc,0.1,0,{"alpha":0},Animate.Linear);
               });
               Animate.to(this.m_flare.flare_03_mc,0.1,0.2,{"alpha":0.4},Animate.Linear,function():void
               {
                  Animate.to(m_flare.flare_03_mc,0.1,0,{"alpha":0},Animate.Linear);
               });
            }
         }
      }
      
      private function runRapidPressesButtonBlinkLoop(param1:Boolean) : void
      {
         var start:Boolean = param1;
         Animate.kill(this.m_view.main_mc.prompt_mc.inner_mc);
         this.m_view.main_mc.prompt_mc.inner_mc.scaleX = this.m_view.main_mc.prompt_mc.inner_mc.scaleY = 1;
         if(start)
         {
            this.m_view.main_mc.prompt_mc.inner_mc.scaleX = this.m_view.main_mc.prompt_mc.inner_mc.scaleY = 0.8;
            Animate.to(this.m_view.main_mc.prompt_mc.inner_mc,0.4,0,{
               "scaleX":1,
               "scaleY":1
            },Animate.BackOut,function():void
            {
               runRapidPressesButtonBlinkLoop(true);
            });
         }
      }
      
      private function pulsateRapidPresses(param1:Boolean) : void
      {
         var start:Boolean = param1;
         Animate.kill(this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_01_mc);
         Animate.kill(this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_02_mc);
         Animate.kill(this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_03_mc);
         Animate.kill(this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_04_mc);
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_01_mc.y = -40;
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_02_mc.x = 40;
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_03_mc.y = 40;
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_04_mc.x = -40;
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_01_mc.scaleX = this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_01_mc.scaleY = 1.2;
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_02_mc.scaleX = this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_02_mc.scaleY = 1.2;
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_03_mc.scaleX = this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_03_mc.scaleY = 1.2;
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_04_mc.scaleX = this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_04_mc.scaleY = 1.2;
         if(start)
         {
            Animate.to(this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_01_mc,0.1,0,{
               "scaleX":1,
               "scaleY":1,
               "y":-31
            },Animate.QuadInOut,function():void
            {
               Animate.to(m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_01_mc,0.1,0,{
                  "scaleX":1.2,
                  "scaleY":1.2,
                  "y":-40
               },Animate.QuadInOut,function():void
               {
                  pulsateRapidPresses(true);
               });
            });
            Animate.to(this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_02_mc,0.1,0,{
               "scaleX":1,
               "scaleY":1,
               "x":31
            },Animate.QuadInOut,function():void
            {
               Animate.to(m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_02_mc,0.1,0,{
                  "scaleX":1.2,
                  "scaleY":1.2,
                  "x":40
               },Animate.QuadInOut);
            });
            Animate.to(this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_03_mc,0.1,0,{
               "scaleX":1,
               "scaleY":1,
               "y":31
            },Animate.QuadInOut,function():void
            {
               Animate.to(m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_03_mc,0.1,0,{
                  "scaleX":1.2,
                  "scaleY":1.2,
                  "y":40
               },Animate.QuadInOut);
            });
            Animate.to(this.m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_04_mc,0.1,0,{
               "scaleX":1,
               "scaleY":1,
               "x":-31
            },Animate.QuadInOut,function():void
            {
               Animate.to(m_view.main_mc.rapid_arrows_mc.inner_mc.arrow_04_mc,0.1,0,{
                  "scaleX":1.2,
                  "scaleY":1.2,
                  "x":-40
               },Animate.QuadInOut);
            });
         }
      }
      
      private function setQTEType(param1:int) : void
      {
         this.m_qteType = param1;
         switch(param1)
         {
            case QTE_TYPE_SINGLE_TAP:
               this.initTap();
               break;
            case QTE_TYPE_PRESSANDHOLD:
               this.initPressAndHold();
               break;
            case QTE_TYPE_RAPIDPRESSES:
               this.initRapidPresses();
               break;
            case QTE_TYPE_COUNTDOWNTIMER:
               this.initCountdownTimer();
         }
      }
      
      private function getQteType(param1:int) : String
      {
         var _loc2_:String = "";
         switch(param1)
         {
            case QTE_TYPE_SINGLE_TAP:
               _loc2_ = "QTE_TYPE_SINGLE_TAP";
               break;
            case QTE_TYPE_PRESSANDHOLD:
               _loc2_ = "QTE_TYPE_PRESSANDHOLD";
               break;
            case QTE_TYPE_RAPIDPRESSES:
               _loc2_ = "QTE_TYPE_RAPIDPRESSES";
               break;
            case QTE_TYPE_COUNTDOWNTIMER:
               _loc2_ = "QTE_TYPE_COUNTDOWNTIMER";
         }
         return _loc2_;
      }
      
      public function setFlare(param1:String) : void
      {
         if(this.m_view.main_mc.flares_mc.container_mc.numChildren > 0)
         {
            this.runFlares(false);
            while(this.m_view.main_mc.flares_mc.container_mc.numChildren > 0)
            {
               this.m_view.main_mc.flares_mc.container_mc.removeChildAt(0);
            }
         }
         switch(param1)
         {
            case "BASE":
               this.m_flare = new QTEButtonPromptWidgetFlaresBaseView();
               break;
            case "SUCCESS":
               this.m_flare = new QTEButtonPromptWidgetFlaresGreenView();
               break;
            case "FAIL":
               this.m_flare = new QTEButtonPromptWidgetFlaresRedView();
         }
         this.m_flare.flare_01_mc.alpha = 0;
         this.m_flare.flare_02_mc.alpha = 0;
         this.m_flare.flare_03_mc.alpha = 0;
         this.m_view.main_mc.flares_mc.container_mc.addChild(this.m_flare);
      }
      
      private function killAll() : void
      {
         Animate.kill(this.m_view);
         if(this.m_view.main_mc.flares_mc.container_mc.numChildren > 0)
         {
            this.runFlares(false);
         }
         Animate.kill(this.m_view.main_mc.result_mc);
         Animate.kill(this.m_view.main_mc.prompt_mc);
         Animate.kill(this.m_view.main_mc.prompt_mc.inner_mc);
         Animate.kill(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc);
         Animate.kill(this.m_view.main_mc.hold_arrow_mc);
         Animate.kill(this.m_view.main_mc.hold_arrow_mc.inner_mc);
         Animate.kill(this.m_view.main_mc.rapid_arrows_mc);
         Animate.kill(this.m_view.main_mc.rapid_arrows_mc.inner_mc);
         Animate.kill(this.m_view.main_mc.progress_mc);
         Animate.kill(this.m_view.main_mc.progress_bg_mc);
         Animate.kill(this.m_view.main_mc.shadow_mc);
         Animate.kill(this.m_view.main_mc.flourish_mc);
      }
      
      private function resetAll() : void
      {
         this.m_view.scaleX = this.m_view.scaleY = 1;
         this.m_view.alpha = 1;
         MenuUtils.setColor(this.m_view.main_mc.progress_mc.dial_mc,MenuConstantsKnt.COLOR_QTE,false);
         this.m_view.main_mc.prompt_mc.alpha = 0;
         this.m_view.main_mc.prompt_mc.scaleX = this.m_view.main_mc.prompt_mc.scaleY = 1.5;
         this.m_view.main_mc.prompt_mc.inner_mc.scaleX = this.m_view.main_mc.prompt_mc.inner_mc.scaleY = 1;
         this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.scaleX = this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.scaleY = 1;
         this.m_view.main_mc.hold_arrow_mc.alpha = 0;
         this.m_view.main_mc.hold_arrow_mc.scaleX = this.m_view.main_mc.hold_arrow_mc.scaleY = 1.5;
         this.m_view.main_mc.hold_arrow_mc.inner_mc.y = -39;
         this.runRapidPressesButtonBlinkLoop(false);
         this.pulsateRapidPresses(false);
         this.m_view.main_mc.rapid_arrows_mc.alpha = 0;
         this.m_view.main_mc.rapid_arrows_mc.inner_mc.alpha = 1;
         this.m_view.main_mc.progress_mc.alpha = 0;
         this.m_view.main_mc.progress_mc.scaleX = this.m_view.main_mc.progress_mc.scaleY = 1.8;
         this.m_view.main_mc.progress_mc.dial_mc.gotoAndStop(0);
         this.m_view.main_mc.progress_bg_mc.alpha = 0;
         this.m_view.main_mc.progress_bg_mc.scaleX = this.m_view.main_mc.progress_bg_mc.scaleY = 1.8;
         this.m_view.main_mc.shadow_mc.alpha = 0;
         this.m_view.main_mc.shadow_mc.scaleX = this.m_view.main_mc.shadow_mc.scaleY = 1.8;
         this.m_view.main_mc.flourish_mc.alpha = 0;
         this.m_view.main_mc.flourish_mc.scaleX = this.m_view.main_mc.flourish_mc.scaleY = 1.8;
         this.m_view.main_mc.result_mc.alpha = 0;
         if(this.m_view.main_mc.flares_mc.container_mc.numChildren > 0)
         {
            this.runFlares(false);
            while(this.m_view.main_mc.flares_mc.container_mc.numChildren > 0)
            {
               this.m_view.main_mc.flares_mc.container_mc.removeChildAt(0);
            }
         }
         MenuUtils.removeFilters(this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.promptHolder_mc);
         this.m_buttonCalled = false;
         this.m_buttonInstantiated = false;
         this.m_buttonPressed = false;
         this.m_rapidPressesPulsateCalled = false;
         this.m_rapidCount = 0;
         this.m_rapidPressesButtonBlinkLoopRunning = false;
         this.m_completedstateRunning = false;
         this.m_qteType = -1;
      }
      
      private function setPromptText(param1:String, param2:int) : void
      {
         this.m_view.main_mc.title_mc.visible = param1 != "";
         MenuUtils.setupTextUpper(this.m_view.main_mc.title_mc.title_txt_L,"",18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         MenuUtils.setupTextUpper(this.m_view.main_mc.title_mc.title_txt_C,"",18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         MenuUtils.setupTextUpper(this.m_view.main_mc.title_mc.title_txt_R,"",18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         var _loc3_:int = 0;
         var _loc4_:String = "Right";
         switch(param2)
         {
            case QTE_LABEL_ALIGN_TOP_LEFT:
               _loc3_ = -58;
               _loc4_ = "Left";
               break;
            case QTE_LABEL_ALIGN_TOP_CENTER:
               _loc3_ = -58;
               _loc4_ = "Center";
               break;
            case QTE_LABEL_ALIGN_TOP_RIGHT:
               _loc3_ = -58;
               _loc4_ = "Right";
               break;
            case QTE_LABEL_ALIGN_CENTER_LEFT:
               _loc3_ = 0;
               _loc4_ = "Left";
               break;
            case QTE_LABEL_ALIGN_CENTER:
               _loc3_ = 0;
               _loc4_ = "Center";
               break;
            case QTE_LABEL_ALIGN_CENTER_RIGHT:
               _loc3_ = 0;
               _loc4_ = "Right";
               break;
            case QTE_LABEL_ALIGN_BOTTOM_LEFT:
               _loc3_ = 58;
               _loc4_ = "Left";
               break;
            case QTE_LABEL_ALIGN_BOTTOM_CENTER:
               _loc3_ = 58;
               _loc4_ = "Center";
               break;
            case QTE_LABEL_ALIGN_BOTTOM_RIGHT:
               _loc3_ = 58;
               _loc4_ = "Right";
         }
         this.m_view.main_mc.title_mc.y = _loc3_;
         if(_loc4_ == "Left")
         {
            MenuUtils.setupTextUpper(this.m_view.main_mc.title_mc.title_txt_L,param1,18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
            this.m_view.main_mc.title_mc.title_txt_L.setTextFormat(this.m_newFormat);
         }
         else if(_loc4_ == "Center")
         {
            MenuUtils.setupTextUpper(this.m_view.main_mc.title_mc.title_txt_C,param1,18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
            this.m_view.main_mc.title_mc.title_txt_C.setTextFormat(this.m_newFormat);
         }
         else if(_loc4_ == "Right")
         {
            MenuUtils.setupTextUpper(this.m_view.main_mc.title_mc.title_txt_R,param1,18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
            this.m_view.main_mc.title_mc.title_txt_R.setTextFormat(this.m_newFormat);
         }
      }
      
      private function setPromptImage(param1:Object) : void
      {
         this.m_promptImage.platform = param1.controllerType;
         this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.promptHolder_mc.scaleX = this.m_view.main_mc.prompt_mc.inner_mc.inner_inner_mc.promptHolder_mc.scaleY = this.m_promptImage.platform == "key" ? 1.25 : PROMPT_ICON_SCALE;
         if((this.m_promptImage.platform == "key" || param1.aElements[0].iconId == -1) && param1.aElements[0].keyGlyph != "")
         {
            this.m_promptImage.customKey = param1.aElements[0].keyGlyph;
         }
         else
         {
            this.m_promptImage.button = param1.aElements[0].iconId;
         }
         this.m_promptImage.visible = true;
      }
   }
}

