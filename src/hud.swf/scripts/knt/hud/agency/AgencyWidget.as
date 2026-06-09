package knt.hud.agency
{
   import flash.display.BlendMode;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class AgencyWidget extends BaseControl
   {
      
      private static const ANIM_SPEED:Number = 0.4;
      
      private static const ANIM_SPEED_FAST:Number = 0.2;
      
      private static const ANIM_DELAY:Number = 0.2;
      
      private static const BASE_SCALE:Number = 0.75;
      
      private static const AIMING_SCALE:Number = BASE_SCALE * 1.3;
      
      private var m_view:AgencyWidgetView;
      
      private var m_previousAgencyValue:Number = 0;
      
      private var m_isAimingWatch:Boolean = false;
      
      private var m_isGreyedOutDueToSocial:Boolean = false;
      
      private var m_isAnyAgencyMoveAvailable:Boolean = false;
      
      private var m_flareLoopIsRunning:Boolean = false;
      
      public function AgencyWidget()
      {
         super();
         this.m_view = new AgencyWidgetView();
         addChild(this.m_view);
         if(MenuConstantsKnt.INVERT_Q_WATCH_DISPLAY)
         {
            this.m_view.scaleX = this.m_view.scaleY = AIMING_SCALE;
            this.m_view.x = -180;
            this.m_view.y = 100;
            this.m_view.alpha = 0;
            this.m_isAimingWatch = true;
         }
         else
         {
            this.m_view.scaleX = this.m_view.scaleY = BASE_SCALE;
            this.m_view.x = 0;
            this.m_view.y = 0;
            this.m_view.alpha = 1;
            this.m_isAimingWatch = false;
         }
         this.m_view.dropshadow_mc.alpha = 0.4;
         this.showQuickFlare(false);
         this.showFullBarGlow(false);
         this.loopFlares(false);
         this.m_view.bars_mc.inner_bars_mc.bar_pin_mc.rotation = -90;
         this.m_view.bars_mc.inner_bars_mc.bar_mc.mask_mc.rotation = -90;
         this.m_view.bars_mc.inner_bars_mc.bar_gain_mc.mask_mc.rotation = -90;
         this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.mask_mc.rotation = -90;
         MenuUtils.setColor(this.m_view.bar_ends_mc,MenuConstantsKnt.COLOR_QTE,false);
         MenuUtils.setColor(this.m_view.bars_mc.inner_bars_mc.bar_pin_mc,MenuConstantsKnt.COLOR_QTE,false);
         MenuUtils.setColor(this.m_view.bars_mc.inner_bars_mc.bar_mc,MenuConstantsKnt.COLOR_AGENCY,false);
         MenuUtils.setColor(this.m_view.bars_mc.inner_bars_mc.bar_gain_mc,MenuConstantsKnt.COLOR_QTE,false);
         MenuUtils.setColor(this.m_view.bars_mc.inner_bars_mc.bar_loss_mc,MenuConstantsKnt.COLOR_QTE,false);
         this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.alpha = 0.24;
         this.m_view.bars_mc.inner_bars_mc.bar_gain_mc.visible = false;
         this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.visible = false;
         this.m_view.numb_mc.alpha = 0.6;
         this.m_view.glow_mc.alpha = 0;
         this.m_view.glow_mc.glow_01_mc.alpha = 0;
         this.m_view.glow_mc.glow_02_mc.alpha = 0;
         this.m_view.glow_mc.glow_03_mc.alpha = 0;
         this.m_view.gradient_mc.visible = false;
         MenuUtils.setColor(this.m_view.icon_mc.inner_mc,MenuConstantsKnt.COLOR_AGENCY,false);
         this.m_view.flares_mc.blendMode = BlendMode.ADD;
         this.m_view.glow_mc.blendMode = BlendMode.ADD;
         this.m_view.bars_mc.bar_bg_mc.dark_bg_mc.alpha = 0.1;
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Number = NaN;
         this.m_view.gradient_mc.visible = false;
         if(Boolean(param1.isLethalForceEnabled) || Boolean(param1.isTrespassing) || Boolean(param1.isLicenseToPunch) || Boolean(param1.isSoftTrespassing))
         {
            if(this.m_isGreyedOutDueToSocial)
            {
               Animate.kill(this.m_view.bar_ends_mc);
               Animate.kill(this.m_view.bars_mc.inner_bars_mc);
               Animate.kill(this.m_view.icon_mc);
               Animate.kill(this.m_view.icon_mc.inner_mc);
               Animate.kill(this.m_view.numb_mc);
               Animate.kill(this.m_view.bars_mc.bar_bg_mc);
               Animate.kill(this.m_view.bars_mc.bar_bg_mc.outline_bg_mc);
               Animate.to(this.m_view.bar_ends_mc,0.2,0,{"alpha":1},Animate.ExpoOut);
               Animate.to(this.m_view.bars_mc.inner_bars_mc,0.2,0,{"alpha":1},Animate.ExpoOut);
               Animate.to(this.m_view.icon_mc.inner_mc,0.2,0,{"color":MenuConstantsKnt.COLOR_AGENCY},Animate.ExpoOut);
               Animate.to(this.m_view.icon_mc,0.2,0,{"alpha":1},Animate.ExpoOut);
               Animate.to(this.m_view.numb_mc,0.2,0,{"alpha":0.6},Animate.ExpoOut);
               Animate.to(this.m_view.bars_mc.bar_bg_mc,0.2,0,{"alpha":1},Animate.ExpoOut);
               Animate.to(this.m_view.bars_mc.bar_bg_mc.outline_bg_mc,0.2,0,{"alpha":0.2},Animate.ExpoOut);
               this.m_isGreyedOutDueToSocial = false;
            }
         }
         else if(!this.m_isGreyedOutDueToSocial)
         {
            Animate.kill(this.m_view.bar_ends_mc);
            Animate.kill(this.m_view.bars_mc.inner_bars_mc);
            Animate.kill(this.m_view.icon_mc);
            Animate.kill(this.m_view.icon_mc.inner_mc);
            Animate.kill(this.m_view.numb_mc);
            Animate.kill(this.m_view.bars_mc.bar_bg_mc);
            Animate.kill(this.m_view.bars_mc.bar_bg_mc.outline_bg_mc);
            this.showQuickFlare(false);
            this.showFullBarGlow(false);
            this.loopFlares(false);
            Animate.to(this.m_view.bar_ends_mc,0.2,0,{"alpha":0.2},Animate.ExpoOut);
            Animate.to(this.m_view.bars_mc.inner_bars_mc,0.2,0,{"alpha":0.2},Animate.ExpoOut);
            Animate.to(this.m_view.icon_mc.inner_mc,0.2,0,{"color":MenuConstantsKnt.COLOR_WHITE},Animate.ExpoOut);
            Animate.to(this.m_view.icon_mc,0.2,0,{"alpha":0.4},Animate.ExpoOut);
            Animate.to(this.m_view.numb_mc,0.2,0,{"alpha":0.2},Animate.ExpoOut);
            Animate.to(this.m_view.bars_mc.bar_bg_mc,0.2,0,{"alpha":0.4},Animate.ExpoOut);
            Animate.to(this.m_view.bars_mc.bar_bg_mc.outline_bg_mc,0.2,0,{"alpha":0.4},Animate.ExpoOut);
            this.m_isGreyedOutDueToSocial = true;
         }
          if((MenuConstantsKnt.INVERT_Q_WATCH_DISPLAY ? Boolean(param1.isAimingWatch) : !Boolean(param1.isAimingWatch)))
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
                "x":-180,
                "y":100,
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
          if(Boolean(param1.isAnyAgencyMoveAvailable) && !this.m_isGreyedOutDueToSocial)
          {
             if(!this.m_isAnyAgencyMoveAvailable)
             {
                this.loopFlares(true);
                this.m_isAnyAgencyMoveAvailable = true;
             }
          }
          else if(this.m_isAnyAgencyMoveAvailable)
          {
             this.loopFlares(false);
             this.m_isAnyAgencyMoveAvailable = false;
          }
          if(param1.currentAgency != this.m_previousAgencyValue)
          {
             _loc2_ = false;
             _loc3_ = param1.currentAgency - this.m_previousAgencyValue;
             if(param1.currentAgency > this.m_previousAgencyValue)
             {
                _loc2_ = true;
             }
             this.setAgency(param1.maximumAgency,param1.currentAgency,_loc3_,_loc2_);
          }
          this.m_previousAgencyValue = param1.currentAgency;
       }
      
      private function setAgency(param1:Number, param2:Number, param3:Number, param4:Boolean) : void
      {
         var agencyCurrentPercentage:Number;
         var agencyBarRotation:Number;
         var maximumAgency:Number = param1;
         var currentAgency:Number = param2;
         var agencyGained:Boolean = param4;
         if(currentAgency >= maximumAgency)
         {
            currentAgency = maximumAgency;
         }
         agencyCurrentPercentage = MenuUtils.roundDecimal(currentAgency * 100 / maximumAgency,2);
         agencyBarRotation = 90 * agencyCurrentPercentage / 100 - 90;
         if(agencyGained)
         {
            Animate.kill(this.m_view.bars_mc.inner_bars_mc.bar_pin_mc);
            Animate.kill(this.m_view.bars_mc.inner_bars_mc.bar_mc.mask_mc);
            Animate.kill(this.m_view.bars_mc.inner_bars_mc.bar_gain_mc.mask_mc);
            Animate.kill(this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.mask_mc);
            this.m_view.bars_mc.inner_bars_mc.bar_gain_mc.visible = true;
            this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.visible = false;
            this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.mask_mc.rotation = agencyBarRotation;
            if(currentAgency < maximumAgency && !this.m_isGreyedOutDueToSocial)
            {
               this.showQuickFlare(true);
            }
            Animate.to(this.m_view.bars_mc.inner_bars_mc.bar_gain_mc.mask_mc,ANIM_SPEED_FAST,0,{"rotation":agencyBarRotation},Animate.ExpoOut,function():void
            {
               if(currentAgency >= maximumAgency && !m_isGreyedOutDueToSocial)
               {
                  showQuickFlare(false);
                  showFullBarGlow(true);
               }
            });
            Animate.to(this.m_view.bars_mc.inner_bars_mc.bar_mc.mask_mc,ANIM_SPEED,ANIM_DELAY,{"rotation":agencyBarRotation},Animate.ExpoOut);
            Animate.to(this.m_view.bars_mc.inner_bars_mc.bar_pin_mc,ANIM_SPEED,ANIM_DELAY,{"rotation":agencyBarRotation},Animate.ExpoOut);
         }
         else
         {
            Animate.kill(this.m_view.bars_mc.inner_bars_mc.bar_pin_mc);
            Animate.kill(this.m_view.bars_mc.inner_bars_mc.bar_mc.mask_mc);
            Animate.kill(this.m_view.bars_mc.inner_bars_mc.bar_gain_mc.mask_mc);
            Animate.kill(this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.mask_mc);
            this.showFullBarGlow(false);
            this.m_view.bars_mc.inner_bars_mc.bar_gain_mc.visible = false;
            this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.visible = true;
            this.m_view.bars_mc.inner_bars_mc.bar_gain_mc.mask_mc.rotation = agencyBarRotation;
            Animate.to(this.m_view.bars_mc.inner_bars_mc.bar_mc.mask_mc,ANIM_SPEED_FAST,0,{"rotation":agencyBarRotation},Animate.ExpoOut);
            Animate.to(this.m_view.bars_mc.inner_bars_mc.bar_loss_mc.mask_mc,ANIM_SPEED,ANIM_DELAY,{"rotation":agencyBarRotation},Animate.ExpoOut);
            Animate.to(this.m_view.bars_mc.inner_bars_mc.bar_pin_mc,ANIM_SPEED,ANIM_DELAY,{"rotation":agencyBarRotation},Animate.ExpoOut);
         }
      }
      
      private function showFullBarGlow(param1:Boolean) : void
      {
         var initialRandAlpha:Number = NaN;
         var randAlpha:Number = NaN;
         var speed:Number = NaN;
         var start:Boolean = param1;
         Animate.kill(this.m_view.glow_mc);
         Animate.kill(this.m_view.glow_mc.glow_01_mc);
         Animate.kill(this.m_view.glow_mc.glow_02_mc);
         Animate.kill(this.m_view.glow_mc.glow_03_mc);
         speed = 1.6;
         initialRandAlpha = 0.3;
         randAlpha = 0.3;
         if(start)
         {
            this.m_view.glow_mc.glow_01_mc.alpha = 0;
            this.m_view.glow_mc.glow_02_mc.alpha = randAlpha / 2;
            this.m_view.glow_mc.glow_03_mc.alpha = randAlpha;
            Animate.to(this.m_view.glow_mc,speed / 4,0,{"alpha":1},Animate.ExpoOut,function():void
            {
               Animate.to(m_view.glow_mc,speed,0,{"alpha":0},Animate.ExpoOut);
            });
            Animate.to(this.m_view.glow_mc.glow_01_mc,speed,0,{"alpha":initialRandAlpha},Animate.Linear,function():void
            {
               Animate.to(m_view.glow_mc.glow_01_mc,speed,0,{"alpha":0},Animate.Linear);
            });
            Animate.to(this.m_view.glow_mc.glow_02_mc,speed / 2,0,{"alpha":0},Animate.Linear,function():void
            {
               Animate.to(m_view.glow_mc.glow_02_mc,speed,0,{"alpha":randAlpha},Animate.Linear,function():void
               {
                  Animate.to(m_view.glow_mc.glow_02_mc,speed / 2,0,{"alpha":randAlpha / 2},Animate.Linear);
               });
            });
            Animate.to(this.m_view.glow_mc.glow_03_mc,speed,0,{"alpha":0},Animate.Linear,function():void
            {
               Animate.to(m_view.glow_mc.glow_03_mc,speed,0,{"alpha":randAlpha},Animate.Linear);
            });
         }
         else
         {
            Animate.to(this.m_view.glow_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            Animate.to(this.m_view.glow_mc.glow_01_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            Animate.to(this.m_view.glow_mc.glow_02_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            Animate.to(this.m_view.glow_mc.glow_03_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
         }
      }
      
      private function showQuickFlare(param1:Boolean) : void
      {
         var start:Boolean = param1;
         if(!this.m_flareLoopIsRunning)
         {
            Animate.kill(this.m_view.flares_mc.flare_01_mc);
            Animate.kill(this.m_view.flares_mc.flare_02_mc);
            Animate.kill(this.m_view.flares_mc.flare_03_mc);
            if(start)
            {
               this.m_view.flares_mc.flare_01_mc.scaleX = 1;
               this.m_view.flares_mc.flare_02_mc.scaleX = 1;
               Animate.to(this.m_view.flares_mc.flare_01_mc,0.3,0,{"alpha":0.4},Animate.ExpoOut,function():void
               {
                  Animate.to(m_view.flares_mc.flare_01_mc,0.4,0,{"alpha":0},Animate.ExpoIn);
               });
               Animate.to(this.m_view.flares_mc.flare_02_mc,0.4,0,{"alpha":0.6},Animate.ExpoOut,function():void
               {
                  Animate.to(m_view.flares_mc.flare_02_mc,0.3,0,{"alpha":0},Animate.ExpoIn);
               });
            }
            else
            {
               this.m_view.flares_mc.flare_01_mc.alpha = 0;
               this.m_view.flares_mc.flare_02_mc.alpha = 0;
               this.m_view.flares_mc.flare_03_mc.alpha = 0;
            }
         }
      }
      
      private function loopFlares(param1:Boolean) : void
      {
         var start:Boolean = param1;
         Animate.kill(this.m_view.flares_mc.flare_01_mc);
         Animate.kill(this.m_view.flares_mc.flare_02_mc);
         Animate.kill(this.m_view.flares_mc.flare_03_mc);
         if(start)
         {
            this.m_flareLoopIsRunning = true;
            Animate.to(this.m_view.flares_mc.flare_01_mc,0.4,0,{"alpha":0.5},Animate.ExpoOut,function():void
            {
               Animate.to(m_view.flares_mc.flare_01_mc,1.6,0.6,{"alpha":0},Animate.Linear,function():void
               {
                  Animate.to(m_view.flares_mc.flare_01_mc,2,0.4,{"alpha":0.4},Animate.Linear,function():void
                  {
                     loopFlares(true);
                  });
               });
            });
            Animate.to(this.m_view.flares_mc.flare_02_mc,1,0,{"alpha":0.5},Animate.ExpoOut,function():void
            {
               Animate.to(m_view.flares_mc.flare_02_mc,2,0.4,{"alpha":0.1},Animate.Linear,function():void
               {
                  m_view.flares_mc.flare_02_mc.scaleX = MenuUtils.getRandomBoolean() ? 1 : -1;
               });
            });
            Animate.to(this.m_view.flares_mc.flare_03_mc,2,1,{"alpha":0.5},Animate.ExpoOut,function():void
            {
               Animate.to(m_view.flares_mc.flare_03_mc,2,0,{"alpha":0.2},Animate.Linear,function():void
               {
                  m_view.flares_mc.flare_03_mc.scaleX = MenuUtils.getRandomBoolean() ? 1 : -1;
               });
            });
         }
         else
         {
            this.m_flareLoopIsRunning = false;
            Animate.to(this.m_view.flares_mc.flare_01_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            Animate.to(this.m_view.flares_mc.flare_02_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            Animate.to(this.m_view.flares_mc.flare_03_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
         }
      }
   }
}
