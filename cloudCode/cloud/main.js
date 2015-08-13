// Takes in User's current PFGeopoint and distance bound 
// as parameters and outputs a list of User Profiles that are
// within the area
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
  		// returns a list of all current users	
  		for (var i = 0; i < results.length; i++) {
  			var object = results[i];
        var currentID = Parse.User.current().id;
        var available = object.get("Available");
        var online = object.get("Online");
  			var geopoint = object.get("Location"); // PFGeoPoint of other user's most recent location
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
