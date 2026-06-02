package knt.hud.notifications
{
   import flash.display.BlendMode;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.hud.*;
   
   public class DangerNotificationWidgetFlares extends BaseControl
   {
      
      public static const SOFT_TRESPASSING:Number = 0;
      
      public static const TRESPASSING:Number = 1;
      
      public static const LETHAL:Number = 2;
      
      public static const SITUATION_CONTAINED:Number = 3;
      
      public static const REINFORCEMENTS_INCOMING:Number = 4;
      
      private static const FLARE_MINIMIZED_SCALE:Number = 0.8;
      
      private var m_view:DangerNotificationWidgetFlaresView;
      
      private var m_flare:*;
      
      private var m_prevRandomInt:int = 0;
      
      private var m_prevMcArray:Array = new Array();
      
      private var m_prevClipArray:Array = new Array();
      
      private var m_randomClipsArray:Array = [1,2,3,4];
      
      public function DangerNotificationWidgetFlares()
      {
         super();
         this.m_view = new DangerNotificationWidgetFlaresView();
         addChild(this.m_view);
         this.m_view.blendMode = BlendMode.ADD;
      }
      
      public function setType(param1:int) : void
      {
         switch(param1)
         {
            case SOFT_TRESPASSING:
               this.m_flare = new DangerNotificationWidgetFlareWhiteView();
               break;
            case TRESPASSING:
               this.m_flare = new DangerNotificationWidgetFlareYellowView();
               break;
            case LETHAL:
               this.m_flare = new DangerNotificationWidgetFlareRedView();
               break;
            case SITUATION_CONTAINED:
               this.m_flare = new DangerNotificationWidgetFlareGreenView();
               break;
            case REINFORCEMENTS_INCOMING:
               this.m_flare = new DangerNotificationWidgetFlareRedView();
               break;
            default:
               this.m_flare = new DangerNotificationWidgetFlareYellowView();
         }
         this.m_flare.flare_01_mc.alpha = 0;
         this.m_flare.flare_02_mc.alpha = 0;
         this.m_flare.flare_03_mc.alpha = 0;
         this.m_flare.flare_04_mc.alpha = 0;
         this.m_view.container_mc.addChild(this.m_flare);
      }
      
      public function animateOpeningSequence() : void
      {
         this.loopFlares(true);
         this.m_view.alpha = 0;
         Animate.to(this.m_view,0.6,0,{
            "y":0,
            "alpha":1
         },Animate.ExpoOut);
      }
      
      public function animateOpeningToMinimizedSequence() : void
      {
         Animate.to(this.m_view,1,0.2,{
            "y":-2,
            "scaleX":FLARE_MINIMIZED_SCALE,
            "scaleY":FLARE_MINIMIZED_SCALE,
            "alpha":0.6
         },Animate.ExpoInOut);
      }
      
      public function animateClosingSequence() : void
      {
         Animate.to(this.m_view,0.4,0,{
            "y":-256,
            "alpha":0
         },Animate.ExpoIn,function():void
         {
            loopFlares(false);
         });
      }
      
      public function animateHiddenToMinimizedSequence() : void
      {
         this.loopFlares(true);
         Animate.to(this.m_view,0.6,0,{
            "y":-2,
            "scaleX":FLARE_MINIMIZED_SCALE,
            "scaleY":FLARE_MINIMIZED_SCALE,
            "alpha":0.6
         },Animate.ExpoOut);
      }
      
      public function initializeForOpeningSequence() : void
      {
         Animate.kill(this.m_view);
         this.loopFlares(false);
         this.m_flare.flare_01_mc.alpha = 0;
         this.m_flare.flare_02_mc.alpha = 0;
         this.m_flare.flare_03_mc.alpha = 0;
         this.m_flare.flare_04_mc.alpha = 0;
         this.m_view.alpha = 0;
         this.m_view.y = -256;
         this.m_view.scaleX = this.m_view.scaleY = 1;
      }
      
      public function initializeForHiddenToMinimizeSequence() : void
      {
         Animate.kill(this.m_view);
         this.loopFlares(false);
         this.m_flare.flare_01_mc.alpha = 0;
         this.m_flare.flare_02_mc.alpha = 0;
         this.m_flare.flare_03_mc.alpha = 0;
         this.m_flare.flare_04_mc.alpha = 0;
         this.m_view.alpha = 0;
         this.m_view.y = -256;
         this.m_view.scaleX = this.m_view.scaleY = FLARE_MINIMIZED_SCALE;
      }
      
      private function loopFlares(param1:Boolean) : void
      {
         var start:Boolean = param1;
         Animate.kill(this.m_flare.flare_01_mc);
         Animate.kill(this.m_flare.flare_02_mc);
         Animate.kill(this.m_flare.flare_03_mc);
         Animate.kill(this.m_flare.flare_04_mc);
         if(start)
         {
            this.m_flare.flare_01_mc.alpha = 0.6;
            Animate.to(this.m_flare.flare_01_mc,2,0,{"alpha":0},Animate.Linear,function():void
            {
               m_flare.flare_01_mc.scaleX = MenuUtils.getRandomBoolean() ? 1 : -1;
            });
            Animate.to(this.m_flare.flare_02_mc,2,0.2,{"alpha":0.6},Animate.Linear,function():void
            {
               Animate.to(m_flare.flare_02_mc,2,0,{"alpha":0},Animate.Linear,function():void
               {
                  m_flare.flare_02_mc.scaleX = MenuUtils.getRandomBoolean() ? 1 : -1;
               });
            });
            Animate.to(this.m_flare.flare_03_mc,2,2,{"alpha":0.6},Animate.Linear,function():void
            {
               Animate.to(m_flare.flare_03_mc,2,0,{"alpha":0},Animate.Linear,function():void
               {
                  m_flare.flare_03_mc.scaleX = MenuUtils.getRandomBoolean() ? 1 : -1;
               });
            });
            Animate.to(this.m_flare.flare_04_mc,2,3,{"alpha":0.6},Animate.Linear,function():void
            {
               Animate.to(m_flare.flare_04_mc,2,0,{"alpha":0},Animate.Linear,function():void
               {
                  m_flare.flare_04_mc.scaleX = MenuUtils.getRandomBoolean() ? 1 : -1;
               });
            });
            Animate.to(this.m_flare.flare_01_mc,2,4,{"alpha":0.6},Animate.Linear,function():void
            {
               loopFlares(true);
            });
         }
         else
         {
            Animate.to(this.m_flare.flare_01_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            Animate.to(this.m_flare.flare_02_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            Animate.to(this.m_flare.flare_03_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
            Animate.to(this.m_flare.flare_04_mc,0.2,0,{"alpha":0},Animate.ExpoIn);
         }
      }
      
      private function getRandomInt() : int
      {
         if(!this.m_randomClipsArray.length)
         {
            this.m_randomClipsArray = [1,2,3,4];
         }
         return int(this.m_randomClipsArray.splice(Math.floor(Math.random() * this.m_randomClipsArray.length),1));
      }
   }
}
