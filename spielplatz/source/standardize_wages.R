library(dplyr)

wdi <- get_data360_api("WB_WDI")

# 2. Clean names for convenience
df <- dat %>%
  rename(
    gdp_current_lcu = NY.GDP.MKTP.CN,
    ppp_factor      = PA.NUS.PPP,
    gdp_deflator    = NY.GDP.DEFL.ZS,
    gdp_const2017ppp_official = NY.GDP.MKTP.PP.KD
  )

# 3. Construct GDP in current PPP dollars
df <- df %>%
  mutate(
    gdp_current_ppp = gdp_current_lcu / ppp_factor
  )

# 4. Rebase to constant 2017 PPP dollars
# Step A: Extract base-year deflator (2017 = 100 in international $ terms)
base_deflator <- df %>%
  filter(year == 2017) %>%
  select(iso2c, gdp_deflator) %>%
  rename(deflator_2017 = gdp_deflator)

# Step B: Apply rebasing
df <- df %>%
  left_join(base_deflator, by = "iso2c") %>%
  mutate(
    gdp_const2017_ppp_rebuilt = gdp_current_ppp / (gdp_deflator / deflator_2017)
  )
