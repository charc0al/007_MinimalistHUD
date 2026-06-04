package knt.hud.watch
{
   import flash.filters.DropShadowFilter;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class WatchGadgetResourceDialWidget extends BaseControl
   {
      
      private static const PLAYER_RESOURCETYPE_INVALID:uint = 0;
      
      private static const PLAYER_RESOURCETYPE_UNKNOWN:uint = 1;
      
      private static const PLAYER_RESOURCETYPE_ELECTRICAL:uint = 2;
      
      private static const PLAYER_RESOURCETYPE_CHEMICAL:uint = 3;
      
      private static const DIAL_NUM_FRAMES:int = 100;
      
      private static const OPEN_ANIM_SPEED:Number = 0.4;
      
      private static const FLASH_ANIM_SPEED:Number = 0.03;
      
      private static const BASE_SCALE:Number = 0.75;

      private static const BASE_X_OFFSET:Number = -18;
      
      private var m_view:WatchGadgetResourceDialWidgetView;
      
      private var m_parentClassInstance:WatchGadgetResourcesWidget;
      
      private var m_resourceType:int = -1;
      
      private var m_previousElectricalColor:int = -1;
      
      private var m_previousChemicalColor:int = -1;
      
      private var m_previousAmmoCount:int = 0;
      
      private var m_previousAmmoMax:int = 0;
      
      private var m_recharging:Boolean = false;
      
      private var m_rechargeDuration:Number = 0;
      
      private var m_rechargeHandRotationCounter:int = 0;
      
      private var m_checkWhenResourceIsFullAgain:Boolean = false;
      
      private var m_playFullResourceAudioStinger:Boolean = false;
      
      public function WatchGadgetResourceDialWidget()
      {
         super();
         this.m_view = new WatchGadgetResourceDialWidgetView();
         addChild(this.m_view);
         this.m_view.scaleX = this.m_view.scaleY = BASE_SCALE;
         this.m_view.x = BASE_X_OFFSET;
         this.m_view.main_mc.electrical_dropshadow_mc.alpha = 0.4;
         this.m_view.main_mc.chemical_dropshadow_mc.alpha = 0.4;
         this.m_view.main_mc.timer_hand_dropshadow_mc.alpha = 0.4;
         this.m_view.main_mc.timer_hand_dropshadow_mc.visible = false;
         MenuUtils.setColor(this.m_view.main_mc.dial_flash_mc,MenuConstantsKnt.COLOR_WHITE,false);
         MenuUtils.setColor(this.m_view.electrical_icon_mc,MenuConstantsKnt.COLOR_WHITE,false);
         MenuUtils.setColor(this.m_view.chemical_icon_mc,MenuConstantsKnt.COLOR_WHITE,false);
         this.m_view.electrical_icon_mc.alpha = 0.5;
         this.m_view.chemical_icon_mc.alpha = 0.5;
         this.m_view.main_mc.dial_bg_mc.visible = false;
         this.m_view.main_mc.dial_gain_mc.alpha = 0.6;
         this.m_view.timer_hand_mc.alpha = 0.6;
         this.m_view.timer_hand_mc.filters = [new DropShadowFilter(4,151,0,0.6,4,4,0.4,1)];
         this.m_view.timer_hand_mc.visible = false;
         this.m_view.timer_indents_mc.visible = false;
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:Number = NaN;
         var _loc2_:Boolean = false;
         if(param1.resourceType != this.m_resourceType)
         {
            _loc2_ = true;
            Animate.kill(this.m_view.timer_hand_mc);
            this.m_view.timer_hand_mc.visible = false;
            this.m_view.main_mc.timer_hand_dropshadow_mc.visible = false;
            this.m_view.timer_indents_mc.visible = false;
            this.m_view.electrical_icon_mc.visible = param1.resourceType == PLAYER_RESOURCETYPE_ELECTRICAL ? true : false;
            this.m_view.main_mc.electrical_dropshadow_mc.visible = param1.resourceType == PLAYER_RESOURCETYPE_ELECTRICAL ? true : false;
            this.m_view.chemical_icon_mc.visible = param1.resourceType == PLAYER_RESOURCETYPE_CHEMICAL ? true : false;
            this.m_view.main_mc.chemical_dropshadow_mc.visible = param1.resourceType == PLAYER_RESOURCETYPE_CHEMICAL ? true : false;
            if(param1.resourceType == PLAYER_RESOURCETYPE_ELECTRICAL)
            {
               MenuUtils.setColor(this.m_view.main_mc.dial_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_ELECTRICAL,false);
               MenuUtils.setColor(this.m_view.main_mc.dial_gain_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_ELECTRICAL,false);
            }
            else if(param1.resourceType == PLAYER_RESOURCETYPE_CHEMICAL)
            {
               MenuUtils.setColor(this.m_view.main_mc.dial_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_CHEMICAL,false);
               MenuUtils.setColor(this.m_view.main_mc.dial_gain_mc,MenuConstantsKnt.COLOR_HUD_RESOURCE_CHEMICAL,false);
            }
            this.m_resourceType = param1.resourceType;
            this.m_previousElectricalColor = int.MIN_VALUE;
            this.m_previousChemicalColor = int.MIN_VALUE;
         }
         if(this.m_resourceType == PLAYER_RESOURCETYPE_ELECTRICAL)
         {
            _loc3_ = MenuConstantsKnt.COLOR_HUD_RESOURCE_ELECTRICAL;
            if(_loc2_ || this.m_previousElectricalColor != _loc3_)
            {
               this.m_previousElectricalColor = _loc3_;
               MenuUtils.setColor(this.m_view.electrical_icon_mc,MenuConstantsKnt.COLOR_WHITE,false);
               MenuUtils.setColor(this.m_view.main_mc.dial_mc,_loc3_,false);
               MenuUtils.setColor(this.m_view.main_mc.dial_gain_mc,_loc3_,false);
            }
         }
         else if(this.m_resourceType == PLAYER_RESOURCETYPE_CHEMICAL)
         {
            _loc4_ = MenuConstantsKnt.COLOR_HUD_RESOURCE_CHEMICAL;
            if(_loc2_ || this.m_previousChemicalColor != _loc4_)
            {
               this.m_previousChemicalColor = _loc4_;
               MenuUtils.setColor(this.m_view.chemical_icon_mc,MenuConstantsKnt.COLOR_WHITE,false);
               MenuUtils.setColor(this.m_view.main_mc.dial_mc,_loc4_,false);
               MenuUtils.setColor(this.m_view.main_mc.dial_gain_mc,_loc4_,false);
            }
         }
         if(param1.ammoCount != this.m_previousAmmoCount)
         {
            _loc5_ = false;
            _loc6_ = param1.ammoCount - this.m_previousAmmoCount;
            if(param1.ammoCount > this.m_previousAmmoCount)
            {
               _loc5_ = true;
            }
            this.setAmmo(param1.ammoMax,param1.ammoCount,_loc6_,_loc5_);
         }
         this.m_previousAmmoCount = param1.ammoCount;
      }
      
      private function setAmmo(param1:Number, param2:Number, param3:Number, param4:Boolean) : void
      {
         var ammoCurrentPercentage:Number;
         var ammoAmountDiffFromPrevPercentage:Number;
         var ammoDiffFromPrevCountFrames:int;
         var flashDialRotation:Number;
         var ammoCountFrames:int = 0;
         var ammoMax:Number = param1;
         var currentAmmo:Number = param2;
         var ammoDiffFromPrev:Number = param3;
         var ammoGained:Boolean = param4;
         if(currentAmmo < ammoMax)
         {
            if(!this.m_checkWhenResourceIsFullAgain)
            {
               this.m_checkWhenResourceIsFullAgain = true;
            }
         }
         if(currentAmmo >= ammoMax)
         {
            if(this.m_checkWhenResourceIsFullAgain)
            {
               this.m_playFullResourceAudioStinger = true;
               this.m_checkWhenResourceIsFullAgain = false;
            }
            currentAmmo = ammoMax;
         }
         ammoCurrentPercentage = Math.ceil(currentAmmo * 100 / ammoMax);
         ammoCountFrames = DIAL_NUM_FRAMES * (ammoCurrentPercentage / 100);
         ammoAmountDiffFromPrevPercentage = Math.ceil(ammoDiffFromPrev * 100 / ammoMax);
         ammoDiffFromPrevCountFrames = DIAL_NUM_FRAMES * (ammoAmountDiffFromPrevPercentage / (ammoAmountDiffFromPrevPercentage >= 0 ? 100 : -100));
         flashDialRotation = ammoAmountDiffFromPrevPercentage >= 0 ? (ammoCurrentPercentage - ammoAmountDiffFromPrevPercentage) * (360 / 100) : ammoCurrentPercentage * (360 / 100);
         if(ammoGained)
         {
            Animate.kill(this.m_view.main_mc);
            Animate.kill(this.m_view.main_mc.dial_mc);
            Animate.kill(this.m_view.main_mc.dial_gain_mc);
            Animate.kill(this.m_view.main_mc.dial_flash_mc);
            Animate.kill(this.m_view.main_mc.indents_mc);
            this.m_view.main_mc.dial_gain_mc.gotoAndStop(ammoCountFrames + 1);
            this.m_view.main_mc.dial_flash_mc.rotation = flashDialRotation;
            this.m_view.main_mc.dial_flash_mc.gotoAndStop(ammoDiffFromPrevCountFrames + 1);
            this.m_view.main_mc.dial_flash_mc.visible = true;
            Animate.delay(this.m_view.main_mc.dial_flash_mc,FLASH_ANIM_SPEED,function():void
            {
               m_view.main_mc.dial_flash_mc.visible = false;
               Animate.delay(m_view.main_mc.dial_flash_mc,FLASH_ANIM_SPEED,function():void
               {
                  m_view.main_mc.dial_flash_mc.visible = true;
                  Animate.delay(m_view.main_mc.dial_flash_mc,FLASH_ANIM_SPEED,function():void
                  {
                     m_view.main_mc.dial_flash_mc.visible = false;
                     Animate.delay(m_view.main_mc.dial_flash_mc,FLASH_ANIM_SPEED,function():void
                     {
                        m_view.main_mc.dial_flash_mc.visible = true;
                        Animate.delay(m_view.main_mc.dial_flash_mc,FLASH_ANIM_SPEED,function():void
                        {
                           m_view.main_mc.dial_flash_mc.visible = false;
                           Animate.fromTo(m_view.main_mc.dial_mc,OPEN_ANIM_SPEED / 2,0,{"frames":m_view.main_mc.dial_mc.currentFrame},{"frames":ammoCountFrames + 1},Animate.Linear,function():void
                           {
                              if(m_playFullResourceAudioStinger)
                              {
                                 CommonUtils.playSound(this,"SFX_GDT_GadgetReady");
                                 m_playFullResourceAudioStinger = false;
                              }
                           });
                           Animate.fromTo(m_view.main_mc.indents_mc,OPEN_ANIM_SPEED / 2,0,{"frames":m_view.main_mc.dial_mc.currentFrame},{"frames":ammoCountFrames},Animate.Linear);
                        });
                     });
                  });
               });
            });
            Animate.kill(this.m_view.main_mc);
            Animate.fromTo(this.m_view.main_mc,0.4,0,{
               "scaleX":1.4,
               "scaleY":1.4
            },{
               "scaleX":1,
               "scaleY":1
            },Animate.ExpoOut);
         }
         else
         {
            Animate.kill(this.m_view.main_mc);
            Animate.kill(this.m_view.main_mc.dial_mc);
            Animate.kill(this.m_view.main_mc.dial_gain_mc);
            Animate.kill(this.m_view.main_mc.dial_flash_mc);
            Animate.kill(this.m_view.main_mc.indents_mc);
            this.m_view.main_mc.dial_flash_mc.rotation = flashDialRotation;
            this.m_view.main_mc.dial_flash_mc.gotoAndStop(ammoDiffFromPrevCountFrames + 1);
            this.m_view.main_mc.dial_flash_mc.visible = true;
            Animate.delay(this.m_view.main_mc.dial_flash_mc,FLASH_ANIM_SPEED,function():void
            {
               m_view.main_mc.dial_flash_mc.visible = false;
            });
            this.m_view.main_mc.scaleX = this.m_view.main_mc.scaleY = 1;
            this.m_view.main_mc.dial_mc.gotoAndStop(ammoCountFrames + 1);
            this.m_view.main_mc.indents_mc.gotoAndStop(ammoCountFrames);
            Animate.fromTo(this.m_view.main_mc.dial_gain_mc,OPEN_ANIM_SPEED / 2,0,{"frames":this.m_view.main_mc.dial_gain_mc.currentFrame},{"frames":ammoCountFrames + 1},Animate.Linear);
         }
      }
      
      public function showRechargeTimer(param1:Boolean) : void
      {
         if(param1 && !this.m_recharging)
         {
            if(this.m_resourceType == PLAYER_RESOURCETYPE_ELECTRICAL)
            {
               this.m_view.electrical_icon_mc.visible = false;
               this.m_view.main_mc.electrical_dropshadow_mc.visible = false;
            }
            else if(this.m_resourceType == PLAYER_RESOURCETYPE_CHEMICAL)
            {
               this.m_view.chemical_icon_mc.visible = false;
               this.m_view.main_mc.chemical_dropshadow_mc.visible = false;
            }
            this.m_view.main_mc.dial_mc.alpha = 0.2;
            this.m_view.timer_hand_mc.visible = true;
            this.m_view.main_mc.timer_hand_dropshadow_mc.visible = true;
            this.m_view.timer_indents_mc.gotoAndStop(0);
            this.m_view.timer_indents_mc.visible = true;
            this.m_rechargeHandRotationCounter = 0;
            this.aniamteRechargeIndents(true);
            this.m_recharging = true;
         }
         else if(this.m_recharging)
         {
            if(this.m_resourceType == PLAYER_RESOURCETYPE_ELECTRICAL)
            {
               this.m_view.electrical_icon_mc.visible = true;
               this.m_view.main_mc.electrical_dropshadow_mc.visible = true;
            }
            else if(this.m_resourceType == PLAYER_RESOURCETYPE_CHEMICAL)
            {
               this.m_view.chemical_icon_mc.visible = true;
               this.m_view.main_mc.chemical_dropshadow_mc.visible = true;
            }
            this.m_view.main_mc.dial_mc.alpha = 1;
            Animate.kill(this.m_view.timer_hand_mc);
            this.m_view.timer_hand_mc.visible = false;
            this.m_view.main_mc.timer_hand_dropshadow_mc.visible = false;
            this.aniamteRechargeIndents(false);
            this.m_view.timer_indents_mc.gotoAndStop(0);
            this.m_view.timer_indents_mc.visible = false;
            this.m_recharging = false;
         }
      }
      
      private function aniamteRechargeIndents(param1:Boolean, param2:int = 0) : void
      {
         var start:Boolean = param1;
         var frame:int = param2;
         Animate.kill(this.m_view.timer_indents_mc);
         if(start)
         {
            frame += 2;
            this.m_view.timer_indents_mc.gotoAndStop(frame);
            Animate.delay(this.m_view.timer_indents_mc,this.m_rechargeDuration / 50,function():void
            {
               aniamteRechargeIndents(true,frame);
            });
         }
      }
      
      public function setRechargeTimer(param1:int) : void
      {
         if(this.m_recharging)
         {
            if(param1 >= this.m_rechargeHandRotationCounter + 6)
            {
               this.m_rechargeHandRotationCounter += 6;
               Animate.kill(this.m_view.timer_hand_mc);
               Animate.fromTo(this.m_view.timer_hand_mc,0.2,0,{"rotation":this.m_rechargeHandRotationCounter - 6},{"rotation":this.m_rechargeHandRotationCounter},Animate.ElasticOut);
            }
         }
      }
      
      public function rechargeDuration(param1:Number) : void
      {
         if(this.m_rechargeDuration != param1)
         {
            this.m_rechargeDuration = param1;
         }
      }
      
      public function setParentClass(param1:WatchGadgetResourcesWidget) : void
      {
         this.m_parentClassInstance = param1;
      }
   }
}
