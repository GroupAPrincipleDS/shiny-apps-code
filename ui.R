#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
#    https://group-a-pds.shinyapps.io/group-a-pds/
#

library(shiny)
library(shinythemes)
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
            actionButton("btnSearch", "Search"),
            plotOutput("good_review"),
            plotOutput("bad_review")
        ),
        
        # Show a table output of searched product
        mainPanel(
            dataTableOutput("tblProducts")
        )
    )

#Add in the documenation into following page 
documentation_page <- div(
    br(),
    p(strong("Introduction"), style = "font-size:500px;"),
    p("In most of the common rating system only showcase the average rating scale from 1 to 5. However, this type of rating showcase is too general and if buyer want to know the true comments or reviews of the interested product, they will have to browser through the comment section one by one.
      Therefore, the purpose of this apps is to help buyers to quickly browse through the review summaries and gain more detailed understanding on the product via word cloud. Word Cloud is a visualization tool where an imaged composed of words used in a particular text or subject, 
      in which the size of each word indicates its frequency or importance. Two word clouds are being generated to analysis the positive reviews and negative reviews.",style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px"),
    br(),
    br(),
    p(strong("Apps Guideline"), style = "font-size:500px;"),
      p("1. User can search the interested appliances in the search column. User can choose to narrow the search by selecting the brand of ideal appliances.",
        br(),"2. A table with the selected type of appliances will be listed based on the review counts.",
        br(),"3. User can further select the product interested to view the word cloud. Table of the review's summary also will be shown.",style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px"),
      br(),
      br(),
      p(strong("Dataset"), style = "font-size:500px;"),
        p("The review dataset used in building this apps is the Appliances's data retrieved from Amazon (2018) where it contained total of 602,777 reviews and summaries. The dataset is introduced into the SQL server for data pre-processing purpose.",style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px"),
        p("For more information regardign the dataset please check the",em("Amazon Review Data (2018)'s"),"page by clicking",
          a(href="http://deepyeti.ucsd.edu/jianmo/amazon/index.html", "Here",target="_blank"),style="text-align:center;color:black",width=2),
    br(),
    br(),
    p(strong("Future Works"), style = "font-size:500px;font-family:times"),
    p("Due to the limitation of the local drive's processing power, this review system only able to conduct the sentiment analysis of a single catergory which is the 'Appliances' in the Amazon product review data.
      Future works can be carry out by including all categories of product in the Amazon review data (2018).",style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px")
      )
      
      #This is sample page we can add in more details or remove it if necessary
      about_us <- div(
          titlePanel("Group A"),
          p(strong("We are group of students from University Malaya Malaysia working on this shinyapps to develop a tool for Amazon Product Rating and Review sentiment analysis."), id = "aboutus"),
          br(),
          p("Below is the details of our group."),
          tags$ol(
              tags$li("Muhammad Umair (S2001767)"),
              tags$li("Kong Mun Yeen (17055182)"),
              tags$li("Teo Boon Long (17198093)"),
              tags$li("Liow Wei Jie (S2016102)")
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
            //console.log(data);
            reviews = data[1];
            reviews_count = reviews["overall"].length;
            
            dataset = [];
            
            for (i=0; i<reviews_count; i++) {
                d = [];
                d.push(reviews["overall"][i]);
                d.push(reviews["vote"][i]);
                d.push(reviews["summary"][i]);
                d.push(reviews["reviewtext"][i]);
                dataset.push(d);
            }
            $("div[id*=\'child_details\']:not(#child_details+data[0])").parent().parent().remove();
            $("tr.selected").removeClass("selected");
            $("#child_details"+data[0]).DataTable({
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
