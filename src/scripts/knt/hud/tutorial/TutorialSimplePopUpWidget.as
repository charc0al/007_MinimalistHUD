package knt.hud.tutorial
{
   import flash.display.Sprite;
   import flash.text.TextFormat;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.Localization;
   import glacier.common.Log;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class TutorialSimplePopUpWidget extends BaseControl
   {
      
      private static const OPEN_ANIM_SPEED:Number = 0.4;
      
      private static const FLASH_ANIM_SPEED:Number = 0.03;
      
      private static const POST_ANIM_SPEED:Number = 0.2;
      
      private static const CLOSE_ANIM_SPEED:Number = 0.4;
      
      private static const DISPLAY_TIME:Number = 4;
      
      public static const ENTRY_Y_OFFSET:int = 36 * 2;
      
      private var m_container:Sprite;
      
      private var m_elementCount:int = 0;
      
      private var m_yposArray:Array;
      
      private var m_entriesAvailable:Vector.<TutorialSimplePopUpWidgetView> = new Vector.<TutorialSimplePopUpWidgetView>();
      
      private var m_newFormat:TextFormat = new TextFormat();
      
      public function TutorialSimplePopUpWidget()
      {
         super();
         this.m_newFormat.letterSpacing = 2;
         this.m_container = new Sprite();
         addChild(this.m_container);
         this.m_yposArray = new Array();
         var _loc1_:uint = 3;
         var _loc2_:Vector.<TutorialSimplePopUpWidgetView> = new Vector.<TutorialSimplePopUpWidgetView>();
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
         Log.debugData(this,param1);
         if(param1 == null)
         {
            return;
         }
         if(Boolean(param1.title) && param1.title != "")
         {
            this.ShowNotification(param1.title,MenuConstantsKnt.COLOR_WHITE);
         }
      }
      
      private function ShowNotification(param1:String, param2:int) : void
      {
         var _loc3_:TutorialSimplePopUpWidgetView = this.acquireEntry(param1,param2);
         var _loc4_:int = this.m_yposArray[this.m_yposArray.length - 1] + ENTRY_Y_OFFSET;
         this.m_yposArray.push(_loc4_);
         _loc3_.y = _loc4_ - ENTRY_Y_OFFSET;
         var _loc5_:Object = {
            "entry":_loc3_,
            "entryindex":this.m_yposArray.length,
            "title":param1,
            "dangerColor":param2
         };
         this.startAnimation(_loc5_);
      }
      
      private function startAnimation(param1:Object) : void
      {
         var bgWidth:int;
         var notificationEntryData:Object = param1;
         notificationEntryData.entry.notification_mc.visible = true;
         bgWidth = Math.max(700,MenuUtils.roundDecimal(notificationEntryData.entry.notification_mc.title_mc.title_txt.textWidth + 120,0));
         Animate.to(notificationEntryData.entry.notification_mc.bg_mc,OPEN_ANIM_SPEED,0,{
            "width":bgWidth,
            "alpha":0.6
         },Animate.Linear,function():void
         {
            notificationEntryData.entry.reticle_mc.alpha = 0;
            MenuUtils.setColor(notificationEntryData.entry.notification_mc.bg_mc,notificationEntryData.dangerColor,false);
            Animate.delay(notificationEntryData.entry.notification_mc.bg_mc,FLASH_ANIM_SPEED,function():void
            {
               notificationEntryData.entry.notification_mc.bg_mc.alpha = 0;
               Animate.delay(notificationEntryData.entry.notification_mc.bg_mc,FLASH_ANIM_SPEED,function():void
               {
                  notificationEntryData.entry.notification_mc.bg_mc.alpha = 0.6;
                  Animate.delay(notificationEntryData.entry.notification_mc.bg_mc,FLASH_ANIM_SPEED,function():void
                  {
                     notificationEntryData.entry.notification_mc.bg_mc.alpha = 0;
                     Animate.delay(notificationEntryData.entry.notification_mc.bg_mc,FLASH_ANIM_SPEED,function():void
                     {
                        notificationEntryData.entry.notification_mc.bg_mc.alpha = 0.6;
                        Animate.delay(notificationEntryData.entry.notification_mc.bg_mc,FLASH_ANIM_SPEED,function():void
                        {
                           notificationEntryData.entry.notification_mc.bg_mc.alpha = 0;
                           Animate.delay(notificationEntryData.entry.notification_mc.bg_mc,FLASH_ANIM_SPEED,function():void
                           {
                              MenuUtils.removeColor(notificationEntryData.entry.notification_mc.bg_mc,true);
                              notificationEntryData.entry.notification_mc.bg_mc.alpha = 0.6;
                              notificationEntryData.entry.notification_mc.title_mc.alpha = 1;
                              notificationEntryData.entry.notification_mc.icon_mc.alpha = 1;
                              Animate.delay(notificationEntryData.entry,DISPLAY_TIME,function():void
                              {
                                 killAllAnimations(notificationEntryData.entry);
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
         var notificationEntryData:Object = param1;
         notificationEntryData.entry.notification_mc.title_mc.alpha = 0;
         notificationEntryData.entry.notification_mc.icon_mc.alpha = 0;
         Animate.to(notificationEntryData.entry.notification_mc.bg_mc,CLOSE_ANIM_SPEED,0,{
            "width":58,
            "alpha":0
         },Animate.QuartOut,function():void
         {
            notificationEntryData.entry.notification_mc.visible = false;
            finishAnimation(notificationEntryData.entry);
         });
      }
      
      private function finishAnimation(param1:TutorialSimplePopUpWidgetView) : void
      {
         Animate.kill(param1);
         this.m_yposArray.shift();
         if(this.m_yposArray.length == 0)
         {
            this.m_container.y = 0;
         }
         this.releaseEntry(param1);
      }
      
      private function acquireEntry(param1:String = "", param2:int = 0) : TutorialSimplePopUpWidgetView
      {
         var _loc3_:TutorialSimplePopUpWidgetView = null;
         if(this.m_entriesAvailable.length > 0)
         {
            _loc3_ = this.m_entriesAvailable.pop();
         }
         else
         {
            _loc3_ = new TutorialSimplePopUpWidgetView();
            this.m_container.addChild(_loc3_);
         }
         _loc3_.reticle_mc.gotoAndStop(1);
         _loc3_.notification_mc.visible = false;
         _loc3_.notification_mc.title_mc.alpha = 0;
         _loc3_.notification_mc.icon_mc.alpha = 0;
         _loc3_.notification_mc.bg_mc.alpha = 0;
         _loc3_.notification_mc.bg_mc.width = 58;
         MenuUtils.setupText(_loc3_.notification_mc.title_mc.title_txt,param1,28,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         _loc3_.notification_mc.title_mc.title_txt.autoSize = "center";
         _loc3_.notification_mc.title_mc.title_txt.setTextFormat(this.m_newFormat);
         _loc3_.notification_mc.title_mc.x = 13;
         _loc3_.notification_mc.icon_mc.x = _loc3_.notification_mc.title_mc.title_txt.textWidth / -2 - 22;
         MenuUtils.setColor(_loc3_.notification_mc.icon_mc,MenuConstantsKnt.COLOR_GREY_MEDIUM,false);
         _loc3_.visible = true;
         return _loc3_;
      }
      
      private function releaseEntry(param1:TutorialSimplePopUpWidgetView) : void
      {
         param1.visible = false;
         this.m_entriesAvailable.push(param1);
      }
      
      private function killAllAnimations(param1:TutorialSimplePopUpWidgetView) : void
      {
         Animate.kill(param1.reticle_mc);
         Animate.kill(param1.notification_mc.bg_mc);
      }
      
      public function testPopUp() : void
      {
         this.onSetData({"title":Localization.get("UI_TutorialText_Bluff_Description1")});
      }
   }
}

