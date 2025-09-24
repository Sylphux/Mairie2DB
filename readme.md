# Mairie2DB

This program allows to search for emails through france's official annuary via multiple methods.
You can then save the data to different file formats :
- csv file format
- json file format
- directly in a google drive spreadsheet
- in txt format

## Bundle

To be able to use the program, be sure to `bundle install`
the you can launch the program with `ruby app.rb`.

## Google Drive

To be able so save data to google drive, you need to create a .env file at the root of the project with google API credentials attributed to the following keys

.env file :
```
ID="xxxxxxxxxxxxxx.apps.googleusercontent.com"
SECRET="xxxxxxxxxx"
```
To get help creating those credentials, visit :
[google_drive gems documentation](https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md#web)

# Disclaimer !

The scrapped items are not meant to be used and only serve educational purposes.
This repo will be turned to private when the project is over.
Please do not use the scrapped content. I will decline all responsibility.

# Credits

This project is done within "The Hacking Project" cursus.