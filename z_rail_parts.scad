include <config.scad>
use <GDMUtils.scad>
use <sliders.scad>
use <joiners.scad>
use <acme_screw.scad>

$fa=2;
$fs=2;

// connectby valid options: "", "fwd", "back"
module z_rail(explode=0, connectby="")
{
	side_joiner_len = 2;
	l = rail_length - 2 * printer_slop;

	up(
		(connectby=="fwd")? -rail_height/2 :
		(connectby=="back")? -rail_height/2 :
		0
	) back(
		(connectby=="back")? -l/2 :
		(connectby=="fwd")? l/2 :
		0
	) {
		color([0.9, 0.7, 1.0])
		prerender(convexity=20)
		union() {
			difference() {
				union() {
					// Bottom.
					up(rail_thick/2) yrot(90)
						sparse_strut(h=rail_width, l=l-0.1, thick=rail_thick, maxang=45, strut=10, max_bridge=500);

					// Walls.
					zrot_copies([0, 180]) {
						up(rail_height/2+0.05) {
							right((rail_spacing+joiner_width)/2) {
								if (wall_style == "crossbeams")
									sparse_strut(h=rail_height+0.1, l=l-10, thick=joiner_width, strut=5);
								if (wall_style == "thinwall")
									thinning_wall(h=rail_height+0.1, l=l-10, thick=joiner_width, strut=5, bracing=false);
								if (wall_style == "corrugated")
									corrugated_wall(h=rail_height, l=l-10, thick=joiner_width, strut=5);
							}
						}
					}

					// Rails.
					xspread(rail_spacing+joiner_width) {
						up(rail_height+groove_height/2-0.05) {
							rail(l=l, w=joiner_width, h=groove_height);
						}
					}

					// Screw rack
					teeth_d = lifter_screw_pitch / 3.2;
					ang = acos(1 - 2*teeth_d/lifter_screw_diam);
					teeth_h = sin(ang) * lifter_screw_diam + 6;
					render(convexity=10)
					difference() {
						xspread(lifter_screw_diam) {
							up(rail_height/2) {
								sparse_strut(h=rail_height, l=l, thick=2.0*teeth_d, strut=platform_thick);
							}
							up(rail_height+groove_height/2) {
								cube(size=[2*teeth_d, l, teeth_h], center=true);
							}
						}
						xspread(2*printer_slop) {
							up(rail_height+groove_height/2) {
								xrot(90) {
									acme_threaded_rod(
										d=lifter_screw_diam,
										l=l+0.1,
										thread_depth=lifter_screw_pitch/3.2,
										pitch=lifter_screw_pitch,
										thread_angle=lifter_screw_angle
									);
								}
							}
						}
					}

					// Side Supports
					up(rail_height/4) {
						yspread(l-2*5-5) {
							difference() {
								cube(size=[rail_width-joiner_width, 4, rail_height/2], center=true);
								xspread(rail_width/3, n=3) {
									cube(size=[16, 11, 12], center=true);
								}
								up(rail_height*3/4 + groove_height/2) {
									xrot(90) {
										cylinder(d=lifter_screw_diam+10, h=10, center=true);
									}
								}
							}
						}
					}

					// Side wiring access hole frame
					if (wall_style == "corrugated") {
						up(10/2+rail_thick) {
							xspread(rail_width-joiner_width) {
								yspread(motor_rail_length-2*28) {
									cube(size=[joiner_width, 16+4, 10+4], center=true);
								}
							}
						}
					}
				}

				// Clear space for joiners.
				up(rail_height/2) {
					joiner_quad_clear(xspacing=rail_spacing+joiner_width, yspacing=l-0.1, h=rail_height, w=joiner_width, clearance=5, a=joiner_angle);
				}


				// Clear space for Side half joiners
				up(rail_height/2/2) {
					yspread(l-2*joiner_width-0.05) {
						zring(r=rail_spacing/2+joiner_width+side_joiner_len-0.05, n=2) {
							zrot(-90) {
								chamfer(chamfer=3, size=[joiner_width, 2*(side_joiner_len+joiner_width/2), rail_height/2], edges=[[0,0,0,0], [1,1,0,0], [0,0,0,0]]) {
									half_joiner_clear(h=rail_height/2, w=joiner_width, a=joiner_angle);
								}
							}
						}
					}
				}

				// Side wiring access hole
				if (wall_style != "crossbeams") {
					up(10/2+rail_thick) {
						xspread(rail_width-joiner_width) {
							yspread(motor_rail_length-2*28) {
								cube(size=[joiner_width+1, 16, 10], center=true);
							}
						}
					}
				}

				// Shrinkage stress relief
				up(rail_thick/2) {
					yspread(17.5, n=7) {
						cube(size=[rail_width+1, 1, rail_thick-2], center=true);
					}
					xspread(22, n=5) {
						yspread(l-10) {
							cube(size=[1, 17.5*2, rail_thick-2], center=true);
						}
					}
				}
			}

			// Side half joiners
			up(rail_height/2/2) {
				yspread(l-20.05) {
					zring(r=rail_spacing/2+joiner_width+side_joiner_len+0.1, n=2) {
						zrot(-90) {
							chamfer(chamfer=3, size=[joiner_width, 2*(side_joiner_len+joiner_width/2), rail_height/2], edges=[[0,0,0,0], [1,1,0,0], [0,0,0,0]]) {
								half_joiner2(h=rail_height/2, w=joiner_width, l=side_joiner_len+joiner_width/2, a=joiner_angle);
							}
						}
					}
				}
			}

			// Snap-tab joiners.
			up(rail_height/2) {
				xspread(rail_spacing+joiner_width) {
					yrot(180) {
						fwd(l/2) xrot(180) joiner(h=rail_height, w=joiner_width, l=6, a=joiner_angle);
						back(l/2) joiner(h=rail_height, w=joiner_width, l=6, a=joiner_angle);
					}
				}
			}
		}
		up(rail_height/2) {
			fwd(l/2+explode) {
				if ($children > 0) children(0);
			}
			back(l/2+explode) {
				if ($children > 1) children(1);
			}
		}
		up(rail_height/2/2) {
			back(l/2-10) {
				left(rail_spacing/2+joiner_width+side_joiner_len) {
					if ($children > 2) children(2);
				}
				right(rail_spacing/2+joiner_width+side_joiner_len) {
					if ($children > 3) children(3);
				}
			}
		}
	}
}
//!z_rail();



module z_rail_parts() { // make me
	z_rail();
}



z_rail_parts();



// vim: noexpandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap

