// Takes in User's current PFGeopoint and distance bound 
// as parameters and outputs a list of User Profiles that are
// within the area
Parse.Cloud.define("findUsers", function(request, response) {
  var currlat = request.params.lat;
  var currlong = request.params.lon;
  var bound = request.params.dist;

  var profileQuery = new Parse.Query("Profile");
  profileQuery.limit(1000);

  var nearbyUserIDList = [];

  var currLoc = new Parse.GeoPoint(currlat, currlong);
  profileQuery.find({
  	success: function(results) {
  		// returns a list of all current users	
  		for (var i = 0; i < results.length; i++) {
  			var object = results[i];
        var currentID = Parse.User.current().id;

  			var geopoint = object.get("Location"); // PFGeoPoint of other user's most recent location
  			if (geopoint != null) {
	  			var dist = currLoc.kilometersTo(geopoint);

	  			if (dist <= bound && currentID != object.get("ID")){
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
