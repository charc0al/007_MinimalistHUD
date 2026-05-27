package knt.hud
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol692")]
   public dynamic class PingBreadcrumbView extends MovieClip
   {
      
      public function PingBreadcrumbView()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         stop();
      }
   }
}

