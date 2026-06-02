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
         this.hideIndicator();
      }
      
      private function setGrenadeType(param1:String) : void
      {
         this.hideIndicator();
      }
      
      private function pulseAnim(param1:Boolean) : void
      {
         Animate.kill(this.m_view.icon_mc);
         Animate.kill(this.m_view.pulse_mc.rings_mc);
         Animate.kill(this.m_view.pulse_mc.bg_mc);
         this.m_fuseCountDown = 0;
      }
      
      public function activate() : void
      {
         this.hideIndicator();
      }
      
      public function activateSmokeNormal() : void
      {
         this.hideIndicator();
      }
      
      public function activateSmokeElectric() : void
      {
         this.hideIndicator();
      }
      
      public function activateExplosive() : void
      {
         this.hideIndicator();
      }
      
      public function activateFlash() : void
      {
         this.hideIndicator();
      }
      
      public function deactivate() : void
      {
         this.hideIndicator();
      }
      
      public function edgeAngle(param1:Number) : void
      {
         this.hideIndicator();
      }
      
      public function fuzeDuration(param1:Number) : void
      {
         this.m_fuseDuration = MenuUtils.roundDecimal(param1,2);
      }
      
      private function hideIndicator() : void
      {
         this.pulseAnim(false);
         this.m_view.direction_mc.visible = false;
         this.m_view.visible = false;
         this.m_edgeLocked = false;
      }
   }
}
