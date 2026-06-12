package glacier.basic
{
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.Localization;
   import glacier.common.ObjectPool;
   import glacier.common.menu.MenuConstants;
   import glacier.common.menu.MenuUtils;
   import scaleform.gfx.DisplayObjectEx;
   
   public class ButtonPromptImage extends BaseControl
   {
      private static var s_pool:ObjectPool = new ObjectPool(ButtonPromptImage,20);
      
      private static var s_pcLocalizedKey:Array = new Array({
         "id":39,
         "str":"cancel",
         "locStr":"UI_KEYPROMPT_ESC"
      },{
         "id":41,
         "str":"accept",
         "locStr":"UI_KEYPROMPT_ENTER"
      },{
         "id":42,
         "str":"",
         "locStr":"UI_KEYPROMPT_RALT"
      },{
         "id":43,
         "str":"",
         "locStr":"UI_KEYPROMPT_LALT"
      },{
         "id":44,
         "str":"",
         "locStr":"UI_KEYPROMPT_CAPSLOCK"
      },{
         "id":45,
         "str":"",
         "locStr":"UI_KEYPROMPT_RCTRL"
      },{
         "id":46,
         "str":"",
         "locStr":"UI_KEYPROMPT_LCTRL"
      },{
         "id":47,
         "str":"",
         "locStr":"UI_KEYPROMPT_RSHIFT"
      },{
         "id":48,
         "str":"",
         "locStr":"UI_KEYPROMPT_LSHIFT"
      },{
         "id":60,
         "str":"lb",
         "locStr":"UI_KEYPROMPT_PAGEUP"
      },{
         "id":61,
         "str":"rb",
         "locStr":"UI_KEYPROMPT_PAGEDOWN"
      });
      
      private var m_view:ButtonPromptView;
      private var m_platform:String;
      private const TEXTFIELD_MARGIN:Number = 4;
      
      public function ButtonPromptImage()
      {
         super();
         this.m_view = new ButtonPromptView();
         this.platform = ControlsMain.getControllerType();
         addChild(this.m_view);
      }
      
      public static function AcquireInstance() : ButtonPromptImage
      {
         var instance:ButtonPromptImage = s_pool.acquireObject();
         DisplayObjectEx.skipNextMatrixLerp(instance);
         return instance;
      }
      
      public static function ReleaseInstance(param1:ButtonPromptImage) : void
      {
         s_pool.releaseObject(param1);
      }
      
      public function getWidth() : Number
      {
         return this.m_view.button_mc.width;
      }
      
      public function set platform(param1:String) : void
      {
         var forcedPlatform:String = ControlsMain.applyForcedControllerType(param1);
         if(this.m_platform != forcedPlatform)
         {
            this.m_platform = forcedPlatform;
            CommonUtils.gotoFrameLabelAndStop(this.m_view,this.getFrameLabelForPlatform(forcedPlatform));
         }
      }
      
      public function get platform() : String
      {
         return this.m_platform;
      }
      
      public function set button(param1:Number) : void
      {
         var i:Number = NaN;
         this.m_view.button_mc.gotoAndStop(param1);
         if(this.m_platform == "key")
         {
            i = 0;
            while(i < s_pcLocalizedKey.length)
            {
               if(s_pcLocalizedKey[i].id == param1)
               {
                  this.localizeKey(s_pcLocalizedKey[i].locStr);
                  break;
               }
               i++;
            }
         }
         this.applyOpenVROffset();
      }
      
      public function set action(param1:String) : void
      {
         var useXbox360:Boolean = false;
         var usePs4Alt:Boolean = false;
         var acceptCancelLayout:int = 0;
         var faceDown:int = 0;
         var faceRight:int = 0;
         var frame:int = 0;
         var i:Number = NaN;
         if(this.platform == "pc")
         {
            if(param1 == "select" || param1 == "back")
            {
               useXbox360 = CommonUtils.isWindowsXBox360ControllerUsed();
               if(useXbox360)
               {
                  param1 += "_xbox360";
               }
            }
         }
         if(this.platform == "ps4")
         {
            if(param1 == "select")
            {
               usePs4Alt = CommonUtils.isDualShock4TrackpadAlternativeButtonNeeded();
               if(usePs4Alt)
               {
                  param1 += "_alt";
               }
            }
         }
         if(this.m_platform != "key" && (param1 == "accept" || param1 == "cancel"))
         {
            acceptCancelLayout = ControlsMain.getMenuAcceptCancelLayout();
            faceDown = 1;
            faceRight = 4;
            frame = param1 == "accept" ? (acceptCancelLayout == CommonUtils.MENU_ACCEPTFACERIGHT_CANCELFACEDOWN ? faceRight : faceDown) : (acceptCancelLayout == CommonUtils.MENU_ACCEPTFACERIGHT_CANCELFACEDOWN ? faceDown : faceRight);
            this.m_view.button_mc.gotoAndStop(frame);
         }
         else
         {
            CommonUtils.gotoFrameLabelAndStop(this.m_view.button_mc,param1);
         }
         if(this.m_platform == "key" && param1 != "")
         {
            i = 0;
            while(i < s_pcLocalizedKey.length)
            {
               if(s_pcLocalizedKey[i].str == param1)
               {
                  this.localizeKey(s_pcLocalizedKey[i].locStr);
                  break;
               }
               i++;
            }
         }
         this.applyOpenVROffset();
      }
      
      public function set customKey(param1:String) : void
      {
         var defaultFormat:TextFormat = null;
         var resizedFormat:TextFormat = null;
         this.platform = "key";
         this.m_view.button_mc.gotoAndStop("customKey");
         this.m_view.button_mc.key_txt.htmlText = param1;
         this.m_view.button_mc.key_txt.autoSize = TextFieldAutoSize.CENTER;
         if(!CommonUtils.changeFontToGlobalIfNeeded(this.m_view.button_mc.key_txt))
         {
            defaultFormat = this.m_view.button_mc.key_txt.defaultTextFormat;
            this.m_view.button_mc.key_txt.setTextFormat(defaultFormat);
         }
         else
         {
            resizedFormat = new TextFormat();
            resizedFormat.size = this.m_view.button_mc.key_txt.defaultTextFormat.size;
            this.m_view.button_mc.key_txt.setTextFormat(resizedFormat);
         }
         MenuUtils.shrinkTextToFit(this.m_view.button_mc.key_txt,42,34);
         this.m_view.button_mc.key_txt.y = -Math.floor((this.m_view.button_mc.key_txt.textHeight + this.TEXTFIELD_MARGIN) / 2);
         this.resetOpenVROffset();
      }
      
      public function set invert(param1:Boolean) : void
      {
         MenuUtils.addColorFilter(this.m_view,param1 ? [MenuConstants.COLOR_MATRIX_INVERTED] : []);
      }
      
      private function localizeKey(param1:String) : void
      {
         var localized:String = null;
         var wordCount:int = 0;
         var multiLineFormat:TextFormat = null;
         if(this.m_view.button_mc.button_txt != null)
         {
            localized = Localization.get(param1);
            this.m_view.button_mc.button_txt.text = localized;
            wordCount = int(localized.match(/[^\s]+/g).length);
            if(wordCount <= 1)
            {
               MenuUtils.shrinkTextToFit(this.m_view.button_mc.button_txt,-1,-1,9,1);
            }
            else
            {
               multiLineFormat = new TextFormat();
               multiLineFormat.leading = -7;
               this.m_view.button_mc.button_txt.setTextFormat(multiLineFormat);
               MenuUtils.shrinkTextToFit(this.m_view.button_mc.button_txt,-1,-1,9,2);
            }
            this.m_view.button_mc.button_txt.y = -Math.floor((this.m_view.button_mc.button_txt.textHeight + this.TEXTFIELD_MARGIN) / 2);
         }
         this.resetOpenVROffset();
      }
      
      private function applyOpenVROffset() : void
      {
         var component:* = undefined;
         if(this.m_platform == "openvr")
         {
            component = BitmapReplacementOpenVR.getComponentDescForGamepadButtonID(this.m_view.button_mc.currentFrame);
            if(component != null)
            {
               if(component.idArchetype == BitmapReplacementOpenVR.ARCHETYPEID_ButtonL || component.idArchetype == BitmapReplacementOpenVR.ARCHETYPEID_ButtonR)
               {
                  this.m_view.y = 3;
                  return;
               }
            }
         }
         this.m_view.y = 0;
      }
      
      private function getFrameLabelForPlatform(param1:String) : String
      {
         switch(param1)
         {
            case CommonUtils.CONTROLLER_TYPE_SWITCHPRO:
            case CommonUtils.CONTROLLER_TYPE_SWITCHJOYCON:
               return "nsp";
            default:
               return param1;
         }
      }
      
      private function resetOpenVROffset() : void
      {
         this.m_view.y = 0;
      }
   }
}
