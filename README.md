## Honours Research Project

My research is based around strategy synthesis for multi-robot systems, specifically for the "warehouse game". 

The report can be read [here]().

### Usage
The project has no dependencies, but uses Tkinter for the GUI simulation tool. Tkinter is included with most standard Python installations, but if you run into errors on startup related to Tkinter - check that your environment is setup to use it.

The program can be run simply: `python3 main.py <scenario> <mode>` where scenario is a file in the scenarios/ folder (without the extension), and mode is either `collective` or `fair`, which responds to either optimising for the collective total score, or finding a strategy profile in which all agents do some work. Once the best strategy profile has been found, a GUI visualiser is opened, allowing you to step through the states, which allows you to explore the strategy generated fully.

Create a new scenario is easy, simply add a text file in the scenarios folder. The format is as follows:

```
<rows> <columns>
<number of agents>
<agent 1> <initial position> <load position> <exit position>
<agent 2> <initial position> <load position> <exit position>
...and so on
```

Note that the positions are actually space-separated coordinate pairs (x and y positions).


### Extra
The repository also includes some extra Promela implementations of the warehouse game, but these can be ignored. They were mostly used to test out different scenarios and ideas directly. A `Makefile` is provided to run these implementations in SPIN directly, but doing so only results in the raw SPIN output, not the optimisation or GUI visualiser.