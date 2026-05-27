package knt.hud
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1954")]
   public dynamic class OffscreenMeleeDirectionWidgetIndicatorView extends MovieClip
   {
      
      public function OffscreenMeleeDirectionWidgetIndicatorView()
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

