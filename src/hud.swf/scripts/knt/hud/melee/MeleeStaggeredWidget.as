package knt.hud.melee
{
   import glacier.common.BaseControl;
   import knt.hud.MeleeStaggeredWidgetView;
   
   public class MeleeStaggeredWidget extends BaseControl
   {
      
      private var m_view:MeleeStaggeredWidgetView;
      
      private var m_isFinishable:Boolean = false;
      
      public function MeleeStaggeredWidget()
      {
         super();
      }
      
      public function onSetData(param1:Object) : void
      {
      }
   }
}

