package knt.hud.notifications
{
   import flash.text.TextFormat;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.Localization;
   import glacier.common.menu.MenuUtils;
   import knt.common.hud.KntHudUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class AgencyUnavailableNotificationWidget extends BaseControl
   {
      
      private static const REASON_NONE:int = 0;
      
      private static const REASON_INSUFFICIENT_AGENCY:int = 1;
      
      private static const REASON_COOLING_DOWN:int = 2;
      
      private static const REASON_WATCHER_NEARBY:int = 3;
      
      private static const REASON_TARGET_TOO_CLOSE:int = 4;
      
      private var m_view:AgencyUnavailableNotificationWidgetView;
      
      private var m_newFormat:TextFormat = new TextFormat();
      
      private var m_warningIsShown:Boolean = false;
      
      public function AgencyUnavailableNotificationWidget()
      {
         super();
         this.m_newFormat.letterSpacing = 3;
         this.m_view = new AgencyUnavailableNotificationWidgetView();
         addChild(this.m_view);
         KntHudUtils.addOutline(this.m_view.icon_mc);
         KntHudUtils.addOutline(this.m_view.title_mc);
         this.m_view.flare_mc.alpha = 0.6;
         this.m_view.visible = false;
      }
      
      public function onSetData(param1:Object) : void
      {
         if(param1.UnavailableReason == REASON_NONE)
         {
            Animate.kill(this.m_view);
            this.m_view.visible = false;
            this.m_view.alpha = 0;
            return;
         }
         if(!MenuConstantsKnt.SHOW_AGENCY_UNAVAILABLE_NOTIFICATION && this.shouldSuppressReason(param1.UnavailableReason))
         {
            Animate.kill(this.m_view);
            this.m_view.visible = false;
            this.m_view.alpha = 0;
            return;
         }
         this.showWarning(this.getReasonString(param1.UnavailableReason));
      }
      
      private function showWarning(param1:String) : void
      {
         var val:String = param1;
         Animate.kill(this.m_view);
         MenuUtils.setupTextUpper(this.m_view.title_mc.title_txt,val,18,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         this.m_view.title_mc.title_txt.autoSize = "center";
         this.m_view.title_mc.title_txt.setTextFormat(this.m_newFormat);
         this.m_view.alpha = 0;
         this.m_view.visible = true;
         Animate.to(this.m_view,0.6,0,{"alpha":1},Animate.ExpoOut,function():void
         {
            Animate.to(m_view,0.6,1,{"alpha":0},Animate.ExpoOut);
         });
      }
      
      private function getReasonString(param1:int) : String
      {
         var _loc2_:String = "";
         switch(param1)
         {
            case REASON_INSUFFICIENT_AGENCY:
               this.m_view.icon_mc.gotoAndStop("unavailable");
               _loc2_ = Localization.get("UI_Agency_InsufficientAgency");
               break;
            case REASON_COOLING_DOWN:
               this.m_view.icon_mc.gotoAndStop("cooldown");
               _loc2_ = Localization.get("UI_Agency_Cooldown");
               break;
            case REASON_WATCHER_NEARBY:
               this.m_view.icon_mc.gotoAndStop("watcher");
               _loc2_ = Localization.get("UI_Interaction_Illegal_WatcherNearby");
               break;
            case REASON_TARGET_TOO_CLOSE:
               this.m_view.icon_mc.gotoAndStop("unavailable");
               _loc2_ = Localization.get("UI_Agency_TooClose");
         }
         return _loc2_;
      }

      private function shouldSuppressReason(param1:int) : Boolean
      {
         return param1 == REASON_INSUFFICIENT_AGENCY || param1 == REASON_COOLING_DOWN;
      }
   }
}
