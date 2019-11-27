/***
* Name: globalUtility
* Author: weng
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model globalUtility

/* Insert your model definition here */

global{
	int stage_color<-30;
	list<string> genre <- ["rock", "pop", "folks", "jazz"];
	Guests leader;
	map<string,int> stage_population<-[];
	float current_global_util<-0.0;
	float new_global_util<-0.0;
	
	init {
		create Guests number: 50 ;
		loop i from:0 to:3{
			create Stage number: 1 with:(stage_color:rgb(rnd(255),rnd(255),rnd(255)),type:genre[i]);
			add  0 at:Stage[i].name to: stage_population;
		}
//		add 1 at:Stage[0].name to: global_util;
//		write stage_population;
		leader <- Guests[0];
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
	int status <- 0; //4 - waiting for leader coordination;
	rgb my_color <- #blue;
	float like_crowd <- rnd(0.0,1.0) ;
	int leader_msg<-0;
	
	
	
	aspect {
		draw sphere(1) color:my_color;
	}
	init{
		guestLocation<-location;
	}
	
	
	reflex goToStage when:  (!(empty(informs)) ) {
		loop msg over: informs{

			if(msg.contents[0]='start'){
				Stage informingConcert <- Stage(agent(msg.sender));
				write name+ " Receive inform from: " + informingConcert;
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
				

				my_color <- fav_stage.stage_color;

				
			}else{
				if(leader=self and msg.contents[0]='notify'){
//					write status;
					Stage thestage <- msg.contents[1];
					Guests g <- Guests(msg.sender);
					int stage_num <-  stage_population[thestage.name];
					add stage_num+1 at:thestage.name to:stage_population;
					leader_msg <-leader_msg+1;
//					status <-1;
				}else{

				Stage sta <- msg.contents[1];
				my_color <- sta.stage_color;

				status<-1;

					
				}
			}


		}
		
		
		if status=0{
			if leader != self{
				status <- 4;
				do start_conversation with: [to :: list(leader), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['notify',fav_stage ] ];
				
			}else{
				status <- 4;
				int stage_num <-  stage_population[fav_stage.name];
				add stage_num+1 at:fav_stage.name to:stage_population;
				
			}
			status <-4;
//			write 'status2 '+status; 
		}
		
//		if status=4{
//			write 'do calc';
//			if(leader=self){
//				
//				do calc_global_util;
//				write 'before utility: '+current_global_util;
//			}
////			status<-1;
//		}
		
		
		
		
	}
	
	reflex do_leader_job when:leader_msg=49 {
			write 'do calc';
			if(leader=self){
				do calc_global_util;
				leader_msg<-0;
				write 'before utility: '+current_global_util;
				write 'new utility: '	+new_global_util;
				status<-1;
			}
			
	}
	

	
	
	
	action calc_global_util{
		loop i from:1 to: length (Guests) - 1 {
			Guests guest<- Guests[i];
//			write guest;
			if(stage_population[guest.fav_stage.name]>50*guest.like_crowd){
				// check anther stage
				float my_util <-  guest.util - stage_population[guest.fav_stage.name]/guest.like_crowd*50;
				current_global_util <- current_global_util+ my_util;
				Stage new_stage <-nil;
				loop s_u over:guest.act_util_list{
					Stage sta <- s_u[0];
					float uti <- s_u[1];
					float mynew_util <-0.0;
					if stage_population[sta.name]>50*guest.like_crowd{
						mynew_util<- uti - stage_population[guest.fav_stage.name]/guest.like_crowd*50;
					}else{
						mynew_util<- uti + stage_population[guest.fav_stage.name]/guest.like_crowd*50;
					}
					if mynew_util > my_util{
						new_stage<-sta;
						my_util <- mynew_util;
					}
				}
				
				if new_stage !=nil{
					int stage_num <-  stage_population[guest.fav_stage.name];
					add stage_num-1 at:guest.fav_stage.name to:stage_population;
					guest.fav_stage <-new_stage;
					write 'ask '+ guest +' to go '+new_stage.name;
					do start_conversation with: [to :: list(guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['move',new_stage ] ];
					int stage_num1 <-  stage_population[new_stage.name];
					add stage_num1+1 at:new_stage.name to:stage_population;					
				}else{
					do start_conversation with: [to :: list(guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['move',guest.fav_stage ] ];
				}
				new_global_util <- new_global_util + my_util;
				
				
				
			}else if(stage_population[guest.fav_stage.name]<50*guest.like_crowd){
				float my_util <-  guest.util + stage_population[guest.fav_stage.name]/guest.like_crowd*50;
				current_global_util <- current_global_util+ my_util;
				Stage new_stage <-nil;
				loop s_u over:guest.act_util_list{
					Stage sta <- s_u[0];
					float uti <- s_u[1];
					float mynew_util <-0.0;
					if stage_population[sta.name]>50*guest.like_crowd{
						mynew_util<- uti - stage_population[guest.fav_stage.name]/guest.like_crowd*50;
					}else{
						mynew_util<- uti + stage_population[guest.fav_stage.name]/guest.like_crowd*50;
					}
					if mynew_util > my_util{
						new_stage<-sta;
						
						my_util <- mynew_util;
					}
				}
				
				if new_stage !=nil{
					int stage_num <-  stage_population[guest.fav_stage.name];
					add stage_num-1 at:guest.fav_stage.name to:stage_population;
					guest.fav_stage <-new_stage;
					write 'ask '+ guest +' to go '+new_stage.name;
					do start_conversation with: [to :: list(guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['move',new_stage ] ];
					int stage_num1 <-  stage_population[new_stage.name];
					add stage_num1+1 at:new_stage.name to:stage_population;					
				}else{
					do start_conversation with: [to :: list(guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['move',guest.fav_stage ] ];
				}
				
				new_global_util <- new_global_util + my_util;
			
			}
		}
	}
	
	
	
	
	
	
	
	
	reflex goingToStage when: status=1 {
		do goto target:fav_stage;
	}
	
	
	reflex atStage when: fav_stage != nil and (location distance_to fav_stage) <5{
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
		draw cube(4) color:stage_color;
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
			whenToEnd <-int(time+30);
			ongoing <- true;
//		}
		
	}
	
//	reflex endConcert when: (time=whenToEnd) and ongoing = true{
//		
//		do start_conversation with: [to ::list(Guests), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['end'] ];
//		
//		write name + ' eeeeeeeeeend concert';
//		whenToStart <- int(time+30);
//		ongoing <- false;
//		
//	}
	
	
}



experiment visitStage type:gui {
	output {
		display visitStage type:opengl{
			species Guests;
			species Stage;
		}
	}
}