package knt.hud.buttonprompts
{
   import flash.display.Sprite;
   import glacier.basic.ButtonPromptImage;
   import glacier.basic.ButtonPromptSpacingImage;
   import glacier.common.CommonUtils;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   
   public class ButtonPromptsWrapper extends Sprite
   {
      
      private static const SHOW_SPACING_ICONS:Boolean = false;
      
      private var m_buttonPrompts:Vector.<ButtonPromptImage>;
      
      private var m_buttonPromptSpacingIcons:Vector.<ButtonPromptSpacingImage>;
      
      public var m_spacingAmount:Number = 26;
      
      public function ButtonPromptsWrapper()
      {
         super();
         this.m_buttonPrompts = new Vector.<ButtonPromptImage>();
         this.m_buttonPromptSpacingIcons = new Vector.<ButtonPromptSpacingImage>();
      }
      
      public function updateData(param1:Object) : void
      {
         var _loc6_:Object = null;
         var _loc7_:ButtonPromptImage = null;
         var _loc8_:ButtonPromptImage = null;
         var _loc9_:ButtonPromptSpacingImage = null;
         var _loc10_:ButtonPromptSpacingImage = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Array = param1.aElements;
         var _loc5_:Number = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc4_.length)
         {
            if(_loc2_ >= this.m_buttonPrompts.length)
            {
               _loc8_ = ButtonPromptImage.AcquireInstance();
               this.m_buttonPrompts.push(_loc8_);
               addChild(_loc8_);
            }
            _loc6_ = _loc4_[_loc2_];
            _loc7_ = this.m_buttonPrompts[_loc2_];
            _loc7_.visible = true;
            _loc7_.platform = param1.controllerType;
            _loc7_.scaleX = _loc7_.scaleY = _loc7_.platform == "key" ? 0.5 : 0.7;
            _loc7_.x = _loc5_;
            _loc7_.y = 40;
            if((_loc7_.platform == CommonUtils.CONTROLLER_TYPE_KEY || _loc6_.iconId == -1) && _loc6_.keyGlyph != "")
            {
               _loc7_.customKey = _loc6_.keyGlyph;
            }
            else
            {
               _loc7_.button = _loc6_.iconId;
            }
            MenuUtils.addColorFilter(_loc7_,[MenuConstantsKnt.COLOR_MATRIX_INVERTED]);
            if(_loc2_ + 1 < _loc4_.length)
            {
               _loc5_ += _loc7_.width + this.m_spacingAmount;
               if(SHOW_SPACING_ICONS)
               {
                  if(_loc3_ >= this.m_buttonPromptSpacingIcons.length)
                  {
                     _loc10_ = ButtonPromptSpacingImage.AcquireInstance();
                     this.m_buttonPromptSpacingIcons.push(_loc10_);
                     addChild(_loc10_);
                  }
                  _loc9_ = this.m_buttonPromptSpacingIcons[_loc3_];
                  _loc9_.x = _loc5_ - _loc7_.width / 2 - this.m_spacingAmount / 2;
                  _loc9_.y = 40;
                  _loc9_.visible = true;
                  _loc3_++;
               }
            }
            _loc2_++;
         }
         _loc2_ = int(_loc4_.length);
         while(_loc2_ < this.m_buttonPrompts.length)
         {
            this.m_buttonPrompts[_loc2_].visible = false;
            _loc2_++;
         }
         _loc2_ = _loc3_;
         while(_loc2_ < this.m_buttonPromptSpacingIcons.length)
         {
            this.m_buttonPromptSpacingIcons[_loc2_].visible = false;
            _loc2_++;
         }
         x = -(_loc5_ / 2);
      }
      
      public function release() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this.m_buttonPrompts.length)
         {
            ButtonPromptImage.ReleaseInstance(this.m_buttonPrompts[_loc1_]);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_buttonPromptSpacingIcons.length)
         {
            ButtonPromptSpacingImage.ReleaseInstance(this.m_buttonPromptSpacingIcons[_loc1_]);
            _loc1_++;
         }
         while(this.m_buttonPrompts.length > 0)
         {
            this.m_buttonPrompts.pop();
         }
         while(this.m_buttonPromptSpacingIcons.length > 0)
         {
            this.m_buttonPromptSpacingIcons.pop();
         }
         while(numChildren > 0)
         {
            removeChildAt(numChildren - 1);
         }
      }
   }
}

