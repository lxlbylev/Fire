-- 
-- Abstract: Simplifies the use of FTP functions with Lua.
-- 
-- Author: Graham Ranson - http://www.grahamranson.co.uk
--
-- Version: 1.0
-- 
-- FTP Helper is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
 
module(..., package.seeall)
 
local ftp = require("socket.ftp")
local ltn12 = require("ltn12")
 
function newConnection(params)
        
        local self = {}
        self.host = params.host or "anonymous.org"
        self.user = params.user or "anonymous"
        self.password = params.password or ""
        self.port = params.port or 21
 
        local putFile = function(params, command)
                        
                success, error = ftp.put{
                        host = self.host, 
                        user = self.user,
                        password = self.password,
                        port = self.port,
                        type = "i",
                        step = ltn12.all,
                        command = command,
                        argument = params.remoteFile,
                        source = ltn12.source.file( io.open( params.localFile, "rb" ) )  
                }
                
                if success then
                        if params.onSuccess then
                                params.onSuccess( { path = self.host .. params.remoteFile } )
                        end
                else
                        if params.onError then
                                params.onError( { error = error } ) 
                        end
                end
                                
                return success, error
                
        end
        
        local getFile = function(params)
        
                local success, error = ftp.get{
                        host = self.host, 
                        user = self.user,
                        password = self.password,
                        port = self.port,
                        type = "i",
                        step = ltn12.all,
                        command = command,
                        argument = params.remoteFile,
                        sink = ltn12.sink.file(params.localFile)
                }
                
                if success then
                        if params.onSuccess then
                                params.onSuccess( { path = params.localPath } )
                        end
                else
                        if params.onError then
                                params.onError( { error = error } ) 
                        end
                end
                        
                return success, error
        end
 
        function self:upload(params)
                return putFile(params, "stor")
        end
        
        function self:download(params)
                
                params.localPath = system.pathForFile( params.localFile, system.DocumentsDirectory )
                params.localFile = io.open( params.localPath, "w+b" ) 
 
                return getFile(params)
        
        end
        
        function self:append(params)
                return putFile(params, "appe")
        end
        
        return self
        
end