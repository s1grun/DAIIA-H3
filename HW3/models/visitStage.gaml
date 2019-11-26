/***
* Name: visitStage
* Author: sigrunarnasigurdardottir
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model visitStage


/* Insert your model definition here */

global{
	int stage_color<-30;
	list<string> genre <- ["rock", "pop", "folks", "jazz"];
	init {
		create Guests number: 50;
		loop i from:0 to:3{
			create Stage number: 1 with:(stage_color:rgb(rnd(255),rnd(255),rnd(255)),type:genre[i]);
		}
	}
}


species Guests skills:[fipa,moving]{
	float betterLightShow <- rnd(0.1, 1.0);
	float betterVisuals <- rnd(0.2, 1.0);
	float goodSoundSystem <- rnd(0.3, 1.0);
	float famous <- rnd (0.0, 1.0);
	float popMusic <- rnd(0.0, 1.0);
	float rockMusic <- rnd(0.0, 1.0);
	float folksMusic <- rnd(0.0, 1.0);
	float jazzMusic <- rnd(0.0, 1.0);
	Stage fav_stage;
	point guestLocation <- nil;
	float util<-0.0;
	list act_util_list <- [];
	int status <- 0;
	rgb my_color <- #blue;
	
	
	aspect {
		draw sphere(1) color:my_color;
	}
	init{
		guestLocation<-location;
	}
	

	
	reflex goToStage when: !(empty(informs)) {
		loop msg over: informs{
//			message msg <- informs[0];
			if(msg.contents[0]='start'){
				Stage informingConcert <- Stage(agent(msg.sender));
//				write name+ " Receive inform from: " + informingConcert;
				string lightstr <- msg.contents[1];
				float light <- float(lightstr);
				string visualstr <- msg.contents[2];
				float visual <- float(visualstr);
				float sound <- float(msg.contents[3]);
				float famous1 <- float(msg.contents[4]);
				float rock <- float(msg.contents[5]);
				float pop <- float(msg.contents[6]);
				float folks <- float(msg.contents[7]);
				float jazz <- float(msg.contents[8]);
				
				
				do utility(light, visual, sound, famous1, rock, pop, folks, jazz, informingConcert);
				
				status<-1;
//				fav_stage.guestsList <+ self;
				my_color <- fav_stage.stage_color;
//				write name + act_util_list;
//				write name+ " Going to: " + fav_stage;
			}else{
//				write name +"reveice :"+msg.contents[0];
				status<-3;
				Stage sender <- Stage(agent(msg.sender));
				my_color <- #blue;
//				write act_util_list;
				remove [fav_stage,util] from:act_util_list;
//				write act_util_list;
				if(length(act_util_list)>1){
					util <- float(last(act_util_list)[1]);
					fav_stage <- last(act_util_list)[0];
					my_color <- fav_stage.stage_color;
					status <-1;
				}
				
				
			}	
		}
		
	}
	
	
	reflex goingToStage when: status=1 {
		do goto target:fav_stage;
	}
	
	
	reflex atStage when: fav_stage != nil and (location distance_to fav_stage) <5 and status=1{
		do wander;
		status<-2;
	}
	

	
	
	reflex goToMyLocation when: status=3 {
		do goto target:guestLocation;
		
	}
	
	reflex atMyLocation when: (location = guestLocation) {
		status <- 0;
	}
	
	
	
	action utility(float light, float visual, float sound, float famous1, float rock, float pop, float folks, float jazz, Stage sender) {
		float tmp <-  betterLightShow * light + betterVisuals * visual + goodSoundSystem * sound + famous * famous1 + rockMusic * rock + popMusic * pop + folksMusic * folks + jazzMusic * jazz;
//		if tmp > util{
//			util <- tmp;
//			fav_stage <- sender;
//		}
		act_util_list <+ [sender,tmp];
		act_util_list <- act_util_list sort_by (float(each[1]));
		util <- float(last(act_util_list)[1]);
		fav_stage <- last(act_util_list)[0];
		
	}
	
}

species Stage skills:[fipa]{
	float betterLightShow <- rnd(0.0, 1.0);
	float betterVisuals <- rnd(0.0, 1.0);
	float goodSoundSystem <- rnd(0.0, 1.0);
	float famous <- rnd (0.0, 1.0);
	float popMusic <- rnd(0.0, 1.0);
	float rockMusic <- rnd(0.0, 1.0);
	float folksMusic <- rnd(0.0, 1.0);
	float jazzMusic <- rnd(0.0, 1.0); 
	string type;
	int whenToStart<-1;
	int whenToEnd<-0;
//	list guestsList;
	bool ongoing <- false;
	
	rgb stage_color;
	
	aspect { 
		if(ongoing = true){
			draw cube(4) color:stage_color;
		}else{
			draw cube(4) color:#gray;
		}
		
	}
	
	init{
		if(type="pop"){
			popMusic <- 0.9;
			rockMusic <- 0.0;
			folksMusic <- 0.0;
			jazzMusic <- 0.0;
		}else if(type="rock"){
			popMusic <- 0.0;
			rockMusic <- 0.9;
			folksMusic <- 0.0;
			jazzMusic <- 0.0;
		}else if(type="folks"){
			popMusic <- 0.0;
			rockMusic <- 0.0;
			folksMusic <- 0.9;
			jazzMusic <- 0.0;
		}else if(type="jazz"){
			popMusic <- 0.0;
			rockMusic <- 0.0;
			folksMusic <- 0.0;
			jazzMusic <- 0.9;
		}
	}
	
	
	reflex stageHostingConcert when: (time = whenToStart and ongoing=false)  {
		
//		if (flip(0.2)){
			betterLightShow <- rnd(0.0, 1.0);
	 		betterVisuals <- rnd(0.0, 1.0);
			goodSoundSystem <- rnd(0.0, 1.0);
			famous <- rnd (0.0, 1.0);
			write name + ": concert is starting soon";
			do start_conversation with: [to :: list(Guests), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['start', betterLightShow, betterVisuals, goodSoundSystem, famous, rockMusic, popMusic, folksMusic, jazzMusic] ];
			whenToEnd <-int(time+10*rnd(10,20));
			ongoing <- true;
//		}
		
	}
	
	reflex endConcert when: (time=whenToEnd) and ongoing = true{
		
		do start_conversation with: [to ::list(Guests), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['end'] ];
		
		write name + ' eeeeeeeeeend concert';
		whenToStart <- int(time+10*rnd(1,5));
		ongoing <- false;
		
	}
	
	
}



experiment visitStage type:gui {
	output {
		display visitStage type:opengl{
			species Guests;
			species Stage;
		}
	}
}