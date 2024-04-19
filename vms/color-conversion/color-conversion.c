/*
   These RGB/HLS/HSV routines come from DEC document AA-MI676A-TE
   "A Guide to Migrating VWS Applications to DECwindows", Sep 1989,
   Appendix F: Color Conversion Routines.

 */

#ifdef VAXC
#module Color_Conversion "V01.0-000"
#endif

/*
 *
 * Facility:
 *
 *      Color_Conversion
 *
 * Abstract:
 *
 *      General usage conversion routines for HLS and HSV and RGB.
 *      The routines use the UIS conventions for Hue in HLS (centered
 *      at RED instead of BLUE).
 *
 * Environment:
 *
 *      VMS/VAX-C
 *
 * Entry Points:
 *
 *	  All values are passed by reference, and F Floating.
 *
 *	  Hue is always from 0 to 360, unless Saturation = 0
 *	  in which case it is ignored as input, and returns a
 *	  -1.0 as output.
 *	  All other values are expressed as a percentage from
 *	  0.0 to 1.0 inclusive.
 *
 *    HSV_to_RGB( Hue, Saturation, Value, Red, Green, Blue)
 *
 *	  Hue.rf.r        = Hue, from 0 to 360	     
 *	  Saturation.rf.r = Saturation, from 0 to 1  
 *	  Value.rf.r	  = Value, from 0 to 1	   
 *	  Red.rf.w	  = Red, from 0 to 1	   
 *	  Green.rf.w	  = Green, from 0 to 1	   
 *	  Blue.rf.w	  = Blue, from 0 to 1        
 *	
 *    HLS_to_RGB( Hue, Lightness, Saturation, Red, Green, Blue)
 *
 *	  Hue.rf.r        = Hue, from 0 to 360	  
 *	  Lightness.rf.r  = Lightness, from 0 to 1  
 *	  Saturation.rf.r = Saturation, from 0 to 1 
 *	  Red.rf.w	  = Red, from 0 to 1	  
 *	  Green.rf.w	  = Green, from 0 to 1	  
 *	  Blue.rf.w	  = Blue, from 0 to 1       
 *	  
 *    RGB_to_HSV( Red, Green, Blue, Hue, Saturation, Value)
 *
 *	  Red.rf.r        = Red, from 0 to 1			       
 *	  Green.rf.r	  = Green, from 0 to 1			       
 *	  Blue.rf.r	  = Blue, from 0 to 1			       
 *	  Hue.rf.w	  = Hue, from 0 to 360, -1.0 if Saturation = 0.0 
 *	  Saturation.rf.w = Saturation, from 0 to 1		       
 *	  Value.rf.w	  = Value, from 0 to 1                           
 *
 *    RGB_to_HLS( Red, Green, Blue, Hue, Lightness, Saturation)
 *
 * 	  Red.rf.r          Red, from 0 to 1  
 * 	  Green.rf.r	    Green, from 0 to 1
 * 	  Blue.rf.r	    Blue, from 0 to 1 
 * 	  Hue.rf.w        = Hue, from 0 to 360, -1.0 if Saturation = 0.0
 *        Lightness.rf.w  = Lightness, from 0 to 1
 *        Saturation.rf.w = Saturation, from 0 to 1
 *
 * Modification History:
 *
 *   Apr 2024: Typos and programming errors corrected by hackerb9.
 *
 */

 extern void HSV_to_RGB();
 extern void HLS_to_RGB();
 extern void RGB_to_HSV();
 extern void RGB_to_HLS();
 static float VALUE();

#define min3(x,y,z)  ( ( (  (x < y) ? x:y ) < z ) ? ( (x < y) ? x:y ) : z ) 
#define max3(x,y,z)  ( ( (  (x > y) ? x:y ) > z ) ? ( (x > y) ? x:y ) : z )

