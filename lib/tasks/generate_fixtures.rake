require 'time'
require 'pathname'

desc 'generates pdf for testing'
task :generate_fixtures do
  class PdfGenerator
    ROOT_DIR = File.expand_path("../../..", __FILE__)
    METADATA_OPTIONS = {
      Title: "Pdfinfo Title",
      Author: "Pdfinfo Author",
      Subject: "Pdfinfo Subject",
      Keywords: "Keyword1 Keyword2",
      Creator: "Pdfinfo Creator",
      Producer: "Pdfinfo Producer",
      CreationDate: Time.parse("2014-10-26 18:23:25 -0700")
    }
    ENCRYPTION_PERMISSIONS = {
      print_document: false,
      modify_contents: false,
      copy_contents: false,
      modify_annotations: false
    }
    ENCRYPTION_OPTIONS = {
      user_password: 'foo',
      owner_password: 'bar',
      permissions: ENCRYPTION_PERMISSIONS
    }
    WRITE_PATH_PREFIX = "spec/fixtures/pdfs"
    def self.generate(dest_path, opts = {}, &block)
      new(opts).write_to(dest_path, &block)
    end

    def initialize(opts = {})
      @encryption = opts[:encryption]
    end

    # @param [String] dest_path path relative to gem root directory to write file to
    def write_to(dest_path, &block)
      require 'prawn'
      dest_dir = Pathname.new(File.join(ROOT_DIR, WRITE_PATH_PREFIX))
      dest_dir.mkpath

      dest_path = dest_dir.join(dest_path)

      Prawn::Document.generate(dest_path.to_path, skip_page_creation: true, info: METADATA_OPTIONS, page_size: 'A4') do |pdf|
        if block_given?
          block.call(pdf)
        else
          1.upto(5) do |n|
            pdf.start_new_page
            pdf.text("Page #{n}")
          end
        end

        pdf.encrypt_document(ENCRYPTION_OPTIONS) if @encryption
      end
    end
  end


  PdfGenerator.generate('test.pdf')
  PdfGenerator.generate('encrypted.pdf', encryption: true)
  begin
    PdfGenerator.generate('invalid_utf-8.pdf') do |pdf|
      pdf.start_new_page
      pdf.text("\xFE\xFF")
    end
  rescue Prawn::Errors::IncompatibleStringEncoding => e
    warn(e.message)
  end
end