package knt.hud.notifications
{
   import flash.display.Sprite;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class PickupNotificationWidget extends BaseControl
   {
      
      public static const ENTRY_HEIGHT:int = 56;
      
      public static const ENTRY_Y_OFFSET:int = 56;
      
      private static const OPEN_ANIM_SPEED:Number = 0.4;
      
      private static const FLASH_ANIM_SPEED:Number = 0.03;
      
      private static const DISPLAY_TIME:Number = 1;
      
      private static const POST_ANIM_SPEED:Number = 0.2;
      
      private static const CLOSE_ANIM_SPEED:Number = 0.4;
      
      public static const PLAYER_RESOURCETYPE_INVALID:uint = 0;
      
      public static const PLAYER_RESOURCETYPE_AMMO:uint = 1;
      
      public static const PLAYER_RESOURCETYPE_ELECTRICAL:uint = 2;
      
      public static const PLAYER_RESOURCETYPE_CHEMICAL:uint = 3;
      
      private var m_container:Sprite;
      
      private var m_elementCount:int = 0;
      
      private var m_yposArray:Array;
      
      private var m_entriesAvailable:Vector.<PickupNotificationWidgetView> = new Vector.<PickupNotificationWidgetView>();
      
      public function PickupNotificationWidget()
      {
         super();
         this.m_container = new Sprite();
         addChild(this.m_container);
         this.m_yposArray = new Array();
         var _loc1_:uint = 3;
         var _loc2_:Vector.<PickupNotificationWidgetView> = new Vector.<PickupNotificationWidgetView>();
         while(_loc2_.length < _loc1_)
         {
            _loc2_.push(this.acquireEntry(0));
         }
         while(_loc2_.length > 0)
         {
            this.releaseEntry(_loc2_.pop());
         }
         this.hideAllNotifications();
      }
      
      public function onSetData(param1:Object) : void
      {
         this.hideAllNotifications();
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         this.hideAllNotifications();
      }
      
      private function ShowNotification(param1:Object) : void
      {
         var _loc2_:PickupNotificationWidgetView = this.acquireEntry(param1.Type);
         var _loc3_:int = this.m_yposArray[this.m_yposArray.length - 1] - ENTRY_Y_OFFSET;
         this.m_yposArray.push(_loc3_);
         _loc2_.y = _loc3_ - ENTRY_Y_OFFSET;
         var _loc4_:Object = {
            "entry":_loc2_,
            "entryindex":this.m_yposArray.length,
            "entryIcon":_loc2_.container_mc.getChildAt(0),
            "gainValue":param1.Amount
         };
         this.startAnimation(_loc4_);
      }
      
      private function hideAllNotifications() : void
      {
         var _loc1_:int = 0;
         this.visible = false;
         this.alpha = 0;
         Animate.kill(this.m_container);
         this.m_container.visible = false;
         this.m_container.alpha = 0;
         this.m_container.y = 0;
         _loc1_ = 0;
         while(_loc1_ < this.m_container.numChildren)
         {
            Animate.kill(this.m_container.getChildAt(_loc1_));
            PickupNotificationWidgetView(this.m_container.getChildAt(_loc1_)).visible = false;
            PickupNotificationWidgetView(this.m_container.getChildAt(_loc1_)).alpha = 0;
            PickupNotificationWidgetView(this.m_container.getChildAt(_loc1_)).container_mc.visible = false;
            Animate.kill(PickupNotificationWidgetView(this.m_container.getChildAt(_loc1_)).container_mc);
            Animate.kill(PickupNotificationWidgetView(this.m_container.getChildAt(_loc1_)).title_txt);
            _loc1_++;
         }
         this.m_yposArray = [];
         this.m_elementCount = 0;
      }
      
      private function startAnimation(param1:Object) : void
      {
         var notificationEntryData:Object = param1;
         Animate.to(notificationEntryData.entry,OPEN_ANIM_SPEED / 2,0,{"alpha":1},Animate.Linear,function():void
         {
            notificationEntryData.entry.container_mc.visible = true;
            Animate.delay(notificationEntryData.entry.container_mc,FLASH_ANIM_SPEED,function():void
            {
               notificationEntryData.entry.container_mc.visible = false;
               Animate.delay(notificationEntryData.entry.container_mc,FLASH_ANIM_SPEED,function():void
               {
                  notificationEntryData.entry.container_mc.visible = true;
                  Animate.delay(notificationEntryData.entry.container_mc,FLASH_ANIM_SPEED,function():void
                  {
                     notificationEntryData.entry.container_mc.visible = false;
                     Animate.delay(notificationEntryData.entry.container_mc,FLASH_ANIM_SPEED,function():void
                     {
                        notificationEntryData.entry.container_mc.visible = true;
                        Animate.delay(notificationEntryData.entry.container_mc,FLASH_ANIM_SPEED,function():void
                        {
                           notificationEntryData.entry.container_mc.visible = false;
                           Animate.delay(notificationEntryData.entry.container_mc,FLASH_ANIM_SPEED,function():void
                           {
                              var baseGainString:String;
                              var currentGainString:String;
                              notificationEntryData.entry.container_mc.visible = true;
                              baseGainString = String(0);
                              currentGainString = String(notificationEntryData.gainValue);
                              if(notificationEntryData.gainValue > 0)
                              {
                                 Animate.addFromToExtended(notificationEntryData.entry.title_txt,OPEN_ANIM_SPEED,0,{"intAnimation":String(0)},{"intAnimation":String(notificationEntryData.gainValue)},Animate.Linear,"+ ","",2,function():void
                                 {
                                    MenuUtils.setupText(notificationEntryData.entry.title_txt,"+ ",24,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorGrey);
                                    MenuUtils.setupText(notificationEntryData.entry.title_txt,addLeadingZero(notificationEntryData.gainValue),24,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorWhite,true);
                                 });
                              }
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
            Animate.offset(this.m_container,0.2,0,{"y":ENTRY_Y_OFFSET},Animate.ExpoOut);
         }
      }
      
      private function endAnimation(param1:Object) : void
      {
         Animate.to(param1.entry,CLOSE_ANIM_SPEED,0,{"alpha":0},Animate.ExpoOut,this.finishAnimation,param1.entry);
      }
      
      private function finishAnimation(param1:PickupNotificationWidgetView) : void
      {
         Animate.kill(param1);
         this.m_yposArray.shift();
         if(this.m_yposArray.length == 0)
         {
            this.m_container.y = 0;
         }
         this.releaseEntry(param1);
      }
      
      private function acquireEntry(param1:uint) : PickupNotificationWidgetView
      {
         var _loc2_:PickupNotificationWidgetView = null;
         var _loc3_:* = undefined;
         if(this.m_entriesAvailable.length > 0)
         {
            _loc2_ = this.m_entriesAvailable.pop();
            while(_loc2_.container_mc.numChildren > 0)
            {
               _loc2_.container_mc.removeChildAt(0);
            }
         }
         else
         {
            _loc2_ = new PickupNotificationWidgetView();
            this.m_container.addChild(_loc2_);
         }
         switch(param1)
         {
            case PLAYER_RESOURCETYPE_AMMO:
               _loc3_ = new PickupNotificationAmmoIconView();
               MenuUtils.setColor(_loc3_,MenuConstantsKnt.COLOR_HUD_RESOURCE_AMMO);
               break;
            case PLAYER_RESOURCETYPE_CHEMICAL:
               _loc3_ = new PickupNotificationChemicalIconView();
               MenuUtils.setColor(_loc3_,MenuConstantsKnt.COLOR_HUD_RESOURCE_CHEMICAL);
               break;
            case PLAYER_RESOURCETYPE_ELECTRICAL:
               _loc3_ = new PickupNotificationElectricalIconView();
               MenuUtils.setColor(_loc3_,MenuConstantsKnt.COLOR_HUD_RESOURCE_ELECTRICAL);
               break;
            default:
               _loc3_ = new PickupNotificationUnknownIconView();
               MenuUtils.setColor(_loc3_,MenuConstantsKnt.COLOR_RED);
         }
         CommonUtils.playSound(this,"UI_HUD_Resource_Gain");
         _loc2_.container_mc.addChild(_loc3_);
         MenuUtils.setupTextUpper(_loc2_.title_txt,this.addLeadingZero(0),24,MenuConstantsKnt.FONT_TYPE_NUMBERS,MenuConstantsKnt.FontColorWhite);
         _loc2_.alpha = 0;
         _loc2_.visible = true;
         return _loc2_;
      }
      
      private function releaseEntry(param1:PickupNotificationWidgetView) : void
      {
         param1.visible = false;
         this.m_entriesAvailable.push(param1);
      }
      
      private function addLeadingZero(param1:Number) : String
      {
         return param1 < 10 ? "0" + param1 : param1.toString();
      }
      
      public function testPickup() : void
      {
         var _loc1_:int = MenuUtils.getRandomInRange(1,5,true);
         var _loc2_:int = MenuUtils.getRandomInRange(1,3,true);
         if(_loc2_ == 1)
         {
            this.onSetData({
               "Ammo":{"Amount":_loc1_},
               "Resource":{
                  "Type":0,
                  "Amount":0
               }
            });
            return;
         }
         this.onSetData({
            "Ammo":{"Amount":0},
            "Resource":{
               "Type":_loc2_,
               "Amount":_loc1_
            }
         });
      }
   }
}

