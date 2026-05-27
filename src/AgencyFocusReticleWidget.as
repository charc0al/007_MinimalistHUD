package knt.hud.weapons
{
   import glacier.common.BaseControl;
   import knt.hud.ThrowableReticleWidgetView;
   
   public class AgencyFocusReticleWidget extends BaseControl
   {
      
      private var m_view:ThrowableReticleWidgetView;
      
      public function AgencyFocusReticleWidget()
      {
         super();
      }
      
      public function setType(param1:Number) : void
      {
      }
      
      public function setCrosshairPosition(param1:Number, param2:Number) : void
      {
      }
      
      override public function onSetSize(param1:Number, param2:Number) : void
      {
         super.onSetSize(param1,param2);
      }
   }
}

