SimpleJSONParserForYAJL
=======================

Simple JSON Parser For YAJL is a wrapper which allows you to parse the json data with event-driven model of SAX, but eliminating the implementation of the complex SAX interface ie. number of callback methods that will be called when events occur during parsing.  
  
  
  
Uses simple stack-based traversal (YAJL) ie. SAX-style of the JSON document to recursively create the objects at each level.  
  

An implementation of the JSONParser object turns JSON into NSObjects. Upon successful completion, rootObject will be an NSDictionary object.   
It is also configurable to send events instead of holding large in-memory data(rootObject).   
   
Configuring the parser to receive events with 'parser.receiveEvents = YES' allows you to parse several MBs of data (above 20MB) easily. 

End developer should not have to deal with the SAX-events and their implementation in the respective callbacks which makes the code messy and also not suitable for large documents.  

The JSONParserDelegate includes a callback which provides the current dictionary with its key and parents, so that response could be handled accordingly.  
  
   

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
	- Receive callbacks (used for huge amount of data)
* Can parse large amount of data (above 20MB) easily.
  
  
  
#### Dependencies:
YAJL framework
  
  
#### Usage:
The YAJLViewController in this repository shows the usage of JSONParser. 


#### License
http://gautam.mit-license.org/
