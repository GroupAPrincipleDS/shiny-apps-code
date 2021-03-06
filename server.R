#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
#    https://group-a-pds.shinyapps.io/group-a-pds/
#

library(shiny)
library(DT)
library(DBI)
library(wordcloud)
library(tm)
library(colourpicker)
library(RWeka)
library(dplyr)
source("ui.R")

# Define server logic
shinyServer(function(input, output, session) {
    router$server(input, output, session)

    # Get list of brands from title search and update brand selection input.
    brands <- observeEvent(input$txtSearch, {
        if (input$txtSearch != "") {
            sql <- paste("SELECT DISTINCT brand FROM amazon_prod_reviews dwd ",
                         "WHERE UPPER(title) LIKE '%", toupper(input$txtSearch), "%' ",
                         "ORDER BY brand",
                         sep="")
            #cat(sql,"\n")
            res <- dbGetQuery(con, sql)

            # Update the selection for Brand. Include the 'All' option to select all brands.
            updateSelectInput(session, "selectBrand", choices=c('All',res), selected='All')
        }
    })
    
    # Update data table with selected brand.
    df <- eventReactive(input$btnSearch, {
        if (input$txtSearch != "") {
            sql <- paste("SELECT AVG(overall) overall_avg, COUNT(overall) review_count, ",
                         "title, brand FROM amazon_prod_reviews ",
                         "WHERE UPPER(title) LIKE '%", toupper(input$txtSearch), "%' ",
                         sep="")

            # If 'All' is not selected, construct the SQL to search for only the specific brand.
            if (input$selectBrand != 'All') {
                sql <- paste(sql,
                             "AND brand = ", dbQuoteString(con, input$selectBrand), " ",
                             sep="")
            }
            sql <- paste(sql,
                         "GROUP BY Title, Brand ORDER BY review_count DESC, overall_avg DESC ",
#                         "LIMIT 10 ",
                         sep="")

            #cat(sql,"\n")
            res <- dbGetQuery(con, sql)
        }
    })

    # dataset for good review
    
    datasource <- eventReactive(input$productselect,{
        wordCloudDf <- data.frame()
        sql <- paste("SELECT overall, summary FROM amazon_prod_reviews ",
                     "WHERE title = '", input$productselect[5], "' ",
                     "AND overall >= 3",
                     sep="")
        wordCloudDf <- dbGetQuery(con, sql)
        good_t_w <- 
            wordCloudDf %>% 
            select(summary)
        mycorpus <- Corpus(VectorSource(good_t_w $summary))
        mycorpus <-tm_map(mycorpus,content_transformer(tolower))
        mycorpus <- tm_map(mycorpus, removeNumbers)
        mycorpus <- tm_map(mycorpus, removeWords,stopwords("english"))
        mycorpus <- tm_map(mycorpus,removePunctuation)
        mycorpus <- tm_map(mycorpus,stripWhitespace)
        mycorpus <- tm_map(mycorpus, removeWords, c("one","two","three","four","five", "star","stars")) 
        
        
        
        token_delim <- " \\t\\r\\n.!?,;\"()"
        bitoken <- NGramTokenizer(mycorpus, Weka_control(min=2,max=2, delimiters = token_delim))
        bitoken <- bitoken[!bitoken %in% c("language =","list language","= en")]
        two_word <- data.frame(table(bitoken))
        sort_two <- two_word[order(two_word$Freq,decreasing=TRUE),]
        remove(wordCloudDf)
        return(sort_two)
    })
    
    
    # dataset for bad review
    
    datasource_v2 <- eventReactive(input$productselect,{
        sql <- paste("SELECT overall, summary FROM amazon_prod_reviews ",
                     "WHERE title = '", input$productselect[5], "' ",
                     "AND overall < 3",
                     sep="")
        wordCloudDf <- dbGetQuery(con, sql)
        bad_t_w <- 
            wordCloudDf %>% 
            select(summary)
        mycorpus_v2 <- Corpus(VectorSource(bad_t_w $summary))
        mycorpus_v2 <-tm_map(mycorpus_v2,content_transformer(tolower))
        mycorpus_v2 <- tm_map(mycorpus_v2, removeNumbers)
        mycorpus_v2 <- tm_map(mycorpus_v2, removeWords,stopwords("english"))
        mycorpus_v2 <- tm_map(mycorpus_v2,removePunctuation)
        mycorpus_v2 <- tm_map(mycorpus_v2,stripWhitespace)
        mycorpus_v2 <- tm_map(mycorpus_v2, removeWords, c("one","two","three","four","five", "star","stars")) 
        
        
        
        token_delim_v2 <- " \\t\\r\\n.!?,;\"()"
        bitoken_v2 <- NGramTokenizer(mycorpus_v2, Weka_control(min=2,max=2, delimiters = token_delim_v2))
        bitoken_v2 <- bitoken_v2[!bitoken_v2 %in% c("language =","list language","= en")]
        two_word_v2 <- data.frame(table(bitoken_v2))
        sort_two_v2 <- two_word_v2[order(two_word_v2$Freq,decreasing=TRUE),]
        remove(wordCloudDf)
        return(sort_two_v2)
    })
    # wordcloud for good review
    
    output$good_review <- renderPlot({
        x <- datasource()$bitoken
        y <- datasource()$Freq
        minfreq_bigram <- 2
        
        wordcloud(x,y,random.order=FALSE,scale = c(3,0.5),min.freq = minfreq_bigram,colors = brewer.pal(8,"Dark2"),
                  max.words=50)
        
        
    })
    
    # wordcloud for bad review
    
    output$bad_review <- renderPlot({
        x <- datasource_v2()$bitoken
        y <- datasource_v2()$Freq
        minfreq_bigram <- 2
        
        wordcloud(x,y,random.order=FALSE,scale = c(3,0.5),min.freq = minfreq_bigram,colors = brewer.pal(8,"Dark2"),
                  max.words=50)
        
        
    })
    output$tblProducts <- renderDataTable(
        { df() },
        filter = list(position='top', clear=FALSE),
        callback = JS("
            var format = function(d) { 
                Shiny.setInputValue('productselect', [d.index(), d.data()]);
                return d.data();
            }
            
            table.on('click', 'td', function() {
                var tr = $(this).closest('tr');
                var row = table.row(tr);
                var rowData = row.data();
                
                var index = row.index();
                
                if (row.child.isShown()) { 
                    row.child.hide();
                }
                else {
                    row.child('<table id=\"child_details'+index+'\"></table>').show();
                    format(row);
                }
            });
        ")
    )
    
    prod <- observeEvent(input$productselect, {
        # print(input$productselect[1])
        # print(input$productselect[5])

        sql <- paste("SELECT overall, vote, summary, reviewtext FROM amazon_prod_reviews ",
                   "WHERE title=",dbQuoteString(con,input$productselect[5]), sep="")
        res <- dbGetQuery(con, sql)
        session$sendCustomMessage("updatechildrow", list(input$productselect[1], res))
    })
})
