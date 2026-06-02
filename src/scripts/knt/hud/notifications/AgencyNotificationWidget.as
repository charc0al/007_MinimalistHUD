package knt.hud.notifications
{
   import flash.display.Sprite;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class AgencyNotificationWidget extends BaseControl
   {
      
      public static const ENTRY_HEIGHT:int = 34;
      
      public static const ENTRY_Y_OFFSET:int = 36;
      
      private static const OPEN_ANIM_SPEED:Number = 0.4;
      
      private static const FLASH_ANIM_SPEED:Number = 0.03;
      
      private static const DISPLAY_TIME:Number = 1;
      
      private static const POST_ANIM_SPEED:Number = 0.2;
      
      private static const CLOSE_ANIM_SPEED:Number = 0.4;
      
      public static const PLAYER_RESOURCETYPE_INVALID:uint = 0;
      
      public static const PLAYER_RESOURCETYPE_AMMO:uint = 1;
      
      public static const PLAYER_RESOURCETYPE_ELECTRICAL:uint = 2;
      
      public static const PLAYER_RESOURCETYPE_CHEMICAL:uint = 3;
      
      private var m_previousValue:Number = 0;
      
      private var m_container:Sprite;
      
      private var m_elementCount:int = 0;
      
      private var m_yposArray:Array;
      
      private var m_entriesAvailable:Vector.<AgencyNotificationWidgetView> = new Vector.<AgencyNotificationWidgetView>();
      
      public function AgencyNotificationWidget()
      {
         super();
         this.m_container = new Sprite();
         addChild(this.m_container);
         this.m_yposArray = new Array();
         var _loc1_:uint = 3;
         var _loc2_:Vector.<AgencyNotificationWidgetView> = new Vector.<AgencyNotificationWidgetView>();
         while(_loc2_.length < _loc1_)
         {
            _loc2_.push(this.acquireEntry());
         }
         while(_loc2_.length > 0)
         {
            this.releaseEntry(_loc2_.pop());
         }
      }
      
      public function onSetData(param1:Object) : void
      {
         this.hideAllEntries();
         if(param1 != null && param1.agencyData != null)
         {
            this.m_previousValue = param1.agencyData.currentAgency;
         }
      }
      
      private function ShowNotification(param1:Object) : void
      {
         var _loc2_:AgencyNotificationWidgetView = this.acquireEntry();
         var _loc3_:int = this.m_yposArray[this.m_yposArray.length - 1] + ENTRY_Y_OFFSET;
         this.m_yposArray.push(_loc3_);
         _loc2_.y = _loc3_ - ENTRY_Y_OFFSET;
         var _loc4_:Object = {
            "entry":_loc2_,
            "entryindex":this.m_yposArray.length,
            "gainValue":param1.Amount
         };
         this.startAnimation(_loc4_);
         CommonUtils.playSound(this,"UI_HUD_Resources_InstinctGain");
      }
      
      private function startAnimation(param1:Object) : void
      {
         var notificationEntryData:Object = param1;
         Animate.to(notificationEntryData.entry.bg_mc,OPEN_ANIM_SPEED / 2,0,{
            "width":34,
            "alpha":0.6
         },Animate.Linear,function():void
         {
            notificationEntryData.entry.bg_mc.visible = false;
            notificationEntryData.entry.icon_mc.visible = true;
            Animate.delay(notificationEntryData.entry.icon_mc,FLASH_ANIM_SPEED,function():void
            {
               notificationEntryData.entry.icon_mc.visible = false;
               Animate.delay(notificationEntryData.entry.icon_mc,FLASH_ANIM_SPEED,function():void
               {
                  notificationEntryData.entry.icon_mc.visible = true;
                  Animate.delay(notificationEntryData.entry.icon_mc,FLASH_ANIM_SPEED,function():void
                  {
                     notificationEntryData.entry.icon_mc.visible = false;
                     Animate.delay(notificationEntryData.entry.icon_mc,FLASH_ANIM_SPEED,function():void
                     {
                        notificationEntryData.entry.icon_mc.visible = true;
                        Animate.delay(notificationEntryData.entry.icon_mc,FLASH_ANIM_SPEED,function():void
                        {
                           notificationEntryData.entry.icon_mc.visible = false;
                           Animate.delay(notificationEntryData.entry.icon_mc,FLASH_ANIM_SPEED,function():void
                           {
                              var titleWidth:int;
                              notificationEntryData.entry.bg_mc.visible = true;
                              notificationEntryData.entry.icon_mc.visible = true;
                              notificationEntryData.entry.icon_mc.icon_frame_mc.visible = false;
                              notificationEntryData.entry.icon_mc.icon_pure_mc.visible = true;
                              MenuUtils.setupText(notificationEntryData.entry.title_mc.title_txt,String(notificationEntryData.gainValue),32,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorWhite);
                              titleWidth = int(notificationEntryData.entry.title_mc.title_txt.textWidth);
                              Animate.to(notificationEntryData.entry.bg_mc,OPEN_ANIM_SPEED,0,{
                                 "x":titleWidth / 2 - 15,
                                 "width":90 + titleWidth
                              },Animate.ExpoOut);
                              Animate.to(notificationEntryData.entry.icon_mc,OPEN_ANIM_SPEED,0,{"x":-34},Animate.ExpoOut);
                              notificationEntryData.entry.title_mc.alpha = 0;
                              notificationEntryData.entry.title_mc.visible = true;
                              Animate.to(notificationEntryData.entry.title_mc,OPEN_ANIM_SPEED,0,{
                                 "x":1,
                                 "alpha":1
                              },Animate.ExpoOut);
                              Animate.delay(notificationEntryData.entry,DISPLAY_TIME,function():void
                              {
                                 endAnimation(notificationEntryData);
                              });
                           });
                        });
                     });
                  });
               });
            });
         });
         if(this.m_yposArray.length >= 2)
         {
            Animate.offset(this.m_container,0.2,0,{"y":-ENTRY_Y_OFFSET},Animate.ExpoOut);
         }
      }
      
      private function endAnimation(param1:Object) : void
      {
         param1.entry.reticle_mc.visible = true;
         Animate.to(param1.entry.reticle_mc,CLOSE_ANIM_SPEED,0,{
            "width":300,
            "alpha":0
         },Animate.ExpoOut);
         Animate.to(param1.entry.bg_mc,CLOSE_ANIM_SPEED,0,{
            "width":34,
            "alpha":0
         },Animate.ExpoOut);
         Animate.to(param1.entry.icon_mc,CLOSE_ANIM_SPEED,0,{
            "x":0,
            "alpha":0
         },Animate.ExpoOut);
         Animate.to(param1.entry.title_mc,CLOSE_ANIM_SPEED,0,{
            "x":-16,
            "alpha":0
         },Animate.ExpoOut,this.finishAnimation,param1.entry);
      }
      
      private function finishAnimation(param1:AgencyNotificationWidgetView) : void
      {
         Animate.kill(param1);
         this.m_yposArray.shift();
         if(this.m_yposArray.length == 0)
         {
            this.m_container.y = 0;
         }
         this.releaseEntry(param1);
      }
      
      private function acquireEntry() : AgencyNotificationWidgetView
      {
         var _loc1_:AgencyNotificationWidgetView = null;
         if(this.m_entriesAvailable.length > 0)
         {
            _loc1_ = this.m_entriesAvailable.pop();
         }
         else
         {
            _loc1_ = new AgencyNotificationWidgetView();
            this.m_container.addChild(_loc1_);
         }
         MenuUtils.setColor(_loc1_.icon_mc,MenuConstantsKnt.COLOR_AGENCY,false);
         _loc1_.icon_mc.icon_frame_mc.visible = true;
         _loc1_.icon_mc.icon_pure_mc.visible = false;
         _loc1_.icon_mc.x = 0;
         _loc1_.icon_mc.alpha = 1;
         _loc1_.icon_mc.visible = false;
         MenuUtils.setupTextUpper(_loc1_.title_mc.title_txt,String(0),32,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorWhite);
         _loc1_.title_mc.x = -16;
         _loc1_.title_mc.visible = false;
         _loc1_.reticle_mc.width = 135;
         _loc1_.reticle_mc.alpha = 0.4;
         _loc1_.reticle_mc.visible = false;
         _loc1_.bg_mc.width = 10;
         _loc1_.bg_mc.alpha = 0;
         _loc1_.bg_mc.visible = true;
         _loc1_.visible = true;
         return _loc1_;
      }
      
      private function releaseEntry(param1:AgencyNotificationWidgetView) : void
      {
         param1.visible = false;
         this.m_entriesAvailable.push(param1);
      }
      
      private function addLeadingZero(param1:Number) : String
      {
         return param1 < 10 ? "0" + param1 : param1.toString();
      }
      
      private function hideAllEntries() : void
      {
         var _loc1_:int = 0;
         this.m_yposArray.length = 0;
         this.m_container.y = 0;
         Animate.kill(this.m_container);
         _loc1_ = 0;
         while(_loc1_ < this.m_container.numChildren)
         {
            Animate.kill(this.m_container.getChildAt(_loc1_));
            this.m_container.getChildAt(_loc1_).visible = false;
            _loc1_++;
         }
      }
      
      public function testGainAgency() : void
      {
         var _loc1_:Array = new Array(0.5,1,1.55,2,0.2555,2.5,4);
         var _loc2_:int = MenuUtils.getRandomInRange(0,_loc1_.length - 1,true);
         var _loc3_:Number = Number(_loc1_[_loc2_]);
         this.m_previousValue = 0;
         this.onSetData({"agencyData":{
            "currentAgency":_loc3_,
            "maximumAgency":6
         }});
      }
   }
}
