package knt.hud
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1130")]
   public dynamic class PingWidgetView extends Sprite
   {
      
      public var backdrop_mc:MovieClip;
      
      public var container_mc:MovieClip;
      
      public var degree_txt:TextField;
      
      public var scan_result_mc:MovieClip;
      
      public var search_mc:MovieClip;
      
      public function PingWidgetView()
      {
         super();
      }
   }
}

