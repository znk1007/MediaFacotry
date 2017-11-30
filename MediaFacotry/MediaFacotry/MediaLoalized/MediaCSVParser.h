//
//  MediaCSVParser.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NS_DESIGNATED_INITIALIZER
#define NS_DESIGNATED_INITIALIZER
#endif

extern NSString * const MediaCSVErrorDomain;

typedef NS_ENUM(NSInteger, MediaCSVErrorCode) {
    /**
     * 表示分隔的文件没有被正确解析。如，双引号的位置错误了
     */
    MediaCSVErrorCodeInvalidFormat = 1,
    
    /**
     * 如 使用MediaCSVParserOptionsUsesFirstLineAsKeys，所有行数都必须一致，否则解析中断并返回错误
     */
    MediaCSVErrorCodeIncorrectNumberOfFields,
};

typedef NS_OPTIONS(NSUInteger, MediaCSVParserOptions) {
    /**
     *  不允许反斜杠作为特殊字符。如使用该选项，则不应该使用反斜杠作为分隔符
     *  参考MediaCSVParser.recognizesBackslashesAsEscapes
     */
    MediaCSVParserOptionsRecognizesBackslashesAsEscapes = 1 << 0,
    /**
     *  引用前清理区域
     *  参考MediaCSVParser.sanitizesFields
     */
    MediaCSVParserOptionsSanitizesFields = 1 << 1,
    /**
     *  注释一般以"#"，如使用该选项，则不能以 "#" 作为分隔符
     *  参考MediaCSVParser.recognizesComments
     */
    MediaCSVParserOptionsRecognizesComments = 1 << 2,
    /**
     *  删除空格
     *  参考MediaCSVParser.trimsWhitespace
     */
    MediaCSVParserOptionsTrimsWhitespace = 1 << 3,
    /**
     *  当您指定此选项时，得到的不是获取一组字符串数组，
     *  而是 MediaCSVOrderedDictionary实例数组。
     *  如果文件只包含一行，则返回空数组。
     */
    MediaCSVParserOptionsUsesFirstLineAsKeys = 1 << 4,
    /**
     *  一些分隔的文件包含以等号开头的字段，
     *  表示内容不应摘要或重新解释。
     *  （ 例如，删除无关紧要的数字）
     *  如果指定此选项，则不能使用等号作为分隔符。
     *  参考MediaCSVParser.recognizesLeadingEqualSign
     *  @link http://edoceo.com/utilitas/csv-file-format
     */
    MediaCSVParserOptionsRecognizesLeadingEqualSign = 1 << 5
};

#pragma mark - 、、、、、、、、、、、转换工具类、、、、、、、、、、、、、、、



/**
 *  An @c NSDictionary subclass that maintains a strong ordering of its key-value pairs
 */
@interface MediaCSVOrderedDictionary : NSDictionary

/**
 重写字典初始化

 @param objects 值数组
 @param keys 键数组
 @return MediaCSVOrderedDictionary
 */
- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys NS_DESIGNATED_INITIALIZER;

/**
 重写解码方法

 @param aDecoder 解码器
 @return MediaCSVOrderedDictionary
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 下标获取对象

 @param idx 下标
 @return 对象
 */
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

/**
 下标获取对象

 @param idx 下标
 @return 对象
 */
- (id)objectAtIndex:(NSUInteger)idx;

@end

@interface NSArray (MediaCSVAdditions)

/**
 解析CSV文件
 
 *  @param fileURL 文件路径
 *  @return 如成功则返回数组结果，否则返回nil
 */
+ (instancetype)arrayWithContentsOfCSVURL:(NSURL *)fileURL;

/**
 解析CSV文件

 @param fileURL 文件路径
 @param options MediaCSVParserOptions
 @return 如成功则返回数组结果，否则返回nil
 */
+ (instancetype)arrayWithContentsOfCSVURL:(NSURL *)fileURL options:(MediaCSVParserOptions)options;

/**
 解析CSV文件

 @param fileURL 文件路径
 @param delimiter 分隔符
 @return 如成功则返回数组结果，否则返回nil
 */
