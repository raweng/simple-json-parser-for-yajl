Simple JSONParser For YAJL
=======================

Simple JSON Parser For YAJL is a wrapper which allows you to parse JSON data with an event-driven model of SAX, but eliminates the need to implement the complex SAX interface (i.e.: number of callback methods that will be called when events occur during parsing).  
  
  
  
It uses simple stack-based traversal (YAJL) (i.e.: SAX-style of the JSON document to recursively create the objects at each level).  
  

An implementation of the JSON Parser Object turns JSON into NSObjects. Upon successful completion, rootObject will be an NSDictionary object.  It is also configured to send events instead of holding large in-memory data(rootObject).   
   
Configuring the parser to receive events with parser.receiveEvents = YES allows you to easily parse several Megabytes of data (above 20MB).

The end developer should not have to deal with the SAX-events and their implementation in their respective callbacks, which can make the code messy and not suitable for large documents.

The JSON Parser Delegate includes a callback which provides the current dictionary with its key and parents, so that the response could be handled accordingly.  
  
   

###### JSONParserDelegate methods
\- (void)dictionary:(NSMutableDictionary*)dictionary forKey:(NSString*)key withParents:(NSString*)parents {
    // Handle response accordingly.
    NSLog(@"<key>: %@; <parents>: %@", key, parents);
    NSLog(@"<Dict>: %@: ", dictionary);
}
  
  
   
   
#### Features:
* SAX-style parsing for json.
* Eliminates the SAX implementation complexities.
* Parses the complete data or chunks of data.
* Fully configurable 
	- Parsing whole data at a time and receiving a in-memory rootObject
	- Receive callbacks (used for a large amount of data)
* Parses large amount of data (above 20MB) easily.
  
  
  
#### Dependencies:
This parser uses the YAJL framework.
  
  
#### Usage:
The YAJLViewController in this repository shows the usage of JSONParser. 


#### License
[MIT License] (http://raweng.mit-license.org/ "MIT License")
