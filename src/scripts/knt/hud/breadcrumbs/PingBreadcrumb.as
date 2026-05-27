package knt.hud.breadcrumbs
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.hud.PingBreadcrumbView;
   
   public class PingBreadcrumb extends BaseControl
   {
      
      private var m_view:PingBreadcrumbView;
      
      private const MAX_DISTANCE:int = 50;
      
      private const MIN_DISTANCE:int = 20;
      
      private const DISTANCE_SCALE_FACTOR:Number = 0.04;
      
      private const DISTANCE_SCALE_MAX:Number = 1.2;
      
      private const DISTANCE_SCALE_MIN:Number = 0.6;
      
      private const DISTANCE_DELAY_FACTOR:Number = 0.007;
      
      private const PLAY_RATE:Number = 1;
      
      private const LOOPS:int = 2;
      
      private const FRAME_RATE_RATIO:Number = 0.016;
      
      private var isAlive:Boolean = false;
      
      public function PingBreadcrumb()
      {
         super();
         this.m_view = new PingBreadcrumbView();
         this.m_view.visible = false;
         this.m_view.alpha = 1;
         this.m_view.scaleX = this.m_view.scaleY = 0.6;
         addChild(this.m_view);
      }
      
      public function ping(param1:Number) : void
      {
         this.isAlive = true;
         Animate.kill(this.m_view);
         Animate.delay(this.m_view,param1 * this.DISTANCE_DELAY_FACTOR,this.animStart);
      }
      
      private function animStart() : void
      {
         Animate.kill(this.m_view);
         this.m_view.alpha = 1;
         this.m_view.visible = true;
         Animate.fromTo(this.m_view,MenuUtils.roundDecimal(this.FRAME_RATE_RATIO * 30,1),0,{"frames":1},{"frames":49},Animate.Linear,function():void
         {
            animLoop();
         });
      }
      
      private function animLoop() : void
      {
         Animate.fromTo(this.m_view,MenuUtils.roundDecimal(this.FRAME_RATE_RATIO * 90,1),0,{"frames":50},{"frames":110},Animate.Linear,function():void
         {
            animLoop();
         });
      }
      
      private function animEnd() : void
      {
         var framesRemaining:Number;
         Animate.kill(this.m_view);
         this.isAlive = false;
         framesRemaining = (120 - this.m_view.currentFrame) / 5;
         Animate.fromTo(this.m_view,MenuUtils.roundDecimal(this.FRAME_RATE_RATIO * framesRemaining,3),0,{"frames":this.m_view.currentFrame},{"frames":110},Animate.Linear,function():void
         {
            Animate.fromTo(m_view,MenuUtils.roundDecimal(FRAME_RATE_RATIO * 70,1),0,{"frames":111},{"frames":162},Animate.Linear,function():void
            {
               m_view.visible = false;
               m_view.gotoAndStop(1);
            });
         });
      }
      
      public function hide() : void
      {
         if(this.isAlive)
         {
            this.animEnd();
         }
         else
         {
            this.m_view.visible = false;
         }
      }
   }
}

