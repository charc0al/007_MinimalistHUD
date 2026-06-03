package glacier.basic
{
   import glacier.common.BaseControl;
   
   public class Mask extends BaseControl
   {
      
      private var m_view:MaskView;
      
      public function Mask()
      {
         super();
         this.m_view = new MaskView();
         addChild(this.m_view);
         this.mask = this.m_view;
      }
      
      override public function onSetSize(param1:Number, param2:Number) : void
      {
         this.m_view.width = param1;
         this.m_view.height = param2;
      }
   }
}

