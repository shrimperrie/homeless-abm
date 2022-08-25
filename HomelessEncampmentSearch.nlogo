globals [
  initial-camps ;; initial number of homeless camps
  time ;; time variable for plotting homeless population over time
  ]
patches-own [
  home-patches? ;; blue patches representing residential areas where homeless agents cannot permanently locate
  camp-patches? ;; green patches representing areas where homeless agents can temporarily locate
]
turtles-own [
  aggregate? ;; turtle who prefers to aggregate with other homeless
  neighbors? ;; a turtle or turtles are located on neighboring patches
  resource-budget ;; resources available to turtles to move, including time, mobility access, cash, etc
]
to setup
  clear-all ;; clears the model
  ask patches
  [ set pcolor white ] ;; the background is white

  ask n-of 8 patches ;; 8 randomly selected patches represent residential clusters
[
 ask n-of 60 patches in-radius 6 ;; 8 patches randomly select 60 patches less than or equal to radius of 6
     [ set pcolor blue ] ;; to turn blue
  ]
  ask n-of 6 patches ;; five randomly selected patches represent homeless encampments
  [ ask n-of 10 patches in-radius 2 ;; 5 patches randomly select 10 patches less than or equal to radius of 2
    [ set pcolor green ] ] ;; to turn green

  ask patches [
  ifelse pcolor = blue ;; each patch asks, Am I blue? If I am blue then
  [ set home-patches? true ] ;; I am home patch
  [ set home-patches? false ] ;; If I am not blue, I am not home patch

  ifelse pcolor = green ;; each patch asks, Am I green? If I am green then
  [ set camp-patches? true ] ;; I am camp patch
  [ set camp-patches? false ] ;; If I am not green, I am not camp patch
   ]

  set-default-shape turtles "person" ;; create homeless agents represented by human shape
  create-turtles initial-homeless ;;  creates homeless agents according to number slider
  set initial-camps count patches with [ pcolor = green ] ;; how many initial homeless camps

ask turtles [
    set size 1.7 ;; turtle size is set at 1.7
    setxy random-xcor random-ycor ;; homeless agents initialize randomly in world
    set resource-budget random-float 250 ;; homeless agents get resource budget determined by a random number between 0 and 249
    ifelse random-float 100 < %-aggregate ;; reports a random floating point number between 0 and 99, if the number is less than the %-aggregate slider,
    ;; the slider will establish an average percentage of homeless agents with preference for aggregating
    [ set color red ] ;; agent is red if it prefers aggregating
    [ set color cyan ];; agent is turquoise if it does not prefer aggregating

    ifelse color = red ;; if the turtle color is red then
    [ set aggregate? true ] ;; the turtle property is true for aggregate
    [ set aggregate? false ] ;; the turtle property is false for aggregate

   ifelse not any? turtles-on neighbors = true ;; if there are not any turtles located on neighboring patches then
    [ set neighbors? false ] ;; turtle has no neighbors
    [ set neighbors? true ] ;; turtle has neighbors
  ]
reset-ticks ;; reset time

end

to go
  if not any? patches with [ pcolor = green ] ;; if no green patches or encampments, stop model
  [ stop ]
  if not any? turtles ;; if no turtles in model, stop model
  [ stop ]
ask turtles [
  if pcolor = blue ;; if patch blue, find new spot by
  [ find-new-spot ] ;; moving until find unoccupied patch

  if ( pcolor = white) and ( color = red ) ;; am I on a white patch and am I red? If true, wander
    [ wander ]

  if  ( color = cyan ) and ( any? turtles-on neighbors = true ) ;; am I turquoise and are any other turtles on eighboring patches? If true, wander
      [ wander ] ;; if both not true, do nothing

  if ( color = red ) and ( any? other turtles-on neighbors = false ) ;; am I red and if there are no other turtles on neighboring patches, wander
    [ wander ] ;; if not true, do nothing
  ]
  ask turtles [
  if (pcolor = white ) and (any? neighbors with [ pcolor = green ]) and ;; am I located on a white patch, do I have any green neighbor patches, and
    ( random-float 100 < probability-growth-decline ) ;; if a random floating point number between 0 and 99 is less than PROBABILITY-GROWTH-DECLINE slider, then
   [ set pcolor green ] ;; patch I'm located on turns green. This represents process of homeless encampment growth.
  ]
  ask turtles
  [ check-if-exit? ];; each turtle checks resource budget, must exit world if less than zero
  ask turtles ;;  homeless encampments close,
  [ disperse-camp ] ;; according to probability slider with some randomness
  ask turtles
  [ new-camp ] ;; creates new homeless camps according to probability slider with some randomness

  if ( new-entry? ) [ ;; if the new-entry switch is on
    ask turtles with [ resource-budget > 249] [ ;; (this number is set very high to avoid exponential growth) turtles with resource budget greater than 249 will,
   if random 100 < probability-growth-decline ;; if a random number between 0 and 100 is less than PROBABILITY-GROWTH-DECLINE slider,
   [ hatch 1  ;; create a new turtle, note - with same properties as original turtle
   [ move ];; move forward 1 patch
    ]]
]
tick ;; observer advance clock by one tick interval
end

