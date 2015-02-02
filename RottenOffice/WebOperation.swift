//
//  WebOperation.swift
//  Dionysus
//
//  Created by Cold Logic on 11/7/14.
//  Copyright (c) 2014 Cold and Logical. All rights reserved.
//

import Foundation

/**
*       Helper class to facilitate the use of NSURLConnections with minimal setup.
*/
public class WebOperation : NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
        /// Lazily loaded NSURLConnection object that is created with the request and self set as the delegate
        lazy public var connection: NSURLConnection! = {
                let c = NSURLConnection(request: self.request, delegate: self, startImmediately: false)
                return c
                }()
        
        /// Completion handler reference object
        public var completionHandler: ((request: NSURLRequest, json: NSDictionary) -> Void)?
        
        /// Failure handler reference object
        public var failureHandler: ((request: NSURLRequest, error: NSError) -> Void)?
        
        /// Lazily loaded NSMutableData object that all data received from the connection is appended to
        lazy public var receivedData: NSMutableData = NSMutableData()
        
        /// Lazily loaded NSMutableURLRequest object with default header information filled in
        lazy public var request: NSMutableURLRequest! = {
                let r = NSMutableURLRequest(URL: NSURL(string: self.urlString!)!)
                r.HTTPMethod = "GET"
                r.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                r.setValue("application/json", forHTTPHeaderField: "Accept")
                return r
                }()
        
        /// The string representation of the URL to connect to
        public var urlString: String?
        
        /**
        Default initializer to set the urlString property
        
        :param: URL The string represenation of the URL to connect to
        
        :returns: A defaultly configured WebOperation object with the urlString set to the inputted URL
        */
        required public init(URL: String) {
                super.init()
                urlString = URL
        }
        
        //MARK: Initializers
        /**
        Main intializer for the WebOperation class. It will probably never be invoked directly as the other convenence initializers utilize this one.
        
        :param: URL                          The string representation of the URL to connect to
        :param: parameters              A Dictionary of keys and values that will be converted into the GET parameters for the URI to be appended to the end of the URL
        :param: data                          A Dictionary of keys and values that will be converted into a URI and appended to the body of the request
        
        :returns: A properly configured WebOperation object that will connect to the URL with the inputted data properly place into the structure
        */
        required convenience public init(URL: String, parameters: [String:String]?, data: [String:String]?) {
                self.init(URL: URL)
                
                if parameters != nil {
                        let parameterString = WebOperation.queryString(parameters)
                        urlString! += "?" + parameterString
                }
                
                if data != nil {
                        let dataString = WebOperation.queryString(data)
                        self.appendStringToData(dataString)
                        request.HTTPMethod = "POST"
                }
        }
        
        /**
        Convience initializer that facilitates data into a POST request.
        
        :param: URL  The string representation of the URL to connect to
        :param: data A Dictionary of keys and values that will be converted into a URI and appended to the body of the request
        
        :returns: A properly configured WebOperation object that will connect to the URL with the inputted data properly place into the structure
        */
        required convenience public init(URL: String, data: [String:String]?) {
                self.init(URL: URL, parameters: nil, data: data)
        }
        
        /**
        Convience initializer that facilitates data into the URI of a GET request.
        
        :param: URL  The string representation of the URL to connect to
        :param: parameters A Dictionary of keys and values that will be converted into the GET parameters for the URI to be appended to the end of the URL
        
        :returns: A properly configured WebOperation object that will connect to the URL with the inputted data properly place into the structure
        */
        required convenience public init(URL: String, parameters: [String:String]?) {
                self.init(URL: URL, parameters: parameters, data: nil)
        }
        
        //MARK: Class functions
        public class func queryString(queries: [String:String]!) -> String! {
                var pString: String = String()
                for (key, value) in queries! {
                        if pString.utf16Count != 0 {
                                pString += "&"
                        }
                        pString += "\(key)=\(value)"
                }
                return pString
        }
        
        //MARK: Instance Operations
        public func appendStringToData(string: String!) {
                let mutableData = NSMutableData()
                mutableData.appendData(string.dataUsingEncoding(NSASCIIStringEncoding)!)
                
                if let currentBody = request.HTTPBody {
                        mutableData.appendData(currentBody)
                }
                
                request.HTTPBody = mutableData
        }
        
        public func connect(completion: ((request: NSURLRequest, json: NSDictionary) -> Void)?, failure: ((request: NSURLRequest, error: NSError) -> Void)?) {
                completionHandler = completion
                failureHandler = failure
                connection.start()
        }
        
        //MARK: NSURLConnectionDataDelegate
        /**
        NSURLConnectionDataDelegate method. Continuosly appends the received data to the holding variable to be sent when the connection finishes loading.
        */
        public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
                receivedData.appendData(data)
        }
        
        //MARK: NSURLConnectionDelegate
        /**
        NSURLConnectionDelegate method. When the connection fails, this will call the failure handler if it isn't nil, and pass the NSError through, along with the NSURLRequest.
        */
        public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
                println("Connection Failed: \(error)")
                if failureHandler != nil {
                        failureHandler!(request: connection.originalRequest, error: error)
                }
        }
        
        /**
        NSURLConnectionDelegate method. When the connection finishes loading, it deserializes it into JSON and calls the completion handler if it isn't nil. If the recieved data isn't JSON, or the JSON serialization fails, the failure handler is called
        */
        public func connectionDidFinishLoading(connection: NSURLConnection) {
                var error: NSError?
                
                if let jsonData: AnyObject = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.allZeros, error: &error) {
                        println("Connection Succeeded for request: \(connection.originalRequest)\n \(jsonData)")
                        if completionHandler != nil {
                                completionHandler!(request: connection.originalRequest, json: jsonData as NSDictionary)
                        }
                } else {
                        println("Connection Succeeded, but no JSON found: \(NSString(data: receivedData, encoding: NSASCIIStringEncoding))")
                        if failureHandler != nil {
                                failureHandler!(request: connection.originalRequest, error: error!)
                        }
                }
                
                receivedData = NSMutableData()
        }
        
        /**
        NSURLConnectionDelegate method. Returns true if the protection space  authentication method is NSURLAuthenticationMethodServerTrust
        */
        public func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool {
                return protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
        }
        
        /**
        NSURLConnectionDelegate method. If the protection space of the challenge is NSURLAuthenticationMethodServerTrust, a call will be made to the challenge's sender to use a server trust NSURLCredential
        */
        public func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                        let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
                        challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)
                }
        }
}
