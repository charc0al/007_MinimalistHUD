package knt.basic
{
   import flash.events.Event;
   import flash.utils.getTimer;
   import glacier.basic.IGlobalLoadindicator;
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.CommonUtils;
   import glacier.common.Localization;
   import glacier.common.menu.MenuConstants;
   import glacier.common.menu.MenuUtils;
   
   public class GlobalLoadindicatorKnt extends BaseControl implements IGlobalLoadindicator
   {
      
      private var m_view:GlobalLoadIndicatorKntView;
      
      private const FRAME_START:int = 40;
      
      private const TOTAL_FRAMES:int = 39;
      
      private var m_deltaTime:Number;
      
      private var m_prevFrame:Number;
      
      private var m_currentFrame:Number;
      
      private var m_fpsToReach:int = 24;
      
      private var m_frameFactor:Number = 0;
      
      private var m_frame:int;
      
      public var m_animated:Boolean = false;
      
      private var m_discrete:Boolean;
      
      private var m_bootFlowMode:Boolean;
      
      private var m_hasSetBarcodeScale:Boolean = false;
      
      private var m_originalBackgroundWidth:Number;
      
      public function GlobalLoadindicatorKnt()
      {
         super();
         this.m_view = new GlobalLoadIndicatorKntView();
         MenuUtils.setColor(this.m_view.loadindicator.progressbar.bar,MenuConstants.COLOR_WHITE,true,1);
         MenuUtils.setColor(this.m_view.loadindicator.progressbar.bg,MenuConstants.COLOR_WHITE,true,0.25);
         this.m_view.loadindicator.progressbar.bar.visible = false;
         this.m_view.loadindicator.progressbar.bg.visible = false;
         addChild(this.m_view);
         this.hideIndicator();
      }
      
      public function onSetData(param1:Object) : void
      {
         if(this.isSaveIndicatorData(param1))
         {
            this.hideIndicator();
            return;
         }
         this.ShowLoadindicator(param1);
      }
      
      public function ShowLoadindicator(param1:Object) : void
      {
         if(this.isSaveIndicatorData(param1))
         {
            this.hideIndicator();
            return;
         }
         this.visible = true;
         this.alpha = 1;
         this.m_view.alpha = 1;
         this.m_discrete = param1.discrete ? true : false;
         this.m_view.loadindicator.progressbar.visible = param1.discrete ? false : true;
         this.m_view.loadindicator.title_txt.visible = param1.discrete ? false : true;
         if(this.m_bootFlowMode)
         {
         }
         this.m_view.loadindicator.inner_mc.gotoAndStop(param1.icon);
         trace("GlobalLoadIndicator icon: " + param1.icon);
         this.setText(param1.header);
         this.m_view.loadindicator.progressbar.width = this.m_view.loadindicator.title_txt.textWidth + 2;
         this.m_view.loadindicator.progressbar.x = -this.m_view.loadindicator.title_txt.textWidth / 2 - 1;
         this.startAnim();
      }
      
      public function HideLoadindicator() : void
      {
         this.m_hasSetBarcodeScale = false;
         this.stopAnim();
      }
      
      public function set BootFlowMode(param1:Boolean) : void
      {
         this.m_bootFlowMode = param1;
      }
      
      public function setText(param1:String) : void
      {
         var _loc2_:Number = -1;
         var _loc3_:Number = 9;
         this.m_view.loadindicator.title_txt.multiline = true;
         this.m_view.loadindicator.title_txt.wordWrap = true;
         if(param1 == null)
         {
            param1 = "";
         }
         MenuUtils.setupTextUpper(this.m_view.loadindicator.title_txt,param1,18,MenuConstants.FONT_TYPE_MEDIUM,MenuConstants.FontColorWhite);
         CommonUtils.changeFontToGlobalIfNeeded(this.m_view.loadindicator.title_txt);
         MenuUtils.setupTextAndShrinkToFitUpper(this.m_view.loadindicator.title_txt,param1,18,MenuConstants.FONT_TYPE_MEDIUM,this.m_view.loadindicator.title_txt.width,_loc2_,_loc3_,MenuConstants.FontColorWhite);
      }
      
      override public function onSetVisible(param1:Boolean) : void
      {
         if(!param1)
         {
            this.hideIndicator();
         }
      }
      
      public function showSaveIcon() : void
      {
         this.hideIndicator();
      }
      
      public function hideSaveIcon() : void
      {
         this.hideIndicator();
      }
      
      public function startAnim() : void
      {
         this.pushBarcodeAnim();
         if(this.m_animated)
         {
            return;
         }
         this.m_animated = true;
         this.m_prevFrame = getTimer();
         if(this.m_discrete)
         {
            this.m_view.gotoAndStop(15);
         }
         else
         {
            this.m_view.gotoAndPlay(2);
         }
      }
      
      public function stopAnim() : void
      {
         this.popBarcodeAnim();
         if(!this.m_animated)
         {
            return;
         }
         this.m_animated = false;
         if(this.m_discrete)
         {
            this.m_view.alpha = 0;
         }
         this.m_view.gotoAndPlay(21);
      }
      
      private function pushBarcodeAnim() : void
      {
         var numFrames:Number;
         var dur:Number;
         var view:GlobalLoadindicatorKnt = null;
         var startFrame:Number = Number(this.m_view.loadindicator.barcodes.currentFrame);
         var endFrame:Number = this.FRAME_START + this.TOTAL_FRAMES;
         if(startFrame < this.FRAME_START || startFrame == endFrame)
         {
            startFrame = this.FRAME_START;
         }
         numFrames = endFrame - startFrame;
         dur = (endFrame - startFrame) / this.m_fpsToReach;
         view = this;
         Animate.fromTo(this.m_view.loadindicator.barcodes,dur,0,{"frames":startFrame},{"frames":endFrame},Animate.Linear,function():void
         {
            if(view.m_animated)
            {
               pushBarcodeAnim();
            }
         });
      }
      
      private function popBarcodeAnim() : void
      {
         Animate.kill(this.m_view.loadindicator.barcodes);
      }
      
      private function update(param1:Event) : void
      {
         this.m_currentFrame = getTimer();
         this.m_deltaTime = (this.m_currentFrame - this.m_prevFrame) * 0.001;
         this.m_prevFrame = this.m_currentFrame;
         this.m_frameFactor += this.m_fpsToReach * this.m_deltaTime;
         this.m_frame = Math.ceil(this.m_frameFactor);
         if(this.m_frame > this.TOTAL_FRAMES)
         {
            this.m_frameFactor = 0;
         }
         this.m_view.loadindicator.barcodes.gotoAndStop(this.FRAME_START + this.m_frame);
      }
      
      public function setProgress(param1:Number) : void
      {
         if(!this.m_hasSetBarcodeScale)
         {
            this.m_hasSetBarcodeScale = true;
         }
         this.m_view.loadindicator.progressbar.bar.visible = true;
         this.m_view.loadindicator.progressbar.bg.visible = true;
         this.m_view.loadindicator.progressbar.visible = true;
         this.m_view.loadindicator.progressbar.bar.scaleX = param1;
      }
      
      public function showProgress(param1:Boolean) : void
      {
         this.m_view.loadindicator.progressbar.bar.visible = param1;
         this.m_view.loadindicator.progressbar.bg.visible = param1;
         this.m_view.loadindicator.progressbar.visible = param1;
      }
      
      override public function onSetSize(param1:Number, param2:Number) : void
      {
         super.onSetSize(param1,param2);
         if(this.m_bootFlowMode)
         {
            return;
         }
      }
      
      private function isSaveIndicatorData(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param1.icon == "save")
         {
            return true;
         }
         return param1.header == Localization.get("UI_HUD_SAVING");
      }
      
      private function hideIndicator() : void
      {
         this.HideLoadindicator();
         Animate.kill(this.m_view);
         Animate.kill(this.m_view.loadindicator);
         Animate.kill(this.m_view.loadindicator.barcodes);
         this.m_view.alpha = 0;
         this.visible = false;
      }
   }
}
