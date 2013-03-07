Client/Server architecture
==========================


Representational State Transfer
-------------------------------

We will use a Representational State Transfer (REST) model.

The server hosts campaigns as folders with XML files. Clients can request status 
and the server responds with a view of the game from the player characters's 
point of view.
Clients can also submit a turn, and when all player characters have a submitted 
turn, the server simulates the turn and saves the changes in the XML.
In other words the server must do the following:

+ Buffer character turn choices, which are sequences of actions.
+ Generates a new XML representing the state of the game world, based on 
character actions.
+ The XML file is stored on the file-system (node.js) or in the client local
storage (HTML 5).
+ Send to each client information on the part of the world that their character 
can see.


~~~~
                             _____________
                            |             |
                            |  XML files  |
                            |             |
                            |             |
                            |             |
                            |_____________|

                                 A   
                                 |   |
                                 |   |
                                     V

   node.js      ----------> [Server tech] <----------   Lua

     A                                                 A
     |   |                                             |   |
http |   | http                                        |   |
get  |   | xml                                     tcp |   | tcp
 or  |   |                                             |   |
post |   |                                             |   |
     |   |                                             |   |
	     V                                                 V

   HTML5/JS     ----------> [Client tech] <----------  Löve2d
   with browser                                          Lua
                                 A   
                                 |   |
                                 |   |
                                     V

                             [Happy player]

~~~~

What is important is that the game is run on the server and that it is sent to 
the client in a formalised XML structure. This will make writing clients easy 
as poop, and keeps everything (kind of) tidy.

HTML5 Web Storage?
------------------
Using the HTML 5 *localStorage* object we can store this XML data client-side:
no need to run a server of any kind. This is not to be confused with the 
*sessionStorage*, which is deleted when the browser is closed.


~~~~


    Filesystem (node.js)                          localStorage (HTML 5)
            A                                              A
            |                                              |
            |                                              |
            -------  [ Abstract storage function ]   ------- 

                                 A   
                                 |   |
                                 |   |
                                     V
                                     
                              [Server tech]
~~~~