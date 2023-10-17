#define m 5
#define n 5

chan a_move = [0] of {int};
int a_moves[m*n];
int a_moves_loaded[m*n];

int a_x = 0;
int a_y = 0;
bool a_loaded = false;
int a_load_x = 0;
int a_load_y = 3;
int a_drop_x = 3;
int a_drop_y = 0;

int a_score = 0;

chan b_move = [0] of {int};
int b_moves[m*n];
int b_moves_loaded[m*n];

int b_x = 2;
int b_y = 2;
bool b_loaded = false;
int b_load_x = 2; // changing this 1 to a 2
int b_load_y = 0;
int b_drop_x = 0;
int b_drop_y = 2; // and this 1 to a 2, makes a big difference

int b_score = 0;


proctype a() {
    int index = m * a_y + a_x;
    if :: (a_loaded == false) -> {
        if :: (a_moves[index] == -1) -> {
            if
            :: (a_x >= 1 && a_moves[index-1] != 2) -> {
                a_moves[index] = 0;
            }
            :: (a_x <= m-2 && a_moves[index+1] != 0) -> {
                a_moves[index] = 2;
            }
            :: (a_y >= 1 && a_moves[index-m] != 3) -> {
                a_moves[index] = 1;
            }
            :: (a_y <= n-2 && a_moves[index+m] != 1) -> {
                a_moves[index] = 3;
            }
            fi
            a_move!a_moves[index];
        } :: else -> {
            a_move!a_moves[index];
        }
        fi
    }
    :: else -> {
        if :: (a_moves_loaded[index] == -1) -> {
            if
            :: (a_x >= 1 && a_moves_loaded[index-1] != 2) -> {
                a_moves_loaded[index] = 0;
            }
            :: (a_x <= m-2 &&  a_moves_loaded[index+1] != 0) -> {
                a_moves_loaded[index] = 2;
            }
            :: (a_y >= 1 &&  a_moves_loaded[index-m] != 3) -> {
                a_moves_loaded[index] = 1;
            }
            :: (a_y <= n-2 &&  a_moves_loaded[index+m] != 1) -> {
                a_moves_loaded[index] = 3;
            }
            fi
            a_move!a_moves_loaded[index];
        } :: else -> {
            a_move!a_moves_loaded[index];
        }
        fi
    }
    fi
}


proctype b() {
    int index = m * b_y + b_x;
    if :: (b_loaded == false) -> {
        if :: (b_moves[index] == -1) -> {
            if
            :: (b_x >= 1 && b_moves[index-1] != 2) -> {
                b_moves[index] = 0;
            }
            :: (b_x <= m-2 && b_moves[index+1] != 0) -> {
                b_moves[index] = 2;
            }
            :: (b_y >= 1 && b_moves[index-m] != 3) -> {
                b_moves[index] = 1;
            }
            :: (b_y <= n-2 && b_moves[index+m] != 1) -> {
                b_moves[index] = 3;
            }
            fi
            b_move!b_moves[index];
        } :: else -> {
            b_move!b_moves[index];
        }
        fi
    }
    :: else -> {
        if :: (b_moves_loaded[index] == -1) -> {
            if
            :: (b_x >= 1 && b_moves_loaded[index-1] != 2) -> {
                b_moves_loaded[index] = 0;
            }
            :: (b_x <= m-2 &&  b_moves_loaded[index+1] != 0) -> {
                b_moves_loaded[index] = 2;
            }
            :: (b_y >= 1 &&  b_moves_loaded[index-m] != 3) -> {
                b_moves_loaded[index] = 1;
            }
            :: (b_y <= n-2 &&  b_moves_loaded[index+m] != 1) -> {
                b_moves_loaded[index] = 3;
            }
            fi
            b_move!b_moves_loaded[index];
        } :: else -> {
            b_move!b_moves_loaded[index];
        }
        fi
    }
    fi
}

init {
int move = -1;
int i = 0;
for(i:0.. m*n-1) {
a_moves[i] = -1;
a_moves_loaded[i] = -1;
b_moves[i] = -1;
b_moves_loaded[i] = -1;
}atomic {
for(i:0.. 50) {

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
        
}}}
ltl goal { 
(<> ((a_x == b_x && a_y == b_y)))
|| ([] ((a_score <= 0) || (b_score <= 0)))}
