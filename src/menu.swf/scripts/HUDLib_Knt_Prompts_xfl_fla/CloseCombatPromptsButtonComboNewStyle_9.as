package HUDLib_Knt_Prompts_xfl_fla
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol524")]
   public dynamic class CloseCombatPromptsButtonComboNewStyle_9 extends MovieClip
   {
      
      public function CloseCombatPromptsButtonComboNewStyle_9()
      {
         super();
         addFrameScript(0,this.frame1,72,this.frame73);
      }
      
      private function hideChildren() : void
      {
         var child:DisplayObject = null;
         var index:int = 0;
         this.visible = false;
         this.alpha = 0;
         index = 0;
         while(index < this.numChildren)
         {
            child = this.getChildAt(index);
            child.visible = false;
            index++;
         }
      }
      
      internal function frame1() : *
      {
         this.hideChildren();
         stop();
      }
      
      internal function frame73() : *
      {
         this.hideChildren();
         gotoAndStop(1);
      }
   }
}
