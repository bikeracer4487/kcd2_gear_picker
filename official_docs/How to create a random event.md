## Events debug

Web debugger connects to the running instance of editor/game and can be used to manually spawn events and tweak spawn settings for debug purposes. It also visualize probability curves and other data.

[http://localhost:1403/player/randomEvents](http://localhost:1403/player/randomEvents)

## Skald nodes

The event system provides several new nodes in Skald. All of them are of module type:

-   [Random event node](https://youtrack.warhorsestudios.cz/articles/KCD2-A-9094/Random-event-node)
-   [Random event variant node](https://youtrack.warhorsestudios.cz/articles/KCD2-A-9095/Random-event-variant-node)
-   [Random event place node](https://youtrack.warhorsestudios.cz/articles/KCD2-A-9096/Event-place-node)

## Event creation tutorial

The event creation pipeline consists of the following steps:

1.  Create a _random event_ node (event definition) in Skald:
2.  Create a _random event variant_ node inside your newly created _random event_ node.
3.  Create or reuse an _event place_ module
4.  Instantiate your _random event_ node in the chosen _event place_ module
5.  Create and link event entities in the level

Let's look into each step in detail.

## 1. Create an event definition

Firstly, we need to create an event definition. If it's a quest event, create a library inside your quest module. Your event definition would be located there.

If it's a general event, then use already created library in the root. All general events definitions are located in the library at "Barbora/random\_events":

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

Inside the library, create a _random event_ definition node. Convention for event naming is the same as with quests and is decribed here: KCD2-A-8335.

Change the default name to lowerCamelCase. In our example that would be _crimeScene._

_(Please ignore englishness of the event name in this particular example..._ 🤫)

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

Select it and set its Cooldown and Tags properties if needed. Or leave them with default values for now:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

## 2. Create an event variant

Open an event definition in the random events library at "Barbora/random\_events" and create a _random event variant_ node there:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

Select your newly created variant and set its properties.

### Create NPC group and soul pool

If your event should spawn NPCs add a new NPC group under the variant's properties:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

Once created:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

To specify which souls should be spawned you can choose between two properties: _soul name_ or _soul pool._ If you only need to spawn a particular static soul, just fill its name in _soul name_ property and skip _soul pool._ If you need to spawn a random soul from a predefined pool of possible souls, skip _soul name_ property and choose a _soul pool_ from the list.

**Soul pool** is just an array of soul names, defined in an XML file at "Tables\\rpg\\SoulPool.xml". Open it and there you will find all existing soul pools in the game. For structuring and separating soul pools from different events, I recommend using a comment tag at the top of the soul pools block, just to describe where these soul pools are used.

_Soul name_ property is just a shortcut for soul pool, it creates an one-entry soul pool under the hood automatically.

**NPC Group** also defines additional spawning settings:

-   Tag points — an asset for tag points, where NPCs would be spawned
-   NPC Asset name — an asset to store a reference to spawned NPCs
-   Scheduler proxy — an asset name string of a LinkableObject that acts as a scheduler proxy for the spawned NPCs
-   Count — defines how many NPCs should be spawned from the soul pool
-   Count SD — standard deviation of the normal distribution defined around _count_ property. If set to zero, normal distribution is not used and exact count would be spawned

A variant can have several NPC Groups, that allows you to define different scheduler proxy and spawn points for specific NPCs in your event if needed.

## 3. Create or reuse Random event places

Event places are tied to the level, so decide if you need Trosecko or Kutnohorsko. For Trosecko you can find all event places in module "Event places" at "Barbora/Trosecko/eventPlaces":

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

(For Kutnohorsko it's the same, you can find all event places at "Barbora/Kutnohorsko/eventPlaces")

Open the gameplay module and you'll see all the existing event places in the level Trosecko:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

All of these modules are instantiated _random event place_ nodes. If you want your event to take place on an already existing event place, just open the module you need and proceed to the next step.

If you need a new event place, welcome to the KCD2-A-9462

## 4. Instantiate Random event definition inside the Event place module

Open the event place module and instantiate the previously created random event definition node there:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

This is an instance of the event definition. It is tied to an actual event place in the level. When you meet an event in the game, you trigger an instance, not a definition. It has its own state separated from other instances. That allows you to communicate with a particular instance of event. For example, if you want to disable only one specific instance, you can create an additional input port on the event definition that would disable the event, and later connect this port only to specific instances which are located under event place modules.

## 4. Create and link event entities in the level

Once the event is instantiated in Skald, we need to connect it to the actual event entities in level. Let's create an event layer under the event place and name it after event. To illustrate how several events under the same event place are organized, I have also created dummy layers for other events _prepadeniNaCeste_ and _ztratyANalezy_.

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

Inside the event layer there is a structure of layers:

-   static
    -   \_script
    -   \_enviro
    -   \_common
-   streamed
    -   variant1
        -   \_script
        -   \_enviro
        -   \_common
    -   variant2
        -   \_script
        -   …

All static things that exist in the level all the time, like random event entities or spawn points, are placed under the _static/_ layer. Things that are streamed when the specific variant of the event is spawned are placed under _streamed/<variant\_name\>/_ layers:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

### Event entities

Add a Random event entity to the previously created _static/\_script_ layer. You can find the entity in the editor under the "Object/Entity" tab. You can filter the entities by name _RandomEvent_.

Name it regionСode\_eventPlaceName\_eventName. In our case it's _tvid\_road2\_crimeScene_.

Create a link from the event place entity to the event entity and name it _module\['<event\_name\_in\_skald\>'\]_:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

### Variant profile holders

TODO: write about dynamic profiles and event global profile

Now let's create a profile for our bandits variant layer, to be able to stream it once the variant is spawned. The convention for naming is: event\_regionCode\_eventPlaceName\_eventName\_variantName. In our case it's _event\_tvid\_road2\_crimescene\_bandits_. Make _game_ and _events_ profile as parent profiles and select _bandits_ as a streaming layer.

**Switch to Skald**. Create a new asset of _Profile_ type. Choose it in _Profile_ property on the variant properties pane and select your newly created profile from the dropmenu. When the event system would choose this variant to spawn, it will also stream the selected profile.

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

### Spawn points

Now let's add some spawn points for event NPCs. Create two tag points inside static/\_script layer and link them from random event entity by asset name of your choice.

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

Once created, lets switch to the Skald and create asset for them there. I want to reuse these spawn points for all variants, so I'll create an asset in Random event module instead of a particular variant module:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

These spawn points can now be used in _Tag points_ property of NPC Group, to define where would NPC from that group spawn:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)

### Scheduler proxy

Scheduler proxy is used to define scheduler links for spawned NPCs. For scheduler proxy lets add another tag point to static/\_script and link it from random event entity:

![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)  
![](data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22currentColor%22%20viewBox%3D%220%200%2016%2016%22%3E%0A%20%20%3Cpath%20fill-rule%3D%22evenodd%22%20d%3D%22M7.979%201.053C9.542%201%2010.751%201.9%2011.354%203.009c.588%201.084.703%202.578-.166%203.802-.306.43-.67.783-1.012%201.093l-.337.299c-.223.196-.429.377-.631.58-.263.263-.462.52-.595.82-.131.297-.213.67-.19%201.186a.7.7%200%201%201-1.398.063c-.032-.705.079-1.297.307-1.815.227-.512.551-.909.885-1.243.235-.236.497-.466.737-.678.1-.087.195-.171.283-.251.321-.29.594-.562.81-.865.5-.703.464-1.61.076-2.323-.388-.715-1.142-1.257-2.097-1.225-.966.032-1.548.418-1.905.878l-.536-.416.536.416a2.704%202.704%200%200%200-.538%201.606.7.7%200%201%201-1.4%200c0-.758.234-1.693.831-2.464C5.63%201.68%206.602%201.1%207.98%201.052Z%22%20clip-rule%3D%22evenodd%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M8.672%2014.043a.951.951%200%201%201-1.902%200%20.951.951%200%200%201%201.902%200Z%22%2F%3E%0A%3C%2Fsvg%3E)