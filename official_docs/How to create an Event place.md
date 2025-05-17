**Before creating a completely new _event place_, be sure that you really need it**. Event places are shared between events, therethrough it make no sense to create two different event places at the exact same location (8x8m area) in the level. Before continuing, I recommend you to open the editor and load nearby layers to make sure there is no already existing event place! If there is, skip this tutorial.

At this point you are completely sure that there is no event place at your desired location. Now you have a burden on your shoulders to create one. You've procrastinated a lot, but deadline is coming. I'll try to make this journey as painless as possible. So turn on your pomodoro timer and lets dive in:

1.  Choose a name for the _event place_. It should properly describe the location. If there's nothing you can come up with, you can choose from the following general ones:
    
    -   road
    -   roadJunction
    
    The full event place name with region code would be <region code\>\_<location name\>. For example tzda\_road
    
    It is possible, that there is already an event place with such name under that region. In such case add a number to the end of the name. For examle: tzda\_road2
    
2.  Create an _event place_ module in Skald
    
    -   In Trosecko level it should be done under Barbora-\>trosecko-\>eventPlaces
    -   In Kutnohorsko level it should be done under Barbora-\>kutnohorsko-\>eventPlaces
3.  Set its "Parent node" properties:
    
    1.  Set name: <region code\>\_<location name\>, Example: tvid\_road2
    2.  Set design name (in czech): <Region\> <location name\>, Example: Vidlak cesta 2
4.  Enable it by checking the _IsEnabled_ input port.
    
5.  Switch to the editor. Under the desired region create a new layer. Name it "eventPlace\_<location name\>". Example: eventPlace\_roadJunction. Set it's color to orange rgb(223,121,52) or use color pick tool on existing event place layer.
    
6.  Right click on the layer, choose _Insert Layer Template_ and select _eventPlace_ template. A new layer would be created with a prefab placed right in front of the camera.
    
7.  Select the prefab and rename to <region code\>\_<location name\>\_eventPlace, Example: tvid\_road2\_eventPlace
    
8.  Before we move on to placing the prefab in the editor, let's review some event place theory. An event place is a defined area in the level (usually not bigger than an 8m x 8m square) where an event can take place. Each event place has a center point (marked by a "fastTravel\_close" tagpoint), where the player is teleported if their fast travel is interrupted by an event.
    
    If two events are more than ~25m apart, it's important to create separate event places for each of them. This is because each event place needs its own center point, and it's not possible to define a single center point for events that are too far apart. Creating separate event places also gives us more control over spawning these events, as we can use different trigger areas for each event. This is particularly important in tighly packed areas like cities or villages. Another reason for creating a separate event place is that it is not possible to have two events of the same type in one event place. Keep this in mind when deciding whether two events can share an event place.
    
9.  Players should not be able to see the center of the event place when they enter the trigger area. If necessary, adjust the trigger area to ensure this. Sometimes it may not be possible to achieve this with only one trigger area. For example, in a large open space, it is propably better to have several small trigger areas on the roads to limit the directions from which the player can spawn the event. In such cases, you should duplicate the existing trigger area and link it to the eventPlace entity with the link name "asset\['RandomEventPlaceTrigger'\]".
    
10.  In the eventPlace prefab, you'll find tagpoints that define where the player will appear if fast travel is interrupted. Make sure you position them correctly. If you're making an event place in a village or city, you can skip this step since those events won't interrupt fast travel. However, it's still a good idea to make a separate event place for events that are far away to have better control over the trigger area.
    
    1.  fastTravel\_close place it at the center of event place.
    2.  fastTravel\_far\[1-4\] place them on the roads about 30m far from the event place center. One per road. They should face the direction of the event. You can delete tagpoint which you didn't use.
11.  Link concept entity with newly created event place:
    
    1.  For Trosecko level you can find concept entity at _Main/\_quest/\_script_ under the name _trosecko_.
    2.  Create a link from it to the _in\_concept_ prefab port of _eventPlace_ prefab.
    3.  Name it module\['<region code\>\_<location name\>'\]. Example: module\['tvid\_road2'\]
12.  Set newly created layer to be included in **events** profile:
    
    ![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)
    
13.  You're done! Great job! 😎😎😎