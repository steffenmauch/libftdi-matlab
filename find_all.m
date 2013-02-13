%
%  libftdi - find_all.c example from
%  http://www.intra2net.com/en/developer/libftdi/index.php
%  as matlab equivalent example for Linux systems
%
%   Copyright 2013
%   steffen.mauch (at) gmail.com
%
%   This program is distributed under the GPL, version 2

% kind of hack to hide warnings
warning off MATLAB:loadlibrary:TypeNotFound
warning off MATLAB:loadlibrary:TypeNotFoundForStructure
[notfound,warnings] = loadlibrary('libftdi.so', '/usr/include/ftdi.h');


% with these two function calls you can 
% show the functions of the library

%libfunctionsview libftdi
%libfunctions libftdi -full

%char manufacturer[128], description[128];
buffer = blanks(128);
buffer1 = blanks(128);
manufacturer = libpointer('cstring',buffer);
description = libpointer('cstring',buffer);

nullPtr = libpointer('voidPtr',uint32(0));

ftdiPtr = calllib('libftdi', 'ftdi_new');

[ret ftdi]= calllib('libftdi', 'ftdi_init', ftdiPtr);
if( ret < 0 )
    error('ftdi_init failed');
end

%struct ftdi_device_list *devlist
devList = libpointer('ftdi_device_listPtrPtr');

[ret ftdi devList] = calllib('libftdi', 'ftdi_usb_find_all', ftdiPtr, devList,  hex2dec('0403'),  hex2dec('6010'));

if( ret < 0 )
    [string ~] = calllib('libftdi', 'ftdi_get_error_string', ftdiPtr);
    error([ 'ftdi_usb_find_all failed:' ret string]);
end

disp( '---------------------' );
disp([ char(13) 'Number of FTDI devices found: ' int2str(ret) char(13) ])

curDev = devList;
%while( isempty( fieldnames(devList.dev) ) == 0 )
while( isempty( curDev ) == 0 )
    [ret ftdi b3 manufacturer_str description_str b6] = calllib('libftdi', 'ftdi_usb_get_strings', ftdiPtr, curDev.dev, manufacturer, 128, description, 128, nullPtr, 0 );
    if( ret < 0 ) 
        [string ~] = calllib('libftdi', 'ftdi_get_error_string', ftdiPtr);
        error([ 'ftdi_usb_find_all failed:' ret string]);
    end
    disp( ['Manufacturer: ' manufacturer_str '  -  Description: ' description_str char(13) ] )
    curDev = curDev.next;
end

calllib('libftdi', 'ftdi_list_free', devList);
calllib('libftdi', 'ftdi_deinit', ftdiPtr);

% clear libftdi objects otherwise library cannot be unloaded
clear ftdiPtr nullPtr ftdi description manufacturer devList
unloadlibrary('libftdi');
