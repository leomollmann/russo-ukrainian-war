# Russo-Ukrainian War monitoring with NASA's FIRMS
by Leonardo Möllmann Schöller

## Why use FIRMS to detect war activity?
| ![national-park-on-fire-twitter](./docs/FIRMSByDate.PNG) |
|:--:|
| Distribution of data points by date, direct correlation |

## Motivation
---
There are several motives to this topic, the biggest one is if this model can detect the intent score of the fire it can help start independent war crimes investigations and help identify climate damage concerning the war.

## Sources
---
* Center for information resilience (twitter data on confirmed attacks) - https://github.com/mauforonda/ukraine
* FIRMS archive data - https://firms.modaps.eosdis.nasa.gov/download/
* What is FIRMS - https://www.earthdata.nasa.gov/faq/firms-faq
* How to use FIRMS data - https://www.arcgis.com/home/item.html?id=b8f4033069f141729ffb298b7418b653
* FIRMS manual - https://modis-fire.umd.edu/files/MODIS_C6_Fire_User_Guide_C.pdf
* Ukraine regions - https://geodata.lib.utexas.edu/catalog/stanford-gg870xt4706
* Ukraine cities, Nature reserves, Forests, Rails, Roads - http://download.geofabrik.de/
* Ukraine forest fires - https://ceobs.org/countries/ukraine/

## Model
---
FIRMS' detected heat signatures are relatively big events of some tons of materials burning in a period, it is mainly used to track fire paths in wildfires for later be used in prevention and data collection about how our climate is changing through the years. These fires could also be triggered by artillery or sabotage, in other words, intentional fire.

The goal is to differentiate what class the FIRMS detected fire point is, is it a direct attack or a normal accidental fire? If we look just where the fire is happening we can get some clues on what is happening but there is no definitive answer, we have some different classifications that are hard to distinguish like:

|          |Forest                        |Urban                            |
|---       |---                           |---                              |
|Accidental|Wildfire                      |Urban Fire                       |
|Attack    |Attack on Defensible Positions|Attack on Civilian Infrastructure|

With this model, we can mass classification data to track independently and in real-time where the fighting is occurring and the intensity of it.

## Annotation
---
The annotation is done by cross-relating temporal and geographical data from Twitter and NASA's FIRMS, this is done both manually and by bulk relation with data sources like the Center for Information Resilience using PostGIS queries.

Another event to consider is that with war, most services are overloaded or stopped working completely like wildfire fighting in occupied regions, one example is the Biloberezhia Sviatoslava national park which was on fire in the dry months of Russian occupation. We can hand annotate that data as an accidental fire in the period of war but this is when the lines begin to blur, we can argue a causal relation of because the war happened, this fire happened, but this will confuse our model a lot and overfit our data, so for these cases, we annotate as accidental.

| ![national-park-on-fire-twitter](./docs/BiloberezhiaSviatoslavaTwitter.PNG) |
|:--:|
| Twitter report of wildfire |

| ![national-park-on-fire-firms](./docs/BiloberezhiaSviatoslavaFIRMS.PNG) |
|:--:|
| FIRMS detected fires around 2022/05/10 |

## Data
---
### FIRMS attributes
Acquired Data:
- `point` or (`lon`, `lat`), coordinate of detection;
- `date`, datetime of detection;
- `brightness`, temperature (in Kelvin) using the MODIS channels 21/22;
- `brightness_t31`, temperature (in Kelvins) of the hotspot/active fire pixel;
- `radiative_power`, pixel-integrated fire radiative power in MW (MegaWatts), related to the rate at which fuel is being consumed;

Computed Geospatial Data:
- `dist_road`, distance to the nearest road, None if it's above 2km
- `dist_rail`, distance to the nearest railway, None if it's above 2km
- `pop_density`, average of nearest population centers weighted by distance using the following equation: $\frac{1}{\sqrt{x}+1}$

| ![LowDensity](./docs/LowDensity.PNG) | ![HighDensity](./docs/HighDensity.PNG) |
|:--:|:--:|
| Low Density Area, 3.3 avg units | High Density Area, 1524 avg units |

Model Data
- `intent`, category of the fire, 1 for accidental, 2 for attack
- `source`, where the classification comes from with 0 being predicted
- `event`, event associated with the annotation, used to intersect data with Twitter

### FIRMS data categories
|Type                              |Count  |Class    |Source|Event|
|---                               |---    |---      |---   |---  |
|2021-01-01 to 2022-02-23          |10115  |-        |      |     |
|2022-02-24 to 2022-11-07          |126027 |-        |      |     |
|1Km from a forest, before the war |6587   |Accident |1     |     |
|Biloberezhia wildfire             |431    |Accident |2     |1    |
|Center for information resilience |7269   |Attack   |3     |     |
|Siege of Matiupol                 |527    |Attack   |4     |2    |
|Siege of Sievierodonetsk          |724    |Attack   |5     |3    |
|Sviatohirsk Lavra                 |2      |?        |      |4    |

* ### 1Km from a forest, before the war

Technically, every fire before the war began was an accident, but to encourage the modal to learn more about natural forest fires, this bias was provided.

| ![AccidentalFiresBeforeWar](./docs/AccidentalFiresBeforeWar.PNG) |
|:--:|
| Geographic distribution |

|Attribute      |Mean    |
|---            |---     |
|brightness     |316.512 |
|brightness_t31 |294.206 |
|radiative_power|24.506  |
|dist_road      |333.939 |
|dist_rail      |453.745 |
|avg_population |49.794  |

* ### Biloberezhia nature reserve wildfires (Russian occupation)

In the dry season during the Russian occupation, this nature reserve burnt down as a result of negligence, no firefighting was provided

| ![Biloberezhia](./docs/Biloberezhia.PNG) |
|:--:|
| Geographic distribution |

|Attribute      |Mean    |
|---            |---     |
|brightness     |332.971 |
|brightness_t31 |294.260 |
|radiative_power|16.170  |
|dist_road      |199.367 |
|dist_rail      |-       |
|avg_population |6.340   |	

* ### Center for information resilience, Twitter correlation with FIRMS

| ![Twitter](./docs/AttacksCorrelatedByTwitter.PNG) |
|:--:|
| Geographic distribution |

| ![ControllMap](./docs/CurrentState.PNG) |
|:--:|
| Current front lines |

|Attribute      |Mean    |
|---            |---     |
|brightness     |325.193 |
|brightness_t31 |287.931 |
|radiative_power|7.597   |
|dist_road      |138.415 |
|dist_rail      |419.653 |
|avg_population |226.314 |	

* ### Siege of Mariupol

| ![Twitter](./docs/SiegeOfMariupol.PNG) |
|:--:|
| Geographic distribution |

|Attribute      |Mean    |
|---            |---     |
|brightness     |321.520 |
|brightness_t31 |279.804 |
|radiative_power|4.242   |
|dist_road      |27.391  |
|dist_rail      |323.292 |
|avg_population |839.082 |	

* ### Siege of Sievierodonetsk-Lysychansk

| ![Twitter](./docs/SiegeOfSievierodonetskLysychansk.PNG) |
|:--:|
| Geographic distribution |

|Attribute      |Mean    |
|---            |---     |
|brightness     |321.302 |
|brightness_t31 |292.513 |
|radiative_power|5.396   |
|dist_road      |78.724  |
|dist_rail      |443.373 |
|avg_population |271.664 |