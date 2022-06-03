library(dplyr)
library(sf)
sf_use_s2(FALSE)
library(geojsonsf)
library(ggplot2)
library(ggtext)
library(ggforce)
library(MetBrewer)
library(ggrepel)
# devtools::install_github("yutannihilation/ggsflabel")
library(ggsflabel)
library(patchwork)

# LOAD DATA
df <- geojson_sf("./data/clean-data_01_municipalities-info.geojson")
df <- df %>% mutate(cluster = as.factor(cluster))

# DATA VISUALIZATIONS
theme_set(theme_minimal(base_family = "Palatino"))
theme_update(
  legend.position = "none",
  plot.background = element_rect(fill='white', color = 'white'),
  panel.background = element_rect(fill='white', color = 'white'),
  axis.title = element_blank(),
  axis.text = element_text(face='bold', color = 'black', size = 10),
  axis.text.x = element_text(margin = margin(25,0,0,0)),
  axis.text.y = element_text(margin = margin(0,30,0,0)),
  panel.grid.major = element_line(linetype = "dotted", color = 'gray90'),
  panel.grid.minor = element_blank(),
  plot.title.position = "plot",
  plot.caption.position = "plot",
  plot.title = element_textbox_simple(size = 18, face = 'bold', margin = margin(5,0,5,0), halign = 0.5),
  plot.subtitle = element_textbox_simple(size = 10, margin = margin(0,0,25,0)),
  plot.caption = element_textbox_simple(size = 9, halign = 0, margin = margin(10,0,0,0)),
)

# ENGLISH - SCATTER PLOT
(
p1 <- df %>% filter(cluster != 0) %>%
  ggplot(aes(x=freq, y=affected_area)) +
  geom_mark_ellipse(aes(fill=cluster), color = "transparent", alpha = 0.75) + 
  geom_point(color='black', size = 3) +
  geom_text_repel(aes(label = name, family = "Optima", fontface = 'bold.italic'),
                  force = 1, size = 3.5,
                  color = 'black',seed = 11) + 
  annotate(geom = "text", x = 12, y = 1500,
           size = 3.45, family = 'Optima', fontface = 'italic',
           label = "1653 ha affected\nby 9 wildfires") +
  annotate(geom = "text", x = 3.2, y = 1400,
           size = 3.45, family = 'Optima', fontface = 'italic',
           label = "1304 ha affected\nby 1 wildfire") +
  annotate(geom = "text", x = 12, y = 1050,
           size = 3.45, family = 'Optima', fontface = 'italic',
           label = "630 ha affected\nby 13 wildfires") +
  geom_curve(data = tribble(
    ~x1, ~x2,~y1,~y2,
    12, 9, 1580, 1653,
    1.5, 1, 1430, 1300,
    12, 13, 930, 630,
    ),
    aes(x=x1,xend=x2,y=y1,yend=y2),
    size = 0.5,
    color='black',
    curvature = 0.5,
    linetype = 'dashed') + 
  scale_fill_manual(values = met.brewer("Hiroshige",3)) +
  scale_y_continuous(breaks = seq(0,1600,400), labels = paste(seq(0,1600,400),"ha")) + 
  scale_x_continuous(breaks = seq(0,13,3), labels = paste(seq(0,13,3), "wildfires"), expand = expansion(mult = 0.15)) + 
  coord_cartesian(clip = "off") +
  labs(
    title='Municipalities affected by wildfires during 2017<br>',
    subtitle = "The visualization showcases the relationship between the <b>number of wildfires</b> (_x-axis_) and <b>affected area</b> (in **hectares** or **ha**) caused by them (_y-axis_). Besides, the data is grouped in three different clusters*.",
    caption = "*<span style='color:#DF9901'><b>Group 2</b></span> has the municipalities with the largest affected areas. The municipalities of <span style='color:#EA701F'><b>Group 1</b></span> and <span style='color:#44A7C5'><b>Group 3</b></span> have lower affected areas, but they differ in the number of records of wildfires.<br><b>Source:</b> Comisión Nacional Forestal (CONAFOR), 2017.<br><b>Visualization by Isaac Arroyo (@unisaacarroyov on Twitter and Behance)</b>",
    #caption = "<b>Source:</b> Comisión Nacional Forestal (CONAFOR), 2017.<br><b>Visualization by Isaac Arroyo (@unisaacarroyov on Twitter and Behance)</b>"
    ) + theme(plot.subtitle = element_textbox_simple(margin = margin(-20,0,20,0)))
)
ggsave("./images/01_municipalities-info_scatterplot.png", units = "px", height = 675, width = 540, scale = 3)

# ENGLISH - MAP
(
p2 <- df %>% filter(cluster != 0) %>%
  ggplot(aes(fill=cluster)) +
  geom_sf(data = df %>% filter(cluster==0), color = 'white', fill = 'gray90', size=0.1) +
  geom_sf(color = 'black', size=0.25) +
  geom_sf_label_repel(aes(label=name, family = 'Optima', fontface = 'bold'),
                      force = 200, nudge_x = -2, seed = 10) + 
  scale_fill_manual(values = met.brewer("Hiroshige",3)) +
  scale_colour_manual(values = met.brewer("Hiroshige",3)) +
  labs(
    title='Map of municipalities affected by wildfires during 2017',
    subtitle = "<br><br><span style='color:#DF9901'><b>Group 2</b></span> has the municipalities with the largest affected areas. The municipalities of <span style='color:#EA701F'><b>Group 1</b></span> and <span style='color:#44A7C5'><b>Group 3</b></span> have lower affected areas, but they differ in the number of records of wildfires.",
    caption = "**Source:** Comisión Nacional Forestal (CONAFOR), 2017.<br>**Visualization by Isaac Arroyo (@unisaacarroyov on Twitter and Behance)**"
  ) +
  coord_sf(xlim = c(3700663, 3994857),
           ylim = c(897964.9, 1140000))
)
ggsave("./images/01_municipalities-info_map.png", units = "px", height = 675, width = 540, scale = 3)

(p1+p2) + plot_layout(widths = c(0.5,0.5))
ggsave("./images/01_municipalities-info.png", units = "px", width = 1080, height = 675, scale = 3)
