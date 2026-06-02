package knt.hud.notifications
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import knt.hud.*;
   
   public class StateNotificationWidget extends BaseControl
   {
      
      private var m_view:StateNotificationWidgetView;
      
      private var m_hidden:Boolean = false;
      
      private var m_disguised:Boolean = false;
      
      public function StateNotificationWidget()
      {
         super();
         this.m_view = new StateNotificationWidgetView();
         this.m_view.hidden_mc.visible = false;
         this.m_view.hidden_mc.alpha = 0;
         this.m_view.hidden_mc.y = 60;
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
         this.hideHidden();
      }
      
      private function prepareHidden() : void
      {
      }
      
      private function showHidden() : void
      {
         Animate.kill(this.m_view.hidden_mc);
         this.m_view.hidden_mc.visible = true;
         Animate.to(this.m_view.hidden_mc,0.4,0,{
            "alpha":1,
            "y":80
         },Animate.ExpoOut);
      }
      
      private function hideHidden() : void
      {
         Animate.kill(this.m_view.hidden_mc);
         this.m_view.hidden_mc.visible = false;
         this.m_view.hidden_mc.alpha = 0;
         this.m_view.hidden_mc.y = 60;
      }
   }
}
