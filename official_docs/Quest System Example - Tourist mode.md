Environment in KCD2 is beautiful. So Let's create a mode that hides all streamed gates and allows to player to discover places that are closed in openworld gameplay. And disable trespass crime reactions for peaceful travelling.

___

1.  Create new buff ai tag in the _buff\_ai\_tag_ table as described in [Adding a new Item](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/articles/KM-A-17/Adding-a-new-Item "KM-A-17: Adding a new Item"). We name the tag **tourist**. Will be used in later steps.
2.  Create new buff in the _buff_ table as described in [Adding a new Item](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/articles/KM-A-17/Adding-a-new-Item "KM-A-17: Adding a new Item"). We name it **mod\_touristMod\_isTourist**. Assign to this buff previously created ai tag. This buff will be useful in concept graph of KCD2. It is a sort of indication that mod is loaded and one of the many ways how we can react to mode events in base game concept graph . And the ai tag is required, so we are able to trigger signal in the base game concept graph.
3.  Create new mod as described in [Skald](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/articles/KM-A-18/Skald "KM-A-18: Skald") so mode has its own concept graph opened.
4.  For player identification create new **soul** asset in _Asset_ tab and check player's souls  
    ![image.png](https://warhorse.youtrack.cloud/api/files/496-687?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTY4N3x3ampLWGxjSVY5azdEZ3l6NTY3dGhpRXIxcjk0VmhzTG9tZzhGSGRmYW1BDQo&updated=1741709006543)
5.  Create a state of type **bool**. This state will control (enable/disable) required effects.
6.  In fact, there is no need to disable effects in this mode. So right mouse button click on state -\> show hidden ports -\> switch defaultValue to **TRUE**. So when the mode concept graph is loaded the state is **TRUE** and the effects are active.
7.  Add _SetGameContext_ node with context **crime\_disabledTrespassReactions**. Connect its _IsActive_ port to _State_ port of bool state. As the name says - this context disables trespass crime reactions when it is active.
8.  Add _Buff_ node. Set _BuffGUID_ parameter to previously created buff: **mod\_touristMod\_isTourist**. If you don't see the buff in the list - reload tables/rerun Skald. Set _Souls_ parameter to previously created asset with player souls.
9.  It should look like this:  
    ![image1.png](https://warhorse.youtrack.cloud/api/files/496-689?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTY4OXxhTTNQN3hlZTNQZXM1NUZvRFloVTBQb3dxY3hvd0dvTGx3Mkc3am9ULUdjDQo&updated=1741714290087)
10.  Now we need to change the concept graph of the base game a bit. Open base game concept graph. How to do it is also described here [Skald](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/articles/KM-A-18/Skald "KM-A-18: Skald")
11.  In the concept graph of base game there are some places you need to add this:  
    ![image2.png](https://warhorse.youtrack.cloud/api/files/496-691?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTY5MXxSS2tHRkdIc0NYd2MtYXpycUhIbXhMdUxLMGVYR3RNWDJQUVhuYVEzRTJvDQo&updated=1741709006543)
12.  This script works as this: Always keeps BuffTagTrigger node active. This node observes whether buff with ai tag "tourist" is added on player's soul. If it so, node sends signal. Signal is then used to unstream profile that contains level layers with closed doors, gates, etc. There is more than one place in concept graph that controls such profiles, so you must use this construct in all places to unstream all gate/door objects.

