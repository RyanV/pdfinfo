require 'time'

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

    def self.generate(dest_path, opts = {})
      new(opts).write_to(dest_path)
    end

    def initialize(opts = {})
      @encryption = opts[:encryption]
    end

    # @param [String] dest_path path relative to gem root directory to write file to
    def write_to(dest_path)
      require 'prawn'

      dest_path = File.join(ROOT_DIR, dest_path)

      Prawn::Document.generate(dest_path, skip_page_creation: true, info: METADATA_OPTIONS, page_size: 'A4') do |pdf|
        1.upto(5) do |n|
          pdf.start_new_page
          pdf.text("Page #{n}")
        end

        pdf.encrypt_document(ENCRYPTION_OPTIONS) if @encryption
      end
    end
  end


  PdfGenerator.generate("spec/fixtures/pdfs/test.pdf")
  PdfGenerator.generate("spec/fixtures/pdfs/encrypted.pdf", encryption: true)
  Prawn::Document.generate(File.join(PdfGenerator::ROOT_DIR, 'spec/fixtures/pdfs/invalid_utf-8.pdf')) { text("\xFE\xFF") }
end