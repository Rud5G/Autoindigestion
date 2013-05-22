 /*
 
 File: ZipDocument.m
 
 Abstract: ZipDocument is the NSDocument subclass representing
 a zip archive and serving as the browser's delegate.
 
 Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008-2009 Apple Inc. All Rights Reserved.
 
 */ 

#import "ZipDocument.h"
#import "ZipEntry.h"
#import "NSData+ZipBrowser.h"
#import <zlib.h>

#define MIN_DIRECTORY_END_OFFSET    20
#define MAX_DIRECTORY_END_OFFSET    66000
#define FILE_HEADER_LENGTH          30
#define DIRECTORY_ENTRY_LENGTH      46

#define DIRECTORY_END_TAG           0x06054b50
#define DIRECTORY_ENTRY_TAG         0x02014b50
#define FILE_ENTRY_TAG              0x04034b50


 @implementation ZipDocument

- (id)init {
    self = [super init];
    if (self) {
        rootEntry = [ZipEntry rootEntry];
    }
    return self;
}

 - (void)readEntries;
{
    NSString *path = nil;
    unsigned long long length = [dataBuffer fileLength];
    uint32_t i, directoryIndex;

    for (i = 0, directoryIndex = directoryEntriesStart; i < numberOfDirectoryEntries; i++) {
        uint16_t compression, namelen, extralen, commentlen;
        uint32_t crcval, csize, usize, headeridx;

        if (directoryIndex < directoryEntriesStart || directoryIndex >= length || directoryIndex + DIRECTORY_ENTRY_LENGTH <= directoryEntriesStart || directoryIndex + DIRECTORY_ENTRY_LENGTH > length || [dataBuffer littleUnsignedIntAtOffset:directoryIndex] != DIRECTORY_ENTRY_TAG) break;

        compression = [dataBuffer littleUnsignedShortAtOffset:directoryIndex + 10];
        crcval = [dataBuffer littleUnsignedIntAtOffset:directoryIndex + 16];
        csize = [dataBuffer littleUnsignedIntAtOffset:directoryIndex + 20];
        usize = [dataBuffer littleUnsignedIntAtOffset:directoryIndex + 24];
        namelen = [dataBuffer littleUnsignedShortAtOffset:directoryIndex + 28];
        extralen = [dataBuffer littleUnsignedShortAtOffset:directoryIndex + 30];
        commentlen = [dataBuffer littleUnsignedShortAtOffset:directoryIndex + 32];
        headeridx = [dataBuffer littleUnsignedIntAtOffset:directoryIndex + 42];

        if (directoryIndex + DIRECTORY_ENTRY_LENGTH + namelen <= directoryEntriesStart || directoryIndex + DIRECTORY_ENTRY_LENGTH + namelen > length) break;

        if (namelen > 0 && headeridx < directoryEntriesStart) {
            NSData *nameData = [dataBuffer dataAtOffset:directoryIndex + DIRECTORY_ENTRY_LENGTH length:namelen];
            if (nameData && [nameData length] == namelen) {
                path = [[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding];
                if (!path) path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:[nameData bytes] length:[nameData length]];
                if (!path) path = [[NSString alloc] initWithData:nameData encoding:NSWindowsCP1252StringEncoding];
                if (!path) path = [[NSString alloc] initWithData:nameData encoding:NSMacOSRomanStringEncoding];
            }
        }

        if (path) {
            ZipEntry *entry = [[ZipEntry alloc] initWithPath:path headerOffset:headeridx CRC:crcval compressedSize:csize uncompressedSize:usize compressionType:compression];
            [entry addToRootEntry:rootEntry];
        }
        directoryIndex += DIRECTORY_ENTRY_LENGTH + namelen + extralen + commentlen;
    }
}

static inline uint32_t _crcFromData(NSData *data) {
    uint32_t crc = (uint32_t) crc32(0, NULL, 0);
    return (uint32_t) crc32(crc, [data bytes], (uInt) [data length]);
}

- (NSData *)unzipEntry:(ZipEntry *)zipEntry {
    unsigned long long length = [dataBuffer fileLength];
    uint16_t compression = [zipEntry compressionType], namelen, extralen;
    uint32_t crcval = [zipEntry CRC], csize = [zipEntry compressedSize], usize = [zipEntry uncompressedSize], headeridx = [zipEntry headerOffset], dataidx;
    z_stream stream;

    if (headeridx < length && headeridx + FILE_HEADER_LENGTH > headeridx && headeridx + FILE_HEADER_LENGTH < length && csize > 0 && usize > 0 && [dataBuffer littleUnsignedIntAtOffset:headeridx] == FILE_ENTRY_TAG && [dataBuffer littleUnsignedShortAtOffset:headeridx + 8] == compression) {
        namelen = [dataBuffer littleUnsignedShortAtOffset:headeridx + 26];
        extralen = [dataBuffer littleUnsignedShortAtOffset:headeridx + 28];
        dataidx = headeridx + FILE_HEADER_LENGTH + namelen + extralen;

        if (dataidx < length && dataidx + csize > dataidx && dataidx + csize > headeridx && dataidx + csize < length) {
            NSData *compressedData = [dataBuffer dataAtOffset:dataidx length:csize];
            if (0 == compression && compressedData && [compressedData length] == csize && usize == csize && _crcFromData(compressedData) == crcval) {
                return compressedData;
            } else if (8 == compression && compressedData && [compressedData length] == csize && usize / 64 < csize) {
                NSMutableData *mutableData = [NSMutableData dataWithLength:usize];
                bzero(&stream, sizeof(stream));
                stream.next_in = (Bytef *)[compressedData bytes];
                stream.avail_in = (uInt) [compressedData length];
                stream.next_out = (Bytef *)[mutableData mutableBytes];
                stream.avail_out = usize;

                if (mutableData && Z_OK == inflateInit2(&stream, -15)) {
                    if (Z_STREAM_END == inflate(&stream, Z_FINISH)) {
                        if (Z_OK == inflateEnd(&stream) && usize == stream.total_out && _crcFromData(mutableData) == crcval) return mutableData;
                    } else {
                        (void)inflateEnd(&stream);
                    }
                }
            }
        }
    }
    return nil;
}

 - (BOOL)readFromDataBuffer:(NSData *)theDataBuffer error:(NSError **)error {
    dataBuffer = theDataBuffer;
    if (dataBuffer) {
        unsigned long long directoryEntriesEnd = 0;
        unsigned long long length = [dataBuffer fileLength];

        for (unsigned long long i = MIN_DIRECTORY_END_OFFSET; directoryEntriesEnd == 0 && i < MAX_DIRECTORY_END_OFFSET && i < length; i++) {
            uint32_t potentialTag = [dataBuffer littleUnsignedIntAtOffset:length - i];
            if (potentialTag == DIRECTORY_END_TAG) {
                directoryEntriesEnd = length - i;
                numberOfDirectoryEntries = [dataBuffer littleUnsignedShortAtOffset:directoryEntriesEnd + 8];
                directoryEntriesStart = [dataBuffer littleUnsignedIntAtOffset:directoryEntriesEnd + 16];
            }
        }

        if (numberOfDirectoryEntries > 0 && directoryEntriesEnd > 0 && directoryEntriesStart > 0 && directoryEntriesStart < length) {
            [self readEntries];
            return YES;
        } else {
            dataBuffer = nil;
            if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:nil];
        }
    }
    return NO;
}

 - (ZipEntry *)rootEntry {
    return rootEntry;
}

@end
