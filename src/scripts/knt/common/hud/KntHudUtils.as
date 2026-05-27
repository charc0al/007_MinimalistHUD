package knt.common.hud
{
   import flash.filters.GlowFilter;
   import knt.hud.*;
   
   public class KntHudUtils
   {
      
      public function KntHudUtils()
      {
         super();
      }
      
      public static function addOutline(param1:*, param2:uint = 0, param3:Number = 0.5, param4:Number = 1.2, param5:Number = 5, param6:int = 2) : void
      {
         if(param4 != 0)
         {
            param1.filters = [new GlowFilter(param2,param3,param4,param4,param5,param6)];
         }
         else
         {
            param1.filters = [];
         }
      }
      
      public static function appendOutline(param1:*, param2:uint = 0, param3:Number = 0.5, param4:Number = 1.2, param5:Number = 5, param6:int = 2) : void
      {
         var _loc7_:Array = param1.filters as Array;
         _loc7_.push(new GlowFilter(param2,param3,param4,param4,param5,param6));
         param1.filters = _loc7_;
      }
   }
}

