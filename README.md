Autoindigestion
===============
Autoindigestion is a command line tool for Mac OS X that downloads all 
available sales reports from iTunes Connect.  It uses the Auto-Ingest tool 
supplied by Apple to download individual reports.

Autoindigestion can be configured to work with multiple iTunes Connect 
vendors.  When Autoindigestion runs, it will look for vendor files, which are
standard XML plists that contain vendor information, including iTunes Connect 
sign in credentials.  For security, it is recommended that each vendor create a 
separate iTunes Connect user limited to the Sales role for use with 
Autoindigestion.

Autoindigestion is available under a BSD-style open source license.  See the
LICENSE file for details.

System Requirements
-------------------
Autoindigestion is developed on Mac OS X 10.8 Mountain Lion using Xcode 4.5.  
It is a modern Objective-C command line tool.  The current distribution is 
source only, so a Mac running Lion with Xcode installed is required.  
Autoindigestion also depends on Apple's Auto-Ingest tool, a Java class 
available from Apple at 
[http://www.apple.com/itunesnews/docs/Autoingestion.class.zip][1].  Java is 
needed to run the Auto-Ingest tool, but is no longer installed on Mac OS X by
default.  You can download the latest Java installer from Apple at
[http://support.apple.com/downloads/#Java][2].

Installation
------------
After downloading the source, open Autoindigestion.xcodeproj in Xcode then
build the project by choosing _Product | Archive_ from the menu.  When building
is complete, the _Organizer - Archives_ window will open.  Click on the 
_Distribute..._ button, choose the _Save Build Products_ option from the
dialog and click _Next_.  Save the build products when prompted.  Xcode will
suggest a build products directory name like `"Autoindigestion 7-6-12 2.35 PM"` 
located in the Autoindigestion project directory by default.

Create the `"Autoindigestion"` directory under `"/Library"`.

Unzip the Auto-Ingest tool file `"Autoingestion.class.zip"` and copy 
`"Autoingestion.class"` to `"/Library/Autoindigestion"`.

The Autoindigestion executable is located in the build products directory at
`"<build products>/usr/local/bin/Autoindigestion"`.  Copy it to
`"Library/Autoindigestion"`.

Optionally copy the man pages to your local man directories.  Copy 
`"Documentation/Autoindigestion.1"` to 
`"/usr/local/share/man/man1/Autoindigestion.1"` and 
`"Documentation/Autoindigestion.5"` to
`"/usr/local/share/man/man5/Autoindigestion.5"`.  You will need to create the
`"/usr/local/share/man/man1"` and `"/usr/local/share/man/man5"` directories if 
they don't exist.  Once in place, run the commands `man Autoindigestion` and 
`man 5 Autoindigestion` to read the respective man pages.

Configuration
-------------
Create the `"Vendors"` directory under `"/Library/Autoindigestion"`.  Create
at least one vendor file.  A vendor filename must end in `".plist"`.  Here is a
sample vendor file:
    
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>VendorName</key>
        <string>Example Inc</string>
        
        <key>VendorID</key>
        <string>81234567</string>
        
        <key>Username</key>
        <string>someone@example.com</string>
        
        <key>Password</key>
        <string>itsasecret</string>
    </dict>
    </plist>
The vendor ID is available in iTunes Connect on the "Sales and Trends" page or
can be found in an existing sales report.  For security, do **not** use the 
username and password of your iTunes Connect Admin user in the vendor file!
Create a separate iTunes Connect user limited to the Sales role for use with 
Autoindigestion.  For additional security, run `chmod 600 "<vendor file>"` 
and `sudo chown root:admin "<vendor file>"` on each vendor file you create.

To run Autoindigestion automatically each day at a specific time, create a 
launchd item at `"/Library/LaunchDaemons/Autoindigestion.plist"`.  Here is a 
sample launchd item that runs at 0800 each morning:
    
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
            "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>Autoindigestion</string>
        
        <key>ProgramArguments</key>
        <array>
            <string>/Library/Autoindigestion/Autoindigestion</string>
        </array>
        
        <key>StartCalendarInterval</key>
        <dict>
            <key>Hour</key>
            <integer>8</integer>
        </dict>
        
        <key>StandardErrorPath</key>
        <string>/Library/Logs/Autoindigestion.log</string>
        
        <key>StandardOutPath</key>
        <string>/Library/Logs/Autoindigestion.log</string>
    </dict>
    </plist>
You may want to adjust the run time based on your time zone.  iTunes Connect
reports are usually available around 0700 Cupertino time (UTC -0800 or -0700
in summer) but are occasionally delayed a few hours.

After creating the launchd item, tell launchd to load it by running 
`sudo launchctl load "/Library/LaunchDaemons/Autoindigestion.plist"`.

Downloaded reports for each vendor will be placed in
`"/Users/Shared/iTunes Connect/<VendorName>"` respectively, where `<VendorName>`
is the value of the `VendorName` key from the vendor file.

Reference
---------
See the [Autoindigestion command man page][3] for complete details on the
`Autoindigestion` command.  For more information on Autoindigestion 
configuration files, see the [Autoindigestion file formats man page][4].

For details on Apple's Auto-Ingest tool and complete information about the
iTunes Connect report format, log into iTunes Connect, go to "Sales and Trends"
and click on the "Download User Guide" link near the bottom of the page to
download the "iTunes Connect Sales and Trends Guide" PDF file.  Note that there
are different guides for vendors of apps, music, video and books.


[1]: http://www.apple.com/itunesnews/docs/Autoingestion.class.zip "Apple's Auto-Ingest tool"
[2]: http://support.apple.com/downloads/#Java "Mac OS X Java installer"
[3]: https://github.com/AblePear/Autoindigestion/blob/master/Documentation/Autoindigestion.1.txt "Autoindigestion command man page"
[4]: https://github.com/AblePear/Autoindigestion/blob/master/Documentation/Autoindigestion.5.txt "Autoindigestion file formats man page"
