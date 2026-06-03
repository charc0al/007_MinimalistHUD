package knt.hud.objectives
{
   import flash.display.BlendMode;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.ImageLoader;
   import glacier.common.Localization;
   import glacier.common.Log;
   import glacier.common.menu.MenuUtils;
   import knt.common.hud.KntHudUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class ObjectivesNotificationItemWidget extends BaseControl
   {
      private static const NOTIFICATION_SCALE:Number = 0.5;
      
      private var m_imageLoader:ImageLoader;
      
      private var m_view:ObjectivesNotificationItemWidgetView;
      
      private var m_totalDuration:Number = 0;
      
      private var m_remainingDuration:Number;
      
      private var m_notificationType:String;
      
      private var m_soundTrigger:String;
      
      private var m_useTotalDuration:Boolean = false;
      
      private var m_xpos_title:Number;
      
      private var m_xpos_headline:Number;
      
      private const NOTIFICATION_HEIGHT:Number = 96;
      
      private var m_maskImage:Boolean = false;
      
      public function ObjectivesNotificationItemWidget()
      {
         super();
         this.m_view = new ObjectivesNotificationItemWidgetView();
         this.m_view.y = -this.NOTIFICATION_HEIGHT / 2;
         this.m_view.scaleX = this.m_view.scaleY = NOTIFICATION_SCALE;
         addChild(this.m_view);
         this.m_view.visible = false;
         KntHudUtils.appendOutline(this.m_view.headline_txt);
         KntHudUtils.appendOutline(this.m_view.title_txt);
         KntHudUtils.addOutline(this.m_view.track_txt,MenuConstantsKnt.COLOR_BLACK,0.32);
         this.m_view.flame_mc.stop();
         MenuUtils.setColor(this.m_view.flame_mc,15964708);
         this.m_xpos_headline = this.m_view.headline_txt.x;
         this.m_xpos_title = this.m_view.title_txt.x;
         this.m_view.track_txt.visible = false;
      }
      
      public function onSetData(param1:Object) : void
      {
         this.hideNotification();
         if(param1 == null)
         {
            return;
         }
         if(!param1.IsValid)
         {
            return;
         }
         if(param1.NotificationType != ObjectivesData.TYPE_ITEM && param1.NotificationType != ObjectivesData.TYPE_CHALLENGE && param1.NotificationType != ObjectivesData.TYPE_CHALLENGEMOSAIC && param1.NotificationType != ObjectivesData.TYPE_COLLECTIBLE && param1.NotificationType != ObjectivesData.TYPE_TUTORIAL)
         {
            return;
         }
         return;
      }
      
      private function animateOpeningSequence() : void
      {
         Animate.delay(this.m_view,0.2,function():void
         {
            var maxTextWidth:Number;
            m_view.visible = true;
            CommonUtils.playSound(this,m_soundTrigger);
            m_view.title_txt.x = m_xpos_title + 16;
            m_view.title_txt.alpha = 0;
            Animate.to(m_view.title_txt,0.23,0.14,{
               "x":m_xpos_title,
               "alpha":1
            },Animate.QuadOut,function():void
            {
               m_view.title_txt.alpha = 0;
               Animate.delay(m_view.title_txt,0.13,function():void
               {
                  m_view.title_txt.alpha = 1;
                  Animate.delay(m_view.title_txt,0.03,function():void
                  {
                     m_view.title_txt.alpha = 0;
                     Animate.delay(m_view.title_txt,0.08,function():void
                     {
                        m_view.title_txt.alpha = 0.75;
                        Animate.to(m_view.title_txt,0.01,0.01,{"alpha":1},Animate.Linear);
                     });
                  });
               });
            });
            m_view.headline_txt.x = m_xpos_headline + 16;
            m_view.headline_txt.alpha = 0;
            Animate.to(m_view.headline_txt,0.23,0.08,{
               "x":m_xpos_headline,
               "alpha":1
            },Animate.QuadOut,function():void
            {
               m_view.headline_txt.alpha = 0;
               Animate.delay(m_view.headline_txt,0.13,function():void
               {
                  m_view.headline_txt.alpha = 1;
                  Animate.delay(m_view.headline_txt,0.03,function():void
                  {
                     m_view.headline_txt.alpha = 0;
                     Animate.delay(m_view.headline_txt,0.08,function():void
                     {
                        m_view.headline_txt.alpha = 0.75;
                        Animate.to(m_view.headline_txt,0.01,0.01,{"alpha":1},Animate.Linear);
                     });
                  });
               });
            });
            if(m_view.track_txt.visible)
            {
               Animate.to(m_view.track_txt,0.3,0.4,{"alpha":1},Animate.QuadOut);
            }
            maxTextWidth = Math.max(m_view.title_txt.textWidth,m_view.headline_txt.textWidth);
            m_view.lines_mc.width = maxTextWidth + 150;
            m_view.lines_mc.alpha = 0;
            m_view.darkBack_mc.width = 40;
            m_view.darkBack_mc.alpha = 0;
            Animate.to(m_view.darkBack_mc,0.65,0,{
               "width":maxTextWidth + 300,
               "alpha":1
            },Animate.QuadOut);
            Animate.to(m_view.lines_mc,0.65,0,{"alpha":0.16},Animate.QuadOut);
            m_view.flame_mc.scaleX = 0.75;
            m_view.flame_mc.scaleY = 1.3;
            m_view.flame_mc.alpha = 0;
            m_view.flame_mc.gotoAndPlay(Math.abs(Math.random() * m_view.flame_mc.totalFrames));
            Animate.to(m_view.flame_mc,0.5,0,{
               "scaleX":1,
               "scaleY":1,
               "alpha":1
            },Animate.QuadInOut);
            m_view.imageHolder_mc.alpha = 0;
            Animate.to(m_view.imageHolder_mc,0.4,0.2,{"alpha":1},Animate.QuadOut);
            m_view.visible = true;
            if(m_useTotalDuration == true)
            {
               animateClosingSequence();
            }
         });
      }
      
      private function animateClosingSequence() : void
      {
         Animate.delay(this.m_view,this.m_useTotalDuration ? this.m_totalDuration - 1 : 0,function():void
         {
            Animate.to(m_view.flame_mc,0.5,0,{"alpha":0},Animate.QuadIn);
            Animate.to(m_view.title_txt,0.6,0.2,{
               "x":m_xpos_title + 16,
               "alpha":0
            },Animate.QuadIn);
            Animate.to(m_view.headline_txt,0.6,0,{
               "x":m_xpos_headline + 16,
               "alpha":0
            },Animate.QuadIn);
            Animate.to(m_view.darkBack_mc,0.66,0,{
               "width":60,
               "alpha":0
            },Animate.QuadIn);
            Animate.to(m_view.lines_mc,0.66,0,{"alpha":0},Animate.QuadIn);
            Animate.to(m_view.imageHolder_mc,0.3,0,{"alpha":0},Animate.QuadIn);
            Animate.to(m_view.track_txt,0.4,0.1,{"alpha":0},Animate.QuadIn);
            Animate.delay(m_view,1,function():void
            {
               m_view.visible = false;
               killAllAnimations();
               killImageLoader();
            });
         });
      }
      
      private function loadImage(param1:String) : void
      {
         while(this.m_view.imageHolder_mc.numChildren > 0)
         {
            this.m_view.imageHolder_mc.removeChildAt(0);
         }
         this.m_imageLoader = new ImageLoader();
         this.m_view.imageHolder_mc.addChild(this.m_imageLoader);
         this.m_imageLoader.scaleX = this.m_imageLoader.scaleY = 1;
         this.m_imageLoader.loadImage(param1,this.onSuccessImage,this.onFailedImage);
         this.animateOpeningSequence();
      }
      
      private function onSuccessImage() : void
      {
         var _loc1_:ObjectivesNotificationItem_ImageMaskView = null;
         if(this.m_maskImage)
         {
            this.m_imageLoader.height = this.NOTIFICATION_HEIGHT;
            this.m_imageLoader.scaleX = this.m_imageLoader.scaleY;
            this.m_imageLoader.x = -this.m_imageLoader.width;
            _loc1_ = new ObjectivesNotificationItem_ImageMaskView();
            this.m_view.imageHolder_mc.addChild(_loc1_);
            _loc1_.width = Math.max(185,this.m_imageLoader.width);
            _loc1_.height = this.NOTIFICATION_HEIGHT;
            _loc1_.x = Math.min(-185 - this.m_view.imageHolder_mc.x,this.m_imageLoader.x);
            _loc1_.y = this.m_imageLoader.y;
            this.m_view.imageHolder_mc.blendMode = BlendMode.LAYER;
            _loc1_.blendMode = BlendMode.ALPHA;
         }
         else
         {
            this.m_imageLoader.height = this.NOTIFICATION_HEIGHT;
            this.m_imageLoader.scaleX = this.m_imageLoader.scaleY;
            this.m_imageLoader.x = -this.m_imageLoader.width;
            this.m_view.imageHolder_mc.blendMode = BlendMode.NORMAL;
         }
      }
      
      private function onFailedImage() : void
      {
         Log.info(Log.ChannelDebug,this,"ObjectivesNotificationItemWidget | " + this.m_view.title_txt.text + " | FAILED to Load image");
      }
      
      private function killAllAnimations() : void
      {
         Animate.kill(this.m_view);
         Animate.kill(this.m_view.title_txt);
         Animate.kill(this.m_view.headline_txt);
         Animate.kill(this.m_view.imageHolder_mc);
         Animate.kill(this.m_view.darkBack_mc);
         Animate.kill(this.m_view.lines_mc);
         Animate.kill(this.m_view.flame_mc);
         Animate.kill(this.m_view.track_txt);
         this.m_view.flame_mc.stop();
      }
      
      private function killImageLoader() : void
      {
         if(this.m_imageLoader != null)
         {
            this.m_imageLoader.cancel();
            this.m_view.imageHolder_mc.removeChild(this.m_imageLoader);
            this.m_imageLoader = null;
         }
      }
      
      private function hideNotification() : void
      {
         this.killAllAnimations();
         this.killImageLoader();
         this.m_soundTrigger = "";
         this.m_totalDuration = 0;
         this.m_remainingDuration = 0;
         this.m_useTotalDuration = false;
         this.m_notificationType = null;
         this.m_maskImage = false;
         this.m_view.track_txt.visible = false;
         this.m_view.imageHolder_mc.alpha = 0;
         this.m_view.visible = false;
         this.visible = false;
      }
      
      override public function onControlLayoutChanged() : void
      {
         MenuUtils.setupText(this.m_view.track_txt,Localization.get("UI_SystemReminder_TipMoreInfoShortcut"),21,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
      }
   }
}
