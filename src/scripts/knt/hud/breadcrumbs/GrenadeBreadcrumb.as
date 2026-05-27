package knt.hud.breadcrumbs
{
   import flash.filters.DropShadowFilter;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class GrenadeBreadcrumb extends BaseControl
   {
      
      private static const FLASH_ANIM_REGULAR_SPEED:Number = 0.6;
      
      private static const FLASH_ANIM_FAST_SPEED:Number = 0.4;
      
      private var m_view:GrenadeBreadcrumbView;
      
      private var m_edgeLocked:Boolean = false;
      
      private var m_fuseDuration:Number = 0;
      
      private var m_fuseCountDown:Number = 0;
      
      public function GrenadeBreadcrumb()
      {
         super();
         this.m_view = new GrenadeBreadcrumbView();
         this.m_view.visible = false;
         this.m_view.direction_mc.visible = false;
         MenuUtils.setColor(this.m_view.pulse_mc.bg_mc,MenuConstantsKnt.COLOR_HUD_DANGER_HIGH);
         this.m_view.filters = [new DropShadowFilter(2,30,0,0.5,2,2,1,1)];
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
      }
      
      private function setGrenadeType(param1:String) : void
      {
         switch(param1)
         {
            case "smoke":
               this.m_view.icon_mc.gotoAndStop("smoke");
               break;
            case "electric":
               this.m_view.icon_mc.gotoAndStop("electric");
               break;
            case "explosive":
               this.m_view.icon_mc.gotoAndStop("frag");
               break;
            case "flash":
               this.m_view.icon_mc.gotoAndStop("flash");
               break;
            default:
               this.m_view.icon_mc.gotoAndStop("default");
         }
         this.pulseAnim(true);
         this.m_view.visible = true;
      }
      
      private function pulseAnim(param1:Boolean) : void
      {
         var variableSpeed:Number = NaN;
         var show:Boolean = param1;
         Animate.kill(this.m_view.icon_mc);
         Animate.kill(this.m_view.pulse_mc.rings_mc);
         Animate.kill(this.m_view.pulse_mc.bg_mc);
         this.m_view.icon_mc.alpha = 1;
         this.m_view.pulse_mc.rings_mc.gotoAndStop(0);
         this.m_view.pulse_mc.bg_mc.gotoAndStop(0);
         if(show)
         {
            variableSpeed = FLASH_ANIM_REGULAR_SPEED;
            if(this.m_fuseDuration - this.m_fuseCountDown <= 0.8)
            {
               variableSpeed = FLASH_ANIM_FAST_SPEED;
            }
            Animate.to(this.m_view.icon_mc,variableSpeed / 2,0,{"alpha":0.7},Animate.Linear,function():void
            {
               m_fuseCountDown += variableSpeed;
               Animate.to(m_view.icon_mc,variableSpeed / 2,0,{"alpha":1},Animate.Linear);
            });
            Animate.fromTo(this.m_view.pulse_mc.rings_mc,variableSpeed,0,{"frames":0},{"frames":60},Animate.Linear);
            Animate.fromTo(this.m_view.pulse_mc.bg_mc,variableSpeed,0,{"frames":0},{"frames":60},Animate.Linear,function():void
            {
               pulseAnim(true);
            });
         }
         else
         {
            this.m_fuseCountDown = 0;
         }
      }
      
      public function activate() : void
      {
         this.setGrenadeType("flash");
      }
      
      public function activateSmokeNormal() : void
      {
         this.setGrenadeType("smoke");
      }
      
      public function activateSmokeElectric() : void
      {
         this.setGrenadeType("electric");
      }
      
      public function activateExplosive() : void
      {
         this.setGrenadeType("explosive");
      }
      
      public function activateFlash() : void
      {
         this.setGrenadeType("flash");
      }
      
      public function deactivate() : void
      {
         this.pulseAnim(false);
         this.m_view.visible = false;
      }
      
      public function edgeAngle(param1:Number) : void
      {
         if(param1 < 0)
         {
            if(this.m_edgeLocked)
            {
               this.m_view.direction_mc.visible = false;
               this.m_edgeLocked = false;
            }
         }
         else
         {
            if(!this.m_edgeLocked)
            {
               this.m_view.direction_mc.visible = true;
               this.m_edgeLocked = true;
            }
            this.m_view.direction_mc.rotation = param1;
         }
      }
      
      public function fuzeDuration(param1:Number) : void
      {
         this.m_fuseDuration = MenuUtils.roundDecimal(param1,2);
      }
   }
}

