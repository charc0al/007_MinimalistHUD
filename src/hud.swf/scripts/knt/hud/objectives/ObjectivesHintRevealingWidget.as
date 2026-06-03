package knt.hud.objectives
{
   import glacier.common.Animate;
   import glacier.common.BaseControl;
   import glacier.common.menu.MenuUtils;
   import knt.common.menu.MenuConstantsKnt;
   import knt.hud.*;
   
   public class ObjectivesHintRevealingWidget extends BaseControl
   {
      
      private static const NOTIFICATION_SCALE:Number = 0.5;
      
      public static const TYPE_NOTIFICATION:int = 4;
      
      public static const STATE_ACTIVE:int = 0;
      
      public static const STATE_COMPLETED:int = 1;
      
      public static const STATE_MISSED:int = 2;
      
      private var m_iconWidth:int = 21;
      
      private var m_gapWidth:int = 10;
      
      private var m_leftXPos:Number = 0;
      
      private var m_rightXPos:Number = 0;
      
      private var m_totalWidth:Number = 0;
      
      private var m_view:ObjectivesNotificationWidgetView;
      
      public function ObjectivesHintRevealingWidget()
      {
         super();
         this.m_view = new ObjectivesNotificationWidgetView();
         this.m_view.scaleX = this.m_view.scaleY = NOTIFICATION_SCALE;
         addChild(this.m_view);
         this.m_view.alpha = 0;
         MenuUtils.addDropShadowFilter(this.m_view.pop_mc.title_txt);
         MenuUtils.addDropShadowFilter(this.m_view.pop_mc.icon_mc);
         MenuUtils.setColor(this.m_view.pop_mc.icon_mc,MenuConstantsKnt.COLOR_OBJECTIVE);
      }
      
      public function onSetData(param1:Object) : void
      {
      }
      
      private function animateOpeningSequence(param1:int, param2:Number) : void
      {
         var alphaState:Number;
         var lineScaleX:Number;
         var state:int = param1;
         var delay:Number = param2;
         var bdPulseScaleX:Number = Number(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.scaleX);
         var bdPulseScaleY:Number = Number(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.scaleY);
         this.m_view.pop_mc.backdrop_pulse_mc.alpha = 1;
         Animate.to(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_01,0.4,0,{"alpha":0},Animate.ExpoOut);
         Animate.to(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_02,0.4,0,{"alpha":0},Animate.ExpoOut);
         Animate.fromTo(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03,0.4,0,{
            "alpha":0.2,
            "scaleX":this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.scaleX,
            "scaleY":this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.scaleY
         },{
            "alpha":0,
            "scaleX":bdPulseScaleX * 1.1,
            "scaleY":bdPulseScaleY * 0.33
         },Animate.ExpoOut);
         Animate.fromTo(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_04,0.3,0.3,{
            "alpha":0.4,
            "scaleX":this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.scaleX,
            "scaleY":this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.scaleY
         },{
            "alpha":0,
            "scaleX":bdPulseScaleX * 2,
            "scaleY":bdPulseScaleY * 0.2
         },Animate.ExpoOut);
         alphaState = 1;
         Animate.to(this.m_view.pop_mc.title_txt,0.4,0.3,{"alpha":alphaState},Animate.ExpoOut);
         Animate.to(this.m_view.pop_mc.icon_mc,0.4,0.3,{"alpha":1},Animate.ExpoOut);
         lineScaleX = Number(this.m_view.pop_mc.line_upper_mc.scaleX);
         Animate.fromTo(this.m_view.pop_mc.line_upper_mc,0.4,0.2,{
            "x":this.m_rightXPos,
            "alpha":0,
            "scaleX":0
         },{
            "x":this.m_leftXPos,
            "alpha":0.2,
            "scaleX":lineScaleX
         },Animate.ExpoOut);
         Animate.fromTo(this.m_view.pop_mc.line_lower_mc,0.4,0.2,{
            "x":this.m_leftXPos,
            "alpha":0,
            "scaleX":0
         },{
            "x":this.m_rightXPos,
            "alpha":0.2,
            "scaleX":lineScaleX
         },Animate.ExpoOut);
         Animate.fromTo(this.m_view.pop_mc.dot_upper_mc,0.4,0.2,{
            "x":this.m_rightXPos,
            "alpha":0
         },{
            "x":this.m_leftXPos,
            "alpha":1
         },Animate.ExpoOut);
         Animate.fromTo(this.m_view.pop_mc.dot_lower_mc,0.4,0.2,{
            "x":this.m_leftXPos,
            "alpha":0
         },{
            "x":this.m_rightXPos,
            "alpha":1
         },Animate.ExpoOut);
         Animate.fromTo(this.m_view.image_mc,0.4,0.4,{
            "x":this.m_rightXPos,
            "alpha":0
         },{
            "x":this.m_leftXPos,
            "alpha":1
         },Animate.ExpoOut);
         Animate.delay(this,delay - 0.4,function():void
         {
            killAllAnimations();
            animateClosingSequence();
         });
      }
      
      private function animateClosingSequence() : void
      {
         this.m_view.pop_mc.backdrop_pulse_mc.alpha = 0;
         Animate.to(this.m_view.pop_mc.title_txt,0.4,0,{"alpha":0},Animate.ExpoOut);
         Animate.to(this.m_view.pop_mc.icon_mc,0.4,0,{"alpha":0},Animate.ExpoOut);
         Animate.to(this.m_view.pop_mc.line_upper_mc,0.4,0,{
            "x":0,
            "scaleX":0
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.pop_mc.line_upper_mc,0.4,0,{"alpha":0},Animate.ExpoOut);
         });
         Animate.to(this.m_view.pop_mc.line_lower_mc,0.4,0,{
            "x":0,
            "scaleX":0
         },Animate.ExpoOut,function():void
         {
            Animate.to(m_view.pop_mc.line_lower_mc,0.4,0,{"alpha":0},Animate.ExpoOut);
         });
         Animate.to(this.m_view.pop_mc.dot_upper_mc,0.4,0,{
            "x":0,
            "alpha":0
         },Animate.ExpoOut);
         Animate.to(this.m_view.pop_mc.dot_lower_mc,0.4,0,{
            "x":0,
            "alpha":0
         },Animate.ExpoOut);
         Animate.to(this.m_view.image_mc,0.4,0,{"alpha":0},Animate.ExpoOut);
      }
      
      private function alignAllElements() : void
      {
         this.m_totalWidth = this.m_view.pop_mc.title_txt.textWidth + this.m_gapWidth + this.m_iconWidth + 2;
         this.m_leftXPos = this.m_view.pop_mc.title_txt.textWidth / -2 + (this.m_gapWidth + this.m_iconWidth) / 2 - this.m_gapWidth - this.m_iconWidth;
         this.m_rightXPos = this.m_leftXPos * -1 + 2;
         this.m_view.pop_mc.title_txt.x = this.m_leftXPos + this.m_gapWidth + this.m_iconWidth;
         this.m_view.pop_mc.icon_mc.x = this.m_leftXPos;
         this.m_view.image_mc.x = this.m_rightXPos;
         this.m_view.pop_mc.dot_upper_mc.x = this.m_rightXPos;
         this.m_view.pop_mc.dot_lower_mc.x = this.m_leftXPos;
         this.m_view.pop_mc.line_upper_mc.x = this.m_rightXPos;
         this.m_view.pop_mc.line_upper_mc.width = this.m_totalWidth;
         this.m_view.pop_mc.line_lower_mc.x = this.m_leftXPos;
         this.m_view.pop_mc.line_lower_mc.width = this.m_totalWidth;
         this.m_view.pop_mc.backdrop_pulse_mc.alpha = 0;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_01.alpha = 1;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_02.alpha = 1;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.alpha = 0.2;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_04.alpha = 0;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_02.width = this.m_totalWidth;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.width = this.m_totalWidth;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03.height = 25;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_04.width = this.m_totalWidth;
         this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_04.height = 25;
      }
      
      private function killAllAnimations() : void
      {
         Animate.kill(this.m_view.pop_mc);
         Animate.kill(this.m_view.pop_mc.title_txt);
         Animate.kill(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_01);
         Animate.kill(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_02);
         Animate.kill(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_03);
         Animate.kill(this.m_view.pop_mc.backdrop_pulse_mc.pulse_mc_04);
         Animate.kill(this.m_view.pop_mc.dot_upper_mc);
         Animate.kill(this.m_view.pop_mc.dot_lower_mc);
         Animate.kill(this.m_view.pop_mc.line_upper_mc);
         Animate.kill(this.m_view.pop_mc.line_lower_mc);
         Animate.kill(this.m_view.pop_mc.icon_mc);
         Animate.kill(this.m_view.image_mc);
         Animate.kill(this);
      }
      
      public function testPop() : void
      {
         this.onSetData({
            "title":"Hint Revealing Test",
            "description":"This is the description if needed?",
            "state":MenuUtils.getRandomInRange(0,2,true),
            "type":4
         });
      }
   }
}

