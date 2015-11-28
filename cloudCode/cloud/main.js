// Takes in User's current PFGeopoint and distance bound 
// as parameters and outputs a list of User Profiles that are
// within the area. SORTS BY ALPHABET
Parse.Cloud.define("findAllEvents", function(request, response) {
  var currlat = request.params.lat;
  var currlon = request.params.lon;
  var bound = request.params.dist;
  var local = request.params.local;

  var eventQuery = new Parse.Query("Event");
  eventQuery.limit(1000);
  eventQuery.ascending("Date");
  var eventList = [];

  var currLoc = new Parse.GeoPoint(currlat, currlon);

  eventQuery.find({
    success: function(results) {
      var currentDate = new Date();

      for (var i = 0; i < results.length; i++) {
        var event = results[i];
        var eventDate = event.get("Date");
        var eventLocation = event.get("Position");
        var eventLocal = event.get("Local");
        var timeDiff = eventDate.getTime() - currentDate.getTime();
        if (timeDiff >= 0) { // Checks if the event has already passed
          if (eventLocation != null) {
            if (local) {
              var dist = currLoc.kilometersTo(eventLocation);

              if (dist <= bound) { // Checks if the distance is within the bound
                eventList.push(event);
              }
            } else {
              eventList.push(event);
            }
          }
        }
      }
      response.success(eventList);
    },
    error: function(error) {
      alert("Error" + error.code + " " + error.message);
    }
  })
})

Parse.Cloud.define("findSavedEvents", function(request, response) {
  var currlat = request.params.lat;
  var currlon = request.params.lon;
  var bound = request.params.dist;
  var local = request.params.local;

  var eventQuery = new Parse.Query("Event");
  eventQuery.limit(1000);
  eventQuery.ascending("Date");
  var eventList = [];

  var currentID = Parse.User.current().id;

  var currLoc = new Parse.GeoPoint(currlat, currlon);

  eventQuery.find({
    success: function(results) {
      var currentDate = new Date();

      for (var i = 0; i < results.length; i++) {
        var event = results[i];
        var eventGoing = event.get("Going");
        var eventMaybe = event.get("Maybe");
        var eventNotGoing = event.get("NotGoing");
        console.log(eventGoing.indexOf(currentID));
        if (eventGoing.indexOf(currentID) != -1 || eventMaybe.indexOf(currentID) != -1 || eventNotGoing.indexOf(currentID) != -1) {
            eventList.push(event);
        }
      }
      response.success(eventList);
    },
    error: function(error) {
      alert("Error" + error.code + " " + error.message);
    }
  })
})

Parse.Cloud.define("findEventsDist", function(request, response) {
  var currlat = request.params.lat;
  var currlon = request.params.lon;
  var bound = request.params.dist;
  var local = request.params.local;
  var all = request.params.all;

  var currentID = Parse.User.current().id;

  var eventQuery = new Parse.Query("Event");
  eventQuery.ascending("Date");
  eventQuery.limit(1000);
  var distList = [];

  var currLoc = new Parse.GeoPoint(currlat, currlon);

  eventQuery.find({
    success: function(results) {
      var currentDate = new Date();

      for (var i = 0; i < results.length; i++) {
        var event = results[i];
        var eventDate = event.get("Date");
        var eventLocation = event.get("Position");
        var eventLocal = event.get("Local");
        var eventGoing = event.get("Going");
        var eventMaybe = event.get("Maybe");
        var eventNotGoing = event.get("NotGoing");
        
        var timeDiff = eventDate.getTime() - currentDate.getTime();
        var dist = currLoc.kilometersTo(eventLocation);
        // If on "All" tab, load in all events 
        // and load distances as above.
        if (all) { 
          if (timeDiff >= 0) { // Checks if the event has already passed
            if (eventLocation != null) {
              if (local) {
                if (dist <= bound) { // Checks if the distance is within the bound
                  distList.push(dist);
                }
              } else {
                distList.push(dist);
              }
            }
          }
        // If on "My Events" tab, load in all events in which you've marked
        // as "Going", "Maybe", and "Not Going"
        } else { 
          if (eventGoing.indexOf(currentID) != -1 || eventMaybe.indexOf(currentID) != -1 || eventNotGoing.indexOf(currentID) != -1) {
            distList.push(dist);
          }
        }
      }
      response.success(distList);
    },
    error: function(error) {
      alert("Error" + error.code + " " + error.message);
    }
  })
})

