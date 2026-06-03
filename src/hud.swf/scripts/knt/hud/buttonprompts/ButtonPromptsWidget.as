package knt.hud.buttonprompts
{
   import flash.display.Sprite;
   import glacier.common.BaseControl;
   import knt.hud.*;
   
   public class ButtonPromptsWidget extends BaseControl
   {
      
      private const MAX_PROMPTS:int = 6;
      
      private var m_view:Sprite;
      
      private var m_buttonClips:Vector.<ButtonPromptWidget>;
      
      public function ButtonPromptsWidget()
      {
         var _loc2_:ButtonPromptWidget = null;
         this.m_buttonClips = new Vector.<ButtonPromptWidget>();
         super();
         this.m_view = new Sprite();
         addChild(this.m_view);
         var _loc1_:int = 0;
         while(_loc1_ < this.MAX_PROMPTS)
         {
            _loc2_ = new ButtonPromptWidget();
            _loc2_.y = -44 * _loc1_;
            this.m_buttonClips.push(this.m_view.addChild(_loc2_));
            _loc1_++;
         }
      }
      
      public function onSetData(param1:Object) : void
      {
         var _loc2_:Array = param1.Prompts as Array;
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            this.m_buttonClips[_loc3_].visible = true;
            this.m_buttonClips[_loc3_].onSetData(_loc2_[_loc3_]);
            _loc3_++;
         }
         _loc3_ = int(_loc2_.length);
         while(_loc3_ < this.MAX_PROMPTS)
         {
            this.m_buttonClips[_loc3_].visible = false;
            _loc3_++;
         }
      }
   }
}

