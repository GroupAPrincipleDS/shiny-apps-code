#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
#    https://group-a-pds.shinyapps.io/group-a-pds/
#

library(shiny)
library(DT)
library(shiny.router)

menu <- (
    tags$ul(
        tags$li(a(class = "item", href = route_link("/"), "Dashboard")),
        tags$li(a(class = "item", href = route_link("other"), "Documentation")),
        tags$li(a(class = "item", href = route_link("aboutus"), "About Us")),
    )
)

#This is our home page or dashboard page
root_page <-     # Sidebar layout with a product search input and table output
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
#Add in the documenation into following page 
documentation_page <- div(
    p("this is just for sample you can remove the slider once the documentation is ready!"),
    sliderInput("obs", "Number of observations:", min = 10, max = 500, value = 100)
    )

#This is sample page we can add in more details or remove it if necessary
about_us <- div(
    titlePanel("Group A"),
    p("We are group of four people with the details as per bellow:", id = "aboutus"),
    tags$ol(
        tags$li("Muhammad Umair (S2001767)"),
        tags$li("Kong"),
        tags$li("Boon"),
        tags$li("Liow"),
    )
)
router <- make_router(
    route("/", root_page),
    route("other", documentation_page),
    route("aboutus", about_us)
)
# Define UI for application
shinyUI(fluidPage( 
    tags$head(includeCSS("stylesheet.css")),
    p("Amazon Product Reviews", id= "title"),
    menu,
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
    router$ui
    

))
