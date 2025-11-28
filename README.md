# Tube Adapter (OpenSCAD)

This repository contains `TubeAdapter.scad`, an OpenSCAD script to generate tapered adapters that fit inside or outside of a pipe. The adapter is modeled by creating an outer tapered shape and subtracting a slightly smaller inner shape to form the wall thickness.

**Prerequisites**

- OpenSCAD is required to view, preview, and render `TubeAdapter.scad`. Download OpenSCAD from: https://www.openscad.org/

**Quick Summary**
- **File:** `TubeAdapter.scad` — produces an adapter with two tapered ends and a mid section.
- **Purpose:** Create adapters that fit inside or outside of a pipe, with configurable outside diameters, tapered lengths, wall thickness, taper direction, and units.

**How it works**
- The script accepts user inputs (diameters, taper direction, tapered lengths, thickness, taper angle) and optionally interprets them as inches or millimeters (`UseInches` flag). Inputs are converted to millimeters internally.
- Geometry is built from a set of circular cross-sections and `hull()` operations to create smooth conical transitions for Side A, a mid-section, and Side B. The outer shell is generated from the outside diameters; an inner cutout (outer minus `2*Thickness`) is subtracted using `difference()` to produce the hollow adapter.
- Taper direction is controlled by `SideA_TaperOut` and `SideB_TaperOut`. When true the end near the center is larger (the taper expands toward the middle); when false the taper narrows toward the middle. Typically, taper out would be true for an adapter that fits inside a larger pipe; taper out would be false for an adapter that would have a pipe inserted into it.

**Main parameters (top of `TubeAdapter.scad`)**
- `UseInches`: `true` or `false` — set to `true` to input values in inches (converted to mm internally).
- `SideA_TaperOut`, `SideB_TaperOut`: booleans that determine taper direction (outward `true`).
- `SideA_Diameter`, `SideB_Diameter`: Diameters at each end. Interpreted as an inside diameter if taper out is false or an outside diameter if taper is true.
- `SideA_Length`, `SideB_Length`: lengths of the tapered sections.
- `Taper`: taper angle in degrees (used with `tan()` to compute diameter change across the tapered length).
- `Thickness`: wall thickness; inner diameters are computed as `outer - 2*Thickness`.

**Implementation notes**
- The script sets `$fn` for smooth circles and uses a small `epsilon` to avoid degenerate hulls when building the model.
- `mm_per_inch = 25.4` is used only for unit conversion; the geometry is created in millimeters.
- The adapter is composed by three hull regions (Side A, mid-section, Side B) joined with `union()`; then the inner cutout is subtracted with `difference()`.

**Render / Export**
- Open `TubeAdapter.scad` in OpenSCAD.
- Edit the variables at the top of `TubeAdapter.scad` to the desired diameters/lengths and set `UseInches` appropriately.
- Preview (F5) → Render (F6) → Export STL.

**License & Credit**
- Original work: Copyright 2023, CompuPhase, Thiadmer Riemersma
- This repository includes modifications by `tippmar`.
- License: Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0). See https://creativecommons.org/licenses/by-sa/4.0/.
