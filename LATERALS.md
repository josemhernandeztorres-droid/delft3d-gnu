# 2D laterals and meshes made for other engines

Notes from running a river mesh built for another shallow-water engine (210 833 triangles, 100 lateral inflows,
64 outflow boundaries, 2 h) on this build. Configuration only; no source change.

## Laterals are sampled at the end of each user time step

`flow_init_usertimestep.f90:60-66` advances `time_user` before `set_external_forcings(tim1fld)`. A lateral discharge
is therefore read at the END of each user time step (`DtUser`) and held for the whole step, which shifts the
hydrograph earlier by `DtUser/2`. On a rising hydrograph the run receives more water than the hydrograph carries.

Measured on a 300 s probe: with `DtUser = 300` the laterals delivered 253 401 m³, with `DtUser = 60` 186 170 m³; the
integral of the hydrographs is 169 363 m³. Over the full 2 h run the excess was 232 645 m³ (+0.8 %), equal to
`DtUser/2 × (Q(end) − Q(start))` = 232 646 m³.

This is the engine's design (identical with Intel builds), so it is handled outside the source:

- shift the time column of the lateral `.bc` files by `−DtUser/2`, so that the value read at the end of each user
  step is the mid-step value (exact for a piecewise-linear hydrograph);
- use a short `DtUser` (60 s);
- check `water_balance_laterals_in` against the integral of the hydrographs (we fail the run above 0.1 %).

## Other settings

- `Cosphiutrsh = 1`: a mesh not built for D-Flow FM is not orthogonal (29 of 315 506 edges with cos > 0.5) and the
  run aborts otherwise.
- `Removesmalllinkstrsh = 0`: otherwise 3 993 small links are removed.
- One `[Boundary]` per chained polyline: the reader takes one polyline per `.pli`.
- `bedlevel` in an `[Initial]` block of the initial-fields file, not in `[Parameter]`.
- Network without a CRS name (`Unknown projected`, EPSG 0): PROJ rejects unknown names.
- 2D laterals as polygons: D-Flow FM takes the cells whose centre is inside and splits Q by area (`s1ini.f90:200`).
