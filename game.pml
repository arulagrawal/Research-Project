#define m 4
#define n 4
#define rounds 50

chan a_chan = [0] of {int};
chan a_can = [0] of {bool};
int a_moves[m*n];
int a_moves_loaded[m*n];
int a_x = 0;
int a_y = 0;
bool a_loaded = false;
int a_load_x = 0;
int a_load_y = 3;
int a_drop_x = 0;
int a_drop_y = 1;
int a_score = 0;

chan b_chan = [0] of {int};
chan b_can = [0] of {bool};
int b_moves[m*n];
int b_moves_loaded[m*n];
int b_x = 2;
int b_y = 2;
bool b_loaded = false;
int b_load_x = 1;
int b_load_y = 2;
int b_drop_x = 3;
int b_drop_y = 3;
int b_score = 0;

chan c_chan = [0] of {int};
chan c_can = [0] of {bool};
int c_moves[m*n];
int c_moves_loaded[m*n];
int c_x = 1;
int c_y = 1;
bool c_loaded = false;
int c_load_x = 3;
int c_load_y = 1;
int c_drop_x = 2;
int c_drop_y = 1;
int c_score = 0;


proctype a() {
    atomic {
        int i = 0;
        for(i:0.. rounds) {
            a_can?true;
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
                    a_chan!a_moves[index];
                } :: else -> {
                    a_chan!a_moves[index];
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
                    a_chan!a_moves_loaded[index];
                } :: else -> {
                    a_chan!a_moves_loaded[index];
                }
                fi
            }
            fi
        }
    }
}


proctype b() {
    atomic {
        int i = 0;
        for(i:0.. rounds) {
            b_can?true;
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
                    b_chan!b_moves[index];
                } :: else -> {
                    b_chan!b_moves[index];
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
                    b_chan!b_moves_loaded[index];
                } :: else -> {
                    b_chan!b_moves_loaded[index];
                }
                fi
            }
            fi
        }
    }
}


proctype c() {
    atomic {
        int i = 0;
        for(i:0.. rounds) {
            c_can?true;
            int index = m * c_y + c_x;
            if :: (c_loaded == false) -> {
                if :: (c_moves[index] == -1) -> {
                    if
                    :: (c_x >= 1 && c_moves[index-1] != 2) -> {
                        c_moves[index] = 0;
                    }
                    :: (c_x <= m-2 && c_moves[index+1] != 0) -> {
                        c_moves[index] = 2;
                    }
                    :: (c_y >= 1 && c_moves[index-m] != 3) -> {
                        c_moves[index] = 1;
                    }
                    :: (c_y <= n-2 && c_moves[index+m] != 1) -> {
                        c_moves[index] = 3;
                    }
                    fi
                    c_chan!c_moves[index];
                } :: else -> {
                    c_chan!c_moves[index];
                }
                fi
            }
            :: else -> {
                if :: (c_moves_loaded[index] == -1) -> {
                    if
                    :: (c_x >= 1 && c_moves_loaded[index-1] != 2) -> {
                        c_moves_loaded[index] = 0;
                    }
                    :: (c_x <= m-2 &&  c_moves_loaded[index+1] != 0) -> {
                        c_moves_loaded[index] = 2;
                    }
                    :: (c_y >= 1 &&  c_moves_loaded[index-m] != 3) -> {
                        c_moves_loaded[index] = 1;
                    }
                    :: (c_y <= n-2 &&  c_moves_loaded[index+m] != 1) -> {
                        c_moves_loaded[index] = 3;
                    }
                    fi
                    c_chan!c_moves_loaded[index];
                } :: else -> {
                    c_chan!c_moves_loaded[index];
                }
                fi
            }
            fi
        }
    }
}


proctype env() {
    atomic {
        int i = 0;
        for (i:0.. rounds) {
            int a_move = -1
int b_move = -1
int c_move = -1
a_can!true;
b_can!true;
c_can!true;
a_chan?a_move;
b_chan?b_move;
c_chan?c_move;

        if :: (a_move == 0) -> {
            a_x = a_x - 1;
        } :: (a_move == 1) -> {
            a_y = a_y - 1;
        } :: (a_move == 2) -> {
            a_x = a_x + 1;
        } :: (a_move == 3) -> {
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
        

        if :: (b_move == 0) -> {
            b_x = b_x - 1;
        } :: (b_move == 1) -> {
            b_y = b_y - 1;
        } :: (b_move == 2) -> {
            b_x = b_x + 1;
        } :: (b_move == 3) -> {
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
        

        if :: (c_move == 0) -> {
            c_x = c_x - 1;
        } :: (c_move == 1) -> {
            c_y = c_y - 1;
        } :: (c_move == 2) -> {
            c_x = c_x + 1;
        } :: (c_move == 3) -> {
            c_y = c_y + 1;
        }
        fi

        if :: (c_loaded == false && c_x == c_load_x && c_y == c_load_y) -> {
            c_loaded = true;
        } :: (c_loaded == true && c_x == c_drop_x && c_y == c_drop_y) -> {
            c_loaded = false;
            c_score = c_score + 1;
        } :: else -> skip;
        fi
        

        }
    }
}
        
init {
int i = 0;
for(i:0.. m*n-1) {
	a_moves[i] = -1;
	a_moves_loaded[i] = -1;
	b_moves[i] = -1;
	b_moves_loaded[i] = -1;
	c_moves[i] = -1;
	c_moves_loaded[i] = -1;
}
                run a();
        

                run b();
        

                run c();
        
run env()
}
ltl goal { 
(<> ((a_x == b_x && a_y == b_y) || (a_x == c_x && a_y == c_y) || (b_x == c_x && b_y == c_y)))
|| ([] ((a_score + b_score + c_score <= 26)))
}
