#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
#    https://group-a-pds.shinyapps.io/group-a-pds/
#

library(shiny)
library(DT)

# Define UI for application
shinyUI(fluidPage(

    tags$head(
        tags$script(HTML('
        Shiny.addCustomMessageHandler("updatechildrow", function(data) {
            console.log(data);
            reviews = data[1];
            reviews_count = reviews["overall"].length;
            
            dataset = [];
            
            for (i=0; i<reviews_count; i++) {
                data = [];
                data.push(reviews["overall"][i]);
                data.push(reviews["vote"][i]);
                data.push(reviews["summary"][i]);
                data.push(reviews["reviewtext"][i]);
                dataset.push(data);
            }
            $("#child_details").DataTable({
                data: dataset,
                columns: [
                    { title: "Rating" },
                    { title: "Votes" },
                    { title: "Summary" },
                    { title: "Review" }
                ]
            });
        })
        '))
    ),

    # Application title
    titlePanel("Group A - Amazon Product Reviews"),

    
    # Sidebar layout with a product search input and table output
    sidebarLayout(
        sidebarPanel(
            textInput("txtSearch", "Search product:"),
            selectInput("selectBrand", "Brand", c('All')),
            actionButton("btnSearch", "Search")
        ),

        # Show a table output of searched product
        mainPanel(
            dataTableOutput("tblProducts")
        )
    )
))
