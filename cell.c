extern char state[];
extern int WorldLength,WorldWidth;
extern int sizeOfBoard;

extern int system_call();

int isInBound(int x,int y){
	if (x>=0 && x<WorldLength && y>=0 && y<WorldWidth)
		return 1;
	return 0;
}

char cell (int a,int b){
	int cellNumber=a*WorldWidth+b;
	char isAlive = 0;
	int livingNeghibors=0,i,j;
	int x = cellNumber/WorldWidth;
	int y = cellNumber%WorldWidth;
	char tmp[WorldLength][WorldWidth];
	for(i=0;i<WorldLength;i++){
		for(j=0;j<WorldWidth;j++){
			tmp[i][j]=state[i*WorldWidth+j];
		}
	}
	isAlive = state[cellNumber];
	if(isInBound(x-1,y)==0){		/*In case of top border*/
		if(tmp[x+1][y]!='0'){
			livingNeghibors++;
		}
		if(tmp[WorldLength-1][y]!='0'){
			livingNeghibors++;
		}
		if(isInBound(x,y-1)==0){		/*in case of top left corner*/
			if(tmp[0][WorldWidth-1]!='0'){
				livingNeghibors++;
			}
			if(tmp[WorldLength-1][WorldWidth-1]!='0'){
				livingNeghibors++;
			}
			if(tmp[1][WorldWidth-1]!='0'){
				livingNeghibors++;
			}
			if(tmp[1][1]!='0'){
				livingNeghibors++;
			}
			if(tmp[0][1]!='0'){
				livingNeghibors++;
			}
			if(tmp[WorldLength-1][1]!='0'){
				livingNeghibors++;
			}
		}else if(isInBound(x,y+1)==0){		/*in case of top right corner*/
		
			if(tmp[0][0]!='0'){
				livingNeghibors++;
			}
			if(tmp[WorldLength-1][0]!='0'){
				livingNeghibors++;
			}
			if(tmp[1][0]!='0'){
				livingNeghibors++;
			}
			if(tmp[0][y-1]!='0'){
				livingNeghibors++;
			}
			if(tmp[1][y-1]!='0'){
				livingNeghibors++;
			}
			if(tmp[WorldLength-1][y-1]!='0'){
				livingNeghibors++;
			}
		}else{								/*in case of middle top*/
			if(tmp[x][y-1]!='0'){
				livingNeghibors++;
			}
			if(tmp[x+1][y-1]!='0'){
				livingNeghibors++;
			}
			if(tmp[WorldLength-1][y-1]!='0'){
				livingNeghibors++;
			}
			if(tmp[x][y+1]!='0'){
				livingNeghibors++;
			}
			if(tmp[1][y+1]!='0'){
				livingNeghibors++;
			}
			if(tmp[WorldLength-1][y+1]!='0'){
				livingNeghibors++;
			}
		}
	}else if(isInBound(x+1,y)==0){			          /*in case of bottom*/			
		if(tmp[0][y]!='0')  
			livingNeghibors++;
		if(tmp[x-1][y]!='0')
			livingNeghibors++;
		if(isInBound(x,y-1)==0){		        /*in case of bottom left corner*/
			if(tmp[x-1][y+1]!='0')
				livingNeghibors++;
			if(tmp[x][y+1]!='0')
				livingNeghibors++;
			if(tmp[0][y+1]!='0')
				livingNeghibors++;
			if(tmp[0][WorldWidth-1]!='0')
				livingNeghibors++;
			if(tmp[WorldLength-1][WorldWidth-1]!='0')
				livingNeghibors++;
			if(tmp[x-1][WorldWidth-1]!='0')
				livingNeghibors++;
		}else if(isInBound(x,y+1)==0){	               /*bottom right corner*/
			if(tmp[x-1][y-1]!='0')
				livingNeghibors++;
			if(tmp[x][y-1]!='0')
				livingNeghibors++;
			if(tmp[0][y-1]!='0')
				livingNeghibors++;
			if(tmp[0][0]!='0')
				livingNeghibors++;
			if(tmp[x][0]!='0')
				livingNeghibors++;
			if(tmp[x-1][0]!='0')
				livingNeghibors++;
		}else{							/*in case of bottom middle*/
			if(tmp[x-1][y-1]!='0')
				livingNeghibors++;
			if(tmp[x][y-1]!='0')
				livingNeghibors++;
			if(tmp[0][y-1]!='0')
				livingNeghibors++;
			if(tmp[0][y+1]!='0')
				livingNeghibors++;
			if(tmp[x][y+1]!='0')
				livingNeghibors++;
			if(tmp[x-1][y+1]!='0')
				livingNeghibors++;
		}
	}else if(isInBound(x,y-1)==0){			/*left middle*/
		if(tmp[x+1][y]!='0')
			livingNeghibors++;
		if(tmp[x+1][y+1]!='0')
			livingNeghibors++;
		if(tmp[x][y+1]!='0')
			livingNeghibors++;
		if(tmp[x-1][y+1]!='0')
			livingNeghibors++;
		if(tmp[x-1][y]!='0')
			livingNeghibors++;
		if(tmp[x-1][WorldWidth-1]!='0')
			livingNeghibors++;
		if(tmp[x][WorldWidth-1]!='0')
			livingNeghibors++;
		if(tmp[x+1][WorldWidth-1]!='0')
			livingNeghibors++;
	}else if(isInBound(x,y+1)==0){			/*right middle*/
		if(tmp[x-1][0]!='0')
			livingNeghibors++;
		if(tmp[x][0]!='0')
			livingNeghibors++;
		if(tmp[x+1][0]!='0')
			livingNeghibors++;
		if(tmp[x+1][y]!='0')
			livingNeghibors++;
		if(tmp[x+1][y-1]!='0')
			livingNeghibors++;
		if(tmp[x][y-1]!='0')
			livingNeghibors++;
		if(tmp[x-1][y-1]!='0')
			livingNeghibors++;
		if(tmp[x-1][y]!='0')
			livingNeghibors++;
	}else{									/*middle of the board*/
		if(tmp[x-1][y-1]!='0')
			livingNeghibors++;
		if(tmp[x-1][y]!='0')
			livingNeghibors++;
		if(tmp[x-1][y+1]!='0')
			livingNeghibors++;
		if(tmp[x][y+1]!='0')
			livingNeghibors++;
		if(tmp[x+1][y+1]!='0')
			livingNeghibors++;
		if(tmp[x+1][y]!='0')
			livingNeghibors++;
		if(tmp[x+1][y-1]!='0')
			livingNeghibors++;
		if(tmp[x][y-1]!='0')
			livingNeghibors++;
	}
	if(isAlive!='0'){
		if(livingNeghibors==2 || livingNeghibors==3){
			if(isAlive=='9'){
				return isAlive;
			}
			return isAlive+1;
		}	
	}
	else{
		if(livingNeghibors==3){
			return '1';
		}
	}
	return '0';
}