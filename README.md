# Script to get invites oneplus from twitter

In September I got over 500+ invites with this script.<br />
Speed of work since, as someone posted, until the script is activated invite, **200-300ms**.
![invites](http://i.imgur.com/NdXCBqW.png)

## Algorithm

* Loads a list of accounts from the file db/oneplus.db
* Get invite from [Twitter Streaming API](https://dev.twitter.com/streaming/overview)
* Activate in account.oneplus.net
* Sends a notification via pushover.net<br />![](http://i.imgur.com/3hcYDsh.png)<br />![](http://i.imgur.com/WdUJpWI.png)
* Switches to the next account, repeat
* Profit!
