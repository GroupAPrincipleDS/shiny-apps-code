#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
#    https://group-a-pds.shinyapps.io/group-a-pds/
#

library(shiny)
library(DT)
library(DBI)
source("ui.R")

# Define server logic
shinyServer(function(input, output, session) {
    router$server(input, output, session)
    # Connect to PostgreSQL
    con <- dbConnect(RPostgres::Postgres(), dbname='pds-project',
                     host = 'pds-group-project.carynrwc1v04.ap-southeast-1.rds.amazonaws.com',
                     port = 5432,
                     user = 'pdsgroupproject',
                     password = 'pdsadmin123')

    # Get list of brands from title search and update brand selection input.
    brands <- observeEvent(input$txtSearch, {
        if (input$txtSearch != "") {
            sql <- paste("SELECT DISTINCT brand FROM data_with_details dwd ",
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
                         "title, brand FROM data_with_details ",
                         "WHERE UPPER(title) LIKE '%", toupper(input$txtSearch), "%' ",
                         sep="")

            # If 'All' is not selected, construct the SQL to search for only the specific brand.
            if (input$selectBrand != 'All') {
                sql <- paste(sql,
                             "AND brand = ", dbQuoteString(con, input$selectBrand), " ",
                             sep="")
            }
            sql <- paste(sql,
                         "GROUP BY Title, Brand ORDER BY overall_avg DESC, review_count DESC ",
#                         "LIMIT 10",
                         sep="")

            #cat(sql,"\n")
            res <- dbGetQuery(con, sql)
        }
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
                    row.child('<table id=\"child_details\"></table>').show();
                    format(row);
                }
            });
        ")
    )
    
    prod <- observeEvent(input$productselect, {
        # print(input$productselect[1])
        # print(input$productselect[5])

        sql <- paste("SELECT overall, vote, summary, reviewtext FROM data_with_details ",
                   "WHERE title=",dbQuoteString(con,input$productselect[5]), sep="")
        res <- dbGetQuery(con, sql)
        session$sendCustomMessage("updatechildrow", list(input$productselect[1], res))
    })
})
