# ggplot2で使用するmy theme

my_theme1 <- theme_classic(base_size=25) + 
  theme(axis.text.y=element_text(colour="black"), axis.text.x=element_text(colour="black"), 
        axis.line=element_line(colour="black", size=1.7, lineend="square"))

my_theme2 <- theme_bw(base_size=25) + 
  theme(axis.text.y=element_text(colour="black"), axis.text.x=element_text(colour="black"), 
        axis.line=element_line(colour="black", size=1.7, lineend="square"))

my_theme3 <- theme_minimal(base_size=25) + 
  theme(axis.text.y=element_text(colour="black"), axis.text.x=element_text(colour="black"), 
        axis.line=element_line(colour="black", size=1.7, lineend="square"))