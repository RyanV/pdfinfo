# Pdfinfo

Simple ruby wrapper around the pdfinfo command
NOTE: This gem is only intended to provide quick access to the metadata returned by the pdfinfo command without flags

## Depdendecies

usage of this gem assumes that you have xpdf installed.  The fastest way to install xpdf:

    $ brew install xpdf
    
## Installation

Add this line to your application's Gemfile:

    gem 'pdfinfo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pdfinfo

## Usage


```ruby
pdfinfo = Pdfinfo.new("path/to/file.pdf")

pdfinfo.creator     #=> "Creator Name" # or nil
pdfinfo.producer    #=> "Producer Name" # or nil
pdfinfo.form        #=> "none"
pdfinfo.page_count  #=> 3
pdfinfo.width       #=> 612
pdfinfo.height      #=> 792
pdfinfo.size        #=> 1521 # file size in bytes
pdfinfo.pdf_version #=> "1.3"
pdfinfo.encrypted?  #=> false # or true
pdfinfo.tagged?     #=> false # or true
```

You can directly set the location of the executable if its not located in your environment $PATH or you just want to point to a different location.

```ruby
Pdfinfo.pdfinfo_command = '/another/bin/path/pdfinfo'
Pdfinfo.pdfinfo_command #=> '/another/bin/path/pdfinfo'
```

## Running specs

generate pdf fixtures by first running 

    $ rake generate_fixtures
    
Then run specs by running

    $ rake

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pdfinfo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
