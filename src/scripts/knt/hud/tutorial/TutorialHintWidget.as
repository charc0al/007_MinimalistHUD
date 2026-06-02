package knt.hud.tutorial
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class TutorialHintWidget extends BaseControl
   {
      
      private var m_view:TutorialHintWidgetView;
      
      private var m_iconWidth:int = 21;
      
      private var m_gapWidth:int = 7;
      
      private var m_leftXPos:Number = 0;
      
      private var m_rightXPos:Number = 0;
      
      private var m_totalWidth:Number = 0;
      
      private var m_isActive:Boolean = false;
      
      public function TutorialHintWidget()
      {
         super();
         this.m_view = new TutorialHintWidgetView();
         this.m_view.alpha = 0;
         addChild(this.m_view);
      }
      
      public function onSetData(param1:Object) : void
      {
         this.m_isActive = false;
         this.killAllAnimations();
         this.visible = false;
         this.m_view.visible = false;
         this.m_view.alpha = 0;
      }
      
      private function showObjectiveWithAnimation() : void
      {
         this.m_view.alpha = 1;
         Animate.to(this.m_view.title_txt,0.4,0.3,{"alpha":1},Animate.ExpoOut);
         Animate.to(this.m_view.icon_mc,0.4,0.3,{"alpha":1},Animate.ExpoOut);
         Animate.to(this.m_view.description_txt,0.4,0.3,{"alpha":0.6},Animate.ExpoOut);
         var _loc1_:Number = this.m_view.line_upper_mc.scaleX;
         Animate.fromTo(this.m_view.line_upper_mc,0.4,0.2,{
            "x":this.m_rightXPos,
            "alpha":0,
            "scaleX":0
         },{
            "x":this.m_leftXPos,
            "alpha":0.2,
            "scaleX":_loc1_
         },Animate.ExpoOut);
         Animate.fromTo(this.m_view.line_lower_mc,0.4,0.2,{
            "x":this.m_leftXPos,
            "alpha":0,
            "scaleX":0
         },{
            "x":this.m_rightXPos,
            "alpha":0.2,
            "scaleX":_loc1_
         },Animate.ExpoOut);
         Animate.fromTo(this.m_view.dot_upper_mc,0.4,0.2,{
            "x":this.m_rightXPos,
            "alpha":0
         },{
            "x":this.m_leftXPos,
            "alpha":1
         },Animate.ExpoOut);
         Animate.fromTo(this.m_view.dot_lower_mc,0.4,0.2,{
            "x":this.m_leftXPos,
            "alpha":0
         },{
            "x":this.m_rightXPos,
            "alpha":1
         },Animate.ExpoOut);
      }
      
      private function animateClosingSequence() : void
      {
         Animate.to(this.m_view.title_txt,0.4,0,{"alpha":0},Animate.ExpoOut);
         Animate.to(this.m_view.description_txt,0.4,0,{"alpha":0},Animate.ExpoOut);
         Animate.to(this.m_view.icon_mc,0.4,0,{"alpha":0},Animate.ExpoOut);
         Animate.to(this.m_view.line_upper_mc,0.4,0,{
            "x":0,
            "scaleX":0
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.line_upper_mc,0.4,0,{"alpha":0},Animate.ExpoOut);
         });
         Animate.to(this.m_view.line_lower_mc,0.4,0,{
            "x":0,
            "scaleX":0
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.line_lower_mc,0.4,0,{"alpha":0},Animate.ExpoOut);
         });
         Animate.to(this.m_view.dot_upper_mc,0.4,0,{
            "x":0,
            "alpha":0
         },Animate.ExpoOut);
         Animate.to(this.m_view.dot_lower_mc,0.4,0,{
            "x":0,
            "alpha":0
         },Animate.ExpoOut);
      }
      
      private function formatEntry(param1:String, param2:String) : void
      {
         this.m_view.alpha = 0;
         MenuUtils.addDropShadowFilter(this.m_view.title_txt);
         MenuUtils.addDropShadowFilter(this.m_view.description_txt);
         MenuUtils.addDropShadowFilter(this.m_view.icon_mc);
         this.m_view.line_upper_mc.alpha = this.m_view.line_lower_mc.alpha = 0;
         this.m_view.dot_upper_mc.alpha = this.m_view.dot_lower_mc.alpha = 0;
         this.m_view.scaleX = this.m_view.scaleY = 1;
         this.m_view.title_txt.alpha = 0;
         this.m_view.description_txt.alpha = 0;
         this.m_view.icon_mc.alpha = 0;
         MenuUtils.setupText(this.m_view.title_txt,param1,22,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         this.m_view.title_txt.autoSize = "center";
         this.m_view.description_txt.autoSize = "left";
         this.m_view.description_txt.width = 382;
         this.m_view.description_txt.multiline = true;
         this.m_view.description_txt.wordWrap = true;
         MenuUtils.setupText(this.m_view.description_txt,"",16,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         if(Boolean(param2) && param2 != "")
         {
            MenuUtils.setupText(this.m_view.description_txt,param2,16,MenuConstantsKnt.FONT_TYPE_NORMAL,MenuConstantsKnt.FontColorWhite);
         }
      }
      
      private function alignAllEntryElements() : void
      {
         this.m_totalWidth = 382 + this.m_gapWidth + this.m_iconWidth + 2;
         this.m_leftXPos = 382 / -2 + (this.m_gapWidth + this.m_iconWidth) / 2 - this.m_gapWidth - this.m_iconWidth;
         this.m_rightXPos = this.m_leftXPos * -1 + 2;
         this.m_view.title_txt.x = this.m_leftXPos + this.m_gapWidth + this.m_iconWidth;
         this.m_view.description_txt.x = this.m_leftXPos + this.m_gapWidth + this.m_iconWidth;
         this.m_view.icon_mc.x = this.m_leftXPos;
         this.m_view.dot_upper_mc.x = this.m_rightXPos;
         this.m_view.dot_lower_mc.x = this.m_leftXPos;
         this.m_view.line_upper_mc.x = this.m_rightXPos;
         this.m_view.line_upper_mc.width = this.m_totalWidth;
         this.m_view.line_lower_mc.x = this.m_leftXPos;
         this.m_view.line_lower_mc.width = this.m_totalWidth;
         this.m_view.x = this.m_leftXPos;
      }
      
      private function killAllAnimations() : void
      {
         Animate.kill(this.m_view.pop_mc);
         Animate.kill(this.m_view.title_txt);
         Animate.kill(this.m_view.dot_upper_mc);
         Animate.kill(this.m_view.dot_lower_mc);
         Animate.kill(this.m_view.line_upper_mc);
         Animate.kill(this.m_view.line_lower_mc);
         Animate.kill(this.m_view.icon_mc);
      }
      
      public function testHint() : void
      {
         this.onSetData({
            "title":"Tutorial Hint",
            "description":"On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain."
         });
      }
   }
}

