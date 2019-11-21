/***
* Name: nQueensProblem
* Author: sigrunarnasigurdardottir
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model nQueensProblem

/* Insert your model definition here */

global {
	
//	int nQueens <- 0;
	int num <- 8;
//	int column <- 10;
	int inital_location<-100/(2*num);
	
	init {
		
		list<list<rgb>> gridColor <- [];
		loop i from: 1 to: num
		{
			list<rgb> col <- [];
			
			loop j from: 0 to: num
			{
				col <+ (((i + j) mod 2) = 0) ? #white : #black;
			}
			gridColor <+ col;
			
		}
//				list<rgb> col <- [];
				
		ask Cells
		{
			color <- gridColor[grid_y][grid_x];
		}
		
		
		loop i from:0 to:num-1{
			if i=0{
				create Queen number: 1 with:(location:{inital_location,0});
			}else{
				create Queen number: 1 with:(location:{inital_location,0}, predecessor:Queen[i-1]);
			}
			
			inital_location<-inital_location+100/(num);
		}
		
		
		
		
		
	}
}

species Queen {
	//list<point> position <- [];
	//bool placeQueen <- false;
	
	Cells my_cell <- nil;
	int col_number;
	Queen predecessor <-nil;
	int status <-0; // 0->not done; 1 -> done; 2 -> no solution;
	point init_location;
	aspect {
		draw sphere(2) color:#blue;
	}
	
	init{
		col_number <- Queen index_of self;
		init_location <- location;
//		write col_number;
	}
	
	reflex canMove when:(predecessor=nil and status=0) or (predecessor!= nil and predecessor.status=1 and status=0){
		write "now moving "+name+ "col_num "+ col_number;
		if my_cell = nil{
//			write "aaaaaa";
			my_cell <-Cells[col_number,0];
			location <- setLocation(my_cell);
		}else if(my_cell.grid_y<num-1){
			my_cell <-Cells[col_number,my_cell.grid_y+1];
			location <- setLocation(my_cell);
		}else if (my_cell.grid_y>=num-1){
			if predecessor != nil{
				my_cell <-nil;
				location <- init_location;
				ask predecessor{
					self.status <-0;
					return;
				}
				
			}else{
				status <-2;
				write "NO solution!";
				return;
			}
		}
		if (predecessor != nil){
			ask predecessor{
				bool check <- doCheck(myself.my_cell);
				write name + " said:"+ check;
				if (check){
					myself.location <- setLocation(myself.my_cell);
					write 'finally set to :'+myself.my_cell.grid_x+","+myself.my_cell.grid_y;
					myself.status <-1;
				}
			}
		}else{
			location <- setLocation(my_cell);
			status <-1;
		}
			
	}
	
	bool doCheck(Cells new_cell){
		write "ask "+ name;
		int newx <- new_cell.grid_x;
		int newy <- new_cell.grid_y;
		int x <- my_cell.grid_x;
		int y <- my_cell.grid_y;
		write "new cell: ("+ new_cell.grid_x+","+new_cell.grid_y+ ") predecessor cell "+ my_cell.grid_x+","+my_cell.grid_y;
		if(newx<=x+1 and newx>=x-1 and newy>=y-1 and newy<=y+1) or (x=newx or y=newy){
			
			return false;
		}else{
			if predecessor != nil{
				ask predecessor{
					bool ck <- doCheck(new_cell);
					write name + " said_:"+ ck;
					if (ck){
						return true;
					}
				}
				return false;
			}else{
				return true;
			}
			
		}
		
	}
	
	point setLocation(Cells c1){
//		write " "+my_cell.grid_x + " "+my_cell.grid_y;
		
		return {c1.grid_x*(100/num)+100/(2*num),c1.grid_y*(100/num)+100/(2*num)};
	}
	
	action getGridLocation{
//		ask Cells{
//			write myself.location;
//		}
		write name+" cell: "+my_cell.grid_x+" "+my_cell.grid_y;
	}
	
	
}

grid Cells width: num height: num{
	init{
//		write self.grid_y;
	}
	
}

experiment nQueensProblem type:gui {
	output {
		display problem type:opengl{
			grid Cells;
			species Queen;
			
		}
	}
}