void RGB_to_HSV ( Red, Green, Blue, Hue, Saturation, Value)
float *Red, *Green, *Blue, *Hue, *Saturation, *Value;
/*
 *  RGB_to_HSV - converts RGB values as input into HSV as output.
 *
 *  All parameters are passed by reference and are floating point.
 *
 *  RGB are read only, HSV are write only.
 *
 *  A Saturation of 0 returns -1.0 as the Hue
 *
 */
{
     float max_value, min_value,
	   color_span,
	   red_content, green_content, blue_content;

    /*
     *  Get the max and min values for RGB
     *
     */

     max_value = max3( *Red, *Green, *Blue); 
     min_value = min3( *Red, *Green, *Blue);

    /*
     *  Value =  max_value
     *
     */

     *Value = max_value;
    
    /*
     * Now compute Saturation
     *
     */
     if (max_value != 0.0)
     {
	  *Saturation = (max_value - min_value) / max_value;
     }
     else
     {
	  *Saturation = 0.0;
     }

    /*
     * And finally the Hue
     *
     */
     if (*Saturation != 0.0)
     {
	  color_span    = max_value - min_value;
	  red_content   = (max_value - *Red) / color_span;  
          green_content = (max_value - *Green) / color_span;
          blue_content  = (max_value - *Blue) / color_span; 

	  /* XXX Original scan uses one equals sign for comparisons! */
	  if (*Red == max_value)
	  {
	       *Hue = blue_content - green_content;
	  }
	  else
	  {
	       if (*Green == max_value)
	       {
		    *Hue = 2.0 + red_content - blue_content;
	       }
	       else
	       {
		    *Hue = 4.0 + green_content - red_content;
	       }
	  }

	  *Hue = *Hue * 60.0;
	  while (*Hue < 0.0) *Hue = *Hue + 360.0;
     }
     else
     {

	  /*
	   *  A Saturation of zero results in UIS$C_COLOR_UNDEFINED which 
	   *  is a -1.0 in floating point 				    
	   *
	   */
	  *Hue = -1.0;
     }
}

void HSV_to_RGB( Hue, Saturation, Value, Red, Green, Blue)
float *Hue, *Saturation, *Value, *Red, *Green, *Blue;
/*
 *  HSV_to_RGB - converts HSV values as input into RGB as output. 
 *
 *  All parameters are passed by reference and are floating point.
 *
 *  HSV are read only, RGB are write only.			       
 */
{
     int   integer_hue;
     float fractional_hue, p, q, t, h;

     if (*Saturation == 0)
     {
	 /*
	  * Strictly speaking, a Saturation of 0 means that Hue should
	  * contain UIS$C COLOR UNDEFINED, but the standard industry
	  * practice is to ignore Hue if the Saturation is 0. The UIS
	  * call will signal an error if Hue is not -1.0
	  *
	  * This is the anachromatic case, where R = G = B = Value.
	  */
	  *Red   = *Value;
	  *Green = *Value; 
	  *Blue  = *Value;
     }
     else
     {
	  h = *Hue; /* A local copy of the Hue */

	  while (h <    0.0) h = h + 360.0; /* Need a positive angle */
	  while (h >= 360.0) h = h - 360.0; /* Need it from 0-360, make 360 = 0 */

	  h = h / 60.0; /* Make it a value between 0 - 5.999999 */

	  integer_hue = h; /* Truncate Hue to a integer from 0-5 */
	  /* XXX original code was *Hue - (float)integer_hue  */ 
	  fractional_hue = h - (float)integer_hue; /* Get the fractional part */

	  p = *Value * (1.0 - *Saturation);
	  q = *Value * (1.0 - (*Saturation * fractional_hue));
	  t = *Value * (1.0 - (*Saturation * (1.0 - fractional_hue)));

	  switch (integer_hue)
	  {
	  case 0:
	  case 6:
	       *Red   = *Value;
	       *Green = t;	
	       *Blue  = p;	
	       break;	 	
	  case 1: 	
	       *Red   = q;	
	       *Green = *Value;
	       *Blue  = p;	
	       break;	 	
	  case 2: 	
	       *Red   = p;	
	       *Green = *Value;
	       *Blue  = t;	
	       break;	 	
	  case 3: 	
	       *Red   = p;	
	       *Green = q;	
	       *Blue  = *Value;
	       break;	 	
	  case 4: 	
	       *Red   = t;	
	       *Green = p;	
	       *Blue  = *Value;
	       break;	 	
	  case 5: 	
	       *Red   = *Value;
	       *Green = p;	
	       *Blue  = q;	
	       break;
	  }
     }
}


void RGB_to_HLS ( Red, Green, Blue, Hue, Lightness, Saturation)
float *Red, *Green, *Blue, *Hue, *Lightness, *Saturation;

