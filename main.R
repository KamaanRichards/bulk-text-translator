# renv::install(c('polyglotr', 'dplyr', 'stringr', 'tcltk', 'purrr', 'furrr'))

### To-Do
# Add error detection/handling
# Enable command line arguments for target columns

renv::restore()

library(polyglotr) # Language detection & translation
library(dplyr) # Data wrangling
library(stringr) # String manipulation
library(tcltk) # File/folder selection
library(purrr) # Vectorized functions
library(furrr) # Parallel processing

print('Select CSV to translate...')
filepath <- tk_choose.files(caption = 'Select the CSV file you want to import')

print('Reading in CSV file...')
filename <- basename(filepath) %>% 
  str_remove('.csv') %>% 
  stringr::str_replace_all(' ', '_')

df_to_translate <- read.csv(filepath) %>% 
  dplyr::distinct(body, .keep_all = TRUE)


if (nrow(df_to_translate) > 3000) {
  df_to_translate <- df_to_translate %>% 
    dplyr::slice_sample(n = 1000, replace = FALSE)
} else {
  df_to_translate <- df_to_translate
}

### For small-scale testing
# df_test <- df_to_translate %>%
#   dplyr::filter(language != 'English') %>%
#   dplyr::slice_sample(., n = 15)

# Function to translate text from dataframe

translate_df_text <- function(col_w_text, col_w_language) {
  if (col_w_language != 'English' && col_w_text != "") {
    translated_text <- tryCatch(
      {
        result <- stringr::str_squish(polyglotr::google_translate(
          as.character(gsub("[^\x20-\x7E]", "", col_w_text)), # Remove characters that might cause issues with API
          target_language = 'en'
        )) %>%
          iconv(., "UTF-8", "ASCII", sub = "")

        print(paste0(str_sub(col_w_text, 1L, 100L)))
        # Sys.sleep(1)

        return(result)
      },
      error = function(e) {
        message("Translation error: ", e$message)
        return(NA)
      }
    )
  } else {
    translated_text <- stringr::str_squish(col_w_text)
  }
  return(translated_text)
}

print('Translating file...')

# Parralel processing
plan(multisession, workers = 6)

elapsed_time <- system.time(
  translations <- future_map2(
    df_to_translate$body,
    df_to_translate$language,
    translate_df_text,
    .progress = TRUE,
    .options = furrr_options(seed = TRUE)
  ),
  gcFirst = TRUE
)

translated_df <- df_to_translate
translated_df$Translation <- unlist(translations)



print(paste0('Successfully translated ', nrow(translated_df), ' records in ', round(elapsed_time['elapsed'] / 60, digits = 3), ' minutes. That comes to ', round(elapsed_time['elapsed'] / 244, digits = 3), ' seconds per record.'))


# # Sequential processing
# elapsed_time <- system.time(
#   translated_df <- df_to_translate %>%
#     dplyr::rowwise() %>%
#     dplyr::mutate(
#       translation = translate_df_text(body, language), # These colomns of interest are currently hard-coded
#       Date = as.Date(substr(date, 1, 10))
#     ) %>%
#     dplyr::select(
#       Dataset = dataset,
#       Source = source,
#       Date,
#       Language = language,
#       Translation = translation,
#       Link = url
#     ),
#   gcFirst = TRUE
# )

# print(paste0('Successfully translated ', nrow(translated_df), ' records in ', round(elapsed_time['elapsed'] / 60, digits = 3), ' minutes'))

print('Select output destination...')
write.csv(translated_df, paste0(tk_choose.dir(caption = 'Select the folder where you want to store your translated CSV'), '/', filename, '_translated.csv'), row.names = FALSE)

print('Translation successful!')
Sys.sleep(5)