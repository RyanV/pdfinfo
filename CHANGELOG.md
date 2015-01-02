#### v1.4.1
* bug fix for ruby 2+ hash creation given response string with multiple successive new line characters. (ArgumentError: invalid number of elements (0 for 1..2))
#### v1.4.0
* raise Pdfinfo::CommandFailed when command returns non-zero exit code
#### v1.3.4
* remove #as_json alias. will continue to work when using with rails, which internally calls #to_hash on the object before calling #as_json.
* height, and width are no longer top level keys when converting object to hash.  Pdfinfo#height and Pdfinfo#width are still available, returning respective dimensions of the first page.
#### v1.3.3
* Add/use PageCollection to avoid adding #as_json functionality directly to Array  
#### v1.3.2
* Fix gemspec to correctly include all required files
#### v1.3.1
* Pdfinfo.exec is now a private instance method
* \#modified_date added to parse ModDate
* user can now configure use of .xpdfrc config file
* \#to_hash now uses #to_h, with #to_hash as the fallback
* Added "Page" functionality/parsing
 
#### v1.2.0
* add #to_hash method which will output the parsed data as a hash.
* rescue from Time.parse on invalid string format

#### v1.1.0
* Pdfinfo::CommandNotFound raised when pdfinfo command can't be found
* Fixes issue with string re-encoding for non- UTF-8 characters in ruby 1.9.3
* Pdfinfo#exec now correctly supports being passed a Pathname object
