#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
#    https://group-a-pds.shinyapps.io/group-a-pds/
#

library(shiny)

# Define UI for application
shinyUI(fluidPage(

    # Application title
    titlePanel("Group A - Amazon Product Reviews"),

    # Sidebar layout with a product search input and table output
    sidebarLayout(
        sidebarPanel(
            textInput("txtSearch", "Search product:", ),
            selectInput("selectBrand", "Brand", c('All')),
            actionButton("btnSearch", "Search")
        ),

        # Show a table output of searched product
        mainPanel(
            dataTableOutput("tblProducts")
        )
    )
))