+ (instancetype)arrayWithContentsOfDelimitedURL:(NSURL *)fileURL delimiter:(unichar)delimiter;

/**
 解析含分隔文件

 @param fileURL 文件路径
 @param options MediaCSVParserOptions
 @param delimiter 分隔符
 @return 如成功则返回数组结果，否则返回nil
 */
+ (instancetype)arrayWithContentsOfDelimitedURL:(NSURL *)fileURL options:(MediaCSVParserOptions)options delimiter:(unichar)delimiter;


/**
 解析含分隔文件

 @param fileURL 文件路径
 @param options MediaCSVParserOptions
 @param delimiter 分隔符
 @param error 解析错误
 @return 如成功则返回数组结果，否则返回nil
 */
+ (instancetype)arrayWithContentsOfDelimitedURL:(NSURL *)fileURL options:(MediaCSVParserOptions)options delimiter:(unichar)delimiter error:(NSError *__autoreleasing *)error;

/**
 CSV字符串

 @return 如成功则返回CSV字符串，否则返回nil
 */
- (NSString *)CSVString;

@end

@interface NSString (MediaCSVAdditions)


/**
 CSV数据
 */
@property (nonatomic, readonly) NSArray *CSVComponents;


/**
 获取CSV数据

 @param options MediaCSVParserOptions
 @return CSV数据数组
 */
- (NSArray *)CSVComponentsWithOptions:(MediaCSVParserOptions)options;

/**
 *  Parses the receiver as a delimited string
 *
 *  @param delimiter The delimiter used in the string
 *
 *  @return An @c NSArray of @c NSArrays of @c NSStrings, if parsing succeeds; @c nil otherwise.
 */

/**
 获取CSV数据

 @param delimiter 分隔符
 @return CVS数据
 */
- (NSArray *)componentsSeparatedByDelimiter:(unichar)delimiter;

/**
 *  Parses the receiver as a delimited string
 *
 *  @param delimiter The delimiter used in the string
 *  @param options   A bitwise-OR of @c MediaCSVParserOptions to control how parsing should occur
 *
 *  @return An @c NSArray of @c NSArrays of @c NSStrings, if parsing succeeds; @c nil otherwise.
 */

/**
 获取CSV数据

 @param delimiter 分隔符
 @param options MediaCSVParserOptions
 @return CVS数据
 */
- (NSArray *)componentsSeparatedByDelimiter:(unichar)delimiter options:(MediaCSVParserOptions)options;

/**
 获取CSV数据

 @param delimiter 分隔符
 @param options MediaCSVParserOptions
 @param error 错误
 @return CVS数据
 */
- (NSArray *)componentsSeparatedByDelimiter:(unichar)delimiter options:(MediaCSVParserOptions)options error:(NSError *__autoreleasing *)error;

@end

#pragma mark - 、、、、、、、、、、、CSV写入工具类、、、、、、、、、、、、、、、


@interface MediaCSVWriter : NSObject
/**
 * 禁用方法，无法写入CSV文件
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 初始化写入方法

 @param path 文件路径
 @return MediaCSVWriter
 */
- (instancetype)initForWritingToCSVFile:(NSString *)path;

/**
 初始化写入方法

 @param stream 输出流
 @param encoding 编码
 @param delimiter 分隔符
 @return MediaCSVWriter
 */
- (instancetype)initWithOutputStream:(NSOutputStream *)stream encoding:(NSStringEncoding)encoding delimiter:(unichar)delimiter NS_DESIGNATED_INITIALIZER;

/**
 *  Write a field to the output stream
 *
 *  If necessary, this will also write a delimiter to the stream as well. This method takes care of all escaping.
 *
 *  @param field The object to be written to the stream
 *  If you provide an object that is not an @c NSString, its @c description will be written to the stream.
 */

/**
 将文件域写入流

 @param field 域
 */
- (void)writeField:(id)field;

/**
 *  输出流换行
 */
- (void)finishLine;

/**
 换行

 @param fields 文件域
 */
