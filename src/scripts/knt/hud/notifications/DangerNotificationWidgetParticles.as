package knt.hud.notifications
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.hud.*;
   
   public class DangerNotificationWidgetParticles extends BaseControl
   {
      
      private var m_view:DangerNotificationWidgetParticlesView;
      
      private var m_particlesArray:Array;
      
      public function DangerNotificationWidgetParticles()
      {
         var _loc1_:DangerNotificationWidgetParticleSingle = null;
         this.m_particlesArray = new Array();
         super();
         this.m_view = new DangerNotificationWidgetParticlesView();
         addChild(this.m_view);
         this.m_view.alpha = 0;
         var _loc2_:int = 0;
         while(_loc2_ < 40)
         {
            _loc1_ = new DangerNotificationWidgetParticleSingle();
            this.m_view.container_mc.addChild(_loc1_);
            this.m_particlesArray.push({"particle":_loc1_});
            _loc2_++;
         }
      }
      
      public function goParticlesBaby() : void
      {
         var i:int = 0;
         var xPos:Number = NaN;
         i = 0;
         while(i < this.m_particlesArray.length)
         {
            xPos = MenuUtils.getRandomInRange(-1200,1200,true) / 12;
            this.m_particlesArray[i].particle.doTheThing(xPos);
            i++;
         }
         this.m_view.alpha = 1;
         Animate.to(this.m_view,1,4,{"alpha":0},Animate.Linear,function():void
         {
            i = 0;
            while(i < m_particlesArray.length)
            {
               m_particlesArray[i].particle.stopTheThing();
               ++i;
            }
         });
      }
      
      public function stopParticlesBaby() : void
      {
         Animate.kill(this.m_view);
         var _loc1_:int = 0;
         while(_loc1_ < this.m_particlesArray.length)
         {
            this.m_particlesArray[_loc1_].particle.stopTheThing();
            _loc1_++;
         }
      }
   }
}
