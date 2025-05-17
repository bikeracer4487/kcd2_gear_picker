## Skald

Place _GenericRandomEvent_ concept node anywhere in the graph (not in EventPlace nor Library).  
Set _GenericEventType_ and _Cooldown_ properties.

Add _RandomEventVariant_ inside the event node. And set it's properties. You should probable set the _CooldownOverride_ property as the default is most likely too high (the default is shared for all variant types).  
You can theoretically have multiple variants in every event node. And then variant would be chosen the same way (based on weight and cooldown) as for normal random events. You can also have multiple _GenericRandomEvent_ with the same _GenericEventType_ type. But I expect you won't need more than one. Maybe in the future you could get the name of the node that was selected as a variable in the AI node, but currently it does not work like that.

If you reload concept graph you should now see the event and it's variant(s) in the random  
events debug. In the debug all generic events are under the "fake" Event place _GenericEvents_.  
Here [http://localhost:1403/player/randomEvents](http://localhost:1403/player/randomEvents)  
You can also see there all the cooldown values including the global _Generic_ cooldown at the top.  
![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

## AI

Now you need to add _FastTravelGenericRandomEvent_ barrier node (Player category) in NPCs behavior.  
You can select the _EventType_. And whether FastForward should be called.  
This node has 2 out bools.

-   _FastTravelContinuesOut_ - This is true when fast travel continues after the barrier opens. Either player succesfully evaded or no event/variant was available (most likely due to one of the 3 types of cooldown).
-   _EvadeFailedOut_ - This is true only when player tried to evade and it failed (if player agreed to stop it will be false). I expect this to be used as a crime indicator.

If this node is executed without receiving perception message from Random event system (it should be the same as normal perception message) and player chooses to stop. Player will be moved to 0 0 0. This is on purpose because it should never happen.  
If the Node is executed when player is not fast traveling, the barrier opens immediately and both out values will be _false_.  
![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

If you want to test fast travel (and map still doesn't work), you can use the CVar  
`wh_pl_FastTravelTo <entityName>` or `wh_pl_FastTravelTo x y z`  
or in case fast travel is not allowed (for example when time is stopped) `wh_pl_FakeFastTravelTo`