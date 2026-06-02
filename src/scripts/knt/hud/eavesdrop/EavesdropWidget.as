package knt.hud.eavesdrop
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class EavesdropWidget extends BaseControl
   {
      public static var s_isAimingWatchGlobal:Boolean = false;
      
      private static var s_instances:Array = [];
      
      private static const STATE_INACTIVE:int = 0;
      
      private static const STATE_VISIBLE:int = 1;
      
      private static const STATE_PREACTIVE:int = 2;
      
      private static const STATE_ACTIVE:int = 3;
      
      private static const STATE_INTERRUPTED:int = 4;
      
      private static const STATE_COMPLETED:int = 5;
      
      private static const STATE_FAILED:int = 6;
      
      private var m_state:int = -1;
      
      private var m_previousState:int = -1;
      
      private var m_view:EavesdropWidgetView;
      
      private var m_audioSpectrum:EavesdropWidgetAudioSpectrum;
      
      private var m_delaySprite:Sprite = new Sprite();
      
      private var m_incomingAudioLevel:Number = 0;
      
      private var m_interrupted:Boolean = false;
      
      private var m_testVisibleSet:Boolean = false;
      
      private var m_testPreactiveSet:Boolean = false;
      
      private var m_testActiveSet:Boolean = false;
      
      public static function setGlobalWatchState(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         s_isAimingWatchGlobal = param1;
         while(_loc2_ < s_instances.length)
         {
            EavesdropWidget(s_instances[_loc2_]).updateRootVisibility();
            _loc2_++;
         }
      }
      
      public function EavesdropWidget()
      {
         super();
         this.m_view = new EavesdropWidgetView();
         addChild(this.m_view);
         this.m_audioSpectrum = new EavesdropWidgetAudioSpectrum();
         this.m_view.container_mc.addChild(this.m_audioSpectrum);
         this.m_view.initializer_mc.visible = false;
         this.m_view.fivepins_bg_mc.visible = false;
         this.m_view.completed_mc.visible = false;
         this.m_view.failed_mc.visible = false;
         this.m_view.interrupted_mc.visible = false;
         this.m_view.debug_txt.visible = false;
         this.m_view.signalstrength_L_mc.visible = false;
         this.m_view.signalstrength_R_mc.visible = false;
         this.m_view.signalstrength_L_mc.bars_bg_mc.gotoAndStop(0);
         this.m_view.signalstrength_R_mc.bars_bg_mc.gotoAndStop(0);
         this.m_view.signalstrength_L_mc.bar_02.alpha = 0;
         this.m_view.signalstrength_L_mc.bar_01.alpha = 0;
         this.m_view.signalstrength_L_mc.bar_00.alpha = 0;
         this.m_view.signalstrength_R_mc.bar_02.alpha = 0;
         this.m_view.signalstrength_R_mc.bar_01.alpha = 0;
         this.m_view.signalstrength_R_mc.bar_00.alpha = 0;
         this.m_view.filters = [new DropShadowFilter(4,90,0,0.3,4,4,0.4,1)];
         s_instances.push(this);
         this.updateRootVisibility();
      }
      
      public function onSetData(param1:Object) : void
      {
         if(this.m_previousState == STATE_COMPLETED || this.m_previousState == STATE_FAILED)
         {
            return;
         }
         if(param1.m_playerDistance <= param1.m_preActivationRange && param1.m_playerDistance > param1.m_activationRange)
         {
            if(param1.m_state == STATE_VISIBLE)
            {
               param1.m_state = STATE_PREACTIVE;
            }
         }
         if(param1.m_state != this.m_previousState)
         {
            this.m_incomingAudioLevel = -1;
            switch(param1.m_state)
            {
               case STATE_INACTIVE:
                  MenuUtils.setupText(this.m_view.debug_txt,"STATE_INACTIVE",16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
                  this.m_view.debug_txt.alpha = 0.4;
                  this.hideWidget();
                  break;
               case STATE_VISIBLE:
                  MenuUtils.setupText(this.m_view.debug_txt,"STATE_VISIBLE",16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
                  this.m_view.debug_txt.alpha = 1;
                  this.setWidgetVisible();
                  break;
               case STATE_PREACTIVE:
                  MenuUtils.setupText(this.m_view.debug_txt,"STATE_PREACTIVE",16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
                  this.m_view.debug_txt.alpha = 1;
                  this.setWidgetActivable();
                  break;
               case STATE_ACTIVE:
                  MenuUtils.setupText(this.m_view.debug_txt,"STATE_ACTIVE",16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
                  this.m_view.debug_txt.alpha = 1;
                  this.setWidgetActive();
                  break;
               case STATE_INTERRUPTED:
                  MenuUtils.setupText(this.m_view.debug_txt,"STATE_INTERRUPTED",16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
                  this.m_view.debug_txt.alpha = 1;
                  if(!this.m_interrupted)
                  {
                     this.setWidgetInterrupted();
                     this.m_interrupted = true;
                  }
                  break;
               case STATE_COMPLETED:
                  MenuUtils.setupText(this.m_view.debug_txt,"STATE_COMPLETED",16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
                  this.m_view.debug_txt.alpha = 1;
                  this.setWidgetCompletedOrFailedAndRemove(param1.m_state);
                  break;
               case STATE_FAILED:
                  MenuUtils.setupText(this.m_view.debug_txt,"STATE_FAILED",16,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
                  this.m_view.debug_txt.alpha = 1;
                  this.setWidgetCompletedOrFailedAndRemove(param1.m_state);
            }
            this.m_state = param1.m_state;
            this.m_previousState = param1.m_state;
         }
         if(param1.m_state == STATE_PREACTIVE || param1.m_state == STATE_ACTIVE)
         {
            this.setSignalStrength(param1.m_playerDistance,param1.m_preActivationRange,param1.m_activationRange);
         }
         this.updateRootVisibility();
      }
      
      private function setWidgetVisible() : void
      {
         MenuUtils.removeColor(this.m_view.initializer_mc,true);
         MenuUtils.removeColor(this.m_view,true);
         Animate.kill(this.m_view.initializer_mc);
         Animate.kill(this.m_view.interrupted_mc);
         this.m_view.interrupted_mc.visible = false;
         this.m_interrupted = false;
         if(this.m_previousState == STATE_PREACTIVE || this.m_previousState == STATE_ACTIVE)
         {
            Animate.kill(this.m_view.signalstrength_L_mc);
            Animate.kill(this.m_view.signalstrength_R_mc);
            Animate.kill(this.m_view.signalstrength_L_mc.bars_bg_mc);
            Animate.kill(this.m_view.signalstrength_R_mc.bars_bg_mc);
            this.m_view.signalstrength_L_mc.bar_02.alpha = 0;
            this.m_view.signalstrength_L_mc.bar_01.alpha = 0;
            this.m_view.signalstrength_L_mc.bar_00.alpha = 0;
            this.m_view.signalstrength_R_mc.bar_02.alpha = 0;
            this.m_view.signalstrength_R_mc.bar_01.alpha = 0;
            this.m_view.signalstrength_R_mc.bar_00.alpha = 0;
            Animate.to(this.m_view.signalstrength_L_mc,0.2,0,{"x":0},Animate.BackOut);
            Animate.to(this.m_view.signalstrength_R_mc,0.2,0,{"x":0},Animate.BackOut,function():void
            {
               m_view.signalstrength_L_mc.visible = false;
               m_view.signalstrength_R_mc.visible = false;
               Animate.kill(m_view.fivepins_bg_mc);
               m_view.fivepins_bg_mc.visible = false;
               m_view.fivepins_bg_mc.gotoAndStop(0);
               m_view.initializer_mc.gotoAndStop(31);
               m_view.initializer_mc.visible = true;
            });
            MenuUtils.removeColor(this.m_view.signalstrength_L_mc.bars_bg_mc,true);
            MenuUtils.removeColor(this.m_view.signalstrength_R_mc.bars_bg_mc,true);
            Animate.fromTo(this.m_view.signalstrength_L_mc.bars_bg_mc,0.2,0,{
               "frames":this.m_view.signalstrength_L_mc.bars_bg_mc.currentFrame,
               "alpha":this.m_view.signalstrength_L_mc.bars_bg_mc.alpha
            },{
               "frames":1,
               "alpha":1
            },Animate.Linear);
            Animate.fromTo(this.m_view.signalstrength_R_mc.bars_bg_mc,0.2,0,{
               "frames":this.m_view.signalstrength_R_mc.bars_bg_mc.currentFrame,
               "alpha":this.m_view.signalstrength_R_mc.bars_bg_mc.alpha
            },{
               "frames":1,
               "alpha":1
            },Animate.Linear);
         }
         else
         {
            this.m_view.initializer_mc.gotoAndStop(1);
            this.m_view.initializer_mc.visible = true;
            Animate.fromTo(this.m_view.initializer_mc,0.27,0,{"frames":1},{"frames":31},Animate.Linear);
         }
         this.m_audioSpectrum.loopAudioSpectrum(false);
      }
      
      private function setWidgetActivable() : void
      {
         MenuUtils.removeColor(this.m_view,true);
         Animate.kill(this.m_view.signalstrength_L_mc);
         Animate.kill(this.m_view.signalstrength_R_mc);
         Animate.kill(this.m_view.signalstrength_L_mc.bars_bg_mc);
         Animate.kill(this.m_view.signalstrength_R_mc.bars_bg_mc);
         Animate.kill(this.m_view.initializer_mc);
         this.m_view.initializer_mc.visible = false;
         Animate.kill(this.m_view.interrupted_mc);
         this.m_view.interrupted_mc.visible = false;
         this.m_interrupted = false;
         if(this.m_previousState == -1 || this.m_previousState == STATE_INTERRUPTED || this.m_previousState == STATE_INACTIVE || this.m_previousState == STATE_VISIBLE)
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.gotoAndStop(7);
            this.m_view.fivepins_bg_mc.visible = true;
            this.m_view.signalstrength_L_mc.x = 0;
            this.m_view.signalstrength_R_mc.x = 0;
            this.m_view.signalstrength_L_mc.bars_bg_mc.gotoAndStop(0);
            this.m_view.signalstrength_R_mc.bars_bg_mc.gotoAndStop(0);
         }
         else if(this.m_previousState == STATE_ACTIVE)
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = true;
            Animate.fromTo(this.m_view.fivepins_bg_mc,0.2,0,{"frames":this.m_view.fivepins_bg_mc.currentFrame},{"frames":7},Animate.Linear);
         }
         this.m_view.signalstrength_L_mc.visible = true;
         this.m_view.signalstrength_R_mc.visible = true;
         Animate.to(this.m_view.signalstrength_L_mc,0.2,0.2,{"x":-10},Animate.BackOut);
         Animate.to(this.m_view.signalstrength_R_mc,0.2,0.2,{"x":10},Animate.BackOut);
         MenuUtils.setColor(this.m_view.signalstrength_L_mc.bars_bg_mc,MenuConstantsKnt.COLOR_WHITE,false);
         MenuUtils.setColor(this.m_view.signalstrength_R_mc.bars_bg_mc,MenuConstantsKnt.COLOR_WHITE,false);
         Animate.fromTo(this.m_view.signalstrength_L_mc.bars_bg_mc,0.2,0,{
            "frames":this.m_view.signalstrength_L_mc.bars_bg_mc.currentFrame,
            "alpha":this.m_view.signalstrength_L_mc.bars_bg_mc.alpha
         },{
            "frames":3,
            "alpha":0.2
         },Animate.Linear);
         Animate.fromTo(this.m_view.signalstrength_R_mc.bars_bg_mc,0.2,0,{
            "frames":this.m_view.signalstrength_R_mc.bars_bg_mc.currentFrame,
            "alpha":this.m_view.signalstrength_R_mc.bars_bg_mc.alpha
         },{
            "frames":3,
            "alpha":0.2
         },Animate.Linear);
         this.m_audioSpectrum.loopAudioSpectrum(false);
      }
      
      private function setWidgetActive() : void
      {
         MenuUtils.removeColor(this.m_view,true);
         Animate.kill(this.m_view.signalstrength_L_mc);
         Animate.kill(this.m_view.signalstrength_R_mc);
         Animate.kill(this.m_view.signalstrength_L_mc.bars_bg_mc);
         Animate.kill(this.m_view.signalstrength_R_mc.bars_bg_mc);
         Animate.kill(this.m_view.initializer_mc);
         this.m_view.initializer_mc.visible = false;
         Animate.kill(this.m_view.interrupted_mc);
         this.m_view.interrupted_mc.visible = false;
         this.m_interrupted = false;
         this.m_view.signalstrength_L_mc.x = 0;
         this.m_view.signalstrength_R_mc.x = 0;
         this.m_view.signalstrength_L_mc.bars_bg_mc.gotoAndStop(0);
         this.m_view.signalstrength_R_mc.bars_bg_mc.gotoAndStop(0);
         this.m_view.signalstrength_L_mc.visible = true;
         this.m_view.signalstrength_R_mc.visible = true;
         if(this.m_previousState == -1 || this.m_previousState == STATE_INTERRUPTED || this.m_previousState == STATE_INACTIVE || this.m_previousState == STATE_VISIBLE)
         {
            this.m_view.signalstrength_L_mc.x = 0;
            this.m_view.signalstrength_R_mc.x = 0;
            this.m_view.signalstrength_L_mc.bars_bg_mc.gotoAndStop(0);
            this.m_view.signalstrength_R_mc.bars_bg_mc.gotoAndStop(0);
            this.m_view.signalstrength_L_mc.visible = true;
            this.m_view.signalstrength_R_mc.visible = true;
         }
         else if(this.m_previousState == STATE_PREACTIVE)
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = true;
            Animate.fromTo(this.m_view.fivepins_bg_mc,0.2,0,{"frames":this.m_view.fivepins_bg_mc.currentFrame},{"frames":1},Animate.Linear,function():void
            {
               m_view.fivepins_bg_mc.visible = false;
            });
         }
         Animate.to(this.m_view.signalstrength_L_mc,0.2,0,{"x":-50},Animate.BackOut);
         Animate.to(this.m_view.signalstrength_R_mc,0.2,0,{"x":50},Animate.BackOut);
         MenuUtils.setColor(this.m_view.signalstrength_L_mc.bars_bg_mc,MenuConstantsKnt.COLOR_WHITE,false);
         MenuUtils.setColor(this.m_view.signalstrength_R_mc.bars_bg_mc,MenuConstantsKnt.COLOR_WHITE,false);
         Animate.fromTo(this.m_view.signalstrength_L_mc.bars_bg_mc,0.2,0,{
            "frames":this.m_view.signalstrength_L_mc.bars_bg_mc.currentFrame,
            "alpha":this.m_view.signalstrength_L_mc.bars_bg_mc.alpha
         },{
            "frames":3,
            "alpha":0.2
         },Animate.Linear);
         Animate.fromTo(this.m_view.signalstrength_R_mc.bars_bg_mc,0.2,0,{
            "frames":this.m_view.signalstrength_R_mc.bars_bg_mc.currentFrame,
            "alpha":this.m_view.signalstrength_R_mc.bars_bg_mc.alpha
         },{
            "frames":3,
            "alpha":0.2
         },Animate.Linear);
         this.m_audioSpectrum.loopAudioSpectrum(true);
      }
      
      private function setWidgetInterrupted() : void
      {
         MenuUtils.removeColor(this.m_view,true);
         this.m_audioSpectrum.loopAudioSpectrum(false);
         MenuUtils.removeColor(this.m_view.initializer_mc,true);
         Animate.kill(this.m_view.signalstrength_L_mc);
         Animate.kill(this.m_view.signalstrength_R_mc);
         Animate.kill(this.m_view.signalstrength_L_mc.bars_bg_mc);
         Animate.kill(this.m_view.signalstrength_R_mc.bars_bg_mc);
         Animate.kill(this.m_view.initializer_mc);
         if(this.m_previousState == STATE_PREACTIVE || this.m_previousState == STATE_ACTIVE)
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = true;
            Animate.fromTo(this.m_view.fivepins_bg_mc,0.2,0,{"frames":this.m_view.fivepins_bg_mc.currentFrame},{"frames":1},Animate.Linear,function():void
            {
               m_view.fivepins_bg_mc.visible = false;
            });
            Animate.to(this.m_view.signalstrength_L_mc,0.2,0,{"x":0},Animate.BackOut);
            Animate.to(this.m_view.signalstrength_R_mc,0.2,0,{"x":0},Animate.BackOut,function():void
            {
               m_view.signalstrength_L_mc.visible = false;
               m_view.signalstrength_R_mc.visible = false;
               m_view.initializer_mc.gotoAndStop(31);
               m_view.initializer_mc.visible = true;
               Animate.fromTo(m_view.initializer_mc,0.27,0,{"frames":31},{"frames":1},Animate.Linear,function():void
               {
                  m_view.initializer_mc.visible = false;
               });
            });
            MenuUtils.removeColor(this.m_view.signalstrength_L_mc.bars_bg_mc,true);
            MenuUtils.removeColor(this.m_view.signalstrength_R_mc.bars_bg_mc,true);
            Animate.fromTo(this.m_view.signalstrength_L_mc.bars_bg_mc,0.2,0,{
               "frames":this.m_view.signalstrength_L_mc.bars_bg_mc.currentFrame,
               "alpha":this.m_view.signalstrength_L_mc.bars_bg_mc.alpha
            },{
               "frames":1,
               "alpha":1
            },Animate.Linear);
            Animate.fromTo(this.m_view.signalstrength_R_mc.bars_bg_mc,0.2,0,{
               "frames":this.m_view.signalstrength_R_mc.bars_bg_mc.currentFrame,
               "alpha":this.m_view.signalstrength_R_mc.bars_bg_mc.alpha
            },{
               "frames":1,
               "alpha":1
            },Animate.Linear);
         }
         else if(this.m_previousState == STATE_VISIBLE)
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = false;
            this.m_view.fivepins_bg_mc.gotoAndStop(0);
            this.m_view.initializer_mc.visible = true;
            this.m_view.initializer_mc.gotoAndStop(31);
            Animate.fromTo(this.m_view.initializer_mc,0.27,0,{"frames":31},{"frames":1},Animate.Linear,function():void
            {
               m_view.initializer_mc.visible = false;
            });
         }
         else
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = false;
            this.m_view.fivepins_bg_mc.gotoAndStop(0);
            this.m_view.signalstrength_L_mc.visible = false;
            this.m_view.signalstrength_R_mc.visible = false;
            this.m_view.initializer_mc.visible = true;
         }
         Animate.kill(this.m_view.interrupted_mc);
         this.m_view.interrupted_mc.gotoAndStop(0);
         MenuUtils.removeColor(this.m_view.interrupted_mc);
         this.m_view.interrupted_mc.visible = true;
         Animate.fromTo(this.m_view.interrupted_mc,0.37,0.27,{"frames":1},{"frames":49},Animate.Linear,function():void
         {
            Animate.delay(m_view.interrupted_mc,1,function():void
            {
               MenuUtils.setColor(m_view.interrupted_mc,MenuConstantsKnt.COLOR_RED,false);
               Animate.fromTo(m_view.interrupted_mc,0.27,0.27,{"frames":50},{"frames":80},Animate.Linear,function():void
               {
                  m_view.interrupted_mc.visible = false;
               });
            });
         });
      }
      
      private function setWidgetCompletedOrFailedAndRemove(param1:int) : void
      {
         var endClip:MovieClip = null;
         var state:int = param1;
         MenuUtils.removeColor(this.m_view,true);
         this.m_audioSpectrum.loopAudioSpectrum(false);
         Animate.kill(this.m_view.signalstrength_L_mc);
         Animate.kill(this.m_view.signalstrength_R_mc);
         Animate.kill(this.m_view.signalstrength_L_mc.bars_bg_mc);
         Animate.kill(this.m_view.signalstrength_R_mc.bars_bg_mc);
         Animate.kill(this.m_view.initializer_mc);
         this.m_view.initializer_mc.visible = false;
         Animate.kill(this.m_view.interrupted_mc);
         this.m_view.interrupted_mc.visible = false;
         this.m_interrupted = false;
         endClip = state == STATE_COMPLETED ? this.m_view.completed_mc : this.m_view.failed_mc;
         if(this.m_previousState == STATE_PREACTIVE || this.m_previousState == STATE_ACTIVE)
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            MenuUtils.setColor(this.m_view.fivepins_bg_mc,state == STATE_COMPLETED ? uint(MenuConstantsKnt.COLOR_GREEN) : uint(MenuConstantsKnt.COLOR_RED),false);
            Animate.delay(this.m_view.fivepins_bg_mc,0.4,function():void
            {
               m_view.fivepins_bg_mc.visible = true;
               Animate.fromTo(m_view.fivepins_bg_mc,0.2,0,{"frames":m_view.fivepins_bg_mc.currentFrame},{"frames":7},Animate.Linear);
            });
            Animate.to(this.m_view.signalstrength_L_mc,0.2,0.4,{"x":0},Animate.BackOut);
            Animate.to(this.m_view.signalstrength_R_mc,0.2,0.4,{"x":0},Animate.BackOut,function():void
            {
               m_view.signalstrength_L_mc.visible = false;
               m_view.signalstrength_R_mc.visible = false;
               m_view.fivepins_bg_mc.visible = false;
               MenuUtils.removeColor(endClip);
               endClip.visible = true;
               Animate.fromTo(endClip,0.2,0,{"frames":1},{"frames":20},Animate.Linear,function():void
               {
                  MenuUtils.setColor(endClip,state == STATE_COMPLETED ? uint(MenuConstantsKnt.COLOR_GREEN) : uint(MenuConstantsKnt.COLOR_RED),false);
                  Animate.fromTo(endClip,0.27,1,{"frames":21},{"frames":50},Animate.Linear,function():void
                  {
                     m_view.debug_txt.visible = false;
                     m_audioSpectrum.removeAudioSpectrum();
                     while(m_view.container_mc.numChildren > 0)
                     {
                        m_view.container_mc.removeChildAt(0);
                     }
                     m_view.visible = false;
                     m_view = null;
                  });
               });
            });
            Animate.fromTo(this.m_view.signalstrength_L_mc.bars_bg_mc,0.2,0.4,{
               "frames":this.m_view.signalstrength_L_mc.bars_bg_mc.currentFrame,
               "alpha":this.m_view.signalstrength_L_mc.bars_bg_mc.alpha
            },{
               "frames":1,
               "alpha":1
            },Animate.Linear);
            Animate.fromTo(this.m_view.signalstrength_R_mc.bars_bg_mc,0.2,0.4,{
               "frames":this.m_view.signalstrength_R_mc.bars_bg_mc.currentFrame,
               "alpha":this.m_view.signalstrength_R_mc.bars_bg_mc.alpha
            },{
               "frames":1,
               "alpha":1
            },Animate.Linear);
         }
         else
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = false;
            this.m_view.signalstrength_L_mc.visible = false;
            this.m_view.signalstrength_R_mc.visible = false;
            MenuUtils.removeColor(endClip);
            endClip.visible = true;
            Animate.fromTo(endClip,0.2,0,{"frames":1},{"frames":20},Animate.Linear,function():void
            {
               MenuUtils.setColor(endClip,state == STATE_COMPLETED ? uint(MenuConstantsKnt.COLOR_GREEN) : uint(MenuConstantsKnt.COLOR_RED),false);
               Animate.fromTo(endClip,0.27,1,{"frames":21},{"frames":50},Animate.Linear,function():void
               {
                  m_view.debug_txt.visible = false;
                  m_audioSpectrum.removeAudioSpectrum();
                  while(m_view.container_mc.numChildren > 0)
                  {
                     m_view.container_mc.removeChildAt(0);
                  }
                  m_view.visible = false;
                  m_view = null;
               });
            });
         }
      }
      
      private function hideWidget() : void
      {
         MenuUtils.removeColor(this.m_view,true);
         this.m_audioSpectrum.loopAudioSpectrum(false);
         MenuUtils.removeColor(this.m_view.initializer_mc,true);
         Animate.kill(this.m_view.signalstrength_L_mc);
         Animate.kill(this.m_view.signalstrength_R_mc);
         Animate.kill(this.m_view.signalstrength_L_mc.bars_bg_mc);
         Animate.kill(this.m_view.signalstrength_R_mc.bars_bg_mc);
         Animate.kill(this.m_view.initializer_mc);
         Animate.kill(this.m_view.interrupted_mc);
         this.m_view.interrupted_mc.visible = false;
         if(this.m_previousState == STATE_PREACTIVE || this.m_previousState == STATE_ACTIVE)
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = true;
            Animate.fromTo(this.m_view.fivepins_bg_mc,0.2,0,{"frames":this.m_view.fivepins_bg_mc.currentFrame},{"frames":1},Animate.Linear,function():void
            {
               m_view.fivepins_bg_mc.visible = false;
            });
            Animate.to(this.m_view.signalstrength_L_mc,0.2,0,{"x":0},Animate.BackOut);
            Animate.to(this.m_view.signalstrength_R_mc,0.2,0,{"x":0},Animate.BackOut,function():void
            {
               m_view.signalstrength_L_mc.visible = false;
               m_view.signalstrength_R_mc.visible = false;
               m_view.initializer_mc.gotoAndStop(31);
               m_view.initializer_mc.visible = true;
               Animate.fromTo(m_view.initializer_mc,0.27,0,{"frames":31},{"frames":1},Animate.Linear,function():void
               {
                  m_view.initializer_mc.visible = false;
               });
            });
            MenuUtils.removeColor(this.m_view.signalstrength_L_mc.bars_bg_mc,true);
            MenuUtils.removeColor(this.m_view.signalstrength_R_mc.bars_bg_mc,true);
            Animate.fromTo(this.m_view.signalstrength_L_mc.bars_bg_mc,0.2,0,{
               "frames":this.m_view.signalstrength_L_mc.bars_bg_mc.currentFrame,
               "alpha":this.m_view.signalstrength_L_mc.bars_bg_mc.alpha
            },{
               "frames":1,
               "alpha":1
            },Animate.Linear);
            Animate.fromTo(this.m_view.signalstrength_R_mc.bars_bg_mc,0.2,0,{
               "frames":this.m_view.signalstrength_R_mc.bars_bg_mc.currentFrame,
               "alpha":this.m_view.signalstrength_R_mc.bars_bg_mc.alpha
            },{
               "frames":1,
               "alpha":1
            },Animate.Linear);
         }
         else if(this.m_previousState == STATE_VISIBLE)
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = false;
            this.m_view.fivepins_bg_mc.gotoAndStop(0);
            this.m_view.initializer_mc.visible = true;
            this.m_view.initializer_mc.gotoAndStop(31);
            Animate.fromTo(this.m_view.initializer_mc,0.27,0,{"frames":31},{"frames":1},Animate.Linear,function():void
            {
               m_view.initializer_mc.visible = false;
            });
         }
         else
         {
            Animate.kill(this.m_view.fivepins_bg_mc);
            this.m_view.fivepins_bg_mc.visible = false;
            this.m_view.fivepins_bg_mc.gotoAndStop(0);
            this.m_view.signalstrength_L_mc.visible = false;
            this.m_view.signalstrength_R_mc.visible = false;
            this.m_view.initializer_mc.visible = true;
         }
      }
      
      private function setSignalStrength(param1:Number, param2:int, param3:int) : void
      {
         var _loc4_:Number = (param2 - param3) / 4;
         var _loc5_:Number = 0;
         if(param1 <= param2 && param1 > _loc4_ * 3 + param3)
         {
            _loc5_ = 1 - (param1 - param3 - _loc4_ * 3) / _loc4_;
            this.m_view.signalstrength_L_mc.bar_02.alpha = 0;
            this.m_view.signalstrength_L_mc.bar_01.alpha = 0;
            this.m_view.signalstrength_L_mc.bar_00.alpha = _loc5_;
            this.m_view.signalstrength_R_mc.bar_02.alpha = 0;
            this.m_view.signalstrength_R_mc.bar_01.alpha = 0;
            this.m_view.signalstrength_R_mc.bar_00.alpha = _loc5_;
         }
         else if(param1 <= _loc4_ * 3 + param3 && param1 > _loc4_ * 2 + param3)
         {
            _loc5_ = 1 - (param1 - param3 - _loc4_ * 2) / _loc4_;
            this.m_view.signalstrength_L_mc.bar_02.alpha = 0;
            this.m_view.signalstrength_L_mc.bar_01.alpha = _loc5_;
            this.m_view.signalstrength_L_mc.bar_00.alpha = 1;
            this.m_view.signalstrength_R_mc.bar_02.alpha = 0;
            this.m_view.signalstrength_R_mc.bar_01.alpha = _loc5_;
            this.m_view.signalstrength_R_mc.bar_00.alpha = 1;
         }
         else if(param1 <= _loc4_ * 2 + param3 && param1 > _loc4_ + param3)
         {
            _loc5_ = 1 - (param1 - param3 - _loc4_) / _loc4_;
            this.m_view.signalstrength_L_mc.bar_02.alpha = _loc5_;
            this.m_view.signalstrength_L_mc.bar_01.alpha = 1;
            this.m_view.signalstrength_L_mc.bar_00.alpha = 1;
            this.m_view.signalstrength_R_mc.bar_02.alpha = _loc5_;
            this.m_view.signalstrength_R_mc.bar_01.alpha = 1;
            this.m_view.signalstrength_R_mc.bar_00.alpha = 1;
         }
         else if(param1 <= param3)
         {
            this.m_view.signalstrength_L_mc.bar_02.alpha = 1;
            this.m_view.signalstrength_L_mc.bar_01.alpha = 1;
            this.m_view.signalstrength_L_mc.bar_00.alpha = 1;
            this.m_view.signalstrength_R_mc.bar_02.alpha = 1;
            this.m_view.signalstrength_R_mc.bar_01.alpha = 1;
            this.m_view.signalstrength_R_mc.bar_00.alpha = 1;
         }
      }
      
      public function toggleDebugTextOnOff() : void
      {
         this.m_view.debug_txt.visible = !this.m_view.debug_txt.visible;
      }
      
      public function set AudioLevel(param1:Number) : void
      {
         if(this.m_state == STATE_ACTIVE)
         {
            this.m_incomingAudioLevel = MenuUtils.roundDecimal(param1,1);
         }
         else
         {
            this.m_incomingAudioLevel = -1;
         }
         this.m_audioSpectrum.setAudioSpectrumVolume(this.m_incomingAudioLevel);
      }
      
      private function updateRootVisibility() : void
      {
         if(this.m_view == null)
         {
            return;
         }
         this.m_view.visible = s_isAimingWatchGlobal && this.shouldDisplayCurrentState();
         if(!s_isAimingWatchGlobal)
         {
            this.m_audioSpectrum.loopAudioSpectrum(false);
         }
         else if(this.m_state == STATE_ACTIVE)
         {
            this.m_audioSpectrum.loopAudioSpectrum(true);
         }
      }
      
      private function shouldDisplayCurrentState() : Boolean
      {
         return this.m_previousState != -1 && this.m_previousState != STATE_INACTIVE;
      }
   }
}