/*
 *  RGB_to_HLS - converts RGB values as input into HLS as output.
 *
 *  All parameters are passed by reference and are floating point.
 *
 *  RGB are read only, HLS are write only.
 *
 *  A Saturation of 0 returns -1.0 as the Hue, otherwise Hue is from 0 - 360
 *
 *
 *  ** NOTE ** This routine follows the UIS convention of RED at 0°
 *    instead of the industry standard convention of locating
 *    BLUE at 0°. To convert to industry standards, add 120°
 *    to the Hue result.
 *    
 */
{
     float max_value, min_value,
	  color_span,
	  red_content, green_content, blue_content;
    /*
     * Get the max and min values for RGB
     *
     */
     max_value = max3( *Red, *Green, *Blue);
     min_value = min3( *Red, *Green, *Blue); 

    /*
     * Compute Lightness
     *
     */
     *Lightness = (max_value + min_value) / 2;

     /* XXX Again, the scanned copy used '=' instead of '==' for comparison. */
     if (max_value == min_value)
     {
	 /*
	  * This is Red = Green = Blue: anachromatic
	  *
	  * A Saturation of zero results in UIS$C COLOR UNDEFINED for Hue
	  * which is a -1.0 in floating point. - -
	  *
	  */
	  *Saturation =  0.0; 
	  *Hue	      = -1.0;
     }
     else
     {
	  color_span    = max_value - min_value;

	 /*
	  * Compute Saturation
	  *
	  */
	  if (*Lightness < 0.5)
	  {
	       *Saturation = color_span / (max_value + min_value);
	  }
	  else
	  {
	       *Saturation = color_span / (2.0 - max_value - min_value);
	  }

	 /*
	  * Compute Hue
	  *
	  */
	  red_content   = (max_value - *Red) / color_span;  
	  green_content = (max_value - *Green) / color_span;
	  blue_content  = (max_value - *Blue) / color_span; 
	  if (*Red == max_value)
	  {
	       *Hue = blue_content - green_content;
	  }
	  else
	  {
	       if (*Green == max_value)
	       {
		    *Hue = 2.0 + red_content - blue_content;
	       }
	       else
	       {
		    *Hue = 4.0 + green_content - red_content;
	       }
	  }
	  *Hue = *Hue * 60.0;
	  while (*Hue < 0.0) *Hue = *Hue + 360.0;
     }
}

void HLS_to_RGB( Hue, Lightness, Saturation, Red, Green, Blue)
float *Hue, *Lightness, *Saturation, *Red, *Green, *Blue;
/*
 *  HLS_to_RGB - converts HSV values as input into RGB as output.
 *
 *  All parameters are passed by reference and are floating point.
 *
 *  HLS are read only, RGB are write only.
 *
 *  ** NOTE ** This routine follows the UIS convention of RED at 0°
 *    instead of the industry standard convention of locating
 *    BLUE at 0°. To convert to industry standards, the input
 *    Hue should have 120° subtracted from it.
 *
 */
{
     float m1, m2;

     if (*Lightness < 0.5)
     {
	  m2 = *Lightness * (1.0 + *Saturation);
     }
     else
     {
	  m2 = *Lightness + *Saturation - (*Lightness * *Saturation);
     }
     m1 = (*Lightness * 2.0) - m2;

     /* XXX This is the one any only time the scan uses '==' for comparison. */
     if (*Saturation == 0)
     {
	 /*
	  *  Strictly speaking, a Saturation of 0 means that Hue should	
	  *  contain UIS$C_COLOR_UNDEFINED, but the standard industry	
	  *  practice is to ignore Hue if the Saturation is o. The UIS	
	  *  routine will signal an error if Hue is not -1.0, this will not.
	  *
	  * This is the anachromatic case, where R = G = B = Lightness.
	  */
	  *Red   = *Lightness;
	  *Green = *Lightness;
	  *Blue  = *Lightness;
     }
     else
     {
	  *Red   = VALUE( m1, m2, *Hue + 120.0);
	  *Green = VALUE( m1, m2, *Hue);
	  *Blue =  VALUE( m1, m2, *Hue - 120.0);
     }
}

static float VALUE( n1, n2, Hue)
float n1, n2, Hue;
{
     while (Hue <    0.0) Hue += 360.0; /* Need a positive angle */
     while (Hue >= 360.0) Hue -= 360.0; /* Need it from 0-360 */
     if (Hue < 60.0) return (n1 + (((n2 - n1) * Hue) / 60.0));
     else
	  if (Hue < 180.0) return (n2);
	  else
	       if (Hue < 240.0) return (n1 + (((n2 - n1) * (240.0 - Hue)) / 60.0));
	       else return (n1);
}

/* End of color_conversion module */
