library(shinydashboard)
library(glue)
library(here)
library(ggiraph)
library(pins)

pins::board_register_datatxt(name = "conscious_lang",
                             url = config::get("board_url"))

# Functions
bar_plot <- function(d,word) {
  word_str <- quo_name(enquo(word))
  link_tbl <- config::get('search_links') %>% bind_rows()
  plot <- d %>%
    mutate(label = glue('{org}/{repo}'),
           word = rep(c(word_str), length(url)),
           matches = map(url, function(u) map_lgl(link_tbl$pattern, grepl, x=u)),
           template = map(matches, function(x) first(link_tbl$template[x]))) %>%
    rowwise() %>%
    mutate(search=ifelse(!is.na(template), glue(template), url)) %>%
    ungroup() %>%
    arrange(-{{word}}) %>%
    slice(1:10) %>%
    ggplot(aes(fct_reorder(label,{{word}}),{{word}})) +
    geom_col_interactive(
      aes(tooltip = paste0(label,': ',scales::comma({{word}},accuracy = 1)),
          data_id = label,
          onclick = glue("window.open(\"{search}\")")),
      fill = '#CB333B') +
    scale_x_discrete(labels = function(x) str_trunc(x, side = 'left', width = 20)) +
    coord_flip() +
    labs(title = NULL,
         caption = glue('Results of "sum(ag -c $word $repo)"'),
         x = 'Repo', y = 'Count') +
    theme(text = element_text(size = 18))

  girafe(ggobj = plot, width_svg = 10, height_svg = 4,
         options = list(opts_tooltip(offx=20,offy=20),
                        opts_sizing(width = .5),
                        opts_selection(type = 'none'),
                        opts_toolbar(position = "bottomleft"),
                        opts_hover_inv(css = "opacity:0.7;")
         ))
}

line_plot <- function(h,word) {
  plot <- h %>%
    group_by(date) %>%
    distinct(org,repo,.keep_all = T) %>%
    summarise(across(where(is.numeric), mean), repos = n()) %>%
    mutate(across(where(is.numeric), round)) %>%
    select(date,word = {{word}}, repos) %>%
    ggplot(aes(date,word)) +
    geom_line(size = 1, colour = '#CB333B') +
    geom_point_interactive(aes(data_id = date,
                               tooltip = glue('{date}: {word}\n{repos} repos')),
      size = 3, colour = '#CB333B') +
    labs(title = NULL,
         caption = glue('Mean words/repo over time'),
         x = 'Date', y = 'Count per Repo') +
    theme(text = element_text(size = 18))

  girafe(ggobj = plot, width_svg = 10, height_svg = 4,
         options = list(opts_tooltip(offx=20,offy=20),
                        opts_sizing(width = .5),
                        opts_selection(type = 'none'),
                        opts_toolbar(position = "bottomleft"),
                        opts_hover_inv(css = "opacity:0.7;")
         ))
}
