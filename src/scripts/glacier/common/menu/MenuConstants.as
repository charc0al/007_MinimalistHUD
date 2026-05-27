package glacier.common.menu
{
   public class MenuConstants
   {
      
      public static var BaseWidth:int = 1920;
      
      public static var BaseHeight:int = 1080;
      
      public static var ScrollingList_Visibility_ExtendWidth:Number = 150;
      
      public static var ScrollingList_VR_ExtendWidth:Number = ScrollingList_Visibility_ExtendWidth * 2;
      
      public static const PLAYERNAME_MIN_CHAR_COUNT:uint = 16;
      
      public static const PLAYER_MULTIPLAYER_DELIMITER:String = " & ";
      
      public static const SPLASH_HINT_TYPE_GLOBAL:int = 0;
      
      public static const SPLASH_HINT_TYPE_TUTORIAL:int = 1;
      
      public static const SPLASH_HINT_TYPE_CONTROLLER:int = 2;
      
      public static var MenuTileSmallWidth:int = 351;
      
      public static var CategoryElementWidth:int = 351;
      
      public static var OptionsListElementSliderWidth:int = 170;
      
      public static var OptionsListElementSliderHeight:int = 10;
      
      public static const COLOR_MATRIX_DEFAULT:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      public static const COLOR_MATRIX_DESATURATED:Array = [0.464418,0.383922,0.05166,0,-2.65,0.194418,0.653922,0.05166,0,-2.65,0.194418,0.383922,0.32166,0,-2.65,0,0,0,1,0];
      
      public static const COLOR_MATRIX_SATURATED:Array = [1.10371,-0.09140999999999995,-0.012299999999999993,0,35,-0.04628999999999997,1.05859,-0.012299999999999993,0,34.99999999999999,-0.04628999999999997,-0.09140999999999995,1.1377,0,35,0,0,0,1,0];
      
      public static const COLOR_MATRIX_DARKENED:Array = [0.5,0,0,0,0,0,0.5,0,0,0,0,0,0.5,0,0,0,0,0,1,0];
      
      public static const COLOR_MATRIX_DARK:Array = [0.24,0,0,0,0,0,0.24,0,0,0,0,0,0.24,0,0,0,0,0,1,0];
      
      public static const COLOR_MATRIX_STENCIL:Array = [0.6,1,0.11,0,0,0.6,1,0.11,0,0,0.6,1,0.11,0,0,0,0,0,1,0];
      
      public static const COLOR_MATRIX_INVERTED:Array = [-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0];
      
      public static const COLOR_MATRIX_BW:Array = [0.3,0.59,0.11,0,0,0.3,0.59,0.11,0,0,0.3,0.59,0.11,0,0,0,0,0,1,0];
      
      public static const COLOR_MATRIX_BW_LOW_CONTRAST:Array = [0.13887,0.27423,0.036899999999999995,0,34.925000000000004,0.13887,0.27423,0.036899999999999995,0,34.925000000000004,0.13887,0.27423,0.036899999999999995,0,34.925000000000004,0,0,0,1,0];
      
      public static const COLOR_MATRIX_GRAYSCALE:Array = [0.5,0.5,0.5,0,0,0.5,0.5,0.5,0,0,0.5,0.5,0.5,0,0,0,0,0,1,0];
      
      public static const COLOR_MATRIX_DARKENED_DESATURATED:Array = [0.6404719999999999,0.31688800000000006,0.042640000000000004,0,-4.999999999999999,0.160472,0.796888,0.042640000000000004,0,-5,0.160472,0.31688800000000006,0.52264,0,-5,0,0,0,1,0];
      
      public static const COLOR_MATRIX_FULLY_DESATURATED:Array = [0.309,0.609,0.082,0,0,0.309,0.609,0.082,0,0,0.309,0.609,0.082,0,0,0,0,0,1,0];
      
      public static var HiliteTime:Number = 0.1;
      
      public static var ScrollTime:Number = 0.3;
      
      public static var WheelScrollTime:Number = 0.1;
      
      public static var SwipeOutTime:Number = 0.1;
      
      public static var SwipeInTime:Number = 0.3;
      
      public static var PageOpenTime:Number = 0.3;
      
      public static var PageCloseTime:Number = 0.1;
      
      public static var tileGap:int = 1;
      
      public static var tileBorder:int = 0;
      
      public static var tileImageBorder:int = 5;
      
      public static var menuXOffset:int = 80;
      
      public static var menuYOffset:int = 56;
      
      public static var verticalScrollGapLeft:int = 0;
      
      public static var verticalScrollGapRight:int = 26;
      
      public static const MenuElementBackgroundAlpha:Number = 0.5;
      
      public static const MenuElementSelectedAlpha:Number = 1;
      
      public static const MenuElementDeselectedAlpha:Number = 0.5;
      
      public static const MenuFrameEndScreenBackgroundAlpha:Number = 0.8;
      
      public static const COLOR_WHITE:int = 16777215;
      
      public static const COLOR_GREY_ULTRA_LIGHT:int = 15461355;
      
      public static const COLOR_GREY_LIGHT:int = 13816530;
      
      public static const COLOR_GREY:int = 12434877;
      
      public static const COLOR_GREY_MEDIUM:int = 9605778;
      
      public static const COLOR_GREY_DARK:int = 4605510;
      
      public static const COLOR_GREY_ULTRA_DARK:int = 2171169;
      
      public static const COLOR_BLACK:int = 0;
      
      public static const COLOR_BLUE_LIGHT:int = 4959472;
      
      public static const COLOR_GOLD:int = 12551492;
      
      public static const COLOR_CYAN:int = 3801087;
      
      public static const COLOR_CYAN_DARK:int = 2589314;
      
      public static const COLOR_RED:int = 16384014;
      
      public static const COLOR_YELLOW:int = 16763136;
      
      public static const COLOR_TURQUOISE:int = 65487;
      
      public static const COLOR_GREEN:int = 4325197;
      
      public static const COLOR_BLUE:int = 2168555;
      
      public static var COLOR_HIGHLIGHT:int = COLOR_GOLD;
      
      public static var COLOR_HIGHLIGHT_BG:int = COLOR_GOLD;
      
      public static const COLOR_MENU_TABS_BACKGROUND:int = 2305594;
      
      public static const COLOR_MENU_SOLID_BACKGROUND:int = 2961464;
      
      public static const COLOR_MENU_BUTTON_TILE_DESELECTED:int = 1054236;
      
      public static const COLOR_MENU_CONTRACT_SEARCH_GREY:int = 5527389;
      
      public static const COLOR_END_SCREEN_BACKGROUND:int = 1647147;
      
      public static var FontColorWhite:String = ColorString(COLOR_WHITE);
      
      public static var FontColorGreyUltraLight:String = ColorString(COLOR_GREY_ULTRA_LIGHT);
      
      public static var FontColorGreyLight:String = ColorString(COLOR_GREY_LIGHT);
      
      public static var FontColorGrey:String = ColorString(COLOR_GREY);
      
      public static var FontColorGreyMedium:String = ColorString(COLOR_GREY_MEDIUM);
      
      public static var FontColorGreyDark:String = ColorString(COLOR_GREY_DARK);
      
      public static var FontColorGreyUltraDark:String = ColorString(COLOR_GREY_ULTRA_DARK);
      
      public static var FontColorBlack:String = ColorString(COLOR_BLACK);
      
      public static var FontColorRed:String = ColorString(COLOR_RED);
      
      public static var FontColorYellow:String = ColorString(COLOR_YELLOW);
      
      public static var FontColorTurquoise:String = ColorString(COLOR_TURQUOISE);
      
      public static var FontColorGreen:String = ColorString(COLOR_GREEN);
      
      public static var FontColorBlue:String = ColorString(COLOR_BLUE);
      
      public static var FontColorHighlight:String = ColorString(COLOR_HIGHLIGHT);
      
      public static const FONT_TYPE_LIGHT:String = "$light";
      
      public static const FONT_TYPE_NORMAL:String = "$normal";
      
      public static const FONT_TYPE_MEDIUM:String = "$medium";
      
      public static const FONT_TYPE_BOLD:String = "$bold";
      
      public static const FONT_TYPE_GLOBAL:String = "$global";
      
      public static const FONT_TYPE_NUMBERS:String = "$numbers";
      
      public static const KEYCODE_ENTER:uint = 13;
      
      public static const KEYCODE_ESC:uint = 27;
      
      public static const KEYCODE_TAB:uint = 9;
      
      public static const KEYCODE_F1:uint = 112;
      
      public static const KEYCODE_RIGHT:uint = 39;
      
      public static const KEYCODE_DOWN:uint = 40;
      
      public static const KEYCODE_A:uint = 65;
      
      public function MenuConstants()
      {
         super();
      }
      
      public static function ColorString(param1:int) : String
      {
         return "#" + param1.toString(16);
      }
      
      public static function ColorNumber(param1:String) : int
      {
         var _loc2_:int = int(param1.indexOf("#"));
         if(_loc2_ >= 0)
         {
            return int("0x" + param1.substr(_loc2_ + 1));
         }
         return 0;
      }
   }
}