to move
  forward 1 ;; move forward 1 step
  set resource-budget resource-budget - 1 ;; with each move, resource budget is reduced by 1
end

to find-new-spot ;; procedure to find new spot
  rt random-float 360 ;; turn right random amount between 0 and 359 degrees
  fd 2 ;; move forward 2 patches
  if any? other turtles-here [ find-new-spot ] ;; if any other turtles are on patch, keep going until turtle finds unoccupied patch
  move-to patch-here  ;; move to center of patch
  set resource-budget resource-budget - 2 ;; decrease resource budget by movement cost of 2 units

end

to wander
  right random 30 ;; turn right random amount between 0 and 30 degrees
  move ;; move forward 1
  left random 45 ;; turn left random amount between 0 and 45 degrees
end

to check-if-exit? ;; turtle checks if it must exit model
  if resource-budget < 0 [ ;; if resource budget is less than 0, leave model
    exit ]  ;;
end

to exit ;; exit model
  die ;; DIE is netlogo primitive removing turtle from model
end

to disperse-camp ;; homeless encampments close
  ask patches with [ pcolor = green ] ;; green patches
    [ ask neighbors4 with [ pcolor = green ] ;; look at four neighbors (von Neumann neighborhood used to decrease number of potential yellow patches)
    [ if random 100 < probability-growth-decline ;; if a random number between 0 and 100 is less than PROBABILITY-GROWTH-DECLINE slider, then
        [ set pcolor yellow ] ] ;; patch turns yellow representing closed camp patch
  ]
 end

to new-camp ;; procedure represents spontaneous creation of new homeless camps when existing camps close
  if any? neighbors with [ pcolor = white ] ;; if turtle has any neighboring patches that are not existing encampments (green patches) or residential patches (blue patches)
  and pcolor = yellow ;; and if turtle is located on yellow patch,
  and random 100 < probability-growth-decline ;; and if a random number between 0 and 100 is less than PROBABILITY-GROWTH-DECLINE slider, then
  [ set pcolor green ] ;; patch will turn green and become new homeless encampment
end
@#$#@#$#@
GRAPHICS-WINDOW
345
20
889
565
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-33
33
-33
33
1
1
1
ticks
30.0

BUTTON
55
160
120
198
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
55
25
270
58
initial-homeless
initial-homeless
1
500
500.0
1
1
NIL
HORIZONTAL

SLIDER
55
65
270
98
%-aggregate
%-aggregate
0
100
86.0
1
1
NIL
HORIZONTAL

BUTTON
145
160
208
200
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
30
210
175
243
track one path
ask one-of turtles [pen-down]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
55
110
282
143
probability-growth-decline
probability-growth-decline
0
10
5.3
.1
1
%
HORIZONTAL

SWITCH
190
210
307
243
new-entry?
new-entry?
0
1
-1000

PLOT
45
405
285
605
Homeless over Time
time
# of homeless
0.0
500.0
0.0
500.0
true
true
"plotxy time count turtles\n\n" ""
PENS
"aggregate" 1.0 0 -2674135 true "" "plot count turtles with [ color = red ]"
"disperse" 1.0 0 -11221820 true "" "plot count turtles with [ color = cyan ]"
"total" 1.0 0 -16777216 true "" "plot count turtles"

MONITOR
120
335
222
380
# homeless total
count turtles
17
1
11

MONITOR
35
280
160
325
# homeless aggregate
count turtles with [ color = red ]
17
1
11

MONITOR
185
280
307
325
# homeless disperse
count turtles with [ color = cyan ]
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model explores the following question: How do people who are homeless select locations to live unsheltered, given the large space of potential locations as well as constraints on mobility and other resources? The main mechanisms in this model focus on simple search strategies for agents with limited sensing distance and heterogeneous resource budgets, as well as mechanisms of clustering and dispersion. Users select the initial number of homeless agents, the proportion of the population who prefer to aggregate, and the probability of growth or decline in the homeless population and encampments. The model only focuses on the search process and does not include mobility for daily living such as working, obtaining services and amenities, or socialization.

If agents had no preferences to aggregate, we would expect to see spatial dispersion of homeless persons in cities. In real life, cities show aggregations of encampments as well as dynamic processes where encampments arise, grow, disband in a continual process over time. Like cities, encampments exhibit both positive and negative feedback effects to growth including overcrowding, unsanitary and unsafe conditions, interpersonal conflicts, and sometimes violence/crime. Encampments can also offer proximity to amenities, transportation, safety, community, and mutual aid.

