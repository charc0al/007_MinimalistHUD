package knt.hud.watch
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.filters.DisplacementMapFilter;
   import flash.filters.DisplacementMapFilterMode;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.Localization;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class WatchTriangulationRadarWidget extends BaseControl
   {
      private static const TARGET_LOOSE_DIRECTION_FOUND:int = 1;
      
      private static const TARGET_NONE_SEARCH_AREA:int = 2;
      
      private static const TARGET_FOUND:int = 3;
      
      private static const TARGET_HACKING_MODE:int = 4;
      
      private static const TARGET_HACKING_OUT_OF_RANGE:int = 5;
      
      private static const TARGET_HACKING_FAILED:int = 6;
      
      private static const TARGET_HACKING_COMPLETE:int = 7;
      
      private static const RADAR_RADIUS:Number = 200 / 2;
      
      private static const RING_NO_TARGET_START_SCALE:Number = 1;
      
      private static const RING_NO_TARGET_END_SCALE:Number = 0.1;
      
      private static const RING_LOOSE_TARGET_START_SCALE:Number = 2.8;
      
      private static const RING_LOOSE_TARGET_END_SCALE:Number = 4;
      
      private static const RING_FOUND_TARGET_START_SCALE:Number = 0.1;
      
      private static const RING_FOUND_TARGET_END_SCALE:Number = 0.6;
      
      private static const RING_LOOSE_TARGET_Y_OFFSET:Number = -380;
      
      private static const GRADIENT_BG_PULSE_SPEED:Number = 3;
      
      private static const BASE_SCALE:Number = 0.75;
      
      private static const AIMING_SCALE:Number = BASE_SCALE * 1.3;
      
      private static const HIDDEN_X_OFFSET:Number = -180;
      
      private static const HIDDEN_Y_OFFSET:Number = 100;
      
      private var displaceBitmap:BitmapData;
      
      public var m_view:WatchTriangulationRadarWidgetView;
      
      private var m_glitching:Boolean = false;
      
      private var m_currentStep:int = -1;
      
      private var m_prevStep:int = -1;
      
      private var m_message:String = "";
      
      private var m_hacking:Boolean = false;
      
      private var m_showHealth:Boolean = true;
      
      private var m_stoppedHackBgLoopDueToHackingOutOfRange:Boolean = false;
      
      private var m_stoppedHackBgLoopDueToHackingComplete:Boolean = false;
      
      private var m_looseTarget:Boolean = false;
      
      private var m_target:Boolean = false;
      
      private var m_showingBootup:Boolean = false;
      
      private var m_loopTargetRingAnimsRunning:Boolean = false;
      
      private var m_isTargetOutsideRadius:Boolean = false;
      
      private var m_isTargetInsideRadius:Boolean = false;
      
      private var m_hackHealthBarInstantiated:Boolean = false;
      
      private var m_healtBarColorWasSetWhite:Boolean = false;
      
      private var m_healtBarColorWasSetYellow:Boolean = false;
      
      private var m_healtBarColorWasSetRed:Boolean = false;
      
      private var m_lowHealthWarningPulsating:Boolean = false;
      
      private var m_triangulationMessageFlashCount:int = 0;
      
      private var m_hackingMessageFlashCount:int = 0;
      
      private var m_pulseRingArray:Array;
      
      private var m_isInTriangulationMode:Boolean = false;
      
      private var m_isAimingWatch:Boolean = false;
      
      private var m_dontHackRecord:Boolean = false;
      
      public function WatchTriangulationRadarWidget()
      {
         var _loc1_:WatchTriangulationRadarPulseRingView = null;
         var _loc3_:Sprite = null;
         this.m_pulseRingArray = new Array();
         super();
         this.m_view = new WatchTriangulationRadarWidgetView();
         addChild(this.m_view);
         this.m_view.hack_health_mc.filters = [new DropShadowFilter(4,151,0,0.6,4,4,0.4,1)];
         this.m_view.hack_health_mc.visible = false;
         this.m_view.hack_health_mc.hackbar_mc.mask_mc.x = -179;
         this.m_view.hack_health_mc.hackbar_mc.bg_mc.gotoAndStop(0);
         MenuUtils.setColor(this.m_view.hack_health_mc.hackbar_mc,MenuConstantsKnt.COLOR_GREY_LIGHT,false);
         this.m_view.hack_health_mc.healthbar_mc.mask_mc.x = -179;
         this.m_view.hack_health_mc.healthbar_mc.bg_mc.gotoAndStop(0);
         MenuUtils.setColor(this.m_view.hack_health_mc.healthbar_mc.bg_mc,MenuConstantsKnt.COLOR_WHITE,false);
         MenuUtils.setupTextUpper(this.m_view.hack_health_mc.health_text_mc.title_txt,Localization.get("UI_HUD_TRIANGULATION_LOWHEALTH"),14,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
         this.m_view.hack_health_mc.health_text_mc.backdrop_mc.width = this.m_view.hack_health_mc.health_text_mc.title_txt.textWidth + 20;
         MenuUtils.setColor(this.m_view.hack_health_mc.health_text_mc.backdrop_mc,MenuConstantsKnt.COLOR_RED,false);
         this.pulsateLowHealthWarning(false);
         this.m_view.intro_mc.visible = false;
         this.m_view.crosshair_mc.alpha = 0.6;
         this.m_view.target_mc.visible = false;
         this.m_view.target_mc.arrow_mc.arrow_inner_mc.alpha = 0;
         this.m_view.target_mc.dot_mc.visible = false;
         if(MenuConstantsKnt.VANILLA_Q_WATCH_DISPLAY)
         {
            this.m_view.visible = false;
            this.m_view.scaleX = this.m_view.scaleY = BASE_SCALE;
            this.m_view.x = 0;
            this.m_view.y = 0;
            this.m_view.alpha = 1;
            this.m_isAimingWatch = false;
         }
         else
         {
            this.m_view.visible = false;
            this.m_view.scaleX = this.m_view.scaleY = AIMING_SCALE;
            this.m_view.x = HIDDEN_X_OFFSET;
            this.m_view.y = HIDDEN_Y_OFFSET;
            this.m_view.alpha = 0;
            this.m_isAimingWatch = true;
         }
         this.m_view.hack_health_mc.scaleX = this.m_view.hack_health_mc.scaleY = 1.25;
         this.m_view.dots_mc.alpha = 0;
         this.m_view.bg_mc.gradient_mc.scaleX = this.m_view.bg_mc.gradient_mc.scaleY = 0;
         this.m_view.bg_mc.gradient_mc.inner_mc.alpha = 0;
         var _loc2_:int = 0;
         while(_loc2_ < 4)
         {
            _loc3_ = new Sprite();
            _loc1_ = new WatchTriangulationRadarPulseRingView();
            _loc3_.addChild(_loc1_);
            this.m_view.pulserings_mc.pulseringsholder_mc.addChild(_loc3_);
            _loc1_.alpha = 0;
            this.m_pulseRingArray.push({
               "pulseRingContainerSprite":_loc3_,
               "pulseRing":_loc1_,
               "pulseRingName":"pulseRing_" + _loc2_
            });
            _loc2_++;
         }
      }
      
      public function onSetData(param1:Object) : void
      {
         if(param1.isInTriangulationMode)
         {
            if(!this.m_isInTriangulationMode)
            {
               this.m_isInTriangulationMode = true;
            }
            if(param1.showHealth != null)
            {
               this.showHealth(param1.showHealth);
            }
            if((MenuConstantsKnt.VANILLA_Q_WATCH_DISPLAY ? !Boolean(param1.isAimingWatch) : Boolean(param1.isAimingWatch)))
            {
               if(this.m_isAimingWatch)
               {
                  Animate.kill(this.m_view);
                  Animate.to(this.m_view,0.2,0,{
                     "x":0,
                     "y":0,
                     "scaleX":BASE_SCALE,
                     "scaleY":BASE_SCALE,
                     "alpha":1
                  },Animate.ExpoOut);
                  this.m_isAimingWatch = false;
               }
            }
            else if(!this.m_isAimingWatch)
            {
               Animate.kill(this.m_view);
               Animate.to(this.m_view,0.2,0,{
                  "x":HIDDEN_X_OFFSET,
                  "y":HIDDEN_Y_OFFSET,
                  "scaleX":AIMING_SCALE,
                  "scaleY":AIMING_SCALE,
                  "alpha":0
               },Animate.ExpoOut);
               this.m_isAimingWatch = true;
            }
            if(this.m_isAimingWatch)
            {
               return;
            }
            if(this.m_prevStep <= 0 && param1.step > 0)
            {
            }
            if(!this.m_showingBootup)
            {
               this.showGlitch(param1.showGlitches);
               if(param1.message != this.m_message)
               {
                  this.setTextMessages(param1.message);
                  this.m_message = param1.message;
               }
               if(this.m_dontHackRecord && param1.step == TARGET_HACKING_MODE)
               {
                  this.setTextMessages("RECORDING");
               }
               if(param1.step != this.m_prevStep)
               {
                  this.m_currentStep = param1.step;
                  this.m_view.visible = true;
                  switch(param1.step)
                  {
                     case TARGET_LOOSE_DIRECTION_FOUND:
                        this.animateLoopTargetRings(true);
                        this.showTriangulationMessage(true,7);
                        this.showHackingMessage(false);
                        MenuUtils.setColor(this.m_view.pulserings_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        MenuUtils.setColor(this.m_view.target_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        this.m_looseTarget = true;
                        this.m_target = false;
                        this.m_hacking = false;
                        break;
                     case TARGET_NONE_SEARCH_AREA:
                        this.animateLoopTargetRings(true);
                        this.showTriangulationMessage(true,7);
                        this.showHackingMessage(false);
                        MenuUtils.setColor(this.m_view.pulserings_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        MenuUtils.setColor(this.m_view.target_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        this.m_looseTarget = false;
                        this.m_target = false;
                        this.m_hacking = false;
                        break;
                     case TARGET_FOUND:
                        this.animateLoopTargetRings(true);
                        if(this.m_hacking)
                        {
                           this.showTriangulationMessage(false);
                           this.showHackingMessage(true,-1);
                        }
                        else
                        {
                           this.showTriangulationMessage(true,7);
                           this.showHackingMessage(false);
                        }
                        MenuUtils.setColor(this.m_view.pulserings_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        MenuUtils.setColor(this.m_view.target_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        this.m_looseTarget = false;
                        this.m_target = true;
                        break;
                     case TARGET_HACKING_MODE:
                        this.showTriangulationMessage(false);
                        this.showHackingMessage(true,-1);
                        MenuUtils.setColor(this.m_view.hack_health_mc.hackbar_mc,MenuConstantsKnt.COLOR_TEAL);
                        MenuUtils.setColor(this.m_view.pulserings_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        MenuUtils.setColor(this.m_view.target_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        this.m_looseTarget = false;
                        this.m_hacking = true;
                        break;
                     case TARGET_HACKING_OUT_OF_RANGE:
                        this.showTriangulationMessage(false);
                        this.showHackingMessage(true,7);
                        this.animateLoopHackBarBg(false);
                        MenuUtils.setColor(this.m_view.hack_health_mc.hackbar_mc,MenuConstantsKnt.COLOR_RED);
                        MenuUtils.setColor(this.m_view.pulserings_mc,MenuConstantsKnt.COLOR_RED,false);
                        MenuUtils.setColor(this.m_view.target_mc,MenuConstantsKnt.COLOR_RED,false);
                        this.m_looseTarget = false;
                        this.m_hacking = true;
                        break;
                     case TARGET_HACKING_FAILED:
                        this.showTriangulationMessage(false);
                        this.showHackingMessage(true,7);
                        this.animateLoopHackBarBg(false);
                        MenuUtils.setColor(this.m_view.hack_health_mc.hackbar_mc,MenuConstantsKnt.COLOR_OBJECTIVE_FAILED);
                        MenuUtils.setColor(this.m_view.pulserings_mc,MenuConstantsKnt.COLOR_OBJECTIVE_FAILED,false);
                        MenuUtils.setColor(this.m_view.target_mc,MenuConstantsKnt.COLOR_OBJECTIVE_FAILED,false);
                        this.m_looseTarget = true;
                        this.m_target = false;
                        Animate.kill(this.m_view.target_mc.arrow_mc.arrow_inner_mc);
                        this.animateLoopTargetRings(false);
                        break;
                     case TARGET_HACKING_COMPLETE:
                        this.showTriangulationMessage(false);
                        this.showHackingMessage(true,7);
                        this.animateLoopHackBarBg(false);
                        MenuUtils.setColor(this.m_view.hack_health_mc.hackbar_mc,MenuConstantsKnt.COLOR_OBJECTIVE_COMPLETED);
                        MenuUtils.setColor(this.m_view.pulserings_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        MenuUtils.setColor(this.m_view.target_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        this.m_looseTarget = false;
                        this.m_target = false;
                        Animate.kill(this.m_view.target_mc.arrow_mc.arrow_inner_mc);
                        this.animateLoopTargetRings(false);
                        break;
                     default:
                        this.showTriangulationMessage(false);
                        this.showHackingMessage(false);
                        MenuUtils.removeColor(this.m_view.hack_health_mc.hackbar_mc);
                        MenuUtils.setColor(this.m_view.pulserings_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        MenuUtils.setColor(this.m_view.target_mc,MenuConstantsKnt.COLOR_OBJECTIVE,false);
                        this.m_looseTarget = false;
                        this.m_target = false;
                        this.m_hacking = false;
                        Animate.kill(this.m_view.target_mc.arrow_mc.arrow_inner_mc);
                        this.animateLoopTargetRings(false);
                        this.m_view.visible = false;
                  }
                  this.m_prevStep = param1.step;
               }
            }
            if(this.m_target || this.m_hacking)
            {
               this.setTargetPosition(param1.triangulationRange,param1.triangulationTargetWithinRange,param1.triangulationTargetDistance);
               this.m_view.target_mc.visible = true;
            }
            else if(this.m_looseTarget)
            {
               Animate.kill(this.m_view.pulserings_mc.pulseringsholder_mc);
               Animate.to(this.m_view.pulserings_mc.pulseringsholder_mc,0.6,0,{"y":0},Animate.ExpoOut);
               this.m_view.target_mc.visible = false;
               this.m_isTargetOutsideRadius = false;
               this.m_isTargetInsideRadius = false;
            }
            else
            {
               Animate.kill(this.m_view.target_mc.arrow_mc.arrow_inner_mc);
               Animate.kill(this.m_view.pulserings_mc.pulseringsholder_mc);
               Animate.to(this.m_view.pulserings_mc.pulseringsholder_mc,0.6,0,{"y":0},Animate.ExpoOut);
               this.m_view.target_mc.visible = false;
               this.m_isTargetOutsideRadius = false;
               this.m_isTargetInsideRadius = false;
            }
            if(this.m_hacking)
            {
               this.setHackingHealthProgress(param1.hackProgress,param1.currentHealth,param1.maxHealth,param1.step,true);
            }
            else if(this.m_hackHealthBarInstantiated)
            {
               this.setHackingHealthProgress(param1.hackProgress,param1.currentHealth,param1.maxHealth,param1.step,false);
            }
            return;
         }
         if(this.m_isInTriangulationMode)
         {
            this.showTriangulationMessage(false);
            this.showHackingMessage(false);
            MenuUtils.removeColor(this.m_view.hack_health_mc.hackbar_mc.bar_mc);
            this.m_looseTarget = false;
            this.m_target = false;
            this.m_hacking = false;
            Animate.kill(this.m_view.target_mc.arrow_mc.arrow_inner_mc);
            this.animateLoopTargetRings(false);
            this.m_view.visible = false;
            this.m_isInTriangulationMode = false;
         }
      }
      
      private function setTargetPosition(param1:Number, param2:Boolean, param3:Number) : void
      {
         var _loc4_:Number = param2 ? RADAR_RADIUS * (param3 / param1) : RADAR_RADIUS;
         if(_loc4_ >= RADAR_RADIUS)
         {
            if(!this.m_isTargetOutsideRadius || this.m_isTargetInsideRadius)
            {
               this.m_view.target_mc.dot_mc.visible = false;
               Animate.kill(this.m_view.target_mc.arrow_mc.arrow_inner_mc);
               Animate.to(this.m_view.target_mc.arrow_mc.arrow_inner_mc,0.6,0,{
                  "alpha":1,
                  "y":-98.35
               },Animate.ExpoOut);
               Animate.kill(this.m_view.pulserings_mc.pulseringsholder_mc);
               Animate.to(this.m_view.pulserings_mc.pulseringsholder_mc,0.6,0,{"y":-98.35},Animate.ExpoOut);
               this.m_isTargetOutsideRadius = true;
               this.m_isTargetInsideRadius = false;
            }
         }
         else if(this.m_isTargetOutsideRadius || !this.m_isTargetInsideRadius)
         {
            this.m_view.target_mc.dot_mc.visible = true;
            Animate.kill(this.m_view.target_mc.arrow_mc.arrow_inner_mc);
            Animate.to(this.m_view.target_mc.arrow_mc.arrow_inner_mc,0.6,0,{
               "alpha":0,
               "y":-98.35
            },Animate.ExpoOut);
            Animate.kill(this.m_view.pulserings_mc.pulseringsholder_mc);
            this.m_isTargetOutsideRadius = false;
            this.m_isTargetInsideRadius = true;
         }
         this.m_view.target_mc.dot_mc.y = -_loc4_;
         if(this.m_isTargetInsideRadius)
         {
            this.m_view.pulserings_mc.pulseringsholder_mc.y = -_loc4_;
         }
      }
      
      private function animateLoopTargetRings(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(!param1)
         {
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               Animate.kill(this.m_pulseRingArray[_loc2_].pulseRing);
               Animate.kill(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite);
               this.m_pulseRingArray[_loc2_].pulseRing.alpha = 0;
               _loc2_++;
            }
            this.m_loopTargetRingAnimsRunning = false;
            this.animateGradientBg(0.6,false,false);
            return;
         }
         if(this.m_currentStep == TARGET_NONE_SEARCH_AREA)
         {
            if(!this.m_loopTargetRingAnimsRunning)
            {
               _loc2_ = 0;
               while(_loc2_ < 4)
               {
                  this.animateSingleRing(this.m_pulseRingArray[_loc2_].pulseRing,3,_loc2_ * 0.75,RING_NO_TARGET_START_SCALE,RING_NO_TARGET_END_SCALE,1,0,true);
                  this.m_pulseRingArray[_loc2_].pulseRingContainerSprite.x = 0;
                  this.m_pulseRingArray[_loc2_].pulseRingContainerSprite.y = 0;
                  this.animateRingContainerOffset(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite,0.2,0,0,false);
                  _loc2_++;
               }
               this.animateGradientBg(6,true,true);
               this.m_loopTargetRingAnimsRunning = true;
            }
            else
            {
               _loc2_ = 0;
               while(_loc2_ < 4)
               {
                  Animate.kill(this.m_pulseRingArray[_loc2_].pulseRing);
                  this.animateRingTransition(this.m_pulseRingArray[_loc2_].pulseRing,0.2,0,RING_NO_TARGET_START_SCALE,_loc2_);
                  Animate.kill(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite);
                  this.animateRingContainerOffset(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite,0.2,0,0,false);
                  _loc2_++;
               }
               this.animateGradientBg(0.6,false,false);
               this.m_loopTargetRingAnimsRunning = false;
            }
         }
         else if(this.m_currentStep == TARGET_LOOSE_DIRECTION_FOUND)
         {
            if(!this.m_loopTargetRingAnimsRunning)
            {
               _loc2_ = 0;
               while(_loc2_ < 4)
               {
                  this.animateSingleRing(this.m_pulseRingArray[_loc2_].pulseRing,2,_loc2_ * 0.3,RING_LOOSE_TARGET_START_SCALE,RING_LOOSE_TARGET_END_SCALE,1,0,true);
                  this.m_pulseRingArray[_loc2_].pulseRingContainerSprite.x = 0;
                  this.m_pulseRingArray[_loc2_].pulseRingContainerSprite.y = RING_LOOSE_TARGET_Y_OFFSET;
                  this.animateRingContainerOffset(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite,0.2,0,RING_LOOSE_TARGET_Y_OFFSET,true);
                  _loc2_++;
               }
               this.animateGradientBg(4,true,true);
               this.m_loopTargetRingAnimsRunning = true;
            }
            else
            {
               _loc2_ = 0;
               while(_loc2_ < 4)
               {
                  Animate.kill(this.m_pulseRingArray[_loc2_].pulseRing);
                  this.animateRingTransition(this.m_pulseRingArray[_loc2_].pulseRing,0.2,0,RING_LOOSE_TARGET_START_SCALE,_loc2_);
                  Animate.kill(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite);
                  this.animateRingContainerOffset(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite,0.2,0,RING_LOOSE_TARGET_Y_OFFSET,true);
                  _loc2_++;
               }
               this.animateGradientBg(0.6,false,false);
               this.m_loopTargetRingAnimsRunning = false;
            }
         }
         else if(this.m_currentStep == TARGET_FOUND)
         {
            if(!this.m_loopTargetRingAnimsRunning)
            {
               _loc2_ = 0;
               while(_loc2_ < 4)
               {
                  this.animateSingleRing(this.m_pulseRingArray[_loc2_].pulseRing,3,_loc2_ * 0.75,RING_FOUND_TARGET_START_SCALE,RING_FOUND_TARGET_END_SCALE,1,0,true);
                  this.m_pulseRingArray[_loc2_].pulseRingContainerSprite.x = 0;
                  this.m_pulseRingArray[_loc2_].pulseRingContainerSprite.y = 0;
                  this.animateRingContainerOffset(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite,0.2,0,0,false);
                  _loc2_++;
               }
               this.animateGradientBg(6,true,true);
               this.m_loopTargetRingAnimsRunning = true;
            }
            else
            {
               _loc2_ = 0;
               while(_loc2_ < 4)
               {
                  Animate.kill(this.m_pulseRingArray[_loc2_].pulseRing);
                  this.animateRingTransition(this.m_pulseRingArray[_loc2_].pulseRing,0.2,0,RING_FOUND_TARGET_START_SCALE,_loc2_);
                  Animate.kill(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite);
                  this.animateRingContainerOffset(this.m_pulseRingArray[_loc2_].pulseRingContainerSprite,0.2,0,0,false);
                  _loc2_++;
               }
               this.animateGradientBg(0.6,false,false);
               this.m_loopTargetRingAnimsRunning = false;
            }
         }
      }
      
      private function animateGradientBg(param1:Number, param2:Boolean, param3:Boolean) : void
      {
         var speed:Number = param1;
         var show:Boolean = param2;
         var loop:Boolean = param3;
         if(show)
         {
            this.m_view.bg_mc.gradient_mc.scaleX = this.m_view.bg_mc.gradient_mc.scaleY = 0;
            this.m_view.bg_mc.gradient_mc.inner_mc.alpha = 0;
            Animate.delay(this.m_view.dots_mc,speed - speed / 12,function():void
            {
               m_view.dots_mc.alpha = 1;
               Animate.to(m_view.dots_mc,1,0,{"alpha":0},Animate.ExpoOut);
            });
            Animate.to(this.m_view.bg_mc.gradient_mc,speed,0,{
               "scaleX":2,
               "scaleY":2
            },Animate.ExpoIn,function():void
            {
               if(loop)
               {
                  animateGradientBg(speed,true,loop);
               }
            });
            Animate.to(this.m_view.bg_mc.gradient_mc.inner_mc,speed / 2,0,{"alpha":0.4},Animate.ExpoIn);
         }
         else
         {
            Animate.kill(this.m_view.dots_mc);
            Animate.kill(this.m_view.bg_mc.gradient_mc);
            Animate.kill(this.m_view.bg_mc.gradient_mc.inner_mc);
            Animate.to(this.m_view.dots_mc,1,0,{"alpha":0},Animate.ExpoOut);
            Animate.to(this.m_view.bg_mc.gradient_mc,speed,0,{
               "scaleX":2,
               "scaleY":2
            },Animate.ExpoOut);
            Animate.to(this.m_view.bg_mc.gradient_mc.inner_mc,speed / 2,0,{"alpha":0},Animate.ExpoIn);
         }
      }
      
      private function animateSingleRing(param1:*, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = false) : void
      {
         var clip:* = param1;
         var speed:Number = param2;
         var delay:Number = param3;
         var startScale:Number = param4;
         var endScale:Number = param5;
         var startAlpha:Number = param6;
         var endAlpha:Number = param7;
         var loop:Boolean = param8;
         Animate.fromTo(clip,speed,delay,{
            "scaleX":startScale,
            "scaleY":startScale,
            "alpha":startAlpha
         },{
            "scaleX":endScale,
            "scaleY":endScale,
            "alpha":endAlpha
         },Animate.Linear,function():void
         {
            if(loop)
            {
               animateSingleRing(clip,speed,0,startScale,endScale,startAlpha,endAlpha,loop);
            }
         });
      }
      
      private function animateRingTransition(param1:*, param2:Number, param3:Number, param4:Number, param5:int) : void
      {
         var clip:* = param1;
         var speed:Number = param2;
         var delay:Number = param3;
         var endScale:Number = param4;
         var count:int = param5;
         Animate.to(clip,speed,delay,{
            "scaleX":endScale,
            "scaleY":endScale
         },Animate.Linear,function():void
         {
            if(count >= m_pulseRingArray.length - 1)
            {
               animateLoopTargetRings(true);
            }
         });
      }
      
      private function animateRingContainerOffset(param1:*, param2:Number, param3:Number, param4:Number, param5:Boolean = false) : void
      {
         var clip:* = param1;
         var speed:Number = param2;
         var delay:Number = param3;
         var yOffset:Number = param4;
         var wriggle:Boolean = param5;
         var xPos:Number = wriggle ? MenuUtils.getRandomInRange(0,100,true) : 0;
         var yPos:Number = yOffset;
         Animate.to(clip,speed,delay,{
            "x":xPos,
            "y":yPos
         },Animate.Linear,function():void
         {
            if(wriggle)
            {
               animateRingContainerOffset(clip,2,0,yOffset,wriggle);
            }
         });
      }
      
      private function showHealth(param1:Boolean) : void
      {
         if(param1 != this.m_showHealth)
         {
            this.m_view.hack_health_mc.healthicon_mc.visible = param1;
            this.m_view.hack_health_mc.healthbar_mc.visible = param1;
            this.m_view.hack_health_mc.health_text_mc.visible = param1;
         }
         this.m_showHealth = param1;
      }
      
      public function setHackingHealthProgress(param1:Number, param2:Number, param3:Number, param4:int, param5:Boolean) : void
      {
         if(param5)
         {
            if(!this.m_hackHealthBarInstantiated)
            {
               this.instantiateAnimateHackHealthMc(true);
               this.m_view.hack_health_mc.visible = true;
               this.m_hackHealthBarInstantiated = true;
            }
            if(this.m_dontHackRecord)
            {
               this.m_view.hack_health_mc.hack_percentage_text_mc.title_txt.text = "";
            }
            else
            {
               MenuUtils.setupText(this.m_view.hack_health_mc.hack_percentage_text_mc.title_txt,this.addLeadingZero(Math.ceil(100 * param1)) + "%",28,MenuConstantsKnt.FONT_TYPE_NUMBERS_BOLD,MenuConstantsKnt.FontColorWhite);
            }
            var _loc6_:Number = param2 / param3;
            this.m_view.hack_health_mc.hackbar_mc.mask_mc.x = param1 * 179 - 179;
            this.m_view.hack_health_mc.healthbar_mc.mask_mc.x = _loc6_ * 179 - 179;
            if(param4 == TARGET_HACKING_OUT_OF_RANGE)
            {
               if(!this.m_stoppedHackBgLoopDueToHackingOutOfRange)
               {
                  this.animateLoopHackBarBg(false);
                  this.m_stoppedHackBgLoopDueToHackingOutOfRange = true;
               }
            }
            else if(param4 == TARGET_HACKING_COMPLETE || param4 == TARGET_HACKING_COMPLETE)
            {
               if(!this.m_stoppedHackBgLoopDueToHackingComplete)
               {
                  this.animateLoopHackBarBg(false);
                  this.m_stoppedHackBgLoopDueToHackingComplete = true;
               }
            }
            else
            {
               if(this.m_stoppedHackBgLoopDueToHackingOutOfRange)
               {
                  this.animateLoopHackBarBg(true);
                  this.m_stoppedHackBgLoopDueToHackingOutOfRange = false;
               }
               if(this.m_stoppedHackBgLoopDueToHackingComplete)
               {
                  this.animateLoopHackBarBg(true);
                  this.m_stoppedHackBgLoopDueToHackingComplete = false;
               }
            }
            if(this.m_showHealth)
            {
               if(_loc6_ <= 0.5 && _loc6_ > 0.25)
               {
                  if(!this.m_healtBarColorWasSetYellow)
                  {
                     MenuUtils.setColor(this.m_view.hack_health_mc.healthbar_mc.bar_mc,MenuConstantsKnt.COLOR_YELLOW,false);
                     this.m_healtBarColorWasSetYellow = true;
                     this.m_healtBarColorWasSetWhite = false;
                     this.m_healtBarColorWasSetRed = false;
                     if(this.m_lowHealthWarningPulsating)
                     {
                        this.pulsateLowHealthWarning(false);
                     }
                  }
               }
               else if(_loc6_ <= 0.25)
               {
                  if(!this.m_healtBarColorWasSetRed)
                  {
                     MenuUtils.setColor(this.m_view.hack_health_mc.healthbar_mc.bar_mc,MenuConstantsKnt.COLOR_RED,false);
                     this.m_healtBarColorWasSetYellow = false;
                     this.m_healtBarColorWasSetWhite = false;
                     this.m_healtBarColorWasSetRed = true;
                     if(!this.m_lowHealthWarningPulsating)
                     {
                        this.pulsateLowHealthWarning(true);
                     }
                  }
               }
               else if(!this.m_healtBarColorWasSetWhite)
               {
                  MenuUtils.setColor(this.m_view.hack_health_mc.healthbar_mc.bar_mc,MenuConstantsKnt.COLOR_WHITE,false);
                  this.m_healtBarColorWasSetYellow = false;
                  this.m_healtBarColorWasSetWhite = true;
                  this.m_healtBarColorWasSetRed = false;
                  if(this.m_lowHealthWarningPulsating)
                  {
                     this.pulsateLowHealthWarning(false);
                  }
               }
            }
            else if(this.m_lowHealthWarningPulsating)
            {
               this.pulsateLowHealthWarning(false);
            }
            return;
         }
         this.instantiateAnimateHackHealthMc(false);
         this.m_view.hack_health_mc.visible = false;
         this.pulsateLowHealthWarning(false);
         this.m_hackHealthBarInstantiated = false;
      }
      
      private function instantiateAnimateHackHealthMc(param1:Boolean) : void
      {
         Animate.kill(this.m_view.hack_health_mc);
         Animate.kill(this.m_view.hack_health_mc.hackicon_mc);
         Animate.kill(this.m_view.hack_health_mc.healthicon_mc);
         Animate.kill(this.m_view.hack_health_mc.healthbar_mc.bg_mc);
         Animate.kill(this.m_view.hack_health_mc.indents_mc);
         Animate.kill(this.m_view.hack_health_mc.hack_percentage_text_mc);
         this.animateLoopHackBarBg(false);
         this.m_view.hack_health_mc.x = 100;
         this.m_view.hack_health_mc.hackicon_mc.alpha = 0;
         this.m_view.hack_health_mc.healthicon_mc.alpha = 0;
         this.m_view.hack_health_mc.hackbar_mc.alpha = 0;
         this.m_view.hack_health_mc.healthbar_mc.alpha = 0;
         this.m_view.hack_health_mc.indents_mc.alpha = 0;
         this.m_view.hack_health_mc.indents_mc.scaleX = 0;
         this.m_view.hack_health_mc.hackbar_mc.mask_mc.x = -179;
         this.m_view.hack_health_mc.healthbar_mc.mask_mc.x = -179;
         this.m_view.hack_health_mc.healthbar_mc.bg_mc.gotoAndStop(0);
         this.m_view.hack_health_mc.hack_percentage_text_mc.alpha = 0;
         MenuUtils.setColor(this.m_view.hack_health_mc.healthbar_mc.bg_mc,MenuConstantsKnt.COLOR_WHITE,false);
         if(param1)
         {
            Animate.to(this.m_view.hack_health_mc,0.6,0,{"x":140},Animate.ExpoOut);
            Animate.to(this.m_view.hack_health_mc.hackicon_mc,0.6,0,{"alpha":0.8},Animate.ExpoOut);
            Animate.to(this.m_view.hack_health_mc.healthicon_mc,0.6,0,{"alpha":0.8},Animate.ExpoOut);
            Animate.to(this.m_view.hack_health_mc.hackbar_mc,0.6,0.3,{"alpha":1},Animate.Linear);
            Animate.to(this.m_view.hack_health_mc.healthbar_mc,0.6,0.3,{"alpha":1},Animate.Linear);
            Animate.to(this.m_view.hack_health_mc.indents_mc,0.6,0,{
               "alpha":1,
               "scaleX":1
            },Animate.ExpoOut);
            Animate.to(this.m_view.hack_health_mc.hack_percentage_text_mc,0.6,0.3,{"alpha":1},Animate.Linear);
            this.animateLoopHackBarBg(true);
         }
      }
      
      private function animateLoopHackBarBg(param1:Boolean) : void
      {
         var start:Boolean = param1;
         Animate.kill(this.m_view.hack_health_mc.hackbar_mc.bg_mc);
         this.m_view.hack_health_mc.hackbar_mc.bg_mc.gotoAndStop(0);
         if(start)
         {
            Animate.fromTo(this.m_view.hack_health_mc.hackbar_mc.bg_mc,0.6,0,{"frames":1},{"frames":24},Animate.Linear,function():void
            {
               animateLoopHackBarBg(true);
            });
         }
      }
      
      private function pulsateLowHealthWarning(param1:Boolean) : void
      {
         var start:Boolean = param1;
         Animate.kill(this.m_view.hack_health_mc.health_text_mc);
         this.m_view.hack_health_mc.health_text_mc.alpha = 0;
         if(start)
         {
            this.m_view.hack_health_mc.health_text_mc.alpha = 1;
            Animate.delay(this.m_view.hack_health_mc.health_text_mc,0.2,function():void
            {
               m_view.hack_health_mc.health_text_mc.alpha = 0;
               Animate.delay(m_view.hack_health_mc.health_text_mc,0.2,function():void
               {
                  pulsateLowHealthWarning(m_showHealth);
               });
            });
            this.m_lowHealthWarningPulsating = true;
         }
         else
         {
            this.m_lowHealthWarningPulsating = false;
         }
      }
      
      private function showHackingMessage(param1:Boolean, param2:int = 0, param3:Boolean = true) : void
      {
         Animate.kill(this.m_view.hack_health_mc.hack_text_mc);
         if(param1)
         {
            this.m_view.hack_health_mc.hack_text_mc.visible = param3;
            if(param2 == -1)
            {
               Animate.delay(this.m_view.hack_health_mc.hack_text_mc,0.2,this.showHackingMessage,param1,param2,!param3);
            }
            else
            {
               param2--;
               if(param2 > 0)
               {
                  Animate.delay(this.m_view.hack_health_mc.hack_text_mc,0.2,this.showHackingMessage,param1,param2,!param3);
               }
            }
         }
         else
         {
            this.m_view.hack_health_mc.hack_text_mc.visible = false;
         }
      }
      
      private function showTriangulationMessage(param1:Boolean, param2:int = 0, param3:Boolean = true) : void
      {
         Animate.kill(this.m_view.message_txt);
         if(param1)
         {
            this.m_view.message_txt.visible = param3;
            param2--;
            if(param2 > 0)
            {
               Animate.delay(this.m_view.message_txt,0.2,this.showTriangulationMessage,param1,param2,!param3);
            }
         }
         else
         {
            this.m_view.message_txt.visible = false;
         }
      }
      
      private function showGlitch(param1:Boolean) : void
      {
         if(param1 != this.m_glitching)
         {
            this.m_glitching = param1;
            this.glitch();
         }
      }
      
      private function glitch() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Point = null;
         if(this.m_glitching)
         {
            this.displaceBitmap = new BitmapData(160,160,true,8947848);
            _loc1_ = 0;
            while(_loc1_ < 5)
            {
               this.displaceBitmap.fillRect(new Rectangle(0,200 * Math.random(),200,200 * Math.random()),Math.random() * 16777215);
               _loc1_++;
            }
            _loc2_ = new Point(0,0);
            this.m_view.filters = [new DisplacementMapFilter(this.displaceBitmap,_loc2_,1,2,15,5,DisplacementMapFilterMode.WRAP,0,1)];
            Animate.delay(this.m_view,0.03 + Math.random() * 0.05,this.glitch);
         }
         else
         {
            this.m_view.filters = [];
            Animate.kill(this.m_view);
         }
      }
      
      private function setTextMessages(param1:String) : void
      {
         MenuUtils.setupText(this.m_view.hack_health_mc.hack_text_mc.title_txt,param1,16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
         this.m_view.hack_health_mc.hack_text_mc.title_txt.height = 100;
         this.m_view.hack_health_mc.hack_text_mc.y = -18 - this.m_view.hack_health_mc.hack_text_mc.title_txt.textHeight;
         MenuUtils.setupText(this.m_view.message_txt,param1,16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite,false);
         this.m_view.message_txt.y = -this.m_view.message_txt.textHeight / 2 + 54;
      }
      
      private function getStepTypeString(param1:int) : String
      {
         var _loc2_:String = "";
         switch(param1)
         {
            case TARGET_LOOSE_DIRECTION_FOUND:
               _loc2_ = "TARGET_LOOSE_DIRECTION_FOUND";
               break;
            case TARGET_NONE_SEARCH_AREA:
               _loc2_ = "TARGET_NONE_SEARCH_AREA";
               break;
            case TARGET_FOUND:
               _loc2_ = "TARGET_FOUND";
               break;
            case TARGET_HACKING_MODE:
               _loc2_ = "TARGET_HACKING_MODE";
               break;
            case TARGET_HACKING_OUT_OF_RANGE:
               _loc2_ = "TARGET_HACKING_OUT_OF_RANGE";
               break;
            case TARGET_HACKING_COMPLETE:
               _loc2_ = "TARGET_HACKING_COMPLETE";
               break;
            default:
               _loc2_ = "NONE / OFF";
         }
         return _loc2_;
      }
      
      private function addLeadingZero(param1:Number) : String
      {
         var _loc2_:String = param1.toString();
         if(param1 < 10)
         {
            _loc2_ = "00" + param1;
         }
         else if(param1 < 100)
         {
            _loc2_ = "0" + param1;
         }
         return _loc2_;
      }
      
      public function set HACK_DisplaceRecording_not_hacking(param1:Boolean) : void
      {
         this.m_dontHackRecord = param1;
      }
   }
}
