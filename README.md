# Pdfinfo
[![Gem Version](https://badge.fury.io/rb/pdfinfo.svg)](http://badge.fury.io/rb/pdfinfo)
[![Build Status](https://travis-ci.org/RyanV/pdfinfo.svg?branch=master)](https://travis-ci.org/RyanV/pdfinfo)
[![Coverage Status](https://img.shields.io/coveralls/RyanV/pdfinfo.svg)](https://coveralls.io/r/RyanV/pdfinfo)

Simple ruby wrapper around pdfinfo utility.
This gem was written and tested around xpdf version 3.04. 


## Depdendecies

usage of this gem assumes that you have xpdf installed (which gives us access to the pdfinfo command).  The fastest way to install xpdf:

    $ brew install xpdf
    
## Installation

Add this line to your application's Gemfile:

    gem 'pdfinfo', '~> 1.1.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pdfinfo

## Usage


```ruby
pdfinfo = Pdfinfo.new("path/to/file.pdf")

pdfinfo.title         #=> "Title" # or nil
pdfinfo.subject       #=> "Subject" # or nil
pdfinfo.keywords      #=> ["Keyword1", "Keyword2"] # or nil
pdfinfo.author        #=> "Author Name" # or nil
pdfinfo.creator       #=> "Creator Name" # or nil
pdfinfo.producer      #=> "Producer Name" # or nil
ddfinfo.creation_date #=> 2014-10-26 20:50:45 -0700 # Time object
pdfinfo.form          #=> "none"
pdfinfo.page_count    #=> 3
pdfinfo.width         #=> 612
pdfinfo.height        #=> 792
pdfinfo.size          #=> 1521 # file size in bytes
pdfinfo.pdf_version   #=> "1.3"
pdfinfo.encrypted?    #=> false # or true
pdfinfo.usage_rights  #=> {print: true, copy: true, change: true, add_notes: true}
pdfinfo.printable?    #=> true  # or false
pdfinfo.copyable?     #=> true  # or false
pdfinfo.changeable?   #=> true  # or false
pdfinfo.modifiable?   #=> true  # or false. alias for #changeable?
pdfinfo.annotatable?  #=> true  # or false
pdfinfo.tagged?       #=> false # or true
```
For encrypted files with a password you can pass in the user or owner password as options

```ruby
pdfinfo = Pdfinfo.new("path/to/encrypted.pdf", user_password: 'foo')
# pdfinfo = Pdfinfo.new("path/to/encrypted.pdf", owner_password: 'foo')
pdfinfo.encrypted?    #=> true
pdfinfo.usage_rights  #=> {print: false, copy: false, change: false, add_notes: false}
```

You can directly set the location of the executable if its not located in your environment $PATH or you just want to point to a different location.

```ruby
Pdfinfo.pdfinfo_command = '/another/bin/path/pdfinfo'
Pdfinfo.pdfinfo_command #=> '/another/bin/path/pdfinfo'
```

## Recent Changes
#### v1.2.0
* add #to_hash method which will output the parsed data as a hash.
* rescue from Time.parse on invalid string format

#### v1.1.0
* Pdfinfo::CommandNotFound raised when pdfinfo command can't be found
* Fixes issue with string re-encoding for non- UTF-8 characters in ruby 1.9.3
* Pdfinfo#exec now correctly supports being passed a Pathname object

## Running specs

generate pdf fixtures by first running 

    $ rake generate_fixtures
    
Then run specs by running

    $ rake

## TODO
* Error handling
* type coersion is getting messy in initialize.  refactor.
