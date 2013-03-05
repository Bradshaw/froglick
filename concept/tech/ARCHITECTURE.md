Client/Server architecture
==========================

We will use a REST model.
The server hosts campaigns as folders with XML files. Clients can request status and the server responds with a view of the game from the player characters's point of view.
Clients can also submit a turn, and when all player characters have a submitted turn, the server simulates the turn and saves the changes in the XML.



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