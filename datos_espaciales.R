<<<<<<< HEAD
# Instalación de sf
install.packages("sf")
# Carga de sf
library(sf)
### Los métodos son funciones que se usan para la programación orientada a objetos. ver en la consolads
### cargar datos del SNIT 
# Lectura de una capa vectorial (GeoJSON) de provincias de Costa Rica
provincias <-
  st_read(
    "provincias.gpkg",
    quiet = TRUE # para evitar el despliegue de mensajes
  )

# Lectura de un archivo CSV con registros de presencia de felinos en Costa Rica
felinos <-
  st_read(
    "felinos.csv",
    options = c(
      "X_POSSIBLE_NAMES=decimalLongitude", # argumento columna de longitud decimal
      "Y_POSSIBLE_NAMES=decimalLatitude"   # argumento columna de latitud decimal
    ),
    quiet = TRUE
  )

# Clase del objeto provincias
class(provincias)
# Clase del objeto felinos 
class (felinos)

# Información general sobre el objeto provincias
provincias

# El método st_crs() retorna el CRS de un objeto sf.
# Despliegue del CRS del objeto provincias y felinos 
st_crs(provincias)
st_crs(felinos)

#"st_crs()" también puede asignar un CRS a un objeto sf que no lo tiene (felinos9.

# Asignación de un CRS al objeto felinos
st_crs(felinos) <- 4326 #WGS84

#revisar la proyección de felinos 
st_crs(felinos) 

## El método st_transform() transforma un objeto sf a un nuevo CRS.

# Transformación del CRS del objeto provincias a WGS84 (EPSG = 4326)
provincias <-
  provincias |>
  st_transform(4326) 

# verificar proyección consola

# El método plot() grafica objetos sf en un mapa.
# Mapeo de las geometrías del objeto provincias
#revisar si geometry o geom en la capa  para el tipo de datos si es SHP, gpkh u otro
plot(provincias["area"])
# Mapeo con argumentos adicionales de plot()
plot(
  provincias$geom,
  extent = st_bbox(c(xmin = -86.0, xmax = -82.3, ymin = 8.0, ymax = 11.3)),
  main = "Provincias de Costa Rica",
  axes = TRUE,
  graticule = TRUE
)
#agregarle capa  
# Los argumentos reset y add de plot() permiten generar un mapa con varias capas.

# Primera capa del mapa
plot(
  provincias$geom,
  extent = st_bbox(c(xmin = -86.0, xmax = -82.3, ymin = 8.0, ymax = 11.3)),
  main = "Registros de presencia de felinos en Costa Rica",
  axes = TRUE,
  graticule = TRUE,
  reset = FALSE # Para que no reinice el mapa en la próxima
)

# Segunda capa
plot(felinos$geometry,
     add = TRUE,  # agregar puntos sobre polígonos   
     pch = 16,
     col = "cadetblue")
# crear el SHP ou otro salida KML, gpkg
provincias |>
  st_write("provincias.shp")

# Escritura del objeto felinos en formato shp
felinos |>
  st_write("felinos.shp")

## como sobre escribir en una archivo:

##

# El paquete leaflet genera mapas interactivos en lenguaje de marcado de hipertexto (HTML), 
# el lenguaje de marcado utilizado para desarrollar páginas web.

# Instalación de leaflet, genera mapa editable
install.packages("leaflet")
library(leaflet)

