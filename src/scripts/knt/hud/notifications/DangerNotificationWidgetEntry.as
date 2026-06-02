package knt.hud.notifications
{
   import flash.filters.BitmapFilterQuality;
   import flash.filters.BlurFilter;
   import flash.text.TextFormat;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class DangerNotificationWidgetEntry extends BaseControl
   {
      
      private static const OPEN_ANIM_SPEED:Number = 0.6;
      
      private static const FLASH_ANIM_SPEED:Number = 0.03;
      
      private static const ICON_PULSE_SPEED:Number = 0.4;
      
      private static const CLOSE_ANIM_SPEED:Number = 0.2;
      
      private static const RETICLE_Y_OFFSET:int = 0;
      
      private static const POST_WIDTH_HEIGHT:int = 54;
      
      private var m_lethalForceEnabled:Boolean = false;
      
      private var m_trespassing:Boolean = false;
      
      private var m_softTrespassing:Boolean = false;
      
      private var m_view:DangerNotificationWidgetEntryView;
      
      private var m_flare:DangerNotificationWidgetFlares;
      
      private var m_newFormat:TextFormat = new TextFormat();
      
      private var m_ignoreDangerStates:Boolean = false;
      
      private var m_dataCloned:Object;
      
      private var m_parentClassInstance:DangerNotificationWidget;
      
      private var m_name:String = "";
      
      public function DangerNotificationWidgetEntry()
      {
         super();
         this.m_newFormat.letterSpacing = 3;
         this.m_view = new DangerNotificationWidgetEntryView();
         addChild(this.m_view);
         this.m_flare = new DangerNotificationWidgetFlares();
         this.m_view.flares_container_mc.addChild(this.m_flare);
         this.m_view.bg_mc.alpha = 0;
         this.initializeForOpeningSequence();
      }
      
      public function onSetData(param1:Object) : void
      {
         this.m_name = param1.title;
         this.m_flare.setType(param1.type);
         MenuUtils.setupText(this.m_view.title_mc.title_txt,param1.title,32,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         this.m_view.title_mc.title_txt.autoSize = "center";
         this.m_view.title_mc.title_txt.setTextFormat(this.m_newFormat);
         MenuUtils.setColor(this.m_view.pattern_mc,param1.dangerColor,false);
      }
      
      public function animateOpeningSequence(param1:Boolean, param2:String, param3:Boolean) : void
      {
         var waitDelay:Number;
         var autoHide:Boolean = param1;
         var soundId:String = param2;
         var waitForOtherEntryToHide:Boolean = param3;
         this.initializeForOpeningSequence();
         this.m_flare.initializeForOpeningSequence();
         waitDelay = waitForOtherEntryToHide ? 0.4 : 0;
         Animate.delay(this,waitDelay,function():void
         {
            CommonUtils.playSound(this,soundId);
            m_flare.animateOpeningSequence();
            Animate.to(m_view.bg_mc,1,0,{"alpha":0.8},Animate.Linear);
            Animate.fromTo(m_view.icon_mc,0.5,0.4,{"frames":0},{"frames":19},Animate.Linear);
            Animate.fromTo(m_view.lines_reveal_mc,1,0,{"frames":0},{"frames":30},Animate.Linear);
            Animate.fromTo(m_view.txt_lines_reveal_mc.line_L_mc,1,0,{"frames":0},{"frames":20},Animate.Linear);
            Animate.fromTo(m_view.txt_lines_reveal_mc.line_R_mc,1,0,{"frames":0},{"frames":20},Animate.Linear);
            Animate.to(m_view.pattern_mc,0.8,0,{
               "alpha":1,
               "y":0
            },Animate.Linear);
            loopPatternMc(true);
            Animate.to(m_view.title_mc,0.1,0.4,{"alpha":0.6},Animate.Linear,function():void
            {
               Animate.delay(m_view.title_mc,0.1,function():void
               {
                  m_view.title_mc.filters = [];
                  m_view.title_mc.alpha = 0;
                  Animate.delay(m_view.title_mc,0.1,function():void
                  {
                     m_view.title_mc.alpha = 1;
                     Animate.delay(m_view.title_mc,0.1,function():void
                     {
                        m_view.title_mc.alpha = 0;
                        Animate.delay(m_view.title_mc,0.1,function():void
                        {
                           m_view.title_mc.alpha = 0.6;
                           Animate.to(m_view.title_mc,0.1,0,{"alpha":1},Animate.Linear);
                        });
                     });
                  });
               });
            });
            Animate.delay(this,4,function():void
            {
               animateOpeningToMinimizedSequence(autoHide);
            });
         });
      }
      
      private function animateOpeningToMinimizedSequence(param1:Boolean) : void
      {
         var autoHide:Boolean = param1;
         this.m_flare.animateOpeningToMinimizedSequence();
         Animate.to(this.m_view.bg_mc,0.6,0,{
            "alpha":0.6,
            "scaleX":0.8,
            "scaleY":0.8
         },Animate.Linear);
         Animate.to(this.m_view.icon_mc,0.6,0,{
            "alpha":0,
            "y":0
         },Animate.ExpoIn);
         Animate.to(this.m_view.pattern_mc,0.6,0,{"y":-56},Animate.Linear);
         Animate.to(this.m_view.title_mc,0.6,0.1,{
            "scaleX":0.5,
            "scaleY":0.5
         },Animate.Linear);
         Animate.addTo(this.m_view.title_mc,0.5,0.2,{"y":32},Animate.ExpoIn,function():void
         {
            if(autoHide)
            {
               animateClosingSequence(autoHide);
            }
         });
      }
      
      public function animateHiddenToMinimizedSequence(param1:String) : void
      {
         this.initializeForHiddenToMinimizeSequence();
         this.m_flare.initializeForHiddenToMinimizeSequence();
         this.m_flare.animateHiddenToMinimizedSequence();
         CommonUtils.playSound(this,param1);
         this.loopPatternMc(true);
         Animate.to(this.m_view.bg_mc,0.6,0,{
            "alpha":0.6,
            "scaleX":0.8,
            "scaleY":0.8
         },Animate.Linear);
         Animate.to(this.m_view.pattern_mc,0.6,0,{
            "y":-56,
            "alpha":1
         },Animate.Linear);
         this.m_view.title_mc.filters = [];
         Animate.addTo(this.m_view.title_mc,0.5,0.2,{
            "y":32,
            "alpha":1
         },Animate.ExpoOut);
      }
      
      private function animateClosingSequence(param1:Boolean = false) : void
      {
         var autoHide:Boolean = param1;
         this.m_flare.animateClosingSequence();
         Animate.to(this.m_view.bg_mc,0.4,0,{
            "alpha":0,
            "scaleX":0.6,
            "scaleY":0.6
         },Animate.Linear);
         Animate.to(this.m_view.icon_mc,0.4,0,{
            "alpha":0,
            "y":0
         },Animate.ExpoIn);
         Animate.to(this.m_view.pattern_mc,0.4,0,{"y":-112},Animate.ExpoIn);
         Animate.to(this.m_view.title_mc,0.4,0,{
            "y":-24,
            "scaleX":0.5,
            "scaleY":0.5
         },Animate.ExpoIn,function():void
         {
            killAllAnimations();
            if(autoHide)
            {
               m_parentClassInstance.callBackFromOverrideCheckPreviousState();
            }
         });
      }
      
      private function initializeForHiddenToMinimizeSequence() : void
      {
         this.killAllAnimations();
         this.m_view.pattern_mc.y = -185;
         this.m_view.title_mc.y = -95;
      }
      
      private function initializeForOpeningSequence() : void
      {
         this.killAllAnimations();
         this.m_view.title_mc.alpha = 0;
         this.m_view.title_mc.scaleX = this.m_view.title_mc.scaleY = 1;
         this.m_view.title_mc.y = 75;
         this.m_view.icon_mc.gotoAndStop(0);
         this.m_view.icon_mc.alpha = 1;
         this.m_view.icon_mc.y = 56;
         var _loc1_:BlurFilter = new BlurFilter(6,6,BitmapFilterQuality.MEDIUM);
         this.m_view.title_mc.filters = [_loc1_];
         this.m_view.lines_reveal_mc.gotoAndStop(0);
         this.m_view.lines_reveal_mc.y = 62;
         var _loc2_:int = MenuUtils.roundDecimal(this.m_view.title_mc.title_txt.textWidth,0);
         this.m_view.txt_lines_reveal_mc.y = 82;
         this.m_view.txt_lines_reveal_mc.line_L_mc.gotoAndStop(0);
         this.m_view.txt_lines_reveal_mc.line_R_mc.gotoAndStop(0);
         this.m_view.txt_lines_reveal_mc.line_L_mc.x = _loc2_ / -2;
         this.m_view.txt_lines_reveal_mc.line_R_mc.x = _loc2_ / 2;
         this.m_view.pattern_mc.inner_mc.gotoAndStop(0);
         this.m_view.pattern_mc.y = -112;
         this.m_view.pattern_mc.alpha = 0;
         this.m_view.bg_mc.alpha = 0;
         this.m_view.bg_mc.scaleX = this.m_view.bg_mc.scaleY = 1;
      }
      
      private function loopPatternMc(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_view.pattern_mc.inner_mc.play();
         }
         else
         {
            this.m_view.pattern_mc.inner_mc.stop();
         }
      }
      
      private function killAllAnimations() : void
      {
         Animate.kill(this);
         Animate.kill(this.m_view.title_mc);
         Animate.kill(this.m_view.icon_mc);
         Animate.kill(this.m_view.lines_reveal_mc);
         this.m_view.lines_reveal_mc.gotoAndStop(0);
         Animate.kill(this.m_view.txt_lines_reveal_mc.line_L_mc);
         Animate.kill(this.m_view.txt_lines_reveal_mc.line_R_mc);
         this.m_view.txt_lines_reveal_mc.line_L_mc.gotoAndStop(0);
         this.m_view.txt_lines_reveal_mc.line_R_mc.gotoAndStop(0);
         Animate.kill(this.m_view.bg_mc);
         this.loopPatternMc(false);
      }
      
      public function callToExitAndHide() : void
      {
         this.killAllAnimations();
         this.animateClosingSequence();
      }
      
      public function setParentClass(param1:DangerNotificationWidget) : void
      {
         this.m_parentClassInstance = param1;
      }
   }
}
