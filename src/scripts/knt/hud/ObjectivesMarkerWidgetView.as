package knt.hud
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol3322")]
   public dynamic class ObjectivesMarkerWidgetView extends Sprite
   {
      
      public var direction_mc:MovieClip;
      
      public var distance_txt:TextField;
      
      public var elevation_down_mc:MovieClip;
      
      public var elevation_up_mc:MovieClip;
      
      public var icon_container_mc:MovieClip;
      
      public function ObjectivesMarkerWidgetView()
      {
         super();
      }
   }
}

