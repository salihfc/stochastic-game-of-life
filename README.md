# Game of Life with Age-Based Coloring in Godot4

This is an implementation of Conway's Game of Life with coloring based on the age of each cell. The game features probability-based rules, where the chance of a birth and the chance of death are determined by the following tables:

| Number of Neighbors | Chance of Birth |
|-------------------:|----------------:|
|                   0 |            0.05 |
|                   1 |           0.183 |
|                   2 |           0.557 |
|                   3 |               1 |
|                   4 |           0.557 |
|                   5 |           0.183 |
|                   6 |            0.05 |
|                   7 |            0.01 |
|                   8 |           0.003 |

| Number of Neighbors | Chance of Death |
|-------------------:|----------------:|
|                   0 |            0.05 |
|                   1 |           0.183 |
|                   2 |               1 |
|                   3 |               1 |
|                   4 |               1 |
|                   5 |           0.183 |
|                   6 |            0.05 |
|                   7 |            0.01 |
|                   8 |           0.003 |

Colors go from green to yellow to red, with the red color being used for cells that have been alive for 5 or more generations.

Here's a table of age and color values used in this implementation:

| Age   | Hex    |
|------:|---------:|
|     0 | `#42ff42`|
|     1 | `#a7ff8c`|
|     2 | `#e3ff96`|
|     3 | `#ffe659`|
|     4 | `#ff8787`|
|  >= 5 | `#ff3639`|


Here's a sample run of the game:

![Sample Run](sample_run.gif)