Parse.Cloud.define("findUsers", function(request, response) {
  var currlat = request.params.lat;
  var currlong = request.params.lon;
  var bound = request.params.dist;

  var profileQuery = new Parse.Query("Profile");
  profileQuery.limit(1000);
  profileQuery.ascending("Name");
  var nearbyUserIDList = [];

  var currLoc = new Parse.GeoPoint(currlat, currlong);
  profileQuery.find({
  	success: function(results) {
      var currentDate = new Date();
  		// returns a list of all current users	
  		for (var i = 0; i < results.length; i++) {
  			var object = results[i];
        var currentID = Parse.User.current().id;
        var lastActive = object.get("last_active");
        var available = object.get("Available");
        var online = object.get("Online");
  			var geopoint = object.get("Location"); // PFGeoPoint of other user's most recent location
  			
        var lastActiveDate = new Date(lastActive);
        var timeDiff = Math.abs(currentDate.getTime() - lastActiveDate.getTime());
        var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
       
        if (diffDays > 15 && available == true) {
          available = false;
          object.set("Available", false);
          object.save();
        }

        if (geopoint != null) {
	  			var dist = currLoc.kilometersTo(geopoint);

	  			if (dist <= bound && currentID != object.get("ID") && available && online){
	  				nearbyUserIDList.push(object);
             var name = object.get("Name");
	  			}
	  		}
  		}
  		response.success(nearbyUserIDList);
  	},
  	error: function(error) {
         alert("Error: " + error.code + " " + error.message);
    }
  });
});

// Takes in User's current PFGeopoint and distance bound 
// as parameters and outputs a list of User Profiles that are
// within the area. SORT BY DISTANCE
Parse.Cloud.define("findUsersByDist", function(request, response) {
  var currlat = request.params.lat;
  var currlong = request.params.lon;
  var bound = request.params.dist;

  var profileQuery = new Parse.Query("Profile");
  profileQuery.limit(1000);
  var nearbyUserIDList = [];

  var currLoc = new Parse.GeoPoint(currlat, currlong);
  profileQuery.find({
    success: function(results) {
      var currentDate = new Date();
      // returns a list of all current users  
      for (var i = 0; i < results.length; i++) {
        var object = results[i];
        var currentID = Parse.User.current().id;
        var lastActive = object.get("last_active");
        var available = object.get("Available");
        var online = object.get("Online");
        var geopoint = object.get("Location"); // PFGeoPoint of other user's most recent location
        
        var lastActiveDate = new Date(lastActive);
        var timeDiff = Math.abs(currentDate.getTime() - lastActiveDate.getTime());
        var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
        
        var name = object.get("Name");

        if (diffDays > 15 && available == true) {
          available = false;
          object.set("Available", false);
        }

        if (geopoint != null) {
          var dist = currLoc.kilometersTo(geopoint);

          if (dist <= bound && currentID != object.get("ID") && available && online){
            nearbyUserIDList.push(object);
          }
        }
      }
      response.success(nearbyUserIDList);
    },
    error: function(error) {
         alert("Error: " + error.code + " " + error.message);
    }
  });
});
/*-----------Send email-----------------------------------*/
 
Parse.Cloud.define("sendMail", function(request, response) {
   var Mandrill = require('mandrill');
   Mandrill.initialize('BLwCVUqy9NAaemxo77OHMw');
 
   var prefquery = new Parse.Query("User");
   var email = Parse.User.current().getEmail();
   prefquery.equalTo("email", email);

   prefquery.find({
      success: function(results) {
        Mandrill.sendEmail({
        message: {
          text: request.params.text,
          subject: "NovaNet Feedback",
          from_email: "nlam@princeton.edu",
          from_name: "NovaNet App",
          to: 
            [
              {
                email: "novanetfeedback@gmail.com",
                name: Parse.User.current().username,
              }
            ]
        },
        async: true
        },
        {
         success: function(httpResponse) {
         console.log(httpResponse);
         response.success("Email sent!");
         },
         error: function(httpResponse) {
         console.error(httpResponse);
         response.error("Uh oh, something went wrong");
         }
        });
      },
      error: function(error) {
         alert("Error: " + error.code + " " + error.message);
      }
  });
});

