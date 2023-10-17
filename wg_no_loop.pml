#define m 4
#define n 4

chan a_move = [0] of {int};
chan b_move = [0] of {int};
// 0 means left, 1 means up, 2 means right, 3 means down
int a_moves[m*n];
int b_moves[m*n];
int a_moves_loaded[m*n];
int b_moves_loaded[m*n];

int a_x = 0;
int a_y = 0;
bool a_loaded = false;

int b_x = 2;
int b_y = 2;
bool b_loaded = false;

int a_load_x = 1;
int a_load_y = 0;
int a_drop_x = 1;
int a_drop_y = 2;

int b_load_x = 2;
int b_load_y = 0;
int b_drop_x = 0;
int b_drop_y = 2;

int a_score = 0;
int b_score = 0;

proctype a() {
    int index = 3 * a_y + a_x;
    if :: (a_loaded == false) -> {
        // printf("a is not loaded\n")
        // see if move is recorded
        if :: (a_moves[index] == -1) -> {
            // printf("move is not recorded\n")
            // move is not recorded
            // make a valid move, and record it
            if
            :: (a_x >= 1 && a_moves[index-1] != 2) -> {
                //can move to the left
                //and the cell to the left does not immediately move
                //back to this cell?
                a_moves[index] = 0;
            }
            :: (a_x <= 1 && a_moves[index+1] != 0) -> { //can move to the right
                a_moves[index] = 2;
            }
            :: (a_y >= 1 && a_moves[index-3] != 3) -> { //can move up
                a_moves[index] = 1;
            }
            :: (a_y <= 1 && a_moves[index+3] != 1) -> { //can move down
                a_moves[index] = 3;
            } 
            fi
            a_move!a_moves[index];
        } :: else -> {
            // make the recorded move
            int move = a_moves[index];
            a_move!move;
        }
        fi
    }
    :: else -> {
        // printf("a is loaded\n")
        // see if move is recorded
        if :: (a_moves_loaded[index] == -1) -> {
            // printf("move is not recorded\n")
            // move is not recorded
            // make a valid move, and record it
            if
            :: (a_x >= 1 && a_moves_loaded[index-1] != 2) -> {
                //can move to the left
                //and the cell to the left does not immediately move
                //back to this cell?
                a_moves_loaded[index] = 0;
            }
            :: (a_x <= 1 &&  a_moves_loaded[index+1] != 0) -> { //can move to the right
                a_moves_loaded[index] = 2;
            }
            :: (a_y >= 1 &&  a_moves_loaded[index-3] != 3) -> { //can move up
                a_moves_loaded[index] = 1;
            }
            :: (a_y <= 1 &&  a_moves_loaded[index+3] != 1) -> { //can move down
                a_moves_loaded[index] = 3;
            } 
            fi
            a_move!a_moves_loaded[index];
        } :: else -> {
            // make the recorded move
            int move = a_moves_loaded[index];
            a_move!move;
        }
        fi
    }
    fi
}

proctype b() {
    int index = 3 * b_y + b_x;
    if :: (b_loaded == false) -> {
        // printf("b is not loaded\n")
        // see if move is recorded
        if :: (b_moves[index] == -1) -> {
            // printf("move is not recorded\n")
            // move is not recorded
            // make b vblid move, bnd record it
            if
            :: (b_x >= 1 && b_moves[index-1] != 2) -> {
                //cbn move to the left
                //bnd the cell to the left does not immedibtely move
                //bbck to this cell?
                b_moves[index] = 0;
            }
            :: (b_x <= 1 && b_moves[index+1] != 0) -> { //cbn move to the right
                b_moves[index] = 2;
            }
            :: (b_y >= 1 && b_moves[index-3] != 3) -> { //cbn move up
                b_moves[index] = 1;
            }
            :: (b_y <= 1 && b_moves[index+3] != 1) -> { //cbn move down
                b_moves[index] = 3;
            } 
            fi
            b_move!b_moves[index];
        } :: else -> {
            // make the recorded move
            int move = b_moves[index];
            b_move!move;
        }
        fi
    }
    :: else -> {
        // printf("b is loaded\n")
        // see if move is recorded
        if :: (b_moves_loaded[index] == -1) -> {
            // printf("move is not recorded\n")
            // move is not recorded
            // make b valid move, and record it
            if
            :: (b_x >= 1 && b_moves_loaded[index-1] != 2) -> {
                //can move to the left
                //and the cell to the left does not immedibtely move
                //back to this cell?
                b_moves_loaded[index] = 0;
            }
            :: (b_x <= 1 &&  b_moves_loaded[index+1] != 0) -> { //can move to the right
                b_moves_loaded[index] = 2;
            }
            :: (b_y >= 1 &&  b_moves_loaded[index-3] != 3) -> { //can move up
                b_moves_loaded[index] = 1;
            }
            :: (b_y <= 1 &&  b_moves_loaded[index+3] != 1) -> { //can move down
                b_moves_loaded[index] = 3;
            } 
            fi
            b_move!b_moves_loaded[index];
        } :: else -> {
            // make the recorded move
            int move = b_moves_loaded[index];
            b_move!move;
        }
        fi
    }
    fi
}

init {
    int i = 0;
    for(i:0.. m*n-1) {
        a_moves[i] = -1;
        b_moves[i] = -1;
        a_moves_loaded[i] = -1;
        b_moves_loaded[i] = -1;
    }

    int move = -1;
    atomic {
        for(i:0.. 50) {
            // printf("a_x: %d, a_y: %d, a_loaded: %d\n", a_x, a_y, a_loaded, a_score);

            run a();
            a_move?move;

            if :: (move == 0) -> {
                a_x = a_x - 1;
            } :: (move == 1) -> {
                a_y = a_y - 1;
            } :: (move == 2) -> {
                a_x = a_x + 1;
            } :: (move == 3) -> {
                a_y = a_y + 1;
            }
            fi

            if :: (a_loaded == false && a_x == a_load_x && a_y == a_load_y) -> {
                a_loaded = true;
            } :: (a_loaded == true && a_x == a_drop_x && a_y == a_drop_y) -> {
                a_loaded = false;
                a_score = a_score + 1;
            } :: else -> skip;
            fi
            // printf("a_x: %d, a_y: %d, a_loaded: %d, a_score: %d\n\n", a_x, a_y, a_loaded, a_score);

            // ---------------------------------------------------------------
            // b
            
            // printf("b_x: %d, b_y: %d, b_loaded: %d\n", b_x, b_y, b_loaded, b_score);

            run b();
            b_move?move;

            if :: (move == 0) -> {
                b_x = b_x - 1;
            } :: (move == 1) -> {
                b_y = b_y - 1;
            } :: (move == 2) -> {
                b_x = b_x + 1;
            } :: (move == 3) -> {
                b_y = b_y + 1;
            }
            fi

            if :: (b_loaded == false && b_x == b_load_x && b_y == b_load_y) -> {
                b_loaded = true;
            } :: (b_loaded == true && b_x == b_drop_x && b_y == b_drop_y) -> {
                b_loaded = false;
                b_score = b_score + 1;
            } :: else -> skip;
            fi
            // printf("b_x: %d, b_y: %d, b_loaded: %d, b_score: %d\n\n", b_x, b_y, b_loaded, b_score);

        }
    }
}

ltl goal {
    (<> (a_x == b_x && a_y == b_y)) 
    || ([] (a_score <= 0 || b_score <= 0))
}

/*
maybe the crash condition is evaluated between the two position changes,
which would not allow transpositions

is there a way to only evaluate the crash condition after both positions update??
*/