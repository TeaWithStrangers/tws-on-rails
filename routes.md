Documentation/Listing of all routes in the TWS API. These will need to be
documented.

# User 
* `GET` /user - info about current user
* `POST` /user - register a user
* `POST` /user/login 
* `POST` /user/logout 
* `GET` /user/:uid - info about user, including tea time attendances. Limited to Hosts+Admins
* `POST` /user/:uid/permissions - Takes a JSON blob [Shape TBD], grants/revokes
  user permissions. Limited to admins

# Cities
* `GET` /city - list of all tea time cities
* `POST` /city - create a city, limited to admins
* `GET` /city/:id - get info about a specific city
* `DELETE` /city/:id - delete a city
* `PUT` /city/:id - update information about a specific city

# Tea Times
* `GET` /city/:id/teatime - get information about tea times within a specific
  date range, or within the next ~two weeks
* `GET` /city/:id/teatime/:id - get information about a tea time
* `POST` /city/:id/teatime - create a tea time in that city
* `PUT` /city/:id/teatime/:id - update information about a tea time
* `DELETE` /city/:id/teatime/:id - delete/cancel a tea time
