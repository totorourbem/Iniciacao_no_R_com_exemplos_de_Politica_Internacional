#Comandos para an�lise de texto#

#Importar e carregar os pacotes - vai levar algum tempo - nem todos os pacotes v�o ser usados, mas quis deixar uma colet�nea para voc�s pesquisarem depois tutoriais dos pacotes#

install.packages("knitr")
install.packages("kableExtra")
install.packages("gridExtra")
install.packages("tidytext")
install.packages("stringr")
install.packages("tidyr")
install.packages("ggplot2")
install.packages("wordcloud2")
install.packages("readxl")
install.packages("openxlsx")
install.packages("textdata")
install.packages("igraph")
install.packages("ggraph")
install.packages("ggrepel")
install.packages("tm")
install.packages("foreign")
install.packages("dplyr")
install.packages("writexl")
install.packages ("memery")
install.packages ("magick")
install.packages("circlize")
install.packages("SentimentAnalysis")
install.packages("tidyverse")
install.packages("devtools")
install.packages("widyr")
install.packages("wordcloud")

library(widyr)
library(devtools)
library(tidyverse)
library(SentimentAnalysis)
library(circlize)
library(memery)
library(magick)
library(writexl)
library(dplyr)
library(tidytext)
library(stringr)
library(tidyr)
library(foreign)
library(igraph)
library(ggraph)
library(ggrepel)
library(tm)
library(ggplot2)
library(wordcloud2)
library(readxl)
library(openxlsx)
library(textdata)
library(knitr)
library(kableExtra)
library(gridExtra) 
library(wordcloud)

discurso <- read_excel("C:/Users/Paulo/Documents/Documents/CursoR_Apolo/Bases de dados/discursos_CSONU_China e EUA.xls")

#Objeto de cores personalizadas que ser�o utilizadas adiante#

my_colors <- c("#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#D55E00")

#Gr�fico de Barras com o N de discursos por ano e pot�ncia#

speeches_potencia <- discurso %>%
  group_by(sigla, ano) %>%
  summarise(number_of_texto = n())

plot <- ggplot(speeches_potencia, aes(ano, number_of_texto, fill=sigla))
plot <- plot + geom_bar(stat = "identity", position = 'dodge')+
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_blank(),
        panel.grid.minor = element_blank()) +
  labs(x = "D�cadas", y = "N� Discursos") +
  ggtitle("Discursos de China e EUA no CSONU(1995-2020)") 
plot


# Faz o preproceamento padr�o de limpeza do texto#

discurso$texto <- discurso$texto %>%
  str_to_lower() %>%                      
  str_replace_all(" *-+ *", "") %>%       
  str_replace_all("[[:punct:]]", " ") %>% 
  removeNumbers() %>%                     
  trimws()                                

# Stop words padr�o do idioma ingl�s#

stopwords(kind = "en")


# Remo��o das stop words#

discurso$texto <- discurso$texto %>%
  removeWords(words = stopwords(kind = "en"))

# Tokeniza��o nas palavras individuais e empilha as palavras#

texto_un <- discurso %>%
  unnest_tokens(output = "words", input = texto)
  texto_un

#Obter os l�xicos do dicion�rio AFINN#

AFINN <- get_sentiments("afinn")


# Merge os dados: jun��o por interse��o, juntar texto_un com os lexicos e polaridade do pacote LexiconPT.#

tb_sen <- inner_join(texto_un,
                     AFINN[, c("word", "value")],
                     by = c("words" = "word"))

# Faz a agrega��o pela m�dia do sentimento por discurso das autoridades#

tb <- tb_sen %>%
  group_by(id, sigla, ano) %>%
  summarise(media = mean(value),
            n = n(),
            sentiment = media/n)

# Densidade de kernel do escore de sentimento dos pa�ses#
ggplot(tb, aes(sentiment, colour = sigla)) +
  geom_density() +
  xlim(-0.1, 0.1)+
  labs(x = "Sentimento", y = "Densidade")

#Novo objeto com os anos nos dois pa�ses#

tb2 <- tb_sen %>%
  group_by(pais, ano) %>%
  summarise(media = mean(value),
            n = n(),
            sentiment = media)
        

#Gr�fico desse novo objeto por nome e sentimento#


tb2 %>%
  ggplot( aes(x=ano, y=sentiment, group=pais, color=pais)) +
  geom_line() +
  scale_color_viridis(discrete = TRUE) +
  ggtitle("Sentimento por Pot�ncia e Ano") +
  ylab("Sentimento do Discurso")

# Determina as frequ�ncias dos termos de polaridade n�o nula.

tb_words4 <- tb_sen %>%
  count(words, value, sigla, sort = TRUE) %>%
  filter(value != 0)

#Prepara o objeto para virar nuvem de palavra#

tb_cloud <- tb_words4 %>%
  spread(key = "sigla", value = "n", fill = 0) %>%
  rename("China" = "CHI", "Estados Unidos" = "USA")
tb_cloud

tb3 <- as.data.frame(tb_cloud[, c("China", "Estados Unidos")])
rownames(tb3) <- tb_cloud$words
head(tb3)


comparison.cloud(tb3,
                 colors = c("red", "blue"),
                 max.words = min(nrow(tb), 500))

#An�lise de sentimento com o dicion�rio NRC#

NRC <- get_sentiments("nrc")

discurso_nrc <- inner_join(texto_un,
                     NRC[, c("word", "sentiment")],
                     by = c("words" = "word"))

decade_mood <-  discurso_nrc %>%
  filter(sigla != "NA" & !sentiment %in% c("positive", "negative")) %>%
  count(sentiment, sigla) %>%
  group_by(sigla, sentiment) %>%
  summarise(sentiment_sum = sum(n)) %>%
  ungroup()

my_colors <- c("#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#D55E00")
grid.col = c("China" = my_colors[1], "USA" = my_colors[2], "anger" = "grey", "anticipation" = "grey", "disgust" = "grey", "fear" = "grey", "joy" = "grey", "sadness" = "grey", "surprise" = "grey", "trust" = "grey")

circos.clear()

circos.par(gap.after = c(rep(5, length(unique(decade_mood[[1]])) - 1), 15,
                         rep(5, length(unique(decade_mood[[2]])) - 1), 15))
chordDiagram(decade_mood,grid.col = grid.col, transparency = .2)
title("Sentimentos Mobilizados por China e EUA no CSONU")
