package knt.hud.notifications
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.hud.DangerNotificationWidgetParticleSingleView;
   
   public class DangerNotificationWidgetParticleSingle extends BaseControl
   {
      
      private var m_view:DangerNotificationWidgetParticleSingleView;
      
      public function DangerNotificationWidgetParticleSingle()
      {
         super();
         this.m_view = new DangerNotificationWidgetParticleSingleView();
         addChild(this.m_view);
         this.m_view.alpha = 0;
      }
      
      public function doTheThing(param1:Number) : void
      {
         this.m_view.alpha = 0;
         this.m_view.x = param1;
         var _loc2_:int = MenuUtils.getRandomInRange(0,50,true);
         var _loc3_:int = MenuUtils.getRandomInRange(150,400,true);
         var _loc4_:Number = MenuUtils.getRandomInRange(200,299,true) / 10;
         var _loc5_:Number = MenuUtils.getRandomInRange(0,10,true) / 10;
         var _loc6_:Number = MenuUtils.getRandomInRange(40,100,true) / 100;
         var _loc7_:int = MenuUtils.getRandomInRange(1,3,true);
         var _loc8_:Number = param1 + param1;
         this.m_view.y = _loc2_;
         this.spinTheThing(_loc4_ / _loc7_,_loc7_);
         Animate.to(this.m_view,_loc4_,_loc5_,{
            "x":_loc8_,
            "y":_loc3_
         },Animate.QuadOut);
         Animate.addTo(this.m_view,_loc4_ / 10,_loc5_,{"alpha":_loc6_},Animate.QuadOut);
      }
      
      private function spinTheThing(param1:Number, param2:int) : void
      {
         var speed:Number = param1;
         var times:int = param2;
         this.m_view.particle_mc.rotationY = 0;
         Animate.to(this.m_view.particle_mc,speed,0,{"rotationY":180},Animate.Linear,function():void
         {
            if(times > 0)
            {
               spinTheThing(speed,times = times - 1);
            }
         });
      }
      
      public function stopTheThing() : void
      {
         Animate.kill(this.m_view);
         Animate.kill(this.m_view.particle_mc);
         this.m_view.alpha = 0;
         this.m_view.y = 0;
         this.m_view.particle_mc.rotationY = 0;
      }
   }
}
