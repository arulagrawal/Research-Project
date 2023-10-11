from itertools import combinations

class robot():
    def __init__(self, name: str, start_pos: tuple[int, int], load_pos: tuple[int, int], exit_pos: tuple[int, int]) -> None:
        self.name = name
        self.start_pos = start_pos
        self.load_pos = load_pos
        self.exit_pos = exit_pos

    def get_variables(self) -> str:
        result = ""

        result += f"chan {self.name}_move = [0] of {{int}};\n"
        result += f"int {self.name}_moves[m*n];\n"
        result += f"int {self.name}_moves_loaded[m*n];\n"

        result += f"int {self.name}_x = {self.start_pos[0]};\n"
        result += f"int {self.name}_y = {self.start_pos[1]};\n"

        result += f"bool {self.name}_loaded = false;\n"

        result += f"int {self.name}_load_x = {self.load_pos[0]};\n"
        result += f"int {self.name}_load_y = {self.load_pos[1]};\n"

        result += f"int {self.name}_drop_x = {self.exit_pos[0]};\n"
        result += f"int {self.name}_drop_y = {self.exit_pos[1]};\n"

        result += f"int {self.name}_score = 0;\n"
        return result
    
    
    def get_proctype(self) -> str:
        return f"""
proctype {self.name}() {{
    int index = 3 * {self.name}_y + {self.name}_x;
    if :: ({self.name}_loaded == false) -> {{
        if :: ({self.name}_moves[index] == -1) -> {{
            if
            :: ({self.name}_x >= 1 && {self.name}_moves[index-1] != 2) -> {{
                {self.name}_moves[index] = 0;
            }}
            :: ({self.name}_x <= m-2 && {self.name}_moves[index+1] != 0) -> {{
                {self.name}_moves[index] = 2;
            }}
            :: ({self.name}_y >= 1 && {self.name}_moves[index-3] != 3) -> {{
                {self.name}_moves[index] = 1;
            }}
            :: ({self.name}_y <= n-2 && {self.name}_moves[index+3] != 1) -> {{
                {self.name}_moves[index] = 3;
            }}
            fi
            {self.name}_move!{self.name}_moves[index];
        }} :: else -> {{
            {self.name}_move!{self.name}_moves[index];
        }}
        fi
    }}
    :: else -> {{
        if :: ({self.name}_moves_loaded[index] == -1) -> {{
            if
            :: ({self.name}_x >= 1 && {self.name}_moves_loaded[index-1] != 2) -> {{
                {self.name}_moves_loaded[index] = 0;
            }}
            :: ({self.name}_x <= m-2 &&  {self.name}_moves_loaded[index+1] != 0) -> {{
                {self.name}_moves_loaded[index] = 2;
            }}
            :: ({self.name}_y >= 1 &&  {self.name}_moves_loaded[index-3] != 3) -> {{
                {self.name}_moves_loaded[index] = 1;
            }}
            :: ({self.name}_y <= n-2 &&  {self.name}_moves_loaded[index+3] != 1) -> {{
                {self.name}_moves_loaded[index] = 3;
            }}
            fi
            {self.name}_move!{self.name}_moves_loaded[index];
        }} :: else -> {{
            {self.name}_move!{self.name}_moves_loaded[index];
        }}
        fi
    }}
    fi
}}
"""
    
    def get_init(self) -> str:
        return f"""
                run {self.name}();
                {self.name}_move?move;

                if :: (move == 0) -> {{
                    {self.name}_x = {self.name}_x - 1;
                }} :: (move == 1) -> {{
                    {self.name}_y = {self.name}_y - 1;
                }} :: (move == 2) -> {{
                    {self.name}_x = {self.name}_x + 1;
                }} :: (move == 3) -> {{
                    {self.name}_y = {self.name}_y + 1;
                }}
                fi

                if :: ({self.name}_loaded == false && {self.name}_x == {self.name}_load_x && {self.name}_y == {self.name}_load_y) -> {{
                    {self.name}_loaded = true;
                }} :: ({self.name}_loaded == true && {self.name}_x == {self.name}_drop_x && {self.name}_y == {self.name}_drop_y) -> {{
                    {self.name}_loaded = false;
                    {self.name}_score = {self.name}_score + 1;
                }} :: else -> skip;
                fi
        """


class game():
    def __init__(self, dimensions: tuple[int, int], num_robots: int) -> None:
        self.m, self.n = dimensions
        self.num_robots = num_robots
        self.robots = []

    def add_robot(self, robot: robot) -> None:
        self.robots.append(robot)

    def get_promela(self) -> str:
        result = ""

        result += f"#define m {self.m}\n"
        result += f"#define n {self.n}\n\n"

        for robot in self.robots:
            result += robot.get_variables() + "\n"

        for robot in self.robots:
            result += robot.get_proctype() + "\n"

        result += "init {\n"
        result += "int move = -1;\n"
        result += "int i = 0;\n"

        result += "for(i:0.. m*n-1) {\n"
        for robot in self.robots:
            result += f"{robot.name}_moves[i] = -1;\n"
            result += f"{robot.name}_moves_loaded[i] = -1;\n"
        result += "}"

        result += "atomic {\n"

        result += "for(i:0.. 50) {\n"
        for robot in self.robots:
            result += robot.get_init() + "\n"
        result += "}"

        result += "}"
        result += "}\n"

        result += self.get_ltl() + "\n"
        return result
    
    def get_ltl(self) -> str:
        result = ""
        names = [robot.name for robot in self.robots]
        
        def get_collision_ltl(combs) -> str:
            collision_boolean_thing = [f"({x}_x == {y}_x && {x}_y == {y}_y)" for x, y in combinations(names, 2)]
            return " || ".join(collision_boolean_thing)
        
        def get_score_ltl(names) -> str: #TODO make score target a parameter
            return " || ".join([f"({name}_score <= 0)" for name in names])

        result += "ltl goal { \n"
        result += f"(<> ({get_collision_ltl(combinations(names, 2))}))\n"
        result += f"|| ([] ({get_score_ltl(names)}))"
        result += "}"

        return result


def get_scenario(file_name: str) -> game:
    scenario: game = None
    with open(file_name, "r") as f:
        dimensions = tuple(map(int, f.readline().split()))
        num_robots = int(f.readline())
        scenario = game(dimensions, num_robots)
        for lines in f.readlines():
            robot_name, start_x, start_y, load_x, load_y, drop_x, drop_y = lines.split()
            start_pos = (int(start_x), int(start_y))
            load_pos = (int(load_x), int(load_y))
            exit_pos = (int(drop_x), int(drop_y))
            robot_ = robot(robot_name, start_pos, load_pos, exit_pos)
            scenario.add_robot(robot_)

    return scenario



def main():
    game = get_scenario("scenarios/2x1.txt")
    with open("game.pml", "w") as f:
        f.write(game.get_promela())


if __name__ == '__main__':
    main()