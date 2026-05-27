package glacier.basic
{
   import flash.display.Sprite;
   import glacier.common.ObjectPool;
   import scaleform.gfx.DisplayObjectEx;
   
   public class ButtonPromptSpacingImage extends Sprite
   {
      
      private static var s_pool:ObjectPool = new ObjectPool(ButtonPromptSpacingImage,20);
      
      private var m_view:ButtonPromptSpacingIconView;
      
      public function ButtonPromptSpacingImage()
      {
         super();
         this.m_view = new ButtonPromptSpacingIconView();
         addChild(this.m_view);
      }
      
      public static function AcquireInstance() : ButtonPromptSpacingImage
      {
         var _loc1_:ButtonPromptSpacingImage = s_pool.acquireObject();
         DisplayObjectEx.skipNextMatrixLerp(_loc1_);
         return _loc1_;
      }
      
      public static function ReleaseInstance(param1:ButtonPromptSpacingImage) : void
      {
         s_pool.releaseObject(param1);
      }
      
      public function getWidth() : Number
      {
         return this.m_view.icon_mc.width;
      }
      
      public function getHeight() : Number
      {
         return this.m_view.icon_mc.height;
      }
   }
}