Urban homeless encampments are places in cities where homeless persons live temporarily in places not meant for human habitation: on streets/sidewalks, in cars, recreational vehicles, parks and green spaces. Urban homeless encampments are phenomena occurring primarily in a few large US cities, with approximately half of all unsheltered persons living in California. While some encampments are formally organized by public officials, this model explores informal, self-organized encampments. 

## HOW IT WORKS

SETUP
The model creates a world of random patches with blue patches representing residential areas in a city. These are clusters where homeless persons cannot live unsheltered  permanently. The model also creates six clusters representing homeless encampments which are green patches. The rest of the environment has a background of white patches.

Turtles or homeless agents have a person shape. The user sets a slider to determine the number of turtles in the INTERFACE tab, from 1 to 500 persons. These turtles are located on random patches in the world. 

Each turtle gets a resource budget which determines their ability to move. Ths resource budget is a random number between 0 and 249 units. This feature introduces heterogeneity and limits for turtles, as they do not have the same or unlimited resources. Also, turtles must EXIT the world when their resource budgets are less than zero.

As shown in the model world, turtles with a preference for aggregating are red and turtles who do not are turquoise or cyan.

In addition, turtles perceive if they have neighbors on any of their neighboring 8 patches. This is important because the turtles will cluster or repel each other during the GO stage. Turtles have limited sensing capabilities and only perceive their 8 local neighbors. Note that if turtles are clustered on the same patch, they are not defined as neighbors in this model.

GO: The model starts when the User hits the GO button. 
STOP: The model will stop when there are no remaining homeless encampments or turtles.

FIND-A-NEW-SPOT: Turtles examine their locations. If turtles are on a blue patch/residential area, they FIND-A-NEW-SPOT. FIND-A-NEW SPOT means to turn right a random amount between 0 and 359 degrees, then move forward 2 patches. This movement decreases the turtle's resource budget by two units. If there are any other turtles on the patch, the turtle keeps going until it finds an unoccupied spot in this procedure.

MOVE: MOVE means to move forward 1 patch and decrease the turtle's resource budget by 1 unit.

WANDER: If a turtle is red/aggregate, and finds itself in neither a residential area or a homeless encampment, it will WANDER. WANDER means to turn right in a random amount between 0 and 30 degrees, MOVE forward 1 patch/decrease resource budget by 1, and turn left by a random amount between 0 and 45 degrees. 

If red/aggregate turtles don't have any neighboring turtles, they will continue to wander. Over time, you will see the red turtles aggregating in homeless encampments. This model allows turtles to occupy the same patch. You will also see the turquoise turtles moving away from other turtles. 

The code includes a process of growth and decline of homeless encampments and the  population. If a patch is not a residential area or an existing encampment, and has a neighboring patch that is an encampment, it will become an encampment according to probability slider from 0 to 10%, with an element of randomness.

CHECK-IF-EXIT: This code asks turtles to check their resource budgets. If the budget is less than zero, the turtle will EXIT. 

EXIT: EXIT removes turtles from the model and uses the Netlogo primitive DIE to remove turtles. 

DISPERSE-CAMP: This code asks green patches/camp patches to look at their neighbors, and if a random number is less than the PROBABILITY-GROWTH-DECLINE slider then the patch will turn yellow to represent a closed camp patch.

NEW-CAMP: This code asks turtles located on green/camp patches to look at neighboring patches. If any are white patches and if any are yellow patches, and if a random number is less than the PROBABILITY-GROWTH-DECLINE slider the patch will turn green to represent a new camp patch. The structure of this code means that new camp patches will always be adjacent to existing green patches and represents a percolation process where a property is spreading, like fire in a forest.

## HOW TO USE IT


The model world is a grid lattice with 33 x 33 patches, or a total of 4,489 patches within a toroidal or wrapped topology. The world is a rough conceptual representation of a city. While cities are not torus-shaped, this model topology works better than a bounded world where cluster and dispersion behaviors lead to unrealistic outcomes.

The interface tab includes 3 tabs to set before the user pushes the SETUP and GO buttons.
INITIAL-HOMELESS slider
%-AGGREGATION slider
PROBABILITY-GROWTH-DECLINE slider

The user selects the number of initial homeless persons, INITIAL-HOMELESS from 1 to 1,000.

The user selects the percentage of the population with a preference for aggregating, %-AGGREGATION, 0 to 100%. 

Then the user selects the PROBABILITY-GROWTH-DECLINE for encampments and homeless population over time from 0 to 10%. Note that PROBABILITY-GROWTH-DECLINE is used to calculate the probability of increase or decrease.

The user then hits SETUP. If desired, the user can TRACK ONE PATH before hitting GO. This button will select a random turtle to draw its path using the pen-down command. 

When the user hits GO the model will start running. It is also possible to hit TRACK ONE PATH after the model has started.