- (void)writeLineOfFields:(id<NSFastEnumeration>)fields;


/**
 换行

 @param dictionary 字典对象
 */
- (void)writeLineWithDictionary:(NSDictionary *)dictionary;


/**
 注释

 @param comment 注释
 */
- (void)writeComment:(NSString *)comment;

/**
 关闭流
 */
- (void)closeStream;

@end

#pragma mark - 、、、、、、、、、、、CSV解析工具类、、、、、、、、、、、、、、、


@class MediaCSVParser;
@protocol MediaCSVParserDelegate <NSObject>
@optional

/**
 开始解析文件流

 @param parser MediaCSVParser
 */
- (void)parserDidBeginDocument:(MediaCSVParser *)parser;


/**
 结束解析文件流

 @param parser MediaCSVParser
 */
- (void)parserDidEndDocument:(MediaCSVParser *)parser;


/**
 开始解析行

 @param parser MediaCSVParser
 @param recordNumber 行序
 */
- (void)parser:(MediaCSVParser *)parser didBeginLine:(NSUInteger)recordNumber;

/**
 结束解析行

 @param parser MediaCSVParser
 @param recordNumber 行序
 */
- (void)parser:(MediaCSVParser *)parser didEndLine:(NSUInteger)recordNumber;


/**
 开始读取当前行内容

 @param parser MediaCSVParser
 @param field 行内容
 @param fieldIndex 行序
 */
- (void)parser:(MediaCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex;


/**
 读取注释

 @param parser MediaCSVParser
 @param comment 注释
 */
- (void)parser:(MediaCSVParser *)parser didReadComment:(NSString *)comment;

/**
 解析过程遇到错误

 @param parser MediaCSVParser
 @param error NSError
 */
- (void)parser:(MediaCSVParser *)parser didFailWithError:(NSError *)error;

@end

@interface MediaCSVParser : NSObject

/**
 代理
 */
@property (assign) id<MediaCSVParserDelegate> delegate;

/**
 审查区域块，如YES，去除双引号
 */
@property (nonatomic, assign) BOOL sanitizesFields;

/**
 去除空格
 */
@property (nonatomic, assign) BOOL trimsWhitespace;

/**
 允许特殊字符
 */
@property (nonatomic, assign) BOOL recognizesBackslashesAsEscapes;

/**
 允许注释
 */
@property (nonatomic, assign) BOOL recognizesComments;

/**
 是否等号开始
 */
@property (nonatomic, assign) BOOL recognizesLeadingEqualSign;

/**
 已读取总字节数
 */
@property (readonly) NSUInteger totalBytesRead;


/**
 * 禁用初始化方法，无法获取输出流
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 初始化方法

 @param stream 输出流
 @param encoding 编码格式
 @param delimiter 分隔符
 @return MediaCSVParser
 */
- (instancetype)initWithInputStream:(NSInputStream *)stream usedEncoding:(inout NSStringEncoding *)encoding delimiter:(unichar)delimiter NS_DESIGNATED_INITIALIZER;

/**
 以CSV字符串初始化

 @param csv CSV字符串
 @return MediaCSVParser
 */
- (instancetype)initWithCSVString:(NSString *)csv;

/**
 指定分隔符字符串初始化

 @param string 含指定分隔符字符串
 @param delimiter 分隔符
 @return MediaCSVParser
 */
- (instancetype)initWithDelimitedString:(NSString *)string delimiter:(unichar)delimiter;

/**
 已CSV文件路径初始化

 @param csvURL CSV文件路径
 @return MediaCSVParser
 */
- (instancetype)initWithContentsOfCSVURL:(NSURL *)csvURL;

/**
 已CSV文件路径，分隔符初始化

 @param URL CSV文件路径
 @param delimiter 分隔符
 @return MediaCSVParser
 */
- (instancetype)initWithContentsOfDelimitedURL:(NSURL *)URL delimiter:(unichar)delimiter;

/**
 开始解析
 */
- (void)parse;

/**
 取消解析
 */
- (void)cancelParsing;

@end
