//determines what type of object we're making.
mode = "tieclip";

thickness = 1.5;
bondlength = 5.0;
thickness2 = bondlength / 2.5;
heptradius = bondlength * 7 / 6;
pentradius = bondlength * 5.3 / 6;
ringthickness = .45;

heptnormal = cos(180 / 7) * heptradius;
heptsecant = sin(180 / 7) * heptradius;
hexnormal = cos(30) * bondlength;
hexsecant = sin(30) * bondlength;
pentnormal = cos(180 / 5) * pentradius;

heptcenter = heptnormal + hexnormal;

heptpent = heptnormal + pentnormal;
heptpent_x = cos(180/7) * heptpent + heptcenter;
heptpent_y = sin(180/7) * heptpent;

tailend = heptpent + pentradius;
tailend_x = cos(180/7) * tailend + heptcenter;
tailend_y = sin(180/7) * tailend;

///////////////////////////////////
module hole(){
	//translate([-0.5, -bondlength * 0.2, -1]){
	//	translate([0.5, 0, 0])
	//		cylinder(h = 3, r=0.5, $fn=20);
	//	translate([0.5, bondlength * 0.4, 0])
	//		cylinder(h = 3, r=0.5, $fn=20);

	//	cube(size=[1, bondlength * 0.4, 3]);
	//}
}

bondwidth = bondlength * 0.4;

module bond(angle, multiplier=1, heft = thickness){
	length = bondlength * multiplier;
	rotate([0,0,angle])
	{
		translate([-bondwidth/2, 0, (thickness - heft)/2])
		{
			//endcaps
			translate([bondwidth/2, 0, 0])
				cylinder(h=heft, r=bondwidth/2, $fn=20);

			translate([bondwidth/2, length, 0])
				cylinder(h=heft, r=bondwidth/2, $fn=20);

			cube(size=[bondwidth, length, heft]);
		}

		translate([0,length,0])
			children();
	}
}

ringcount = 40;

module ring(){
	for(i = [0:ringcount])
		rotate([0,0,360/ringcount * i])
			translate([-ringthickness/2,-bondlength/3,thickness/2])
				rotate([0,90,0])
					cylinder(h=ringthickness, r=thickness2/2, $fn=40);
}

module attachment(angle){
	cheight = 2 * bondlength / 5;
	difference(){
		bond(angle);
		rotate([0,0,angle])
			translate([0,bondlength,(thickness - cheight) / 2])
				cylinder(h=cheight, r=bondlength/3, $fn=60);
	}
	rotate([0,0,angle])
		translate([0,bondlength,0])
			ring();
}

st = 16/3;
snakelength = bondwidth * 25;

module snake(angle){
	rotate([0,0,angle])
	for(i = [0:200])
	{
		assign(fraction = i/200)
			//the formula -16/3 x^3 + 8x^2 -3x was determined using CALCULUS.
			translate([-0.5 * bondwidth,fraction * snakelength, bondwidth * (fraction + 
				(-st * fraction * fraction * fraction + 8 * fraction * fraction - 3 * fraction))])
				cube(size=[bondwidth * (1 + 3 * fraction),snakelength / 200 + 0.2, bondwidth * (1 - fraction * 0.8)]);
	}
}

module clipback(){
	translate([0,0,-thickness * 1.7])
	{
		bond(-180, 0.5, thickness * 3)
			translate([0,0,-thickness * 1])
				snake(-15);
	}
}

///////////////////////////////////

//6-7-5 ring system
minkheight = thickness2 - thickness;
vdisp = -minkheight / 2;

difference(){
	union(){
		//build the hexagon
		rotate(a=[0,0,30])
			translate([0,0,vdisp])
				difference(){
					minkowski(){
						cylinder(h = minkheight, r=bondlength, $fn=6);
						cylinder(h = thickness, r = bondwidth/2, $fn=20);
					}
					translate([0,0,thickness2])
						minkowski(){
							cylinder(h = thickness, r=bondlength-bondwidth, $fn = 6);
							sphere(r=minkheight, $fn=20);
						}
				}

		//build the heptagon
		translate([heptcenter, 0, vdisp])
			difference(){
				minkowski(){
					cylinder(h = minkheight, r=heptradius, $fn=7);
					cylinder(h = thickness, r = bondwidth/2, $fn=20);
				}
				translate([0,0,thickness2])
					minkowski(){
						cylinder(h = thickness, r=heptradius-bondwidth, $fn = 7);
						sphere(r=minkheight, $fn=20);
					}
			}

		//build the pentagon
		translate([heptpent_x, heptpent_y, vdisp])
			rotate(a=[0,0, 180 / 7])
			difference(){
				minkowski(){
					cylinder(h = minkheight, r=pentradius, $fn=5);
					cylinder(h = thickness, r = bondwidth/2, $fn=20);
				}
				translate([0,0,thickness2])
					minkowski(){
						cylinder(h = thickness, r=pentradius-bondwidth, $fn = 5);
						sphere(r=minkheight, $fn=20);
					}
			}
	}

	translate([hexnormal, 0, 0])
		hole();

	translate([heptpent + heptnormal, heptsecant, 0])
		rotate(a=[0,0,180/7])  //fudge factor
			translate([0,-0.5,0])	//fudge factor
				hole();
}

//carboxy
ang14 = 180/14;
translate([hexnormal + heptnormal - heptradius * sin(ang14), heptradius * cos(ang14), 0])
	rotate(ang14)
		bond();

// 8-methyl

translate([-hexnormal, -hexsecant, 0])
	bond(120);

// 2-tail

translate([tailend_x, tailend_y, 0])
	bond(-180/7 - 180/5)
		bond(-60)
			if(mode=="pendant")
			{
				attachment(60);
			}	else
			{
				bond(60)
					if (mode=="tieclip")
						clipback();
			}


// 7-glyco

translate([-hexnormal, hexsecant, 0])
			bond(60)
					bond(-60)
						rotate([0,0,140]){
								bond(-60, 1, thickness2)
										bond(60,0.8, thickness2)
												bond(-100,1.4, thickness2);	
								bond(-100,1.4,thickness2)
										bond(100, 0.8, thickness2)
												bond(-60, 1, thickness2)
														bond(40)
																if (mode=="pendant")
																{
																	attachment(-60);
																} else {
																	bond(-60);
																}
						}
