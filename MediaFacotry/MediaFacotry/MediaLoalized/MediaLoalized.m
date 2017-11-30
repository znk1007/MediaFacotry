//
//  MediaLoalized.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaLoalized.h"
#import "MediaCSVParser.h"

@interface MediaLoalizedTool()<MediaCSVParserDelegate>
@property (nonatomic, strong) NSArray<NSMutableArray *> *parseResults;
@property (nonatomic, strong) MediaCSVParser *csvParser;
@property (nonatomic, assign) NSUInteger lanCount;
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, strong) NSMutableDictionary *mapDict;

@property (nonatomic, strong) NSArray *languagePaths;
@end

@implementation MediaLoalizedTool
#pragma mark - Init
- (instancetype)initWithSourceFilePath:(NSString *)filePath languageCount:(NSUInteger)lanCount
{
    self = [super init];
    if (self) {
        _lanCount = lanCount;
        
        // 解析 key
        _mapDict = [NSMutableDictionary dictionary];
        NSDictionary *tempMapDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"source" ofType:@"strings"]];
        [tempMapDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_mapDict setObject:key forKey:obj];
        }];
        
        MediaCSVParser *parse = [[MediaCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:filePath]];
        parse.delegate = self;
        _csvParser = parse;
        
    }
    return self;
}

- (instancetype)initWithSourceFileName:(NSString *)fileName languageCount:(NSUInteger)lanCount
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:(fileName.pathExtension.length > 0) ? nil : @"csv"];
    return [self initWithSourceFilePath:filePath languageCount:lanCount];
}

- (void)setUpdata
{
    _keys = [NSMutableArray array];
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSUInteger i = 0; i < _lanCount; i++) {
        [temp addObject:[NSMutableArray array]];
    }
    _parseResults = [temp copy];
}

#pragma Puablic
- (void)beginParse
{
    [self setUpdata];
    [_csvParser parse];
}

#pragma mark - MediaCSVParserDelegate
- (void)parserDidBeginDocument:(MediaCSVParser *)parser
{
    NSLog(@"ParserDidBeginDocument");
}

- (void)parser:(MediaCSVParser *)parser didFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(localizableToolsError:error:)]) {
        [self.delegate localizableToolsError:self error:error];
    }
    NSLog(@"Parser error: %@", error);
}

- (void)parserDidEndDocument:(MediaCSVParser *)parser
{
    NSLog(@"ParserDidEndDocument");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(localizableToolsEndParse:)]) {
        [self.delegate localizableToolsEndParse:self];
    }
    
    @autoreleasepool {
        NSMutableArray *languagePaths = [NSMutableArray array];
        
        NSString *rootPath = [MediaLoalizedTool saveLocalizableRootFilePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:rootPath isDirectory:nil]) {
            [[NSFileManager defaultManager] removeItemAtPath:rootPath error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSLog(@"CSV 文件被保存到：%@", rootPath);
        
        for (NSUInteger i = 0; i < _lanCount; i++) {
            
            NSArray *aLanguages = _parseResults[i];
            NSMutableArray *temps = [NSMutableArray array];
            NSUInteger aLanCount = aLanguages.count;
            for (NSUInteger i = 0, max = _keys.count; i < max; i++) {
                if (i < aLanCount) {
                    
                    // 避免文本中还有逗号
                    NSString *aLanguage = [self removeInvalidStr:aLanguages[i]];
                    [temps addObject:[NSString stringWithFormat:@"\"%@\"=\"%@\";",_keys[i], aLanguage]];
                } else {
                    [temps addObject:[NSString stringWithFormat:@"\"%@\"=\"%@\";",_keys[i], @""]];
                }
            }
            
            NSString *csvFile = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"language_%@.csv", @(i)]];
            [[NSFileManager defaultManager] createFileAtPath:csvFile contents:nil attributes:nil];
            [languagePaths addObject:csvFile];
            
            MediaCSVWriter *writer = [[MediaCSVWriter alloc] initForWritingToCSVFile:csvFile];
            for (NSUInteger i = 0, max = temps.count; i < max; i++) {
                [writer writeField:temps[i]];
                [writer finishLine];
            }
        }
        
        _languagePaths = [languagePaths copy];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(localizableToolsEndWrite:)]) {
            [self.delegate localizableToolsEndWrite:self];
        }
    }
}

- (void)parser:(MediaCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex
{
    field = field.length == 0 ? @"❌❌" : field;
    
    if (fieldIndex == 0) {
        NSString *key = [_mapDict objectForKey:[self removeInvalidStr:field]];
        [_keys addObject:key ?: @"❌❌"];
    }
    
    if (fieldIndex < _parseResults.count) {
        [_parseResults[fieldIndex] addObject:field];
    }
}

#pragma mark - Helper
- (NSString *)removeInvalidStr:(NSString *)sourceStr
{
    NSMutableString *aLanguage = [[NSMutableString alloc] initWithString:sourceStr];
    if ([aLanguage containsString:@","] && [aLanguage hasPrefix:@"\""] && [aLanguage hasSuffix:@"\""]) {
        [aLanguage replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
        [aLanguage deleteCharactersInRange:NSMakeRange(aLanguage.length-1, 1)];
    }
    return [aLanguage copy];
}

+ (NSString *)saveLocalizableRootFilePath
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"language"];
    return rootPath;
}
@end
