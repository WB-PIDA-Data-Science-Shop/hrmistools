library(stringdist)
library(dplyr)
library(text)
library(tibble)

# --- 1) Example Portuguese job titles
pt_jobs <- c("enfermeira", "pedreiro", "professor de matemática",
             "contador", "advogado tributarista") |>
  vectorize_gt(
    source_language = "pt"
  )

isco_dict <- tibble(
  code = c("2211", "7112", "2310", "2411", "2619"),
  title_en = c("Nursing professionals", "Bricklayers and related workers",
               "Teaching professionals", "Accountants", "Legal professionals"),
  desc_en = c("Provide nursing care", "Build walls and structures",
              "Teach at schools or universities", "Prepare financial accounts",
              "Specialized legal practitioners")
) %>%
  mutate(doc = paste(title_en, desc_en, sep = " — "))

# --- 4) Preprocess function
preprocess_text <- function(text) {
  text <- tolower(text)
  text <- stringr::str_replace_all(text, "[[:punct:]]", " ")
  text <- iconv(text, to = "ASCII//TRANSLIT") # remove accents
  text <- str_squish(text)
  return(text)
}

en_jobs_clean <- sapply(en_jobs, preprocess_text)
isco_docs_clean <- sapply(isco_dict$doc, preprocess_text)

# --- 5) Compute embeddings (text package)
job_embeddings <- textEmbed(en_jobs_clean, model = "bert-base-uncased")
isco_embeddings <- textEmbed(isco_docs_clean, model = "bert-base-uncased")

# --- 6) Compute cosine similarity
cosine_sim <- function(a, b) {
  a_norm <- sqrt(rowSums(a^2))
  b_norm <- sqrt(rowSums(b^2))
  sim <- a %*% t(b) / (a_norm %*% t(b_norm))
  return(sim)
}

sim_matrix <- cosine_sim(job_embeddings$embeddings, isco_embeddings$embeddings)

# --- 7) Top-k ISCO mapping function
top_k_matches <- function(sim_row, k = 3) {
  idx <- order(sim_row, decreasing = TRUE)[1:k]
  tibble(
    isco_code = isco_dict$code[idx],
    isco_title = isco_dict$title_en[idx],
    similarity = sim_row[idx]
  )
}

# --- 8) Map each job to top-k ISCO
results <- lapply(1:nrow(sim_matrix), function(i) {
  top_k <- top_k_matches(sim_matrix[i, ], k = 3)
  top_k %>% mutate(input_job = en_jobs[i]) %>% select(input_job, everything())
})

results <- bind_rows(results)
print(results)
