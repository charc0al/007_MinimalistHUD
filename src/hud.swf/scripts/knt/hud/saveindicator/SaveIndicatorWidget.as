package knt.hud.saveindicator
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import knt.hud.*;
   
   public class SaveIndicatorWidget extends BaseControl
   {
      
      private var m_view:SaveIndicatorWidgetView;
      
      public function SaveIndicatorWidget()
      {
         super();
         this.m_view = new SaveIndicatorWidgetView();
         addChild(this.m_view);
         this.hideIndicator();
      }
      
      public function onSetData(param1:Object) : void
      {
         this.hideIndicator();
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         this.hideIndicator();
      }
      
      private function hideIndicator() : void
      {
         Animate.kill(this.m_view.outer_mc);
         Animate.kill(this.m_view.inner_mc);
         Animate.kill(this.m_view.title_txt);
         this.m_view.outer_mc.alpha = 0;
         this.m_view.inner_mc.alpha = 0;
         this.m_view.title_txt.alpha = 0;
         this.visible = false;
      }
   }
}
