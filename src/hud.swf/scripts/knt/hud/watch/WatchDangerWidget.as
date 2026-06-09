package knt.hud.watch
{
   import flash.text.TextFormat;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.Localization;
   import glacier.common.ObjectUtils;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class WatchDangerWidget extends BaseControl
   {
      
      private static const ANIM_SPEED:Number = 1;
      
      private static const FLASH_ANIM_SPEED:Number = 0.03;
      
      private static const ICON_PULSE_SPEED:Number = 0.4;
      
      private static const BASE_SCALE:Number = 0.75;
      
      private static const AIMING_SCALE:Number = BASE_SCALE * 1.3;
      
      private static const BASE_X_OFFSET:Number = -45;
      
      private var m_view:WatchDangerWidgetView;
      
      private var m_lethalForceEnabled:Boolean = false;
      
      private var m_trespassing:Boolean = false;
      
      private var m_softTrespassing:Boolean = false;
      
      private var m_hidden:Boolean = false;
      
      private var m_disguised:Boolean = false;
      
      private var m_dangerIsShown:Boolean = false;
      
      private var m_infoMcWidth:int = 0;
      
      private var m_hiddenMcWidth:int = 0;
      
      private var m_triangulationModeHidden:Boolean = false;
      
      private var m_newFormat:TextFormat = new TextFormat();
      
      private var m_isAimingWatch:Boolean = true;
      
      private var m_ignoreDangerStates:Boolean = false;
      
      private var m_dataCloned:Object;
      
      public function WatchDangerWidget()
      {
         super();
         this.m_newFormat.letterSpacing = 8;
         this.m_view = new WatchDangerWidgetView();
         this.m_view.trespass_bg_mc.alpha = 0;
         this.m_view.warning_mc.alpha = 0;
         this.m_view.warning_mc.sign_mc.alpha = 0.4;
         MenuUtils.setColor(this.m_view.warning_mc.sign_mc,MenuConstantsKnt.COLOR_GREY_ULTRA_DARK,false);
         this.m_view.warning_bg_mc.alpha = 0.4;
         this.m_view.info_mc.visible = false;
         this.m_view.info_mc.desc_mc.visible = false;
         this.m_view.info_mc.desc_mc.bg_mc.alpha = 0.6;
         this.m_view.hidden_mc.visible = false;
         this.m_view.hidden_mc.desc_mc.visible = false;
         this.m_view.hidden_mc.desc_mc.bg_mc.alpha = 0.6;
         if(MenuConstantsKnt.INVERT_Q_WATCH_DISPLAY)
         {
            this.m_view.scaleX = this.m_view.scaleY = AIMING_SCALE;
            this.m_view.x = BASE_X_OFFSET - 180;
            this.m_view.y = 100;
            this.m_view.alpha = 0;
            this.m_isAimingWatch = true;
         }
         else
         {
            this.m_view.scaleX = this.m_view.scaleY = BASE_SCALE;
            this.m_view.x = BASE_X_OFFSET;
            this.m_view.y = 0;
            this.m_view.alpha = 1;
            this.m_isAimingWatch = false;
         }
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
         if(param1.commonData.isInTriangulationMode)
         {
            if(!this.m_triangulationModeHidden)
            {
               this.m_view.trespass_bg_mc.visible = false;
               this.m_view.warning_mc.visible = false;
               this.m_view.warning_bg_mc.visible = false;
               this.m_triangulationModeHidden = true;
            }
         }
         else if(this.m_triangulationModeHidden)
         {
            this.m_view.trespass_bg_mc.visible = true;
            this.m_view.warning_mc.visible = true;
            this.m_view.warning_bg_mc.visible = true;
            this.m_triangulationModeHidden = false;
         }
          if((MenuConstantsKnt.INVERT_Q_WATCH_DISPLAY ? Boolean(param1.commonData.isAimingWatch) : !Boolean(param1.commonData.isAimingWatch)))
          {
             if(this.m_isAimingWatch)
             {
                Animate.kill(this.m_view);
                Animate.to(this.m_view,0.2,0,{
                   "x":BASE_X_OFFSET,
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
                "x":BASE_X_OFFSET - 180,
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
          if(param1 == null)
          {
             return;
          }
          this.m_dataCloned = ObjectUtils.cloneDeep(param1);
          if(this.m_ignoreDangerStates)
          {
             if(this.m_dangerIsShown)
             {
                this.setDangerState(false);
                this.m_lethalForceEnabled = false;
                this.m_trespassing = false;
                this.m_softTrespassing = false;
             }
             return;
          }
          if(param1.commonData.isLethalForceEnabled != this.m_lethalForceEnabled || param1.commonData.isTrespassing != this.m_trespassing || param1.commonData.isSoftTrespassing != this.m_softTrespassing)
          {
             this.m_lethalForceEnabled = param1.commonData.isLethalForceEnabled;
             this.m_trespassing = param1.commonData.isTrespassing;
             this.m_softTrespassing = param1.commonData.isSoftTrespassing;
             this.updateDangerState();
          }
       }
      
      private function setDangerState(param1:Boolean, param2:String = "", param3:int = 0) : void
      {
         var start:Boolean = param1;
         var infoTitle:String = param2;
         var col:int = param3;
         Animate.kill(this.m_view.trespass_bg_mc);
         Animate.kill(this.m_view.trespass_bg_mc.inner_mc);
         Animate.kill(this.m_view.warning_mc);
         Animate.kill(this.m_view.warning_mc.inner_mc);
         if(start)
         {
            if(this.m_dangerIsShown)
            {
               Animate.to(this.m_view.trespass_bg_mc,ANIM_SPEED * 0.2,0,{"alpha":0},Animate.ExpoOut,function():void
               {
                  showDangerState(col,infoTitle);
               });
               Animate.to(this.m_view.warning_mc,ANIM_SPEED * 0.2,0,{"alpha":0},Animate.ExpoOut);
            }
            else
            {
               this.showDangerState(col,infoTitle);
            }
            this.m_dangerIsShown = true;
         }
         else
         {
            this.hideDangerState();
            this.m_dangerIsShown = false;
         }
      }
      
      private function showDangerState(param1:int, param2:String = "") : void
      {
         var col:int = param1;
         var infoTitle:String = param2;
         this.prepareInfo(infoTitle,col);
         this.m_view.trespass_bg_mc.alpha = 0;
         this.m_view.warning_mc.alpha = 0;
         Animate.delay(this.m_view.trespass_bg_mc,FLASH_ANIM_SPEED + 0.3,function():void
         {
            m_view.trespass_bg_mc.alpha = 1;
            m_view.warning_mc.alpha = 1;
            Animate.delay(m_view.trespass_bg_mc,FLASH_ANIM_SPEED,function():void
            {
               m_view.trespass_bg_mc.alpha = 0;
               m_view.warning_mc.alpha = 0;
               Animate.delay(m_view.trespass_bg_mc,FLASH_ANIM_SPEED,function():void
               {
                  m_view.trespass_bg_mc.alpha = 0.8;
                  m_view.warning_mc.alpha = 1;
                  Animate.delay(m_view.trespass_bg_mc,FLASH_ANIM_SPEED,function():void
                  {
                     m_view.trespass_bg_mc.alpha = 0;
                     m_view.warning_mc.alpha = 0;
                     Animate.delay(m_view.trespass_bg_mc,FLASH_ANIM_SPEED,function():void
                     {
                        m_view.trespass_bg_mc.alpha = 0.6;
                        m_view.warning_mc.alpha = 1;
                        Animate.delay(m_view.trespass_bg_mc,FLASH_ANIM_SPEED,function():void
                        {
                           m_view.trespass_bg_mc.alpha = 0;
                           m_view.warning_mc.alpha = 0;
                           Animate.delay(m_view.trespass_bg_mc,FLASH_ANIM_SPEED,function():void
                           {
                              m_view.trespass_bg_mc.alpha = 0.4;
                              m_view.warning_mc.alpha = 1;
                              pulsateIcon(true,5);
                              Animate.to(m_view.trespass_bg_mc,ANIM_SPEED,0,{"alpha":0},Animate.ExpoOut);
                           });
                        });
                     });
                  });
               });
            });
         });
      }
      
      private function hideDangerState() : void
      {
         Animate.to(this.m_view.trespass_bg_mc,ANIM_SPEED * 0.2,0,{"alpha":0},Animate.ExpoOut);
         this.pulsateIcon(false,0);
         Animate.to(this.m_view.warning_mc,ANIM_SPEED * 0.2,0,{"alpha":0},Animate.ExpoOut);
      }
      
      public function updateDangerState() : void
      {
         if(this.m_trespassing)
         {
            if(this.m_lethalForceEnabled)
            {
               this.setDangerState(true,Localization.get("UI_HUD_DANGER_LICENCE_TO_KILL_TITLE"),MenuConstantsKnt.COLOR_HUD_DANGER_HIGH);
               return;
            }
            this.setDangerState(true,Localization.get("UI_HUD_DANGER_TRESPASSING_TITLE"),MenuConstantsKnt.COLOR_HUD_DANGER_MED);
            return;
         }
         if(this.m_softTrespassing)
         {
            this.setDangerState(true,Localization.get("UI_HUD_DANGER_SOFT_TRESPASSING_TITLE"),MenuConstantsKnt.COLOR_HUD_DANGER_MED);
            return;
         }
         if(this.m_dangerIsShown)
         {
            this.setDangerState(false);
            this.m_lethalForceEnabled = false;
            this.m_trespassing = false;
            this.m_softTrespassing = false;
         }
      }
      
      private function pulsateIcon(param1:Boolean, param2:int) : void
      {
         var start:Boolean = param1;
         var count:int = param2;
         Animate.kill(this.m_view.warning_mc);
         this.m_view.warning_mc.alpha = 1;
         if(start && count > 0)
         {
            Animate.delay(this.m_view.warning_mc,ICON_PULSE_SPEED,function():void
            {
               m_view.warning_mc.alpha = 0;
               Animate.delay(m_view.warning_mc,ICON_PULSE_SPEED,function():void
               {
                  --count;
                  pulsateIcon(true,count);
               });
            });
         }
      }
      
      private function prepareInfo(param1:String, param2:int) : void
      {
         MenuUtils.setColor(this.m_view.trespass_bg_mc.inner_mc,param2,false);
         MenuUtils.setColor(this.m_view.warning_mc.inner_mc,param2,false);
      }
      
      public function set ignoreDangerStates(param1:Boolean) : void
      {
         if(this.m_ignoreDangerStates != param1)
         {
            this.m_ignoreDangerStates = param1;
            if(this.m_ignoreDangerStates)
            {
               if(this.m_dangerIsShown)
               {
                  this.setDangerState(false);
                  this.m_lethalForceEnabled = false;
                  this.m_trespassing = false;
                  this.m_softTrespassing = false;
               }
            }
            else
            {
               this.onSetData(this.m_dataCloned);
            }
         }
      }
   }
}