The interface tab outputs 3 monitors that report the total number of homeless and  subtotals for homeless who aggregate or disperse. These numbers are also depicted in a plot, Homeless over Time.

The interface tab has a NEW-ENTRY? switch that will increase over time the number of homeless turtles according to the PROBABILITY-GROWTH-DECLINE slider with some randomness.


## THINGS TO NOTICE

This model only focuses on a search for locations to live unsheltered. This is an important distinction as agents stop their action once they meet their goal or run out of resources and leave the model. The model does not represent the daily life paths of unsheltered homeless persons.

If the user selects a population that has a 100% probability of not aggregating, the model displays very little movement and no clustering. This population of non-aggregators will only move if their initial random location is on a blue residential patch. They will move only enough to locate off a blue patch and to remain dispersed from neighbors. In this case, the existing population conserves resources, remains relatively isolated from other homeless agents, and the population continues to grow exponentially over time. This outcome is not typically observed in real life.

Agents will cluster on the same patches but may not have any neighbors even though it appears that they do. This is a feature of the model size and scale.


## THINGS TO TRY
Explore what happens when you have a very small number of homeless agents who prefer to aggregate. Because of the relatively large model space agents have great difficulty clustering with other agents (similar to the DLA model). Agents use up their resource budgets looking for other agents, and exit from the model quickly. Does the size of the model world affect this issue? Try changing the model size in SETTINGS on the Interface tab. If you reduce the size of the world, how do outcomes change?

What happens when there are a large number of aggregate agents? What happens when you have a small or large number of agents who do not aggregate? Explore what happens when you reduce or increase the model world.

Try changing the PROBABILITY-GROWTH-DECLINE slider to see what happens. What happens if you turn off the new-entry? switch, and no new agents enter the world? 


## EXTENDING THE MODEL

Modelers can add information exchange between agents to explore whether information and social ties might more realistically reflect patterns of encampments. Or they might add social influence interactions similar to Netlogo extensions of the Segregation Model ABM. How might agents influence each other and change their preferences? 

Modelers could add more input variability by changing hard-coded properties. For example, they could change the code to establish the number of encampments by a slider rather than the hard-coded 6 settlement clusters.
 
This model could be extended to use real GIS data so the model depicts an actual city. For example, the City of Seattle now tracks verified homeless encampments. The link below shows a map of these verified encampments. It is interesting to note that almost half of all encampments are located in two neighborhoods: Downtown and SODO (south of downtown) industrial area. This GIS data could be combined with time geography and urban scaling theories discussed in Luis M.A. Bettencourt's Introduction to Urban Science. Could these theories help explain quantitatively how clusters of encampments enclose the daily paths of people living unsheltered and provide value to agents through aggregation and informal settlement?

https://experience.arcgis.com/experience/af548fd66fc94e98a5067b299b7d1209/

Network topology: Other potential extensions include changing the topology of the model to a network. Will a network topology reflect more realistically real-life encampment patterns? 

Path dependence: Path dependence could be another extension where initial locations of homeless encampments might affect the future location of encampments or otherwise constrain the space of possibilities. In the current model, encampments grow and close with some probability and randomness. However, new encampments only arise adjacent or on old encampments. How might this reflect or not reflect real-life data?

Hysteresis: Another potential extension is to introduce more heterogeneity in agent properties, specifically hysteresis or "stickiness." In this case, some agents might exhibit hysteresis of their unsheltered state when they become housed and cycle in and out of living unsheltered. 

## RELATED MODELS
- Fire Model
- DLA Model
- Path Dependence Model

## CREDITS AND REFERENCES

Wilensky, U. (1997). Netlogo Fire model. http://ccl.northwestern.edu/netlogo/models/Fire.
Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Wilensky, U., Rand, W. (2006). Netlogo DLA Simple model. https://ccl.northwestern.edu/netlogo/models/DLASimple. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Rand, W. and Wilensky, U. (2007). Netlogo Urban Suite - Path Dependence model. http://ccl.northwestern.edu/netlogo/models/UrbanSuite-Path Dependence. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

This model is written in Netlogo 6.2.2. Wilensky, U. 1999. Netlogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL. 

Code syntax for clustering of residential and homeless encampments (lines 20-27 in Editor view on Code tab) from 3 lines of Mushroom Hunt demonstration code, p. 22, Railsback, Steven F. and Grimm, Volker, Agent-Based and Individual-Based Modeling, A Practical Introduction, Second Edition, 2019

Wilensky, U. and Rand, W. (2015) Introduction to Agent-based Modeling: Modeling Natural, Social and Engineered Complex Systems with Netlogo. Cambridge, MA. MIT Press.

This model will be available on github as a project of TEAM HOMER, a team from Complexity Weekend facilitated by Shirley Haruka Bekins exploring the complexity of homelessness.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
