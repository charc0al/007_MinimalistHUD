package knt.hud.npcstate
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import knt.common.hud.KntHudUtils;
   import knt.hud.*;
   
   public class NpcMoveToWaypointWidget extends BaseControl
   {
      
      private var m_isAimingWatchLocalBool:Boolean = false;
      
      private var m_view:NpcMoveToWaypointWidgetView;
      
      public function NpcMoveToWaypointWidget()
      {
         super();
         this.m_view = new NpcMoveToWaypointWidgetView();
         this.m_view.alpha = 0.6;
         this.m_view.scaleX = this.m_view.scaleY = 0.25;
         this.m_view.visible = false;
         addChild(this.m_view);
         KntHudUtils.addOutline(this.m_view.waypoint_mc,0,0.5,2,6);
      }
      
      public function onSetData(param1:Object) : void
      {
         var data:Object = param1;
         this.m_isAimingWatchLocalBool = data.m_isAimingWatch == null ? false : Boolean(data.m_isAimingWatch);
         this.m_view.visible = true;
         if(!this.m_isAimingWatchLocalBool)
         {
            Animate.delay(this.m_view,2,function():void
            {
               if(!m_isAimingWatchLocalBool)
               {
                  m_view.visible = false;
               }
            });
         }
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         this.visible = param1;
         if(!param1)
         {
            this.m_view.visible = false;
            Animate.kill(this.m_view);
         }
      }
   }
}
