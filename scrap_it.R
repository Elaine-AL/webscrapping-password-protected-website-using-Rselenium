library("RSelenium")
library("XML") #for reading HTML tables

#Make sure you have your listed customers that you wish to search the information for in a vector (or dataframe) form

Mycustomer = c("123op", "rt245", "327ytb3")

#Start the automation process
driver = rsDriver(browser = c("chrome"), chromever = "88.0.4324.96", port = 4367L)
remdr = driver[["client"]]
remdr$open()

#This is the link of the website you wish to scrap information from
Mynhif = "http://website/data/index.html"
remdr$navigate(Mynhif)
remdr$findElement("name", "login")$sendKeysToElement(list("*****"))
remdr$findElement("name", "password")$sendKeysToElement(list("****"))
remdr$findElement("css", "input[type='submit']")$clickElement()

#If there are tabs or buttons with links then use the below statement
remdr$findElement("link text", "Customer info")$clickElement()

#If there are dropdown menus to select from use the statement below
remdr$findElement("xpath", "//*/option[@value = 'ID']")$clickElement()

#I will be using a for {} loop to extract information from a table for every customer in my list and append it to a dataframe

Minti = c()
thetable = c()

for (i in Mycustomer) {
  tryCatch({remdr$findElement("name", "number")$sendKeysToElement(list(i))
            remdr$findElement("css", "input[type='submit']")$clickElement()
            minti = remdr$findElement("xpath", "//table/tbody/tr[2]/td/table/tbody/tr/td/table[1]/tbody/tr/td[1]/table/tbody/tr[1]/td[1]/table")$getElementAttribute("outerHTML")[[1]]
            minti = XML::readHTMLTable(minti, header=FALSE, as.data.frame=TRUE)[[1]]
            
            Minti = rbind(Minti, minti)
            
            #always be sure to clear our the search panel using the statement below otherwise the customer IDs will appending themselves on the search panel giving you errors or no information
            
            remdr$findElement("name", "number")$clearElement()
            }, 
                     #when an error occurs or if the users info is not found, clear out the search panel and start the loop again for the next user search
                     error = function(e) {
                       remdr$findElement("name", "number")$clearElement()
                       force(do.next)},
                     #when a warning occurs, clear out the search panel and start the loop again for the next user search 
                     warning = function(w) {
                       remdr$findElement("name", "number")$clearElement()
                       print(NA)}
     )
  
}
thetable = rbind(thetable, Minti)

#You can now start your cleaning process.
