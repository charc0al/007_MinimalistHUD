package knt.hud.weapons
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.text.TextFormat;
   import glacier.basic.ButtonPromptImage;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.Localization;
   import glacier.common.menu.MenuUtils;
   import knt.common.hud.KntHudUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class WeaponReticleWidget extends BaseControl
   {
      private static const SHOW_RADIAL_AMMO:Boolean = false;
      
      private static const SHOW_SPREAD_RING:Boolean = false;
      
      private static const SHOW_AGENCY_BAR:Boolean = false;
      
      private static const SHOW_RELOAD_UI:Boolean = false;
      
      private static const SHOW_HIT_MARKERS:Boolean = false;
      
      private static const SHOW_ILLEGAL_INDICATOR:Boolean = false;
      
      public static const TYPE_HANDGUN:int = 1;
      
      public static const TYPE_SUBMACHINEGUN:int = 2;
      
      public static const TYPE_ASSAULTRIFLE:int = 3;
      
      public static const TYPE_SHOTGUN:int = 6;
      
      public static const TYPE_BOLTACTION:int = 7;
      
      private var m_view:WeaponReticleWidgetView;
      
      private var m_buttonPrompts:Vector.<ButtonPromptImage>;
      
      private var m_reloadPromptImage:ButtonPromptImage = new ButtonPromptImage();
      
      private var m_newFormat:TextFormat = new TextFormat();
      
      private var m_reticle:*;
      
      private var m_currentType:int = 0;
      
      private var m_previousType:int = 0;
      
      private var m_weaponTypeRemainedTheSame:Boolean = false;
      
      private var m_ironSightsOffsetX:int = -10;
      
      private var m_ironSightsTargetOffsetX:int = -6;
      
      private var m_ironSightsIllegalTargetOffsetX:int = -14;
      
      private var m_boundriesFadedOut:Boolean = false;
      
      private var m_warningPulsating:Boolean = false;
      
      private var m_delaySprite:Sprite = new Sprite();
      
      private var m_reloadNotificationActive:Boolean = false;
      
      private var m_outOfAmmoNotificationActive:Boolean = false;
      
      private var m_reloadingNotificationActive:Boolean = false;
      
      private var m_warningNotificationActive:Boolean = false;
      
      private var m_reloadCalled:Boolean = false;
      
      private var m_abortReloadCalled:Boolean = false;
      
      private var m_ammoInClip:int = 0;
      
      private var m_previousAmmoRemaining:int = -1;
      
      private var m_ammoDotArray:Array = new Array();
      
      private var m_ammoDotAlpha:Number = 1;
      
      private var m_ammoDotUsedAlpha:Number = 0.3;
      
      private var m_ammoDotWidth:Number = 0;
      
      private var m_ammoDotHeight:Number = 0;
      
      private var m_nMinSpreadRadius:Number = 0;
      
      private var m_nMaxSpreadRadius:Number = 0;
      
      private var m_spreadCircleSprite:Sprite;
      
      private var m_focusAimBgSprite:Sprite;
      
      private var m_focusAimBarSprite:Sprite;
      
      private var m_focusAimBarMaskSprite:Sprite;
      
      private var m_focusAimEndPinSprite:Sprite;
      
      private var m_spreadCircleAngleSpan:int = 0;
      
      private var m_ammoDotsAngleSpan:int = 0;
      
      private var m_currentAgency:Number = -1;
      
      private var m_maximumAgency:Number = -1;
      
      private var m_agencyBarAngleSpan:int = 0;
      
      private var m_reloadPromptIconId:int = -1;
      
      private var m_shouldShowReticle:Boolean = false;
      
      private var m_isAiming:Boolean = false;
      
      private var m_hasTarget:Boolean = false;
      
      private var m_canLethalForceBeUsedOnTarget:Boolean = true;
      
      public function WeaponReticleWidget()
      {
         super();
         this.m_view = new WeaponReticleWidgetView();
         addChild(this.m_view);
         this.m_view.reload_prompt_mc.filters = [new DropShadowFilter(1,151,0,0.4,4,4,0.4,1)];
         this.m_newFormat.letterSpacing = 2;
         this.m_view.spread_test_mc.visible = false;
         this.m_buttonPrompts = new Vector.<ButtonPromptImage>();
         this.m_view.reload_progressbar_mc.bg_mc.alpha = 0.4;
      }
      
      public function onSetData(param1:Object) : void
      {
         if(this.m_maximumAgency != param1.AgencyData.maximumAgency || this.m_currentAgency != param1.AgencyData.currentAgency)
         {
            this.m_maximumAgency = param1.AgencyData.maximumAgency;
            this.m_currentAgency = param1.AgencyData.currentAgency;
            if(this.m_reticle)
            {
               this.setAgency();
            }
         }
         if(!SHOW_RELOAD_UI)
         {
            this.m_view.reload_prompt_mc.visible = false;
            return;
         }
         if(param1.ReloadPromptData.aElements.length > 0)
         {
            if(this.m_reloadPromptIconId != param1.ReloadPromptData.aElements[0].iconId)
            {
               while(this.m_view.reload_prompt_mc.container_mc.numChildren > 0)
               {
                  this.m_view.reload_prompt_mc.container_mc.removeChildAt(0);
               }
               this.m_reloadPromptImage = this.processReloadButtonPrompt(param1.ReloadPromptData.aElements[0],param1.ReloadPromptData.controllerType);
               this.m_view.reload_prompt_mc.visible = this.m_reloadNotificationActive && this.m_shouldShowReticle ? true : false;
               this.m_view.reload_prompt_mc.container_mc.addChild(this.m_reloadPromptImage);
               this.m_view.reload_prompt_mc.y = this.m_view.warning_mc.y;
               this.m_reloadPromptIconId = param1.ReloadPromptData.aElements[0].iconId;
            }
         }
      }
      
      public function setType(param1:int, param2:Number, param3:Number) : void
      {
         if(param1 == this.m_currentType && param2 == this.m_nMinSpreadRadius && param3 == this.m_nMaxSpreadRadius)
         {
            return;
         }
         this.m_view.spread_test_mc.width = this.m_view.spread_test_mc.height = param3 * 2;
         Animate.kill(this.m_delaySprite);
         if(this.m_reticle)
         {
            Animate.kill(this.m_reticle.ammo_mc);
            Animate.kill(this.m_reticle.ironsight_mc.ironsight_inner_mc);
            Animate.kill(this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_0.inner_mc);
            Animate.kill(this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_1.inner_mc);
            this.pulsateWarning(false);
            this.m_reloadNotificationActive = false;
            this.m_outOfAmmoNotificationActive = false;
            this.m_reloadingNotificationActive = false;
            while(this.m_reticle.ammo_mc.spread_circle_container_mc.numChildren > 0)
            {
               this.m_reticle.ammo_mc.spread_circle_container_mc.removeChildAt(0);
            }
            this.m_spreadCircleSprite = null;
            while(this.m_reticle.ammo_mc.agency_container_mc.numChildren > 0)
            {
               this.m_reticle.ammo_mc.agency_container_mc.removeChildAt(0);
            }
            this.m_focusAimBgSprite = null;
            this.m_focusAimBarSprite = null;
            this.m_focusAimBarMaskSprite = null;
            this.m_focusAimEndPinSprite = null;
            while(this.m_reticle.ammo_mc.ammo_container_mc.numChildren > 0)
            {
               this.m_reticle.ammo_mc.ammo_container_mc.removeChildAt(0);
            }
            this.m_ammoDotArray = [];
            while(this.m_view.container_mc.numChildren > 0)
            {
               this.m_view.container_mc.removeChildAt(0);
            }
            this.m_reticle = null;
            this.m_boundriesFadedOut = false;
         }
         this.m_nMaxSpreadRadius = param3;
         this.m_nMinSpreadRadius = param2;
         switch(param1)
         {
            case TYPE_HANDGUN:
               this.m_reticle = new HandGunReticleView();
               this.m_view.container_mc.addChild(this.m_reticle);
               break;
            case TYPE_SUBMACHINEGUN:
               this.m_reticle = new SubMachineGunReticleView();
               this.m_view.container_mc.addChild(this.m_reticle);
               break;
            case TYPE_ASSAULTRIFLE:
               this.m_reticle = new AssaultRifleReticleView();
               this.m_view.container_mc.addChild(this.m_reticle);
               break;
            case TYPE_SHOTGUN:
               this.m_reticle = new ShotgunReticleView();
               this.m_view.container_mc.addChild(this.m_reticle);
               break;
            case TYPE_BOLTACTION:
               this.m_reticle = new BoltActionRifleReticleView();
               this.m_view.container_mc.addChild(this.m_reticle);
         }
         this.m_reticle.ammo_mc.agency_container_mc.visible = false;
         KntHudUtils.addOutline(this.m_reticle.posts_mc);
         KntHudUtils.addOutline(this.m_reticle.ironsight_mc);
         KntHudUtils.addOutline(this.m_reticle.ammo_mc.ammo_container_mc);
         KntHudUtils.addOutline(this.m_reticle.ammo_mc.spread_circle_container_mc);
         KntHudUtils.addOutline(this.m_reticle.ammo_mc.reload_progress_container_mc);
         KntHudUtils.addOutline(this.m_reticle.reload_prompt_mc);
         KntHudUtils.addOutline(this.m_reticle.warning_mc);
         KntHudUtils.addOutline(this.m_reticle.illegal_mc);
         this.m_reticle.warning_mc.visible = false;
         this.m_reticle.reload_prompt_mc.visible = false;
         this.m_view.reload_prompt_mc.visible = false;
         this.m_view.warning_mc.alpha = 0;
         this.m_view.warning_mc.y = param3 + 46;
         Animate.kill(this.m_view.reload_progressbar_mc.bar_mc);
         this.m_view.reload_progressbar_mc.visible = false;
         this.m_view.reload_progressbar_mc.y = this.m_view.warning_mc.y + 12;
         this.m_reticle.ammo_mc.visible = SHOW_RADIAL_AMMO || SHOW_SPREAD_RING || SHOW_AGENCY_BAR;
         this.m_reticle.ammo_mc.spread_circle_container_mc.alpha = 0;
         if(this.m_reticle.posts_mc)
         {
            this.m_reticle.posts_mc.alpha = 0;
         }
         this.m_reticle.ironsight_mc.alpha = 1;
         this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_0.inner_mc.x = this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_1.inner_mc.x = this.m_ironSightsOffsetX;
         this.m_reticle.hit_mc.alpha = 0;
         this.m_reticle.hit_kill_mc.alpha = 0;
         this.m_reticle.hit_mc.visible = SHOW_HIT_MARKERS;
         this.m_reticle.hit_kill_mc.visible = SHOW_HIT_MARKERS;
         this.m_reticle.crosshair_mc.visible = false;
         this.m_reticle.illegal_mc.visible = false;
         MenuUtils.removeColor(this.m_view.holstered_crosshair_mc,true);
         this.m_currentType = param1;
         if(this.m_hasTarget)
         {
            this.hasTarget(this.m_hasTarget,this.m_canLethalForceBeUsedOnTarget);
         }
         if(!this.m_shouldShowReticle)
         {
            this.pulsateWarning(false);
            this.m_reticle.visible = false;
            this.m_view.holstered_crosshair_mc.visible = this.m_outOfAmmoNotificationActive ? false : true;
         }
      }
      
      public function setSpreadRadius(param1:Number) : void
      {
         if(param1 <= this.m_nMinSpreadRadius)
         {
            param1 = this.m_nMinSpreadRadius;
         }
         this.setSpreadCircleRadius(param1);
         switch(this.m_currentType)
         {
            case TYPE_HANDGUN:
               this.moveIronSights(param1,24,1,0,-1,0);
               break;
            case TYPE_SUBMACHINEGUN:
               this.moveIronSights(param1,24,1,0,-1,0);
               break;
            case TYPE_ASSAULTRIFLE:
               this.moveIronSights(param1,24,1,0,-1,0);
               break;
            case TYPE_SHOTGUN:
               this.moveIronSights(param1,24,1,0,-1,0);
               break;
            case TYPE_BOLTACTION:
               this.moveIronSights(param1,24,1,0,-1,0);
         }
      }
      
      private function moveIronSights(param1:Number, param2:Number, ... rest) : void
      {
         var _loc5_:MovieClip = null;
         var _loc4_:int = 0;
         while(_loc4_ < rest.length / 2)
         {
            _loc5_ = this.m_reticle.ironsight_mc.ironsight_inner_mc.getChildByName("ironsight_mc_" + String(_loc4_)) as MovieClip;
            _loc5_.x = (param1 - param2) * rest[_loc4_ * 2];
            _loc4_++;
         }
      }
      
      private function moveOuterPosts(param1:Number, param2:Number, ... rest) : void
      {
         var _loc5_:MovieClip = null;
         var _loc4_:int = 0;
         while(_loc4_ < rest.length / 2)
         {
            _loc5_ = this.m_reticle.posts_mc.getChildByName("post_mc_" + String(_loc4_)) as MovieClip;
            _loc5_.x = (param1 - param2) * rest[_loc4_ * 2];
            _loc5_.y = (param1 - param2) * rest[_loc4_ * 2 + 1];
            _loc4_++;
         }
      }
      
      private function setAgency() : void
      {
         if(!SHOW_AGENCY_BAR)
         {
            return;
         }
         this.m_focusAimBarMaskSprite.rotation = -90 - this.m_agencyBarAngleSpan / -2 - this.m_currentAgency / this.m_maximumAgency * this.m_agencyBarAngleSpan;
      }
      
      public function setAmmo(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:WeaponReticleAmmoView = null;
         var _loc7_:int = 0;
         if(!SHOW_RADIAL_AMMO && !SHOW_SPREAD_RING && !SHOW_AGENCY_BAR && !SHOW_RELOAD_UI)
         {
            this.m_previousAmmoRemaining = param1;
            this.m_ammoInClip = param2;
            this.m_previousType = this.m_currentType;
            this.m_view.reload_prompt_mc.visible = false;
            this.m_view.reload_progressbar_mc.visible = false;
            this.m_view.warning_mc.alpha = 0;
            return;
         }
         if(this.m_currentType != this.m_previousType || this.m_ammoInClip != param2 || this.m_ammoDotArray.length == 0)
         {
            switch(this.m_currentType)
            {
               case TYPE_HANDGUN:
                  this.m_spreadCircleAngleSpan = 110;
                  this.m_ammoDotsAngleSpan = 60;
                  this.m_agencyBarAngleSpan = 90;
                  this.m_ammoDotWidth = 2;
                  this.m_ammoDotHeight = 2;
                  break;
               case TYPE_SUBMACHINEGUN:
                  this.m_spreadCircleAngleSpan = 90;
                  this.m_ammoDotsAngleSpan = 110;
                  this.m_agencyBarAngleSpan = 120;
                  this.m_ammoDotWidth = 1;
                  this.m_ammoDotHeight = 3;
                  break;
               case TYPE_ASSAULTRIFLE:
                  this.m_spreadCircleAngleSpan = 70;
                  this.m_ammoDotsAngleSpan = 135;
                  this.m_agencyBarAngleSpan = 145;
                  this.m_ammoDotWidth = 1;
                  this.m_ammoDotHeight = 3;
                  break;
               case TYPE_SHOTGUN:
                  this.m_spreadCircleAngleSpan = 90;
                  this.m_ammoDotsAngleSpan = 45;
                  this.m_agencyBarAngleSpan = 90;
                  this.m_ammoDotWidth = 3;
                  this.m_ammoDotHeight = 3;
                  break;
               case TYPE_BOLTACTION:
                  this.m_spreadCircleAngleSpan = 70;
                  this.m_ammoDotsAngleSpan = 45;
                  this.m_agencyBarAngleSpan = 90;
                  this.m_ammoDotWidth = 2;
                  this.m_ammoDotHeight = 6;
            }
            if(this.m_currentType == TYPE_BOLTACTION && param2 > 10)
            {
               this.m_ammoDotsAngleSpan = param2 * 5;
               this.m_agencyBarAngleSpan = param2 * 5.5;
            }
            if(this.m_spreadCircleSprite)
            {
               while(this.m_reticle.ammo_mc.spread_circle_container_mc.numChildren > 0)
               {
                  this.m_reticle.ammo_mc.spread_circle_container_mc.removeChildAt(0);
               }
            }
            else
            {
               this.m_spreadCircleSprite = new Sprite();
            }
            this.m_reticle.ammo_mc.spread_circle_container_mc.addChild(this.m_spreadCircleSprite);
            this.drawSpreadCircle();
            if(this.m_focusAimBgSprite)
            {
               while(this.m_reticle.ammo_mc.agency_container_mc.numChildren > 0)
               {
                  this.m_reticle.ammo_mc.agency_container_mc.removeChildAt(0);
               }
            }
            else
            {
               this.m_focusAimBgSprite = new Sprite();
               this.m_focusAimBarSprite = new Sprite();
               this.m_focusAimBarMaskSprite = new Sprite();
               this.m_focusAimEndPinSprite = new Sprite();
            }
            this.m_reticle.ammo_mc.agency_container_mc.addChild(this.m_focusAimBgSprite);
            this.m_reticle.ammo_mc.agency_container_mc.addChild(this.m_focusAimBarSprite);
            this.m_reticle.ammo_mc.agency_container_mc.addChild(this.m_focusAimBarMaskSprite);
            this.m_reticle.ammo_mc.agency_container_mc.addChild(this.m_focusAimEndPinSprite);
            KntHudUtils.addOutline(this.m_focusAimBgSprite,MenuConstantsKnt.COLOR_BLACK,0.3);
            KntHudUtils.addOutline(this.m_focusAimEndPinSprite);
            this.m_focusAimBarSprite.mask = this.m_focusAimBarMaskSprite;
            this.drawAgencyBar();
            _loc4_ = MenuUtils.roundDecimal(this.m_ammoDotsAngleSpan / (param2 - 1),2);
            _loc5_ = 0;
            if(this.m_ammoDotArray.length > 0)
            {
               while(this.m_reticle.ammo_mc.ammo_container_mc.numChildren > 0)
               {
                  this.m_reticle.ammo_mc.ammo_container_mc.removeChildAt(0);
               }
            }
            this.m_ammoDotArray = [];
            this.m_reticle.ammo_mc.ammo_container_mc.rotation = this.m_ammoDotsAngleSpan / -2;
            _loc7_ = 0;
            _loc7_ = 0;
            while(_loc7_ < param2)
            {
               _loc6_ = new WeaponReticleAmmoView();
               _loc6_.dot_mc.y = Math.max(36,this.m_nMaxSpreadRadius) + 4;
               _loc6_.dot_mc.width = this.m_ammoDotWidth;
               _loc6_.dot_mc.height = this.m_ammoDotHeight;
               _loc6_.alpha = _loc7_ < param1 ? this.m_ammoDotAlpha : this.m_ammoDotUsedAlpha;
               this.m_reticle.ammo_mc.ammo_container_mc.addChild(_loc6_);
               this.m_ammoDotArray.push(_loc6_);
               _loc6_.rotation = _loc5_;
               _loc5_ += _loc4_;
               _loc7_++;
            }
            this.m_ammoInClip = param2;
            this.m_previousType = this.m_currentType;
            this.m_weaponTypeRemainedTheSame = false;
         }
         else
         {
            this.m_weaponTypeRemainedTheSame = true;
         }
         if(this.m_reloadCalled)
         {
            _loc7_ = 0;
            while(_loc7_ < this.m_ammoInClip)
            {
               this.m_ammoDotArray[_loc7_].alpha = _loc7_ < param1 ? this.m_ammoDotAlpha : this.m_ammoDotUsedAlpha;
               _loc7_++;
            }
            this.m_reloadCalled = false;
         }
         _loc7_ = 0;
         while(_loc7_ < this.m_ammoInClip)
         {
            this.m_ammoDotArray[_loc7_].alpha = _loc7_ < param1 ? this.m_ammoDotAlpha : this.m_ammoDotUsedAlpha;
            _loc7_++;
         }
         if(param2 >= 2)
         {
            if(param1 <= 2 && param3 >= 1 || param1 <= 2 && param3 == -1)
            {
               if(!this.m_reloadNotificationActive)
               {
                  if(this.m_warningPulsating)
                  {
                     this.pulsateWarning(false);
                  }
                  this.setWarningNotification(Localization.get("UI_HUD_WEAPON_RELOAD"),MenuConstantsKnt.COLOR_YELLOW,true);
                  if(this.m_outOfAmmoNotificationActive)
                  {
                     MenuUtils.removeColor(this.m_reticle.ironsight_mc,true);
                  }
                  this.m_reloadNotificationActive = true;
                  this.m_outOfAmmoNotificationActive = false;
                  this.m_reloadingNotificationActive = false;
                  if(this.m_shouldShowReticle)
                  {
                     this.pulsateWarning(true);
                  }
               }
            }
            else if(param1 == 0 && param3 == 0)
            {
               this.m_view.holstered_crosshair_mc.visible = false;
               if(!this.m_outOfAmmoNotificationActive)
               {
                  if(this.m_warningPulsating)
                  {
                     this.pulsateWarning(false);
                  }
                  this.setWarningNotification(Localization.get("UI_HUD_WEAPON_OUT_OF_AMMO"),MenuConstantsKnt.COLOR_RED,false);
                  MenuUtils.setColor(this.m_reticle.ironsight_mc,MenuConstantsKnt.COLOR_WHITE,true,0.6);
                  this.m_reloadNotificationActive = false;
                  this.m_outOfAmmoNotificationActive = true;
                  this.m_reloadingNotificationActive = false;
                  if(this.m_shouldShowReticle)
                  {
                     this.pulsateWarning(true);
                  }
               }
            }
            else
            {
               if(this.m_weaponTypeRemainedTheSame && param1 > this.m_previousAmmoRemaining)
               {
               }
               if(this.m_reloadNotificationActive)
               {
                  this.m_reloadNotificationActive = false;
                  this.m_view.reload_prompt_mc.visible = false;
               }
               if(this.m_outOfAmmoNotificationActive)
               {
                  this.m_outOfAmmoNotificationActive = false;
                  MenuUtils.removeColor(this.m_reticle.ironsight_mc,true);
               }
               if(!this.m_shouldShowReticle)
               {
                  this.m_view.holstered_crosshair_mc.visible = true;
               }
            }
         }
         this.m_previousAmmoRemaining = param1;
      }
      
      public function reloadCalled(param1:Number) : void
      {
         var fReloadDuration:Number = param1;
         if(!SHOW_RELOAD_UI)
         {
            this.m_view.reload_prompt_mc.visible = false;
            this.m_view.reload_progressbar_mc.visible = false;
            this.m_view.warning_mc.alpha = 0;
            return;
         }
         if(!this.m_reloadingNotificationActive)
         {
            if(this.m_warningPulsating)
            {
               this.pulsateWarning(false);
            }
            this.setWarningNotification(Localization.get("UI_HUD_WEAPON_RELOADING"),MenuConstantsKnt.COLOR_GREEN,false);
            this.m_reloadNotificationActive = false;
            this.m_outOfAmmoNotificationActive = false;
            this.m_reloadingNotificationActive = true;
            this.pulsateWarning(true);
         }
         Animate.kill(this.m_view.reload_progressbar_mc.bar_mc);
         this.m_view.reload_progressbar_mc.visible = true;
         MenuUtils.setColor(this.m_reticle.ironsight_mc,MenuConstantsKnt.COLOR_WHITE,true,0.6);
         this.m_view.reload_progressbar_mc.bar_mc.width = 180;
         Animate.to(this.m_view.reload_progressbar_mc.bar_mc,fReloadDuration,0,{"width":0},Animate.Linear,function():void
         {
            m_view.reload_progressbar_mc.visible = false;
            if(m_warningPulsating)
            {
               pulsateWarning(false);
            }
            m_reloadingNotificationActive = false;
            MenuUtils.removeColor(m_reticle.ironsight_mc,true);
            m_view.reload_prompt_mc.visible = false;
         });
         this.m_reloadCalled = true;
      }
      
      public function abortReloadCalled() : void
      {
         if(!SHOW_RELOAD_UI)
         {
            this.m_view.reload_prompt_mc.visible = false;
            this.m_view.reload_progressbar_mc.visible = false;
            this.m_view.warning_mc.alpha = 0;
            return;
         }
         if(this.m_reloadingNotificationActive)
         {
            if(this.m_warningPulsating)
            {
               this.pulsateWarning(false);
            }
            this.setWarningNotification("",MenuConstantsKnt.COLOR_GREEN,false);
            Animate.kill(this.m_view.reload_progressbar_mc.bar_mc);
            this.m_view.reload_progressbar_mc.visible = false;
            MenuUtils.removeColor(this.m_reticle.ironsight_mc,true);
            this.m_view.reload_prompt_mc.visible = false;
            this.m_reloadCalled = false;
            this.m_reloadingNotificationActive = false;
         }
      }
      
      private function setWarningNotification(param1:String, param2:int, param3:Boolean) : void
      {
         if(!SHOW_RELOAD_UI)
         {
            this.m_view.reload_prompt_mc.visible = false;
            this.m_view.warning_mc.alpha = 0;
            return;
         }
         MenuUtils.setupText(this.m_view.warning_mc.reload_txt,param1,18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         this.m_view.warning_mc.reload_txt.autoSize = "left";
         this.m_view.warning_mc.reload_txt.setTextFormat(this.m_newFormat);
         var _loc4_:int = param3 ? int((15 + 22 + this.m_view.warning_mc.reload_txt.width) / -2 + 15) : int((15 + 26 + this.m_view.warning_mc.reload_txt.width) / -2);
         this.m_view.reload_prompt_mc.x = _loc4_;
         this.m_view.warning_mc.x = _loc4_;
         this.m_view.reload_prompt_mc.y = this.m_view.warning_mc.y;
         if(this.m_shouldShowReticle)
         {
            this.m_view.reload_prompt_mc.visible = param3;
         }
      }
      
      private function pulsateWarning(param1:Boolean) : void
      {
         var start:Boolean = param1;
         if(!SHOW_RELOAD_UI)
         {
            this.m_warningPulsating = false;
            this.m_view.warning_mc.alpha = 0;
            return;
         }
         Animate.kill(this.m_view.warning_mc);
         this.m_view.warning_mc.alpha = 0;
         if(start)
         {
            this.m_view.warning_mc.alpha = 1;
            Animate.delay(this.m_view.warning_mc,0.2,function():void
            {
               m_view.warning_mc.alpha = 0;
               Animate.delay(m_view.warning_mc,0.2,function():void
               {
                  pulsateWarning(true);
               });
            });
            this.m_warningPulsating = true;
         }
         else
         {
            this.m_warningPulsating = false;
         }
      }
      
      public function shouldShowReticle(param1:Boolean, param2:Boolean) : void
      {
         this.m_shouldShowReticle = param1;
         if(param1)
         {
            this.setIllegalStateReticle();
            this.m_reticle.visible = true;
            this.m_view.holstered_crosshair_mc.visible = false;
            this.m_view.reload_prompt_mc.visible = this.m_reloadNotificationActive ? true : false;
            if(this.m_reloadNotificationActive)
            {
               this.pulsateWarning(true);
            }
            else if(this.m_outOfAmmoNotificationActive)
            {
               this.pulsateWarning(true);
               MenuUtils.setColor(this.m_reticle.ironsight_mc,MenuConstantsKnt.COLOR_WHITE,true,0.6);
            }
         }
         else
         {
            if(!this.m_reloadingNotificationActive)
            {
               this.pulsateWarning(false);
            }
            this.m_view.reload_prompt_mc.visible = false;
            this.setIllegalStateHolstered();
            this.m_reticle.visible = false;
            if(this.m_outOfAmmoNotificationActive)
            {
               this.m_view.holstered_crosshair_mc.visible = false;
            }
            else
            {
               this.m_view.holstered_crosshair_mc.visible = true;
               this.m_view.holstered_crosshair_mc.scaleX = this.m_view.holstered_crosshair_mc.scaleY = this.m_hasTarget ? 1.4 : 0.7;
            }
         }
      }
      
      public function hasTarget(param1:Boolean, param2:Boolean) : void
      {
         if(param1 && param2 || !param1 && !this.m_canLethalForceBeUsedOnTarget)
         {
            if(!this.m_outOfAmmoNotificationActive)
            {
               this.m_reticle.illegal_mc.visible = false;
               MenuUtils.removeColor(this.m_reticle.ironsight_mc,true);
            }
         }
         this.m_hasTarget = param1;
         this.m_canLethalForceBeUsedOnTarget = param2;
         if(this.m_shouldShowReticle)
         {
            if(!this.m_outOfAmmoNotificationActive)
            {
               Animate.kill(this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_0.inner_mc);
               Animate.kill(this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_1.inner_mc);
               if(this.m_hasTarget)
               {
                  Animate.to(this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_0.inner_mc,0.3,0,{"x":(!SHOW_ILLEGAL_INDICATOR || param2 ? this.m_ironSightsTargetOffsetX : this.m_ironSightsIllegalTargetOffsetX)},Animate.ExpoOut);
                  Animate.to(this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_1.inner_mc,0.3,0,{"x":(!SHOW_ILLEGAL_INDICATOR || param2 ? this.m_ironSightsTargetOffsetX : this.m_ironSightsIllegalTargetOffsetX)},Animate.ExpoOut);
                  this.setIllegalStateReticle();
               }
               else
               {
                  Animate.to(this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_0.inner_mc,0.2,0,{"x":this.m_ironSightsOffsetX},Animate.ExpoOut);
                  Animate.to(this.m_reticle.ironsight_mc.ironsight_inner_mc.ironsight_mc_1.inner_mc,0.2,0,{"x":this.m_ironSightsOffsetX},Animate.ExpoOut);
                  this.m_reticle.ironsight_mc.alpha = 1;
               }
            }
         }
         else if(!this.m_outOfAmmoNotificationActive)
         {
            this.setIllegalStateHolstered();
            this.m_view.holstered_crosshair_mc.scaleX = this.m_view.holstered_crosshair_mc.scaleY = this.m_hasTarget ? 1.4 : 0.7;
            this.m_reticle.ironsight_mc.alpha = 1;
         }
      }
      
      public function updateCanLethalForceBeUsed(param1:Boolean) : void
      {
         this.m_canLethalForceBeUsedOnTarget = param1;
         if(this.m_hasTarget && this.m_shouldShowReticle)
         {
            this.setIllegalStateReticle();
         }
      }
      
      public function triggerHit() : void
      {
         if(!SHOW_HIT_MARKERS)
         {
            this.m_reticle.hit_mc.alpha = 0;
            return;
         }
         Animate.kill(this.m_reticle.hit_mc);
         this.m_reticle.hit_mc.alpha = 1;
         Animate.fromTo(this.m_reticle.hit_mc,0.2,0,{"frames":1},{"frames":25},Animate.QuartOut,function():void
         {
            m_reticle.hit_mc.alpha = 0;
         });
      }
      
      public function triggerHitCritical() : void
      {
      }
      
      public function triggerKill() : void
      {
         if(!SHOW_HIT_MARKERS)
         {
            this.m_reticle.hit_mc.alpha = 0;
            this.m_reticle.hit_kill_mc.alpha = 0;
            return;
         }
         Animate.kill(this.m_reticle.hit_mc);
         this.m_reticle.hit_mc.alpha = 0;
         Animate.kill(this.m_reticle.hit_kill_mc.hit_kill_inner_mc);
         this.m_reticle.hit_kill_mc.alpha = 1;
         Animate.fromTo(this.m_reticle.hit_kill_mc.hit_kill_inner_mc,0.3,0,{"frames":1},{"frames":25},Animate.QuartOut,function():void
         {
            m_reticle.hit_kill_mc.alpha = 0;
         });
      }
      
      public function shotEmitted() : void
      {
         if(!this.m_boundriesFadedOut)
         {
            this.fadeOutBoundaries();
            this.m_boundriesFadedOut = true;
         }
         Animate.kill(this.m_delaySprite);
         Animate.delay(this.m_delaySprite,0.2,function():void
         {
            fadeInBoundaries();
            m_boundriesFadedOut = false;
         });
      }
      
      private function fadeInBoundaries() : void
      {
         Animate.kill(this.m_reticle.ironsight_mc.ironsight_inner_mc);
         Animate.to(this.m_reticle.ironsight_mc.ironsight_inner_mc,1,0,{"alpha":1},Animate.ExpoOut);
      }
      
      private function fadeOutBoundaries() : void
      {
         Animate.kill(this.m_reticle.ironsight_mc.ironsight_inner_mc);
         Animate.to(this.m_reticle.ironsight_mc.ironsight_inner_mc,1,0,{"alpha":0.6},Animate.ExpoOut);
      }
      
      private function setIllegalStateReticle() : void
      {
         if(!SHOW_ILLEGAL_INDICATOR)
         {
            this.m_reticle.illegal_mc.visible = false;
            MenuUtils.removeColor(this.m_reticle.ironsight_mc,true);
            return;
         }
         if(!this.m_canLethalForceBeUsedOnTarget)
         {
            this.m_reticle.illegal_mc.visible = true;
            MenuUtils.setColor(this.m_reticle.ironsight_mc,MenuConstantsKnt.COLOR_WHITE,true,0.6);
         }
         else
         {
            this.m_reticle.illegal_mc.visible = false;
            MenuUtils.removeColor(this.m_reticle.ironsight_mc,true);
         }
      }
      
      private function setIllegalStateHolstered() : void
      {
         if(!SHOW_ILLEGAL_INDICATOR)
         {
            MenuUtils.removeColor(this.m_view.holstered_crosshair_mc,true);
            return;
         }
         if(!this.m_canLethalForceBeUsedOnTarget)
         {
            MenuUtils.setColor(this.m_view.holstered_crosshair_mc,MenuConstantsKnt.COLOR_RED);
         }
         else
         {
            MenuUtils.removeColor(this.m_view.holstered_crosshair_mc,true);
         }
      }
      
      private function drawAgencyBar() : void
      {
         if(!SHOW_AGENCY_BAR)
         {
            return;
         }
         this.m_focusAimBgSprite.graphics.clear();
         this.m_focusAimBgSprite.graphics.lineStyle(1,MenuConstantsKnt.COLOR_WHITE,0.3,false,"none","none");
         this.m_focusAimBgSprite.rotation = -90 - this.m_agencyBarAngleSpan / 2;
         this.m_focusAimBarSprite.graphics.clear();
         this.m_focusAimBarSprite.graphics.lineStyle(2,MenuConstantsKnt.COLOR_AGENCY,1,false,"none","none");
         this.m_focusAimBarSprite.rotation = -90 - this.m_agencyBarAngleSpan / 2;
         this.m_focusAimBarMaskSprite.graphics.clear();
         this.m_focusAimBarMaskSprite.graphics.beginFill(MenuConstantsKnt.COLOR_RED,1);
         this.m_focusAimBarMaskSprite.rotation = -90 - this.m_agencyBarAngleSpan / 2;
         this.m_focusAimEndPinSprite.graphics.clear();
         this.m_focusAimEndPinSprite.graphics.lineStyle(3,MenuConstantsKnt.COLOR_QTE,0.8,false,"none","none");
         this.m_focusAimEndPinSprite.rotation = -90 - this.m_agencyBarAngleSpan / 2;
         var _loc1_:int = Math.max(36,this.m_nMaxSpreadRadius) + 12;
         this.drawCircleSegment(_loc1_ + 2,180 - 0.5,this.m_agencyBarAngleSpan + 180 + 0.5,this.m_focusAimBgSprite);
         this.drawCircleSegment(_loc1_,180,this.m_agencyBarAngleSpan + 180,this.m_focusAimBarSprite);
         this.drawCircleSegment(_loc1_,180,0.5 + 180,this.m_focusAimEndPinSprite);
         this.drawCircleSegment(_loc1_,this.m_agencyBarAngleSpan + 180 - 0.5,this.m_agencyBarAngleSpan + 180,this.m_focusAimEndPinSprite);
         this.m_focusAimBarMaskSprite.graphics.moveTo(0,0);
         this.drawCircleSegment(_loc1_ + 10,180,this.m_agencyBarAngleSpan + 180,this.m_focusAimBarMaskSprite);
         this.m_focusAimBarMaskSprite.graphics.lineTo(0,0);
         this.setAgency();
      }
      
      private function drawSpreadCircle() : void
      {
         if(!SHOW_SPREAD_RING)
         {
            return;
         }
         this.m_spreadCircleSprite.graphics.clear();
         this.m_spreadCircleSprite.graphics.lineStyle(2,MenuConstantsKnt.COLOR_WHITE,1,false,"none","none");
         this.m_spreadCircleSprite.rotation = -90 - this.m_spreadCircleAngleSpan / 2;
         this.drawCircleSegment(this.m_nMaxSpreadRadius,0,this.m_spreadCircleAngleSpan,this.m_spreadCircleSprite);
         this.drawCircleSegment(this.m_nMaxSpreadRadius,180,this.m_spreadCircleAngleSpan + 180,this.m_spreadCircleSprite);
      }
      
      private function drawCircleSegment(param1:Number, param2:Number, param3:Number, param4:Sprite) : void
      {
         var _loc12_:Point = null;
         var _loc5_:Number = param2 * (Math.PI / 180);
         var _loc6_:Number = param3 * (Math.PI / 180);
         var _loc7_:Point = this.polarToCartesian(param1,_loc5_);
         param4.graphics.moveTo(_loc7_.x,_loc7_.y);
         var _loc8_:int = Math.ceil(Math.abs(_loc6_ - _loc5_) / (Math.PI / 180));
         var _loc9_:Number = _loc5_;
         var _loc10_:Number = (_loc6_ - _loc5_) / _loc8_;
         var _loc11_:int = 0;
         while(_loc11_ < _loc8_)
         {
            _loc9_ += _loc10_;
            _loc12_ = this.polarToCartesian(param1,_loc9_);
            param4.graphics.lineTo(_loc12_.x,_loc12_.y);
            _loc11_++;
         }
      }
      
      private function polarToCartesian(param1:Number, param2:Number) : Point
      {
         return new Point(param1 * Math.cos(param2),param1 * Math.sin(param2));
      }
      
      private function setSpreadCircleRadius(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(SHOW_SPREAD_RING && this.m_reticle && Boolean(this.m_spreadCircleSprite))
         {
            _loc2_ = 0.8 - Math.floor(param1 * 100 / this.m_nMaxSpreadRadius) / 200;
            this.m_reticle.ammo_mc.spread_circle_container_mc.alpha = _loc2_;
            this.m_spreadCircleSprite.width = (param1 + 12) * 2;
            this.m_spreadCircleSprite.height = (param1 + 12) * 2;
         }
      }
      
      private function processReloadButtonPrompt(param1:Object, param2:String) : ButtonPromptImage
      {
         var _loc3_:ButtonPromptImage = ButtonPromptImage.AcquireInstance();
         _loc3_.platform = param2;
         _loc3_.scaleX = _loc3_.scaleY = _loc3_.platform == "key" ? 0.5 : 0.7;
         if(_loc3_.platform == "key")
         {
            _loc3_.customKey = param1.keyGlyph;
         }
         else
         {
            _loc3_.button = param1.iconId;
         }
         return _loc3_;
      }
      
      private function getType(param1:int) : String
      {
         var _loc2_:String = "";
         switch(param1)
         {
            case TYPE_HANDGUN:
               _loc2_ = "TYPE_HANDGUN";
               break;
            case TYPE_SUBMACHINEGUN:
               _loc2_ = "TYPE_SUBMACHINEGUN";
               break;
            case TYPE_ASSAULTRIFLE:
               _loc2_ = "TYPE_ASSAULTRIFLE";
               break;
            case TYPE_SHOTGUN:
               _loc2_ = "TYPE_SHOTGUN";
               break;
            case TYPE_BOLTACTION:
               _loc2_ = "TYPE_BOLTACTION";
               break;
            default:
               _loc2_ = "TYPE_UNKNOWN";
         }
         return _loc2_;
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         if(this.m_reticle)
         {
            if(!param1)
            {
               if(this.m_warningPulsating)
               {
                  this.pulsateWarning(false);
               }
            }
         }
         this.visible = param1;
      }
      
      override public function onSetSize(param1:Number, param2:Number) : void
      {
         super.onSetSize(param1,param2);
         this.m_view.x = param1 / 2;
         this.m_view.y = param2 / 2;
      }
      
      public function set showTestSpreadCircle(param1:Boolean) : void
      {
         this.m_view.spread_test_mc.visible = param1;
      }
   }
}

