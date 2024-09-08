# TGO Quest System

# Goals of the Quest System

- Independent - We want quest system to be reachable from any other systems without breaking anything.
- Easy-to-use - Implementation should be easy to use in the Editor and Should be managable when there is a lot of quests to manage.
- Merged UI - UI of the quest system will be connected with overall UI which includes Journal and other pop-ups.

## Implementation

The Implementation of Quest System is going to use a Quest resource that holds information about the Quest. You can append this quest to a Quest Chain to group them.

Quest counted independently so you don't have to put it in a Quest Chain for it to work.



## Quest

Quest resource holds the information about the quest.

This information include:

-Quest ID
-Title
-Description
-Is Completed
-Objectives
-Rewards

## Objectives

Quest Objectives are actions that you have to complete as the player. 
Quest holds an array of objectives and doing all of them is necessary for them to be completed.

Quest objective by itself is also a resource which holds the information:

-Description
-Type
-Is Complete
-Status

Objective has two types. These are text,number. This typing determines whether quest objective is about collecting items or doing a singular task. You have to pick text if a singular task has to be completed otherwise have to pick number.

Objective Status is determined by objective's type and will show how many items you have to collect or whether the task is completed.

## Rewards

This will be implemented later but basically when the quest is completed, we want to distribute rewards to player. These can be items or a new quest. If a quest is in a quest chain.
Player will be rewarded with a new quest automatically.

## Chain Quest

Chain Quest is a resource that will be stored in Quest Manager and holds an Array for Quests.

## Signalbus

I have included a signalbus with quest system, It is a singleton to hold signals and used in this case 
to update and the other systems like UI that interact with quest system to update themselves automatically when a quest is updated. 

## Quest Manager

Quest Manager is the node that holds the quests ,quest chains and methods to update them. 

these methods are:

Add Quest
Complete Quest
Update Objectives
Check Objective Status
On Update Quest
On Dialogic Signal
