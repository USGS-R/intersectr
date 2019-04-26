context("curvilinear")

test_that("curvilinear", {
  library(ncmeta)
  nc_file <- system.file("nc/test_stageiv_xyt.nc", package = "stars")

  nc_var <- nc_vars(nc_file)
  variable_name <- nc_var$name[1]

  nc_coord_vars <- nc_coord_var(nc_file, variable_name)

  x_var <- nc_coord_vars$X
  y_var <- nc_coord_vars$Y
  t_var <- nc_coord_vars$T

  nc <- RNetCDF::open.nc(nc_file)

  x <- RNetCDF::var.get.nc(nc, x_var, unpack = TRUE)
  y <- RNetCDF::var.get.nc(nc, y_var, unpack = TRUE)

  geom <- sf::read_sf(system.file("shape/nc.shp", package = "sf")) %>%
    st_transform(5070)

  geom <- geom[5, ]

  in_prj <- "+init=epsg:4326"

  cell_geometry <- suppressWarnings(
    create_cell_geometry(x, y, in_prj, geom))

  expect(nrow(cell_geometry) == 340)

  cell_geometry <- suppressWarnings(
    create_cell_geometry(x, y, in_prj, geom, 10000))

  expect(nrow(cell_geometry) == 700)

  data_source_cells <- st_sf(select(cell_geometry, grid_ids))
  target_polygons <- st_sf(select(geom, CNTY_ID))

  sf::st_agr(data_source_cells) <- "constant"
  sf::st_agr(target_polygons) <- "constant"

  area_weights <- calculate_area_intersection_weights(
    data_source_cells,
    target_polygons)

  suppressWarnings(intersected <- execute_intersection(nc_file, variable_name, area_weights,
                                      cell_geometry, x_var, y_var, t_var))

  expect_equal(intersected$`1832`[intersected$time_stamp == as.POSIXct("2018-09-14 15:00:00", tz = "UTC")],
               0.77, tolerance = 0.1)

  nc_file <- system.file("extdata/test_stageiv_xyt_borked.nc", package = "intersectr")
  nc <- RNetCDF::open.nc(nc_file)

  x <- RNetCDF::var.get.nc(nc, x_var, unpack = TRUE)
  y <- RNetCDF::var.get.nc(nc, y_var, unpack = TRUE)

  cell_geometry <- suppressWarnings(
    create_cell_geometry(x, y, in_prj, geom))

  data_source_cells <- st_sf(select(cell_geometry, grid_ids))

  area_weights <- calculate_area_intersection_weights(
    data_source_cells,
    target_polygons)

  suppressWarnings(intersected <- execute_intersection(nc_file, variable_name, area_weights,
                                                       cell_geometry, x_var, y_var, t_var))

  expect_equal(intersected$`1832`[intersected$time_stamp == as.POSIXct("2018-09-14 15:00:00", tz = "UTC")],
               0.77, tolerance = 0.1)

  # cell_geometry_2 <- cell_geometry
  # cell_geometry_2$geometry <- cell_geometry_2$geometry + 500
  #
  # target_polygons <- st_sf(select(cell_geometry_2, grid_ids_2 = grid_ids))
  #
  # area_weights <- calculate_area_intersection_weights(
  #   data_source_cells,
  #   target_polygons)
  #
  # suppressWarnings(intersected <- execute_intersection(nc_file, variable_name, area_weights,
  #                                                      cell_geometry, x_var, y_var, t_var))
})

# geom_data <- select(target_polygons, grid_ids_2)
# g_names <- as.numeric(names(intersected)[2:ncol(intersected)])
#
# plot_fun <- function(row, geom_data, intersected, g_names) {
#   geom_data <- geom_data %>%
#     dplyr::left_join(data.frame(grid_ids_2 = g_names,
#                                 poly_data = as.numeric(intersected[row, 2:ncol(intersected)]),
#                                 stringsAsFactors = FALSE),
#                      by = "grid_ids_2")
#   plot(geom_data["poly_data"], border = NA, breaks = c(0,10,20,30,40,50,60,70,80,90,100))
# }
#
# gifski::save_gif(lapply(1:nrow(intersected), plot_fun, intersected = intersected, geom_data = geom_data,
#                         g_names = g_names), gif_file = "test.gif")