// Generates random number of length 6
function numberGenerator() {
  var string = "";
  for (var i = 0; i < 6; i++) {
    var randNum = Math.floor(Math.random() * 10);
    string = string + randNum;
  }
  return parseInt(string);
}




Parse.Cloud.define("sendUserNumber", function(request, response) {
  var Mandrill = require('mandrill');
   Mandrill.initialize('o9teflgXREp5JoM83-VTbw');
 
   var prefquery = new Parse.Query("User");
   var email = request.params.email
   var name = Parse.User.current().getUsername();
   prefquery.equalTo("email", email);

   var randomNum = numberGenerator();
   prefquery.find({
      success: function(results) {
        Mandrill.sendEmail({
        message: {
          html: "<p>Hello " + name + ",</p><br/><br/><p> Your reset code is " + randomNum + ". </p>",
          subject: "NovaNet: Reset your password",
          from_email: "novanetfeedback@gmail.com",
          from_name: "NovaNet",
          to: 
            [
              {
                email: email,
                name: Parse.User.current().username,
              }
            ]
        },
        async: true
        },
        {
         success: function(httpResponse) {
         console.log(httpResponse);
         response.success("Email sent!");
         },
         error: function(httpResponse) {
         console.error(httpResponse);
         response.error("Uh oh, something went wrong");
         }
        });
      },
      error: function(error) {
         alert("Error: " + error.code + " " + error.message);
      }
  });
});


// Finds all the distances of the users that show up in range
Parse.Cloud.define("findDistances", function(request, response) {
  var currlat = request.params.lat;
  var currlong = request.params.lon;
  var bound = request.params.dist;

  var profileQuery = new Parse.Query("Profile");
  profileQuery.limit(1000);
  profileQuery.ascending("Name");
  var distanceList = [];

  var currLoc = new Parse.GeoPoint(currlat, currlong);
  profileQuery.find({
    success: function(results) {
      // returns a list of all current users  
      for (var i = 0; i < results.length; i++) {
        var object = results[i];
        var currentID = Parse.User.current().id;
        var available = object.get("Available");
        var online = object.get("Online");
        var geopoint = object.get("Location"); // PFGeoPoint of other user's most recent location
        if (geopoint != null) {

          var dist = Math.ceil(currLoc.kilometersTo(geopoint));
          if (dist <= bound && currentID != object.get("ID") && available && online){
            distanceList.push(dist);
          }
        }
      }
      response.success(distanceList);

    },
    error: function(error) {
         alert("Error: " + error.code + " " + error.message);
    }
  });
});


Parse.Cloud.define("findConversations", function(request, response) {
  var id = Parse.User.current().id;

  // Query for all conversations participant objects where you are the user 
  // to find Conversation ID's and counters
  var conversationParticipantQuery = new Parse.Query("ConversationParticipant");
  conversationParticipantQuery.equalTo("User", id);
  conversationParticipantQuery.limit(1000);

  conversationParticipantQuery.find({
    success: function(participants) {

      // Uses the conversationID of each conversation to create list of sorted conversations
      var conversationIDList = [];
      for (var i = 0; i < participants.length; i++) {
        conversationIDList.push(participants[i].get("ConversationID"));
      }

      var conversationQuery = new Parse.Query("Conversation");
      conversationQuery.containedIn("objectId", conversationIDList);
      conversationQuery.descending("MostRecent");
      conversationQuery.find({
        success: function(conversations) {
          response.success(conversations);
        }, 
        error: function(error2) {
          alert("Error: " + error2.code + " " + error2.message);
        }
      });
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
});

Parse.Cloud.define("findConversationParticipants", function(request, response) {
  var id = Parse.User.current().id;

  // Query for all conversations participant objects where you are the user 
  // to find Conversation ID's and counters
  var conversationParticipantQuery = new Parse.Query("ConversationParticipant");
  conversationParticipantQuery.equalTo("User", id);
  conversationParticipantQuery.limit(1000);
  conversationParticipantQuery.descending("MostRecent");

  conversationParticipantQuery.find({
    success: function(participants) {
      response.success(participants);
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
});

Parse.Cloud.define("saveDataMongo", function(request, response) {

});
