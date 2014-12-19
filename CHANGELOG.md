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
