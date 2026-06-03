package knt.hud.buttonprompts
{
   import flash.geom.Point;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import glacier.basic.ButtonPromptImage;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.ImageLoader;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   
   public class RubberCamPromptWidget extends BaseControl
   {
      
      private static const PROMPT_PADDING:int = 10;
      
      private static const PROMPT_BACKGROUND_SIZE:int = 56;
      
      private static const PROMPT_ANIM_X_OFFSET:int = 15;
      
      private var m_textField:TextField;
      
      private var m_textFormat:TextFormat;
      
      private var m_promptImage:ButtonPromptImage;
      
      private var m_promptBackgroundImage:ImageLoader;
      
      private var m_promptImagePosition:Point = new Point(0,0);
      
      private var m_elementSize:Point = new Point(0,0);
      
      private var m_isRubberCamActive:Boolean = false;
      
      private var m_backgroundResourceID:String = "";
      
      private var m_label:String = "";
      
      private var m_promptControllerType:String = "";
      
      private var m_promptKeyGlyph:String = "";
      
      private var m_promptIconId:int = -2147483648;
      
      public function RubberCamPromptWidget()
      {
         super();
         this.m_promptBackgroundImage = new ImageLoader();
         this.m_promptBackgroundImage.width = PROMPT_BACKGROUND_SIZE;
         this.m_promptBackgroundImage.height = PROMPT_BACKGROUND_SIZE;
         addChild(this.m_promptBackgroundImage);
         this.m_textField = new TextField();
         this.m_textField.antiAliasType = AntiAliasType.ADVANCED;
         this.m_textField.embedFonts = false;
         this.m_textField.width = 1000;
         this.m_textFormat = new TextFormat();
         this.m_textFormat.letterSpacing = 0.2;
         addChild(this.m_textField);
         this.m_promptImage = new ButtonPromptImage();
         addChild(this.m_promptImage);
      }
      
      override public function onSetSize(param1:Number, param2:Number) : void
      {
         this.m_elementSize.x = param1;
         this.m_elementSize.y = param2;
         this.updateLayout();
      }
      
      public function onSetData(param1:Object) : void
      {
         var label:String;
         var controllerType:String;
         var keyGlyph:String = null;
         var iconId:int = 0;
         var data:Object = param1;
         var backgroundResourceID:String = data.promptBackgroundResourceID;
         if(backgroundResourceID != this.m_backgroundResourceID)
         {
            this.m_backgroundResourceID = backgroundResourceID;
            this.m_promptBackgroundImage.loadImage(this.m_backgroundResourceID,this.onImageCallbackSuccess);
         }
         label = data.label;
         if(this.m_label != label)
         {
            this.m_label = label;
            MenuUtils.setupText(this.m_textField,data.label,21,MenuConstantsKnt.FONT_TYPE_MEDIUM,MenuConstantsKnt.FontColorWhite);
         }
         controllerType = data.prompt.controllerType;
         if(this.m_promptControllerType != controllerType)
         {
            this.m_promptControllerType = controllerType;
            this.m_promptImage.platform = this.m_promptControllerType;
         }
         if(data.prompt.aElements.length > 0)
         {
            keyGlyph = data.prompt.aElements[0].keyGlyph;
            iconId = int(data.prompt.aElements[0].iconId);
            if(this.m_promptKeyGlyph != keyGlyph || this.m_promptIconId != iconId)
            {
               this.m_promptKeyGlyph = keyGlyph;
               this.m_promptIconId = iconId;
               if((this.m_promptImage.platform == "key" || this.m_promptIconId == -1) && this.m_promptKeyGlyph != "")
               {
                  this.m_promptImage.customKey = this.m_promptKeyGlyph;
               }
               else
               {
                  this.m_promptImage.button = this.m_promptIconId;
               }
            }
         }
         this.updateLayout();
         if(data.isActive != this.m_isRubberCamActive)
         {
            this.m_isRubberCamActive = data.isActive;
            if(this.m_isRubberCamActive)
            {
               Animate.kill(this.m_promptImage);
               Animate.fromTo(this.m_promptImage,0.5,0,{"x":this.m_promptImagePosition.x},{"x":this.m_promptImagePosition.x + PROMPT_ANIM_X_OFFSET},Animate.SineInOut,function():void
               {
                  animatePromptLoop();
               });
            }
         }
      }
      
      private function onImageCallbackSuccess() : void
      {
         this.m_promptBackgroundImage.width = PROMPT_BACKGROUND_SIZE;
         this.m_promptBackgroundImage.height = PROMPT_BACKGROUND_SIZE;
      }
      
      private function updateLayout() : void
      {
         this.m_textField.x = this.m_elementSize.x - this.m_textField.textWidth;
         this.m_textField.y = (PROMPT_BACKGROUND_SIZE - this.m_textField.textHeight) / 2;
         this.m_promptBackgroundImage.x = this.m_textField.x - PROMPT_BACKGROUND_SIZE - PROMPT_PADDING;
         this.m_promptImagePosition.x = this.m_promptBackgroundImage.x + PROMPT_BACKGROUND_SIZE / 2;
         this.m_promptImagePosition.y = this.m_promptBackgroundImage.y + PROMPT_BACKGROUND_SIZE / 2;
         this.m_promptImage.x = this.m_promptImagePosition.x;
         this.m_promptImage.y = this.m_promptImagePosition.y;
      }
      
      private function animatePromptLoop() : void
      {
         if(!this.m_isRubberCamActive)
         {
            return;
         }
         Animate.fromTo(this.m_promptImage,1,0,{"x":this.m_promptImagePosition.x + PROMPT_ANIM_X_OFFSET},{"x":this.m_promptImagePosition.x - PROMPT_ANIM_X_OFFSET},Animate.SineInOut,function():void
         {
            Animate.fromTo(m_promptImage,1,0,{"x":m_promptImagePosition.x - PROMPT_ANIM_X_OFFSET},{"x":m_promptImagePosition.x + PROMPT_ANIM_X_OFFSET},Animate.SineInOut,function():void
            {
               animatePromptLoop();
            });
         });
      }
   }
}

