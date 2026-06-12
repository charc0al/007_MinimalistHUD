package knt.common.menu
{
   public class MenuConstantsKnt
   {
      public static const FORCE_PROMPTS_PS4:Boolean = false;
      public static const FORCE_PROMPTS_PS5:Boolean = true;
      public static const FORCE_PROMPTS_XBOXONE:Boolean = false;
      public static const FORCE_PROMPTS_XBOXSERIESX:Boolean = false;
      public static const FORCE_PROMPTS_SWITCHPRO:Boolean = false;
      public static const FORCE_PROMPTS_SWITCHJOYCON:Boolean = false;
      
      public function MenuConstantsKnt()
      {
         super();
      }
      
      public static function GetForcedControllerPromptType() : String
      {
         if(FORCE_PROMPTS_PS4)
         {
            return "ps4";
         }
         if(FORCE_PROMPTS_PS5)
         {
            return "ps5";
         }
         if(FORCE_PROMPTS_XBOXONE)
         {
            return "xboxone";
         }
         if(FORCE_PROMPTS_XBOXSERIESX)
         {
            return "xboxseriesx";
         }
         if(FORCE_PROMPTS_SWITCHPRO)
         {
            return "nspro";
         }
         if(FORCE_PROMPTS_SWITCHJOYCON)
         {
            return "nsjc";
         }
         return "";
      }
   }
}
