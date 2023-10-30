from itertools import combinations
import re
import subprocess
from pprint import pprint

from gui import simulate_game

class robot:
    def __init__(
        self,
        name: str,
        start_pos: tuple[int, int],
        load_pos: tuple[int, int],
        exit_pos: tuple[int, int],
    ) -> None:
        self.name = name
        self.start_pos = start_pos
        self.load_pos = load_pos
        self.exit_pos = exit_pos

    def get_variables(self) -> str:
        result = ""

        result += f"chan {self.name}_chan = [0] of {{int}};\n"
        result += f"chan {self.name}_can = [0] of {{bool}};\n"
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
    atomic {{
        int i = 0;
        for(i:0.. rounds) {{
            {self.name}_can?true;
            int index = m * {self.name}_y + {self.name}_x;
            if :: ({self.name}_loaded == false) -> {{
                if :: ({self.name}_moves[index] == -1) -> {{
                    if
                    :: ({self.name}_x >= 1 && {self.name}_moves[index-1] != 2) -> {{
                        {self.name}_moves[index] = 0;
                    }}
                    :: ({self.name}_x <= m-2 && {self.name}_moves[index+1] != 0) -> {{
                        {self.name}_moves[index] = 2;
                    }}
                    :: ({self.name}_y >= 1 && {self.name}_moves[index-m] != 3) -> {{
                        {self.name}_moves[index] = 1;
                    }}
                    :: ({self.name}_y <= n-2 && {self.name}_moves[index+m] != 1) -> {{
                        {self.name}_moves[index] = 3;
                    }}
                    fi
                    {self.name}_chan!{self.name}_moves[index];
                }} :: else -> {{
                    {self.name}_chan!{self.name}_moves[index];
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
                    :: ({self.name}_y >= 1 &&  {self.name}_moves_loaded[index-m] != 3) -> {{
                        {self.name}_moves_loaded[index] = 1;
                    }}
                    :: ({self.name}_y <= n-2 &&  {self.name}_moves_loaded[index+m] != 1) -> {{
                        {self.name}_moves_loaded[index] = 3;
                    }}
                    fi
                    {self.name}_chan!{self.name}_moves_loaded[index];
                }} :: else -> {{
                    {self.name}_chan!{self.name}_moves_loaded[index];
                }}
                fi
            }}
            fi
        }}
    }}
}}
"""

    def get_init(self) -> str:
        return f"""
                run {self.name}();
        """

    def get_env(self) -> str:
        return f"""
        if :: ({self.name}_move == 0) -> {{
            {self.name}_x = {self.name}_x - 1;
        }} :: ({self.name}_move == 1) -> {{
            {self.name}_y = {self.name}_y - 1;
        }} :: ({self.name}_move == 2) -> {{
            {self.name}_x = {self.name}_x + 1;
        }} :: ({self.name}_move == 3) -> {{
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


class game:
    def __init__(self, dimensions: tuple[int, int], num_robots: int) -> None:
        self.m, self.n = dimensions
        self.num_robots = num_robots
        self.robots = []
        self.target_total_score = 0
        self.rounds = 50


    def add_robot(self, robot: robot) -> None:
        self.robots.append(robot)

    def get_promela(self) -> str:
        result = ""

        result += f"#define m {self.m}\n"
        result += f"#define n {self.n}\n"
        result += f"#define rounds {self.rounds}\n\n"

        for robot in self.robots:
            result += robot.get_variables() + "\n"

        for robot in self.robots:
            result += robot.get_proctype() + "\n"

        result += self.get_env() + "\n"

        result += "init {\n"
        result += "int i = 0;\n"

        result += "for(i:0.. m*n-1) {\n"
        for robot in self.robots:
            result += f"\t{robot.name}_moves[i] = -1;\n"
            result += f"\t{robot.name}_moves_loaded[i] = -1;\n"
        result += "}"

        for robot in self.robots:
            result += robot.get_init() + "\n"

        result += "run env()\n"
        result += "}\n"

        result += self.get_ltl() + "\n"
        return result

    def get_env(self) -> str:
        return f"""
proctype env() {{
    atomic {{
        int i = 0;
        for (i:0.. rounds) {{
            {self.get_env_inner()}
        }}
    }}
}}
        """

    def get_env_inner(self) -> str:
        result = ""
        for robot in self.robots:
            result += f"int {robot.name}_move = -1\n"

        for robot in self.robots:
            result += f"{robot.name}_can!true;\n"

        for robot in self.robots:
            result += f"{robot.name}_chan?{robot.name}_move;\n"

        for robot in self.robots:
            result += robot.get_env() + "\n"
        return result

    def get_ltl(self) -> str:
        result = ""
        names = [robot.name for robot in self.robots]

        def get_collision_ltl(combs) -> str:
            collision_boolean_thing = [
                f"({x}_x == {y}_x && {x}_y == {y}_y)" for x, y in combs
            ]
            return " || ".join(collision_boolean_thing)

        # def get_score_ltl(names) -> str:  # TODO make score target a parameter
        #     return " || ".join([f"({name}_score <= 0)" for name in names])
        def get_score_ltl(names) -> str:
            score_sum = " + ".join(f"{name}_score" for name in names)
            return f"({score_sum} <= {self.target_total_score})"


        result += "ltl goal { \n"
        result += f"(<> ({get_collision_ltl(combinations(names, 2))}))\n"
        result += f"|| ([] ({get_score_ltl(names)}))"
        result += "\n}"

        return result
    
    def run(self):
        with open("game.pml", "w") as f:
            f.write(self.get_promela())

        subprocess.run(
            ["spin", "-a", "game.pml"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        subprocess.run(
            [
                "gcc",
                "-DMEMLIM=8192",
                "-O3",
                "-DNOFAIR",
                "-DNOCOMP",
                "-DXUSAFE",
                "-DVECTORSZ=4096",
                "-DBITSTATE",
                "-w",
                "-o",
                "pan",
                "pan.c",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        subprocess.run(
            ["./pan", "-m10000", "-a", "-N", "-G4", "goal"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=2 * 60
        )
        result = subprocess.run(
            [
                "spin",
                "-X",
                "-n123",
                "-l",
                "-g",
                "-k",
                "game.pml.trail",
                "-u10000",
                "game.pml",
            ],
            capture_output=True,
            text=True,
            # timeout=1 * 60
        )
        output = result.stdout
        strategies = {r.name: {} for r in self.robots}
        for robot in strategies.keys():
            strategies[robot]["moves"] = {}
            strategies[robot]["moves_loaded"] = {}
            strategies[robot]["score"] = 0

        move_regex = r"(\s*[a-zA-Z0-9.-]+)_(\w+)\[(\d+)\] = (-?\d+)"
        for line in output.splitlines():
            match = re.match(move_regex, line.strip())
            if match:
                robot, move_type, index, move = match.groups()
                strategies[robot][move_type][int(index)] = int(move)
            else:
                match = re.match(r"([a-zA-Z0-9.-]+)_score = (\d+)", line.strip())
                if match:
                    robot, score = match.groups()
                    strategies[robot]["score"] = int(score)

        subprocess.run(["rm", "-f", "pan*", "*.trail", "*.tmp"])
        return strategies
    
    def iterative_search(self):
        total_score = 0
        strategy_profile = None
        try:
            for _ in range(10):
                self.target_total_score = total_score # dont need plus one because we search for <=
                strategy_profile = self.run()
                total_score = sum([strategy_profile[r]["score"] for r in strategy_profile.keys()])
                print(f"Total score improved to: {total_score}")
                print("Individual scores:")
                for robot in self.robots:
                    print(f"{robot.name}: {strategy_profile[robot.name]['score']}")
        except subprocess.TimeoutExpired:
            print("Time limit exceeded")
            return strategy_profile

        return strategy_profile

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
    strategy_profile = game.iterative_search()
    simulate_game(game, strategy_profile)

if __name__ == "__main__":
    main()
