#define m 3
#define n 3

chan a_move = [0] of {int};
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
        printf("a is not loaded\n")
        // see if move is recorded
        if :: (a_moves[index] == -1) -> {
            printf("move is not recorded\n")
            // move is not recorded
            // make a valid move, and record it
            if
            :: (a_x <= 1) -> { //can move to the right
                a_moves[index] = 2;
                // a_x = a_x + 1;
            }
            :: (a_x >= 1) -> { //can move to the left
                a_moves[index] = 0;
                // a_x = a_x - 1;
            }
            :: (a_y <= 1) -> { //can move down
                a_moves[index] = 3;
                // a_y = a_y + 1;
            }
            :: (a_y >= 1) -> { //can move up
                a_moves[index] = 1;
                // a_y = a_y - 1;
            }
            fi
            a_move!a_moves[index];
        } :: else -> {
            // make the recorded move
            int move = a_moves[index];
            // if :: (move == 0) -> {
            //     a_x = a_x - 1;
            // } :: (move == 1) -> {
            //     a_y = a_y - 1;
            // } :: (move == 2) -> {
            //     a_x = a_x + 1;
            // } :: (move == 3) -> {
            //     a_y = a_y + 1;
            // }
            // fi
            a_move!move;
        }
        fi
    }
    :: else -> {
        printf("a is loaded\n")
        // see if move is recorded
        if :: (a_moves_loaded[index] == -1) -> {
            printf("move is not recorded\n")
            // move is not recorded
            // make a valid move, and record it
            if
            :: (a_x <= 1) -> { //can move to the right
                a_moves_loaded[index] = 2;
                // a_x = a_x + 1;
            }
            :: (a_x >= 1) -> { //can move to the left
                a_moves_loaded[index] = 0;
                // a_x = a_x - 1;
            }
            :: (a_y <= 1) -> { //can move down
                a_moves_loaded[index] = 3;
                // a_y = a_y + 1;
            }
            :: (a_y >= 1) -> { //can move up
                a_moves_loaded[index] = 1;
                // a_y = a_y - 1;
            }
            fi
            a_move!a_moves_loaded[index];
        } :: else -> {
            // make the recorded move
            int move = a_moves_loaded[index];
            // if :: (move == 0) -> {
            //     a_x = a_x - 1;
            // } :: (move == 1) -> {
            //     a_y = a_y - 1;
            // } :: (move == 2) -> {
            //     a_x = a_x + 1;
            // } :: (move == 3) -> {
            //     a_y = a_y + 1;
            // }
            // fi
            a_move!move;
        }
        fi
    }
    fi
    // check the state after the move
    // here for now, but maybe in a controller later?
    // if :: (a_loaded == false && a_x == a_load_x && a_y == a_load_y) -> {
    //     a_loaded = true;
    // } :: (a_loaded == true && a_x == a_drop_x && a_y == a_drop_y) -> {
    //     a_loaded = false;
    //     a_score = a_score + 1;
    // } else -> skip;
    // fi

}

proctype b() {
    int index = 3 * b_y + b_x;
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
        for(i:0.. 9) {
            printf("a_x: %d, a_y: %d, a_loaded: %d\n", a_x, a_y, a_loaded, a_score);

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
            printf("a_x: %d, a_y: %d, a_loaded: %d, a_score: %d\n\n", a_x, a_y, a_loaded, a_score);
        }
    }
}

/*
problems:

1. It is possible for the agent to ping pong between two states
if a -> b and b -> a, no progress can be made
how can we avoid this?

one possibility is to not allow the agent to
move back to the state it just came from
i.e. it cannot move to a cell which leads to the current cell

is there a way to solve this with ltl instead?



*/