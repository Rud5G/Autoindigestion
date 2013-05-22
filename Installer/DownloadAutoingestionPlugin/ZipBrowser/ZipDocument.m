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
#import "FileBuffer.h"
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
    unsigned long long length = [fileBuffer fileLength];
    uint32_t i, directoryIndex;

    for (i = 0, directoryIndex = directoryEntriesStart; i < numberOfDirectoryEntries; i++) {
        uint16_t compression, namelen, extralen, commentlen;
        uint32_t crcval, csize, usize, headeridx;

        if (directoryIndex < directoryEntriesStart || directoryIndex >= length || directoryIndex + DIRECTORY_ENTRY_LENGTH <= directoryEntriesStart || directoryIndex + DIRECTORY_ENTRY_LENGTH > length || [fileBuffer littleUnsignedIntAtOffset:directoryIndex] != DIRECTORY_ENTRY_TAG) break;

        compression = [fileBuffer littleUnsignedShortAtOffset:directoryIndex + 10];
        crcval = [fileBuffer littleUnsignedIntAtOffset:directoryIndex + 16];
        csize = [fileBuffer littleUnsignedIntAtOffset:directoryIndex + 20];
        usize = [fileBuffer littleUnsignedIntAtOffset:directoryIndex + 24];
        namelen = [fileBuffer littleUnsignedShortAtOffset:directoryIndex + 28];
        extralen = [fileBuffer littleUnsignedShortAtOffset:directoryIndex + 30];
        commentlen = [fileBuffer littleUnsignedShortAtOffset:directoryIndex + 32];
        headeridx = [fileBuffer littleUnsignedIntAtOffset:directoryIndex + 42];

        if (directoryIndex + DIRECTORY_ENTRY_LENGTH + namelen <= directoryEntriesStart || directoryIndex + DIRECTORY_ENTRY_LENGTH + namelen > length) break;

        if (namelen > 0 && headeridx < directoryEntriesStart) {
            NSData *nameData = [fileBuffer dataAtOffset:directoryIndex + DIRECTORY_ENTRY_LENGTH length:namelen];
            if (nameData && [nameData length] == namelen) {
                path = [[NSString alloc] initWithData:nameData encoding:documentEncoding];
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

- (BOOL)writeEntry:(ZipEntry *)zipEntry toFileURL:(NSURL *)fileURL forOperation:(NSOperation *)operation error:(NSError **)error {
    BOOL retval = NO;
    unsigned long long length = [fileBuffer fileLength];
    uint16_t compression = [zipEntry compressionType], namelen, extralen;
    uint32_t crcval = [zipEntry CRC], csize = [zipEntry compressedSize], usize = [zipEntry uncompressedSize], headeridx = [zipEntry headerOffset], dataidx;
    NSData *compressedData = nil, *uncompressedData = nil;
    NSMutableData *mutableData = nil;
    NSError *localError = nil;
    z_stream stream;
    
    if (headeridx < length && headeridx + FILE_HEADER_LENGTH > headeridx && headeridx + FILE_HEADER_LENGTH < length && csize > 0 && usize > 0 && [fileBuffer littleUnsignedIntAtOffset:headeridx] == FILE_ENTRY_TAG && [fileBuffer littleUnsignedShortAtOffset:headeridx + 8] == compression) {
        namelen = [fileBuffer littleUnsignedShortAtOffset:headeridx + 26];
        extralen = [fileBuffer littleUnsignedShortAtOffset:headeridx + 28];
        dataidx = headeridx + FILE_HEADER_LENGTH + namelen + extralen;

        if (dataidx < length && dataidx + csize > dataidx && dataidx + csize > headeridx && dataidx + csize < length) {
            // Currently this is all done in memory, but it could potentially be done block-by-block as a stream
            compressedData = [fileBuffer dataAtOffset:dataidx length:csize];
            if (0 == compression && compressedData && [compressedData length] == csize && usize == csize && _crcFromData(compressedData) == crcval) {
                // If the entry is stored uncompressed, we write it out verbatim
                uncompressedData = compressedData;
            } else if (8 == compression && compressedData && [compressedData length] == csize && usize / 64 < csize) {
                // If the entry is stored deflated, we inflate it and write out the results
                mutableData = [NSMutableData dataWithLength:usize];
                bzero(&stream, sizeof(stream));
                stream.next_in = (Bytef *)[compressedData bytes];
                stream.avail_in = (uInt) [compressedData length];
                stream.next_out = (Bytef *)[mutableData mutableBytes];
                stream.avail_out = usize;

                if (mutableData && Z_OK == inflateInit2(&stream, -15)) {
                    if (Z_STREAM_END == inflate(&stream, Z_FINISH)) {
                        if (Z_OK == inflateEnd(&stream) && usize == stream.total_out && _crcFromData(mutableData) == crcval) uncompressedData = mutableData;
                    } else {
                        (void)inflateEnd(&stream);
                    }
                }
            }
            if (uncompressedData && [uncompressedData writeToURL:fileURL options:NSAtomicWrite error:&localError]) retval = YES;
        }
    }
    if (!retval && error) *error = localError ? localError : [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileURL, NSURLErrorKey, nil]];
    return retval;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL encoding:(NSStringEncoding)encoding error:(NSError **)error {
    BOOL retval = NO;
    unsigned long long i, length, directoryEntriesEnd = 0;
    uint32_t potentialTag;
    NSError *localError = nil;

    if (!fileBuffer) fileBuffer = [[FileBuffer alloc] initWithURL:absoluteURL error:&localError];
    if (fileBuffer) {
        documentEncoding = encoding;
        length = [fileBuffer fileLength];

        // First, we locate the zip directory
        for (i = MIN_DIRECTORY_END_OFFSET; directoryEntriesEnd == 0 && i < MAX_DIRECTORY_END_OFFSET && i < length; i++) {
            potentialTag = [fileBuffer littleUnsignedIntAtOffset:length - i];
            if (potentialTag == DIRECTORY_END_TAG) {
                directoryEntriesEnd = length - i;
                numberOfDirectoryEntries = [fileBuffer littleUnsignedShortAtOffset:directoryEntriesEnd + 8];
                directoryEntriesStart = [fileBuffer littleUnsignedIntAtOffset:directoryEntriesEnd + 16];
            }
        }

        // If we have a valid zip directory, report success and queue reading of the actual entries in the background
        if (numberOfDirectoryEntries > 0 && directoryEntriesEnd > 0 && directoryEntriesStart > 0 && directoryEntriesStart < length) {
            [self readEntries];
            retval = YES;
        } else {
            [fileBuffer close];
            fileBuffer = nil;
        }
    }
    if (!retval && error) *error = localError ? localError : [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:absoluteURL, NSURLErrorKey, nil]];
    return retval;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL error:(NSError **)outError {
    return [self readFromURL:absoluteURL encoding:NSUTF8StringEncoding error:outError];
}

- (void)setFileBuffer:(FileBuffer *)theFileBuffer {
    fileBuffer = theFileBuffer;
}

- (ZipEntry *)rootEntry {
    return rootEntry;
}

@end
