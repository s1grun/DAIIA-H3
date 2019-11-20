/***
* Name: nQueensProblem
* Author: sigrunarnasigurdardottir
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model nQueensProblem

/* Insert your model definition here */

global {
	
	int nQueens <- 0;
	int row <- 10;
	int column <- 10;
	
	init {
		create queen number: nQueens;
		list<list<rgb>> gridColor <- [];
		loop i from: 1 to: row
		{
			list<rgb> col <- [];
			
			loop j from: 0 to: row
			{
				col << (((i + j) mod 2) = 0) ? #white : #black;
			}
			gridColor << col;
			
		}
				list<rgb> col <- [];
				
		ask cells
		{
			color <- gridColor[grid_y][grid_x];
		}
	}
}

species queen {
	//list<point> position <- [];
	//bool placeQueen <- false;
	
	
}

grid cells width: row height: column;

experiment nQueensProblem type:gui {
	output {
		display problem type:opengl{
			species queen;
			grid cells;
		}
	}
}