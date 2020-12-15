library(wordcloud2)
library(tm)
library(colourpicker)
library(RWeka)
library(dplyr)


# filter the product based on name & rating, need to find a way to integrate with Koong shiny interface when we select the product, t is the view imported Malik database

good_t_w <- 
  t %>% 
  filter(title == "LG LT700P Refrigerator Water Filter, Filters up to 300 Gallons of Water, Compatible with Select LG Multi-Door Refrigerators with SlimSpace Plus Ice System") %>%
  filter(overall>=3) %>%
  select(reviewtext,summary)

bad_t_w <- 
  t %>% 
  filter(title == "LG LT700P Refrigerator Water Filter, Filters up to 300 Gallons of Water, Compatible with Select LG Multi-Door Refrigerators with SlimSpace Plus Ice System") %>%
  filter(overall<3) %>%
  select(reviewtext,summary)

# still not decide want to generate the word cloud based on reviewtext or reveiw summary)



# processing the text of the selected product into word cloud

mycorpus <- Corpus(VectorSource(good_t_w $summary))
mycorpus <-tm_map(mycorpus,content_transformer(tolower))
mycorpus <- tm_map(mycorpus, removeNumbers)
mycorpus <- tm_map(mycorpus, removeWords,stopwords("english"))
mycorpus <- tm_map(mycorpus,removePunctuation)
mycorpus <- tm_map(mycorpus,stripWhitespace)
mycorpus <- tm_map(mycorpus, removeWords, c("one","two","three","four","five", "star","stars")) 


# generate wordcloud with Bigrams(two words) 
minfreq_bigram <- 2

token_delim <- " \\t\\r\\n.!?,;\"()"
bitoken <- NGramTokenizer(mycorpus, Weka_control(min=2,max=2, delimiters = token_delim))
two_word <- data.frame(table(bitoken))
sort_two <- two_word[order(two_word$Freq,decreasing=TRUE),]

wordcloud(sort_two$bitoken,sort_two$Freq,random.order=FALSE,scale = c(4,0.5),min.freq = minfreq_bigram,colors = brewer.pal(8,"Dark2"),max.words=40)

