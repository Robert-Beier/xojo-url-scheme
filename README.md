# xojo-url-scheme

Using a URL scheme under Mac and Windows with a single instance application

## Usage

### Mac

- run application
- type myscheme:hello_world in browser url bar

### Windows

- run as administrator at first run to make registry entries (in a final application, this should happen in the installer)
- type myscheme:hello_world in browser url bar

## Modifications for usage in your application

- move the method registerUrlSchemeWindows in an installer and modify the application path
- replace the scheme "myscheme" with yours in the registerUrlSchemeWindows method and the addUrlSchemeToPlist Build script
- write your application code in the initApplication method and the handler for a url scheme call in the siaUseParams method
- currently, if multiple url scheme calls happen before the application has been initialized, only the last parameters will be saved and used; create an array, if you need the parameters from all the calls
- your application window should not behave like the LogWindow; it should only open in initApplication; else it would be visible for a moment, everytime an url scheme is called

## Technical explaination

### Mac

This is completely explained in [this article](http://blog.xojo.com/2016/05/09/let-your-os-x-desktop-app-react-to-custom-uris/) on the xojo blog.
The application recieves url scheme parameters through the HandleAppleEvent.

### Windows

The registry entry is explained in [this article](http://blog.xojo.com/2016/08/16/custom-uri-schemes-on-windows/) on the xojo blog.
Just using the registry entry, a new instance of your application will always be started when calling the url scheme. To avoid this, a IPCSocket is used to create a single instance application. If a new instance is started, it tries to connect to the IPCSocket to check if another instance is listening. If this fails, it's the only running instance and starts listening to the IPCSocket. If connecting to the IPCSocket succeeds, another instance is already running and the one just started will pass it's url scheme parameters and close itself.
The listening instance recieves passed url scheme parameters through the DataAvaiableEvent.

## Problems

Depending on your application size, there will be a delay between calling the url scheme and your application reacting to it on windows. This is because a new instance has to be started and before the xojo app runs your code, there is some preparation done. For one of my projects (200 MB Built), it takes over 20 seconds, so it is not usable. A possible solution is a second small application, responsible for either starting the main application or forwarding the url scheme to a running instance.

## Bugs

This code may contain bugs. Please share them, if you find some to improve the code.

### Known bugs

- when parsing the windows command line call arguments, multiple double quotes aren't currently recognized
