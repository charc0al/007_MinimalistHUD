package knt.hud
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol1440")]
   public dynamic class CommsWidgetView extends Sprite
   {
      
      public var bg_mc:MovieClip;
      
      public var column_mc:MovieClip;
      
      public var container_mc:MovieClip;
      
      public var image_mc:MovieClip;
      
      public var title_txt:TextField;
      
      public function CommsWidgetView()
      {
         super();
      }
   }
}

