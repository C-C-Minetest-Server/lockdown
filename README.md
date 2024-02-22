# Server Lockdown

This mod puts the server into temporary maintenance mode on admin request. If any player without `server` or `privs` privileges attempts to join during maintenance, they will be rejected for an optional reason.

Whether the server is in maintenance is controlled by the existence of `<world>/lockdown.txt`; if present, its content is the reason for maintenance. It can also be controlled by a chatcommand (`/lockdown on/off [<reason>]`).
