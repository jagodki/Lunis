# Lunis
<img src="Icons/appIcon.png"/><br>
A native application for iPhones to show the reachabilities and locations of schools in an interactive map.

## Goal of the project
### Description
Information about schools are often published at websites of cities.
People, who e.g. are interested in the schools of several cities, have to visit several websites to get all information they want.
These websites have different structure and also the presentation and the information of the schools are different.
The app Lunis provides data about schools from different cities in one place and in the same and comparable structure.
An important point of choosing a school for the own children is the location and reachability of schools.
Therefore the core function of the app is a map presentation of the schools, where the user can see the location of the schools
and also their area, where all other schools of a city are more far away.
The app also provides a functionality to calculate the shortest distance to the schools.
To provide all these information, the data about the schools have to preprocessed manually, i.e. not all cities and their
schools can be found in the app.

### Available cities with their schools
#### Germany
- Meißen (Sachsen)
- Radebeul (Sachsen)

### Available localisations for this app
- 🇩🇪 Deutsch
- 🇬🇧 English
- 🇫🇷 Français
- 🇵🇱 Polski
- 🇸🇪 Svenska

### Legal
The source code of the app is published under the terms of the Apache 2.0 license and can be used by everyone without any charge.
<br>
The information about the schools, that are used, are free available, the specific sources can be read in the detail view of the donwload tab:
<img src=""/>
<br>
Data from OpenStreetMap is used to calculate the reachabilities of the schools.
<br>
#### Privacy Policy
- <a href="https://github.com/jagodki/Lunis/blob/master/Privacy%20Policies/pp_de.md">Deutsch</a>
- <a href="https://github.com/jagodki/Lunis/blob/master/Privacy%20Policies/pp_en.md">English</a>
- <a href="https://github.com/jagodki/Lunis/blob/master/Privacy%20Policies/pp_fr.md">Français</a>
- <a href="https://github.com/jagodki/Lunis/blob/master/Privacy%20Policies/pp_pl.md">Polski</a>
- <a href="https://github.com/jagodki/Lunis/blob/master/Privacy%20Policies/pp_se.md">Svenska</a>

## Contact
If you have questions about the app, the preparation of the data or you want data of your city/schools in the app,
then you can contact me via GitHub or via mail:
<br>
<a href="jagodki.cj@gmail.com">jagodki.cj@gmail.com</a>

## Usage of the app
### Download
The download tab provides all cities, whose schools can be downloaded. You can choose between a map presentation and a list.
The list will be grouped by countries. If you select an entry, a new detailed view will be opend with information about this city, 
the source of the school information etc. From there you can download the data or, if the data is already on your device,
delete the datasets.

### Map
All downloaded schools have coordinates and will be displayed on the map. The map tab provides several buttons:
<img src=""/>
1 - you can search the visible schools by their name
2 - you can show your current position for comparing it to the location of the schools
3 - you can choose the schools, that will be presented on the map (all schools, just the filtered schools, just the favourite schools)
4 - this button will show a hexagonal raster on the map. Each raster cell will be coloured with the same colour of the nearest school. A cell will be grey if two or more schools have the same distance to this cell.
5 - this button opens a new view. In this view the visible schools on the map will be arranged by their distance to your current position.

### List of all schools
The schools on your device will also be provided in list form. You can filter the list e.g. to show only a special school type.
There is also the possibility to (un-)mark a school as favourite using a swish gesture like in the mail app:
<img src=""/>
And you can also (un-)mark several schools at once as favourites:
<img src=""/>
The swish gesture shows an additional button for changing to the maps tab and zooming to the school:
<img src=""/>
The segmented control on top of the view gives you the possiblity to scroll only through the filtered or favourite schools.

###Reachability of a school
The detail view of a school contains a button at the end of the view:
<img src=""/>
A new view with a map into it will be opend after tapping this button. On the map you can see a hexagonal raster
with a colour ramp to indicate the average distance in the raster cells to the selected school (green = low distance,
red = high distance, grey = distance cannot be calculated). You can show your current position by tapping this button:
<img src=""/>
If you long press into the map, a pin will drop down and the average distance at this position will be presented:
<img src=""/>


### More
The more tab provides access to the privacy policy and to the information about the source code and the icon sources.

## Technical information
### Architecture of the app
The datasets provided for the download are stored in CloudKit, whereupon these datasets contain the spatial data in GeoJSON files.
After downloading these files, the the GeoJSON-files will be parsed into Swift-objects and stored in CoreData directly on the device.
All the spatial objects schon in the map tab are stored locally. The app is an example for providing and using small, static spatial data
without the usage of OGC services. Because of the internal storage of the spatial data, the cartographic presentation is very fast.
Just the background map and the download needs an access to the internet. The cartographic work is done by the MapKit framework.

### Data preparation
A detailed description and all scripts for processing data for this project can be found in the <a href="">lunis_data_preparation</a> project.
If you want to contribute datasets, please upload (via push request) them to this project.
