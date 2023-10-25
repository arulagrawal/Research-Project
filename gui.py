import tkinter as tk


def simulate_game(game, strategy_profile):
    root = tk.Tk()
    root.title("Robot Game")

    m, n = game.m, game.n
    width = m * 100
    height = n * 100
    canvas = tk.Canvas(root, width=width, height=height, bg="white")
    canvas.pack()
    cell_size = 100
    robot_size = 90

    for i in range(m):
        canvas.create_line(i * cell_size, 0, i * cell_size, n * cell_size)
    for j in range(n):
        canvas.create_line(0, j * cell_size, m * cell_size, j * cell_size)

    colours = ["red", "green", "blue", "yellow", "orange", "purple", "pink", "brown"];
    sprites = []
    for i, robot in enumerate(game.robots):
        sprite = Sprite(robot, strategy_profile[robot.name], colours[i], cell_size, robot_size, m, n)
        sprites.append(sprite)

    for sprite in sprites:
        sprite.draw_poi(canvas)
    update_sprites(sprites, canvas)

    root.bind("<Right>", lambda event: next_move(event, sprites, canvas))

    root.mainloop()

def next_move(event, sprites, canvas):
    update_sprites(sprites, canvas)

def update_sprites(sprites, canvas):
    for sprite in sprites:
        sprite.draw_next(canvas)

def draw_robot(canvas, x, y, color, robot_size, cell_size):
    padding = (cell_size - robot_size)
    return canvas.create_oval((x * cell_size) + padding, (y * cell_size) + padding, 
                       ((x + 1) * cell_size) - padding, ((y + 1) * cell_size) - padding, 
                       fill=color, outline=color)

def move_robot(canvas,old_id, new_x, new_y, color, robot_size, cell_size):
    canvas.delete(old_id)
    return draw_robot(canvas, new_x, new_y, color, robot_size, cell_size)

class Sprite:
    def __init__(self, robot, strategy, colour, cell_size, robot_size, m, n) -> None:
        self.init_x, self.init_y = robot.start_pos
        self.load_x, self.load_y = robot.load_pos
        self.drop_x, self.drop_y = robot.exit_pos
        self.x, self.y = self.init_x, self.init_y
        self.old_x, self.old_y = None, None
        self.draw_id = None
        self.strategy = strategy
        self.colour = colour
        self.cell_size = cell_size
        self.size = robot_size
        self.load = False
        self.m, self.n = m, n
        self.score = 0

    def draw_next(self, canvas):
        if self.draw_id is None:
            print("drawing initial")
            self.old_x, self.old_y = self.x, self.y
            self.draw_id = draw_robot(canvas, self.x, self.y, self.colour, self.size, self.cell_size)
        else:
            self.old_x, self.old_y = self.x, self.y
            self.x, self.y = self.get_next_pos()
            self.draw_id = move_robot(canvas, self.draw_id, self.x, self.y, self.colour, self.size, self.cell_size)

    def draw_poi(self, canvas):
        # this function draws the load and drop points
        # each point is a rectangle with size 40x40, centered on the cell where it is
        # the rectangle matches the color of the robot
        # the load point rectangle has an L inside it
        # the drop point rectangle has a D inside it

        # load point
        x, y = self.load_x, self.load_y
        padding = (self.cell_size - 40) // 2
        canvas.create_rectangle((x * self.cell_size) + padding, (y * self.cell_size) + padding, 
                       ((x + 1) * self.cell_size) - padding, ((y + 1) * self.cell_size) - padding, 
                       fill=self.colour, outline=self.colour)
        
        canvas.create_text((x * self.cell_size) + (self.cell_size // 2), (y * self.cell_size) + (self.cell_size // 2), text="L", font=("Arial", 20))

        # drop point
        x, y = self.drop_x, self.drop_y
        padding = (self.cell_size - 40) // 2
        canvas.create_rectangle((x * self.cell_size) + padding, (y * self.cell_size) + padding, 
                       ((x + 1) * self.cell_size) - padding, ((y + 1) * self.cell_size) - padding, 
                       fill=self.colour, outline=self.colour)
        
        canvas.create_text((x * self.cell_size) + (self.cell_size // 2), (y * self.cell_size) + (self.cell_size // 2), text="D", font=("Arial", 20))
    
    def get_next_pos(self):
        index = self.m * self.y + self.x
        if self.load:
            move = self.strategy["moves_loaded"][index]
        else:
            move = self.strategy["moves"][index]
        
        n_x, n_y = -1, -1
        # 0 means left, 1 means up, 2 means right, 3 means down
        if move == 0:
            n_x, n_y = self.x - 1, self.y
        elif move == 1:
            n_x, n_y = self.x, self.y - 1
        elif move == 2:
            n_x, n_y = self.x + 1, self.y
        else:
            n_x, n_y = self.x, self.y + 1
        
        if (n_x, n_y) == (self.load_x, self.load_y):
            self.load = True
        elif (n_x, n_y) == (self.drop_x, self.drop_y):
            self.load = False
            self.score += 1
        
        return n_x, n_y
