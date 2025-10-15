# renv::install(c('polyglotr', 'dplyr', 'stringr', 'tcltk', 'purrr'))

### To-Do
# Add error detection/handling
# Enable command line arguments for target columns

renv::restore()

library(polyglotr) # Language detection & translation
library(dplyr) # Data wrangling
library(stringr) # String manipulation
library(tcltk) # File/folder selection
library(purrr) # TBD

print('Select CSV to translate...')
filepath <- tk_choose.files(caption = 'Select the CSV file you want to import')

print('Reading in CSV file...')
filename <- basename(filepath) %>% 
  str_remove('.csv')
df_to_translate <- read.csv(filepath)
df_test <- df_to_translate %>% 
  dplyr::filter(language != 'English') %>% 
  dplyr::slice_sample(., n = 15)

# Function to translate text from dataframe
translate_df_text <- function(col_w_text, col_w_language) {
  if (col_w_language != 'English') {
    translated_text <- stringr::str_squish(polyglotr::google_translate(
      as.character(col_w_text),
      target_language = 'en'
    )) %>% 
      iconv(., "UTF-8", "ASCII", sub = "")
  } else {
    translated_text <- stringr::str_squish(col_w_text)
  }

  return(translated_text)
}

print('Translating file...')
translated_df <- df_test %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    translation = translate_df_text(body, language), # These colomns of interest are currently hard-coded
    Date = as.Date(substr(date, 1, 10))
  ) %>%
  dplyr::select(
    Dataset = dataset,
    Source = source,
    Date,
    Language = language,
    Translation = translation,
    Link = url
  )

print('Select destination...')
write.csv(translated_df, paste0(tk_choose.dir(caption = 'Select the folder where you want to store your translated CSV'), '/', filename, '_translated.csv'), row.names = FALSE)

print('Translation successful!')
Sys.sleep(5)