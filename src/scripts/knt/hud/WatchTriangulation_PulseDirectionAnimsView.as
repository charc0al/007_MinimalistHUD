package knt.hud
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1828")]
   public dynamic class WatchTriangulation_PulseDirectionAnimsView extends MovieClip
   {
      
      public function WatchTriangulation_PulseDirectionAnimsView()
      {
         super();
         addFrameScript(80,this.frame81,161,this.frame162,242,this.frame243);
      }
      
      internal function frame81() : *
      {
         gotoAndPlay("far");
      }
      
      internal function frame162() : *
      {
         gotoAndPlay("medium");
      }
      
      internal function frame243() : *
      {
         gotoAndPlay("close");
      }
   }
}

