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
Autoindigestion is developed on Mac OS X 10.8 Mountain Lion using Xcode 5.0.
It is a modern Objective-C command line tool.  The current distribution is 
source only, so a Mac running Mountain Lion with Xcode installed is required.
The Xcode project now includes a target for building a standard Mac installer
package.  (A pre-built, signed installer package is planned for the future.)

Autoindigestion also depends on Apple's Auto-Ingest tool, a Java class 
available from Apple at 
[http://www.apple.com/itunesnews/docs/Autoingestion.class.zip][1].  The 
installer package will automatically download the latest version of the 
Auto-Ingest tool from Apple.  Java is needed to run the Auto-Ingest tool, but 
is no longer installed on Mac OS X by default.  You can download the latest 
Java installer from Apple at [http://support.apple.com/downloads/#Java][2].

Installation
------------
After downloading the source, open `Autoindigestion.xcodeproj` in Xcode then
build the installer package by selecting the _Installer_ scheme in the
_Product | Scheme_ menu, then choosing _Product | Build_ or _Product | Run_.
If you run the _Installer_ scheme from Xcode, the Autoindigestion installer will
launch automatically after it is built.  To locate the installer package file,
right click on the `Autoindigestion.pkg` entry in the Xcode project and select
_Show in Finder_.

Manual Installation and Removal
-------------------------------
The Autoindigestion installer creates the following directories and files:

  - `"/Library/Autoindigestion/Autoindigestion"`
  - `"/Library/Autoindigestion/Autoingestion.class"`
  - `"/Library/Autoindigestion/Vendors/ExampleVendor.plist"`
  - `"/Library/LaunchDaemons/Autoindigestion.plist"`
  - `"/usr/local/share/man/man1/Autoindigestion.1"`
  - `"/usr/local/share/man/man5/Autoindigestion.5"`

In addition, the installer creates a temporary directory named
`"/tmp/com.ablepear.autoindigestion.installer/"` and will remove it when 
installation is completed under normal circumstances.

Configuration
-------------
Create at least one vendor file in `"/Library/Autoindigestion/Vendors"`.  A
vendor filename must end in `".plist"`.  Here is a sample vendor file:
    
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
The installer will create a similar one at
`"/Library/Autoindigestion/Vendors/ExampleVendor.plist"`.  The vendor ID is
available in iTunes Connect on the "Sales and Trends" page or can be found in
an existing sales report.  For security, do **not** use the  username and
password of your iTunes Connect Admin user in the vendor file!  Create a
separate iTunes Connect user limited to the Sales role for use with
Autoindigestion.  For additional security, run `chmod 600 "<vendor file>"` and
`sudo chown root:admin "<vendor file>"` on each vendor file you create.

The installer creates and loads a launchd item at
`"/Library/LaunchDaemons/Autoindigestion.plist"` that will run Autoindigestion
automatically each day.  Here is a sample launchd item that runs at 8:30 AM in
the morning and again at 1030 PM in the evening:
    
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
        <array>
            <dict>
                <key>Hour</key>
                <integer>8</integer>
                <key>Minute</key>
                <integer>30</integer>
            </dict>
            <dict>
                <key>Hour</key>
                <integer>22</integer>
                <key>Minute</key>
                <integer>30</integer>
            </dict>
        </array>
        <key>StandardErrorPath</key>
        <string>/Library/Logs/Autoindigestion.log</string>
        
        <key>StandardOutPath</key>
        <string>/Library/Logs/Autoindigestion.log</string>
    </dict>
    </plist>
You may want to adjust the run time based on your time zone.  iTunes Connect
reports are usually available around 0700 Cupertino time (UTC -0800 or -0700
in summer) but are occasionally delayed a few hours.

After creating or modifying the launchd item, tell launchd to load it by
running `sudo launchctl load "/Library/LaunchDaemons/Autoindigestion.plist"`.

To disable Autoindigestion, run
`sudo launchctl unload "/Library/LaunchDaemons/Autoindigestion.plist"`.

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
