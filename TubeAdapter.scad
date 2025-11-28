/* Tube size adapter

  Generates a 3D model of an adapter for pipe or tubing with different diameters at each end, with an angled transition between the diameters. The adapter is tapered (in or out) at each end to allow for a snug fit. The length of each section is customizable.




   Copyright 2023, CompuPhase, Thiadmer Riemersma
   This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License
   (https://creativecommons.org/licenses/by-sa/4.0/).

   Updated 28/11/25 tippmar -
   * Added input to control taper direction at each end.
   * Diameter is interpreted as inside if taper inward; outside diameter if taper out
   * Added an option to specify input units in metric or inches.
*/

/* [Options] */

// INPUT UNITS: Set true to enter dimensions in inches, false to enter in mm.
UseInches = true;

// Side A Taper direction: set true to taper OUTWARD, false to taper INWARD.
SideA_TaperOut = true;

// Side B Taper direction: set true to taper OUTWARD, false to taper INWARD.
SideB_TaperOut = true;

// Side A diameter: Must be the larger diameter value. Interpreted as an OUTSIDE diameter when `SideA_TaperOut` is true, otherwise interpreted as an INSIDE diameter.
SideA_Diameter = 3.93;

// Side B diameter: Must be the smaller diameter value. Interpreted as an OUTSIDE diameter when `SideB_TaperOut` is true, otherwise interpreted as an INSIDE diameter.
SideB_Diameter = 2.46;

// Side A Length
SideA_Length = 3;

// Side B Length
SideB_Length = 2;

// Taper angle in degrees
Taper = 1.5;

// Wall thickness
Thickness = 0.125;

/* [Hidden] */
epsilon = 0.05;
$fn = 100;


// Convert inputs to internal units (mm) if requested. Do NOT overwrite user inputs;
mm_per_inch = 25.4; // mm per inch — used only for conversion below
SideA_input_mm = UseInches ? SideA_Diameter * mm_per_inch : SideA_Diameter; // input value (interpreted per taper flag)
SideB_input_mm = UseInches ? SideB_Diameter * mm_per_inch : SideB_Diameter; // input value (interpreted per taper flag)
SideA_Length_mm = UseInches ? SideA_Length * mm_per_inch : SideA_Length;
SideB_Length_mm = UseInches ? SideB_Length * mm_per_inch : SideB_Length;
Thickness_mm = UseInches ? Thickness * mm_per_inch : Thickness;

// Interpret inputs according to taper direction:
// - If Side?_TaperOut is true, the provided value is an OUTSIDE diameter.
// - If Side?_TaperOut is false, the provided value is an INSIDE diameter.
// Compute both outer and inner diameters (mm) for each side.
SideA_OuterDiameter_mm = SideA_TaperOut ? SideA_input_mm : (SideA_input_mm + 2*Thickness_mm);
SideA_InnerDiameter_mm = SideA_TaperOut ? (SideA_input_mm - 2*Thickness_mm) : SideA_input_mm;
SideB_OuterDiameter_mm = SideB_TaperOut ? SideB_input_mm : (SideB_input_mm + 2*Thickness_mm);
SideB_InnerDiameter_mm = SideB_TaperOut ? (SideB_input_mm - 2*Thickness_mm) : SideB_input_mm;

MidLength_mm = (SideA_OuterDiameter_mm - SideB_InnerDiameter_mm) / 2;  /* for a roughly 45 degree angle */

module adapter_shape(SideA_diameter, SideB_diameter, SideA_Length, SideB_Length, Cutout, SideA_taper_out=false, SideB_taper_out=false) {
  union() {
    // sect_a_tail is the diameter at the inner end of the Side A tapered section.
    // If SideA_taper_out is true, Side A increases toward the center; otherwise it decreases.
    sect_a_tail = SideA_taper_out ? SideA_diameter + (SideA_Length * tan(Taper)) : SideA_diameter - (SideA_Length * tan(Taper));
    // sect_b_tail: mirror behavior for Side B
    sect_b_tail = SideB_taper_out ? SideB_diameter + (SideB_Length * tan(Taper)) : SideB_diameter - (SideB_Length * tan(Taper));
    epsilon_spacing = Cutout ? epsilon : 0;
    delta = Cutout ? sqrt(2) * Thickness_mm / 2 : 0;
    /* side A */
    hull() {
      translate([0, 0, -epsilon_spacing])
        cylinder(d = SideA_diameter, h = epsilon);
      translate([0, 0, SideA_Length - delta])
        cylinder(d = sect_a_tail, h = epsilon);
    }
    /* mid section */
    hull() {
      translate([0, 0, SideA_Length - delta])
        cylinder(d = sect_a_tail, h = epsilon);
      translate([0, 0, SideA_Length + MidLength_mm - delta])
        cylinder(d = sect_b_tail, h = epsilon);
    }
    /* side B */
    hull() {
      translate([0, 0, SideA_Length + MidLength_mm - delta])
        cylinder(d = sect_b_tail, h = epsilon);
      translate([0, 0, SideA_Length + MidLength_mm + SideB_Length])
        cylinder(d = SideB_diameter, h = epsilon + epsilon_spacing);
    }
  }
}

difference() {
  /* outer shape */
  adapter_shape(SideA_OuterDiameter_mm, SideB_OuterDiameter_mm, SideA_Length_mm, SideB_Length_mm, false, SideA_TaperOut, SideB_TaperOut);
  /* inner shape */
  adapter_shape(SideA_InnerDiameter_mm, SideB_InnerDiameter_mm, SideA_Length_mm, SideB_Length_mm, true, SideA_TaperOut, SideB_TaperOut);
}