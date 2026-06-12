package
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import glacier.common.CommonUtils;
   import knt.common.menu.MenuConstantsKnt;
   import scaleform.gfx.*;
   
   public class ControlsMain extends Sprite
   {
      private static var ms_instance:ControlsMain = null;
      private static var ms_invertEnabledChannels:Boolean = false;
      private static var ms_enabledChannels:Dictionary = new Dictionary();
      private static var ms_isMouseActive:Boolean = false;
      private static var ms_onMouseActiveChanged:Function = null;
      private static var ms_isVrModeActive:Boolean = false;
      private static var ms_activeLocale:String = "";
      private static var ms_controllerType:String = "";
      private static var ms_isVRLaserPointerActive:Boolean = false;
      private static var ms_menuAcceptCancelLayout:int = 0;
      public static const DISPLAY_SIZE_NORMAL:int = 0;
      public static const DISPLAY_SIZE_SMALL:int = 1;
      private static var ms_displaySize:int = DISPLAY_SIZE_NORMAL;
      public static var ms_frameCount:int = -1;
      public static const MENUINPUTCAPABILITY_TEXTINPUT_VIA_PHYSICAL_KEYBOARD:int = 1 << 0;
      public static const MENUINPUTCAPABILITY_TEXTINPUT_VIA_VIRTUAL_KEYBOARD:int = 1 << 1;
      public static const MENUINPUTCAPABILITY_NAVIGATION_VIA_MOUSE:int = 1 << 2;
      public static const MENUINPUTCAPABILITY_NAVIGATION_VIA_PHYSICAL_KEYBOARD:int = 1 << 3;
      public static const VRLASERPOINTERTRIGGERPROMPT_NONE:int = 0;
      public static const VRLASERPOINTERTRIGGERPROMPT_TEXTLESS_GLOW:int = 1;
      public static const VRLASERPOINTERSTICKPROMPT_NONE:int = 0;
      public static const VRLASERPOINTERSTICKPROMPT_GENERIC_SCROLL:int = 1;
      public static const VRLASERPOINTERSTICKPROMPT_ACTION_LTRT:int = 2;
      private static var ms_menuInputCapabilities:int = 0;
      public var OnLoadMovieDone:Function;
      private var m_loadedMovies:Dictionary;
      public var SetVRLaserPointerDotVisible:Function = null;
      public var SetVRLaserPointerTriggerPrompt:Function = null;
      public var SetVRLaserPointerStickPrompt:Function = null;
      
      public function ControlsMain()
      {
         super();
         ms_instance = this;
         Extensions.enabled = true;
         Extensions.noInvisibleAdvance = true;
         this.m_loadedMovies = new Dictionary();
         this.SetupLogTraceChannels(true,["mouse"]);
      }
      
      public static function isMouseActive() : Boolean
      {
         return ms_isMouseActive;
      }
      
      public static function setOnMouseActiveChangedCallback(param1:Function) : void
      {
         ms_onMouseActiveChanged = param1;
      }
      
      public static function isVrModeActive() : Boolean
      {
         return ms_isVrModeActive;
      }
      
      public static function getControllerType() : String
      {
         return applyForcedControllerType(ms_controllerType);
      }
      
      public static function applyForcedControllerType(param1:String) : String
      {
         var forcedType:String = MenuConstantsKnt.GetForcedControllerPromptType();
         if(forcedType == "")
         {
            return param1;
         }
         switch(param1)
         {
            case CommonUtils.CONTROLLER_TYPE_KEY:
            case CommonUtils.CONTROLLER_TYPE_OPENVR:
            case CommonUtils.CONTROLLER_TYPE_OCULUSVR:
               return param1;
            default:
               return forcedType;
         }
      }
      
      public static function isVRLaserPointerActive() : Boolean
      {
         return ms_isVRLaserPointerActive;
      }
      
      public static function getMenuAcceptCancelLayout() : int
      {
         return ms_menuAcceptCancelLayout;
      }
      
      public static function getActiveLocale() : String
      {
         return ms_activeLocale;
      }
      
      public static function getDisplaySize() : int
      {
         return ms_displaySize;
      }
      
      public static function getMenuInputCapabilities() : int
      {
         return ms_menuInputCapabilities;
      }
      
      public static function isLogChannelEnabled(param1:String) : Boolean
      {
         if(ms_invertEnabledChannels)
         {
            if(!hasTraceChannels())
            {
               return false;
            }
            if(param1.toLowerCase() in ms_enabledChannels)
            {
               return false;
            }
         }
         else if(hasTraceChannels() && !(param1.toLowerCase() in ms_enabledChannels))
         {
            return false;
         }
         return true;
      }
      
      public static function setVRLaserPointerDotVisible(param1:Boolean) : void
      {
         if(ms_instance != null && ms_instance.SetVRLaserPointerDotVisible != null)
         {
            ms_instance.SetVRLaserPointerDotVisible(param1);
         }
      }
      
      public static function showVRLaserPointerDot() : void
      {
         if(ms_instance != null && ms_instance.SetVRLaserPointerDotVisible != null)
         {
            ms_instance.SetVRLaserPointerDotVisible(true);
         }
      }
      
      public static function hideVRLaserPointerDot() : void
      {
         if(ms_instance != null && ms_instance.SetVRLaserPointerDotVisible != null)
         {
            ms_instance.SetVRLaserPointerDotVisible(false);
         }
      }
      
      public static function enableVRLaserPointerDotOnObject(param1:DisplayObject) : void
      {
         param1.addEventListener(MouseEvent.ROLL_OVER,ControlsMain.showVRLaserPointerDot,false,0,false);
         param1.addEventListener(MouseEvent.ROLL_OUT,ControlsMain.hideVRLaserPointerDot,false,0,false);
      }
      
      public static function setVRLaserPointerTriggerPrompt(param1:int) : void
      {
         if(ms_instance != null && ms_instance.SetVRLaserPointerTriggerPrompt != null)
         {
            ms_instance.SetVRLaserPointerTriggerPrompt(param1);
         }
      }
      
      public static function setVRLaserPointerStickPrompt(param1:int) : void
      {
         if(ms_instance != null && ms_instance.SetVRLaserPointerStickPrompt != null)
         {
            ms_instance.SetVRLaserPointerStickPrompt(param1);
         }
      }
      
      private static function hasTraceChannels() : Boolean
      {
         var channel:* = undefined;
         var channels:* = ms_enabledChannels;
         for each(channel in channels)
         {
            return true;
         }
         return false;
      }
      
      public static function getFrameCount() : int
      {
         return ms_frameCount;
      }
      
      public function attachInstance(param1:Sprite, param2:String) : Sprite
      {
         var classRef:Class = getDefinitionByName(param2) as Class;
         var instance:Sprite = new classRef();
         param1.addChild(instance);
         return instance;
      }
      
      public function setInstanceDepth(param1:Sprite, param2:Sprite, param3:uint) : void
      {
         param3 = Math.max(Math.min(param3,param1.numChildren - 1),0);
         if(param3 >= 0)
         {
            param1.setChildIndex(param2,param3);
         }
      }
      
      public function LoadMovie(param1:String, param2:String) : void
      {
         var urlReq:URLRequest;
         var loaderContext:LoaderContext;
         var loader:Loader = null;
         var swf:String = param1;
         var rid:String = param2;
         loader = new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void
         {
            OnLoadMovieDone(rid,loader.content);
         });
         this.m_loadedMovies[swf] = loader;
         addChild(loader);
         urlReq = new URLRequest(swf);
         loaderContext = new LoaderContext(false,ApplicationDomain.currentDomain,null);
         loader.load(urlReq,loaderContext);
      }
      
      public function UnloadMovie(param1:String) : void
      {
         var loader:Loader = this.m_loadedMovies[param1];
         if(loader != null)
         {
            loader.unload();
            removeChild(loader);
            delete this.m_loadedMovies[param1];
         }
      }
      
      public function SetMouseActive(param1:Boolean) : void
      {
         if(ms_isMouseActive == param1)
         {
            return;
         }
         trace("info | Mouse | SetMouseActive: " + param1);
         ms_isMouseActive = param1;
         if(ms_onMouseActiveChanged != null)
         {
            ms_onMouseActiveChanged(ms_isMouseActive);
         }
      }
      
      public function SetVrModeActive(param1:Boolean) : void
      {
         ms_isVrModeActive = param1;
         trace("info | Mouse | SetVrModeActive: " + param1);
      }
      
      public function SetControllerType(param1:String) : void
      {
         ms_controllerType = param1;
      }
      
      public function SetVRLaserPointerActive(param1:Boolean) : void
      {
         ms_isVRLaserPointerActive = param1;
      }
      
      public function SetMenuAcceptCancelLayout(param1:int) : void
      {
         ms_menuAcceptCancelLayout = param1;
      }
      
      public function SetActiveLocale(param1:String) : void
      {
         ms_activeLocale = param1;
         trace("info | Locale | SetActiveLocale: " + param1);
      }
      
      public function SetDisplaySize(param1:int) : void
      {
         if(ms_displaySize == param1)
         {
            return;
         }
         trace("info | SetDisplaySize: " + param1);
         ms_displaySize = param1;
      }
      
      public function SetMenuInputCapabilities(param1:int) : void
      {
         ms_menuInputCapabilities = param1;
      }
      
      public function SetupLogTraceChannels(param1:Boolean, param2:Array) : void
      {
         var channel:String = null;
         trace("setTraceChannels: invert enabled channels: " + param1);
         ms_invertEnabledChannels = param1;
         ms_enabledChannels = new Dictionary();
         for each(channel in param2)
         {
            trace("setTraceChannels: " + (param1 ? "disabled" : "enabled") + " trace channel: " + channel);
            ms_enabledChannels[channel.toLowerCase()] = true;
         }
      }
   }
}
