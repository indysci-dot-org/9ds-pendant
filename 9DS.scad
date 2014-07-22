thickness = 1.5;
bondlength = 5;
heptradius = bondlength * 7 / 6;
pentradius = bondlength * 5.3 / 6;

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
	translate([-0.5, -bondlength * 0.2, -0.05]){
		translate([0.5, 0, 0])
			cylinder(h = thickness + 0.1, r=0.5, $fn=20);
		translate([0.5, bondlength * 0.4, 0])
			cylinder(h = thickness + 0.1, r=0.5, $fn=20);

		cube(size=[1, bondlength * 0.4, thickness + 0.1]);
	}
}

bondwidth = bondlength * 0.4;

module bond(angle, multiplier=1){
	length = bondlength * multiplier;
	rotate([0,0,angle])
	{
		translate([-bondwidth/2, 0, 0])
		{
			//endcaps
			translate([bondwidth/2, 0, 0])
				cylinder(h=thickness, r=bondwidth/2, $fn=20);

			translate([bondwidth/2, length, 0])
				cylinder(h=thickness, r=bondwidth/2, $fn=20);

			cube(size=[bondwidth, length, thickness]);
		}

		translate([0,length,0])
			children();
	}
}


ringthickness = 0.3;

module ring(){
	for(i = [0:60])
		rotate([0,0,360/60 * i])
			translate([-ringthickness/2,-bondlength/3,thickness/2])
				rotate([0,90,0])
					cylinder(h=ringthickness, r=bondlength/5, $fn=40);
}

module ringsubtraction(){
	cheight = 2 * bondlength / 5;
	difference(){
		translate([0,0,(thickness - cheight) / 2])
			cylinder(h=cheight, r=bondlength/3, $fn=60);
		for(i = [0:60])
			rotate([0,0,360/60 * i])
				translate([-ringthickness/2,-bondlength/3,thickness/2])
					rotate([0,90,0])
						cylinder(h=ringthickness, r=bondlength/5, $fn=40);
	}
}

module attachment(angle){
	difference(){
		bond(angle);
		rotate([0,0,angle])
			translate([0,bondlength,0])
				ringsubtraction();
	}
	rotate([0,0,angle])
		translate([0,bondlength,0])
			ring();
}

///////////////////////////////////

//6-7-5 ring system

difference(){
	union(){
		//build the hexagon
		rotate(a=[0,0,30]){
			cylinder(h = thickness, r=bondlength, $fn=6);
		}

		//build the heptagon
		translate([heptcenter, 0, 0]){
			cylinder(h = thickness, r=heptradius, $fn=7);
		}

		//build the pentagon
		translate([heptpent_x, heptpent_y, 0])
		rotate(a=[0,0, 180 / 7]){
			cylinder(h = thickness, r=pentradius, $fn=5);
		}
	}

	translate([hexnormal, 0, 0])
		hole();

	translate([heptpent + heptnormal, heptsecant, 0])
		rotate(a=[0,0,180/7])  //fudge factor
			translate([0,-0.5,0])	//fudge factor
				hole();
}

// 8-methyl

translate([-hexnormal, -hexsecant, 0])
	bond(120);

// 2-tail

translate([tailend_x, tailend_y, 0])
	bond(-180/7 - 180/5)
		bond(-60)
			attachment(60);


// 7-glyco

translate([-hexnormal, hexsecant, 0])
			bond(60)
					bond(-60)
						rotate([0,0,140]){
								bond(-60)
										bond(60,0.8)
												bond(-100,1.4);	
								bond(-100,1.4)
										bond(100, 0.8)
												bond(-60)
														bond(40)
																attachment(-60);
						}
