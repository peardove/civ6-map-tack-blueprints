-- Built-in blueprint for the official Gathering Storm Huge TSL Earth map.
-- Coordinates use Civilization VI's zero-based (x, y) plot coordinates.

MTB_TSL_HUGE_AUSTRALIA = {
  id = "tsl_huge_australia_harbor_trade",
  ownedNamePrefix = "[MTB-AU]",
  titleKey = "LOC_MTB_BLUEPRINT_AUSTRALIA_TITLE",
  descriptionKey = "LOC_MTB_BLUEPRINT_AUSTRALIA_DESCRIPTION",
  map = {
    width = 130,
    height = 66,
    -- Terrain-only anchors are stable even when resources, ley lines, huts,
    -- and other dynamic layers differ between games.
    anchors = {
      { x = 115, y = 13, terrain = "TERRAIN_PLAINS" },
      { x = 117, y = 14, terrain = "TERRAIN_COAST" },
      { x = 112, y = 15, terrain = "TERRAIN_GRASS" },
      { x = 114, y = 22, terrain = "TERRAIN_PLAINS" },
      { x = 123, y = 9,  terrain = "TERRAIN_PLAINS_HILLS" },
      { x = 110, y = 27, terrain = "TERRAIN_PLAINS" },
    },
  },
  plans = {
    { cityCount = 6, titleKey = "LOC_MTB_PLAN_6", adjacency = 60 },
    { cityCount = 8, titleKey = "LOC_MTB_PLAN_8", adjacency = 80 },
    { cityCount = 10, titleKey = "LOC_MTB_PLAN_10", adjacency = 100 },
  },
  cities = {
    {
      labelKey = "LOC_MTB_CITY_01",
      city = { x = 115, y = 13 },
      harbor = { x = 115, y = 12 },
      commercialHub = { x = 114, y = 13 },
    },
    {
      labelKey = "LOC_MTB_CITY_02",
      city = { x = 112, y = 15 },
      harbor = { x = 112, y = 14 },
      commercialHub = { x = 113, y = 14 },
    },
    {
      labelKey = "LOC_MTB_CITY_03",
      city = { x = 117, y = 18 },
      harbor = { x = 118, y = 18 },
      commercialHub = { x = 117, y = 17 },
    },
    {
      labelKey = "LOC_MTB_CITY_04",
      city = { x = 114, y = 22 },
      harbor = { x = 114, y = 23 },
      commercialHub = { x = 113, y = 23 },
    },
    {
      labelKey = "LOC_MTB_CITY_05",
      city = { x = 109, y = 22 },
      harbor = { x = 108, y = 23 },
      commercialHub = { x = 108, y = 22 },
    },
    {
      labelKey = "LOC_MTB_CITY_06",
      city = { x = 104, y = 15 },
      harbor = { x = 105, y = 14 },
      commercialHub = { x = 105, y = 15 },
    },
    {
      labelKey = "LOC_MTB_CITY_07",
      city = { x = 125, y = 13 },
      harbor = { x = 125, y = 12 },
      commercialHub = { x = 126, y = 12 },
    },
    {
      labelKey = "LOC_MTB_CITY_08",
      city = { x = 123, y = 9 },
      harbor = { x = 124, y = 8 },
      commercialHub = { x = 124, y = 9 },
    },
    {
      labelKey = "LOC_MTB_CITY_09",
      city = { x = 106, y = 25 },
      harbor = { x = 107, y = 24 },
      commercialHub = { x = 107, y = 25 },
    },
    {
      labelKey = "LOC_MTB_CITY_10",
      city = { x = 110, y = 27 },
      harbor = { x = 109, y = 27 },
      commercialHub = { x = 110, y = 28 },
    },
  },
}