# Mapa leaflet básico de provincias y registros de presencia de felinos
leaflet() |>
  setView(# centro y nivel inicial de acercamiento
    lng = -84.19452,
    lat = 9.572735,
    zoom = 7) |>
  addTiles(group = "OpenStreetMap") |> # capa base de OSM
  addPolygons(
    # capa de provincias (polígonos)
    data = provincias,
    color = "black",
    fillColor = "transparent",
    stroke = TRUE,
    weight = 1.3
  ) |>
  addCircleMarkers(
    # capa de registros de presencia (puntos)
    data = felinos,
    stroke = F, #borde del la fomra F, FALSE
    radius = 4, # en píxeles
    fillColor = 'blue',
    fillOpacity = 1, # de cero a uno
    group = "Felinos",
    popup = paste(
      paste0("<strong>Especie: </strong>", felinos$species),
      paste0("<strong>Localidad: </strong>", felinos$locality),
      paste0("<strong>Fecha: </strong>", felinos$eventDate),
      paste0("<strong>Fuente: </strong>", felinos$institutionCode),
      paste0("<a href='", felinos$occurrenceID, "'>Más información</a>"),
      sep = '<br/>'
    )
  ) |>
  addLayersControl(# control de capas
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Felinos"))


## cargar nuevas librerías 

# Instalación de leaflet.extras (funciones adicionales de leaflet)
install.packages("leaflet.extras")

# Instalación de leaflem (funciones adicionales de leaflet)
install.packages("leafem")

# Carga de leaflet.extras
library(leaflet.extras)

# Carga de leafem
library(leafem)

### nuevos elementos del mapa interactivo 

# Mapa leaflet básico de provincias y registros de presencia de felinos
leaflet() |>
  setView(# centro y nivel inicial de acercamiento
    lng = -84.19452,
    lat = 9.572735,
    zoom = 7) |>
  addHeatmap( data = felinos,
             
             lng = ~decimalLongitude, 
             lat = ~ decimalLatitude,
             radius = 20)|>
  addTiles(group = "OpenStreetMap") |> # capa base de OSM |>
  addProviderTiles(providers$Esri.NatGeoWorldMap, group = "Esri.NatGeoWorldMap") |> #agregar otra capa base siemrpe con los pipes
  addProviderTiles(providers$Esri.WorldTopoMap , group = "Esri.WorldTopoMap")|>
  addPolygons(
    # capa de provincias (polígonos)
    data = provincias,
    color = "black",
    fillColor = "transparent",
    stroke = TRUE,
    weight = 1.0,
    group="Provincias"
  ) |>
  addCircleMarkers(
    # capa de registros de presencia (puntos)
    clusterOptions = markerClusterOptions(), #añadir cluster
    data = felinos,
    stroke = F,
    radius = 4,
    fillColor = 'blue',
    fillOpacity = 1,
    group = "Felinos",
    popup = paste(
      paste0("<strong>Especie: </strong>", felinos$species),
      paste0("<strong>Localidad: </strong>", felinos$locality),
      paste0("<strong>Fecha: </strong>", felinos$eventDate),
      paste0("<strong>Fuente: </strong>", felinos$institutionCode),
      paste0("<a href='", felinos$occurrenceID, "'>Más información</a>"),
      sep = '<br/>'
    )
  ) |>
  addLayersControl(
    baseGroups = c("OpenStreetMap", "Esri.NatGeoWorldMap", "Esri.WorldTopoMap"),
    overlayGroups = c("Provincias","Felinos")) |> # control de capas
  addResetMapButton() |> # botón de reinicio
  addSearchOSM() |> # búsqueda en OSM
  addMouseCoordinates() |> # coordenadas del puntero del ratón
  addScaleBar(position = "bottomleft", options = scaleBarOptions(imperial = FALSE)) |> # barra de escala
  addMiniMap(position = "bottomleft") # mapa de ubicación

### Como cargar un ráster en R/cargar paquete terra
install.packages("terra")
library(terra)

## cargar raáster 
# Lectura de una capa raster de altitud
altitud <-
  rast(
    "altitud.tif"
  )
class(altitud)

# Información general sobre el objeto altitud
altitud

# CRS del objeto altitud
crs(altitud)

# Asignación de un CRS a una copia del objeto altitud
altitud_crtm05 <- altitud
crs(altitud_crtm05) <- "EPSG:5367"

# Consulta
crs(altitud_crtm05)

# Transformación del CRS del objeto altitud
altitud_utm17N <-
  altitud |>
  project("EPSG:8910")

# Consulta
crs(altitud_utm17N)

plot(altitud)


## como plotear raster en leaflet 

install.packages("terra")
install.packages("rgdal")
library(terra)
library(rgdal)

# Paleta de colores de altitud de Costa Rica
colores_altitud <-
  colorNumeric(terrain.colors(10),
               values(altitud),
               na.color = "transparent")

# Mapa leaflet básico con capas de altitud, provincias y registros de presencia de felinos
leaflet() |>
  setView(# centro y nivel inicial de acercamiento
    lng = -84.19452,
    lat = 9.572735,
    zoom = 7) |>  
  addTiles(group = "OpenStreetMap") |> # capa base de OSM
  addRasterImage( # capa raster
    raster(altitud), # conversión de SpatRaster a RasterLayer 
    colors = colores_altitud, # paleta de colores
    opacity = 0.6,
    group = "Altitud",
  ) |>
  addLegend(
    title = "Altitud",
    values = values(altitud),
    pal = colores_altitud,
    position = "bottomleft",
    group = "Altitud"
  ) |>
  addPolygons(
    data = provincias,
    color = "black",
    fillColor = "transparent",
    stroke = TRUE,
    weight = 1.0,
    group = "Provincias"
  ) |>
  addCircleMarkers(
    data = felinos,
    stroke = F,
    radius = 4,
    fillColor = 'blue',
    fillOpacity = 1,
    group = "Felinos",
    popup = paste(
      paste0("<strong>Especie: </strong>", felinos$species),
      paste0("<strong>Localidad: </strong>", felinos$locality),
      paste0("<strong>Fecha: </strong>", felinos$eventDate),
      paste0("<strong>Fuente: </strong>", felinos$institutionCode),
      paste0("<a href='", felinos$occurrenceID, "'>Más información</a>"),
      sep = '<br/>'
    )    
  ) |>
  addLayersControl(
    # control de capas
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Altitud", "Provincias", "Felinos")
  )
=======
# Instalación de sf
install.packages("sf")
# Carga de sf
library(sf)
### Los métodos son funciones que se usan para la programación orientada a objetos. ver en la consolads
### cargar datos del SNIT 
# Lectura de una capa vectorial (GeoJSON) de provincias de Costa Rica
provincias <-
  st_read(
    "provincias.gpkg",
    quiet = TRUE # para evitar el despliegue de mensajes
  )

# Lectura de un archivo CSV con registros de presencia de felinos en Costa Rica
felinos <-
  st_read(
    "felinos.csv",
    options = c(
      "X_POSSIBLE_NAMES=decimalLongitude", # argumento columna de longitud decimal
      "Y_POSSIBLE_NAMES=decimalLatitude"   # argumento columna de latitud decimal
    ),
    quiet = TRUE
  )

# Clase del objeto provincias
class(provincias)
# Clase del objeto felinos 
class (felinos)

# Información general sobre el objeto provincias
provincias

# El método st_crs() retorna el CRS de un objeto sf.
# Despliegue del CRS del objeto provincias y felinos 
st_crs(provincias)
st_crs(felinos)

#"st_crs()" también puede asignar un CRS a un objeto sf que no lo tiene (felinos9.

# Asignación de un CRS al objeto felinos
st_crs(felinos) <- 4326 #WGS84

#revisar la proyección de felinos 
st_crs(felinos) 

## El método st_transform() transforma un objeto sf a un nuevo CRS.

# Transformación del CRS del objeto provincias a WGS84 (EPSG = 4326)
provincias <-
  provincias |>
  st_transform(4326) 

# verificar proyección consola

# El método plot() grafica objetos sf en un mapa.
# Mapeo de las geometrías del objeto provincias
#revisar si geometry o geom en la capa  para el tipo de datos si es SHP, gpkh u otro
plot(provincias["area"])
# Mapeo con argumentos adicionales de plot()
plot(
  provincias$geom,
  extent = st_bbox(c(xmin = -86.0, xmax = -82.3, ymin = 8.0, ymax = 11.3)),
  main = "Provincias de Costa Rica",
  axes = TRUE,
  graticule = TRUE
)
#agregarle capa  
# Los argumentos reset y add de plot() permiten generar un mapa con varias capas.

# Primera capa del mapa
plot(
  provincias$geom,
  extent = st_bbox(c(xmin = -86.0, xmax = -82.3, ymin = 8.0, ymax = 11.3)),
  main = "Registros de presencia de felinos en Costa Rica",
  axes = TRUE,
  graticule = TRUE,
  reset = FALSE # Para que no reinice el mapa en la próxima
)

# Segunda capa
plot(felinos$geometry,
     add = TRUE,  # agregar puntos sobre polígonos   
     pch = 16,
     col = "cadetblue")
# crear el SHP ou otro salida KML, gpkg
provincias |>
  st_write("provincias.shp")

# Escritura del objeto felinos en formato shp
felinos |>
  st_write("felinos.shp")
# El paquete leaflet genera mapas interactivos en lenguaje de marcado de hipertexto (HTML), 
# el lenguaje de marcado utilizado para desarrollar páginas web.

# Instalación de leaflet, genera mapa editable
install.packages("leaflet")
library(leaflet)

# Mapa leaflet básico de provincias y registros de presencia de felinos
leaflet() |>
  setView(# centro y nivel inicial de acercamiento
    lng = -84.19452,
    lat = 9.572735,
    zoom = 7) |>
  addTiles(group = "OpenStreetMap") |> # capa base de OSM
  addPolygons(
    # capa de provincias (polígonos)
    data = provincias,
    color = "black",
    fillColor = "transparent",
    stroke = TRUE,
    weight = 1.3
  ) |>
  addCircleMarkers(
    # capa de registros de presencia (puntos)
    data = felinos,
    stroke = F, #borde del la fomra F, FALSE
    radius = 4, # en píxeles
    fillColor = 'blue',
    fillOpacity = 1, # de cero a uno
    group = "Felinos",
    popup = paste(
      paste0("<strong>Especie: </strong>", felinos$species),
      paste0("<strong>Localidad: </strong>", felinos$locality),
      paste0("<strong>Fecha: </strong>", felinos$eventDate),
      paste0("<strong>Fuente: </strong>", felinos$institutionCode),
      paste0("<a href='", felinos$occurrenceID, "'>Más información</a>"),
      sep = '<br/>'
    )
  ) |>
  addLayersControl(# control de capas
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Felinos"))


## cargar nuevas librerías 

# Instalación de leaflet.extras (funciones adicionales de leaflet)
install.packages("leaflet.extras")

# Instalación de leaflem (funciones adicionales de leaflet)
install.packages("leafem")

# Carga de leaflet.extras
library(leaflet.extras)

# Carga de leafem
library(leafem)

### nuevos elementos del mapa interactivo 

# Mapa leaflet básico de provincias y registros de presencia de felinos
leaflet() |>
  setView(# centro y nivel inicial de acercamiento
    lng = -84.19452,
    lat = 9.572735,
    zoom = 7) |>
  addTiles(group = "OpenStreetMap") |> # capa base de OSM |>
  addPolygons(
    # capa de provincias (polígonos)
    data = provincias,
    color = "black",
    fillColor = "transparent",
    stroke = TRUE,
    weight = 1.0
  ) |>
  addCircleMarkers(
    # capa de registros de presencia (puntos)
    data = felinos,
    stroke = F,
    radius = 4,
    fillColor = 'blue',
    fillOpacity = 1,
    group = "Felinos",
    popup = paste(
      paste0("<strong>Especie: </strong>", felinos$species),
      paste0("<strong>Localidad: </strong>", felinos$locality),
      paste0("<strong>Fecha: </strong>", felinos$eventDate),
      paste0("<strong>Fuente: </strong>", felinos$institutionCode),
      paste0("<a href='", felinos$occurrenceID, "'>Más información</a>"),
      sep = '<br/>'
    )
  ) |>
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Felinos")) |> # control de capas
  addResetMapButton() |> # botón de reinicio
  addSearchOSM() |> # búsqueda en OSM
  addMouseCoordinates() |> # coordenadas del puntero del ratón
  addScaleBar(position = "bottomleft", options = scaleBarOptions(imperial = FALSE)) |> # barra de escala
  addMiniMap(position = "bottomleft") # mapa de ubicación
>>>>>>> f9c47f49e40e53643669f3e4f3709e1beddc4f4b
